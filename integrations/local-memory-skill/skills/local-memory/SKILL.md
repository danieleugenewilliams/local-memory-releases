---
name: local-memory
description: >-
  Persistent knowledge system for AI agents. Use proactively to build expertise
  across sessions: capture insights, decisions, bug fixes, and patterns; recall
  what was learned before answering ("what do we already know about X", "have we
  seen this before", "remember this"); detect contradictions and track open
  questions. Works through Local Memory's MCP tools, CLI (`local-memory`), or
  REST API (localhost:3002). Trigger whenever durable knowledge should be stored
  or retrieved rather than re-derived.
allowed-tools: >-
  mcp__local-memory__bootstrap mcp__local-memory__search mcp__local-memory__ask
  mcp__local-memory__summarize mcp__local-memory__observe mcp__local-memory__reflect
  mcp__local-memory__evolve mcp__local-memory__question mcp__local-memory__questions
  mcp__local-memory__resolve mcp__local-memory__relate mcp__local-memory__find_related
  mcp__local-memory__discover mcp__local-memory__map_graph mcp__local-memory__status
  mcp__local-memory__predict mcp__local-memory__explain mcp__local-memory__counterfactual
  mcp__local-memory__temporal mcp__local-memory__get_memory_by_id
  mcp__local-memory__update_memory mcp__local-memory__validate
  mcp__local-memory__migrate_domain
  Bash(local-memory:*)
---

# Local Memory

Local Memory is a persistent, local-first knowledge layer. It is not a file store —
it turns raw **observations** into **learnings**, then **patterns**, then
**schemas**, so an agent accumulates durable expertise instead of re-deriving it
every session.

Use it proactively. Storing and recalling knowledge is cheap; re-discovering it is
not.

## Pick the interface (do this first)

The same operations are available three ways. Use whichever the environment offers,
in this order of preference:

1. **MCP tools** — if tools named `local-memory:*` are available, use them. Lowest
   overhead, structured results. (This skill pre-approves the read/capture tools.)
2. **CLI** — if you can run shell commands, use the `local-memory` binary.
3. **REST API** — if you can only make HTTP calls, use `http://localhost:3002/api/v1`.

> Tool names below assume the MCP server is registered as **`local-memory`** (so a
> tool is `local-memory:search`). If it was registered under another name, substitute
> that prefix.

Confirm the service is reachable before relying on it: call `local-memory:status`
(MCP), run `local-memory status` (CLI), or `curl http://localhost:3002/api/v1/health`
(REST). If unreachable, see [reference/setup.md](reference/setup.md).

## The core loop

```
bootstrap  →  search/ask (before answering)  →  observe (as you learn)
           →  reflect (synthesize)  →  evolve (validate & promote)
```

1. **Orient at session start.** Call `bootstrap` once to load relevant patterns,
   recent learnings, and pending questions. It returns `memory_stats` and highlights —
   read them before deciding what to do.
2. **Recall before answering.** Before answering a non-trivial question or making a
   decision, `search` for prior knowledge (or `ask` for a synthesized answer). Don't
   re-derive what's already stored.
3. **Capture as you learn.** When something worth keeping emerges, `observe` it.
   Capture *why*, not just *what* — context, root cause, the decision and its
   rationale. Tag consistently and set a `domain`.
4. **Synthesize.** Periodically (or at session end) `reflect` to turn observations
   (L0) into learnings (L1).
5. **Mature knowledge.** When a learning proves correct, `evolve(operation="validate",
   success=true)` to strengthen it; promotion to pattern/schema follows from repeated
   validation.

## What is worth storing

- Architecture decisions and the rationale behind them
- Bug fixes and their root causes (not just the symptom)
- Approaches that worked — and ones that didn't, with why
- User/project preferences, constraints, and conventions
- Non-obvious facts that took effort to establish

Skip ephemera that the repo, git history, or the current conversation already records.

## Habits that make it work

- **Specific beats vague.** "Postgres connection pool exhaustion under N+1 query in
  the report job; fixed by eager-loading X" — not "fixed a DB bug."
- **Tag and domain consistently** so retrieval works later.
- **Search cross-session** (`session_filter_mode: "all"`) unless you deliberately want
  only the current session.
- **Track unknowns.** When you hit something you can't resolve, `question(...)` it.
  When you later learn the answer, `resolve(...)` it.
- **Surface contradictions** instead of silently overwriting. Let `resolve` / `evolve`
  reconcile conflicting knowledge so history stays traceable. Prefer `evolve`/`update`
  over `delete` — deletion loses the trail.

## Knowledge levels (brief)

| Level | Name | Weight | Meaning |
|-------|------|--------|---------|
| L0 | Observation | 0.0–1.0 | Raw intake, ephemeral |
| L1 | Learning | 1.0–5.0 | Candidate insight |
| L2 | Pattern | 5.0–9.0 | Validated generalization |
| L3 | Schema | 9.0–10.0 | Durable framework |

Full model — promotion thresholds, decay, contradictions, relationships — is in
[reference/concepts.md](reference/concepts.md).

## Reference (load as needed)

- [reference/concepts.md](reference/concepts.md) — the World Memory model: levels,
  evolution, contradictions, questions, relationship types, maintenance.
- [reference/mcp.md](reference/mcp.md) — every MCP tool with current parameters and
  examples.
- [reference/cli.md](reference/cli.md) — `local-memory` commands and flags, plus
  automation patterns (git hooks, cron).
- [reference/rest.md](reference/rest.md) — REST endpoints, request shapes, and curl
  examples.
- [reference/setup.md](reference/setup.md) — install, configuration, service
  management, and troubleshooting.

## Token discipline

Read operations accept a `response_format` (`detailed` / `concise` / `summary` /
`ids_only`); `search` also has an `intelligent` format with a `max_tokens` budget.
Default to `concise` and widen only when you need full content. See the reference
files for per-tool specifics.
