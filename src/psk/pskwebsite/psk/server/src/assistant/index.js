/**
 * index.js — the assistant orchestrator.
 *
 * Pipeline:
 *   1. safety refusal check (code, before anything else)
 *   2. pending confirmation / clarification handling
 *   3. intent classification (rules -> model if unsure)
 *   4. reference resolution ("take me there")
 *   5. entity resolution  OR  hybrid retrieval  OR  API handoff
 *   6. confidence gate
 *   7. action construction from the registry
 *   8. state update
 */
import { classify } from './intent.js';
import { resolve, getEntity } from './resolver.js';
import { retrieve, indexStats, inferCategory } from './retriever.js';
import { answer, checkRefusal } from './generate.js';
import { buildAction, buildActions, checkGates, supportingActions } from './actions.js';
import { detectLanguage } from './normalize.js';
import config, { describeMode } from './config.js';
import {
  getSession, addTurn, pushFocus, isReferential, resolveReference,
  setPendingClarification, setPendingConfirmation, clearPending,
  isAffirmation, isDenial,
} from './conversation.js';

const NAV_INTENTS = new Set(['NAVIGATE', 'DEPOSIT', 'WITHDRAW', 'BET_HISTORY',
  'ACCOUNT', 'KYC', 'PROMOTION', 'SUPPORT', 'RESPONSIBLE_GAMING']);
const INFO_INTENTS = new Set(['FAQ', 'GAME_INFO', 'PROMOTION']);

const reply = (o) => ({
  intent: 'UNKNOWN', confidence: 0, entity: null, answer: '', actions: [],
  sources: [], requires_confirmation: false, ...o,
});

/**
 * @param {string} message
 * @param {object} opts { sessionId, user: { authenticated, kyc_status, region, language } }
 */
export async function handleQuery(message, opts = {}) {
  const text = String(message || '').trim();
  const session = getSession(opts.sessionId || 'anon');
  const user = opts.user || {};
  const language = user.language || detectLanguage(text);

  if (!text) {
    return reply({ intent: 'UNKNOWN', answer: 'What can I help you with?' });
  }

  addTurn(session, 'user', text);

  /* ---------- 1. hard safety refusals ---------- */
  const refusal = checkRefusal(text);
  if (refusal) {
    const acts = buildActions(['page_responsible_gaming', 'page_contact']);
    const out = reply({
      intent: 'RESPONSIBLE_GAMING',
      confidence: 0.99,
      answer: refusal.message,
      actions: acts,
      refusal_reason: refusal.id,
    });
    addTurn(session, 'assistant', out.answer, { refusal: refusal.id });
    clearPending(session);
    return out;
  }

  /* ---------- 2. pending confirmation ---------- */
  if (session.pending_confirmation) {
    const pending = session.pending_confirmation;
    if (isAffirmation(text)) {
      clearPending(session);
      const action = buildAction(pending.entity_id, { intent: pending.intent });
      const gate = checkGates(action, user);
      const out = reply({
        intent: pending.intent,
        confidence: 0.97,
        entity: entityBrief(pending.entity_id),
        answer: gate.allowed
          ? `Opening ${getEntity(pending.entity_id).name}.`
          : gateMessage(gate, action),
        actions: gate.allowed ? [action] : gateActions(gate, action),
        navigate: gate.allowed ? action.route : null,
        resolved_by: 'confirmation_accepted',
      });
      addTurn(session, 'assistant', out.answer);
      return out;
    }
    if (isDenial(text)) {
      clearPending(session);
      const out = reply({
        intent: 'AMBIGUOUS',
        answer: 'No problem — what would you like to do instead?',
      });
      addTurn(session, 'assistant', out.answer);
      return out;
    }
    clearPending(session);   // anything else: treat as a new query
  }

  /* ---------- 3. pending clarification ---------- */
  if (session.pending_clarification) {
    const options = session.pending_clarification.options || [];
    const picked = options.find((o) =>
      text.toLowerCase().includes(o.label.toLowerCase()) ||
      text.toLowerCase().includes(o.entity_id));
    if (picked) {
      clearPending(session);
      return await navigateTo(picked.entity_id, 'NAVIGATE', session, user,
        'clarification_answered', 0.96);
    }
    clearPending(session);
  }

  /* ---------- 3b. orphan yes/no ---------- */
  // With nothing pending, a bare affirmation has no referent. Answering it from
  // RAG produces a confident non-sequitur, so ask instead.
  if (isAffirmation(text) || isDenial(text)) {
    const out = reply({
      intent: 'AMBIGUOUS',
      confidence: 0.3,
      answer: 'Sorry — what would you like me to do?',
    });
    addTurn(session, 'assistant', out.answer);
    return out;
  }

  /* ---------- 4. intent ---------- */
  const { intent, confidence: intentConf, method } = await classify(text);

  /* ---------- 5. referential follow-up ---------- */
  if (isReferential(text)) {
    const focus = resolveReference(session);
    if (!focus) {
      const out = reply({
        intent: 'AMBIGUOUS',
        confidence: 0.3,
        answer: 'Where would you like to go? I have lost track of what that refers to.',
        clarification: { question: 'What would you like me to open?', options: [] },
        requires_confirmation: true,
      });
      addTurn(session, 'assistant', out.answer);
      return out;
    }
    return await navigateTo(focus.entity_id, intent === 'UNKNOWN' ? 'NAVIGATE' : intent,
      session, user, 'focus_stack', 0.93);
  }

  /* ---------- 6. account data never comes from RAG ---------- */
  if (intent === 'ACCOUNT_DATA') {
    const acts = buildActions(['page_account', 'page_tickets', 'page_account']);
    const out = reply({
      intent: 'ACCOUNT_DATA',
      confidence: intentConf,
      answer: 'I can\'t see account balances, bets or verification status — those live in '
        + 'your account rather than in the help content. These pages show them directly.',
      actions: acts,
      notes: ['Account data must be fetched from the account API with the user session, '
        + 'never from the knowledge base.'],
    });
    addTurn(session, 'assistant', out.answer);
    return out;
  }

  /* ---------- 6b. explicitly ambiguous ---------- */
  if (intent === 'AMBIGUOUS') {
    const { candidates } = resolve(text);
    return clarify(candidates, session, text);
  }

  /* ---------- 7. navigation ---------- */
  if (NAV_INTENTS.has(intent)) {
    const typeHint = intent === 'NAVIGATE' ? null : 'PAGE';
    const { best, candidates, ambiguous } = resolve(text, { typeHint });

    // intent-implied destination when no entity was named ("i want to deposit")
    // Mapped against the real registry. This build has no withdrawal or KYC
    // flow, so those intents go to the nearest real page and the reply says so
    // rather than routing to a URL that does not exist.
    const implied = {
      DEPOSIT: 'page_deposit',
      WITHDRAW: 'page_account',
      BET_HISTORY: 'page_tickets',
      KYC: 'page_account',
      PROMOTION: 'page_promotions',
      SUPPORT: 'page_contact',
      RESPONSIBLE_GAMING: 'page_responsible_gaming',
      ACCOUNT: 'page_account',
    }[intent];

    const unavailableNote = {
      WITHDRAW: 'This demo has no withdrawal flow — balances are demo credits only. '
        + 'Your account page shows your balance and history.',
      KYC: 'This demo has no identity verification step. Your account page has the '
        + 'settings that do exist, including play limits.',
    }[intent];

    if (unavailableNote) {
      const out = reply({
        intent,
        confidence: intentConf,
        entity: entityBrief(implied),
        answer: unavailableNote,
        actions: buildActions([implied, 'page_help']),
      });
      addTurn(session, 'assistant', out.answer);
      return out;
    }

    const target = (best && best.confidence >= config.thresholds.navigateWithHint)
      ? best.entity_id
      : implied || best?.entity_id;

    if (!target || (ambiguous && !implied)) {
      return clarify(candidates, session, text);
    }

    const conf = implied && (!best || best.confidence < config.thresholds.navigateWithHint)
      ? Math.max(intentConf, 0.9)
      : best.confidence;

    return await navigateTo(target, intent, session, user,
      best?.method || 'intent_implied', conf);
  }

  /* ---------- 8. informational ---------- */
  if (INFO_INTENTS.has(intent) || intent === 'SEARCH' || intent === 'UNKNOWN') {
    const { best } = resolve(text);

    // an unmistakable entity match outranks an unsure intent: "help", "promotions"
    if (intent === 'UNKNOWN' && best && best.confidence >= 0.95) {
      return await navigateTo(best.entity_id, 'NAVIGATE', session, user,
        best.method, best.confidence);
    }

    const filters = {};
    if (best && best.confidence >= 0.7 && best.entity_type === 'GAME') {
      filters.game_id = best.entity_id;
    }
    // deposit and withdrawal FAQs are lexically near-identical, so route by category
    const cat = inferCategory(text);
    if (cat && intent === 'FAQ') filters.category = cat;

    const hits = await retrieve(text, filters);

    if (!hits.length) {
      if (intent === 'UNKNOWN') {
        const out = reply({
          intent: 'UNKNOWN',
          confidence: 0.3,
          answer: 'I\'m not sure about that one. I can help you find a game, get to a page, '
            + 'or answer questions about deposits, withdrawals, verification and promotions.',
          actions: buildActions(['page_help', 'page_contact']),
        });
        addTurn(session, 'assistant', out.answer);
        return out;
      }
      const out = reply({
        intent,
        confidence: intentConf,
        answer: 'I don\'t have that in the help content. Support can help you directly.',
        actions: buildActions(['page_help', 'page_contact']),
      });
      addTurn(session, 'assistant', out.answer);
      return out;
    }

    const composed = await answer(text, hits, { language });
    const primary = best && best.confidence >= 0.7 ? buildAction(best.entity_id) : null;

    // page links attached to the retrieved FAQ become buttons
    const relatedIds = [...new Set(hits.flatMap((h) => h.payload.related_pages || []))]
      .filter((id) => id !== best?.entity_id)
      .slice(0, 2);

    const actions = [
      ...(primary ? [primary] : []),
      ...buildActions(relatedIds),
      ...supportingActions(intent, best?.entity_id).slice(0, 1),
    ].slice(0, 3);

    if (best?.confidence >= 0.7) pushFocus(session, best);

    const out = reply({
      intent,
      confidence: intentConf,
      entity: best && best.confidence >= 0.7 ? entityBrief(best.entity_id) : null,
      answer: composed.text,
      answer_mode: composed.mode,
      actions,
      sources: hits.map((h) => ({
        chunk_id: h.chunk_id,
        document_type: h.payload.document_type,
        title: h.payload.title,
        score: Math.round(h.score * 100) / 100,
        requires_verified_source: Boolean(h.payload.requires_verified_source),
      })),
    });
    addTurn(session, 'assistant', out.answer);
    return out;
  }

  /* ---------- fallback ---------- */
  const out = reply({
    intent: 'UNKNOWN',
    answer: 'I didn\'t quite follow. Could you rephrase that?',
    actions: buildActions(['page_help']),
  });
  addTurn(session, 'assistant', out.answer);
  return out;
}

/* ------------------------------------------------------------------ */
function entityBrief(id) {
  const e = getEntity(id);
  return e ? { entity_id: e.id, entity_type: e.type, name: e.name } : null;
}

function gateMessage(gate, action) {
  const name = getEntity(action.entity_id)?.name || 'that page';
  if (gate.gate === 'login') return `You'll need to log in first to reach ${name}.`;
  if (gate.gate === 'kyc') return 'That page needs identity verification to be complete first.';
  if (gate.gate === 'unavailable') return 'That isn\'t available right now.';
  return 'I can\'t open that at the moment.';
}

function gateActions(gate, action) {
  if (gate.gate === 'kyc') return buildActions(['page_account', 'page_help']);
  if (gate.gate === 'login') return [action];   // the UI routes through its login wall
  return buildActions(['page_help']);
}

async function navigateTo(entityId, intent, session, user, resolvedBy, confidence) {
  const action = buildAction(entityId, { intent });
  if (!action) {
    return reply({
      intent: 'UNKNOWN',
      answer: 'I couldn\'t find that on the site.',
      actions: buildActions(['page_help']),
    });
  }

  const gate = checkGates(action, user);
  const financial = config.confirmActions.has(action.action);

  // financial destinations always confirm, regardless of confidence
  if (financial && gate.allowed) {
    setPendingConfirmation(session, { entity_id: entityId, intent });
    const out = reply({
      intent,
      confidence,
      entity: entityBrief(entityId),
      answer: `I can take you to ${action.label.replace(/^\w+\s/, '')}. Shall I?`,
      actions: [{ ...action, requires_confirmation: true }],
      requires_confirmation: true,
      resolved_by: resolvedBy,
      notes: ['Financial destination — confirmation required regardless of confidence.'],
    });
    addTurn(session, 'assistant', out.answer);
    return out;
  }

  if (!gate.allowed) {
    const out = reply({
      intent,
      confidence,
      entity: entityBrief(entityId),
      answer: gateMessage(gate, action),
      actions: gateActions(gate, action),
      resolved_by: resolvedBy,
      gate: gate.gate,
    });
    addTurn(session, 'assistant', out.answer);
    return out;
  }

  pushFocus(session, { entity_id: entityId, entity_type: action.entity_type, name: action.label });

  const out = reply({
    intent,
    confidence,
    entity: entityBrief(entityId),
    answer: `Opening ${getEntity(entityId).name}.`,
    actions: [action],
    navigate: confidence >= config.thresholds.navigateDirect ? action.route : null,
    resolved_by: resolvedBy,
  });
  addTurn(session, 'assistant', out.answer);
  return out;
}

function clarify(candidates, session, text) {
  const options = candidates.slice(0, 3).map((c) => ({
    entity_id: c.entity_id, label: c.name, entity_type: c.entity_type,
  }));
  setPendingClarification(session, { query: text, options });

  const out = reply({
    intent: 'AMBIGUOUS',
    confidence: candidates[0]?.confidence || 0.2,
    answer: options.length
      ? 'I want to make sure I take you to the right place — which did you mean?'
      : 'Could you tell me which game or page you\'re looking for?',
    clarification: {
      question: options.length ? 'Which one did you mean?' : 'What would you like to open?',
      options,
    },
    actions: buildActions(options.map((o) => o.entity_id)),
    requires_confirmation: true,
  });
  addTurn(session, 'assistant', out.answer);
  return out;
}

export function assistantStatus() {
  return { mode: describeMode(), ...indexStats() };
}

export default { handleQuery, assistantStatus };
