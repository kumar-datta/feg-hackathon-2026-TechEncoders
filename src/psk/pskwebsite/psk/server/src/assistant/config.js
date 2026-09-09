/**
 * Assistant configuration.
 *
 * The assistant is designed to work with NO API key at all. Without one it runs
 * in deterministic mode: exact/fuzzy entity resolution, rule-based intent
 * routing, BM25 retrieval and extractive answers. That covers navigation and
 * most FAQ traffic. An API key upgrades two things — semantic embeddings and
 * LLM-phrased answers — but never becomes the source of truth for routes.
 */

const PROVIDERS = {
  openai: {
    baseUrl: 'https://api.openai.com/v1',
    chatPath: '/chat/completions',
    embedPath: '/embeddings',
    defaultChat: 'gpt-4o-mini',
    defaultEmbed: 'text-embedding-3-small',
    authHeader: (k) => ({ Authorization: `Bearer ${k}` }),
    style: 'openai',
  },
  groq: {
    baseUrl: 'https://api.groq.com/openai/v1',
    chatPath: '/chat/completions',
    embedPath: null,
    defaultChat: 'qwen/qwen3.8-27b',
    defaultEmbed: null,
    authHeader: (k) => ({ Authorization: `Bearer ${k}` }),
    style: 'openai',
  },
  together: {
    baseUrl: 'https://api.together.xyz/v1',
    chatPath: '/chat/completions',
    embedPath: '/embeddings',
    defaultChat: 'meta-llama/Llama-3.3-70B-Instruct-Turbo',
    defaultEmbed: 'BAAI/bge-large-en-v1.5',
    authHeader: (k) => ({ Authorization: `Bearer ${k}` }),
    style: 'openai',
  },
  anthropic: {
    baseUrl: 'https://api.anthropic.com/v1',
    chatPath: '/messages',
    embedPath: null,               // Anthropic has no embeddings endpoint
    defaultChat: 'claude-sonnet-5',
    defaultEmbed: null,
    authHeader: (k) => ({ 'x-api-key': k, 'anthropic-version': '2023-06-01' }),
    style: 'anthropic',
  },
  google: {
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    chatPath: '/models/{model}:generateContent',
    embedPath: '/models/{model}:embedContent',
    defaultChat: 'gemini-2.0-flash',
    defaultEmbed: 'text-embedding-004',
    authHeader: () => ({}),        // key goes in the query string
    style: 'google',
  },
  ollama: {
    baseUrl: 'http://localhost:11434/v1',
    chatPath: '/chat/completions',
    embedPath: '/embeddings',
    defaultChat: 'llama3.1',
    defaultEmbed: 'nomic-embed-text',
    authHeader: () => ({}),
    style: 'openai',
  },
};

const providerName = (process.env.AI_PROVIDER || 'none').toLowerCase();
const apiKey = (process.env.AI_API_KEY || '').trim();
const provider = PROVIDERS[providerName] || null;

// ollama runs locally and needs no key
const keyRequired = providerName !== 'ollama' && providerName !== 'none';
const enabled = Boolean(provider) && (!keyRequired || apiKey.length > 0);

export const config = {
  providerName,
  provider,
  apiKey,
  enabled,

  baseUrl: (process.env.AI_BASE_URL || provider?.baseUrl || '').replace(/\/$/, ''),
  chatModel: process.env.AI_MODEL || provider?.defaultChat || null,
  embedModel: process.env.AI_EMBED_MODEL || provider?.defaultEmbed || null,
  maxTokens: Number(process.env.AI_MAX_TOKENS || 600),

  /** Semantic embeddings need a key AND a provider that offers an embed endpoint. */
  get embeddingsEnabled() {
    return this.enabled && Boolean(this.embedModel) && Boolean(this.provider?.embedPath);
  },

  /* ---------------- retrieval + safety thresholds ---------------- */
  thresholds: {
    navigateDirect: 0.90,      // act without asking
    navigateWithHint: 0.70,    // act, but show "did you mean"
    clarify: 0.45,             // below this, always ask
    financialConfirm: 0.95,    // deposit/withdraw need this AND a confirm step
    retrievalFloor: 0.12,      // below this a chunk is not worth citing
  },

  retrieval: {
    topK: 5,
    candidatePool: 20,
    vectorWeight: 0.6,
    bm25Weight: 0.4,
    rrfK: 60,
  },

  /** Financial destinations always confirm, whatever the confidence. */
  confirmActions: new Set(['OPEN_DEPOSIT', 'OPEN_WITHDRAW']),
};

export function describeMode() {
  if (!config.enabled) {
    return 'deterministic (no API key) — resolution, routing and extractive answers active';
  }
  const emb = config.embeddingsEnabled ? config.embedModel : 'built-in lexical fallback';
  return `${config.providerName} · chat=${config.chatModel} · embeddings=${emb}`;
}

export default config;
