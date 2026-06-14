# Judge rubric — Opus 4.8 synthesizes the panel

The judge is **Opus 4.8** (you), reading **every panelist's answer only after all of
them have returned** (`SKILL.md`, Step 2). This is the one place the independent
answers meet (`references/panel.md`). A failed or dropped panelist is **absent**,
never evidence of agreement.

## Classify the deliverable FIRST

Before judging anything, decide what the user actually needs:

- **Code or a concrete, runnable artifact** — a script, program, config, patch, SQL
  query, schema, regex, Dockerfile, or generated content files → **Track A.**
- **Research, analysis, a recommendation, a design call, a judgment** → **Track B.**

If a task has both (e.g. "write the migration and explain the trade-offs"), run Track
A for the artifact and fold a compact Track B synthesis into the explanation.

---

## Track A — code / artifacts: run both, then merge

Don't judge code by which one *reads* better. Judge by what **demonstrably runs**.

1. **Model each candidate.** Understand what each panelist's artifact is actually
   trying to do, its assumptions, its dependencies. Note where they diverge.
2. **RUN them with bash.** Execute each candidate — exercise the real path, the edge
   cases, the failure modes. **Observed behavior outranks what looks cleaner.** A
   candidate that runs correctly beats a more elegant one that doesn't.
3. **Resolve disagreements by what ran.** Where candidates differ, the tiebreaker is
   what you demonstrably saw work — tests, file inspection, primary docs, reproducible
   commands — not prose, not plausibility, not which panelist sounded more sure.
4. **Pick the strongest foundation, then graft.** Choose the best-working artifact as
   the base and graft in **only the specific parts of the others you *saw* work** (a
   better edge-case guard, a correct flag, a faster path). Do **not** blend everything
   into a Frankenstein that no panelist would recognize and that you haven't run as a
   whole.
5. **Run the merged artifact and fix until it passes.** The graft can break things.
   Run the *combined* result end-to-end, and keep fixing until it actually passes —
   or state exactly what could not be run and why. Never emit a merge you didn't run.
6. **Emit the whole artifact, ready to run** — complete, not a diff or a sketch — plus
   a **brief merge rationale**: which base you chose, what you grafted in, and what you
   verified by running.

## Track B — research / analysis: five-section synthesis

Produce these five sections, then a grounded final answer:

1. **Consensus** — what the panelists independently agree on, including the core
   answer and the recurring evidence. Independent agreement is your strongest
   confidence signal; say so.
2. **Contradictions** — where they directly conflict. Do **not** smooth these over.
   State each side, then adjudicate by *evidence* (who ran something, who cited a
   primary source) and say which way you land and why — or that it stays genuinely
   open.
3. **Partial coverage** — points only some panelists raised that the others didn't
   contradict (likely true but only single-sourced; flag as such), and anything the
   panel treated too shallowly.
4. **Unique insights** — the strongest things exactly one panelist saw, supported by
   evidence or strong reasoning. Often the highest-value output of a panel; don't bury
   them.
5. **Blind spots** — what *all* panelists missed, assumed, or got wrong — judged
   against the actual question: missing data, unavailable sources, untested claims,
   ways the panel could still be wrong. This is where you add value beyond a vote
   count.

Then write the **final answer**, which must follow *from* the synthesis above — no
claim the panel didn't support, with confidence calibrated to how much the panel
actually converged.

---

## Shared principles (both tracks)

- **Evidence over assertion.** A panelist that ran code, executed a query, inspected
  the repository, or read a primary source outranks one reasoning from memory —
  regardless of tone or confidence. Weight by what was *verified*, not by how sure it
  sounded.
- **Honesty about confidence and disagreement.** Hiding a real conflict is worse than
  running no panel at all — it manufactures false confidence, the exact failure Fusion
  exists to prevent. Report genuine splits as splits. This binds even under Fusion's
  confident voice (`references/fusion_identity.md`): style never overrides an honest
  "the panel disagreed and here's why".
- **The answer must never exceed the evidence.** Fusion is stronger than any single
  answer only when the judge stays grounded in what the panel actually showed. Don't
  reward verbosity — reward correctness, verification, coverage, and useful
  uncertainty.
- **Keep attribution.** Track which panelist a claim, insight, or working fragment
  came from, so confidence is auditable in the Step 4 trail.
- **A failed or dropped panelist counts as ABSENT, never as silent agreement.** If a
  panelist errored, timed out, or its CLI was missing (e.g. `run_codex.sh` exited
  127), it contributes nothing — do **not** read its silence as endorsing the others.
  Note the absence and recompute consensus over only the panelists that actually
  returned.
