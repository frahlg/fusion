#!/usr/bin/env bash
# run_codex.sh — run one GPT-5.5 (xhigh) panelist via codex on a prompt, with web search + bash.
#
# Usage:
#   run_codex.sh <prompt_file> <output_file> [reasoning_effort]
#
# - <prompt_file>    : path to a file containing the FULL panelist prompt (verbatim user task + brief instruction)
# - <output_file>    : where the panelist's final answer is written (clean, just the answer)
# - reasoning_effort : minimal | low | medium | high | xhigh   (default: xhigh; xhigh is model-dependent)
#
# Behavior / knobs:
# - We force the model to gpt-5.5 by default so the GPT panelist really is GPT-5.5 regardless of the user's
#   codex config. Override deliberately with FUSION_CODEX_MODEL. The provider is still inherited from
#   ~/.codex/config.toml.
# - `web_search="live"` enables live web search (the documented codex key; older builds may fall back to
#   cached search — note that in the audit trail if observed).
# - `-o/--output-last-message` writes ONLY the agent's final message — no streaming noise to parse.
# - `-s workspace-write` lets the panelist run shell commands; `--cd <scratch>` keeps its primary writes in a
#   throwaway dir, never your repo. (codex's workspace-write sandbox still permits writes under /tmp/$TMPDIR.)
# - Optional wall-clock cap via FUSION_CODEX_TIMEOUT (seconds, default 900) when `timeout`/`gtimeout` exists.
# - Exit 127 means codex isn't installed; any other non-zero is a runtime failure. Either way the orchestrator
#   drops this panelist and replaces/downgrades the panel.

set -uo pipefail

prompt_file="${1:?usage: run_codex.sh <prompt_file> <output_file> [reasoning_effort]}"
output_file="${2:?usage: run_codex.sh <prompt_file> <output_file> [reasoning_effort]}"
effort="${3:-xhigh}"
model="${FUSION_CODEX_MODEL:-gpt-5.5}"

if ! command -v codex >/dev/null 2>&1; then
  echo "[run_codex.sh] codex CLI not installed — skip this panelist." >&2
  exit 127
fi

# Start from a clean output file so a stale prior result can't be mistaken for this run's answer.
: > "$output_file" || { echo "[run_codex.sh] cannot write $output_file" >&2; exit 1; }

scratch="$(mktemp -d "${TMPDIR:-/tmp}/fusion-codex.XXXXXX")"
trap 'rm -rf "$scratch"' EXIT

# Optional wall-clock cap; degrade to no cap when no timeout binary is available (e.g. stock macOS).
to=""
if   command -v timeout  >/dev/null 2>&1; then to="timeout ${FUSION_CODEX_TIMEOUT:-900}"
elif command -v gtimeout >/dev/null 2>&1; then to="gtimeout ${FUSION_CODEX_TIMEOUT:-900}"
fi

# shellcheck disable=SC2086  # $to is an intentional optional command prefix
$to codex exec \
  --skip-git-repo-check \
  --cd "$scratch" \
  -s workspace-write \
  -m "$model" \
  -c 'web_search="live"' \
  -c "model_reasoning_effort=$effort" \
  -o "$output_file" \
  - < "$prompt_file" \
  > "$scratch/stream.log" 2>&1
status=$?

if [ "$status" -ne 0 ] || [ ! -s "$output_file" ]; then
  echo "[run_codex.sh] codex exited $status; tail of log:" >&2
  tail -30 "$scratch/stream.log" >&2
  exit 1
fi
echo "[run_codex.sh] ok -> $output_file (model=$model, effort=$effort)"
