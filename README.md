# Fusion

**Fuse a panel of frontier models into one super-intelligent answer.**

Fusion is a [Claude Code](https://claude.com/claude-code) skill that runs a hard question through a
**panel → judge** pipeline. The same prompt is dispatched to several models *in parallel* — each answering
independently with web search and bash, none seeing the others' work — and then **Opus 4.8** judges every
answer into a structured analysis (consensus, contradictions, partial coverage, unique insights, blind
spots) and writes one final answer grounded in it, in the voice of **Fusion**.

The mechanism is **independence, then synthesis**. The diversity that makes a panel beat a single model is
harvested, not manufactured: running the same prompt independently yields different reasoning paths, tool
calls, and sources — even two cold runs of the *same* model diverge enough that synthesizing them beats
running it once. So there are no contrived "lenses" or personas; every panelist gets the task verbatim and
answers it straight.

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

Opus 4.8 **always** judges and writes the final answer — the pipeline can't be reversed, because the
panelist models can't call back out to spawn Opus.

## The panels

| Slug | Panel | Requires |
| --- | --- | --- |
| `opus4.8-gpt5.5` | Opus 4.8 + **GPT-5.5 (xhigh)** in parallel → Opus judges | the `codex` CLI |
| `opus4.8-4.8` | the **same prompt run twice** as 2 independent Opus 4.8 panelists → Opus judges | nothing — works everywhere (fallback) |
| `opus4.8-gpt5.5-gemini3.1pro` | Opus 4.8 + GPT-5.5 + **Gemini 3.1 Pro** in parallel → Opus judges | `codex` + `gemini` CLIs |

The skill auto-detects which panelist CLIs are installed and uses the richest panel available, falling back
gracefully when one is missing. The default is **Opus 4.8 + GPT-5.5 (xhigh)**.

## Install

```bash
git clone <your-fork-url> fusion
cd fusion
./install.sh
```

This copies the skill to `~/.claude/skills/fusion` and the `/fusion` command to `~/.claude/commands`, then
prints which panels your machine can run. Restart Claude Code (or run `/reload-skills`) afterward.

> Override the target with `CLAUDE_CONFIG_DIR=/path/to/.claude ./install.sh`.

## Use

Ask any hard question through Fusion:

```
/fusion Should we run our edge control loop on a single MQTT broker or a quorum?
```

…or just ask in prose to "run it through Fusion" / "give me a panel answer". Best for high-stakes research,
design calls, and debugging where being confidently wrong is expensive. A panel costs roughly N× the tokens
of a single answer and runs as slow as its slowest panelist — that's the deliberate trade.

## Requirements

- Claude Code with Opus 4.8 (judge + an always-available panelist via subagents).
- Optional: the [`codex`](https://github.com/openai/codex) CLI for the GPT-5.5 (xhigh) panelist.
- Optional: a `gemini` CLI for the three-model panel.

## License

MIT — see [LICENSE](LICENSE).
