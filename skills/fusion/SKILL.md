---
name: fusion
description: >-
  Run a hard question through Fusion: independent frontier-model panelists answer
  the same prompt blind, then Opus 4.8 synthesizes one grounded final answer with an
  audit trail. Use when the user says "run it through Fusion", "/fusion", "fuse this",
  "ask the panel", wants a multi-model / panel / ensemble answer, a question
  cross-checked across models, an independent second or third opinion, or a
  higher-confidence answer with consensus and blind spots surfaced — even if they
  never say "fusion". Best for high-stakes research, architecture and design calls,
  and hard debugging where being confidently wrong is expensive. Skip it for easy or
  low-stakes questions; it costs panel-size tokens plus the judging pass.
model: claude-opus-4-8
argument-hint: <hard question>
---

# Fusion

Run a hard question through a **panel → judge** pipeline and return one answer you
can trust more than any single model's.

> Paths below use `${CLAUDE_SKILL_DIR}`, the directory containing this `SKILL.md`.
> Claude Code substitutes it automatically, so scripts and references resolve whether
> Fusion is installed at the personal, project, or plugin level. Run scripts as
> `${CLAUDE_SKILL_DIR}/scripts/…` and read references as `${CLAUDE_SKILL_DIR}/references/…`.

## The mechanism: independence, then synthesis

A panel beats a single model only when its members are genuinely independent — so
Fusion **harvests** diversity from independent runs instead of **manufacturing** it
with personas or "lenses". Every panelist gets the user's task verbatim, answers it
blind, and the answers meet in exactly one place: the judge. Independent agreement is
the strongest confidence signal; independent disagreement is the signal most worth
surfacing. Read the full doctrine in `references/panel.md` **before you fan out.**

## The hard rule: Opus 4.8 always judges

**Opus 4.8 always judges and writes the final answer. The pipeline cannot be
reversed.** Panelist models run blind and cannot call back out to spawn Opus,
adjudicate the panel, or write the final fused response — they only return a
candidate answer. The judge is the only place the panel converges. (This skill pins
`model: claude-opus-4-8` so the judging pass is always Opus, however `/fusion` was
invoked.) The slug reads driver-first (`opus4.8-…`) for the same reason.

---

## Step 0 — Pick the panel

Run the detector and read its recommendation:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/detect_panel.sh   # prints a SLUG= line
```

The slugs:

- `opus4.8-gpt5.5` — the default, when the `codex` CLI is present.
- `opus4.8-4.8` — two independent Opus 4.8 runs; the no-CLI fallback (a real panel,
  not a no-op).

**Honor a user-named slug** if they asked for one. If the panelist it needs isn't
installed, **fall back gracefully** to the richest panel you *can* run rather than
failing, and note the downgrade in Step 4. Step 0 only checks that a CLI is
*installed*, not that it's logged in or its provider is reachable — if a CLI panelist
fails anyway at runtime, Step 1's fallback keeps the panel intact (that's expected,
not an error). See `references/panel.md` for what each slug contains.

## Step 1 — Fan out, in parallel and blind

Build each panelist's prompt as **the user's task verbatim + the short instruction
from `references/panel.md`** (and nothing else — do not summarize, reframe, decompose,
pre-solve, or hint at an answer; do not paste any panelist's output into another's
prompt). Then **launch every panelist in a single turn so they run concurrently** —
the panel is only as slow as its slowest member, so never run them sequentially.

- **Opus 4.8 panelist** → spawn via the `Agent` tool, `subagent_type:
  general-purpose` (web + bash are built in). For `opus4.8-4.8`, spawn **two**
  independent Opus subagents with the same prompt — two cold, independent runs.
- **GPT-5.5 panelist** → write the prompt to a temp file and run the helper:

  ```bash
  PROMPT=$(mktemp); OUT=$(mktemp)
  cat > "$PROMPT" <<'EOF'
  <user task verbatim + the short panelist instruction>
  EOF
  bash ${CLAUDE_SKILL_DIR}/scripts/run_codex.sh "$PROMPT" "$OUT" xhigh
  ```

  Launch this Bash call with **`run_in_background: true`** (codex at xhigh can take
  minutes) and, in the *same turn*, spawn the Opus subagent — so the panel runs
  concurrently, not one after another. Then await the background job and read `$OUT`.
  `run_codex.sh` runs one GPT-5.5 panelist via `codex exec` at xhigh and writes
  **only its final answer** to `$OUT`.

**If a CLI panelist fails at runtime** — `run_codex.sh` exits non-zero (127 means
codex isn't installed; any other non-zero is a runtime failure) even though Step 0
expected it — **spawn a second independent Opus 4.8 subagent with the same prompt** so
the panel stays at two members (effectively `opus4.8-4.8`), and record the downgrade
for Step 4. Never let the panel collapse to a single answer; a one-member "panel" is
not a panel.

> **Local-file tasks:** CLI panelists run in an isolated scratch dir and **cannot see
> the user's repo**. For tasks that depend on local code, paste the relevant files
> into the panelist prompt (the Opus subagent panelist *can* read the repo, so weight
> it accordingly), or note in Step 4 that the CLI panelist judged without repo access.

Wait for all launched panelists and collect each one's final answer. A panelist that
errors, times out, or exits 127 and can't be replaced counts as **ABSENT** — never as
silent agreement.

## Step 2 — Judge

Only after **every** panelist has returned, judge (Opus 4.8, you). Follow
`references/judge_rubric.md`. **Classify the deliverable FIRST:**

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
panel. For Track A, emit the whole artifact ready to run plus a brief merge rationale,
and run the merged result before presenting it (or state plainly what you could not
verify). For Track B, the final answer must be traceable to the synthesis — no claim
the panel didn't support, with confidence calibrated to how much it actually
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
