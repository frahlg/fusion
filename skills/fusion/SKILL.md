---
name: fusion
description: >-
  Answer a hard question with a panel of frontier models judged into one grounded
  answer. Dispatches the SAME prompt to several models in parallel and BLIND (each
  with web search + bash, none seeing the others' work), then Opus 4.8 judges every
  answer into a structured analysis and writes one final answer grounded in it — in
  the voice of Fusion. Default panel: Opus 4.8 + GPT-5.5 (xhigh, via the `codex`
  CLI). Use this when the user says "run it through Fusion", "fuse this", "/fusion",
  "ask the panel", or asks for a multi-model / panel / ensemble answer, wants a
  question cross-checked or sanity-checked across models, wants a second (and third)
  independent opinion, or wants a higher-confidence answer with consensus and blind
  spots surfaced — even if they never say the word "fusion". Best for high-stakes
  research, architecture and design calls, and hard debugging where being
  confidently wrong is expensive. The mechanism is independence then synthesis:
  diversity is harvested from independent runs, NOT manufactured with assigned
  personas or "lenses" — every panelist gets the user's task verbatim. Skip it for
  easy or low-stakes questions; a panel costs N× the tokens and runs as slow as its
  slowest panelist.
---

# Fusion

Run a hard question through a **panel → judge** pipeline and return one answer you
can trust more than any single model's.

> Paths below are relative to this skill's own directory (`<skill_dir>`, i.e.
> `~/.claude/skills/fusion`). Run scripts as `<skill_dir>/scripts/…` and read
> references as `<skill_dir>/references/…`.

## The mechanism: independence, then synthesis

A panel beats a single model only when its members are genuinely independent. The
diversity that makes the panel worth its cost is **harvested from independent runs,
not manufactured**. Run the same prompt independently and you get different
reasoning paths, different tool calls, different sources — even two cold runs of the
*same* model diverge enough that synthesizing them beats running it once.

So Fusion does the opposite of role-play. There are **no personas, no assigned
"lenses", no stances**. Every panelist receives the user's task **verbatim** plus
one short instruction, answers it straight and blind, and the answers only ever meet
in one place: the judge. Independent agreement is the strongest confidence signal you
can get; independent disagreement is the signal most worth surfacing. The full
doctrine is in `references/panel.md` — read it before you fan out.

## The hard rule: Opus 4.8 always judges

**Opus 4.8 always judges and writes the final answer. The pipeline cannot be
reversed.** Panelist models run blind and cannot call back out to spawn Opus,
adjudicate the panel, or write the final fused response — they only return a
candidate answer. The judge is the only place the panel converges. The slug reads
driver-first (`opus4.8-…`) for exactly this reason.

---

## Step 0 — Pick the panel

Run the detector and read its recommendation:

```bash
bash <skill_dir>/scripts/detect_panel.sh   # prints a SLUG= line
```

The slugs:

- `opus4.8-gpt5.5` — the default, when the `codex` CLI is present.
- `opus4.8-gpt5.5-gemini3.1pro` — richest, when `gemini` is also present.
- `opus4.8-4.8` — two independent Opus 4.8 runs; the no-CLI fallback (a real panel,
  not a no-op).

**Honor a user-named slug** if they asked for one (e.g. "use the three-model
panel"). But if a panelist that slug needs isn't installed, **fall back gracefully**
to the richest panel you *can* run rather than failing — and note the downgrade in
Step 4. See `references/panel.md` for what each slug contains.

## Step 1 — Fan out, in parallel and blind

Build each panelist's prompt as **the user's task verbatim + the short instruction
from `references/panel.md`** (and nothing else — do not summarize, reframe,
decompose, pre-solve, or hint at an answer; do not paste any panelist's output into
another's prompt). Then **launch every panelist in a single turn so they run
concurrently** — the panel is only as slow as its slowest member, so never run them
sequentially.

- **Opus 4.8 panelist** → spawn via the `Agent` tool, `subagent_type:
  general-purpose` (web + bash are built in). For `opus4.8-4.8`, spawn **two**
  independent Opus subagents with the same prompt — two cold, independent runs.
- **GPT-5.5 panelist** → write the prompt to a temp file and run the helper in the
  background:

  ```bash
  PROMPT=$(mktemp); OUT=$(mktemp)
  cat > "$PROMPT" <<'EOF'
  <user task verbatim + the short panelist instruction>
  EOF
  bash <skill_dir>/scripts/run_codex.sh "$PROMPT" "$OUT" xhigh   # run in background
  ```

  `run_codex.sh` runs one GPT-5.5 panelist via `codex exec` at xhigh and writes
  **only its final answer** to `$OUT`.
- **Gemini panelist** (three-model slug only) → run its CLI the same way: prompt in a
  temp file, in the background, alongside the others.

**If a CLI panelist fails at runtime** — `run_codex.sh` exits 127 (codex not
installed) or errors out even though Step 0 expected it — **spawn a second
independent Opus 4.8 subagent with the same prompt** so the panel stays at two
members (effectively `opus4.8-4.8`), and record the downgrade for Step 4. Never let
the panel collapse to a single answer; a one-member "panel" is not a panel.

Wait for all launched panelists and collect each one's final answer. A panelist that
errors, times out, or exits 127 and can't be replaced counts as **ABSENT** — never
as silent agreement.

## Step 2 — Judge

Only after **every** panelist has returned, switch to the judge role (Opus 4.8,
you). Follow `references/judge_rubric.md`. **Classify the deliverable FIRST:**

- **Code or a concrete artifact** (a script, config, patch, query, schema, content
  files…) → **Track A — run-both-and-merge.** Build a real model of each candidate,
  then *run them with bash* and let observed behavior decide. Pick the strongest
  foundation and graft in the specific parts of the other(s) you saw work; run the
  merged artifact and fix until it passes. No Frankenstein blends.
- **Research, analysis, a recommendation, a judgment call** → **Track B —
  five-section synthesis:** Consensus · Contradictions · Partial coverage · Unique
  insights · Blind spots — then a final answer that follows *from* that synthesis.

Shared discipline (full detail in the rubric): evidence over assertion (a panelist
that ran code or read a primary source outranks one reasoning from memory); honesty
about confidence and disagreement; keep attribution; the answer must never exceed the
evidence; an absent panelist is never counted as agreement.

## Step 3 — Write the final deliverable

Write **one** answer, grounded in the Step 2 analysis — never a mere average of the
panel. For Track A, emit the whole artifact ready to run plus a brief merge
rationale, and run the merged result before presenting it (or state plainly what you
could not verify). For Track B, the final answer must be traceable to the synthesis —
no claim the panel didn't support, with confidence calibrated to how much it actually
converged. Write it in **Fusion's voice** per `references/fusion_identity.md`:
singular, luminous, confident — but the voice shapes **style, never substance**.

## Step 4 — Present

Lead with **the final answer** in Fusion's voice. Then, beneath a divider, the
**audit trail**:

- **Panel:** the slug, which panelists actually ran, and any that were absent or
  replaced.
- **For research (Track B):** the five sections (Consensus / Contradictions / Partial
  coverage / Unique insights / Blind spots).
- **For code (Track A):** the merge rationale and what you verified by running.
- **If the panel downgraded** because a CLI was missing, say so plainly and how to
  enable the fuller panel (e.g. "GPT-5.5 was absent — install the `codex` CLI and log
  in to run the default `opus4.8-gpt5.5` panel").

## Cost & latency

A panel costs roughly **N× the tokens** of a single answer (plus the Opus judging
pass) and runs **as slow as its slowest panelist**. That's the deliberate trade for
higher confidence — so **don't reach for Fusion on easy or low-stakes questions.**
Save it for the calls where being confidently wrong is expensive.
