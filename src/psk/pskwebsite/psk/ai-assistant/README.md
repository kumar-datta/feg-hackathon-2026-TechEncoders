# AI Assistant — Datasets & Architecture

RAG + deterministic-navigation datasets for a gambling/betting site assistant.

> **All data here is MOCK/EXAMPLE data.** The 14 policy records are deliberate
> placeholders. Routes are examples. Nothing here is a substitute for your real
> product catalogue, routing table, or legal documentation.

---

## Quick start

```bash
python tools/gen_navigation.py     # entities, pages, aliases, actions
python tools/gen_rag_knowledge.py  # game knowledge, policy placeholders
python tools/gen_faq.py            # 112 FAQ records
python tools/gen_intents.py        # intents, aliases, ambiguity, follow-ups
python tools/gen_chunks_eval.py    # chunks, evaluation, safety tests
python tools/validate.py           # referential integrity — run this in CI
```

`validate.py` exits non-zero on any broken cross-reference. Wire it into your
ingestion pipeline before anything reaches the vector database.

---

## What's here

| Dataset | Records | Embed? | Store |
|---|---:|:-:|---|
| `navigation/entities.json` | 34 | alias sentence only | Postgres |
| `navigation/pages.json` | 18 | ❌ | Postgres |
| `navigation/aliases.json` | 275 | ❌ | Postgres + trigram |
| `navigation/categories.json` | 11 | ❌ | Postgres |
| `rag/faq.json` | 112 | ✅ | Vector + Postgres |
| `rag/game_knowledge.json` | 8 | ✅ | Vector + Postgres |
| `rag/help_articles.json` | 2 | ✅ | Vector + Postgres |
| `rag/policies.json` | 14 | ✅ *(once real)* | Vector + Postgres |
| `rag/chunks_example.json` | 8 | ❌ | Reference |
| `intents/intent_examples.json` | 159 | ❌ | Few-shot / classifier |
| `intents/nl_alias_queries.json` | 73 | ❌ | Feeds alias table |
| `intents/ambiguous_queries.json` | 52 | ❌ | Few-shot + eval |
| `intents/followups.json` | 52 | ❌ | Few-shot + eval |
| `intents/actions.json` | 14 | ❌ | Config |
| `evaluation/*.json` | 141 | ❌ | CI gates |

**Coverage:** 43 of 112 FAQs are flagged `requires_verified_source` — those must
not state specifics until your policy is loaded. 29 of 38 safety cases expect a
refusal or clarification.

---

## The one principle

**The vector database never decides where to navigate.**

```
"aviator kholo"  →  entity_id: game_aviator  →  Postgres lookup  →  /games/aviator
                    ↑ model emits this        ↑ backend resolves this
```

The model emits a canonical `entity_id`. The backend resolves the route. The action
executor has no code path that accepts a URL from the model, which is what prevents
invented links.

---

## Docs

- **`docs/01-schemas.md`** — every schema, the confidence policy, what gets embedded
  and what must not, and the non-negotiable safety rules.
- **`docs/02-metadata.md`** — metadata fields, which are filters vs. payload,
  per-type chunking strategy, Postgres/vector split, retrieval method per dataset.
- **`docs/03-architecture.md`** — ingestion and retrieval pipelines, CI gates, and
  worked API request/response samples including refusals.

---

## Before this ships

1. Replace all 14 policy placeholders with your published documentation.
2. Replace every `route` with your real routing table.
3. Have compliance review the responsible-gaming and refusal behaviours.
4. Add your real game catalogue — the 8 game records are generic examples.
5. Get native review of the Hinglish/Telugu aliases.
6. Log every low-confidence and clarification event; that log is your best source
   of new aliases.
