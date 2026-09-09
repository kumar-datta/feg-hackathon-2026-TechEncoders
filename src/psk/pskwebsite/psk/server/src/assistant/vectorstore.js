/**
 * vectorstore.js — in-memory vector index with cosine similarity.
 *
 * With a corpus of a few hundred chunks a brute-force scan is well under a
 * millisecond, so there is no reason to run a separate vector database yet.
 * The interface mirrors what a real store would expose, so swapping in pgvector
 * or Qdrant later means replacing this file only.
 *
 * When no embedding API is configured it falls back to a deterministic
 * hashed bag-of-words vector. That is weaker than a real embedding — it catches
 * lexical overlap rather than meaning — but it keeps the pipeline working and
 * is honestly labelled as `lexical_hash` in the results.
 */
import { tokens } from './normalize.js';
import { embed } from './llm.js';
import config from './config.js';

const FALLBACK_DIM = 512;

/** Deterministic string hash. */
function hash(str) {
  let h = 2166136261;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

/** Hashed bag-of-words with sublinear term weighting. */
export function lexicalVector(text, dim = FALLBACK_DIM) {
  const v = new Float32Array(dim);
  const t = tokens(text);
  const counts = new Map();
  for (const tok of t) counts.set(tok, (counts.get(tok) || 0) + 1);

  for (const [tok, n] of counts) {
    const w = 1 + Math.log(n);
    v[hash(tok) % dim] += w;
    // a second slot per token reduces collision damage
    v[hash(tok + '#2') % dim] += w * 0.5;
  }
  return normalizeVec(Array.from(v));
}

export function normalizeVec(v) {
  let norm = 0;
  for (const x of v) norm += x * x;
  norm = Math.sqrt(norm) || 1;
  return v.map((x) => x / norm);
}

export function cosine(a, b) {
  const n = Math.min(a.length, b.length);
  let dot = 0;
  for (let i = 0; i < n; i++) dot += a[i] * b[i];
  return dot;   // both sides are pre-normalised
}

export class VectorStore {
  constructor() {
    this.items = [];        // { id, vector, payload }
    this.mode = 'lexical_hash';
  }

  get size() {
    return this.items.length;
  }

  /**
   * Index a batch of documents. Uses the embedding API when configured,
   * otherwise the deterministic lexical fallback.
   */
  async addBatch(docs) {
    if (config.embeddingsEnabled) {
      const BATCH = 64;
      const vectors = [];
      for (let i = 0; i < docs.length; i += BATCH) {
        const slice = docs.slice(i, i + BATCH);
        const res = await embed(slice.map((d) => d.text));
        if (!res) {
          // provider failed mid-way — fall back wholesale so the index stays consistent
          console.warn('[assistant] embedding failed, using lexical fallback for the corpus');
          vectors.length = 0;
          break;
        }
        vectors.push(...res.map(normalizeVec));
      }
      if (vectors.length === docs.length) {
        this.mode = `embeddings:${config.embedModel}`;
        docs.forEach((d, i) => this.items.push({ id: d.id, vector: vectors[i], payload: d.payload }));
        return this;
      }
    }

    this.mode = 'lexical_hash';
    for (const d of docs) {
      this.items.push({ id: d.id, vector: lexicalVector(d.text), payload: d.payload });
    }
    return this;
  }

  async queryVector(text) {
    if (this.mode.startsWith('embeddings')) {
      const res = await embed([text]);
      if (res?.[0]) return normalizeVec(res[0]);
      // fall through if the call failed at query time
    }
    return lexicalVector(text);
  }

  async search(text, limit = 20) {
    if (!this.items.length) return [];
    const q = await this.queryVector(text);
    const scored = this.items.map((it) => ({
      id: it.id,
      score: cosine(q, it.vector),
      payload: it.payload,
    }));
    scored.sort((a, b) => b.score - a.score);
    return scored.slice(0, limit);
  }
}

export default VectorStore;
