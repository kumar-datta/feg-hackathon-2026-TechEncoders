# Metadata Design (PART 12)

Metadata is what makes hybrid retrieval controllable. Without it you get one flat
similarity search over everything, which is why assistants answer deposit questions
with withdrawal content.

---

## Full schema

| Field | Type | Filterable | Purpose |
|---|---|:-:|---|
| `document_id` | string | ✅ | Parent document. Groups chunks for re-ranking and citation. |
| `chunk_id` | string | ✅ | Unique chunk key. Idempotent upserts. |
| `document_type` | enum | ✅ **primary** | `FAQ` \| `GAME_KNOWLEDGE` \| `POLICY` \| `HELP_ARTICLE` \| `ENTITY_ALIAS` |
| `category` | enum | ✅ **primary** | `DEPOSIT`, `WITHDRAWAL`, `KYC`, `BETTING`, `GAMES`, … |
| `subcategory` | string | ✅ | Narrower split, e.g. `pending_deposit`. |
| `language` | enum | ✅ **primary** | `en` \| `hi` \| `te` \| `mixed`. |
| `game_id` | string \| null | ✅ | Joins a chunk to a navigation entity. Enables "answer + open game". |
| `page_id` | string \| null | ✅ | Drives the action buttons under an answer. |
| `source` | string | ○ | Originating file/system. |
| `source_url` | string \| null | ○ | Citation target. **Never** synthesised by the model. |
| `created_at` / `updated_at` | timestamp | ✅ | Freshness ranking, staleness alerts. |
| `version` | int | ○ | Rollback and A/B of content revisions. |
| `status` | enum | ✅ **primary** | `active` \| `draft` \| `deprecated`. Filter to `active` on every query. |
| `priority` | enum | ○ | `high`/`medium`/`low` — a re-ranking tiebreaker, not a filter. |
| `access_level` | enum | ✅ **primary** | `public` \| `authenticated` \| `internal`. |
| `requires_verified_source` | bool | ✅ | If true, the model must not state specifics. |
| `jurisdiction` | string \| null | ✅ | Region-gating for policy content. |

---

## Which fields are filters vs. payload

**Hard pre-filters — applied before vector search, always:**

```
status = 'active'
AND access_level IN (allowed_for_this_session)
AND (jurisdiction IS NULL OR jurisdiction = user_region)
AND (language = user_language OR language = 'en')
```

These four are non-negotiable. Skipping `access_level` leaks internal content;
skipping `jurisdiction` shows a user a policy that does not apply to them.

**Soft filters — narrow when intent is confident:**

`document_type`, `category`, `game_id`, `page_id`.

Routing by `category` once the intent classifier is confident is the single highest-value
retrieval improvement available. A `WITHDRAWAL` query searching only `category='WITHDRAWAL'`
avoids the entire deposit corpus, which is lexically near-identical.

**Payload only — never filtered on:** `source`, `source_url`, `version`, `created_at`.

**Re-ranking signals — not filters:** `priority`, `updated_at`.

---

## Chunking strategy per document type

Uniform chunk size is the most common RAG mistake. Different content has different
natural boundaries.

| Type | Strategy | Target size | Overlap | Rationale |
|---|---|---|---|---|
| **FAQ** | One chunk per Q&A pair — **never split** | 50–150 tokens | 0 | The pair *is* the unit. Splitting orphans the answer from its question. |
| **Game rules** | Split on semantic section (`description`, `how_to_play`, `terminology`) | 100–250 tokens | 0 | Sections are already self-contained. Keep glossaries whole. |
| **Policy** | Split on clause/article boundary | 200–400 tokens | 10% | Legal meaning depends on clause integrity. Never split mid-sentence. |
| **Help articles** | Sliding window over the narrative | 300–500 tokens | 15% | Prose has cross-references; overlap preserves them. |
| **Long documents** | Hierarchical: section → paragraph, with a parent summary | 400–600 tokens | 15% | Retrieve the small chunk, optionally expand to the parent for context. |
| **Entity aliases** | One sentence per entity | 20–40 tokens | 0 | Recall aid only. Truth lives in Postgres. |

**Rules that override the table**

1. Never split a Q&A pair, a glossary entry, or a numbered step list.
2. Always prepend the document title to the chunk text before embedding — it cheaply
   restores context the chunk lost.
3. Chunks under ~20 tokens are noise. Merge them upward.
4. Store `approx_tokens`; it's your first diagnostic when retrieval degrades.

---

## Storage split

### PostgreSQL — the source of truth

```
entities            id, type, name, description, category, parent_id,
                    route, status, requires_auth, requires_kyc
entity_aliases      alias, entity_id, match_type    -- + trigram index
pages               page_id, route, page_type, available_actions
actions             action, requires_entity_type, requires_auth, confirm_before_execute
documents           document_id, type, category, version, status, updated_at
chunks              chunk_id, document_id, content, metadata   -- mirror for BM25 + audit
conversations       session_id, turns, focus_stack
```

Why the chunk text is mirrored in Postgres: it gives you BM25 via `tsvector`, an
audit trail, and the ability to rebuild the vector index from scratch without
re-sourcing content.

**Indexes that matter:**

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_alias_trgm  ON entity_aliases USING gin (alias gin_trgm_ops);
CREATE UNIQUE INDEX idx_alias_exact ON entity_aliases (alias, entity_id);
CREATE INDEX idx_chunk_fts   ON chunks USING gin (to_tsvector('english', content));
CREATE INDEX idx_chunk_meta  ON chunks ((metadata->>'category'), (metadata->>'status'));
```

The trigram index on aliases is what makes `aviater`, `avaitor` and `avitor` resolve
without a model call.

### Vector database — semantic recall only

Embed: FAQ chunks, game knowledge chunks, help article chunks, policy chunks
(once real), and one alias sentence per entity.

**Do not embed:** routes, page registry rows, action definitions, user balances,
bet histories, KYC status, transaction records.

The last three aren't a "should not" — they're per-user, change by the second, and
storing them in a shared index is both a correctness bug and a data-protection problem.

---

## Retrieval method per dataset

| Dataset | Exact | Trigram | BM25 | Vector | Hybrid | API |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Entity by `id` | ✅ | | | | | |
| Entity by alias (clean) | ✅ | | | | | |
| Entity by alias (typo) | | ✅ | ○ | ○ | ✅ | |
| Entity by description | | | ○ | ✅ | ✅ | |
| Pages | ✅ | | ✅ | | | |
| Actions | ✅ | | | | | |
| FAQ | | | ✅ | ✅ | ✅ | |
| Game knowledge | | | ○ | ✅ | ✅ | |
| Policies | | | ✅ | ✅ | ✅ | |
| Help articles | | | ○ | ✅ | ✅ | |
| Balance / bets / KYC / transactions | | | | | | ✅ |

✅ primary ○ supporting

**Entity resolution order** (stop at the first confident hit — most queries never
reach the model):

1. Exact alias match → confidence 0.98
2. Normalised exact (lowercase, strip punctuation/diacritics) → 0.95
3. Trigram similarity ≥ 0.45 → 0.75–0.90 scaled by score
4. Vector search over alias sentences → 0.60–0.85
5. Nothing above 0.45 → **clarify**

Steps 1–3 are pure Postgres: fast, cheap, deterministic, and testable.

---

## Suggested hybrid weighting

Start at **0.6 vector / 0.4 BM25**, fused with Reciprocal Rank Fusion rather than
raw score addition — the two score scales aren't comparable.

Tune per intent. Navigation-ish queries lean lexical; "explain how X works"
queries lean semantic. Treat these numbers as a starting point to be validated
against `evaluation/retrieval_eval.json`, not as settled values.
