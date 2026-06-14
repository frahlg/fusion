#!/usr/bin/env bash
# detect_panel.sh — figure out which panelist CLIs are installed and recommend a Fusion panel.
#
# Fusion fans a prompt out to a panel of models in parallel, then Opus 4.8 judges and writes the final
# answer. Opus 4.8 is always available as a panelist via the Agent tool (in-process subagents) and is
# always the judge — so it never needs a CLI check. This script only probes the *external* panelist CLI
# (GPT-5.5 via codex) and prints the richest panel the machine can currently support.
#
# Note: this checks that codex is INSTALLED and looks usable (supports --output-last-message). It does NOT
# verify auth or that the configured provider is reachable — if codex fails at runtime anyway, the
# orchestrator's fallback (a second independent Opus run) keeps the panel intact. See SKILL.md, Step 1.
#
# Output: human-readable lines + a final `SLUG=...` line the orchestrator can grep.

have() { command -v "$1" >/dev/null 2>&1; }

codex_ok=false
if have codex && codex exec --help 2>/dev/null | grep -q -- '--output-last-message'; then
  codex_ok=true
fi

echo "panelist availability (Opus 4.8 is always a panelist + the judge, via Agent subagents):"
echo "  opus4.8       : yes (Agent subagents — always available)"
printf "  gpt5.5 (xhigh): %s (codex CLI present + usable; auth/provider verified at runtime)\n" \
  "$([ "$codex_ok" = true ] && echo yes || echo NO)"
echo

# Default panel is Opus 4.8 + GPT-5.5 (xhigh). If codex is missing/unusable, fall back to two independent
# Opus runs so the skill never hard-fails. (A future revision could add a third CLI panelist here.)
if $codex_ok; then slug="opus4.8-gpt5.5"
else               slug="opus4.8-4.8"
fi

echo "recommended panel: $slug"
echo "SLUG=$slug"
