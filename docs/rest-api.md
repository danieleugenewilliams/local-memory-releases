# REST API Reference

Local Memory provides a comprehensive REST API accessible at `http://localhost:3002/api/v1`. The API supports JSON request/response formats and provides full CRUD operations for memories, AI-powered analysis, relationship management, categorization, temporal analysis, and system management.

## Base URL
```
http://localhost:3002/api/v1
```

## Authentication
Currently, no authentication is required for local development. All endpoints are accessible without credentials.

## Response Format
All responses follow a consistent JSON structure:
```json
{
  "success": true|false,
  "message": "Human-readable message",
  "data": { ... } // Response data
}
```

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

### 1.1 Store Memory
**Endpoint**: `POST /api/v1/memories`
**Purpose**: Create a new memory with content, tags, and metadata

**Request Body**:
```json
{
  "content": "Memory content to store",
  "importance": 8,
  "tags": ["tag1", "tag2"],
  "domain": "knowledge-domain",
  "source": "source-identifier"
}
```

**Parameters**:
- `content` (string, required): The memory content to store
- `importance` (integer, optional): Importance level 1-10 (default: 5)
- `tags` (array of strings, optional): Tags for categorization
- `domain` (string, optional): Knowledge domain
- `source` (string, optional): Source identifier

**Example**:
```bash
curl -X POST http://localhost:3002/api/v1/memories \
  -H "Content-Type: application/json" \
  -d '{"content": "REST API documentation example", "importance": 7, "tags": ["api", "documentation"]}'
```

### 1.2 List Memories
**Endpoint**: `GET /api/v1/memories`
**Purpose**: Retrieve memories with optional filtering and pagination

**Query Parameters**:
- `limit` (integer, optional): Number of results (default: 20, max: 100)
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
- `response_format` (string, optional): "detailed", "concise", "ids_only", "summary", "custom"

**Note**: Always explicitly set the `response_format` parameter to avoid potential errors with default format handling.

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
  "use_ai": false,
  "limit": 20,
  "cursor": "base64-encoded-cursor",
  "response_format": "concise"
}
```

### 1.5 Get Memory by ID
**Endpoint**: `GET /api/v1/memories/{id}`
**Purpose**: Retrieve a specific memory by its UUID

**Path Parameters**:
- `id` (string, required): Memory UUID

**Example**:
```bash
curl "http://localhost:3002/api/v1/memories/550e8400-e29b-41d4-a716-446655440000"
```

### 1.6 Update Memory
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

### 1.7 Delete Memory
**Endpoint**: `DELETE /api/v1/memories/{id}`
**Purpose**: Permanently delete a memory

**Example**:
```bash
curl -X DELETE "http://localhost:3002/api/v1/memories/550e8400-e29b-41d4-a716-446655440000"
```

### 1.8 Get Related Memories
**Endpoint**: `GET /api/v1/memories/{id}/related`
**Purpose**: Find memories related to a specific memory through relationships

**Query Parameters**:
- `limit` (integer, optional): Number of results (default: 10)
- `max_depth` (integer, optional): Relationship depth (default: 2)
- `min_similarity` (number, optional): Minimum similarity 0.0-1.0 (default: 0.5)

### 1.9 Get Memory Statistics
**Endpoint**: `GET /api/v1/memories/stats`
**Purpose**: Get detailed statistics about stored memories

**Example**:
```bash
curl "http://localhost:3002/api/v1/memories/stats"
```

---

## 2. AI Analysis Operations

### 2.1 Analyze Memories
**Endpoint**: `POST /api/v1/analyze`
**Purpose**: AI-powered analysis of memories with question answering, summarization, and pattern analysis

**Smart Endpoint Routing**: The system automatically routes analysis requests to optimized endpoints based on `analysis_type`:
- `summarize` → routed to `/api/v1/summarize`
- `temporal_patterns` → routed to `/api/v1/temporal/patterns`
- `question`, `analyze` → handled by `/api/v1/analyze`

**Request Body**:
```json
{
  "analysis_type": "question",
  "question": "What are the key differences between supervised and unsupervised learning?",
  "response_format": "concise",
  "limit": 10
}
```

**Parameters**:
- `analysis_type` (string, optional): "question", "summarize", "analyze", "temporal_patterns" (default: "question")
- `question` (string, required for question type): Natural language question
- `query` (string, optional): Filter memories before analysis
- `timeframe` (string, optional): Time period - "today", "week", "month", "all" (default: "all")
- `response_format` (string, optional): Response format optimization
- `limit` (integer, optional): Maximum memories to analyze (default: 10)

**Example**:
```bash
curl -X POST http://localhost:3002/api/v1/analyze \
  -H "Content-Type: application/json" \
  -d '{"analysis_type": "question", "question": "What is Redis?", "response_format": "concise"}'
```

### 2.2 Ask Question
**Endpoint**: `POST /api/v1/ask`
**Purpose**: AI-powered question answering using stored memories as context

**Request Body**:
```json
{
  "question": "What are the key concepts in machine learning?",
  "limit": 10,
  "use_ai": true
}
```

### 2.3 Summarize Memories
**Endpoint**: `POST /api/v1/summarize`
**Purpose**: Generate AI-powered summaries of stored memories

**Request Body**:
```json
{
  "query": "machine learning",
  "limit": 10,
  "timeframe": "month"
}
```

---

## 3. Relationship Operations

### 3.1 Discover Relationships
**Endpoint**: `POST /api/v1/relationships/discover`
**Purpose**: AI-powered discovery of relationships between memories

**Request Body**:
```json
{
  "memory_id": "optional-central-memory-id",
  "limit": 10,
  "min_strength": 0.6,
  "relationship_types": ["expands", "references"]
}
```

### 3.2 Create Relationship
**Endpoint**: `POST /api/v1/relationships`
**Purpose**: Create an explicit relationship between two memories

**Request Body**:
```json
{
  "source_memory_id": "uuid1",
  "target_memory_id": "uuid2",
  "relationship_type": "expands",
  "strength": 0.8,
  "context": "Optional explanation of the relationship"
}
```

**Relationship Types**:
- `references`: Direct reference or citation
- `contradicts`: Conflicting information
- `expands`: Builds upon or extends
- `similar`: Related concepts
- `sequential`: Temporal or logical sequence
- `causes`: Causal relationship
- `enables`: Prerequisite or dependency

### 3.3 Map Memory Graph
**Endpoint**: `GET /api/v1/memories/{id}/graph`
**Purpose**: Generate a graph visualization of memory relationships

**Path Parameters**:
- `id` (string, required): Central memory UUID

**Query Parameters**:
- `depth` (integer, optional): Maximum relationship depth (default: 2)

---

## 4. Category Operations

### 4.1 Create Category
**Endpoint**: `POST /api/v1/categories`
**Purpose**: Create a new category for organizing memories

**Request Body**:
```json
{
  "name": "Machine Learning",
  "description": "Concepts and techniques in machine learning",
  "parent_category_id": "optional-parent-uuid",
  "confidence_threshold": 0.8
}
```

### 4.2 List Categories
**Endpoint**: `GET /api/v1/categories`
**Purpose**: Retrieve all available categories

**Query Parameters**:
- `parent_category_id` (string, optional): Filter by parent category
- `include_subcategories` (boolean, optional): Include subcategories (default: true)

### 4.3 Categorize Memory
**Endpoint**: `POST /api/v1/memories/{id}/categorize`
**Purpose**: AI-powered categorization of a specific memory

**Request Body**:
```json
{
  "suggested_categories": ["Machine Learning", "AI"],
  "create_new_categories": true
}
```

### 4.4 Get Category Stats
**Endpoint**: `GET /api/v1/categories/stats`
**Purpose**: Get statistics about category usage

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

### 5.2 Track Learning Progression
**Endpoint**: `POST /api/v1/temporal/progression`
**Purpose**: Track learning progression for specific concepts

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

### 6.2 Search by Date Range
**Endpoint**: `POST /api/v1/search/date-range`
**Purpose**: Search memories within a specific date range

**Request Body**:
```json
{
  "start_date": "2025-01-01",
  "end_date": "2025-12-31",
  "tags": ["machine learning"],
  "limit": 20
}
```

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
    "timestamp": "2025-11-12T12:59:36Z"
  },
  "message": "Server is healthy"
}
```

### 7.2 List Sessions
**Endpoint**: `GET /api/v1/sessions`
**Purpose**: Get all available session identifiers

### 7.3 Get System Stats
**Endpoint**: `GET /api/v1/stats`
**Purpose**: Get system-wide statistics and metrics

### 7.4 Create Domain
**Endpoint**: `POST /api/v1/domains`
**Purpose**: Create a new knowledge domain

**Request Body**:
```json
{
  "name": "artificial-intelligence",
  "description": "AI research, algorithms, and applications"
}
```

### 7.5 Get Domain Stats
**Endpoint**: `GET /api/v1/domains/{domain}/stats`
**Purpose**: Get statistics for a specific domain

---

## Response Formats & Token Optimization

Local Memory provides multiple response formats to optimize token usage:

### Response Format Options
- **`detailed`**: Full response with all fields
- **`concise`**: Essential fields only (~70% token reduction)
- **`ids_only`**: Minimal response with IDs (~95% token reduction)
- **`summary`**: Truncated content (~50% token reduction)
- **`custom`**: Custom field selection for fine control

### Response Templates
Predefined templates for common use cases:
- **`agent_minimal`**: Ultra-minimal for AI agents (~99% reduction)
- **`analysis_ready`**: Optimized for AI analysis
- **`relationship_focused`**: Graph operations focus
- **`temporal_analysis`**: Time-series analysis
- **`content_preview`**: Balanced preview
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
curl -X POST http://localhost:3002/api/v1/memories \
  -d '{"content": "Example memory", "importance": 7}'

# CLI Equivalent
local-memory remember "Example memory" --importance 7

# MCP Equivalent
store_memory(content="Example memory", importance=7)
```

## Best Practices

1. **Use appropriate response formats**: Choose `concise` or `ids_only` formats when working with large datasets
2. **Enable AI search selectively**: Use `use_ai=true` only when semantic search is needed
3. **Implement pagination**: Use cursor-based pagination for large result sets
4. **Set reasonable limits**: Keep `limit` parameter reasonable (10-50) for optimal performance
5. **Filter by session**: Use `session_filter_mode` to scope searches appropriately
6. **Cache health checks**: Health check responses can be cached for monitoring systems

## Error Handling

The API returns appropriate HTTP status codes:
- **200 OK**: Successful operation
- **201 Created**: Resource created successfully
- **400 Bad Request**: Invalid request parameters
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server-side error

Always check the `success` field in responses and handle errors appropriately in your client code.