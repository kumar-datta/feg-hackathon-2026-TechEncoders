import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/casino_game.dart';
import 'actions.dart';
import 'assistant_models.dart';
import 'conversation.dart';
import 'entity_registry.dart';
import 'intent.dart';
import 'refusals.dart';
import 'resolver.dart';
import 'retriever.dart';

/// The on-device orchestrator — a port of the website's `assistant/index.js`.
///
/// Pipeline for every message:
///   1. safety refusal check (code, before anything else)
///   2. pending confirmation / clarification handling
///   3. orphan yes/no guard
///   4. intent classification (rules)
///   5. reference resolution ("take me there")
///   6. entity resolution  OR  hybrid retrieval
///   7. confidence gate
///   8. action construction from the registry
///   9. focus stack update
///
/// The core invariant is preserved: an answer can only *name* an entity, and
/// [ActionBuilder] is the only thing that turns that into a route.
class AssistantService {
  static const Set<String> _navIntents = {
    'NAVIGATE', 'DEPOSIT', 'WITHDRAW', 'BET_HISTORY', 'ACCOUNT', 'KYC', 'PROMOTION', 'SUPPORT', 'RESPONSIBLE_GAMING',
  };
  static const Set<String> _infoIntents = {'FAQ', 'GAME_INFO', 'PROMOTION'};

  final EntityResolver resolver = EntityResolver();
  final Retriever retriever = Retriever();
  late final ActionBuilder actions = ActionBuilder(resolver);
  final ConversationSession session = ConversationSession();

  bool _ready = false;
  bool get isReady => _ready;
  int get chunkCount => retriever.chunkCount;
  int get entityCount => resolver.all.length;

  /// Loads the knowledge corpus from assets and builds the indexes.
  Future<void> initialize(List<CasinoGame> games) async {
    if (_ready) return;
    resolver.load(EntityRegistry.build(games));
    try {
      final raw = await rootBundle.loadString('assets/assistant/knowledge.json');
      final list = jsonDecode(raw) as List<dynamic>;
      final chunks = list.map((j) => KnowledgeChunk.fromJson(j as Map<String, dynamic>)).toList();
      // entity alias sentences: a recall aid only; truth stays in the registry
      for (final e in resolver.all) {
        chunks.add(KnowledgeChunk(
          chunkId: 'doc_entity_${e.id}',
          documentId: 'doc_entity_${e.id}',
          title: '${e.name} (${e.type})',
          content: '${e.name} is ${e.description} It is in the ${e.category} section. '
              '${e.aliases.isNotEmpty ? 'It is also called: ${e.aliases.take(8).join(', ')}.' : ''}',
          category: 'NAVIGATION',
          documentType: 'ENTITY_ALIAS',
          keywords: e.keywords,
          relatedPages: [e.id],
          priority: 'low',
          requiresVerifiedSource: false,
        ));
      }
      retriever.build(chunks);
    } catch (_) {
      // knowledge asset missing: navigation still works, FAQ answers fall back
      retriever.build(const []);
    }
    _ready = true;
  }

  /// Refresh the registry when the catalogue changes.
  void reloadEntities(List<CasinoGame> games) => resolver.load(EntityRegistry.build(games));

  Future<AssistantReply> handle(String message, {required bool authenticated}) async {
    final text = message.trim();
    if (text.isEmpty) return const AssistantReply(answer: 'What can I help you with?');

    /* ---------- 1. hard safety refusals ---------- */
    final refusal = RefusalChecker.check(text);
    if (refusal != null) {
      session.clearPending();
      return AssistantReply(
        intent: 'RESPONSIBLE_GAMING',
        confidence: 0.99,
        answer: refusal.message,
        actions: actions.buildAll(['page_responsible_gaming', 'page_contact']),
        refusalReason: refusal.id,
      );
    }

    /* ---------- 2. pending confirmation ---------- */
    final pendingConfirm = session.pendingConfirmation;
    if (pendingConfirm != null) {
      if (ConversationSession.isAffirmation(text)) {
        session.clearPending();
        final action = actions.build(pendingConfirm.entityId, intent: pendingConfirm.intent);
        final gate = checkGates(action, authenticated: authenticated);
        final name = resolver.getEntity(pendingConfirm.entityId)?.name ?? 'that page';
        return AssistantReply(
          intent: pendingConfirm.intent,
          confidence: 0.97,
          answer: gate.allowed ? 'Opening $name.' : _gateMessage(gate, name),
          actions: gate.allowed && action != null ? [action] : _gateActions(gate, action),
          navigateRoute: gate.allowed ? action?.route : null,
          resolvedBy: 'confirmation_accepted',
        );
      }
      if (ConversationSession.isDenial(text)) {
        session.clearPending();
        return const AssistantReply(intent: 'AMBIGUOUS', answer: 'No problem — what would you like to do instead?');
      }
      session.clearPending(); // anything else: treat as a new query
    }

    /* ---------- 3. pending clarification ---------- */
    final pendingClarify = session.pendingClarification;
    if (pendingClarify != null) {
      final lower = text.toLowerCase();
      ClarificationOption? picked;
      for (final o in pendingClarify.options) {
        if (lower.contains(o.label.toLowerCase()) || lower.contains(o.entityId)) {
          picked = o;
          break;
        }
      }
      session.clearPending();
      if (picked != null) {
        return _navigateTo(picked.entityId, 'NAVIGATE', authenticated, 'clarification_answered', 0.96);
      }
    }

    /* ---------- 3b. orphan yes/no ---------- */
    if (ConversationSession.isAffirmation(text) || ConversationSession.isDenial(text)) {
      return const AssistantReply(intent: 'AMBIGUOUS', confidence: 0.3, answer: 'Sorry — what would you like me to do?');
    }

    /* ---------- 4. intent ---------- */
    final classified = IntentClassifier.classify(text);
    final intent = classified.intent;
    final intentConf = classified.confidence;

    /* ---------- 5. referential follow-up ---------- */
    if (ConversationSession.isReferential(text)) {
      final focus = session.resolveReference();
      if (focus == null) {
        return const AssistantReply(
          intent: 'AMBIGUOUS',
          confidence: 0.3,
          answer: 'Where would you like to go? I have lost track of what that refers to.',
          requiresConfirmation: true,
        );
      }
      return _navigateTo(focus.entityId, intent == 'UNKNOWN' ? 'NAVIGATE' : intent, authenticated, 'focus_stack', 0.93);
    }

    /* ---------- 6. account data never comes from RAG ---------- */
    if (intent == 'ACCOUNT_DATA') {
      return AssistantReply(
        intent: 'ACCOUNT_DATA',
        confidence: intentConf,
        answer: authenticated
            ? "I don't read balances or bet outcomes from the help content — those live in your account. "
                'Your wallet and tickets show them directly.'
            : "I can't see account balances or bets — those live in your account. Log in and the wallet and tickets show them directly.",
        actions: actions.buildAll(['page_account', 'page_tickets']),
      );
    }

    /* ---------- 6b. explicitly ambiguous ---------- */
    if (intent == 'AMBIGUOUS') {
      return _clarify(resolver.resolve(text).candidates, text);
    }

    /* ---------- 7. navigation ---------- */
    if (_navIntents.contains(intent)) {
      final typeHint = intent == 'NAVIGATE' ? null : 'PAGE';
      final res = resolver.resolve(text, typeHint: typeHint);
      final best = res.best;

      final implied = switch (intent) {
        'DEPOSIT' => 'page_deposit',
        'WITHDRAW' => 'page_account',
        'BET_HISTORY' => 'page_tickets',
        'KYC' => 'page_account',
        'PROMOTION' => 'page_promotions',
        'SUPPORT' => 'page_contact',
        'RESPONSIBLE_GAMING' => 'page_responsible_gaming',
        'ACCOUNT' => 'page_account',
        _ => null,
      };

      final unavailableNote = switch (intent) {
        'WITHDRAW' => 'This demo has no withdrawal flow — balances are demo credits only. Your account page shows your balance and history.',
        'KYC' => 'This demo has no identity verification step. Your account page has the settings that do exist, including play limits.',
        _ => null,
      };
      if (unavailableNote != null) {
        return AssistantReply(
          intent: intent,
          confidence: intentConf,
          answer: unavailableNote,
          actions: actions.buildAll([implied!, 'page_help']),
        );
      }

      final target = (best != null && best.confidence >= EntityResolver.navigateWithHint)
          ? best.entityId
          : implied ?? best?.entityId;

      if (target == null || (res.ambiguous && implied == null)) {
        return _clarify(res.candidates, text);
      }

      final conf = implied != null && (best == null || best.confidence < EntityResolver.navigateWithHint)
          ? (intentConf > 0.9 ? intentConf : 0.9)
          : best!.confidence;

      return _navigateTo(target, intent, authenticated, best?.method ?? 'intent_implied', conf);
    }

    /* ---------- 8. informational ---------- */
    if (_infoIntents.contains(intent) || intent == 'SEARCH' || intent == 'UNKNOWN') {
      final res = resolver.resolve(text);
      final best = res.best;

      // an unmistakable entity match outranks an unsure intent: "help", "promotions"
      if (intent == 'UNKNOWN' && best != null && best.confidence >= 0.95) {
        return _navigateTo(best.entityId, 'NAVIGATE', authenticated, best.method, best.confidence);
      }

      String? gameFilter = Retriever.inferGame(text);
      if (best != null && best.confidence >= 0.7 && best.entityType == 'GAME') {
        gameFilter = _knowledgeGameFor(best.entityId);
      }
      final cat = Retriever.inferCategory(text);
      final hits = retriever.retrieve(
        text,
        category: intent == 'FAQ' || intent == 'GAME_INFO' ? cat : null,
        gameId: gameFilter,
      );

      if (hits.isEmpty) {
        if (intent == 'UNKNOWN') {
          return AssistantReply(
            intent: 'UNKNOWN',
            confidence: 0.3,
            answer: "I'm not sure about that one. I can help you find a game, get to a screen, "
                'or answer questions about deposits, bets, verification and promotions.',
            actions: actions.buildAll(['page_help', 'page_contact']),
          );
        }
        return AssistantReply(
          intent: intent,
          confidence: intentConf,
          answer: "I don't have that in the help content. Support can help you directly.",
          actions: actions.buildAll(['page_help', 'page_contact']),
        );
      }

      final composed = _extractiveAnswer(hits);
      final primary = best != null && best.confidence >= 0.7 ? actions.build(best.entityId) : null;

      final relatedIds = <String>{};
      for (final h in hits) {
        relatedIds.addAll(h.chunk.relatedPages);
      }
      relatedIds.remove(best?.entityId);

      final replyActions = <AssistantAction>[
        ?primary,
        ...actions.buildAll(relatedIds.take(2)),
        ...actions.supporting(intent, best?.entityId).take(1),
      ].take(3).toList();

      if (best != null && best.confidence >= 0.7) {
        session.pushFocus(best.entityId, best.entityType, best.name);
      }

      return AssistantReply(
        intent: intent,
        confidence: intentConf,
        answer: composed,
        answerMode: 'extractive',
        actions: replyActions,
        sources: hits
            .map((h) => AssistantSource(
                  chunkId: h.chunk.chunkId,
                  title: h.chunk.title,
                  documentType: h.chunk.documentType,
                  score: (h.score * 100).round() / 100,
                  requiresVerifiedSource: h.chunk.requiresVerifiedSource,
                ))
            .toList(),
      );
    }

    return AssistantReply(
      intent: 'UNKNOWN',
      answer: "I didn't quite follow. Could you rephrase that?",
      actions: actions.buildAll(['page_help']),
    );
  }

  /// Maps an app game entity to the knowledge-base game id (the corpus covers
  /// engines, not individual titles).
  String? _knowledgeGameFor(String entityId) {
    final e = resolver.getEntity(entityId);
    if (e == null) return null;
    final t = e.name.toLowerCase();
    if (t.contains('roulette')) return 'game_roulette';
    if (t.contains('blackjack')) return 'game_blackjack';
    if (t.contains('baccarat')) return 'game_baccarat';
    if (t.contains('poker')) return 'game_blackjack';
    return 'category_slots';
  }

  /// Extractive answer: returns the retrieved text verbatim, so it cannot
  /// hallucinate. Policy-flagged chunks get the "no exact figures" note.
  String _extractiveAnswer(List<RetrievalHit> hits) {
    final top = hits.first.chunk;
    if (top.requiresVerifiedSource) {
      return "${top.content}\n\nI can't give you exact figures for this — they have to come from the official policy rather than from me.";
    }
    return top.content;
  }

  String _gateMessage(GateResult gate, String name) {
    if (gate.gate == 'login') return "You'll need to log in first to reach $name.";
    if (gate.gate == 'unavailable') return "That isn't available right now.";
    return "I can't open that at the moment.";
  }

  List<AssistantAction> _gateActions(GateResult gate, AssistantAction? action) {
    if (gate.gate == 'login') return [?action, ...actions.buildAll(['page_login'])];
    return actions.buildAll(['page_help']);
  }

  AssistantReply _navigateTo(String entityId, String intent, bool authenticated, String resolvedBy, double confidence) {
    final action = actions.build(entityId, intent: intent);
    if (action == null) {
      return AssistantReply(
        intent: 'UNKNOWN',
        answer: "I couldn't find that in the app.",
        actions: actions.buildAll(['page_help']),
      );
    }

    final gate = checkGates(action, authenticated: authenticated);
    final financial = ActionBuilder.confirmActions.contains(action.action);

    // financial destinations always confirm, regardless of confidence
    if (financial && gate.allowed) {
      session.pendingConfirmation = PendingConfirmation(entityId, intent);
      final target = action.label.replaceFirst(RegExp(r'^\w+\s'), '');
      return AssistantReply(
        intent: intent,
        confidence: confidence,
        answer: 'I can take you to $target. Shall I?',
        actions: [action.copyWith(requiresConfirmation: true)],
        requiresConfirmation: true,
        resolvedBy: resolvedBy,
      );
    }

    if (!gate.allowed) {
      return AssistantReply(
        intent: intent,
        confidence: confidence,
        answer: _gateMessage(gate, resolver.getEntity(entityId)?.name ?? 'that'),
        actions: _gateActions(gate, action),
        resolvedBy: resolvedBy,
      );
    }

    session.pushFocus(entityId, action.entityType, action.label);
    final name = resolver.getEntity(entityId)!.name;
    return AssistantReply(
      intent: intent,
      confidence: confidence,
      answer: 'Opening $name.',
      actions: [action],
      navigateRoute: confidence >= EntityResolver.navigateDirect ? action.route : null,
      resolvedBy: resolvedBy,
    );
  }

  AssistantReply _clarify(List<ResolvedEntity> candidates, String text) {
    final options = candidates
        .take(3)
        .map((c) => ClarificationOption(entityId: c.entityId, label: c.name, entityType: c.entityType))
        .toList();
    session.pendingClarification = PendingClarification(text, options);
    return AssistantReply(
      intent: 'AMBIGUOUS',
      confidence: candidates.isEmpty ? 0.2 : candidates.first.confidence,
      answer: options.isNotEmpty
          ? 'I want to make sure I take you to the right place — which did you mean?'
          : "Could you tell me which game or screen you're looking for?",
      clarification: options,
      actions: actions.buildAll(options.map((o) => o.entityId)),
      requiresConfirmation: true,
    );
  }
}
