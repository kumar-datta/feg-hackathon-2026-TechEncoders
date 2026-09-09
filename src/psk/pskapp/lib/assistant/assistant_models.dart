/// Data types shared by the assistant pipeline and the chat UI.
library;

/// A navigable thing inside the app: a screen, a casino game, a sport, a
/// category. Routes are opaque strings owned by [AssistantRouter]; the model
/// never invents one — it can only name an `entity_id`.
class AssistantEntity {
  final String id;
  final String type; // PAGE | GAME | SPORT | CATEGORY
  final String name;
  final List<String> aliases;
  final String description;
  final String category;
  final String route;
  final List<String> keywords;
  final bool requiresAuth;
  final bool active;

  const AssistantEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.aliases,
    required this.description,
    required this.category,
    required this.route,
    this.keywords = const [],
    this.requiresAuth = false,
    this.active = true,
  });
}

class ResolvedEntity {
  final String entityId;
  final String entityType;
  final String name;
  final String route;
  final bool requiresAuth;
  final bool active;
  final double confidence;
  final String method;

  const ResolvedEntity({
    required this.entityId,
    required this.entityType,
    required this.name,
    required this.route,
    required this.requiresAuth,
    required this.active,
    required this.confidence,
    required this.method,
  });

  ResolvedEntity withConfidence(double c) => ResolvedEntity(
        entityId: entityId,
        entityType: entityType,
        name: name,
        route: route,
        requiresAuth: requiresAuth,
        active: active,
        confidence: c,
        method: method,
      );
}

class ResolveResult {
  final ResolvedEntity? best;
  final List<ResolvedEntity> candidates;
  final bool ambiguous;
  const ResolveResult({required this.best, required this.candidates, required this.ambiguous});
}

/// A knowledge chunk — one FAQ answer, one game-rules section, one policy.
class KnowledgeChunk {
  final String chunkId;
  final String documentId;
  final String title;
  final String content;
  final String category;
  final String documentType;
  final List<String> keywords;
  final List<String> relatedPages;
  final String priority;
  final bool requiresVerifiedSource;
  final String? gameId;

  const KnowledgeChunk({
    required this.chunkId,
    required this.documentId,
    required this.title,
    required this.content,
    required this.category,
    required this.documentType,
    required this.keywords,
    required this.relatedPages,
    required this.priority,
    required this.requiresVerifiedSource,
    this.gameId,
  });

  factory KnowledgeChunk.fromJson(Map<String, dynamic> j) => KnowledgeChunk(
        chunkId: j['chunk_id'] as String,
        documentId: j['document_id'] as String? ?? j['chunk_id'] as String,
        title: j['title'] as String? ?? '',
        content: j['content'] as String? ?? '',
        category: j['category'] as String? ?? '',
        documentType: j['document_type'] as String? ?? 'FAQ',
        keywords: (j['keywords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        relatedPages: (j['related_pages'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        priority: j['priority'] as String? ?? 'medium',
        requiresVerifiedSource: j['requires_verified_source'] == true,
        gameId: j['game_id'] as String?,
      );
}

class RetrievalHit {
  final KnowledgeChunk chunk;
  double score;
  final List<String> methods;
  RetrievalHit(this.chunk, this.score, this.methods);
}

class AssistantAction {
  final String action; // OPEN_GAME | OPEN_PAGE | OPEN_DEPOSIT ...
  final String label;
  final String entityId;
  final String entityType;
  final String route;
  final bool requiresAuth;
  final bool requiresConfirmation;
  final bool active;

  const AssistantAction({
    required this.action,
    required this.label,
    required this.entityId,
    required this.entityType,
    required this.route,
    required this.requiresAuth,
    required this.requiresConfirmation,
    required this.active,
  });

  AssistantAction copyWith({bool? requiresConfirmation}) => AssistantAction(
        action: action,
        label: label,
        entityId: entityId,
        entityType: entityType,
        route: route,
        requiresAuth: requiresAuth,
        requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
        active: active,
      );

  Map<String, dynamic> toJson() => {
        'action': action,
        'label': label,
        'entity_id': entityId,
        'entity_type': entityType,
        'route': route,
        'requires_auth': requiresAuth,
        'requires_confirmation': requiresConfirmation,
      };

  factory AssistantAction.fromJson(Map<String, dynamic> j) => AssistantAction(
        action: j['action'] as String? ?? 'OPEN_PAGE',
        label: j['label'] as String? ?? '',
        entityId: j['entity_id'] as String? ?? '',
        entityType: j['entity_type'] as String? ?? 'PAGE',
        route: j['route'] as String? ?? '',
        requiresAuth: j['requires_auth'] == true,
        requiresConfirmation: j['requires_confirmation'] == true,
        active: true,
      );
}

class ClarificationOption {
  final String entityId;
  final String label;
  final String entityType;
  const ClarificationOption({required this.entityId, required this.label, required this.entityType});

  Map<String, dynamic> toJson() => {'entity_id': entityId, 'label': label, 'entity_type': entityType};
  factory ClarificationOption.fromJson(Map<String, dynamic> j) => ClarificationOption(
        entityId: j['entity_id'] as String? ?? '',
        label: j['label'] as String? ?? '',
        entityType: j['entity_type'] as String? ?? 'PAGE',
      );
}

class AssistantSource {
  final String chunkId;
  final String title;
  final String documentType;
  final double score;
  final bool requiresVerifiedSource;
  const AssistantSource({
    required this.chunkId,
    required this.title,
    required this.documentType,
    required this.score,
    required this.requiresVerifiedSource,
  });

  Map<String, dynamic> toJson() => {
        'chunk_id': chunkId,
        'title': title,
        'document_type': documentType,
        'score': score,
        'requires_verified_source': requiresVerifiedSource,
      };
  factory AssistantSource.fromJson(Map<String, dynamic> j) => AssistantSource(
        chunkId: j['chunk_id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        documentType: j['document_type'] as String? ?? '',
        score: (j['score'] as num?)?.toDouble() ?? 0,
        requiresVerifiedSource: j['requires_verified_source'] == true,
      );
}

/// The assistant's reply to one user message.
class AssistantReply {
  final String intent;
  final double confidence;
  final String answer;
  final List<AssistantAction> actions;
  final List<ClarificationOption> clarification;
  final List<AssistantSource> sources;
  final bool requiresConfirmation;
  final String? refusalReason;
  final String? navigateRoute; // set only when the jump is safe
  final String? answerMode;
  final String? resolvedBy;

  const AssistantReply({
    this.intent = 'UNKNOWN',
    this.confidence = 0,
    this.answer = '',
    this.actions = const [],
    this.clarification = const [],
    this.sources = const [],
    this.requiresConfirmation = false,
    this.refusalReason,
    this.navigateRoute,
    this.answerMode,
    this.resolvedBy,
  });
}

/// One bubble in the chat transcript, persisted between launches.
class ChatMessage {
  final String role; // user | assistant
  final String content;
  final DateTime at;
  final List<AssistantAction> actions;
  final List<ClarificationOption> clarification;
  final List<AssistantSource> sources;
  final String? intent;
  final String? refusal;
  final bool error;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.at,
    this.actions = const [],
    this.clarification = const [],
    this.sources = const [],
    this.intent,
    this.refusal,
    this.error = false,
  });

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'at': at.toIso8601String(),
        'actions': actions.map((a) => a.toJson()).toList(),
        'clarification': clarification.map((c) => c.toJson()).toList(),
        'sources': sources.map((s) => s.toJson()).toList(),
        'intent': intent,
        'refusal': refusal,
        'error': error,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        role: j['role'] as String? ?? 'assistant',
        content: j['content'] as String? ?? '',
        at: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime.now(),
        actions: (j['actions'] as List<dynamic>? ?? [])
            .map((a) => AssistantAction.fromJson(a as Map<String, dynamic>))
            .toList(),
        clarification: (j['clarification'] as List<dynamic>? ?? [])
            .map((c) => ClarificationOption.fromJson(c as Map<String, dynamic>))
            .toList(),
        sources: (j['sources'] as List<dynamic>? ?? [])
            .map((s) => AssistantSource.fromJson(s as Map<String, dynamic>))
            .toList(),
        intent: j['intent'] as String?,
        refusal: j['refusal'] as String?,
        error: j['error'] == true,
      );
}
