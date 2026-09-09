/**
 * retriever.js — hybrid retrieval over the knowledge corpus.
 *
 * BM25 and vector results are fused with Reciprocal Rank Fusion rather than
 * added directly, because the two score scales are not comparable.
 */
import BM25 from './bm25.js';
import VectorStore from './vectorstore.js';
import config from './config.js';
import { translateCommands } from './normalize.js';

let bm25 = null;
let vectors = null;
let CHUNKS = [];

/**
 * @param {Array} chunks  [{ chunk_id, document_id, title, content, category,
 *                           document_type, related_pages, game_id,
 *                           requires_verified_source, priority }]
 */
export async function buildIndex(chunks) {
  CHUNKS = chunks;

  bm25 = new BM25();
  for (const c of chunks) {
    // title is prepended so the chunk keeps context it would otherwise lose
    bm25.add(c.chunk_id, `${c.title} ${c.content} ${(c.keywords || []).join(' ')}`, c);
  }
  bm25.build();

  vectors = new VectorStore();
  await vectors.addBatch(chunks.map((c) => ({
    id: c.chunk_id,
    text: `${c.title}\n${c.content}`,
    payload: c,
  })));

  return { chunks: chunks.length, vectorMode: vectors.mode };
}

export const indexStats = () => ({
  chunks: CHUNKS.length,
  vectorMode: vectors?.mode || 'not_built',
});

/** Reciprocal Rank Fusion. */
function rrf(lists, weights) {
  const k = config.retrieval.rrfK;
  const scores = new Map();
  lists.forEach((list, li) => {
    list.forEach((item, rank) => {
      const inc = (weights[li] || 1) / (k + rank + 1);
      const cur = scores.get(item.id);
      if (cur) {
        cur.score += inc;
        cur.sources.push({ method: li === 0 ? 'vector' : 'bm25', rank: rank + 1, raw: item.score });
      } else {
        scores.set(item.id, {
          score: inc,
          payload: item.payload,
          sources: [{ method: li === 0 ? 'vector' : 'bm25', rank: rank + 1, raw: item.score }],
        });
      }
    });
  });
  return [...scores.entries()]
    .map(([id, v]) => ({ chunk_id: id, ...v }))
    .sort((a, b) => b.score - a.score);
}

/**
 * @param {string} query
 * @param {object} filters  { category, document_type, game_id, page_id }
 */
export async function retrieve(query, filters = {}) {
  if (!bm25 || !vectors) return [];

  // translate command words so "aviator kaise khelte hain" retrieves English content
  const { text: translated } = translateCommands(query);
  const searchText = translated && translated.length > 2 ? `${query} ${translated}` : query;

  const pool = config.retrieval.candidatePool;
  const [vecHits, lexHits] = await Promise.all([
    vectors.search(searchText, pool),
    Promise.resolve(bm25.search(searchText, pool)),
  ]);

  let fused = rrf([vecHits, lexHits],
    [config.retrieval.vectorWeight, config.retrieval.bm25Weight]);

  // soft filters — applied after fusion so a confident lexical hit is not lost
  if (filters.category) {
    fused = fused.map((f) => f.payload.category === filters.category
      ? { ...f, score: f.score * 1.6 } : f);
  }
  if (filters.document_type) {
    fused = fused.filter((f) => f.payload.document_type === filters.document_type);
  }
  if (filters.game_id) {
    fused = fused.map((f) => f.payload.game_id === filters.game_id
      ? { ...f, score: f.score * 2.0 } : f);
  }

  // section preference: an explanatory question wants the overview/how-to chunk,
  // not an incidental Q&A that happens to share vocabulary
  const wantsExplainer = /\b(how (does|do|to)|what is|explain|rules|kaise|ela)\b/i.test(query);
  if (wantsExplainer) {
    // If a proper explainer section exists, an incidental Q&A chunk must not
    // outrank it merely because it shares a word like "does".
    const hasExplainer = fused.some((f) => /__(overview|howto|rules)$/.test(f.chunk_id || ''));
    fused = fused.map((f) => {
      const id = f.chunk_id || '';
      if (/__(overview|howto|rules)$/.test(id)) return { ...f, score: f.score * 2.5 };
      if (/__q\d+$/.test(id)) return { ...f, score: f.score * (hasExplainer ? 0.25 : 0.7) };
      return f;
    });
  }

  // priority is a tiebreaker, never a filter
  fused = fused.map((f) => {
    const boost = f.payload.priority === 'high' ? 1.12
      : f.payload.priority === 'low' ? 0.94 : 1;
    return { ...f, score: f.score * boost };
  });

  fused.sort((a, b) => b.score - a.score);

  // normalise so the floor threshold means something across queries
  const max = fused[0]?.score || 1;
  return fused
    .map((f) => ({ ...f, score: f.score / max }))
    .filter((f) => f.score >= config.thresholds.retrievalFloor)
    .slice(0, config.retrieval.topK);
}

/**
 * Infer the FAQ category from the query so a "deposit pending" question does not
 * retrieve the near-identical withdrawal answer. These two corpora overlap almost
 * completely in vocabulary, so category routing matters more than score tuning.
 */
const CATEGORY_HINTS = [
  ['DEPOSIT',            ['deposit', 'add money', 'add funds', 'top up', 'topup', 'recharge', 'jama', 'vesali']],
  ['WITHDRAWAL',         ['withdraw', 'withdrawal', 'withdrawl', 'payout', 'cash out', 'cashout', 'nikal', 'teesuko']],
  ['KYC',                ['kyc', 'verif', 'document', 'identity', 'passport']],
  ['BETTING',            ['bet', 'stake', 'odds', 'accumulator', 'settled', 'wager']],
  ['PROMOTIONS',         ['bonus', 'promo', 'offer', 'wagering', 'free spin']],
  ['ACCOUNT',            ['password', 'login', 'log in', 'profile', 'username', 'restricted']],
  ['RESPONSIBLE_GAMING', ['self exclu', 'take a break', 'addict', 'problem gambl', 'deposit limit']],
  ['TECHNICAL',          ['loading', 'error', 'not working', 'froze', 'app keeps']],
  ['SUPPORT',            ['support', 'complaint', 'contact', 'agent']],
  ['GAMES',              ['slot', 'rtp', 'volatility', 'demo mode']],
];

export function inferCategory(query) {
  const q = String(query || '').toLowerCase();
  let bestCat = null;
  let bestLen = 0;
  for (const [cat, hints] of CATEGORY_HINTS) {
    for (const h of hints) {
      // longest matching hint wins, so "deposit limit" beats "deposit"
      if (q.includes(h) && h.length > bestLen) {
        bestCat = cat;
        bestLen = h.length;
      }
    }
  }
  return bestCat;
}

export default { buildIndex, retrieve, indexStats, inferCategory };
