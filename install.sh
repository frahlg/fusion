#!/usr/bin/env bash
# install.sh — install the Fusion skill into your Claude Code config.
#
# Copies:
#   skills/fusion -> $CLAUDE_DIR/skills/fusion
# where CLAUDE_DIR defaults to ~/.claude (override with CLAUDE_CONFIG_DIR).
#
# The skill is itself invocable as /fusion, so no separate command file is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

mkdir -p "$CLAUDE_DIR/skills"

rm -rf "$CLAUDE_DIR/skills/fusion"
cp -R "$HERE/skills/fusion" "$CLAUDE_DIR/skills/fusion"
chmod +x "$CLAUDE_DIR/skills/fusion/scripts/"*.sh

echo "✓ Installed Fusion into $CLAUDE_DIR"
echo "    skill   : $CLAUDE_DIR/skills/fusion"
echo "    invoke  : /fusion  (or just ask to 'run it through Fusion')"
echo

# Report which panels are usable on this machine.
have() { command -v "$1" >/dev/null 2>&1; }
echo "Panel availability here:"
echo "  opus4.8-4.8     : ready (two independent Opus 4.8 runs, judged by Opus — no external CLI)"
if have codex; then
  echo "  opus4.8-gpt5.5  : ready (codex found: $(codex --version 2>/dev/null | head -1))"
else
  echo "  opus4.8-gpt5.5  : needs the 'codex' CLI (install + log in for the GPT-5.5 xhigh panelist)"
fi
echo
echo "Next: restart Claude Code (or run /reload-skills) so the 'fusion' skill and /fusion command load."
