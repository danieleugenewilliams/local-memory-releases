# MCP Tools Reference

Local Memory's MCP (Model Context Protocol) server exposes **24 tools** for complete
knowledge-engineering and memory management. These tools are designed for both human
users and AI agents, with intelligent token optimization, pagination support, and
flexible response formats.

Parameters below match the current **v1.5.1** tool schemas. Only `required` params must
be supplied; everything else uses the default shown. In prose, reference a tool as
`local-memory:<name>` (assuming the server is registered as `local-memory`); when
calling, use your host's tool-call format.

## Overview

The 24 tools cover the full knowledge lifecycle:

- Orienting a session and checking service health
- Capturing observations and recording open questions
- Retrieving and synthesizing answers from stored knowledge
- Maturing raw observations into durable learnings and patterns
- Building and traversing a relationship graph between memories
- Reasoning over patterns (prediction, causal explanation, counterfactuals)
- Maintaining integrity (validation, corrections, deletions, domain migration, temporal analysis)

## Tool Categories

| Group | Tools |
|-------|-------|
| **Orient** | `bootstrap`, `status` |
| **Capture** | `observe`, `question` |
| **Retrieve** | `search`, `ask`, `summarize`, `get_memory_by_id` |
| **Synthesize / mature** | `reflect`, `evolve`, `resolve`, `questions` |
| **Graph** | `relate`, `find_related`, `discover`, `map_graph` |
| **Reason** | `predict`, `explain`, `counterfactual` |
| **Maintain** | `validate`, `update_memory`, `delete_memory`, `migrate_domain`, `temporal` |

---

## Orient

### bootstrap

**Purpose**: Initialize a session with relevant context. Returns memory statistics
(counts by level, domain, relationships, questions, recent activity) plus highlights.
Call once at the start of a session.

**Parameters**:
- `mode` (string, optional): `full` (default), `minimal`, or `domain`
- `domain` (string): required when `mode="domain"`
- `include_questions` (boolean, optional): default `true`
- `include_learnings` (boolean, optional): default `true`
- `include_patterns` (boolean, optional): default `true`
- `limit` (integer, optional): items per category (default 20, max 100)
- `session_id` (string, optional)

**Usage Examples**:
```javascript
bootstrap(mode="full", include_questions=true)
bootstrap(mode="domain", domain="programming")
```

**Best Practices**: Run `bootstrap` at session start to load relevant context before
doing other work. Use `mode="domain"` to focus on a single knowledge area.

### status

**Purpose**: Report knowledge-base health and composition: totals, level distribution,
open questions, and recent activity. Use to confirm the service is up and to orient.

**Parameters**:
- `response_format` (string, optional): `detailed` (default), `concise`, `summary`

**Usage Example**:
```javascript
status()
status(response_format="summary")
```

**Best Practices**: A quick, read-only health check — good for confirming connectivity
and getting a high-level snapshot of the knowledge base.

---

## Capture

### observe

**Purpose**: Record intake. Stored at the observation level (L0) by default; pass `level`
to store higher. Capture context and source, not just the bare fact.

**Parameters**:
- `content` (string, **required**): the memory content to store
- `level` (string, optional): `observation` (default), `learning`, `pattern`, `schema`
- `tags` (array of strings, optional): tags for categorization
- `domain` (string, optional): knowledge domain for organization
- `source` (string, optional): where the observation came from
- `context` (string, optional): additional context
- `weight` (number, optional): initial weight, 0.0–10.0
- `auto_promote` (boolean, optional): default `false`
- `session_id` (string, optional)

**Usage Examples**:
```javascript
observe(content="Redis SCAN is O(1) per call but O(N) overall",
        tags=["redis","performance"], domain="databases")
observe(content="Circuit breaker prevents cascading failures",
        level="learning", weight=3.5, auto_promote=true)
```

**Best Practices**: Record the surrounding context and source so the memory stays useful
later. Leave everyday intake at the default `observation` level and let `reflect` promote
it; reserve higher levels for knowledge you already know is durable.

### question

**Purpose**: Record a knowledge gap or conflict. This *records* a question; use the
`questions` tool to *list* existing ones.

**Parameters**:
- `content` (string, **required**): the question, gap, or contradiction
- `question_type` (string, optional): `epistemic_gap` (default), `contradiction`, `prediction_failure`
- `priority` (integer, optional): 1–10, default 5
- `domain` (string, optional)
- `origin_context` (string, optional)
- `session_id` (string, optional)
- `response_format` (string, optional): `detailed`, `concise` (default), `ids_only`

**Usage Example**:
```javascript
question(content="Why does the cache miss rate spike after deploys?",
         question_type="epistemic_gap", priority=7, domain="infra")
```

**Best Practices**: Log open questions as you encounter them so they can be resolved
later with `resolve`. Use `contradiction` when two memories conflict.

---

## Retrieve

### search

**Purpose**: Semantic, tag, date-range, or hybrid search across all memories. Use this
when you have a query string and want ranked memories; use `ask` when you want a
synthesized answer. Features intelligent token optimization, cursor-based pagination, and
flexible response formats.

**Parameters**:
- `query` (string): required for `semantic`/`hybrid`
- `tags` (array of strings): required for `tags`/`hybrid`
- `search_type` (string, optional): `semantic` (default), `tags`, `date_range`, `hybrid`
- `use_ai` (boolean, optional): default `false`; enables vector embeddings (more accurate, slower)
- `domain` (string, optional): filter by knowledge domain
- `start_date` / `end_date` (string, optional): date range in `YYYY-MM-DD`
- `session_filter_mode` (string, optional): `all` (default), `session_only`, `session_and_shared`
- `limit` (integer, optional): default 5, max 100
- `format` (string, optional): `intelligent` (default), `detailed`, `summary`, `ids_only` (token-budgeted)
- `max_tokens` (integer, optional): budget for `intelligent` format (default 1000, range 50–8000)
- `response_format` (string, optional): `detailed`, `concise` (default), `ids_only`, `summary`, `custom`
- `response_template` (string, optional): e.g. `agent_minimal`, `analysis_ready`, `relationship_focused`
- `cursor` / `page_size` (optional): pagination

**Usage Examples**:
```javascript
search(query="machine learning deployment", domain="ai", format="intelligent", max_tokens=500)
search(tags=["python"], search_type="tags", page_size=20)
search(search_type="hybrid", query="neural networks", tags=["deep-learning"], domain="ai")
```

**Best Practices**: Use semantic search for natural language, `tags`/`hybrid` for
precision. Leverage the `intelligent` format with a `max_tokens` budget for token
efficiency, and use cursors for large result sets.

### ask

**Purpose**: Natural-language Q&A grounded in stored memories — returns a synthesized
answer plus its sources.

**Parameters**:
- `question` (string, **required**): the natural-language question
- `context_limit` (integer, optional): memories used as context (default 5, max 50)
- `session_id` (string, optional)
- `session_filter_mode` (string, optional): `session_only`, `session_and_shared`
- `response_format` (string, optional): `detailed` (default), `concise`, `ids_only`

**Usage Example**:
```javascript
ask(question="What are the main challenges in machine learning deployment?")
```

**Best Practices**: Ask specific questions. Raise `context_limit` when an answer needs
broader grounding; validate the synthesized answer against its cited source memories.

### summarize

**Purpose**: Summarize memories over a timeframe.

**Parameters**:
- `timeframe` (string, optional): `day`, `week`, `month`, `all` (default)
- `limit` (integer, optional): default 20, max 100
- `session_id` (string, optional)
- `response_format` (string, optional): `detailed` (default), `concise`, `summary`

**Usage Example**:
```javascript
summarize(timeframe="week", response_format="concise")
```

**Best Practices**: Use to review recent activity or produce a rollup of a domain's
memories over a period.

### get_memory_by_id

**Purpose**: Direct lookup by ID; returns full content, level, weight, tags, and metadata.

**Parameters**:
- `id` (string, **required**): the memory ID to retrieve

**Usage Example**:
```javascript
get_memory_by_id(id="550e8400-e29b-41d4-a716-446655440000")
```

---

## Synthesize & mature

### reflect

**Purpose**: Process observations (L0) into learnings (L1).

**Parameters**:
- `mode` (string, optional): `single` (default), `batch`, `auto`
- `observation_id` (string): required for `single` (UUID)
- `batch_size` (integer, optional): default 10, max 50 (for `batch`)
- `auto_criteria` (string, optional): e.g. `time_based` (for `auto`)
- `dry_run` (boolean, optional): preview promotions without writing or invoking the model (default `false`)
- `session_id` (string, optional)

**Usage Examples**:
```javascript
reflect(mode="batch", batch_size=10)
reflect(mode="single", observation_id="<uuid>")
```

**Best Practices**: Run `reflect` periodically to mature accumulated observations into
durable learnings. Use `dry_run=true` to preview which observations would be promoted.

### evolve

**Purpose**: Lifecycle operations on a memory — validation, promotion, decay, and
accommodation.

**Parameters**:
- `operation` (string, **required**): `validate`, `promote`, `decay`, `accommodate`
- `entity_id` (string): required for `validate`/`promote` (UUID)
- `success` (boolean): required for `validate`
- `context` (string, optional): rationale
- `threshold_days` (integer, optional): for `decay` (default 30, max 365)
- `dry_run` (boolean, optional): preview (recommended for `decay`)
- `session_id` (string, optional)

**Usage Examples**:
```javascript
evolve(operation="validate", entity_id="<uuid>", success=true, context="held up in prod")
evolve(operation="decay", threshold_days=30, dry_run=true)
```

**Best Practices**: Use `validate` to reinforce or weaken a memory based on whether it
held up; use `promote` when knowledge has advanced. Preview `decay` with `dry_run=true`
before applying.

### resolve

**Purpose**: Close a question or reconcile a contradiction.

**Parameters**:
- `question_id` (string, **required**): the question to resolve (UUID)
- `resolution_type` (string, **required**): `answered`, `a_supersedes`, `b_supersedes`, `conditional`, `merged`, `context`, `invalidated`
- `rationale` (string, **required**): why the question was resolved this way
- `synthesis_content` (string, optional): with `create_synthesis`, mint a new memory (for `merged`)
- `create_synthesis` (boolean, optional)
- `update_weights` (boolean, optional): default `true`
- `update_relationship` (boolean, optional): default `true`
- `response_format` (string, optional): `detailed` (default), `concise`, `ids_only`

**Usage Example**:
```javascript
resolve(question_id="<uuid>", resolution_type="a_supersedes",
        rationale="Newer benchmark supersedes the earlier measurement")
```

**Best Practices**: Prefer `resolve` over deletion when knowledge is superseded — it
preserves traceability. Use `merged` with `create_synthesis` to fold two conflicting
memories into one.

### questions

**Purpose**: List existing questions, contradictions, and gaps. To record a new one, use
the `question` tool.

**Parameters**:
- `status` (string, optional): `pending` (default), `investigating`, `resolved`, `archived`
- `question_type` (string, optional): filter by type
- `priority_min` (integer, optional)
- `domain` (string, optional)
- `session_id` (string, optional)
- `limit` (integer, optional): default 50, max 200
- `offset` (integer, optional)
- `response_format` (string, optional): `detailed` (default), `concise`, `summary`, `ids_only`

**Usage Example**:
```javascript
questions(status="pending", priority_min=7)
```

**Best Practices**: Review pending questions at session start (alongside `bootstrap`) to
decide what to investigate next.

---

## Graph

### relate

**Purpose**: Create a typed edge between two memories.

**Parameters**:
- `source_memory_id` (string, **required**, UUID)
- `target_memory_id` (string, **required**, UUID)
- `relationship_type` (string, optional): `references` (default), `contradicts`, `expands`, `similar`, `sequential`, `causes`, `enables`
- `strength` (number, optional): 0.0–1.0, default **0.5** (note: the CLI `relate` default is 0.8)
- `context` (string, optional)
- `session_id` (string, optional)

**Usage Example**:
```javascript
relate(source_memory_id="id1", target_memory_id="id2",
       relationship_type="expands", strength=0.9)
```

**Best Practices**: Use explicit relationships to encode structure the vector index can't
infer (e.g. `causes`, `sequential`). Use `strength` to prioritize edges.

### find_related

**Purpose**: Find related memories for a seed ID, via graph edges plus vector similarity.

**Parameters**:
- `memory_id` (string, **required**): the seed memory
- `limit` (integer, optional): default 10, max 100
- `min_similarity` (number, optional): 0.0–1.0, default 0.0 (returns all)
- `response_format` (string, optional): `detailed` (default), `concise`, `ids_only`

**Usage Example**:
```javascript
find_related(memory_id="<uuid>", limit=5)
```

### discover

**Purpose**: Surface latent relationship candidates across the knowledge base — no seed
ID required.

**Parameters**:
- `limit` (integer, optional): default 10, max 100
- `min_strength` (number, optional): default 0.5
- `memory_id` (string, optional): scope to one memory
- `session_id` (string, optional): scope to a session
- `relationship_type_filter` (array of strings, optional)
- `response_format` (string, optional): `detailed` (default), `concise`, `ids_only`

**Usage Example**:
```javascript
discover(limit=10, min_strength=0.6)
```

**Best Practices**: Run periodically to find implicit connections you haven't recorded,
then promote strong candidates with `relate`.

### map_graph

**Purpose**: Traverse explicit `relate` edges around a memory; returns nodes, edges, and
distances.

**Parameters**:
- `memory_id` (string, **required**): the central memory
- `depth` (integer, optional): hops, default 2, max 5
- `response_format` (string, optional): `concise` (default), `detailed`, `ids_only`

**Usage Example**:
```javascript
map_graph(memory_id="<uuid>", depth=2)
```

**Best Practices**: Use for visualizing a neighborhood of connected knowledge. Keep
`depth` low on large graphs to control response size.

---

## Reason

### predict

**Purpose**: Predict outcomes from stored patterns and schemas.

**Parameters**:
- `given` (string, **required**): the current condition
- `action` (string, optional): the action being considered
- `domain` (string, optional)
- `schema_ids` (array of strings, optional)
- `use_ai` (boolean, optional): default `false`
- `limit` (integer, optional): default 5, max 20
- `response_format` (string, optional): `detailed` (default), `concise`, `summary`, `ids_only`

**Usage Example**:
```javascript
predict(given="cache hit rate dropped after deploy", action="roll back", domain="infra")
```

### explain

**Purpose**: Trace the causal path between two states.

**Parameters**:
- `from_state` (string, **required**)
- `to_state` (string, **required**)
- `max_depth` (integer, optional): hops, default 4, max 10
- `domain` (string, optional)
- `use_ai` (boolean, optional): default `false`
- `response_format` (string, optional): `detailed` (default), `concise`, `summary`, `ids_only`

**Usage Example**:
```javascript
explain(from_state="deploy shipped", to_state="latency regression")
```

### counterfactual

**Purpose**: "What if" reasoning over an alternative condition.

**Parameters**:
- `observed` (string, **required**): what actually happened
- `if_condition` (string, **required**): the alternative condition
- `domain` (string, optional)
- `schema_ids` (array of strings, optional)
- `use_ai` (boolean, optional): default `false`
- `response_format` (string, optional): `detailed` (default), `concise`, `summary`, `ids_only`

**Usage Example**:
```javascript
counterfactual(observed="outage lasted 40 minutes",
               if_condition="circuit breaker had been enabled")
```

**Best Practices**: The Reason tools work best once you have matured `pattern`/`schema`
level memories. Enable `use_ai=true` for richer inference at the cost of latency.

---

## Maintain

### validate

**Purpose**: Knowledge-graph integrity check. Read-only by default; can apply automatic
fixes when explicitly confirmed.

**Parameters**:
- `checks` (array of strings, optional): subset of `orphaned_reference`, `relationship_cycle`, `weight_inconsistency`, `stale_question`, `promotion_chain_broken`, `duplicate_relationship` (empty = all)
- `auto_fix` (boolean, optional): default `false`
- `dry_run` (boolean, optional): default **`true`**
- `confirm_auto_fix` (boolean, optional): default `false`; **required** to actually apply fixes (with `auto_fix=true, dry_run=false`)
- `domain` (string, optional)
- `batch_size` (integer, optional): default 1000
- `session_id` (string, optional)
- `response_format` (string, optional): `detailed` (default), `concise`, `ids_only`, `summary`

**Usage Examples**:
```javascript
validate()                                                    // preview all checks
validate(auto_fix=true, dry_run=false, confirm_auto_fix=true) // apply fixes
```

**Best Practices**: Always preview first (the default). Applying fixes is a deliberate,
three-flag action (`auto_fix`, `dry_run=false`, `confirm_auto_fix`) to prevent accidental
data modification.

### update_memory

**Purpose**: Correct existing knowledge (content, importance, tags, or domain). Prefer
`evolve(promote)` when the knowledge has *advanced*; use `update_memory` for
*corrections*.

**Parameters**:
- `id` (string, **required**): the memory to update
- `content` (string, optional): updated content
- `importance` (integer, optional): 1–10
- `tags` (array of strings, optional): updated tags
- `domain` (string, optional): updated domain

**Usage Examples**:
```javascript
update_memory(id="<uuid>", content="Corrected transformer knowledge")
update_memory(id="<uuid>", importance=10)
```

### delete_memory

**Purpose**: Permanently remove a memory. Use only for genuinely erroneous entries — if
knowledge is merely superseded, prefer `resolve` or `evolve(accommodate)` to keep
traceability.

**Parameters**:
- `id` (string, **required**): the memory to delete

**Usage Example**:
```javascript
delete_memory(id="<uuid>")
```

**Best Practices**: Destructive and irreversible. Reach for `resolve`/`evolve` first;
delete only truly wrong data.

### migrate_domain

**Purpose**: Bulk-rename memories from one domain to another (case-insensitive match).

**Parameters**:
- `from_domain` (string, **required**)
- `to_domain` (string, **required**)
- `dry_run` (boolean, optional): default **`true`** (preview first)
- `session_id` (string, optional): scope to a session

**Usage Examples**:
```javascript
migrate_domain(from_domain="ml", to_domain="machine-learning", dry_run=true)
migrate_domain(from_domain="ml", to_domain="machine-learning", dry_run=false)
```

**Best Practices**: Preview with the default `dry_run=true` to confirm the match set
before committing the rename.

### temporal

**Purpose**: Analyze how knowledge evolves over time.

**Parameters**:
- `operation` (string, **required**): `patterns`, `progression`, `gaps`, `timeline`
- `concept` (string): required for `progression`; optional for `patterns`/`timeline`
- `timeframe` (string, optional): `week`, `month` (default), `quarter`, `year` (for `patterns`)
- `analysis_type` (string, optional): `learning_progression` (default), `knowledge_gaps`, `concept_evolution`
- `focus_areas` (array of strings, optional): for `gaps`
- `start_date` / `end_date` (string, optional): for `timeline`
- `memory_ids` (array of strings, optional): for `timeline`
- `response_format` (string, optional): `detailed`, `concise` (default), `summary`

**Usage Examples**:
```javascript
temporal(operation="patterns", timeframe="quarter")
temporal(operation="progression", concept="deep learning")
```

**Best Practices**: Use `progression` to track mastery of a concept over time and `gaps`
to surface areas that need more observation.

---

## Deprecated tools

Seven earlier tool names are retained for backward compatibility but hidden by default
(they appear only when the server is started with `enable_legacy_tools=true`). Avoid them
in new work — they are slated for removal in v2.0. Each maps to a current tool or
parameter:

| Deprecated | Use instead |
|------------|-------------|
| `store_memory` | `observe` |
| `analysis` | `predict` / `explain` / `counterfactual` |
| `stats` | `status` |
| `relationships` | `relate` (and `find_related` / `discover` / `map_graph`) |
| `sessions` | `bootstrap` |
| `domains` | the `domain` parameter on other tools |
| `categories` | the `tags` parameter on other tools |

> `delete_memory` is **not** deprecated — it is one of the 24 current tools.

---

## Integration Patterns

### Best Practices Summary

1. **Orient first**: Call `bootstrap` at session start; use `status` to confirm the service is up.
2. **Capture with context**: Record source and context in `observe`, not just the bare fact.
3. **Let knowledge mature**: Use `reflect` and `evolve` to promote observations into durable learnings and patterns.
4. **Preserve traceability**: Prefer `resolve` / `evolve(accommodate)` over `delete_memory` when knowledge is superseded.
5. **Search vs. ask**: Use `search` for ranked memories, `ask` for a synthesized answer.
6. **Token management**: Choose `format` / `response_format` and `max_tokens` based on your budget; use cursors/pagination for large result sets.
7. **Validate deliberately**: Preview with `validate()`; apply fixes only with the explicit three-flag confirmation.
