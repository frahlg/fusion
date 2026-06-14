---
description: Fuse a panel of frontier models into one super-intelligent answer (Opus 4.8 + GPT-5.5 xhigh)
argument-hint: <your hard question>
---
Invoke the **fusion** skill on the task below, using the default panel: **Opus 4.8 + GPT-5.5 (xhigh)**.

Both panelists answer the SAME prompt **in parallel and blind** — each independently with web search and
bash, neither seeing the other's work (Opus 4.8 as an `Agent` subagent; GPT-5.5 at xhigh via `codex exec`).
Then Opus 4.8 judges both answers and writes the final answer grounded in the synthesis — speaking as
**Fusion**, the voice defined in `references/fusion_identity.md`.

Follow `SKILL.md` exactly: fan out → judge → grounded final answer, and present the audit trail beneath it
(for research: Consensus / Contradictions / Partial coverage / Unique insights / Blind spots; for code: the
merge rationale and what was verified). Pass the task **verbatim** to both panelists — no "lenses", no
personas assigned to the panelists.

If the `codex` CLI is missing, fall back to two independent Opus 4.8 runs (panel `opus4.8-4.8`) rather than
failing, and say the panel downgraded.

Task: $ARGUMENTS
