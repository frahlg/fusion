# Panel doctrine — independence, then synthesis

This is the load-bearing idea of Fusion. Read it before fanning out (`SKILL.md`,
Step 1).

## Why independence

A panel only beats a single model when its members reason **independently**. Run the
same prompt in parallel and the runs diverge — different reasoning paths, different
searches, different sources, different mistakes. That divergence is the raw material
synthesis turns into a better answer.

The two outcomes that matter:

- **Independent agreement = high confidence.** When models that never saw each
  other's work land in the same place, that convergence is real evidence — not an
  echo.
- **Independent disagreement = the signal worth surfacing.** A genuine split is the
  single most valuable thing a panel produces: it marks exactly where a lone model
  would have been confidently wrong. Surface it; never average it away.

## No lenses, no personas — ever

Do **not** assign panelists roles, stances, "lenses", personas, or angles ("you be
the skeptic", "argue the security view", "you're the optimist"). Manufactured
diversity **corrupts** the independence the whole method depends on:

- A persona biases a panelist *toward* its assigned conclusion, so agreement stops
  meaning "two minds converged" and disagreement stops meaning "a real fork exists" —
  both signals become artifacts of the costume you handed out.
- Real diversity is already *in* the independent runs. You don't add it; you harvest
  it.

**Every panelist gets the user's task verbatim** plus only the short, neutral
instruction below. Same task, same instruction, for all of them.

## Isolation rules

- Panelists **never** see each other's work. Never paste one panelist's output —
  partial or final — into another's prompt.
- The **orchestrator must not pre-digest the task**: no reframing, no decomposition
  into sub-questions, no hints, no "here's how I'd approach it". Pass it through
  clean. Pre-digestion is just a lens by another name.
- **The judge is the only place the answers meet.** Convergence is computed once, at
  synthesis time, by Opus 4.8 (`references/judge_rubric.md`) — never during the
  fan-out.

## Panel composition by slug

Chosen by `scripts/detect_panel.sh`. The slug names the **panelists only** — Opus 4.8
is always the separate driver and judge, and is never replaced by a panelist.

| Slug | Panelists (all blind, in parallel) | Requires |
| --- | --- | --- |
| `opus4.8-gpt5.5` | Opus 4.8 (`Agent`, general-purpose) + GPT-5.5 xhigh (`scripts/run_codex.sh`) | `codex` CLI |
| `opus4.8-4.8` | two independent Opus 4.8 runs (two separate `Agent` subagents, same prompt) | nothing — universal fallback |
| `opus4.8-gpt5.5-gemini3.1pro` | the above two + Gemini 3.1 Pro (`gemini` CLI) | `codex` + `gemini` CLIs |

`opus4.8-4.8` is a real panel, not a no-op: two cold, independent Opus runs diverge
enough that synthesizing them beats a single run. Always prefer the richest panel
available; downgrade gracefully and disclose it (`SKILL.md`, Step 4). A dropped
panelist is **absent**, not silent agreement.

## The exact short instruction each panelist receives

Append this — and nothing more — after the user's task verbatim. Identical for every
panelist:

```
Answer the task above completely and independently. You have web search and a shell
(bash); use them to verify facts, read primary sources, and — for code or other
runnable artifacts — actually run and test what you produce rather than reasoning
about it from memory. Do not modify any shared working tree; if you need to
experiment, work only in scratch files or a temp directory. Ground your claims in
evidence and state your confidence honestly, flagging anything you could not verify.
You are one of several models answering this same task in parallel and blind; do not
address, imagine, or coordinate with the others — just give your own best, complete
answer. Return only that final answer.
```

That single instruction asks for independence, evidence, safe tool use, and honest
confidence — without ever steering the conclusion. That is the whole point.
