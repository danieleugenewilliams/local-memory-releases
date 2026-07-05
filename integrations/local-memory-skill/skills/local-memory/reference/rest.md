# REST API reference

Use the REST API when you can only make HTTP calls. Base URL:
`http://localhost:3002/api/v1` (port auto-selects 3002–3005 if 3002 is busy). No auth
for local use. Ensure the daemon is running first:

```bash
local-memory start
curl http://localhost:3002/api/v1/health      # -> {"data":{"status":"healthy"},...}
```

## Response patterns (important)

Two shapes, by endpoint category:

- **CRUD / admin** (memories, search, categories, domains, system) wrap results:
  `{ "success": true, "message": "...", "data": { ... } }`
- **Knowledge-engineering** (`observe`, `question`, `evolve`, `reflect`, `predict`,
  `explain`, `counterfactual`, `resolve`, `validate`, `bootstrap`, `relate`,
  `temporal/*`) return **raw JSON** (operation-specific fields; most include
  `"success": true`, but some — e.g. `POST /bootstrap` — omit it).

For knowledge-engineering endpoints, trust the **HTTP status code** (2xx = success;
`POST /observe` returns 201 on create, others 200).
Errors: `{"error":"error","code":400,"message":"..."}` or `{"error":"not_found","id":"..."}`.

Field notes (verified against a live v1.5.0 daemon):
- `POST /observe` returns the new id in **`memory_id`** (top level), plus `level`,
  `level_label`, `suggested_actions`, and `summary` — not a `data` envelope.
- `GET /memories/search` returns `{ "count": N, "data": [...] }` (no `message`).
- `DELETE /memories/{id}` returns the full envelope and 404s on an unknown id.
- `GET /questions` works for listing even though it is omitted from the `GET /api/v1/`
  catalog.

## Core memory

```bash
# Store (creates an L0 observation by default; pass "level" to go higher)
curl -X POST http://localhost:3002/api/v1/memories \
  -H "Content-Type: application/json" \
  -d '{"content":"Your insight","importance":8,"tags":["t1","t2"],"domain":"backend"}'

# Search (always set response_format explicitly)
curl "http://localhost:3002/api/v1/memories/search?query=neural%20networks&use_ai=true&response_format=detailed"

# Advanced search with cursor pagination
curl -X POST http://localhost:3002/api/v1/memories/search \
  -H "Content-Type: application/json" \
  -d '{"query":"machine learning","limit":20,"response_format":"concise","cursor":"<opaque>"}'

# Get / update / delete by id
curl http://localhost:3002/api/v1/memories/<id>
curl -X PUT http://localhost:3002/api/v1/memories/<id> -H "Content-Type: application/json" -d '{"importance":9}'
curl -X DELETE http://localhost:3002/api/v1/memories/<id>
```

## Knowledge engineering

```bash
# Orient
curl -X POST http://localhost:3002/api/v1/bootstrap -H "Content-Type: application/json" \
  -d '{"mode":"full","include_questions":true}'
curl http://localhost:3002/api/v1/status

# Capture
curl -X POST http://localhost:3002/api/v1/observe -H "Content-Type: application/json" \
  -d '{"content":"API rate limits are 100/min","level":"learning","tags":["api","limits"]}'
curl -X POST http://localhost:3002/api/v1/question -H "Content-Type: application/json" \
  -d '{"content":"How does X persist under load?","question_type":"epistemic_gap","priority":7}'

# Synthesize & mature
curl -X POST http://localhost:3002/api/v1/reflect -H "Content-Type: application/json" -d '{"mode":"batch","batch_size":10}'
curl -X POST http://localhost:3002/api/v1/evolve  -H "Content-Type: application/json" \
  -d '{"operation":"validate","entity_id":"<uuid>","success":true}'
curl -X POST http://localhost:3002/api/v1/resolve -H "Content-Type: application/json" \
  -d '{"question_id":"<uuid>","resolution_type":"answered","rationale":"..."}'
curl "http://localhost:3002/api/v1/questions?status=pending"

# Reason
curl -X POST http://localhost:3002/api/v1/predict        -d '{"given":"high traffic","use_ai":true}' -H "Content-Type: application/json"
curl -X POST http://localhost:3002/api/v1/explain        -d '{"from_state":"login","to_state":"purchase"}' -H "Content-Type: application/json"
curl -X POST http://localhost:3002/api/v1/counterfactual -d '{"observed":"deploy failed","if_condition":"ran tests"}' -H "Content-Type: application/json"
```

## Analysis, relationships, temporal

```bash
# AI Q&A / summarize / analyze (smart-routes by analysis_type)
curl -X POST http://localhost:3002/api/v1/ask       -d '{"question":"What is Redis?","use_ai":true}' -H "Content-Type: application/json"
curl -X POST http://localhost:3002/api/v1/summarize -d '{"timeframe":"month","limit":20}'           -H "Content-Type: application/json"

# Relationships
curl -X POST http://localhost:3002/api/v1/relationships -H "Content-Type: application/json" \
  -d '{"source_memory_id":"<id1>","target_memory_id":"<id2>","relationship_type":"causes","strength":0.9}'
curl -X POST http://localhost:3002/api/v1/relationships/discover -d '{"min_strength":0.6,"limit":10}' -H "Content-Type: application/json"
curl "http://localhost:3002/api/v1/memories/<id>/related?limit=10"
curl "http://localhost:3002/api/v1/memories/<id>/graph?depth=2"

# Temporal
curl -X POST http://localhost:3002/api/v1/temporal/patterns -H "Content-Type: application/json" \
  -d '{"analysis_type":"learning_progression","concept":"machine learning","timeframe":"month"}'
curl -X POST http://localhost:3002/api/v1/temporal/gaps -d '{"focus_areas":["deep learning"]}' -H "Content-Type: application/json"
```

## Token optimization

Add `response_format` to any read: `detailed` | `concise` (~70% smaller) | `summary`
(~50%) | `ids_only` (~95%) | `custom`. Response templates also exist (`agent_minimal`,
`analysis_ready`, `relationship_focused`, `temporal_analysis`, `metadata_only`,
`full_context`).

```bash
curl -X POST http://localhost:3002/api/v1/memories/search \
  -H "Content-Type: application/json" \
  -d '{"query":"machine learning","response_format":"ids_only"}'
```

## Endpoint groups (overview)

Core memory (CRUD + search) · AI analysis (`/ask`, `/summarize`, `/analyze`) ·
relationships (`/relationships`, `/relationships/discover`, `/memories/{id}/related`,
`/memories/{id}/graph`) · temporal (`/temporal/{patterns,progression,gaps,timeline}`) ·
knowledge engineering (`/observe`, `/question`, `/bootstrap`, `/evolve`, `/reflect`,
`/predict`, `/explain`, `/counterfactual`, `/resolve`, `/questions`, `/validate`,
`/relate`, `/status`) · system (`/health`, `/stats`, `/config`). Full list: `GET /api/v1/`.
