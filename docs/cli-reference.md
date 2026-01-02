# CLI Reference Guide

Local Memory provides a comprehensive command-line interface for managing your persistent memory through natural language commands. This reference covers all available commands, their flags, and usage patterns.

## Global Flags

These flags are available for all commands:

```bash
--config string      # Config file path (default: auto-detected)
--log_level string   # Log level: debug, info, warn, error (default: info)
--mcp                # Run as MCP server (JSON-RPC over stdin/stdout)
--quiet              # Suppress output
--help, -h           # Help for any command
--version, -v        # Show version
```

## Parameter Help System

Local Memory features an intelligent parameter help system with progressive discovery:

```bash
# Basic parameter help
local-memory search --help_parameters

# Progressive discovery levels
local-memory search --help_parameters --basic_only      # Beginner-friendly
local-memory search --help_parameters --show_advanced   # Power users
local-memory search --help_parameters --show_all        # Expert options

# Context-aware suggestions
local-memory remember --help_context
```

## Core Memory Commands

### remember - Store a Memory

Store information with automatic AI categorization.

```bash
local-memory remember [content] [flags]
```

**Examples:**
```bash
local-memory remember "Go channels are like pipes between goroutines"
local-memory remember "Redis is excellent for caching" --importance 8 --tags caching,databases
local-memory remember "Neural networks for NLP" --domain ai-research
```

**Flags:**
- `--importance int`: Importance level 1-10 (default: 5)
- `--tags strings`: Tags for categorization
- `--domain string`: Knowledge domain
- `--json`: Output in JSON format

### search - Search Memories

Search using keywords or AI-powered semantic similarity.

```bash
local-memory search [query] [flags]
```

**Examples:**
```bash
local-memory search "concurrency patterns"
local-memory search "databases" --limit 5 --use_ai
local-memory search "python" --domain programming --tags web,scripting
local-memory search "neural networks" --fields id,content,importance
```

**Core Flags:**
- `--limit int`: Maximum results (default: 10)
- `--use_ai`: Use AI-powered semantic search
- `--tags strings`: Filter by tags
- `--domain string`: Filter by knowledge domain
- `--json`: Output in JSON format

**Advanced Flags:**
- `--fields strings`: Select specific fields (id,content,importance,tags,domain,created_at,updated_at,slug)
- `--response_format string`: Format: detailed, concise, ids_only, summary, custom, intelligent, ultra, micro (default: detailed)
- `--max_content_length int`: Max content length with sentence-boundary truncation (0 = no limit)
- `--search_type string`: Type: semantic, tags, date_range, hybrid (auto-detected)
- `--session_filter_mode string`: Session filtering: all, session_only, session_and_shared (default: all)
- `--start_date string`: Start date for range search (YYYY-MM-DD)
- `--end_date string`: End date for range search (YYYY-MM-DD)

### get - Get Memory by ID

Retrieve a specific memory by its unique identifier.

```bash
local-memory get <memory-id> [flags]
```

**Examples:**
```bash
local-memory get 550e8400-e29b-41d4-a716-446655440000
local-memory get <memory-id> --json
```

**Flags:**
- `--json`: Output in JSON format

### update - Update a Memory

Update content, importance, tags, or domain of existing memory.

```bash
local-memory update <memory-id> [flags]
```

**Examples:**
```bash
local-memory update 550e8400-e29b-41d4-a716-446655440000 --content "Updated content"
local-memory update 550e8400-e29b-41d4-a716-446655440000 --importance 9 --tags updated,important
local-memory update 550e8400-e29b-41d4-a716-446655440000 --domain "new-domain"
```

**Flags:**
- `--content string`: New content for the memory
- `--importance int`: New importance level 1-10 (0 = no change)
- `--tags strings`: New tags (replaces existing)
- `--domain string`: New knowledge domain
- `--confirm`: Skip confirmation prompt
- `--json`: Output in JSON format

### forget - Delete a Memory

Remove a memory from persistent storage.

```bash
local-memory forget <memory-id> [flags]
```

**Examples:**
```bash
local-memory forget 550e8400-e29b-41d4-a716-446655440000
local-memory forget --confirm 550e8400-e29b-41d4-a716-446655440000
```

**Flags:**
- `--confirm`: Skip confirmation prompt
- `--json`: Output in JSON format

### list - List All Memories

Retrieve a paginated list of all stored memories.

```bash
local-memory list [flags]
```

**Examples:**
```bash
local-memory list
local-memory list --limit 10 --offset 20
local-memory list --response_format concise --json
```

**Flags:**
- `--limit int`: Maximum memories to return (default: 20)
- `--offset int`: Number to skip for pagination (default: 0)
- `--response_format string`: Format: detailed, concise, summary
- `--json`: Output in JSON format

## Relationship Commands

### relate - Create Relationship

Create a relationship between two memories using their IDs.

```bash
local-memory relate <source-memory-id> <target-memory-id> [flags]
```

**Examples:**
```bash
local-memory relate <source-id> <target-id>
local-memory relate <source-id> <target-id> --strength 0.9 --type expands
```

**Flags:**
- `--strength float32`: Relationship strength 0.0-1.0 (default: 0.8)
- `--type string`: Relationship type: references, contradicts, expands, similar, sequential, causes, enables (default: references)
- `--confirm`: Skip confirmation prompt
- `--json`: Output in JSON format

### find_related - Find Related Memories

Find memories related to a specific memory using AI-powered discovery.

```bash
local-memory find_related <memory-id> [flags]
```

**Examples:**
```bash
local-memory find_related 550e8400-e29b-41d4-a716-446655440000
local-memory find_related <memory-id> --limit 10 --min_strength 0.5
local-memory find_related <memory-id> --relationship_types similar,references
```

**Flags:**
- `--limit int`: Maximum related memories to return (default: 10)
- `--min_strength float64`: Minimum relationship strength 0.0-1.0 (default: 0.0)
- `--relationship_types strings`: Filter by types: references, contradicts, expands, similar, sequential, causes, enables
- `--session_id string`: Filter to specific session
- `--response_format string`: Format: detailed, concise, ids_only (default: concise)
- `--json`: Output in JSON format

### discover - Discover Relationships

Use AI to discover potential relationships between memories.

```bash
local-memory discover [flags]
```

**Examples:**
```bash
local-memory discover --limit 20 --min_strength 0.7
local-memory discover --memory_id <memory-id> --limit 10
local-memory discover --session_id current --relationship_types similar,expands
```

**Flags:**
- `--limit int`: Maximum relationships to discover (default: 20)
- `--min_strength float64`: Minimum strength for discovery 0.0-1.0 (default: 0.5)
- `--memory_id string`: Discover relationships for specific memory ID
- `--relationship_types strings`: Filter by relationship types to discover
- `--session_id string`: Limit to memories from specific session
- `--response_format string`: Format: detailed, concise, ids_only (default: concise)
- `--json`: Output in JSON format

### map_graph - Generate Relationship Graph

Generate a relationship graph showing connections between memories.

```bash
local-memory map_graph <memory-id> [flags]
```

**Examples:**
```bash
local-memory map_graph 550e8400-e29b-41d4-a716-446655440000
local-memory map_graph <memory-id> --depth 3 --include_strength
local-memory map_graph <memory-id> --relationship_types similar,references --json
```

**Flags:**
- `--depth int`: Relationship hops to include 1-5 (default: 2)
- `--include_strength`: Include relationship strength values (default: true)
- `--relationship_types strings`: Filter by specific relationship types
- `--response_format string`: Format: detailed, concise, ids_only (default: concise)
- `--json`: Output in JSON format

## Analysis Commands

### analyze - AI-Powered Memory Analysis

Perform AI-powered analysis including Q&A, summarization, and pattern analysis.

```bash
local-memory analyze [query] [flags]
```

**Question Answering:**
```bash
local-memory analyze "What are the key differences between supervised and unsupervised learning?" --type question
```

**Summarization:**
```bash
local-memory analyze --type summarize --timeframe month --limit 50
```

**Pattern Analysis:**
```bash
local-memory analyze "machine learning patterns" --type analyze
```

**Temporal Analysis:**
```bash
local-memory analyze --type temporal_patterns --concept "deep learning" --temporal_timeframe quarter
```

**Core Flags:**
- `--type string`: Analysis type: question, summarize, analyze, temporal_patterns (default: question)
- `--timeframe string`: Time period: today, week, month, all (default: all)
- `--limit int`: Maximum memories to include (default: 10)
- `--json`: Output in JSON format

**Advanced Flags:**
- `--concept string`: Specific concept for temporal pattern analysis
- `--temporal_timeframe string`: Timeframe: week, month, quarter, year (default: month)
- `--temporal_analysis_type string`: Type: learning_progression, knowledge_gaps, concept_evolution (default: learning_progression)
- `--context_limit int`: Max memories for Q&A context (default: 10)
- `--session_filter_mode string`: Session filtering: all, session_only, session_and_shared (default: all)
- `--session_id string`: Session ID for filtering
- `--response_format string`: Format: detailed, concise, ids_only, summary, custom, ultra, micro (default: concise)
- `--response_template string`: Template: agent_minimal, analysis_ready, relationship_focused, temporal_analysis, content_preview, metadata_only, full_context

## Organization Commands

### Categories

**list_categories** - List all categories:
```bash
local-memory list_categories        # List all categories with details
local-memory list_categories --json # Output in JSON format
```

**create_category** - Create a new category:
```bash
local-memory create_category <name> [description] [flags]

# Examples
local-memory create_category "technical-docs" "Technical documentation"
local-memory create_category "ai-research" --parent_id <parent-uuid>
```
- `--parent_id string`: Parent category UUID for hierarchy

**categorize** - Categorize memory using AI:
```bash
local-memory categorize <memory-id> [flags]

# Examples
local-memory categorize 550e8400-e29b-41d4-a716-446655440000
local-memory categorize <memory-id> --confidence_threshold 0.8 --auto_create false
```
- `--confidence_threshold float64`: Minimum confidence for auto-categorization (default: 0.7)
- `--auto_create`: Auto-create new categories suggested by AI (default: true)

**category_stats** - Show category statistics:
```bash
local-memory category_stats [category-id] [--json]
```

### Domains

**list_domains** - List knowledge domains:
```bash
local-memory list_domains [--json]
```

**create_domain** - Create knowledge domain:
```bash
local-memory create_domain <name> [description]

# Examples
local-memory create_domain "ai-research" "Artificial Intelligence Research"
local-memory create_domain "programming" "Software Development"
```

**domain_stats** - Show domain statistics:
```bash
local-memory domain_stats <domain> [--json]
```

### Sessions

**list_sessions** - List memory sessions:
```bash
local-memory list_sessions [--json]
```

**session_stats** - Show current session statistics:
```bash
local-memory session_stats [--json]
```

## Daemon Management Commands

### start - Start Daemon
```bash
local-memory start
```

### stop - Stop Daemon
```bash
local-memory stop
```

### status - Show Daemon Status
```bash
local-memory status [--json]
```

### install - Install Integration
```bash
local-memory install [target] [flags]

# Examples
local-memory install mcp                    # Auto-detect MCP clients
local-memory install mcp claude-desktop     # Specific client
local-memory install mcp claude-code
local-memory install --all                  # Complete setup + MCP
```
- `--all`: Complete setup and installation
- `--auto_setup`: Automatically configure services
- `--json`: Output in JSON format

### setup - Run Setup Wizard
```bash
local-memory setup [flags]

# Examples
local-memory setup --interactive             # Interactive wizard
local-memory setup --silent                 # Silent setup with defaults
local-memory setup --output results.json    # Save results to file
```
- `--interactive`: Run interactive setup wizard
- `--silent`: Run silent setup with defaults
- `--show_deps`: Show dependency status and installation instructions
- `--output string`: Output setup results to file (JSON)
- `--json`: Output in JSON format

## Diagnostic Commands

### doctor - Comprehensive System Check
```bash
local-memory doctor
```

### validate - Validate Installation
```bash
local-memory validate [target] [--json]

# Examples
local-memory validate mcp       # Validate MCP installation
local-memory validate config    # Validate configuration file syntax and structure
local-memory validate all       # Validate everything (default)
```

### Process Management

**ps** - List running processes:
```bash
local-memory ps
```

**kill_all** - Kill all processes:
```bash
local-memory kill_all [flags]

# Examples
local-memory kill_all --confirm                    # Kill all processes
local-memory kill_all --type rest --confirm       # Kill only REST processes
local-memory kill_all --type mcp --confirm        # Kill only MCP processes
local-memory kill_all --type background --confirm # Kill only background processes
```
- `--type string`: Filter by process type: mcp, rest, background
- `--confirm`: Skip confirmation prompt
- `--json`: Output in JSON format

**kill** - Kill specific process:
```bash
local-memory kill <pid> --confirm [--json]
```

### License Management

```bash
local-memory license [subcommand] [flags]

# Examples
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX
local-memory license status
local-memory license validate LM-XXXX-XXXX-XXXX-XXXX-XXXX
```
- `--accept_terms`: Auto-accept terms and conditions (for activation)
- `--json`: Output in JSON format

## Shell Completion

Generate shell autocompletion scripts:

```bash
# Generate completion scripts
local-memory completion bash > ~/.local-completion.bash
local-memory completion zsh > ~/.local-completion.zsh
local-memory completion fish > ~/.config/fish/completions/local-memory.fish

# Add to shell profile
echo 'source ~/.local-completion.bash' >> ~/.bashrc   # Bash
echo 'source ~/.local-completion.zsh' >> ~/.zshrc     # Zsh
```

## Response Formats

All commands support multiple response formats via `--response_format`:

- **detailed**: Full object information with all fields
- **concise**: Essential fields only (~70% size reduction)
- **ids_only**: Memory IDs only (~95% size reduction)
- **summary**: Truncated content (~50% size reduction)
- **custom**: Use with `--fields` for precise control
- **intelligent**: Auto-optimizes based on context
- **ultra**: Minimal essential information
- **micro**: Absolute minimal output

## Field Selection

Use `--fields` for precise output control:
```bash
local-memory search "query" --fields id,content,importance,tags
local-memory search "query" --response_format custom --fields id,importance
```

Available fields: `id`, `content`, `importance`, `tags`, `domain`, `created_at`, `updated_at`, `slug`