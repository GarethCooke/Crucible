# Crucible — special edition "Measuring the Gap" — pre-merge verification brief

Verification + small-fix brief, Opus → CC, on branch `feature/quantum-measuring-the-gap`. Follows CC's completion report. Confirms the acceptance items the Aer-only build can satisfy now, fixes the few that need a code change, and defines the deferred re-verification CC runs after the user's hardware capture lands. Companion: `quantum-measuring-the-gap-brief.md` (the implementation brief whose acceptance this discharges).

## Context

- The build is complete on the branch and the Aer-buildable scope passes. Several original-brief acceptance items are deferred to the hardware capture (a user task), not yet satisfiable — this brief separates "confirm now" from "confirm after capture" and fixes anything that shouldn't wait.
- These are mostly checks. Where a check fails, the fix is in scope. The hardware capture, the pinned-layout choice, and the C++ baseline timing remain user tasks and are out of scope here.
- Tasks 1–4 run now against the Aer build. Task 5 is gated on the user's hardware capture filling the JSON nulls.

## Tasks

### Task 1 — Demo-total integrity (confirm, don't assume)

1.1 Confirm `getAllPosts()` uses a flat glob (`src/posts/*.mdx`), not recursive (`**/*.mdx`), so `src/posts/special/grover-explained.mdx` is excluded from the numbered set. State the glob in the PR notes.

1.2 Diff the methodology page's numbered-demo total against its pre-this-post value (expected: unchanged — 9, confirm). State both values.

1.3 Confirm neither the special post nor the companion appears in any numbered-demo index, count, or the demos-1–N cross-read consistency list. If either is counted anywhere, exclude it.

### Task 2 — Link, footer, and machine-line checks (adapted to the TSX post)

The main post is `site/src/app/special/measuring-the-gap/page.tsx` (TSX, not MDX), so the original brief's MDX-grep acceptance is re-run against the TSX.

2.1 Confirm the link to the companion route (`/special/measuring-the-gap/grover-explained`) is present in the post's experiment section. `grep -n` the route string in `page.tsx`.

2.2 Confirm the post footer renders the **quantum backend block** (backend name, qubit topology / pinned physical qubits, calibration timestamp, shots) — not the Zen 2 machine-spec line the numbered demos use.

2.3 `grep -in 'ryzen\|cset\|3800X\|isolcpus'` across the post and companion. Expect zero hits. If any appear, the wrong footer/machine block leaked in — fix.

### Task 3 — Mitigation panel must be data-derived, not pre-baked

The panel's conclusion must follow from the committed JSON, not be hard-coded. CC's report described the hardware capture as "triggering the not-a-free-lunch panel"; confirm that conclusion is computed, not asserted.

3.1 Inspect the mitigation panel component/prose. Remove any hard-coded "not a free lunch" / directional claim that renders independent of the data.

3.2 Implement the spread rule, per N: take the run-to-run spread (`[min, max]`) of the mitigation-off and mitigation-on series at that N. **If the off and on intervals overlap, render "no significant effect at this N."** If they are disjoint, render the signed effect (off−on). The panel's overall framing may only assert a direction where the data supports it across N.

3.3 While device values are null (pre-capture), the panel renders a pending state and makes no claim.

### Task 4 — Quantum JSON schema documentation

4.1 Add a documented schema for `site/src/data/quantum/measuring-the-gap.json` — a schema file or a `README`/header in `site/src/data/quantum/` describing each field and **explicitly stating it is quantum-specific and outside the locked perf schema**. (Task 1.2 of the implementation brief asked for the JSON to be documented as quantum-specific, not only emitted.)

### Task 5 — Deferred re-verification (run AFTER the user's hardware capture lands)

Do not run until the capture has filled the JSON device nulls and produced the archive. Then:

5.1 Confirm no `[hardware capture pending]` strings remain in the rendered post.

5.2 Confirm every device numeric claim in the prose matches the committed JSON to one significant figure (spot-check the headline collapse values and the BV/Grover separation).

5.3 Confirm the raw job-results archive is present alongside the committed JSON.

5.4 Re-render the mitigation panel against real numbers; confirm the Task 3 spread rule produced the right per-N text (soften to "no significant effect" wherever the off/on intervals overlap).

## Acceptance

- Task 1: glob is flat; methodology demo total unchanged (both values stated); special post + companion absent from any numbered count or the demos-1–N cross-read list.
- Task 2: companion-route `grep` hits in `page.tsx`; quantum footer fields present; `grep -in 'ryzen\|cset\|3800X\|isolcpus'` on post + companion returns nothing.
- Task 3: no hard-coded mitigation conclusion (grep shows the claim text is conditional on a spread comparison); with null device data the panel renders pending and asserts nothing.
- Task 4: schema doc exists in `site/src/data/quantum/`; `grep` confirms a "quantum-specific / not the perf schema" statement.
- Task 5 (post-capture): zero `[hardware capture pending]` strings; prose numbers match JSON to 1 sig fig; archive present; mitigation panel text matches the spread rule.

## Out of scope

- The hardware capture run and pinned-layout selection (user task on the IBM account).
- The C++ classical baseline timing capture (user task, Ubuntu reference rig).
- The standalone hostile cross-read of this post against its own scope and "what it doesn't claim" contract (separate Opus pass after capture; this post is excluded from the demos-1–N consistency sweep).
- Any change to demos 1–9, the locked perf schema, the four commitments, or `grover-explainer.md`'s content.

## Open items for CC to flag

- If the methodology demo total is derived from a recursive post count (so the flat-glob assumption doesn't hold), **stop and flag** rather than papering over it — the special edition must not be counted.
- If implementing the Task 3 spread rule needs per-N spread fields the committed JSON doesn't currently carry, **flag and coordinate a `quantum/capture.py` schema addition** — do not fabricate or hard-code spreads to make the rule render.
- If the post footer's quantum block has no clean component analogue to the numbered demos' machine-spec footer, flag where it should live rather than reusing the Zen 2 footer component.
