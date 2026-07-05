# Getting Started with Local Memory

Local Memory is a powerful, local-first AI memory system that lets you store, search, and reason over information using semantic understanding. This guide will help you get started with Local Memory **v1.5.1** quickly.

## What is Local Memory?

Local Memory provides three complementary interfaces for intelligent information storage and retrieval:

- **CLI (Command-line Interface)**: Direct human interaction and scripting
- **MCP (Model Context Protocol)**: Integration with AI agents and Claude
- **REST API**: Web service integration and automation

All three interfaces provide the same functionality with consistent behavior and responses.

### The knowledge model in one minute

Local Memory isn't a flat note store. Knowledge enters as a raw **observation** and matures toward durable understanding through a simple loop:

| Level | Name | Meaning |
|-------|------|---------|
| L0 | Observation | Raw intake, captured as you learn |
| L1 | Learning | A candidate insight synthesized from observations |
| L2 | Pattern | A generalization validated across many learnings |
| L3 | Schema | A durable framework that explains patterns |

The core loop is **observe → reflect → evolve**: you `observe` what you learn, periodically `reflect` to turn observations into learnings, and `evolve` to validate and promote knowledge as it proves out. You don't have to think about the levels to get value — just `observe` and `search` — but they're what lets Local Memory accumulate expertise instead of re-deriving it every session. See the [Configuration](configuration.md) docs and the bundled agent skill for the full model.

## Installation

### Quick Setup

```bash
# Install the CLI + MCP server
npm install -g local-memory-mcp

# Run the setup wizard (or --silent / --interactive)
local-memory setup

# Activate your license (required for commercial use)
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept_terms

# Start the daemon + REST API
local-memory start

# Configure the MCP client config for you (auto-detects Claude Desktop)
local-memory install mcp
# For Claude Code:            local-memory install mcp claude-code

# Verify everything is healthy
local-memory doctor
```

That's the whole path from zero to a running memory system. `local-memory install mcp` writes the MCP client configuration for you and auto-detects Claude Desktop; pass a client name (`claude-code`, `cursor`, ...) to target a specific one.

### Manual Installation

1. Download the appropriate binary for your platform from the [releases page](https://github.com/danieleugenewilliams/local-memory-releases) # Note: This is not a placeholder. This is the correct release repo.
2. Place the binary in your PATH
3. Run the setup wizard: `local-memory setup`
4. After purchasing from localmemory.co, activate your license: `local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept_terms`
5. Install MCP integration: `local-memory install mcp`

### Teaching an agent to use Local Memory

An **agent skill** ships in this repo at `integrations/local-memory-skill/`. It teaches AI agents (like Claude) when and how to use Local Memory — the core loop, what's worth storing, and the tool reference. Install it as a Claude Code plugin, or run the bundled `install.sh`. Once installed, your agent will proactively capture and recall knowledge on its own.

## Basic Workflow

Here's how to get started with Local Memory:

### 1. Start the System

```bash
# Start the daemon
local-memory start

# Check if it's running
local-memory status
```

### 2. Store Your First Memory

```bash
# Record an observation (this replaces the old `remember` command)
local-memory observe "The transformer architecture revolutionized NLP with self-attention mechanisms"

# Observation with a domain and tags
local-memory observe "Python is great for data science" --domain programming --tags "python,data-science"

# Set an initial weight (0.0-10.0) or record it at a higher level
local-memory observe "Circuit breaker pattern prevents cascading failures" --level learning --weight 6.0
```

> Note: `remember` (and `store_memory`) were removed in v1.5.0. Use `observe` everywhere you previously used them.

### 3. Search Your Memories

```bash
# Simple keyword search
local-memory search "transformer architecture"

# AI-powered semantic search (optional — requires Ollama, see below)
local-memory search "neural networks" --use_ai

# Search by tags
local-memory search "python" --tags "python,web"

# Date range search
local-memory search --search_type date_range --start_date "2024-01-01" --end_date "2024-12-31"
```

### 4. Create Relationships

```bash
# Find memories first to get their IDs
local-memory search "transformer" --limit 2

# Create a typed relationship between two memories (using IDs from search results)
local-memory relate 359bf199-0fcf-4403-8dc6-ffd07f6cb900 359bf199-0fcf-4403-8dc6-ffd07f6cb911 --type references --strength 0.8 --confirm
```

### 5. Analyze Your Knowledge

```bash
# Ask questions about your memories (AI-powered — requires Ollama)
local-memory analyze "What are the key concepts I've learned about machine learning?" --type question

# Summarize recent memories
local-memory analyze --type summarize --timeframe week

# Track learning progression
local-memory analyze --type temporal_patterns --concept "deep learning"
```

## Core Concepts

### Memory Storage
- Each memory has a unique ID
- Memories can have tags, a knowledge level, a weight, a domain, and metadata
- Content is automatically analyzed for semantic understanding

### Knowledge Levels
- **Observation (L0)**: raw intake, captured as you learn
- **Learning (L1)**: a candidate insight synthesized from observations via `reflect`
- **Pattern (L2)**: a generalization validated across many learnings
- **Schema (L3)**: a durable framework that explains patterns

Knowledge matures through the **observe → reflect → evolve** loop; promotion is earned through repeated validation.

### Search Types
- **Keyword Search**: Traditional text matching
- **Semantic Search**: AI-powered meaning-based search (`--use_ai`, requires Ollama)
- **Tag Search**: Filter by specific tags
- **Date Range**: Search by time periods (`--search_type date_range`)
- **Hybrid Search**: Combine multiple search criteria

### Relationships
- Connect related memories with typed relationships
- Relationship types: references, contradicts, expands, similar, sequential, causes, enables
- Relationships have strength ratings (0.0 to 1.0)

### Analysis Types
- **Question Answering**: Ask natural language questions about your stored knowledge
- **Summarization**: Generate summaries of memory collections
- **Pattern Analysis**: Discover patterns and themes in your memories
- **Temporal Analysis**: Track learning progression over time

## Optional AI Services

Core capture and retrieval (`observe`, keyword `search`, `relate`) work out of the box with no extra services — Local Memory uses a local SQLite store by default.

Some operations are **AI-enhanced** and need a local model stack:

- **Ollama** (default `http://localhost:11434`) powers `analyze`/`ask` and semantic `search --use_ai`. Auto-detected when present; AI features degrade gracefully if it's absent.
- **Qdrant** (default `http://localhost:6333`) is an **optional** vector database for faster/larger semantic search. It is **disabled by default** — SQLite vector search works without it. Local Memory only *detects* Qdrant; it does not launch it, so you must start Qdrant separately if you want to use it.

## Configuration Basics

### Configuration Directory
Local Memory stores its configuration and data in:
- **macOS**: `~/.local-memory/`
- **Linux**: `~/.local-memory/`
- **Windows**: `%USERPROFILE%\.local-memory\`

### Key Configuration Files
- `config.yaml`: Main configuration
- `unified-memories.db`: SQLite database
- `daemon.log`: System log
- `qdrant-storage/`: Qdrant vector data (only if Qdrant is enabled)

### Environment Variables
```bash
export LOCAL_MEMORY_CONFIG_DIR="$HOME/.local-memory"
export MEMORY_REST_API_PORT="3002"
export MEMORY_OLLAMA_BASE_URL="http://localhost:11434"
```

## License Management

Local Memory requires a commercial license for use. You can obtain a license key at [localmemory.co](https://localmemory.co).

### License Commands

```bash
# Activate a new license
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX

# Activate with automatic terms acceptance
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept_terms

# Check license status
local-memory license status

# Validate an existing license
local-memory license validate LM-XXXX-XXXX-XXXX-XXXX-XXXX

# View license information in JSON format
local-memory license status --json
```

### License Key Troubleshooting

If you encounter issues with license activation, here are common solutions:

#### Character Format Issues
License keys must use regular hyphens (-) to separate segments. If you copy-paste your license key and see errors about "invalid length," check for:

- **Em-dash (—)**: Often inserted by word processors like Microsoft Word
- **En-dash (–)**: Sometimes used in documents instead of regular hyphens

**Solution**: Local Memory automatically normalizes these characters, but if you still have issues, manually replace any special dashes with regular hyphens (-).

#### Common Error Messages
- **"invalid license key length"**: Check for special dash characters (see above)
- **"terms and conditions not accepted"**: Use the `--accept_terms` flag or run activation without it for an interactive prompt
- **"license key contains invalid characters"**: Ensure only alphanumeric characters and hyphens are used

#### Getting Help
If issues persist:
1. Run `local-memory doctor` for system diagnostics
2. Check license status: `local-memory license status`
3. Contact support with the error message and your system information

## Integration Options

### MCP Integration (AI Agents)
Local Memory integrates with AI agents through the Model Context Protocol:

```bash
# Install MCP integration (auto-detects Claude Desktop)
local-memory install mcp

# For specific clients
local-memory install mcp claude-desktop
local-memory install mcp claude-code
local-memory install mcp cursor

# Complete setup and installation in one command
local-memory install --all
```

After installing, restart your MCP client so it picks up the new server.

### REST API Usage
Access Local Memory via HTTP REST API (base URL `http://localhost:3002/api/v1`, no auth on localhost):

```bash
# Health check
curl http://localhost:3002/api/v1/health

# Store a memory
curl -X POST http://localhost:3002/api/v1/memories \
  -H "Content-Type: application/json" \
  -d '{"content": "Your memory content", "importance": 7, "tags": ["notes"], "domain": "general"}'

# Search
curl "http://localhost:3002/api/v1/memories/search?query=neural%20networks&use_ai=true"
```

### Scripting with CLI
```bash
# Export search results to JSON
local-memory search "transformer" --json > memories_backup.json

# Store from a script
local-memory observe "$(echo 'memory content')" --tags "script-generated"

# Count results by tag
local-memory search "python" --tags "python" --json | jq '.data.result_count'
```

## Common Use Cases

### Research and Learning
- Store research notes and papers
- Connect related concepts
- Track learning progression
- Ask questions about accumulated knowledge

### Development Knowledge Base
- Store code snippets and solutions
- Document lessons learned
- Track project decisions
- Build team knowledge base

### Personal Knowledge Management
- Store meeting notes and insights
- Track ideas and thoughts
- Build personal wiki
- Organize information by topics

## Getting Help

### Command-Line Help
```bash
# General help
local-memory --help

# Command-specific help
local-memory search --help

# Progressive parameter discovery
local-memory search --help_parameters
local-memory search --help_parameters --show_all

# Context-aware help
local-memory search --help_context

# Workflow guidance
local-memory search --help_workflow
```

### System Diagnostics
```bash
# Run comprehensive diagnostics
local-memory doctor

# Check system status
local-memory status

# Validate installation
local-memory validate

# Check license status
local-memory license status
```

### Troubleshooting
```bash
# List running local-memory processes
local-memory ps

# View logs
tail -f ~/.local-memory/daemon.log

# Kill stuck processes, then restart
local-memory kill_all
local-memory start
```

## Next Steps

1. **Explore Advanced Features**: Check out the detailed CLI reference and REST API documentation
2. **Set Up Integrations**: Configure MCP for your AI tools, and install the agent skill from `integrations/local-memory-skill/`
3. **Customize Configuration**: Adjust settings for your specific needs
4. **Build Workflows**: Create scripts and automation around your knowledge management needs

For detailed documentation on specific features, see:
- [CLI Reference](cli-reference.md) - Complete command documentation
- [REST API](rest-api.md) - Full API specification
- [MCP Tools](mcp-tools.md) - Model Context Protocol integration
- [Configuration](configuration.md) - Advanced configuration options
</content>
</invoke>
