# CLI Reference Guide

Local Memory provides a comprehensive command-line interface for managing your persistent memory through natural language commands. This reference covers all available commands, their flags, and usage patterns for **Local Memory v1.5.1**.

Many reasoning and lifecycle commands take their main inputs as **positional arguments**, not flags. Always check `local-memory <command> --help` for the exact signature.

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
local-memory search --help_context
```

## Core Memory Commands

### observe - Record an Observation

Record observations and content with knowledge hierarchy levels. This is the primary capture command (it replaces the old `remember` command). New content is recorded at the `observation` level by default and can later be matured into learnings, patterns, and schemas.

```bash
local-memory observe [content] [flags]
```

**Examples:**
```bash
local-memory observe "Go channels are like pipes between goroutines"
local-memory observe "API returns 500 errors under load" --level observation --tags api,errors --domain backend
local-memory observe "Circuit breaker pattern prevents cascading failures" --level learning --weight 6.0
local-memory observe "Database connection pools optimize resource usage" --level pattern --auto_promote
```

**Flags:**
- `--level string`: Memory level: observation, learning, pattern, schema (default: observation)
- `--weight float`: Initial weight 0.0-10.0 (auto-assigned if not specified)
- `--tags strings`: Tags for categorization
- `--domain string`: Knowledge domain
- `--source string`: Source of the observation
- `--context string`: Additional context
- `--auto_promote`: Automatically promote when criteria are met
- `--session_id string`: Session identifier
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
local-memory search "patterns" --start_date 2025-01-01 --end_date 2025-12-31
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

Remove a memory from persistent storage. This is a permanent delete — use sparingly.

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

## Knowledge Questions

Track open questions, contradictions, and epistemic gaps, then resolve them once you have an answer.

### question - Record a Question

Record questions, contradictions, and knowledge gaps for later resolution.

```bash
local-memory question [content] [flags]
```

**Examples:**
```bash
local-memory question "How does Redis handle persistence exactly?"
local-memory question "Contradiction: memory A says X, memory B says Y" --question_type contradiction --priority 8
local-memory question "Need to understand database sharding" --domain databases --priority 7
```

**Flags:**
- `--question_type string`: Type: epistemic_gap, contradiction, prediction_failure (default: epistemic_gap)
- `--priority int`: Priority level 1-10 (default: 5)
- `--domain string`: Knowledge domain
- `--origin_context string`: Context that prompted this question
- `--session_id string`: Session identifier
- `--response_format string`: Format: detailed, concise, ids_only (default: concise)
- `--json`: Output in JSON format

### questions - List Questions

List and filter recorded questions, contradictions, and epistemic gaps.

```bash
local-memory questions [flags]
```

**Examples:**
```bash
local-memory questions
local-memory questions --type contradiction
local-memory questions --status resolved --limit 10
local-memory questions --priority-min 7 --format concise
local-memory questions --format ids_only
```

**Flags:**
- `--status string`: Filter by status: pending, investigating, resolved, archived (default: pending)
- `--type string`: Filter by type: epistemic_gap, contradiction, prediction_failure
- `--domain string`: Filter by knowledge domain
- `--priority-min int`: Minimum priority 1-10
- `--session-id string`: Filter by originating session ID
- `--limit int`: Maximum number of results (default: 50)
- `--offset int`: Pagination offset (default: 0)
- `--format string`: Output format: detailed, concise, summary, ids_only (default: detailed)
- `--json`: Output in JSON format

### resolve - Resolve a Question

Resolve a detected contradiction or answer an epistemic gap with a structured resolution. Takes `question_id`, `resolution_type`, and `rationale` as positional arguments.

```bash
local-memory resolve <question_id> <resolution_type> <rationale> [flags]
```

**Examples:**
```bash
local-memory resolve <question-id> a_supersedes "Memory A is more recent and accurate"
local-memory resolve <question-id> merged "Both contain partial truths" --create_synthesis --synthesis_content "Combined understanding..."
```

**Flags:**
- `--create_synthesis`: Create a synthesis memory from merged understanding
- `--synthesis_content string`: Synthesized understanding content (for `merged` resolution)
- `--update_relationship`: Update contradiction relationship (default: true)
- `--update_weights`: Update memory weights based on resolution (default: true)
- `--session_id string`: Session identifier
- `--json`: Output in JSON format

## Relationship Commands

### relate - Create Relationship

Create a relationship between two memories using their IDs. Takes source and target memory IDs as positional arguments.

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
- `--session_id string`: Session identifier for attribution
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
- `--min_strength float`: Minimum relationship strength 0.0-1.0
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
- `--min_strength float`: Minimum strength for discovery 0.0-1.0 (default: 0.5)
- `--memory_id string`: Discover relationships for specific memory ID
- `--relationship_types strings`: Filter by relationship types to discover
- `--session_id string`: Limit to memories from specific session
- `--response_format string`: Format: detailed, concise, ids_only (default: concise)
- `--json`: Output in JSON format

### map_graph - Generate Relationship Graph

Generate a relationship graph showing connections between memories. Takes the memory ID as a positional argument.

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

## Analysis & Reasoning Commands

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

### predict - Predict Outcomes

Use stored patterns and schemas to predict outcomes based on a given context. Takes the `given` context as a positional argument.

```bash
local-memory predict <given> [flags]
```

**Examples:**
```bash
local-memory predict "user clicks checkout button"
local-memory predict "API receives high traffic" --use_ai
local-memory predict "test fails" --action "rerun test" --domain testing
```

**Flags:**
- `--action string`: Optional action being taken in the given context
- `--domain string`: Focus domain for prediction filtering
- `--limit int`: Maximum number of predictions to return (default: 5)
- `--schema_ids strings`: Specific schema UUIDs to use for prediction
- `--use_ai`: Enable AI-enhanced prediction generation
- `--session_id string`: Session identifier
- `--response_format string`: Format: detailed, concise, summary, ids_only (default: detailed)
- `--json`: Output in JSON format

### explain - Trace Causal Paths

Find and explain the causal chain connecting two states using stored knowledge. Takes `from_state` and `to_state` as positional arguments.

```bash
local-memory explain <from_state> <to_state> [flags]
```

**Examples:**
```bash
local-memory explain "user logged in" "user completed purchase"
local-memory explain "test passed" "deployment failed" --use_ai
local-memory explain "error occurred" "service recovered" --max_depth 6
```

**Flags:**
- `--domain string`: Focus domain for causal path discovery
- `--max_depth int`: Maximum number of relationship hops to traverse (default: 4)
- `--use_ai`: Enable AI-enhanced explanation generation
- `--session_id string`: Session identifier
- `--response_format string`: Format: detailed, concise, summary, ids_only (default: detailed)
- `--json`: Output in JSON format

### counterfactual - "What If" Reasoning

Explore alternative scenarios by reasoning about counterfactual conditions. Takes `observed` and `if_condition` as positional arguments. Also available as the alias `whatif`.

```bash
local-memory counterfactual <observed> <if_condition> [flags]
```

**Examples:**
```bash
local-memory counterfactual "deployment failed" "we had run integration tests"
local-memory counterfactual "user churned" "price was 20% lower" --use_ai
local-memory whatif "feature was delayed" "we had more resources"
```

**Flags:**
- `--domain string`: Focus domain for counterfactual reasoning
- `--schema_ids strings`: Specific schema UUIDs to consult for reasoning
- `--use_ai`: Enable AI-enhanced counterfactual reasoning
- `--session_id string`: Session identifier
- `--response_format string`: Format: detailed, concise, summary, ids_only (default: detailed)
- `--json`: Output in JSON format

## Knowledge Evolution

Mature raw observations into higher-order knowledge and manage the memory lifecycle over time.

### reflect - Process Observations into Learnings

Transform raw observations into structured learnings using AI analysis. Takes the mode as a positional argument (`single`, `batch`, or `auto`).

```bash
local-memory reflect <mode> [flags]
```

**Examples:**
```bash
local-memory reflect single --observation_id <uuid>
local-memory reflect batch --batch_size 10
local-memory reflect auto --auto_criteria "weight>0.3"
local-memory reflect batch --dry_run
```

**Flags:**
- `--observation_id string`: UUID of observation to reflect on (required for single mode)
- `--batch_size int`: Number of observations to process in batch mode (default: 10)
- `--auto_criteria string`: Criteria for automatic reflection selection
- `--dry_run`: Preview which observations would be promoted without modifying the database
- `--session_id string`: Session identifier
- `--json`: Output in JSON format

### evolve - Run Evolution Operations

Execute knowledge evolution operations to manage the memory lifecycle. Takes the operation as a positional argument (`validate`, `promote`, `decay`, or `accommodate`).

```bash
local-memory evolve <operation> [flags]
```

**Examples:**
```bash
local-memory evolve validate --entity_id <uuid> --success
local-memory evolve promote --entity_id <uuid>
local-memory evolve decay --threshold_days 30 --dry_run
local-memory evolve accommodate --entity_id <uuid>
```

**Flags:**
- `--entity_id string`: UUID of memory entity to operate on (required for validate/promote)
- `--success`: Validation success (required for validate operation)
- `--threshold_days int`: Days threshold for decay operation (default: 30)
- `--dry_run`: Preview changes without applying (for decay)
- `--context string`: Context or rationale for the evolution operation
- `--session_id string`: Session identifier
- `--json`: Output in JSON format

## Session Context

### bootstrap - Initialize Session Context

Load relevant patterns, learnings, and questions to initialize agent context at the start of a session.

```bash
local-memory bootstrap [flags]
```

**Examples:**
```bash
local-memory bootstrap                                    # Full context initialization
local-memory bootstrap --mode minimal --include_questions false
local-memory bootstrap --mode domain --domain programming --limit 10
```

**Flags:**
- `--mode string`: Bootstrap mode: full, minimal, domain (default: full)
- `--domain string`: Focus domain (required for domain mode)
- `--limit int`: Maximum number of items per category (default: 20)
- `--include_patterns`: Include high-weight patterns (default: true)
- `--include_learnings`: Include recent learnings (default: true)
- `--include_questions`: Include pending questions (default: true)
- `--session_id string`: Session identifier
- `--json`: Output in JSON format

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

**migrate_domain** - Move memories from one domain to another (defaults to dry-run):
```bash
local-memory migrate_domain --from <source> --to <target> [flags]

# Examples
local-memory migrate_domain --from old-domain --to new-domain
local-memory migrate_domain --from old-domain --to new-domain --dry_run=false
```
- `--from string`: Source domain name (required)
- `--to string`: Target domain name (required)
- `--dry_run`: Preview migration without applying changes (default: true)
- `--session_id string`: Limit migration to memories in this session
- `--json`: Output in JSON format

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

Validate the Local Memory installation and configuration.

```bash
local-memory validate [target] [--json]

# Examples
local-memory validate mcp       # Validate MCP installation
local-memory validate config    # Validate configuration file syntax and structure
local-memory validate all       # Validate everything (default)
```

### validate_graph - Validate Knowledge Graph Integrity

Check for data integrity issues in the knowledge graph and optionally repair them. Defaults to dry-run. Also available as the aliases `validate-graph` and `check-integrity`.

```bash
local-memory validate_graph [flags]

# Examples
local-memory validate_graph
local-memory validate_graph --checks orphaned_reference,weight_inconsistency
local-memory validate_graph --auto_fix --dry_run=false
```
- `--checks strings`: Specific checks to run: orphaned_reference, relationship_cycle, weight_inconsistency, stale_question, promotion_chain_broken, duplicate_relationship
- `--auto_fix`: Apply automatic fixes for fixable issues
- `--dry_run`: Preview fixes without applying (default: true)
- `--domain string`: Filter validation to a specific domain
- `--session_id string`: Filter validation to a specific session
- `--batch_size int`: Batch size for processing large datasets (default: 1000)
- `--response_format string`: Format: detailed, concise, ids_only, summary (default: detailed)
- `--json`: Output in JSON format

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

Read and retrieve commands support multiple response formats via `--response_format`. Not every command exposes the full set — check `local-memory <command> --help` for the values a given command accepts.

- **detailed**: Full object information with all fields
- **concise**: Essential fields only (~70% size reduction)
- **ids_only**: Memory IDs only (~95% size reduction)
- **summary**: Truncated content (~50% size reduction)
- **custom**: Use with `--fields` for precise control
- **intelligent**: Auto-optimizes based on context
- **ultra**: Minimal essential information
- **micro**: Absolute minimal output

For machine-readable output suitable for scripting, use `--json` (available on nearly every command) rather than a response format value.

## Field Selection

Use `--fields` for precise output control:
```bash
local-memory search "query" --fields id,content,importance,tags
local-memory search "query" --response_format custom --fields id,importance
```

Available fields: `id`, `content`, `importance`, `tags`, `domain`, `created_at`, `updated_at`, `slug`
