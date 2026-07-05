# CLI reference

Use the `local-memory` binary when you can run shell commands but don't have the MCP
tools. Same operations as MCP, exposed as subcommands. Most commands accept `--json`
for machine-readable output; the read/retrieve commands (e.g. `search`, `get`,
`analyze`) also accept `--response_format` to control verbosity. Many reasoning and
lifecycle commands take their main inputs as **positional arguments**, not flags —
check `local-memory <command> --help` for the exact signature.

```bash
local-memory --help                 # all commands
local-memory <command> --help       # flags for one command
local-memory search --help_parameters --show_all   # progressive parameter discovery
```

## Service management

```bash
local-memory start      # start daemon + REST API (port 3002)
local-memory stop       # stop daemon
local-memory status     # health, counts by level, domains, relationships, questions
local-memory ps         # list running processes
local-memory doctor     # comprehensive system + service check
```

## Capture

```bash
# Record an observation (L0 by default)
local-memory observe "API returns 500s under load" --level observation --tags api,errors --domain backend

# Store a learning directly
local-memory observe "Circuit breaker prevents cascading failures" \
  --level learning --weight 6.0 --tags architecture,resilience

# Track a knowledge gap
local-memory question "How does Redis handle persistence under high write load?" \
  --question_type epistemic_gap --priority 7
```

`observe` flags: `--level` (observation|learning|pattern|schema), `--weight`,
`--tags`, `--domain`, `--source`, `--context`, `--auto_promote`, `--session_id`.

## Retrieve

```bash
local-memory search "concurrency patterns" --use_ai --limit 5
local-memory search "python" --domain programming --tags web,scripting
local-memory search "patterns" --start_date 2025-01-01 --end_date 2025-12-31
local-memory get <memory-id>

# AI analysis (Q&A / summarize / analyze / temporal)
local-memory analyze "Differences between supervised and unsupervised learning?" --type question
local-memory analyze --type summarize --timeframe month --limit 50
local-memory analyze --type temporal_patterns --concept "deep learning" --temporal_timeframe quarter
```

Key `search` flags: `--use_ai`, `--limit`, `--tags`, `--domain`, `--search_type`
(semantic|tags|date_range|hybrid), `--session_filter_mode` (all|session_only|
session_and_shared), `--start_date`/`--end_date`, `--fields` (custom field selection),
`--response_format` (detailed|concise|ids_only|summary|custom|intelligent|ultra|micro).

## Synthesize & mature

```bash
# `reflect` takes the mode as a positional arg (single | batch | auto)
local-memory reflect batch --batch_size 10
local-memory reflect single --observation_id <uuid>

# `evolve` takes the operation as a positional arg (validate | promote | decay | accommodate)
local-memory evolve validate --entity_id <uuid> --success true
local-memory evolve promote  --entity_id <uuid>
local-memory evolve decay    --threshold_days 30 --dry_run

# resolve takes question_id, resolution_type, and rationale as positional args
local-memory resolve <question-id> a_supersedes "Newer info supersedes the older note"
```

## Graph & relationships

```bash
local-memory relate <source-id> <target-id> --type causes --strength 0.9 --confirm
local-memory find_related <memory-id> --limit 10 --min_strength 0.5
local-memory discover --limit 20 --min_strength 0.7
local-memory map_graph <memory-id> --depth 3
```

> Note: the CLI `relate` default `--strength` is **0.8** (the MCP `relate` default is 0.5).

## Reasoning

```bash
# predict/explain/counterfactual take their states as positional args
local-memory predict "API receives high traffic" --use_ai
local-memory explain "test passed locally" "deployment failed" --use_ai
local-memory counterfactual "deployment failed" "we had run integration tests"
```

## Maintenance & admin

```bash
local-memory validate_graph --checks orphaned_reference,weight_inconsistency --dry_run
local-memory update <memory-id> --content "Corrected content" --importance 9
local-memory forget <memory-id> --confirm          # permanent delete — use sparingly
local-memory migrate_domain --from old --to new --dry_run
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept_terms
local-memory install mcp                            # configure MCP for detected clients
```

## Response formats

`detailed` (full) · `concise` (~70% smaller) · `summary` (~50%) · `ids_only` (~95%) ·
`custom` (with `--fields`) · `intelligent`/`ultra`/`micro` (progressively minimal).
Available fields for `--fields`: `id, content, importance, tags, domain, created_at,
updated_at, slug`.

## Automation patterns

```bash
# Parse JSON output (--json emits the machine-readable envelope)
local-memory search "api" --json | jq '.data.results[].memory.content'

# Post-commit git hook (.git/hooks/post-commit)
#!/bin/bash
local-memory observe "Committed: $(git log -1 --oneline)" --level observation --tags git

# Daily reflection via cron
0 18 * * *  local-memory reflect batch
```
