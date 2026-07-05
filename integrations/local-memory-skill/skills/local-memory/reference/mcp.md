# MCP tools reference

The Local Memory MCP server exposes 24 tools. Parameters below match the current
(v1.5.x) tool schemas. In prose, reference a tool as `local-memory:<name>` (assuming
the server is registered as `local-memory`); when calling, use the host's tool-call
format. Only `required` params must be supplied; everything else has the default shown.

Quick map:

| Group | Tools |
|-------|-------|
| Orient | `bootstrap`, `status` |
| Capture | `observe`, `question` |
| Retrieve | `search`, `ask`, `summarize`, `get_memory_by_id` |
| Synthesize / mature | `reflect`, `evolve`, `resolve`, `questions` |
| Graph | `relate`, `find_related`, `discover`, `map_graph` |
| Reason | `predict`, `explain`, `counterfactual` |
| Maintain | `validate`, `update_memory`, `delete_memory`, `migrate_domain`, `temporal` |

---

## Orient

### bootstrap
Initialize a session with relevant context. Returns `memory_stats` (counts by level,
domain, relationships, questions, recent activity) and highlights. Call once at the start.
- `mode` — `full` (default) | `minimal` | `domain`
- `domain` — required when `mode="domain"`
- `include_questions` / `include_learnings` / `include_patterns` — bool, default true
- `limit` — items per category (default 20, max 100)
- `session_id`

```
bootstrap(mode="full", include_questions=true)
bootstrap(mode="domain", domain="programming")
```

### status
Knowledge-base health and composition: totals, level distribution, open questions,
recent activity. Use to confirm the service is up and to orient.
- `response_format` — `detailed` (default) | `concise` | `summary`

---

## Capture

### observe
Record intake. L0 by default; pass `level` to store higher. Capture context/source,
not just the fact.
- `content` *(required)*
- `level` — `observation` (default) | `learning` | `pattern` | `schema`
- `tags` — string[]
- `domain`, `source`, `context`
- `weight` — 0.0–10.0 initial weight
- `auto_promote` — bool, default false
- `session_id`

```
observe(content="Redis SCAN is O(1) per call but O(N) overall",
        tags=["redis","performance"], domain="databases")
observe(content="Circuit breaker prevents cascading failures",
        level="learning", weight=3.5, auto_promote=true)
```

### question
Record a knowledge gap or conflict (this *records*; use `questions` to *list*).
- `content` *(required)*
- `question_type` — `epistemic_gap` (default) | `contradiction` | `prediction_failure`
- `priority` — 1–10, default 5
- `domain`, `origin_context`, `session_id`
- `response_format` — `detailed` | `concise` (default) | `ids_only`

---

## Retrieve

### search
Semantic / tag / date / hybrid search. Use this when you have a query string and want
ranked memories (use `ask` when you want a synthesized answer).
- `query` — required for `semantic`/`hybrid`
- `tags` — required for `tags`/`hybrid`
- `search_type` — `semantic` (default) | `tags` | `date_range` | `hybrid`
- `use_ai` — bool, default false; enables vector embeddings (more accurate, slower)
- `domain`, `start_date`, `end_date` (YYYY-MM-DD)
- `session_filter_mode` — `all` (default) | `session_only` | `session_and_shared`
- `limit` — default 5, max 100
- `format` — `intelligent` (default) | `detailed` | `summary` | `ids_only` (token-budgeted)
- `max_tokens` — budget for `intelligent` (default 1000, 50–8000)
- `response_format` — `detailed` | `concise` (default) | `ids_only` | `summary` | `custom`
- `response_template` — e.g. `agent_minimal`, `analysis_ready`, `relationship_focused`
- `cursor` / `page_size` — pagination

```
search(query="machine learning deployment", domain="ai", format="intelligent", max_tokens=500)
search(tags=["python"], search_type="tags", page_size=20)
```

### ask
Natural-language Q&A grounded in stored memories (synthesized answer + sources).
- `question` *(required)*
- `context_limit` — memories used as context (default 5, max 50)
- `session_id`, `session_filter_mode` — `session_only` | `session_and_shared`
- `response_format` — `detailed` (default) | `concise` | `ids_only`

### summarize
Summarize memories over a timeframe.
- `timeframe` — `day` | `week` | `month` | `all` (default)
- `limit` — default 20, max 100
- `session_id`
- `response_format` — `detailed` (default) | `concise` | `summary`

### get_memory_by_id
Direct lookup by ID; returns full content, level, weight, tags, metadata.
- `id` *(required)*

---

## Synthesize & mature

### reflect
Process observations (L0) into learnings (L1).
- `mode` — `single` | `batch` | `auto` (default `single`)
- `observation_id` — required for `single` (UUID)
- `batch_size` — default 10, max 50 (for `batch`)
- `auto_criteria` — e.g. `time_based` (for `auto`)
- `dry_run` — preview promotions without writing/invoking the model (default false)
- `session_id`

```
reflect(mode="batch", batch_size=10)
reflect(mode="single", observation_id="<uuid>")
```

### evolve
Lifecycle operations on a memory.
- `operation` *(required)* — `validate` | `promote` | `decay` | `accommodate`
- `entity_id` — required for `validate`/`promote` (UUID)
- `success` — required for `validate` (bool)
- `context` — rationale
- `threshold_days` — for `decay` (default 30, max 365)
- `dry_run` — preview (recommended for `decay`)
- `session_id`

```
evolve(operation="validate", entity_id="<uuid>", success=true, context="held up in prod")
evolve(operation="decay", threshold_days=30, dry_run=true)
```

### resolve
Close a question or reconcile a contradiction.
- `question_id` *(required, UUID)*
- `resolution_type` *(required)* — `answered` | `a_supersedes` | `b_supersedes` |
  `conditional` | `merged` | `context` | `invalidated`
- `rationale` *(required)*
- `synthesis_content` + `create_synthesis` — for `merged`, optionally mint a new memory
- `update_weights` (default true), `update_relationship` (default true)
- `response_format` — `detailed` (default) | `concise` | `ids_only`

### questions
List existing questions/contradictions/gaps (to record one, use `question`).
- `status` — `pending` (default) | `investigating` | `resolved` | `archived`
- `question_type` — filter; `priority_min`; `domain`; `session_id`
- `limit` (default 50, max 200), `offset`
- `response_format` — `detailed` (default) | `concise` | `summary` | `ids_only`

---

## Graph

### relate
Create a typed edge between two memories.
- `source_memory_id`, `target_memory_id` *(required, UUIDs)*
- `relationship_type` — `references` (default) | `contradicts` | `expands` | `similar` |
  `sequential` | `causes` | `enables`
- `strength` — 0.0–1.0, **default 0.5** (note: the CLI `relate` default is 0.8)
- `context`, `session_id`

### find_related
Related memories for a seed ID, via graph edges + vector similarity.
- `memory_id` *(required)*
- `limit` (default 10, max 100)
- `min_similarity` — 0.0–1.0, default 0.0 (returns all)
- `response_format` — `detailed` (default) | `concise` | `ids_only`

### discover
Latent relationship candidates across the base — no ID needed.
- `limit` (default 10, max 100)
- `min_strength` — default 0.5
- `memory_id` — optional scope; `session_id` — optional scope
- `relationship_type_filter` — string[]
- `response_format` — `detailed` (default) | `concise` | `ids_only`

### map_graph
Traverse explicit `relate` edges around a memory; returns nodes/edges/distances.
- `memory_id` *(required)*
- `depth` — hops, default 2, max 5
- `response_format` — `concise` (default) | `detailed` | `ids_only`

---

## Reason

### predict
Predict outcomes from patterns/schemas.
- `given` *(required)*; `action` (optional)
- `domain`; `schema_ids` (string[]); `use_ai` (default false); `limit` (default 5, max 20)
- `response_format` — `detailed` (default) | `concise` | `summary` | `ids_only`

### explain
Trace the causal path between two states.
- `from_state`, `to_state` *(required)*
- `max_depth` — hops, default 4, max 10; `domain`; `use_ai`
- `response_format` — `detailed` (default) | `concise` | `summary` | `ids_only`

### counterfactual
"What if" reasoning over an alternative condition.
- `observed`, `if_condition` *(required)*
- `domain`; `schema_ids`; `use_ai`
- `response_format` — `detailed` (default) | `concise` | `summary` | `ids_only`

---

## Maintain

### validate
Knowledge-graph integrity check (read-only by default).
- `checks` — subset of `orphaned_reference`, `relationship_cycle`,
  `weight_inconsistency`, `stale_question`, `promotion_chain_broken`,
  `duplicate_relationship` (empty = all)
- `auto_fix` — default false
- `dry_run` — default **true**
- `confirm_auto_fix` — **required** to actually apply fixes (with `auto_fix=true,
  dry_run=false`)
- `domain`, `batch_size` (default 1000), `session_id`
- `response_format` — `detailed` (default) | `concise` | `ids_only` | `summary`

```
validate()                                              # preview all
validate(auto_fix=true, dry_run=false, confirm_auto_fix=true)   # apply
```

### update_memory
Correct existing knowledge (content/importance/tags/domain). Prefer `evolve(promote)`
when the knowledge has *advanced*; use `update_memory` for *corrections*.
- `id` *(required)*; `content`, `importance` (1–10), `tags`, `domain`

### delete_memory
Permanently remove a memory. Use only for genuinely erroneous entries — if knowledge is
merely superseded, prefer `resolve`/`evolve(accommodate)` to keep traceability.
- `id` *(required)*  *(Not pre-approved by this skill — destructive.)*

### migrate_domain
Bulk-rename memories from one domain to another (case-insensitive match).
- `from_domain`, `to_domain` *(required)*
- `dry_run` — default **true** (preview first); `session_id` — optional scope

### temporal
Analyze how knowledge evolves over time.
- `operation` *(required)* — `patterns` | `progression` | `gaps` | `timeline`
- `concept` — required for `progression`; optional for `patterns`/`timeline`
- `timeframe` — `week` | `month` (default) | `quarter` | `year` (for `patterns`)
- `analysis_type` — `learning_progression` (default) | `knowledge_gaps` | `concept_evolution`
- `focus_areas` (for `gaps`); `start_date`/`end_date`/`memory_ids` (for `timeline`)
- `response_format` — `detailed` | `concise` (default) | `summary`

---

## Deprecated tools

Hidden but still functional for backward compatibility (avoid in new work; slated for
removal in v2.0): `store_memory` → use `observe`; `analysis` → `predict`/`explain`/
`counterfactual`; `stats` → `status`; `relationships` → `relate`; `sessions` →
`bootstrap`; `domains` → `domain` param; `categories` → `tags` param.
