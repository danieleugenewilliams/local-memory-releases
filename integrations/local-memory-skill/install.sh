#!/usr/bin/env bash
#
# Install the Local Memory agent skill into a skills directory that your agent reads.
#
# Usage:
#   ./install.sh [target] [--project]
#
# target (where to install):
#   agents   Vendor-neutral ~/.agents/skills  (Gemini CLI, Cursor, Copilot, ...) [default]
#   claude   ~/.claude/skills              (Claude Code / Claude Desktop)
#   codex    ~/.codex/skills              (OpenAI Codex)
#   all      Install into every directory above
#
# --project   Install into the current repo's ./.<target>/skills instead of $HOME,
#             so the skill is scoped to (and can be committed with) this project.
#
# This copies skills/local-memory. It does NOT install the MCP server itself
# (`npm install -g local-memory-mcp`) — see README.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills/local-memory"

TARGET="${1:-agents}"
SCOPE_DIR="$HOME"
for arg in "$@"; do
  if [ "$arg" = "--project" ]; then SCOPE_DIR="$(pwd)"; fi
done

if [ ! -d "$SRC" ]; then
  echo "error: skill source not found at $SRC" >&2
  exit 1
fi

install_to() {
  local base="$1"                      # e.g. .agents, .claude, .codex
  local dest="$SCOPE_DIR/$base/skills/local-memory"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -R "$SRC" "$dest"
  echo "installed -> $dest"
}

case "$TARGET" in
  agents) install_to ".agents" ;;
  claude) install_to ".claude" ;;
  codex)  install_to ".codex"  ;;
  all)    install_to ".agents"; install_to ".claude"; install_to ".codex" ;;
  --project) install_to ".agents" ;;   # bare `--project` -> default target
  *) echo "unknown target: $TARGET (use: agents | claude | codex | all)" >&2; exit 1 ;;
esac

echo "Done. Restart your agent (or run its reload command) to pick up the skill."
