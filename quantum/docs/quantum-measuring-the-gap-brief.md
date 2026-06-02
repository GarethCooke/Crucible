# Crucible — special edition: "Measuring the Gap" (quantum vs classical) — implementation brief

Implementation brief, Opus → CC. Builds the off-cadence special-edition post that measures the gap between Grover's theoretical √N speedup and what NISQ hardware actually delivers. Companion documents: `quantum-measuring-the-gap-scope.md` (thesis, sections, the "what it doesn't claim" contract), `quantum-measuring-the-gap-pilot-scope.md` (the pilot that calibrated this), `grover-explainer.md` (the published companion explainer — see Task 2), `grover_pilot.py` (the validated pilot scaffold), `BRIEF.md` and `crucible-handover.md` (the four locked commitments this post deliberately sits outside). Work on a feature branch; merge is a user task. **This is NOT a numbered demo** — it ships at `/special`, outside the C++ cadence, and must not increment the methodology page's demo total.

## Context

- The calibration pilot is **complete**. All §A questions resolved: the collapse curve exists (Q1), free tier is ample (Q2), the Bernstein–Vazirani contrast is strong and stays in (Q3), QAOA is skipped (Q4), cadence is `/special` (Q5). The mitigation off-vs-on panel resolved as a real "not a free lunch" finding.
- **The pilot numbers are throwaway and are NOT the published figures.** They establish the experiment's shape; the committed numbers come from a fresh capture (Task 1 protocol), which is a **user task on the IBM account** (cloud submission + any spend), exactly like every reference-machine capture. The pilot's qualitative findings, for orientation only:
  - Grover device success collapses across N=8/16/32 (works → halved → at the random floor) while the ideal simulator stays near 1.0 and classical is always correct.
  - BV success stays high and roughly flat across the same N (shallow circuit), giving a large separation from Grover at N=32 — the contrast that shows the killer is **circuit depth × per-gate error, not "quantum."**
  - Mitigation (DD + measurement twirling) hurt where Grover already works, inflated run-to-run variance at the mid-collapse point, and did nothing where it had collapsed. An apparent mitigation "rescue" in an early run was a qubit-layout confound, exposed once the comparison was run on matched qubits.
  - Absolute numbers are **layout-dependent** (the mid-collapse point moved ~0.09 between physical-qubit choices); within-run reproducibility is ~0.003.
- Backend used in the pilot: `ibm_marrakesh`, 4096 shots, `seed_transpiler=42`. The capture must pin physical qubits (`initial_layout`) so the Grover/BV and mitigation-off/on comparisons are clean.a
- The published companion explainer source is saved at `Crucible/quantum/docs/grover-explainer.md`.

## Story angle and scope (from the scope doc — do not re-derive)

Thesis: take a problem with a famous theoretical quantum speedup, run it both ways, and measure the gap between the promise and the silicon. Classical wins decisively today; the post shows precisely why (gate error × depth, decoherence, no error correction), then maps where advantage genuinely is landing now and why that's a different problem class.

**What the post must NOT claim** (defensive scope — enforce in prose and acceptance):
- Not "quantum is hype." Credit the real 2026 advantage claims (quantum-simulation/physics class) as claimed and recent, awaiting independent replication.
- No quantum win on any finance workload. The finance angle is promissory; cite the real on-hardware "par-with-classical" results as exactly that, not a win.
- Not a benchmark in the Crucible sense. The numbers are not comparable ns/op and the post says so.
- Not a Q-Day prediction. The asymptotic chart shows requirements, not a date.

## Tasks

### Task 1 — Capture harness + quantum-specific JSON schema

1.1 Promote `grover_pilot.py` into a capture tool under `Crucible/quantum/` (e.g. `capture.py`) that runs, against a pinned `initial_layout`: the Grover N-sweep (n ∈ {3,4,5}), the BV N-sweep at the same n, and the Grover mitigation off/on pair — each with marked-state averaging and ≥5 outer repeats, **and extra repeats at the mid-collapse N** where the mitigation magnitude was uncertain in the pilot. Reuse the validated circuit builders (`build_grover`, `build_bv`) and the matched-qubit logic unchanged.

1.2 Emit a **separate, clearly-namespaced** JSON file (e.g. `site/src/data/quantum/measuring-the-gap.json`) — **do not** shoehorn quantum metadata into the locked perf schema. The quantum block carries: backend name, qubit topology / physical qubits used, native gate set, calibration timestamp, shots, per-N mean and run-to-run spread for each series (Grover device, BV device, ideal simulator, classical floor), the mitigation off/on series, and the per-circuit records. Archive the raw job-results JSON alongside it.

1.3 Also emit the Aer-only teaching-sweep data (P(marked) vs iteration count at one N) and the ideal-simulator reference curve. These cost no QPU time and are reproducible.

1.4 The C++ classical linear-scan baseline (microsecond wall-clock) is a separate small bench — see Task 7.

### Task 2 — Companion explainer page (and the link from the post)

2.1 Create a published companion page from the **existing** source `Crucible/quantum/docs/grover-explainer.md`. Use that file's content as the page body — do not rewrite it. Convert to the site's MDX/page format as needed; preserve the structure (mental model → problem → steps → over-rotation → measure → why hardware fails → links → "what you don't need").

2.2 Insert a link **from the main post to this companion page**: a short inline pointer in the post's mechanism/experiment section (two–three sentences of the mechanic) followed by a "full walkthrough →" link to the companion page. The main post does not inline the full explainer.

2.3 Place the companion at a `/special`-namespaced route (e.g. `/special/measuring-the-gap/grover-explained`); confirm the exact route against the site's routing — see Open items.

### Task 3 — Visuals (reuse/compose; do not fork pre-emptively)

Build five panels plus one theory chart, reusing existing chart components where they adapt and composing where they don't:
- **Headline collapse curve** — three series (ideal simulator flat-high, Grover device collapsing, classical always-correct) against N, with the random-floor line. Adapt the existing N-sweep chart machinery to a probability y-axis if it takes it cleanly.
- **Over-rotation teaching chart** — P(marked) vs Grover iteration count at one N, showing the rise-to-peak-then-fall oscillation. Pairs with the companion explainer.
- **Mechanism** — transpiled circuit depth / two-qubit-gate count vs N, annotated with the per-gate error and the resulting compounded fidelity (why the curve collapses).
- **BV-vs-Grover contrast** — both device success curves on one ratio/probability view; BV roughly flat, Grover collapsing.
- **Mitigation off-vs-on** — Grover device success, mitigation off vs on, per N, with the run-to-run spread shown (the variance inflation is part of the finding).
- **Asymptotic crossover (theory)** — classical O(N) vs Grover O(√N) per-op cost, crossover far off-scale, annotated with the fault-tolerance requirements. **Label it theory-not-measurement** so the hostile cross-read doesn't read it as empirical.

### Task 4 — The MDX post

Write the post following the scope's section structure: hook (the promise vs what running it does), the experiment (Grover, classical vs real quantum, named backend, why this problem), headline collapse result, mechanism (gate error × depth, decoherence, no error correction), the asymptotic-crossover theory chart, where advantage IS landing now (honest 2026 survey, quantum-simulation class, claimed-awaiting-replication), the finance sidebar (promissory, no production win, cite the par-with-classical on-hardware result), takeaway (real and advancing, but classical silicon wins for these workloads today), and the methodology-departure note. Adapt the prose register from a recent post (e.g. `08-sorting-shootout.mdx`). All numerical claims in prose derive from the Task 1 JSON, not from this brief.

### Task 5 — `/special` handling

5.1 Index card: render the post with a "special edition / outside the standard methodology" marker, visually distinct from the numbered demo cards.

5.2 Methodology page: add a short note documenting the departure (not C++, not the Zen 2 rig, not the perf machine-block, not the ns/op convention). **Do not increment the demo total** — this is not a numbered demo.

5.3 Post header: carry the same "special edition" marker.

5.4 The post carries a quantum-appropriate footer (backend, qubit topology, calibration timestamp, shots) — **not** the Zen 2 machine-spec line the numbered demos use.

### Task 6 — Reproducibility caveats on-page

State on the post: numbers are physical-qubit-layout dependent (pin recorded); cloud backends recalibrate so exact numbers won't reproduce; the classical baseline and simulator reproduce exactly, the hardware numbers are pinned by the archived job results, not by re-running.

### Task 7 — C++ classical baseline bench

Write a C++ linear-scan baseline (find the marked item in an unstructured array of size N) producing a microsecond wall-clock figure, in keeping with the project's normal bench style. The **authoritative timing capture is a user task on the Ubuntu reference rig** (isolated cores, perf, turbo off) — see Out of scope. Do not publish a Windows/MinGW-built figure.

## Acceptance

Harness / schema:
- `Crucible/quantum/capture.py` runs end-to-end on the Aer dry-run path with `python capture.py ... ` (no hardware) and validates every circuit near 1.0; the Grover and BV builders are unchanged from the validated pilot (diff shows no edits to `build_grover`/`build_bv` logic).
- The committed JSON validates against a documented quantum-specific schema and lives outside `site/src/data/perf/`. `grep -rn "perf" site/src/data/quantum/` returns nothing implying reuse of the locked perf schema.
- Raw job-results archive is present alongside the committed JSON.

Companion + link:
- The companion page exists and its body matches `Crucible/quantum/docs/grover-explainer.md` (no rewrite).
- `grep -n` in the post's MDX finds a link to the companion page route.

Post / site:
- All numeric claims in the post prose match the committed JSON to one significant figure (spot-check the headline collapse values and the BV/Grover separation).
- The post contains an explicit "what this does not claim" passage covering the four non-claims above.
- The asymptotic-crossover chart is labelled as theory/not-measurement (grep the label).
- The index card and post header carry the special-edition marker; the methodology page demo total is **unchanged** from its pre-this-post value (diff the total).
- The post footer is the quantum backend block, not the Zen 2 machine-spec line (`grep` confirms no `Ryzen`/`cset`/`3800X` in this post).

## Out of scope

- The formal hardware capture and any spend approval — user task on the IBM account, like every reference-machine capture. CC builds the harness and Aer-validates it; the user runs the hardware capture.
- The authoritative C++ baseline timing capture — user task on the Ubuntu reference rig.
- Any change to demos 1–9 code, prose, JSON, the locked perf schema, or the methodology page's four commitments. This post sits outside them.
- Including this post in the demos-1–N hostile-cross-read consistency sweep, or in the numbered demo total.
- A QAOA hardware run (skipped per the pilot) and any Shor instance beyond a referenced Q-Day sidebar.
- Rewriting `grover-explainer.md`'s content (use it as-is per Task 2).

## Open items for CC to flag

- If no existing chart component adapts cleanly to a probability y-axis, build a minimal new component rather than distorting an ns/op chart — **surface the choice** rather than forcing a reused component.
- If the site's routing has no clean home for a non-demo `/special` page (post + companion), **stop and flag** where these should live rather than guessing; the route names in Tasks 2–5 are intent, not confirmed paths.
- The BV circuit uses **n+1 qubits** (input + ancilla); the capture's `initial_layout` pin must be wide enough for the BV sweep, not just Grover's n. If a pinned layout is too narrow for BV, flag rather than silently letting the transpiler re-route.
- If the user's fresh capture shows the mid-collapse-N mitigation effect sitting within the run-to-run spread, **soften the mitigation panel to "no significant effect"** rather than asserting a direction — the pilot's single comparison was suggestive, not conclusive, at that N.
- If the methodology page's structure makes "document the departure without bumping the total" awkward (e.g. the total is derived from a post count), **flag it** — the special edition must not be counted as a numbered demo.

## Notes for CC

- Stage the build so the post and charts render against the **committed JSON** once the user's capture lands; until then, build against the pilot/Aer data with placeholders clearly marked, and do not commit pilot numbers as published figures.
- The companion explainer (Task 2) has no hardware or data dependency — it can land first and independently.
