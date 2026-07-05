# Local Memory — Agent Skill

A single [Agent Skill](https://agentskills.io) that teaches AI agents to use
[Local Memory](https://localmemory.co) well: capture insights, recall prior context,
and grow durable expertise across sessions — through whichever interface the agent has
(MCP tools, the `local-memory` CLI, or the REST API).

`SKILL.md` is an open standard read natively by Claude Code/Desktop, OpenAI Codex,
Gemini CLI, Cursor, GitHub Copilot/VS Code, and Windsurf. Author once, run everywhere.

## What's here

```
local-memory-skill/
├── .claude-plugin/plugin.json     # Claude Code plugin manifest (bundles MCP + skill)
├── .mcp.json                      # MCP server config (registers server as "local-memory")
├── skills/local-memory/
│   ├── SKILL.md                   # the skill: what/when, interface selection, core loop
│   └── reference/
│       ├── concepts.md            # World Memory model (levels, evolution, contradictions)
│       ├── mcp.md                 # every MCP tool + current params
│       ├── cli.md                 # CLI commands, flags, automation
│       ├── rest.md                # REST endpoints + curl
│       └── setup.md               # install, config, troubleshooting
├── install.sh                     # copy the skill into a skills dir
└── README.md
```

`skills/local-memory/` is the source of truth. The plugin wrapper and `install.sh` both
point at that one copy.

## Prerequisite

The skill teaches *usage*; you still need Local Memory installed and running:

```bash
npm install -g local-memory-mcp
local-memory setup
local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX --accept_terms
local-memory start
```

See `skills/local-memory/reference/setup.md` for details.

## Install the skill

### Claude Code — as a plugin (also wires up the MCP server)

Load this directory as a plugin so users get the skill **and** the MCP server in one step:

```bash
claude --plugin-dir ./local-memory-skill        # local test session
claude plugin validate ./local-memory-skill     # check the manifests
```

The bundled `.mcp.json` registers the server as `local-memory` by invoking
`local-memory --mcp` (expects the binary on `PATH`; edit the `command` to an absolute
path otherwise). For persistent installs, distribute via a plugin marketplace.

### Any other agent — copy the skill folder

```bash
./install.sh agents     # ~/.agents/skills (Gemini CLI, Cursor, Copilot, ...)
./install.sh claude     # ~/.claude/skills (Claude Code/Desktop, no plugin)
./install.sh codex      # ~/.codex/skills  (OpenAI Codex)
./install.sh all        # all of the above
./install.sh agents --project   # scope to ./.agents/skills in the current repo
```

Or copy `skills/local-memory/` by hand into the skills directory your agent scans.
`~/.agents/skills` is the vendor-neutral path read by the widest set of agents.

After installing, restart the agent (or run its reload command).

> **Aider** has no skill auto-discovery — load `skills/local-memory/SKILL.md` manually
> with `/read-only`.

## Notes

- **Server name.** Tool references assume the MCP server is registered as `local-memory`
  (tools appear as `local-memory:<tool>`). If you register it under another name, adjust
  the prefix and the `allowed-tools` list in `SKILL.md`.
- **`allowed-tools`** in `SKILL.md` pre-approves Local Memory's read/capture tools for
  Claude (other agents apply their own permission models); the destructive
  `delete_memory` is intentionally excluded.
- **Scope.** This skill replaces the *usage* prompts (the MCP/REST/CLI tabs) at
  localmemory.co/prompts. The OS installation walkthroughs there are out of scope.
