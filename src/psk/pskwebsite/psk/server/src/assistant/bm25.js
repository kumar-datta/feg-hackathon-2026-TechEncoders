/**
 * bm25.js — in-memory lexical index.
 *
 * At this corpus size (a few hundred chunks) a plain in-process BM25 beats a
 * network round-trip to a search service, and it needs no infrastructure.
 */
import { tokens } from './normalize.js';

const K1 = 1.5;
const B = 0.75;

export class BM25 {
  constructor() {
    this.docs = [];          // { id, tokens, len, payload }
    this.df = new Map();     // term -> document frequency
    this.avgLen = 0;
  }

  add(id, text, payload) {
    const t = tokens(text);
    this.docs.push({ id, tokens: t, len: t.length, payload });
    for (const term of new Set(t)) {
      this.df.set(term, (this.df.get(term) || 0) + 1);
    }
  }

  build() {
    const total = this.docs.reduce((a, d) => a + d.len, 0);
    this.avgLen = this.docs.length ? total / this.docs.length : 0;

    // precompute term frequencies per doc
    for (const d of this.docs) {
      d.tf = new Map();
      for (const term of d.tokens) d.tf.set(term, (d.tf.get(term) || 0) + 1);
    }
    return this;
  }

  idf(term) {
    const n = this.docs.length;
    const df = this.df.get(term) || 0;
    // BM25+ style smoothing keeps idf positive for very common terms
    return Math.log(1 + (n - df + 0.5) / (df + 0.5));
  }

  search(query, limit = 20) {
    const qTerms = tokens(query);
    if (!qTerms.length || !this.docs.length) return [];

    const scored = [];
    for (const d of this.docs) {
      let score = 0;
      for (const term of qTerms) {
        const f = d.tf.get(term);
        if (!f) continue;
        const norm = 1 - B + B * (d.len / (this.avgLen || 1));
        score += this.idf(term) * ((f * (K1 + 1)) / (f + K1 * norm));
      }
      if (score > 0) scored.push({ id: d.id, score, payload: d.payload });
    }

    scored.sort((a, b) => b.score - a.score);

    // normalise to 0..1 so scores are comparable across queries
    const max = scored[0]?.score || 1;
    return scored.slice(0, limit).map((s) => ({ ...s, score: s.score / max }));
  }
}

export default BM25;
