/**
 * conversation.js — per-session state and pronoun resolution.
 *
 * "Take me there" only works if there is a resolvable referent. When the focus
 * stack is empty the correct behaviour is to ask, never to guess — guessing a
 * destination is how an assistant sends someone to the wrong financial page.
 *
 * In-memory with TTL. Swap for Redis or the sessions collection when you need
 * this to survive a restart or run multi-instance.
 */
const SESSIONS = new Map();
const TTL_MS = 30 * 60 * 1000;      // 30 minutes
const MAX_TURNS = 12;
const MAX_FOCUS = 5;

/** Phrases that refer back to something already mentioned. */
const REFERENTIAL = [
  'there', 'it', 'that', 'this one', 'that one', 'that game', 'this game',
  'take me there', 'open it', 'show me that', 'go there', 'launch that',
  'same one', 'the one', 'wahan', 'wahan le chalo', 'usko', 'wo wala', 'woh',
  'akkada', 'adi', 'daani',
];

function now() {
  return Date.now();
}

function prune() {
  const cutoff = now() - TTL_MS;
  for (const [id, s] of SESSIONS) {
    if (s.updatedAt < cutoff) SESSIONS.delete(id);
  }
}

export function getSession(sessionId) {
  prune();
  if (!SESSIONS.has(sessionId)) {
    SESSIONS.set(sessionId, {
      session_id: sessionId,
      turns: [],
      focus_stack: [],
      pending_clarification: null,
      pending_confirmation: null,
      createdAt: now(),
      updatedAt: now(),
    });
  }
  const s = SESSIONS.get(sessionId);
  s.updatedAt = now();
  return s;
}

export function addTurn(session, role, content, meta = {}) {
  session.turns.push({ role, content, at: new Date().toISOString(), ...meta });
  if (session.turns.length > MAX_TURNS) {
    session.turns = session.turns.slice(-MAX_TURNS);
  }
  session.updatedAt = now();
}

/** Push an entity to the front of the focus stack. */
export function pushFocus(session, entity) {
  if (!entity?.entity_id) return;
  session.focus_stack = [
    { entity_id: entity.entity_id, entity_type: entity.entity_type, name: entity.name,
      at: new Date().toISOString() },
    ...session.focus_stack.filter((f) => f.entity_id !== entity.entity_id),
  ].slice(0, MAX_FOCUS);
}

/**
 * Does the message rely on something previously mentioned?
 *
 * Matching is word-boundary aware on purpose: a naive substring check treats
 * "deposit" and "withdrawals" as containing the pronoun "it", which silently
 * hijacks ordinary questions into follow-ups against the focused entity.
 */
export function isReferential(query) {
  const q = String(query || '').toLowerCase().trim().replace(/[^\w\s]/g, '');
  if (!q) return false;
  if (q.length > 40) return false;                 // long messages carry their own subject

  const words = q.split(/\s+/).filter(Boolean);
  const wordSet = new Set(words);

  for (const phrase of REFERENTIAL) {
    if (q === phrase) return true;
    if (phrase.includes(' ')) {
      // multi-word phrase: match on a word-boundary regex
      const re = new RegExp(`\\b${phrase.replace(/\s+/g, '\\s+')}\\b`);
      if (re.test(q)) return true;
    } else if (wordSet.has(phrase)) {
      return true;
    }
  }
  return false;
}

/** The entity a pronoun refers to, or null. */
export function resolveReference(session) {
  return session.focus_stack[0] || null;
}

export function setPendingClarification(session, payload) {
  session.pending_clarification = payload;
}

export function setPendingConfirmation(session, payload) {
  session.pending_confirmation = payload;
}

export function clearPending(session) {
  session.pending_clarification = null;
  session.pending_confirmation = null;
}

const AFFIRM = ['yes', 'y', 'yeah', 'yep', 'ok', 'okay', 'sure', 'go', 'go ahead',
  'do it', 'confirm', 'haan', 'ha', 'theek hai', 'sari', 'avunu', 'please do'];
const DENY = ['no', 'n', 'nope', 'cancel', 'stop', 'wait', 'nahi', 'nahin', 'ledu',
  'not now', 'never mind', 'nevermind'];

export function isAffirmation(q) {
  const s = String(q || '').toLowerCase().trim().replace(/[^a-z\s]/g, '');
  return AFFIRM.includes(s) || AFFIRM.some((a) => s === a || s.startsWith(a + ' '));
}

export function isDenial(q) {
  const s = String(q || '').toLowerCase().trim().replace(/[^a-z\s]/g, '');
  return DENY.includes(s) || DENY.some((d) => s === d || s.startsWith(d + ' '));
}

export function sessionStats() {
  prune();
  return { active_sessions: SESSIONS.size };
}

export default {
  getSession, addTurn, pushFocus, isReferential, resolveReference,
  setPendingClarification, setPendingConfirmation, clearPending,
  isAffirmation, isDenial, sessionStats,
};
