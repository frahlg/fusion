# CLAUDE.md — Fusion

Project instructions for working on the **Fusion** skill. This file documents the repo for any agent
editing it. It is *not* a system prompt and is *not* installed into `~/.claude` — only `skills/fusion/` is
copied by `install.sh`. The skill is itself invocable as `/fusion`, so there's no separate command file.

## What this is

Fusion is a [Claude Code](https://claude.com/claude-code) skill that answers a hard question with a
**panel → judge** pipeline: the same prompt is dispatched to several frontier models *in parallel and
blind* (each with web search and bash, none seeing the others' work), and then Opus 4.8 judges every
answer into a structured analysis and writes one final answer grounded in it. The default panel is
**Opus 4.8 + GPT-5.5 (xhigh, via the `codex` CLI)**.

The mechanism is **independence, then synthesis** — diversity is harvested from independent runs, not
manufactured with assigned "lenses" or personas. Every panelist gets the user's task verbatim.

## Layout

```
install.sh                              # copies skill into ~/.claude (CLAUDE_CONFIG_DIR override)
skills/fusion/SKILL.md                  # orchestration: fan out -> judge -> grounded final answer
skills/fusion/references/panel.md       # independence / no-lenses doctrine
skills/fusion/references/judge_rubric.md# Track A (code: run both, merge) / Track B (research: 5 sections)
skills/fusion/references/fusion_identity.md  # the "Fusion" voice the final answer is written in
skills/fusion/scripts/detect_panel.sh   # detect the codex CLI, recommend the panel
skills/fusion/scripts/run_codex.sh      # run one GPT-5.5 (xhigh) panelist via codex exec
```

## Conventions

- **Opus 4.8 always judges and writes the final answer** — the pipeline can't be reversed (panelist models
  can't call back out to spawn Opus). The slug reads driver-first for that reason. `SKILL.md` pins
  `model: claude-opus-4-8` so the judging pass is Opus however `/fusion` was invoked.
- Reference bundled files with `${CLAUDE_SKILL_DIR}` (the official Claude Code substitution), never a
  hard-coded `~/.claude/...` path — the skill may be installed at personal, project, or plugin level.
- Panelists must stay **isolated**: never paste one panelist's output into another's prompt.
- `run_codex.sh` forces `-m gpt-5.5` (override `FUSION_CODEX_MODEL`), `model_reasoning_effort=xhigh`, and
  `web_search="live"`; the provider is still inherited from `~/.codex/config.toml`.
- The `fusion_identity.md` voice shapes *style*, never *substance*: the final answer must stay
  evidence-grounded and honest about disagreement and uncertainty. A grandiose voice that hides a real
  conflict defeats the whole point of a panel.
- This repo is plain Bash + Markdown. No build step. Keep scripts POSIX-bash, `set -uo pipefail`, and
  degrade gracefully when a CLI is missing (exit 127 → drop that panelist).

## Testing changes

- `bash -n skills/fusion/scripts/*.sh install.sh` for syntax; `shellcheck` if available.
- Dry-run install into a temp dir: `CLAUDE_CONFIG_DIR=$(mktemp -d) ./install.sh`.
- `bash skills/fusion/scripts/detect_panel.sh` should print a `SLUG=` line.
