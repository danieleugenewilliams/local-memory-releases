# Getting Started with Local Memory

Local Memory is a powerful AI memory system that allows you to store, search, and analyze information using semantic understanding. This guide will help you get started with Local Memory quickly.

## What is Local Memory?

Local Memory provides three complementary interfaces for intelligent information storage and retrieval:

- **CLI (Command-line Interface)**: Direct human interaction and scripting
- **MCP (Model Context Protocol)**: Integration with AI agents and Claude
- **REST API**: Web service integration and automation

All three interfaces provide the same functionality with consistent behavior and responses.

## Installation

### Quick Setup

```bash
# Download and install
npm install -g local-memory-mcp

# Run the setup wizard
local-memory setup

# Or use specific setup modes
local-memory setup --interactive  # Interactive wizard
local-memory setup --silent      # Silent setup with defaults

# Activate your license (required for commercial use)
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX

# Verify license status
local-memory license status

# Start the daemon
local-memory start

# Verify installation
local-memory doctor
```

### Manual Installation

1. Download the appropriate binary for your platform from the [releases page](https://github.com/danieleugenewilliams/local-memory-releases) # Note: This is not a placeholder. This is the correct release repo.
2. Place the binary in your PATH
3. Run the setup wizard: `local-memory setup`
4. After purchasing from localmemory.co, activate your license: `local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX`
5. Install MCP integration: `local-memory install`

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
# Basic memory storage
local-memory remember "The transformer architecture revolutionized NLP with self-attention mechanisms"

# Memory with metadata
local-memory remember "Python is great for data science" --tags "programming,python,data-science" --importance 8
```

### 3. Search Your Memories

```bash
# Simple search
local-memory search "transformer architecture"

# AI-powered semantic search
local-memory search "neural networks" --use_ai

# Search by tags
local-memory search --tags "programming,python"

# Date range search
local-memory search --start_date "2024-01-01" --end_date "2024-12-31"
```

### 4. Create Relationships

```bash
# Find related memories first
local-memory search "transformer" --limit 2

# Create relationships between memories (using IDs from search results)
local-memory relate 359bf199-0fcf-4403-8dc6-ffd07f6cb900 359bf199-0fcf-4403-8dc6-ffd07f6cb911 --type "references" --strength 0.8 --confirm
```

### 5. Analyze Your Knowledge

```bash
# Ask questions about your memories
local-memory analyze "What are the key concepts I've learned about machine learning?"

# Summarize recent memories
local-memory analyze --type summarize --timeframe week

# Track learning progression
local-memory analyze --type temporal_patterns --concept "deep learning"
```

## Core Concepts

### Memory Storage
- Each memory has a unique ID
- Memories can have tags, importance ratings, and metadata
- Content is automatically analyzed for semantic understanding

### Search Types
- **Keyword Search**: Traditional text matching
- **Semantic Search**: AI-powered meaning-based search
- **Tag Search**: Filter by specific tags
- **Date Range**: Search by time periods *(under development)*
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

## Configuration Basics

### Configuration Directory
Local Memory stores its configuration and data in:
- **macOS**: `~/.local-memory/`
- **Linux**: `~/.local-memory/`
- **Windows**: `%USERPROFILE%\.local-memory\`

### Key Configuration Files
- `config.yaml`: Main configuration
- `unified-memories.db`: SQLite database (encrypted)
- `logs/`: System logs

### Environment Variables
```bash
export LOCAL_MEMORY_CONFIG_DIR="$HOME/.local-memory"
export LOCAL_MEMORY_LOG_LEVEL="info"
export LOCAL_MEMORY_API_PORT="3002"
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

#### `--accept-terms` Flag Issues
Both formats work correctly:
```bash
# Both of these work the same way:
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept-terms
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept_terms
```

#### Common Error Messages
- **"invalid license key length"**: Check for special dash characters (see above)
- **"terms and conditions not accepted"**: Use `--accept-terms` flag or run activation without the flag for interactive prompt
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
# Install MCP integration
local-memory install

# For specific clients
local-memory install mcp claude-desktop
local-memory install mcp cursor

# Complete setup and installation in one command
local-memory install --all
```

### REST API Usage
Access Local Memory via HTTP REST API:

```bash
# Health check
curl http://localhost:3002/api/v1/health

# Store a memory
curl -X POST http://localhost:3002/api/v1/memories \
  -H "Content-Type: application/json" \
  -d '{"content": "Your memory content", "importance": 7}'
```

### Scripting with CLI
```bash
# Export memories to JSON
local-memory search "all" --json > memories_backup.json

# Batch operations
local-memory remember "$(echo 'memory content')" --tags "script-generated"

# Count memories by tag
local-memory search --tags "python" --json | jq '. | length'
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
# Check if daemon is running
local-memory ps

# View logs
tail -f ~/.local-memory/daemon.log

# Kill stuck processes
local-memory kill_all
```

## Next Steps

1. **Explore Advanced Features**: Check out the detailed CLI reference and REST API documentation
2. **Set Up Integrations**: Configure MCP for your AI tools
3. **Customize Configuration**: Adjust settings for your specific needs
4. **Build Workflows**: Create scripts and automation around your knowledge management needs

For detailed documentation on specific features, see:
- [CLI Reference](cli-reference.md) - Complete command documentation
- [REST API](rest-api.md) - Full API specification
- [MCP Tools](mcp-tools.md) - Model Context Protocol integration
- [Configuration](configuration.md) - Advanced configuration options