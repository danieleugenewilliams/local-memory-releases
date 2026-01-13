# Local Memory (localmemory.co)

**Version 1.3.0** - AI-powered persistent memory system for developers working with Claude Code, Claude Desktop, Gemini, Codex, Cursor, and other coding agents.

Transform your AI interactions with intelligent memory that grows smarter over time. Build persistent knowledge bases, track learning progression, and maintain context across conversations. Local Memory provides MCP, REST API, and Command-line interfaces for you and your coding agents to store, retrieve, discover, and analyze memories to give your agent the right context for it's work and tasks.

## Key Features

- **One-Command Install**: `npm install -g local-memory-mcp`
- **Smart Memory**: AI-powered categorization and relationship discovery
- **Lightning Fast**: 10-57ms search responses with semantic similarity
- **MCP Integration**: Works seamlessly with Claude Desktop and other AI tools
- **REST API**: Easily integrate into your applications and workflows
- **Command-Line Interface**: Enable script automation and code execution via shell scripts and commands
- **Persistent Context**: Never lose conversation context again
- **Enterprise Ready**: Commercial licensing with security hardening

## Quick Start

### Installation
```bash
npm install -g local-memory-mcp
```

### License Activation
```bash
# Get your license key from https://localmemory.co
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX

# Verify activation
local-memory license status
```

### Start the Service
```bash
# Start the daemon
local-memory start

# Verify it's running
local-memory status
```

## CLI Usage

### Basic Memory Operations
```bash
# Store memories with automatic AI categorization
local-memory remember "Go channels are like pipes between goroutines"
local-memory remember "Redis is excellent for caching" --importance 8 --tags caching,database

# Search memories (keyword and AI-powered semantic search)
local-memory search "concurrency patterns"
local-memory search "neural networks" --use_ai --limit 5

# Create relationships between concepts
local-memory relate "channels" to "goroutines" --type enables

# Delete memories
local-memory forget <memory-id>
```

### Advanced Search
```bash
# Tag-based search
local-memory search --tags python,programming

# Date range search
local-memory search --start_date 2025-01-01 --end_date 2025-12-31

# Domain filtering
local-memory search "machine learning" --domain ai-research

# Session filtering (cross-conversation access)
local-memory search "recent work" --session_filter_mode all
```

## MCP Integration

### Claude Desktop Setup

Add to your Claude Desktop configuration file:

```json
{
  "mcpServers": {
    "local-memory": {
      "command": "/path/to/local-memory",
      "args": [
        "--mcp"
      ],
      "transport": "stdio"
    }
  }
}
```

### Available MCP Tools

When configured, Claude will have access to these memory tools:

**Core Tools:**
- `observe` - Record observations with knowledge level support (L0-L3)
- `search` - Find memories with semantic search
- `bootstrap` - Initialize sessions with knowledge context

**Knowledge Evolution:**
- `reflect` - Process observations into learnings
- `evolve` - Validate, promote, or decay knowledge
- `question` - Track epistemic gaps and contradictions
- `resolve` - Resolve contradictions and answer questions

**Reasoning Tools:**
- `predict` - Generate predictions from patterns
- `explain` - Trace causal paths between states
- `counterfactual` - Explore "what if" scenarios
- `validate` - Check knowledge graph integrity

**Relationship Tools:**
- `relate` - Create relationships between memories
- Plus memory management tools (update, delete, get)

## REST API

When the daemon is running, REST API is available at `http://localhost:3002`:

```bash
# Search memories
curl "http://localhost:3002/api/memories/search?query=python&limit=5"

# Store new memory
curl -X POST "http://localhost:3002/api/memories" \
  -H "Content-Type: application/json" \
  -d '{"content": "Python dict comprehensions are powerful", "importance": 7}'

# Health check
curl "http://localhost:3002/api/v1/health"
```

## Service Management

```bash
# Start daemon
local-memory start

# Check daemon status
local-memory status

# Stop daemon
local-memory stop

# View running processes
local-memory ps

# Kill all processes (if needed)
local-memory kill_all

# System diagnostics
local-memory doctor
```

## What's New in v1.3.0

- **World Memory Knowledge Hierarchy** - Four-level knowledge progression system
  - L0 Observations: Raw intake, ephemeral
  - L1 Learnings: Candidate insights, volatile
  - L2 Patterns: Validated generalizations, durable
  - L3 Schemas: Theoretical frameworks, permanent
- **Contradiction Detection** - Automatic conflict identification using 5-layer heuristics
- **Epistemic Gap Tracking** - Track unknown unknowns through dedicated questions system
- **Knowledge Evolution** - Validation, promotion, and decay mechanisms
- **10 New MCP Tools** - observe, reflect, question, resolve, evolve, bootstrap, predict, explain, counterfactual, validate

## System Requirements

- **RAM**: 512MB minimum
- **Storage**: 100MB for binaries, variable for database
- **Platforms**: macOS (Intel/ARM64), Linux x64, Windows x64

## Licensing

### Commercial License Required
Local Memory requires a commercial license for all use cases. Get your license at [localmemory.co](https://localmemory.co).

### Activation
```bash
# Activate license
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX

# Check status
local-memory license status
```

## Support

- **Documentation**: [localmemory.co/docs](https://localmemory.co/docs)
- **Architecture**: [localmemory.co/architecture](https://localmemory.co/architecture)
- **Prompts**: [localmemory.co/prompts](https://localmemory.co/prompts)
- **Support**: [Local Memory Discord](https://discord.gg/rMmn8xP3fZ)
- **Releases Repo**: [Local Memory Releases](https://github.com/danieleugenewilliams/local-memory-releases)

---

**Transform your AI workflow with persistent memory. Install now and never lose context again.**

```bash
npm install -g local-memory-mcp
```