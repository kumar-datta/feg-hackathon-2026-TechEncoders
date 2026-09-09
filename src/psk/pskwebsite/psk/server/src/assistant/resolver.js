/**
 * resolver.js — deterministic entity resolution.
 *
 * Resolution ladder (stops at the first confident hit):
 *   1. exact alias match                    -> 0.98
 *   2. normalised exact                     -> 0.95
 *   3. command-translated exact             -> 0.93   ("aviator kholo")
 *   4. alias contained in the query         -> 0.88
 *   5. token overlap / keyword match        -> 0.60-0.85
 *   6. trigram + edit similarity (typos)    -> 0.55-0.90
 *   below the clarify threshold             -> candidates, no pick
 *
 * The model never chooses a route. It gets an entity_id from here, and the
 * action layer maps that id to a route from the registry.
 */
import { normalize, translateCommands, trigramSimilarity, editSimilarity, tokens }
  from './normalize.js';
import config from './config.js';

let ENTITIES = [];
let ALIAS_INDEX = new Map();   // normalised alias -> [entity_id]

export function loadEntities(entities, aliases) {
  ENTITIES = entities;
  ALIAS_INDEX = new Map();
  const add = (alias, id) => {
    const key = normalize(alias);
    if (!key) return;
    if (!ALIAS_INDEX.has(key)) ALIAS_INDEX.set(key, []);
    const list = ALIAS_INDEX.get(key);
    if (!list.includes(id)) list.push(id);
  };
  for (const e of entities) {
    add(e.name, e.id);
    for (const a of e.aliases || []) add(a, e.id);
  }
  for (const a of aliases || []) add(a.alias, a.entity_id);
}

export const getEntity = (id) => ENTITIES.find((e) => e.id === id) || null;
export const allEntities = () => ENTITIES;

function hit(id, confidence, method) {
  const e = getEntity(id);
  if (!e) return null;
  return {
    entity_id: e.id,
    entity_type: e.type,
    name: e.name,
    route: e.route,
    status: e.status,
    requires_auth: e.requires_auth,
    requires_kyc: e.requires_kyc,
    confidence: Math.round(confidence * 100) / 100,
    method,
  };
}

/**
 * Resolve a query to candidate entities, best first.
 * @returns {{ best: object|null, candidates: object[], ambiguous: boolean }}
 */
export function resolve(query, { typeHint = null } = {}) {
  const q = normalize(query);
  if (!q) return { best: null, candidates: [], ambiguous: false };

  // strip a leading navigation phrase so "take me to aviator" matches as "aviator"
  const stripNav = (t) => t
    .replace(/^(please\s+)?(can you\s+)?(take me to|take me|bring me to|go to|goto|navigate to|open up|open|show me|show|launch|start|play|i want to play|i want to|i wanna|find me|find)\s+/i, '')
    .replace(/^(the|a|an)\s+/i, '')
    .replace(/\s+(page|section|game|now|please|plz)$/i, '')
    .trim();

  const qStripped = normalize(stripNav(q));

  const scores = new Map();          // entity_id -> { conf, method }
  const bump = (id, conf, method) => {
    const cur = scores.get(id);
    if (!cur || conf > cur.conf) scores.set(id, { conf, method });
  };

  // ---- 1 & 2: exact / normalised exact ----
  const exactKey = ALIAS_INDEX.has(q) ? q
    : (qStripped && ALIAS_INDEX.has(qStripped) ? qStripped : null);
  if (exactKey) {
    const ids = ALIAS_INDEX.get(exactKey);
    // a single owner is a confident match; several owners is genuine ambiguity
    const conf = ids.length === 1 ? 0.98 : 0.55;
    ids.forEach((id) => bump(id, conf, ids.length === 1 ? 'exact_alias' : 'ambiguous_alias'));
  }

  // ---- 3: command-word translation ("aviator kholo" -> "aviator open") ----
  const { text: translated, translatedCount } = translateCommands(query);
  if (translatedCount > 0 && translated && translated !== q) {
    if (ALIAS_INDEX.has(translated)) {
      ALIAS_INDEX.get(translated).forEach((id) => bump(id, 0.93, 'translated_exact'));
    }
    // also try the query with command words removed entirely
    const stripped = translated
      .split(' ')
      .filter((t) => !['open', 'show', 'go', 'there', 'want', 'play', 'me', 'my', 'take'].includes(t))
      .join(' ');
    if (stripped && ALIAS_INDEX.has(stripped)) {
      ALIAS_INDEX.get(stripped).forEach((id) => bump(id, 0.92, 'translated_stripped'));
    }
  }

  // ---- 4: alias appears inside the query ----
  const haystacks = [q, qStripped, translated].filter(Boolean);
  for (const [alias, ids] of ALIAS_INDEX) {
    if (alias.length < 4) continue;                  // too short to be safe
    for (const hay of haystacks) {
      if (hay === alias) continue;                   // already handled
      if (hay.includes(alias)) {
        // longer alias match = stronger signal
        const conf = Math.min(0.90, 0.72 + alias.length / 60);
        ids.forEach((id) => bump(id, conf, 'alias_contained'));
      }
    }
  }

  // ---- 5: token / keyword overlap ----
  const qTokens = new Set(tokens(translated || q));
  for (const e of ENTITIES) {
    const kw = new Set([
      ...tokens(e.name),
      ...(e.keywords || []).flatMap((k) => tokens(k)),
    ]);
    if (!kw.size) continue;
    let shared = 0;
    for (const t of qTokens) if (kw.has(t)) shared++;
    if (shared > 0) {
      const conf = Math.min(0.85, 0.5 + shared * 0.12);
      bump(e.id, conf, 'keyword_overlap');
    }
  }

  // ---- 6: fuzzy (typos) ----
  if (q.length >= 4) {
    for (const [alias, ids] of ALIAS_INDEX) {
      if (Math.abs(alias.length - q.length) > 6) continue;
      const tri = trigramSimilarity(q, alias);
      if (tri < 0.42) continue;
      const edit = editSimilarity(q, alias);
      const sim = tri * 0.6 + edit * 0.4;
      if (sim >= 0.55) {
        ids.forEach((id) => bump(id, Math.min(0.90, sim), 'fuzzy'));
      }
    }
  }

  let ranked = [...scores.entries()]
    .map(([id, { conf, method }]) => hit(id, conf, method))
    .filter(Boolean);

  if (typeHint) {
    ranked = ranked.map((r) =>
      r.entity_type === typeHint ? { ...r, confidence: Math.min(0.99, r.confidence + 0.04) } : r);
  }

  // an inactive entity must never be navigated to
  ranked.forEach((r) => {
    if (r.status && r.status !== 'active') r.confidence = Math.min(r.confidence, 0.3);
  });

  ranked.sort((a, b) => b.confidence - a.confidence);

  const best = ranked[0] || null;
  const runnerUp = ranked[1] || null;

  // near-tie between different entities is ambiguity, not a winner
  const tooClose = Boolean(
    best && runnerUp &&
    best.confidence - runnerUp.confidence < 0.06 &&
    best.confidence < config.thresholds.navigateDirect
  );

  const ambiguous = !best ||
    best.confidence < config.thresholds.clarify ||
    tooClose;

  return { best, candidates: ranked.slice(0, 5), ambiguous };
}

export default { loadEntities, resolve, getEntity, allEntities };
