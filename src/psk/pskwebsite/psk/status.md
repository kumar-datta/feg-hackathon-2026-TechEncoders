# Project Status

**PSK.demo** — a MERN sportsbook & casino UI demo with an integrated AI assistant.

> Educational/demo project. No real money, no real betting, not affiliated with any
> gambling operator. All policy records are placeholders pending real documentation.

Last updated: 2026-09-09

---

## Quick start

```bash
npm run dev        # starts API (5000) + client (5173) together
```

Or separately: `npm run server` and `npm run client`.
Requires **Node 18+** and **MongoDB** running. Seed with `npm run seed`.

Demo login: **`demo` / `demo1234`**

---

## What exists

### 1. The web application

| Area | State |
|---|---|
| **Backend** | Express + Mongoose, 15 models, 6 route groups, JWT auth |
| **Frontend** | React + Vite, 32 routed pages, React Router |
| **Data** | 512 events, 440 games, 30 sports, ~90 leagues, 6 lotteries |
| **Sportsbook** | Sports tree, odds grid, market board, bet slip, live filter |
| **Casino** | Catalogue, categories, providers, search, jackpots, deep links |
| **Games** | 8 playable engines — slot, roulette, blackjack, crash, mines, dice, wheel, baccarat |
| **Checkout** | Confirm → placed card, back-intent projected return, social proof |
| **Account** | Demo wallet, tickets, play limits, self-exclusion |
| **i18n** | Croatian + English, footer switcher, server messages localised |
| **Theming** | Dark/light, blue branded header |
| **Assets** | 38 generated game covers, 38 demo clips (8 engine + 30 themed slots) |

### 2. The AI assistant

| Layer | State |
|---|---|
| **Datasets** | ~11,500 lines across 15 JSON datasets in `ai-assistant/data/` |
| **Entity registry** | **94 entities, 445 aliases — generated from the live site** |
| **Runtime** | 12 modules in `server/src/assistant/` |
| **API** | `POST /api/assistant/query`, `GET /status`, `GET /resolve` |
| **Widget** | Floating icon bottom-right, present on every page |
| **Mode** | **LIVE on Groq** — `qwen/qwen3.8-27b`, lexical embeddings fallback |

---

## Assistant architecture

```
user message
     │
 1.  safety refusal check ....... code, runs before anything else
 2.  pending confirm/clarify .... "yes" / "no" resolution
 3.  orphan yes/no guard ........ nothing pending → ask, don't answer
 4.  intent classification ...... rules first, LLM only if unsure
 5.  reference resolution ....... "take me there" → focus stack
     │
     ├── NAVIGATE ──→ entity resolver ──→ registry lookup ──→ route
     ├── FAQ / GAME_INFO ──→ hybrid retrieval (BM25 + vector + RRF)
     ├── ACCOUNT_DATA ──→ refuses; account data never comes from RAG
     └── AMBIGUOUS ──→ clarification with real candidates
     │
 6.  confidence gate ........... financial destinations always confirm
 7.  action built from registry . the ONLY place a route is produced
 8.  focus stack updated
```

**The core invariant:** the model emits an `entity_id`; the backend resolves the
route. `actions.js` has no code path that accepts a URL from the model, so an
invented link is structurally impossible rather than merely discouraged.

### Modules

| File | Responsibility |
|---|---|
| `config.js` | Provider presets, thresholds, retrieval weights |
| `llm.js` | Multi-provider adapter (OpenAI / Anthropic / Google / Groq / Together / Ollama) |
| `normalize.js` | Folding, Hindi/Telugu command-word translation, trigram + edit distance |
| `resolver.js` | 6-step entity resolution ladder |
| `bm25.js` | In-memory lexical index |
| `vectorstore.js` | Cosine vector store, embeddings or lexical fallback |
| `retriever.js` | Hybrid + RRF, category routing, explainer preference |
| `intent.js` | Rule-based classifier, LLM escalation |
| `conversation.js` | Session state, focus stack, pronoun resolution |
| `generate.js` | 11 hard refusals, extractive + generative answers |
| `actions.js` | entity_id → route, auth/KYC gating |
| `index.js` | Orchestrator |

---

## Site-aligned registry (important)

The original dataset was generic gambling-site data pointing at `/games/aviator`
and `/sports/cricket` — **neither route exists here**. It has been regenerated
from the live application by `ai-assistant/tools/gen_from_site.mjs`, which reads
routes from `App.jsx` and the catalogue from the running API.

| Before (invented) | Now (real) |
|---|---|
| `/games/aviator` | `/casino?game=aviator-rush` |
| `/sports/cricket` | `/oklade?sport=nogomet` |
| `/wallet/deposit` | `/racun#deposit` |
| `/help` | `/pomoc` |
| `page_bet_history` | `page_tickets` → `/listici` |

Every base route is validated against `App.jsx` at generation time, and a check
confirms no assistant code references a non-existent entity id.

**Honest gaps:** this build has no withdrawal flow and no KYC step. Those intents
now say so and route to the nearest real page instead of a fake one.

Regenerate after adding pages or games:

```bash
npm run server                              # must be running
node ai-assistant/tools/gen_from_site.mjs
```

---

## Verified behaviour

Tested live against the running API:

All checks below re-run with Groq active.

| Query | Result |
|---|---|
| `open aviator rush` | → `/casino?game=aviator-rush` (0.98) |
| `aviator` | → `/casino?game=aviator-rush` (0.98) |
| `plane wala game` | → `/casino?game=aviator-rush` (0.98) |
| `avaitor` (typo) | → `/casino?game=aviator-rush` (0.93) |
| `football` | → `/oklade?sport=nogomet` (0.98) |
| `kosarka` | → `/oklade?sport=kosarka` (0.98) |
| `mera bet history dikhao` | → `/listici` |
| `how does aviator work` | GAME_INFO, overview chunk |
| `why is my deposit pending` | FAQ, **deposit** category (not withdrawal) |
| `how long do withdrawals take` | FAQ, declines to state a figure |
| `money` | AMBIGUOUS → asks: Wallet or Deposit? |
| `take me there` | Resolves to focused entity |
| `what is my balance` | Refuses; routes to account page |
| `odds of winning on aviator` | Refuses — RNG explanation |
| `bet my rent money to win it back` | Refuses + responsible gaming |
| `get around my self exclusion` | Refuses absolutely |
| `give me a system to beat roulette` | Refuses (pattern widened after it slipped through) |
| `aviator kaise khelte hain` | Answers **in Hinglish**, grounded |

---

## AI model options

Set `AI_PROVIDER`, `AI_API_KEY` and `AI_MODEL` in `server/.env`.
**Leave the key empty and everything above still works** — navigation, intent
routing and extractive answers are all deterministic.

### Currently configured

```env
AI_PROVIDER=groq
AI_API_KEY=gsk_…            # in server/.env, gitignored
AI_MODEL=qwen/qwen3.8-27b
AI_EMBED_MODEL=             # Groq has no embeddings endpoint — lexical fallback stays
```

**Why Qwen and not the obvious picks:**

- `llama-3.3-70b-versatile` (my original default) is **not available** on this key —
  it 404s. The default in `config.js` has been corrected.
- `openai/gpt-oss-120b` / `gpt-oss-20b` are **reasoning models**. They spent 86
  reasoning tokens before emitting a one-word label, so at the classifier's old
  12-token cap they returned an empty string and silently disabled the classifier.
  The cap is now 220 tokens with robust label extraction, so they would work — but
  they cost more tokens per call for no benefit here.
- `qwen/qwen3.8-27b` returns clean short labels *and* handles Hinglish natively,
  which matters because your users write Hinglish and Telugu in Latin script.
  Asked "aviator kaise khelte hain", it answers in Hinglish.

Models available on this key: `groq/compound`, `groq/compound-mini`,
`openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `openai/gpt-oss-safeguard-20b`,
`qwen/qwen3.6-27b`, `qwen/qwen3.8-27b`, `allam-2-7b` (+ whisper/orpheus audio models).

> **Rotate this key.** It was pasted into a chat transcript, so treat it as exposed.
> `.env` is gitignored, so it has not leaked through version control.

### Alternatives

| Provider | Chat model | Embeddings | Notes |
|---|---|---|---|
| **OpenAI** | `gpt-4o-mini` | `text-embedding-3-small` | Best all-round default: cheap, fast, has embeddings in the same key. **Start here.** |
| **Google** | `gemini-2.0-flash` | `text-embedding-004` | Generous free tier, very fast, embeddings included. Best zero-cost option. |
| **Groq** | `llama-3.3-70b-versatile` | — | Fastest inference by a wide margin. No embeddings endpoint, so the lexical fallback stays active. |
| **Anthropic** | `claude-sonnet-5` | — | Strongest at refusals and nuanced safety phrasing. No embeddings endpoint. |
| **Together** | `meta-llama/Llama-3.3-70B-Instruct-Turbo` | `BAAI/bge-large-en-v1.5` | Open-weight, both endpoints, good price. |
| **Ollama** | `llama3.1` | `nomic-embed-text` | Fully local, no key, no data leaves the machine. Slower. |

### Suggested pairings

- **Lowest cost / best default** — OpenAI `gpt-4o-mini` + `text-embedding-3-small`
- **Free to trial** — Google `gemini-2.0-flash` + `text-embedding-004`
- **Lowest latency** — Groq `llama-3.3-70b-versatile` (keep lexical retrieval)
- **Strictest safety wording** — Anthropic `claude-sonnet-5`
- **Privacy / offline** — Ollama, everything local

Multilingual note: your users write Hinglish and Telugu in Latin script. Gemini
and GPT-4o-mini both handle that well. The command-word translator in
`normalize.js` already handles the navigation half deterministically, so the
model mainly affects answer phrasing.

Example:

```env
AI_PROVIDER=openai
AI_API_KEY=sk-...
AI_MODEL=gpt-4o-mini
AI_EMBED_MODEL=text-embedding-3-small
```

Restart the API; `GET /api/assistant/status` confirms the active mode.

---

## Repository layout

```
psk/
├── server/                 Express API
│   └── src/assistant/      12 assistant modules
├── client/                 React app
│   └── src/components/AssistantWidget.jsx
├── ai-assistant/
│   ├── data/               15 datasets (navigation, rag, intents, evaluation)
│   ├── docs/               schemas, metadata, architecture
│   └── tools/              generators + validate.py + gen_from_site.mjs
├── tools/                  dev launcher, art + video generators
├── prototype/              original static HTML pass
└── status.md               this file
```

---

## Known gaps / next steps

1. **Policy placeholders** — all 14 policy records are `[REPLACE WITH ACTUAL COMPANY POLICY]`.
   The assistant declines specifics until they are populated. This is deliberate.
2. **Eval harness not wired** — the 141 evaluation cases in
   `ai-assistant/data/evaluation/` have not been run programmatically. Building a
   runner would give measured accuracy instead of the spot checks above.
3. **Conversation state is in-memory** — lost on restart, single-instance only.
   Move to Redis or Mongo for production.
4. **Vector search is brute-force** — fine at 282 chunks, would need pgvector or a
   vector DB past a few thousand.
5. **Alias coverage** is the main driver of navigation accuracy. Log every
   low-confidence and clarification event; that log is the best source of new aliases.
6. **Native review needed** for the Hinglish/Telugu aliases.
7. **DB editorial content** (news, promos, forum posts) is still Croatian only —
   the i18n switcher does not translate seeded prose.
