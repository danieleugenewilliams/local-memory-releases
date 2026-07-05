# REST API Reference

Local Memory provides a comprehensive REST API accessible at `http://localhost:3002/api/v1`. The API supports JSON request/response formats and provides the full knowledge-engineering lifecycle (observe, reflect, relate, predict, explain, and more) alongside memory CRUD, search, relationship management, temporal analysis, and system management.

**Version 1.5.1**

## Base URL
```
http://localhost:3002/api/v1
```
The port auto-selects from the range 3002–3005 if 3002 is already in use. Fetch the complete, live endpoint catalog at any time with `GET /api/v1/`.

## Authentication
Currently, no authentication is required for local development. All endpoints are accessible without credentials. (Configuration endpoints require auth only when security is explicitly enabled.)

## Response Format
Responses use **two shapes** depending on the endpoint category — this distinction matters when parsing results:

**CRUD / admin** endpoints (memory create/read/update/delete, list, search, categories, domains, system) wrap their result in a consistent envelope:
```json
{
  "success": true,
  "message": "Human-readable message",
  "data": { ... }
}
```

**Knowledge-engineering** endpoints (`observe`, `question`, `reflect`, `relate`, `predict`, `explain`, `counterfactual`, `resolve`, `evolve`, `validate`, `bootstrap`, and `temporal/*`) return **raw JSON** with operation-specific fields at the top level — no `data` envelope. Most include `"success": true`, but some (for example `POST /bootstrap`) omit it, so **trust the HTTP status code** rather than relying on a `success` field for these endpoints.

## Error Responses
The API uses different error response formats depending on the error type:

**General Errors** (validation, server errors):
```json
{
  "error": "error",
  "code": 400,
  "message": "validation failed: content is required"
}
```

**Not Found Errors** (invalid IDs):
```json
{
  "error": "not_found",
  "id": "invalid-uuid"
}
```

**Error Fields**:
- `error` (string): Error type ("error", "not_found")
- `code` (integer): HTTP status code (for general errors)
- `message` (string): Human-readable error description (for general errors)
- `id` (string): The ID that was not found (for not found errors)

---

## 1. Memory Operations

### 1.1 Observe (Store a Memory)
**Endpoint**: `POST /api/v1/observe`
**Purpose**: Record an observation and intake content for knowledge processing. This is the primary way to store a memory in v1.5.x. By default it creates an L0 observation; pass `level` to store at a higher level.

**Request Body**:
```json
{
  "content": "Memory content to store",
  "level": "observation",
  "importance": 8,
  "tags": ["tag1", "tag2"],
  "domain": "knowledge-domain",
  "source": "source-identifier"
}
```

**Parameters**:
- `content` (string, required): The observation content
- `level` (string, optional): `observation`, `learning`, `pattern`, or `schema` (default: `observation`)
- `weight` (number, optional): Initial weight 0.0–10.0
- `tags` (array of strings, optional): Tags for categorization
- `domain` (string, optional): Knowledge domain
- `source` (string, optional): Source identifier
- `session_id` (string, optional): Session identifier
- `auto_promote` (boolean, optional): Automatically promote when criteria are met (default: false)

**Response** (raw JSON, HTTP 201 on create): the new id is returned at the top level as **`memory_id`**, alongside `level`, `level_label`, `suggested_actions`, and `summary`.
```json
{
  "success": true,
  "memory_id": "cabfad74-70e2-43e6-b635-c3c6ff7ef614",
  "level": "L0",
  "level_label": "observation (L0)",
  "domain": "backend",
  "importance": 2,
  "knowledge_type": "observation",
  "summary": "Stored '...' as observation (L0). Importance: 2/10.",
  "suggested_actions": ["Use 'reflect' to consolidate ...", "..."]
}
```

**Example**:
```bash
curl -X POST http://localhost:3002/api/v1/observe \
  -H "Content-Type: application/json" \
  -d '{"content": "REST API documentation example", "importance": 7, "tags": ["api", "documentation"]}'
```

> **Deprecated**: `POST /api/v1/memories` still works but is deprecated in favor of `POST /api/v1/observe`. It accepts `content`, `importance`, `tags`, `domain`, `source` and returns the wrapped `{success, message, data}` envelope.

### 1.2 List Memories
**Endpoint**: `GET /api/v1/memories`
**Purpose**: Retrieve memories with optional filtering and pagination

**Query Parameters**:
- `limit` (integer, optional): Number of results (default: 20)
- `session_filter_mode` (string, optional): "all", "session_only", "session_and_shared" (default: "all")
- `truncate_content` (boolean, optional): Enable content truncation (default: false)
- `max_content_chars` (integer, optional): Max characters when truncating (default: 500)
- `include_embeddings` (boolean, optional): Include vector embeddings (default: false)

**Example**:
```bash
curl "http://localhost:3002/api/v1/memories?limit=10&truncate_content=true"
```

### 1.3 Search Memories
**Endpoint**: `GET /api/v1/memories/search`
**Purpose**: Search memories using semantic similarity and keywords

**Query Parameters**:
- `query` (string, required): Search query
- `use_ai` (boolean, optional): Enable AI-powered semantic search (default: false)
- `limit` (integer, optional): Number of results (default: 10)
- `session_filter_mode` (string, optional): Session filtering mode (default: "all")
- `response_format` (string, optional): "detailed", "concise", "ids_only", "summary", "custom"

**Note**: Always explicitly set the `response_format` parameter to avoid potential errors with default format handling.

**Response**: Returns `{ "count": N, "data": [...] }` at the top level (no `message` field), plus format/optimization metadata.

**Example**:
```bash
curl "http://localhost:3002/api/v1/memories/search?query=neural%20networks&use_ai=true&response_format=detailed"
```

### 1.4 Enhanced Search with Pagination
**Endpoint**: `POST /api/v1/memories/search`
**Purpose**: Advanced search with cursor-based pagination for large datasets

**Request Body**:
```json
{
  "query": "search query",
  "limit": 20,
  "min_importance": 5,
  "min_similarity": 0.5,
  "cursor": "base64-encoded-cursor",
  "response_format": "concise"
}
```

### 1.5 Intelligent Search
**Endpoint**: `POST /api/v1/memories/search/intelligent`
**Purpose**: AI-powered search with automatic response-format optimization

**Request Body**:
```json
{
  "query": "search query",
  "limit": 20,
  "min_importance": 5,
  "response_format": "concise",
  "response_template": "agent_minimal"
}
```

### 1.6 Get Memory by ID
**Endpoint**: `GET /api/v1/memories/{id}`
**Purpose**: Retrieve a specific memory by its UUID

**Path Parameters**:
- `id` (string, required): Memory UUID

**Query Parameters**:
- `include_embeddings` (boolean, optional): Include vector embeddings (default: false)

**Example**:
```bash
curl "http://localhost:3002/api/v1/memories/550e8400-e29b-41d4-a716-446655440000"
```

### 1.7 Update Memory
**Endpoint**: `PUT /api/v1/memories/{id}`
**Purpose**: Update an existing memory's content or metadata

**Request Body**:
```json
{
  "content": "Updated memory content",
  "importance": 9,
  "tags": ["updated", "tag"]
}
```

### 1.8 Delete Memory
**Endpoint**: `DELETE /api/v1/memories/{id}`
**Purpose**: Permanently delete a memory

Returns the full wrapped envelope (`{success, message, data}`) with `data.status: "deleted"`, and returns **404** with `{"error":"not_found","id":"..."}` for an unknown id.

**Example**:
```bash
curl -X DELETE "http://localhost:3002/api/v1/memories/550e8400-e29b-41d4-a716-446655440000"
```

### 1.9 Get Related Memories
**Endpoint**: `GET /api/v1/memories/{id}/related`
**Purpose**: Find memories related to a specific memory through relationships

**Query Parameters**:
- `limit` (integer, optional): Number of results (default: 10)
- `max_depth` (integer, optional): Relationship depth (default: 2)
- `min_similarity` (number, optional): Minimum similarity 0.0-1.0 (default: 0.5)
- `include_indirect` (boolean, optional): Include indirect relationships (default: false)
- `relationship_types` (string, optional): Comma-separated relationship types to include

### 1.10 Map Memory Graph
**Endpoint**: `GET /api/v1/memories/{id}/graph`
**Purpose**: Generate a graph visualization of memory relationships

**Path Parameters**:
- `id` (string, required): Central memory UUID

**Query Parameters**:
- `depth` (integer, optional): Maximum relationship depth (default: 2)

### 1.11 Get Memory Statistics
**Endpoint**: `GET /api/v1/memories/stats`
**Purpose**: Get detailed statistics about stored memories

**Query Parameters**:
- `session_id` (string, optional): Session to get stats for

**Example**:
```bash
curl "http://localhost:3002/api/v1/memories/stats"
```

---

## 2. Knowledge Engineering

These endpoints implement the knowledge-maturation lifecycle: capture observations, synthesize them into learnings and patterns, connect them, and reason over them. They return **raw JSON** (see [Response Format](#response-format)) — trust the HTTP status code.

### 2.1 Reflect (Promote Observations)
**Endpoint**: `POST /api/v1/reflect`
**Purpose**: Process observations into learnings (L0 → L1 promotion)

**Request Body**:
```json
{
  "mode": "single",
  "observation_id": "uuid",
  "batch_size": 10
}
```

**Parameters**:
- `mode` (string, optional): `single`, `batch`, or `auto` (default: `single`)
- `observation_id` (string, required for single mode): Observation UUID to reflect on
- `batch_size` (integer, optional): Observations to process in batch mode (default: 10, max: 50)
- `auto_criteria` (string, optional): Criteria for auto mode selection
- `session_id` (string, optional)

### 2.2 Relate (Create a Relationship)
**Endpoint**: `POST /api/v1/relate`
**Purpose**: Create a relationship between two memories

**Request Body**:
```json
{
  "source_memory_id": "uuid1",
  "target_memory_id": "uuid2",
  "relationship_type": "causes",
  "strength": 0.9,
  "context": "Optional explanation of the relationship"
}
```

**Relationship Types**: `references`, `contradicts`, `expands`, `similar`, `sequential`, `causes`, `enables` (default: `references`). `strength` is 0.0–1.0 (default: 0.5).

### 2.3 Predict
**Endpoint**: `POST /api/v1/predict`
**Purpose**: Generate predictions from stored patterns and schemas

**Request Body**:
```json
{
  "given": "high traffic",
  "action": "scale horizontally",
  "domain": "backend",
  "limit": 5,
  "use_ai": true
}
```
`given` is required. `limit` default 5 (max 20).

### 2.4 Explain
**Endpoint**: `POST /api/v1/explain`
**Purpose**: Trace causal paths between two states

**Request Body**:
```json
{
  "from_state": "login",
  "to_state": "purchase",
  "max_depth": 4,
  "domain": "backend",
  "use_ai": true
}
```
`from_state` and `to_state` are required. `max_depth` default 4 (max 10).

### 2.5 Counterfactual
**Endpoint**: `POST /api/v1/counterfactual`
**Purpose**: Perform "what if" reasoning to explore alternative scenarios

**Request Body**:
```json
{
  "observed": "deploy failed",
  "if_condition": "ran tests first",
  "domain": "backend",
  "use_ai": true
}
```
`observed` and `if_condition` are required.

### 2.6 Question (Record a Knowledge Gap)
**Endpoint**: `POST /api/v1/question`
**Purpose**: Record epistemic gaps, contradictions, and open questions

**Request Body**:
```json
{
  "content": "How does X persist under load?",
  "question_type": "epistemic_gap",
  "priority": 7,
  "domain": "backend",
  "origin_context": "observed during load test",
  "response_format": "concise"
}
```

**Parameters**:
- `content` (string, required)
- `question_type` (string, optional): `epistemic_gap`, `contradiction`, `prediction_failure` (default: `epistemic_gap`)
- `priority` (integer, optional): 1–10 (default: 5)
- `domain`, `origin_context`, `session_id` (optional)
- `response_format` (string, optional): `detailed`, `concise`, `ids_only` (default: `concise`)

### 2.7 List Questions
**Endpoint**: `GET /api/v1/questions`
**Purpose**: List recorded questions, optionally filtered by status

**Query Parameters**:
- `status` (string, optional): e.g. `pending`

**Response**: `{ "count": N, "has_more": bool, "items": [...] }`

**Example**:
```bash
curl "http://localhost:3002/api/v1/questions?status=pending"
```

### 2.8 Resolve (Answer a Question)
**Endpoint**: `POST /api/v1/resolve`
**Purpose**: Resolve contradictions and answer epistemic gaps

**Request Body**:
```json
{
  "question_id": "uuid",
  "resolution_type": "answered",
  "rationale": "Explanation for the resolution",
  "create_synthesis": false,
  "synthesis_content": "...",
  "update_weights": true
}
```

**Parameters**:
- `question_id` (string, required)
- `resolution_type` (string, required): `a_supersedes`, `b_supersedes`, `conditional`, `merged`, `context`, `invalidated`, `answered`
- `rationale` (string, required)
- `create_synthesis`, `synthesis_content`, `update_weights`, `session_id` (optional)

### 2.9 Evolve
**Endpoint**: `POST /api/v1/evolve`
**Purpose**: Run evolution processes on knowledge: validate, promote, decay, accommodate

**Request Body**:
```json
{
  "operation": "validate",
  "entity_id": "uuid",
  "success": true,
  "dry_run": false,
  "threshold_days": 30
}
```

**Parameters**:
- `operation` (string, required): `validate`, `promote`, `decay`, `accommodate`
- `entity_id` (string, required for validate/promote)
- `success` (boolean, required for validate)
- `threshold_days` (integer, optional, default: 30 — for decay)
- `dry_run`, `context`, `session_id` (optional)

### 2.10 Validate (Graph Integrity)
**Endpoint**: `POST /api/v1/validate`
**Purpose**: Validate knowledge-graph integrity and optionally repair issues

**Request Body**:
```json
{
  "checks": ["orphaned_reference", "relationship_cycle"],
  "dry_run": true,
  "auto_fix": false,
  "batch_size": 1000,
  "domain": "backend",
  "response_format": "detailed"
}
```

**Parameters**:
- `checks` (array, optional): `orphaned_reference`, `relationship_cycle`, `weight_inconsistency`, `stale_question`, `promotion_chain_broken`, `duplicate_relationship` (default: all)
- `dry_run` (boolean, optional, default: true)
- `auto_fix` (boolean, optional, default: false)
- `batch_size` (integer, optional, default: 1000, max: 10000)
- `domain`, `session_id` (optional)
- `response_format` (string, optional, default: `detailed`)

---

## 3. AI Analysis Operations

### 3.1 Ask Question
**Endpoint**: `POST /api/v1/ask`
**Purpose**: AI-powered question answering using stored memories as context

**Request Body**:
```json
{
  "question": "What are the key concepts in machine learning?",
  "session_id": "optional-session"
}
```

**Example**:
```bash
curl -X POST http://localhost:3002/api/v1/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What is Redis?"}'
```

### 3.2 Summarize Memories
**Endpoint**: `POST /api/v1/summarize`
**Purpose**: Generate AI-powered summaries of stored memories over a timeframe

**Request Body**:
```json
{
  "timeframe": "7d",
  "limit": 20,
  "session_id": "optional-session"
}
```
`timeframe`: `all`, `24h`, `7d`.

> **Deprecated**: `POST /api/v1/analyze` (pattern/insight/trend/connection analysis) is deprecated in favor of the knowledge-engineering reasoning endpoints `POST /api/v1/predict`, `POST /api/v1/explain`, and `POST /api/v1/counterfactual`.

---

## 4. Relationship Operations

Relationships are created with `POST /api/v1/relate` (see [2.2](#22-relate-create-a-relationship)). The following remain available:

### 4.1 Get Related Memories / Map Graph
See [1.9 Get Related Memories](#19-get-related-memories) (`GET /api/v1/memories/{id}/related`) and [1.10 Map Memory Graph](#110-map-memory-graph) (`GET /api/v1/memories/{id}/graph`).

> **Deprecated**: `POST /api/v1/relationships` (create) and `POST /api/v1/relationships/discover` (AI discovery) are deprecated in favor of `POST /api/v1/relate`. They still function and continue to accept their original request bodies.

---

## 5. Temporal Analysis Operations

### 5.1 Analyze Temporal Patterns
**Endpoint**: `POST /api/v1/temporal/patterns`
**Purpose**: Analyze learning patterns and progression over time

**Request Body**:
```json
{
  "analysis_type": "learning_progression",
  "concept": "machine learning",
  "timeframe": "month"
}
```
`analysis_type` (required): `learning_progression`, `knowledge_gaps`, `concept_evolution`. `timeframe` (required): `week`, `month`, `quarter`, `year`.

### 5.2 Track Learning Progression
**Endpoint**: `POST /api/v1/temporal/progression`
**Purpose**: Track learning progression for a specific concept

**Request Body**:
```json
{
  "concept": "neural networks",
  "include_suggestions": true
}
```

### 5.3 Detect Knowledge Gaps
**Endpoint**: `POST /api/v1/temporal/gaps`
**Purpose**: Identify knowledge gaps and learning priorities

**Request Body**:
```json
{
  "focus_areas": ["machine learning", "deep learning"]
}
```

### 5.4 Generate Timeline
**Endpoint**: `POST /api/v1/temporal/timeline`
**Purpose**: Create timeline visualization of learning milestones

**Request Body**:
```json
{
  "concept": "machine learning",
  "memory_ids": ["uuid1", "uuid2"],
  "start_date": "2025-01-01",
  "end_date": "2025-12-31"
}
```

---

## 6. Advanced Search Operations

### 6.1 Search by Tags
**Endpoint**: `POST /api/v1/search/tags`
**Purpose**: Search memories by tags with boolean operators

**Request Body**:
```json
{
  "tags": ["machine learning", "python"],
  "operator": "AND",
  "domain": "programming",
  "limit": 10
}
```
`tags` (required). `operator`: `AND`, `OR` (default: `AND`).

### 6.2 Search by Date Range
**Endpoint**: `POST /api/v1/search/date-range`
**Purpose**: Search memories within a specific date range

**Request Body**:
```json
{
  "start_date": "2025-01-01",
  "end_date": "2025-12-31",
  "domain": "programming",
  "limit": 20
}
```
Dates are ISO 8601.

---

## 7. System & Management Operations

### 7.1 Health Check
**Endpoint**: `GET /api/v1/health`
**Purpose**: Check API health and system status

**Response**:
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "session": "daemon-session-id",
    "timestamp": "2026-07-05T23:34:27Z"
  },
  "message": "Server is healthy"
}
```

### 7.2 System Status
**Endpoint**: `GET /api/v1/status`
**Purpose**: Get unified system status and statistics (memory counts, level distribution, domains, categories, relationships, pending questions, contradictions, epistemic gaps, and suggested actions)

**Example**:
```bash
curl "http://localhost:3002/api/v1/status"
```

### 7.3 Bootstrap Session
**Endpoint**: `POST /api/v1/bootstrap`
**Purpose**: Initialize a session with knowledge context — highlights, recent learnings, detected patterns, memory stats, and pending questions. Ideal as the first call in a new agent session.

**Request Body**:
```json
{
  "mode": "full",
  "include_learnings": true,
  "include_patterns": true,
  "include_questions": true,
  "domain": "backend",
  "limit": 20
}
```

**Parameters**:
- `mode` (string, optional): `full`, `minimal`, `domain` (default: `full`)
- `domain` (string, required when `mode=domain`)
- `include_learnings`, `include_patterns`, `include_questions` (boolean, optional, default: true)
- `limit` (integer, optional, default: 20, max: 100)
- `session_id` (string, optional)

**Response**: raw JSON with `highlights`, `memory_stats`, `patterns`, `recent_learnings`, `pending_questions`, `suggested_actions`, `summary`, `session_id`, and `mode`. Note this endpoint **does not** include a `success` field — trust the HTTP status.

### 7.4 Evolution Stats
**Endpoint**: `GET /api/v1/evolution/stats`
**Purpose**: Get knowledge-evolution statistics (promotions, decay, validations)

### 7.5 Migrate Domain
**Endpoint**: `POST /api/v1/domains/migrate`
**Purpose**: Migrate memories from one domain to another

**Request Body**:
```json
{
  "from_domain": "old-domain",
  "to_domain": "new-domain",
  "dry_run": true
}
```
`from_domain` and `to_domain` are required. `dry_run` defaults to true — preview before applying.

### 7.6 Configuration
- `GET /api/v1/config` — get full server configuration
- `GET /api/v1/config/sections` — list configuration sections
- `GET /api/v1/config/{section}` — get a specific section
- `PUT /api/v1/config/{section}` — update a section
- `POST /api/v1/config/validate` — validate a configuration payload without applying it

Configuration endpoints require authentication when security is enabled.

### 7.7 Deprecated System Endpoints
The following still respond but are deprecated:
- `GET /api/v1/stats` → use `GET /api/v1/status`
- `GET /api/v1/sessions` → use `POST /api/v1/bootstrap`
- `GET /api/v1/domains`, `POST /api/v1/domains`, `GET /api/v1/domains/{domain}/stats` → use the `domain` parameter on `observe`/`search`
- `POST /api/v1/categories`, `GET /api/v1/categories`, `GET /api/v1/categories/stats`, `POST /api/v1/memories/{id}/categorize` → use the `tags` parameter on `observe`/`search`

---

## Response Formats & Token Optimization

Local Memory provides multiple response formats to optimize token usage. Add `response_format` to any read:

### Response Format Options
- **`detailed`**: Full response with all fields
- **`concise`**: Essential fields only (~70% token reduction)
- **`summary`**: Truncated content (~50% token reduction)
- **`ids_only`**: Minimal response with IDs (~95% token reduction)
- **`custom`**: Custom field selection for fine control

### Response Templates
Predefined templates for common use cases:
- **`agent_minimal`**: Ultra-minimal for AI agents (~99% reduction)
- **`analysis_ready`**: Optimized for AI analysis
- **`relationship_focused`**: Graph operations focus
- **`temporal_analysis`**: Time-series analysis
- **`metadata_only`**: No content fields
- **`full_context`**: Maximum information

### Example with Format Optimization
```bash
# Concise format for reduced tokens
curl -X POST http://localhost:3002/api/v1/memories/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "machine learning",
    "response_format": "concise",
    "limit": 10
  }'

# IDs only for minimal response
curl -X POST http://localhost:3002/api/v1/memories/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "machine learning",
    "response_format": "ids_only"
  }'
```

## Pagination

The API supports cursor-based pagination for efficient handling of large datasets:

```json
{
  "limit": 20,
  "cursor": "eyJvZmZzZXQiOjEwfQ==",
  "response": {
    "results": [...],
    "cursor": "eyJvZmZzZXQiOjMwfQ==",
    "has_more": true,
    "total_count": 150
  }
}
```

To paginate through results:
1. Make initial request without cursor
2. Use returned cursor for next page
3. Continue until `has_more` is false

## Cross-Interface Consistency

All operations are available across CLI, MCP, and REST API with consistent behavior:

```bash
# REST API
curl -X POST http://localhost:3002/api/v1/observe \
  -H "Content-Type: application/json" \
  -d '{"content": "Example memory", "importance": 7}'

# CLI Equivalent
local-memory observe "Example memory" --importance 7

# MCP Equivalent
observe(content="Example memory", importance=7)
```

## Best Practices

1. **Use appropriate response formats**: Choose `concise` or `ids_only` formats when working with large datasets
2. **Enable AI search selectively**: Use `use_ai=true` only when semantic search is needed
3. **Implement pagination**: Use cursor-based pagination for large result sets
4. **Set reasonable limits**: Keep `limit` parameter reasonable (10-50) for optimal performance
5. **Filter by session**: Use `session_filter_mode` to scope searches appropriately
6. **Bootstrap first**: Call `POST /api/v1/bootstrap` at the start of a session to load relevant context
7. **Cache health checks**: Health check responses can be cached for monitoring systems

## Error Handling

The API returns appropriate HTTP status codes:
- **200 OK**: Successful operation
- **201 Created**: Resource created successfully (e.g. `POST /observe`)
- **400 Bad Request**: Invalid request parameters
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server-side error

For CRUD/admin endpoints, check the `success` field in responses. For knowledge-engineering endpoints, **trust the HTTP status code** — some omit `success`. Handle errors appropriately in your client code.
