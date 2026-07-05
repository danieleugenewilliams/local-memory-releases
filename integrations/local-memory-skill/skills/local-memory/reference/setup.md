# Setup, configuration & troubleshooting

What an agent needs to get Local Memory running, point itself at the right service, and
recover when something is wrong. (Full OS-by-OS install walkthroughs with license keys
live on localmemory.co; this is the operational subset.)

## Is it running?

Always confirm reachability before relying on the store:

```bash
local-memory status                         # CLI
curl http://localhost:3002/api/v1/health    # REST -> {"data":{"status":"healthy"},...}
```

Via MCP, call `local-memory:status`. If the MCP tools aren't present at all, the server
isn't registered with this client — fall back to CLI or REST, or see "MCP not
connecting" below.

## Install / start

```bash
npm install -g local-memory-mcp     # install
local-memory setup                  # first-run wizard (or --silent / --interactive)
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept_terms   # required for commercial use
local-memory start                  # start daemon + REST API
local-memory doctor                 # verify everything
local-memory install mcp            # configure MCP for detected clients (claude-desktop, cursor, ...)
```

Manual install: download the binary from the releases page, put it on `PATH`, then
`local-memory setup`.

## Optional AI services

Some operations are AI-enhanced (`ask`, semantic `search` with `use_ai`, and
`predict`/`explain`/`counterfactual` with `use_ai=true`). These use a local model stack:

- **Ollama** (default `http://localhost:11434`) — embeddings `nomic-embed-text`,
  chat `qwen2.5:3b`. Auto-detected.
- **Qdrant** (default `http://localhost:6333`) — optional vector DB for faster/larger
  semantic search. Disabled by default; SQLite vector search works without it.

Core capture/retrieve works without these; AI features degrade gracefully if absent.

## Configuration

Config + data live in `~/.local-memory/` (Windows: `%USERPROFILE%\.local-memory\`). The
config loader creates it `0700` (owner-only); the `setup` wizard's location check creates
it `0755`. Because `mkdir -p` never re-modes an existing directory, the actual mode is set
by whichever runs first — often `0755` in practice. Key files: `config.yaml` (main
config), `unified-memories.db` (SQLite store), `daemon.log`, `qdrant-storage/`.

Precedence (highest first): `--config <path>` → `./local-memory/config.yaml` →
`./.local-memory/config.yaml` → `~/.local-memory/config.yaml`. YAML or JSON; any setting
can be overridden by a `MEMORY_`-prefixed env var.

Settings worth knowing:

```yaml
rest_api:   { enabled: true, auto_port: true, port: 3002, host: localhost }
ollama:     { enabled: true, auto_detect: true, embedding_model: nomic-embed-text, chat_model: "qwen2.5:3b" }
qdrant:     { enabled: false, url: "http://localhost:6333", vector_size: 768 }
mcp:        { enable_legacy_tools: false }   # set true only to re-expose deprecated tools
session:    { auto_generate: true, strategy: git-directory }
evolution:  { decay_enabled: false, decay_interval_hours: 24, decay_threshold_days: 30 }  # scheduled decay off by default
contradiction: { enabled: true, similarity_threshold: 0.85 }
```

Common env overrides:

```bash
export LOCAL_MEMORY_CONFIG_DIR="$HOME/.local-memory"
export MEMORY_REST_API_PORT="3002"
export MEMORY_OLLAMA_BASE_URL="http://localhost:11434"
export MEMORY_LICENSE_KEY="LM-XXXX-XXXX-XXXX-XXXX"
```

**Config changes require a daemon restart** (`local-memory stop && local-memory start`).
Core settings (DB path, license, service URLs) always need a full restart.

## Troubleshooting

| Symptom | Action |
|---------|--------|
| MCP tools absent | `local-memory install mcp`, then restart the MCP client. Until then use CLI/REST. |
| Service unreachable | `local-memory ps`; if down, `local-memory start`; then `local-memory doctor`. |
| Port 3002 in use | Daemon auto-selects 3002–3005; check `local-memory status` for the actual port. |
| AI features failing | `local-memory doctor` to check Ollama/Qdrant; AI is optional. |
| License rejected | Watch for em/en-dashes (—/–) pasted instead of hyphens (-); re-activate. |
| Permission errors | `chmod 700 ~/.local-memory`. |
| Stuck processes | `local-memory kill_all`, then `local-memory start`. |
| Inspect logs | `tail -f ~/.local-memory/daemon.log`. |

## MCP server name

This skill assumes the MCP server is registered as **`local-memory`**, so tools appear
as `local-memory:<tool>` / `mcp__local-memory__<tool>`. If it was registered under a
different name (e.g. `local-memory-latest`), the tool prefix and the `allowed-tools` in
`SKILL.md` change accordingly. The bundled `.mcp.json` registers it as `local-memory`.
