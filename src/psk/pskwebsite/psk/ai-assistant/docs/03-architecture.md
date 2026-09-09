# Architecture: Ingestion, Retrieval and API (PART 15)

---

## 1. Project structure

```
ai-assistant/
├── data/
│   ├── navigation/              # deterministic — Postgres, NOT the vector DB
│   │   ├── entities.json            34 entities (games, categories, sports, pages)
│   │   ├── pages.json               18 pages with available_actions
│   │   ├── categories.json          11 category/sport entities
│   │   └── aliases.json            275 alias → entity_id rows
│   │
│   ├── rag/                     # knowledge — embedded
│   │   ├── faq.json                112 Q&A records
│   │   ├── game_knowledge.json       8 game documents
│   │   ├── help_articles.json        2 long-form articles (chunking demo)
│   │   ├── policies.json            14 PLACEHOLDERS — need your legal input
│   │   └── chunks_example.json       8 worked chunking examples
│   │
│   ├── intents/                 # training / few-shot / routing
│   │   ├── intent_examples.json    159 labelled queries
│   │   ├── nl_alias_queries.json    73 multilingual / misspelled queries
│   │   ├── ambiguous_queries.json   52 must-clarify cases
│   │   ├── followups.json           52 multi-turn examples
│   │   └── actions.json             14 actions + intent→action map
│   │
│   └── evaluation/
│       ├── retrieval_eval.json      48 retrieval cases
│       ├── navigation_eval.json     55 navigation cases
│       └── safety_eval.json         38 safety / hallucination tests
│
├── docs/
│   ├── 01-schemas.md
│   ├── 02-metadata.md
│   └── 03-architecture.md
└── tools/                       # regenerate everything from source
```

---

## 2. Purpose of each dataset

| Dataset | Purpose | Embed? | Lives in |
|---|---|:-:|---|
| `entities.json` | Canonical registry; the only source of routes | Alias sentence only | Postgres |
| `pages.json` | Page capabilities → action buttons, auth gating | ❌ | Postgres |
| `aliases.json` | Fast exact/fuzzy entity resolution | ❌ | Postgres + trigram |
| `categories.json` | Hierarchy for browse and disambiguation | ❌ | Postgres |
| `faq.json` | Primary informational corpus | ✅ | Vector + Postgres |
| `game_knowledge.json` | Game mechanics and terminology | ✅ | Vector + Postgres |
| `help_articles.json` | Long-form troubleshooting | ✅ | Vector + Postgres |
| `policies.json` | Legal/policy answers | ✅ *(once real)* | Vector + Postgres |
| `chunks_example.json` | Reference for the chunker | ❌ | Repo only |
| `intent_examples.json` | Few-shot / classifier training | ❌ | Repo → prompt or model |
| `nl_alias_queries.json` | Alias-table expansion + eval | ❌ | Feeds `aliases.json` |
| `ambiguous_queries.json` | Teaches the model to ask, not guess | ❌ | Few-shot + eval |
| `followups.json` | Pronoun/context resolution | ❌ | Few-shot + eval |
| `actions.json` | Executor contract | ❌ | Postgres / config |
| `evaluation/*` | CI gates | ❌ | Test harness |

---

## 3. Ingestion pipeline

```
                    ┌─────────────────────────────────────────┐
 source JSON ──────►│ 1. VALIDATE                             │
                    │   schema, unique ids, no orphan parents, │
                    │   every game_id ↔ entity id             │
                    └──────────────────┬──────────────────────┘
                                       ▼
              ┌────────────────────────┴────────────────────────┐
              ▼                                                 ▼
   ┌──────────────────────┐                        ┌────────────────────────┐
   │ 2a. NAVIGATION PATH  │                        │ 2b. KNOWLEDGE PATH     │
   │  entities, pages,    │                        │  faq, games, help,     │
   │  aliases, actions    │                        │  policies              │
   └──────────┬───────────┘                        └───────────┬────────────┘
              ▼                                                ▼
   ┌──────────────────────┐                        ┌────────────────────────┐
   │ 3a. UPSERT Postgres  │                        │ 3b. CHUNK per type     │
   │  + trigram index     │                        │  (see 02-metadata §)   │
   └──────────┬───────────┘                        └───────────┬────────────┘
              │                                                ▼
              │                                    ┌────────────────────────┐
              │                                    │ 4. ENRICH metadata     │
              │                                    │  link game_id/page_id, │
              │                                    │  language, status      │
              │                                    └───────────┬────────────┘
              │                                                ▼
              │                                    ┌────────────────────────┐
              │                                    │ 5. EMBED (batch)       │
              │                                    │  title + content       │
              │                                    └───────────┬────────────┘
              │                                                ▼
              │                                    ┌────────────────────────┐
              │                                    │ 6. UPSERT vector DB    │
              │                                    │  + mirror to Postgres  │
              │                                    └───────────┬────────────┘
              ▼                                                ▼
   ┌───────────────────────────────────────────────────────────────────────┐
   │ 7. POST-INGEST VALIDATION — run evaluation/*.json, fail the build     │
   │    if navigation accuracy or safety refusal rate regresses            │
   └───────────────────────────────────────────────────────────────────────┘
```

**Step 1 checks that must fail the build**

- duplicate `entity_id` or `chunk_id`
- `parent_id` pointing at a non-existent entity
- `game_id` in `game_knowledge.json` with no matching entity
- `related_pages` referencing an unknown `page_id`
- any `route` not matching your real routing table
- a policy record whose content is no longer a placeholder but has
  `requires_verified_source: true` and no `last_reviewed`

**Re-ingestion:** navigation is small — rebuild it wholesale on every deploy.
Knowledge is incremental — upsert by `chunk_id`, and hard-delete chunks whose
parent document disappeared, or you will serve deleted content indefinitely.

---

## 4. Retrieval pipeline (request path)

```
1. NORMALISE          lowercase, strip punctuation, transliteration hints,
                      detect language
                          │
2. RESOLVE CONTEXT    pronoun? → focus_stack[0]; empty → mark AMBIGUOUS
                          │
3. CLASSIFY INTENT    few-shot from intent_examples.json (or a fine-tuned
                      classifier). Emits intent + confidence
                          │
        ┌─────────────────┼─────────────────────┬──────────────────┐
        ▼                 ▼                     ▼                  ▼
   NAVIGATE          FAQ/GAME_INFO         ACCOUNT/BALANCE      AMBIGUOUS
        │                 │                     │                  │
4a. ENTITY RESOLVE   4b. HYBRID RETRIEVE   4c. API TOOL CALL   4d. CLARIFY
   exact → trigram      pre-filter on          authenticated       return top
   → vector             status/access/         session only        candidates,
        │               jurisdiction                │              ask, stop
        │               BM25 + vector → RRF         │
        │               → rerank top 20 → 5         │
        ▼                 ▼                        ▼
5. CONFIDENCE GATE   (see 01-schemas §7). Financial actions need ≥0.95 + confirm.
                     Inactive entity → never navigate.
        │
6. GENERATE          Grounded answer, citations, no invented URLs/policies.
                     Refuse per the safety rules.
        │
7. ACTION            entity_id → Postgres route lookup → typed action object.
                     The executor accepts NO model-generated URL.
        │
8. UPDATE STATE      push entity onto focus_stack; log for evaluation
```

**Latency note.** Steps 4a exact/trigram are sub-millisecond Postgres lookups.
Most navigation queries — the bulk of traffic — should never touch the vector DB
or a generation call at all. Route those to a fast path and reserve the LLM for
genuinely ambiguous or informational input.

---

## 5. What must never happen

Enforced in code, not only in the prompt:

1. The action executor has **no code path** accepting a URL string from the model.
2. Balance, bets, KYC status, transactions come from the API or are not stated.
3. `requires_verified_source: true` content cannot be paraphrased into a specific
   claim — the generator must cite or decline.
4. Confidence below threshold → clarify. There is no "best guess" branch for
   financial or destructive actions.
5. Distress signals route to responsible gaming **before** any other intent,
   including an explicit navigation request.

---

## 6. Assistant API — sample input/output

### Request

```json
POST /api/assistant/query
{
  "session_id": "sess_8f21",
  "message": "aviator kholo",
  "user_context": { "authenticated": true, "kyc_status": "verified",
                    "region": "IN", "language": "hinglish" }
}
```

### Response A — confident navigation

```json
{
  "intent": "NAVIGATE",
  "confidence": 0.96,
  "entity": { "entity_id": "game_aviator", "entity_type": "GAME", "name": "Aviator" },
  "answer": "Opening Aviator for you.",
  "actions": [
    { "action": "OPEN_GAME", "label": "Open Aviator",
      "entity_id": "game_aviator", "route": "/games/aviator" }
  ],
  "sources": [],
  "requires_confirmation": false,
  "resolved_by": "exact_alias_match"
}
```

`route` is present because the **backend** resolved it from the registry after the
model returned `entity_id`. The model never emitted that string.

### Response B — grounded informational answer

```json
{
  "intent": "GAME_INFO",
  "confidence": 0.94,
  "entity": { "entity_id": "game_aviator", "entity_type": "GAME", "name": "Aviator" },
  "answer": "In Aviator a multiplier starts at 1.00x and rises during the round, ending at a randomly determined point. If you cash out before it ends, your stake is settled at the multiplier shown at that moment; if the round ends first, that round's stake is lost. Each round is independent, so previous rounds tell you nothing about the next one.",
  "actions": [
    { "action": "OPEN_GAME", "label": "Open Aviator", "entity_id": "game_aviator", "route": "/games/aviator" },
    { "action": "OPEN_RESPONSIBLE_GAMING", "label": "Set limits", "entity_id": "page_responsible_gaming", "route": "/responsible-gaming" }
  ],
  "sources": [
    { "chunk_id": "doc_game_aviator__c01", "document_type": "GAME_KNOWLEDGE", "score": 0.91 },
    { "chunk_id": "doc_game_aviator__c02", "document_type": "GAME_KNOWLEDGE", "score": 0.87 }
  ],
  "requires_confirmation": false
}
```

### Response C — ambiguous, must clarify

```json
{
  "intent": "AMBIGUOUS",
  "confidence": 0.38,
  "entity": null,
  "answer": "We have a few crash games — which did you mean?",
  "clarification": {
    "question": "Which crash game would you like?",
    "options": [
      { "entity_id": "game_aviator", "label": "Aviator" },
      { "entity_id": "game_crash_classic", "label": "Crash Classic" },
      { "entity_id": "category_crash_games", "label": "Show all crash games" }
    ]
  },
  "actions": [],
  "sources": [],
  "requires_confirmation": true
}
```

### Response D — financial action, confirmation required

```json
{
  "intent": "WITHDRAW",
  "confidence": 0.96,
  "entity": { "entity_id": "page_withdraw", "entity_type": "PAGE", "name": "Withdraw" },
  "answer": "I can take you to the withdrawal page. Shall I?",
  "actions": [
    { "action": "OPEN_WITHDRAW", "label": "Go to withdraw",
      "entity_id": "page_withdraw", "route": "/wallet/withdraw",
      "requires_confirmation": true }
  ],
  "sources": [],
  "requires_confirmation": true,
  "notes": ["Financial destination — confirmation required regardless of confidence."]
}
```

### Response E — refusal (policy not verified)

```json
{
  "intent": "FAQ",
  "confidence": 0.91,
  "entity": null,
  "answer": "I can't give you a specific number for withdrawal processing time — that figure has to come from the official withdrawal policy rather than from me. It's published on the withdrawal page, and support can confirm it for your account.",
  "actions": [
    { "action": "OPEN_WITHDRAW", "label": "Withdrawal page", "entity_id": "page_withdraw", "route": "/wallet/withdraw" },
    { "action": "OPEN_SUPPORT", "label": "Contact support", "entity_id": "page_contact_support", "route": "/help/contact" }
  ],
  "sources": [{ "chunk_id": "faq_withdrawal_002", "document_type": "FAQ", "score": 0.93 }],
  "refusal_reason": "requires_verified_source"
}
```

### Response F — account data (API, never RAG)

```json
{
  "intent": "ACCOUNT",
  "confidence": 0.93,
  "entity": { "entity_id": "page_wallet", "entity_type": "PAGE", "name": "Wallet" },
  "answer": "I can't see account balances. Your wallet page shows your current balance and recent activity.",
  "actions": [
    { "action": "OPEN_WALLET", "label": "Open wallet", "entity_id": "page_wallet", "route": "/wallet" }
  ],
  "sources": [],
  "notes": ["Balance was not retrieved from RAG. Call the account service with the authenticated session if you want it inline."]
}
```

---

## 7. Evaluation gates for CI

| Metric | Dataset | Suggested gate |
|---|---|---|
| Navigation accuracy (correct `entity_id`) | `navigation_eval.json` | ≥ 95% on easy/medium |
| Ambiguity detection (did **not** guess) | `navigation_eval.json` ambiguous | ≥ 98% |
| Retrieval recall@5 | `retrieval_eval.json` | ≥ 90% |
| Correct source type | `retrieval_eval.json` | ≥ 95% |
| Safety refusal rate | `safety_eval.json` | **100%** on `should_refuse_or_clarify` |
| False refusal | `safety_eval.json` `SAFE_BASELINE` | ≤ 5% |
| Invented URL rate | all sets | **0%** — hard fail |

Ambiguity detection and safety refusal are the two that matter most. A system that
navigates confidently but occasionally guesses wrong on a financial page is worse
than one that asks a clarifying question, and a single invented withdrawal
timeframe is a compliance incident rather than a bug.

---

## 8. Before this ships

1. **Replace all 14 policy placeholders** with your published documentation. Until
   then the assistant must decline specifics — that behaviour is built into the data
   via `requires_verified_source`.
2. **Replace every route** with your real routing table. The routes here are examples.
3. **Have compliance review** the responsible-gaming responses and the refusal
   behaviours. This is a regulated product and those responses carry obligations
   that vary by licence.
4. **Add your real game catalogue.** The eight game records are generic examples of
   publicly-known mechanics; per-title rules must come from each provider.
5. **Localise properly.** The Hinglish/Telugu examples here are a starting alias set,
   not a substitute for native review.
6. **Log every low-confidence and clarification event.** That log is the highest-value
   source of new aliases, and alias coverage is what drives navigation accuracy.
