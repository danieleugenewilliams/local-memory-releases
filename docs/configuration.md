# Configuration Guide

Local Memory provides a comprehensive configuration system that supports YAML and JSON formats with intelligent defaults and auto-detection capabilities. This guide covers all configuration options, file structures, and environment variables.

## Configuration Directory Structure

Local Memory creates and manages a dedicated configuration directory for all application data, configuration files, and runtime artifacts.

### Default Locations
- **macOS**: `~/.local-memory/`
- **Linux**: `~/.local-memory/`
- **Windows**: `%USERPROFILE%\.local-memory\`

### Directory Contents
```
~/.local-memory/
├── config.yaml              # Main configuration file (YAML format, auto-generated)
├── unified-memories.db       # SQLite database for memory storage
├── license.json             # License key and terms acceptance data
├── daemon.log               # Runtime log file for daemon processes
├── local-memory.pid         # Process ID file for running daemon
├── logs/                    # Directory for log files (when file logging is enabled)
├── qdrant-storage/          # Qdrant vector database storage (when enabled)
└── storage/                 # Additional storage for embeddings and metadata
```

**Security**: The config loader creates the directory with owner-only access (`0700`). Note that the `setup` wizard's location check creates it with `0755` instead. Because `mkdir -p` never re-modes an existing directory, the actual permissions are set by whichever code path runs first — often `0755` in practice. To enforce owner-only access, run `chmod 700 ~/.local-memory`.

## Configuration File Hierarchy

Local Memory supports multiple configuration sources with hierarchical precedence:

1. **Command-line flags**: `--config /path/to/config.yaml`
2. **Current directory**: `./local-memory/config.yaml`
3. **Project directory**: `./.local-memory/config.yaml`
4. **User default**: `~/.local-memory/config.yaml`

### Supported Formats
- **YAML** (preferred): `config.yaml`
- **JSON**: `config.json`
- **Environment Variables**: All settings can be overridden with `MEMORY_` prefixed variables

## Core Configuration Sections

### Database Configuration

Local Memory uses SQLite as the primary database with support for automatic migrations, backup scheduling, and connection pooling.

```yaml
database:
  path: "~/.local-memory/unified-memories.db"  # Database file location
  backup_interval: "24h"                       # Automatic backup frequency
  max_backups: 7                               # Maximum backup files to retain
  auto_migrate: true                           # Enable automatic schema migrations
```

**Database Features:**
- **Unified Storage**: Single database file containing all memory data
- **Automatic Backups**: Configurable backup intervals with retention limits
- **Migration Support**: Automatic schema updates on version changes
- **Connection Pooling**: Optimized for concurrent access patterns

### Logging Configuration

Comprehensive logging with configurable output formats and destinations:

```yaml
logging:
  level: "info"                                # debug, info, warn, error
  format: "console"                            # console, json, simple
  enable_file_logging: false                   # Enable log file output
  log_directory: "~/.local-memory/logs"        # Log file directory
  max_log_files: 10                            # Maximum log files to retain
  max_log_size: 10485760                       # Maximum size per log file (10MB)
```

**Log Output Formats:**
- **console**: Human-readable colored output for terminal use
- **json**: Structured JSON format for log aggregation systems
- **simple**: Minimal format for embedded or constrained environments

**Log File Management:**
- **Rotation**: Automatic log rotation based on size limits
- **Retention**: Configurable number of historical log files
- **Directory**: Logs stored in dedicated `logs/` subdirectory
- **Naming**: Timestamped files with automatic cleanup

### License Configuration

Local Memory includes license management for commercial features and terms acceptance tracking:

```yaml
license:
  required: true                               # Whether license is required
  key: "LM-XXXX-XXXX-XXXX-XXXX"               # License key (if activated)
  storage_path: "~/.local-memory/license.json" # License data storage location
  check_on_startup: true                       # Validate license on application start
  terms:
    required: true                             # Terms acceptance required
    source: "embedded"                         # "embedded", "remote", or file path
    url: "https://www.localmemory.co/terms/"   # Remote terms URL
    timeout: "10s"                             # HTTP timeout for remote fetch
```

**License File Format (`license.json`):**
```json
{
  "key": "LM-XXXX-XXXX-XXXX-XXXX-XXXX",
  "validated_at": "2025-11-07T16:00:58.942742-05:00",
  "version": "2.0",
  "status": "valid",
  "terms_accepted": true,
  "terms_accepted_at": "2025-11-07T16:00:58.942742-05:00",
  "terms_version": "1.0"
}
```

## Service Integration

### AI Services Configuration

#### Ollama Configuration
```yaml
ollama:
  enabled: true                                # Enable Ollama integration
  auto_detect: true                            # Auto-detect Ollama service availability
  base_url: "http://localhost:11434"           # Ollama API endpoint
  embedding_model: "nomic-embed-text"          # Model for text embeddings
  chat_model: "qwen2.5:3b"                     # Model for chat/completion
  timeout: "30s"                               # Request timeout
  retries: 3                                   # Retry attempts for failed requests
```

#### Qdrant Configuration
```yaml
qdrant:
  enabled: false                               # Enable Qdrant vector database
  auto_detect: true                            # Auto-detect Qdrant service availability
  url: "http://localhost:6333"                 # Qdrant API endpoint
  api_key: ""                                  # API key for authenticated access
  collection: "memory_embeddings"              # Vector collection name
  timeout: "30s"                               # Request timeout (raised for large collections)
  max_retries: 3                               # Retry attempts
  vector_size: 768                             # Embedding vector dimensions
  distance: "Cosine"                           # Similarity distance metric
```

**Qdrant is optional and disabled by default.** Local Memory does **not** launch Qdrant for you — you must run it separately (and set `enabled: true`). At daemon startup Local Memory only *detects* Qdrant by probing `http://localhost:6333`. If Qdrant is disabled or unreachable, semantic search falls back to the built-in SQLite vector search, so core capture and retrieval keep working without it.

### REST API Configuration

```yaml
rest_api:
  enabled: true                                # Enable REST API server
  auto_port: true                              # Auto-select available port
  port: 3002                                   # API server port
  host: "localhost"                            # Bind address
  cors: true                                   # Enable CORS for web clients
  rate_limit: true                             # Enable request rate limiting
  max_request_size: "10mb"                     # Maximum request body size
  tls:
    enabled: false                             # Enable HTTPS/TLS
    cert_file: ""                              # TLS certificate file path
    key_file: ""                               # TLS private key file path
```

### MCP Configuration

Model Context Protocol integration with configurable tool sets:

```yaml
mcp:
  enable_legacy_tools: false                   # Enable deprecated individual tools
```

## Session Management

Local Memory supports session-based organization for grouping related memories and operations:

```yaml
session:
  auto_generate: true                          # Auto-generate session IDs
  strategy: "git-directory"                    # Session ID generation strategy
  custom_id: ""                                # Custom session ID (when auto_generate=false)
```

**Session Strategies:**
- `git`: Uses current git branch name
- `directory`: Uses current working directory hash
- `git-directory`: Combines git branch and directory information
- `uuid`: Generates random UUID
- `custom`: Uses explicitly configured custom ID

## Memory Evolution & Contradiction Detection

Local Memory can promote frequently validated memories into higher-confidence learnings, decay stale ones, and flag contradictions between stored memories.

### Evolution Configuration
```yaml
evolution:
  validation_success_delta: 0.2                # Weight increase on successful validation
  validation_failure_delta: 0.1               # Weight decrease on failed validation
  decay_factor: 0.9                            # Weight multiplier applied during decay
  archival_threshold: 0.5                      # Archive memories below this weight
  l1_to_l2_validations: 3                      # Validations required for L1 -> L2 promotion
  l1_to_l2_min_weight: 5.0                     # Minimum weight for L1 -> L2 promotion
  l1_to_l2_min_confidence: 0.80                # Minimum confidence for L1 -> L2 promotion
  l2_to_l3_validations: 5                      # Validations required for L2 -> L3 promotion
  l2_to_l3_min_weight: 9.0                     # Minimum weight for L2 -> L3 promotion
  l2_to_l3_min_confidence: 0.90                # Minimum confidence for L2 -> L3 promotion
  decay_enabled: false                         # Scheduled decay is OFF by default
  decay_interval_hours: 24                     # How often decay runs (when enabled)
  decay_threshold_days: 30                     # Decay memories unused for this many days
```

**Promotion tiers:** memories start at L1. Reaching 3 validations with weight >= 5.0 and confidence >= 0.80 promotes L1 -> L2; reaching 5 validations with weight >= 9.0 and confidence >= 0.90 promotes L2 -> L3.

**Scheduled decay is disabled by default** (`decay_enabled: false`). When enabled, decay runs every `decay_interval_hours` and reduces the weight of memories unused for longer than `decay_threshold_days`.

### Contradiction Configuration
```yaml
contradiction:
  enabled: true                                # Contradiction detection enabled by default
  similarity_threshold: 0.85                   # High similarity required to compare two memories
```

## Performance & Security

### Performance Configuration
```yaml
performance:
  enable_metrics: false                        # Enable performance metrics collection
  cache_size: 1000                             # Memory cache size
  batch_size: 100                              # Batch processing size
  pool_size: 10                                # Connection pool size
```

### Security Configuration
```yaml
security:
  max_content_length: 50000                    # Maximum memory content length
  max_tags_per_memory: 20                      # Maximum tags per memory
  max_tag_length: 100                          # Maximum tag length
  rate_limit_requests: 1000                    # Rate limit request count
  rate_limit_window: "1m"                      # Rate limit time window
```

## Environment Variables

All configuration settings can be overridden using environment variables with the `MEMORY_` prefix:

### Core Settings
- `MEMORY_PROFILE` - Configuration profile selection
- `MEMORY_DB_PATH` - Database file location
- `MEMORY_LOGGING_LEVEL` - Logging verbosity level (the bare `LOG_LEVEL` also works)
- `MEMORY_LICENSE_KEY` - License key for activation

### Service Settings
- `MEMORY_REST_API_PORT` - REST API port number
- `MEMORY_OLLAMA_BASE_URL` - Ollama service URL
- `MEMORY_QDRANT_URL` - Qdrant service URL

### Example Environment Setup
```bash
# Configuration directory
export LOCAL_MEMORY_CONFIG_DIR="$HOME/.local-memory"

# Service configuration
export MEMORY_REST_API_PORT="3002"
export MEMORY_LOGGING_LEVEL="info"
export MEMORY_OLLAMA_BASE_URL="http://localhost:11434"

# Security settings
export MEMORY_LICENSE_KEY="LM-XXXX-XXXX-XXXX-XXXX"
```

## Auto-Configuration Features

Local Memory provides intelligent defaults and auto-detection:

- **Zero-Config Defaults**: Works out-of-the-box with sensible defaults
- **Auto-Detection**: Automatically detects available services (Ollama, Qdrant)
- **Port Auto-Selection**: Finds available ports when default ports are in use
- **First-Run Setup**: Interactive wizard for initial configuration

## Configuration Profiles

Local Memory supports multiple configuration profiles for different environments:

### Development Profile
```yaml
# config-dev.yaml
logging:
  level: "debug"
  enable_file_logging: true
rest_api:
  cors: true
performance:
  enable_metrics: true
```

### Production Profile
```yaml
# config-prod.yaml
logging:
  level: "warn"
  format: "json"
  enable_file_logging: true
rest_api:
  cors: false
  rate_limit: true
  tls:
    enabled: true
security:
  rate_limit_requests: 500
```

### Usage
```bash
# Use specific profile
local-memory start --config config-dev.yaml

# Environment variable
export MEMORY_PROFILE="development"
local-memory start
```

## Configuration Validation

### Setup Wizard
```bash
# First-run setup (auto-detects services)
local-memory setup

# Interactive setup wizard
local-memory setup --interactive

# Validate existing configuration
local-memory validate
```

### Diagnostics
```bash
# Comprehensive system check
local-memory doctor

# Run doctor with a custom config file
local-memory doctor --config /path/to/config.yaml

# Machine-readable diagnostics
local-memory doctor --json
```

`doctor` already checks service connectivity (Ollama, Qdrant, REST API) as part of its standard run.

## Advanced Configuration

### Custom Configuration Paths

```bash
# Use custom configuration file
local-memory start --config /path/to/custom-config.yaml

# Use custom configuration directory
export LOCAL_MEMORY_CONFIG_DIR="/custom/path"
local-memory start
```

### Setup Options

Local Memory provides flexible setup options:

```bash
# Run interactive setup wizard
local-memory setup --interactive

# Run silent setup with defaults
local-memory setup --silent

# Show dependency status and installation instructions
local-memory setup --show_deps

# Save setup results to JSON file
local-memory setup --output setup-results.json
```

### Configuration Changes

**Note**: Configuration changes require restarting the daemon to take effect:

```bash
# Stop the daemon
local-memory stop

# Start with new configuration
local-memory start
```

Critical settings like database path, license configuration, and core service URLs always require a full restart.

## Troubleshooting Configuration

### Common Issues

1. **Configuration File Not Found**
   ```bash
   # Inspect configuration and search paths
   local-memory doctor

   # Regenerate configuration with defaults
   local-memory setup --silent
   ```

2. **Permission Issues**
   ```bash
   # Fix directory permissions
   chmod 700 ~/.local-memory

   # Re-run setup to recreate the configuration directory
   local-memory setup
   ```

3. **Service Connection Issues**
   ```bash
   # Check service connectivity (Ollama, Qdrant, REST API)
   local-memory doctor
   ```

### Configuration Debugging

```bash
# Configuration validation is handled through:
local-memory doctor
local-memory validate

# Run doctor with custom config file
local-memory doctor --config /path/to/config.yaml
```

For more detailed configuration examples and advanced setups, see the platform-specific guides and integration documentation.