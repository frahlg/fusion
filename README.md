# Fusion

[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](LICENSE)
[![Claude Code skill](https://img.shields.io/badge/Claude%20Code-skill-d97757)](https://claude.com/claude-code)
[![Panel](https://img.shields.io/badge/panel-Opus%204.8%20%2B%20GPT--5.5-blue)](#the-panels)
[![Answer](https://img.shields.io/badge/answer-42-9cf)](#the-panels)

**Stop trusting one model. Convene a panel.**

Fusion is a [Claude Code](https://claude.com/claude-code) skill for questions where a single model answer is
too cheap to trust. It runs your hardest prompt through a **panel → judge** pipeline: several frontier models
answer *in parallel and blind*, then Opus 4.8 judges every answer and forges one you can actually trust — with
the full audit trail underneath.

> *Deep Thought ran for 7½ million years and returned a single number. Fusion runs a panel of frontier models
> and returns one grounded answer — plus the receipts.*

**The counterintuitive part:** you don't need *different* models to beat one model. Even two cold runs of the
*same* model diverge — different reasoning paths, different searches, different mistakes — and synthesizing
that divergence beats running it once. Fusion harvests that diversity instead of faking it with personas or
"lenses".

```
                      ┌──────────────┐
                 ┌──▶ │  panelist 1  │ ─┐   (web + bash, independent)
                 │    │  Opus 4.8    │  │
 prompt ──▶ fan ─┤    └──────────────┘  ├─▶ ┌──────────────┐
            out  │    ┌──────────────┐  │   │   Opus 4.8   │ ──▶ Fusion's
                 └──▶ │  panelist 2  │ ─┘   │  (judge +    │     final answer
                      │  GPT-5.5     │      │  synthesize) │   (grounded in
                      │  (xhigh)     │      └──────────────┘    the analysis)
                      └──────────────┘
              each answers blind          consensus · contradictions ·
                                          partial · unique · blind spots
```

Many great minds computing toward one answer — except this answer ships with receipts, disagreement, and its
own confidence boundaries. Opus 4.8 **always** judges and writes the final answer; the pipeline can't be
reversed, because the panelist models can't call back out to spawn Opus.

## What an answer looks like

Fusion always leads with the verdict, then shows its work (illustrative):

```text
> /fusion Single MQTT broker or a quorum for our edge control loop?

Run the quorum. Every independent line of reasoning converged here: a single
broker is a single point of failure your control loop can't survive, and the
latency cost of consensus stays inside your 200 ms budget. One real caveat — no
panelist could verify failover time under network partition, so prove that on
your hardware before you trust it in production.

──────────────────────────────────────────────────────────────
Panel: opus4.8-gpt5.5 — Opus 4.8 ✓  ·  GPT-5.5 (xhigh) ✓
Consensus      · quorum for availability; latency fits the 200 ms budget
Contradictions · broker count (3 vs 5) — adjudicated to 3 on the cited benchmark
Unique insight · GPT-5.5 flagged split-brain on even-sized clusters
Blind spots    · failover-under-partition timing unverified by either panelist
```

The verdict you can read in ten seconds. The audit trail is there for when being wrong is expensive.

## The panels

| Slug | Panel | Requires |
| --- | --- | --- |
| `opus4.8-gpt5.5` | Opus 4.8 + **GPT-5.5 (xhigh)** in parallel → Opus judges | the `codex` CLI |
| `opus4.8-4.8` | the **same prompt run twice** as 2 independent Opus 4.8 panelists → Opus judges | nothing — works everywhere (fallback) |

The skill auto-detects whether the `codex` CLI is installed and usable, and falls back gracefully to the
pure-Opus panel when it isn't. The default is **Opus 4.8 + GPT-5.5 (xhigh)**.

*Two independent minds in; one answer out. Deep Thought only had the one.*

## When to use it

Reach for Fusion when one model being **confidently wrong** would cost you more than an extra model pass:

- architecture and design calls
- high-stakes research
- gnarly / incident debugging
- vendor or framework decisions
- claims that need sources, commands, or cross-checking

Skip it for the easy stuff — Fusion is deliberately slower and more expensive than one model.

## Install

```bash
git clone https://github.com/frahlg/fusion.git
cd fusion
./install.sh
```

This copies the skill to `~/.claude/skills/fusion` and prints which panels your machine can run. The skill is
itself invocable as `/fusion`, so no separate command file is needed. Restart Claude Code (or run
`/reload-skills`) afterward.

> Override the target with `CLAUDE_CONFIG_DIR=/path/to/.claude ./install.sh`.

## Use

Run one hard prompt:

```
/fusion Should we run our edge control loop on a single MQTT broker or a quorum?
```

…or just ask in prose to "run it through Fusion" / "ask the panel". Fusion returns the final answer first,
then the audit trail (Consensus / Contradictions / Partial coverage / Unique insights / Blind spots) so you
can trace every claim back to a panelist.

Don't panic about the cost: a panel runs roughly N× the tokens of a single answer and is as slow as its
slowest panelist. That's the deliberate trade for an answer worth trusting — not a default.

## Requirements

- Claude Code with Opus 4.8 (judge + an always-available panelist via subagents).
- Optional: the [`codex`](https://github.com/openai/codex) CLI for the GPT-5.5 (xhigh) panelist. Without it,
  Fusion runs the pure-Opus `opus4.8-4.8` panel.

## License

MIT — see [LICENSE](LICENSE).
