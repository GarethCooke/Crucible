# Crucible — special edition: "Measuring the Gap" (quantum vs classical) — scope sketch

Pre-pilot scope sketch, for Opus/user. **Not a committable brief** — per the demo 5/6/7 lesson, the implementation brief comes after a calibration pilot, and the skill's anti-pattern list forbids committing numerical targets before calibration. This doc fixes the thesis, the experiment design, the post's contents, and the questions the pilot must answer. The brief gets written once the pilot resolves §A.

## Context

- This is a **deliberate departure** from the locked Crucible methodology, not a numbered demo in the C++ cadence. Flag it as a "special edition" on the index and in the post header.
- It breaks four locked commitments at once: not C++ (Python/Qiskit, with a thin C++ classical baseline for continuity), not the isolated Zen 2 rig (a cloud NISQ backend), not the perf-counter machine block, not the median/IQR/p99 ns-per-op stat convention.
- `crucible-handover.md` — the "No IguanaWare branding / rigour signal" principle is the whole reason this post works. The value here is the *measurement and the refusal to hype*, aimed at a hype-allergic quant audience. A post that showed quantum "winning" via a rigged comparison would damage exactly the credibility Crucible exists to signal.
- `BRIEF.md` / methodology page — the four commitments and the locked JSON schema are **out of scope** for this post (see Out of scope). This post sits outside them and says so on the page.
- Current field state (verify again at brief time — this is moving weekly): as of May 2026 the first *practical quantum advantage* claims are landing (Q-CTRL/IBM Fermi-Hubbard materials sim, IonQ/Ansys, Google's Quantum Echoes), all in quantum-simulation / physics problem classes, all fresh and vendor-driven. None is a classical-data or finance workload. Treat them as "claimed, awaiting independent replication," not settled.

## Thesis

Take a problem with a famous *theoretical* quantum speedup, run it both ways — classical on the reference rig, and a small real instance on a NISQ backend — and **measure the gap between the promise and the silicon**. The honest punchline: on today's hardware the classical version wins decisively, and the post shows precisely *why* (gate error × circuit depth, decoherence, no error correction), then maps where advantage genuinely is landing now and why those are a different problem class from search/sort/finance.

**What the post does NOT claim:**

- Not "quantum is hype." It isn't — the post acknowledges the 2026 advantage claims as real and credits the trajectory.
- Not a quantum win on any finance problem. There isn't one yet; the post says so.
- Not a benchmark in the Crucible sense. The numbers are not comparable ns/op and the post is explicit that they aren't.
- Not a prediction of Q-Day timing. The asymptotic chart shows *requirements*, not a date.

## The experiment

**Headline algorithm: Grover's search** (unstructured search, theoretical O(√N) vs classical O(N)). Chosen because the classical comparison is trivial (linear scan), the speedup is famous, and the failure mode on real hardware is dramatic and teachable.

- **Classical side:** a linear scan in C++, timed on the reference rig the normal Crucible way (microseconds). Keeps one foot in the project's home turf.
- **Quantum side:** Grover on a small real backend (IBM free tier, search space N = 8–32, i.e. 3–5 qubits) via Qiskit. Also run the **noiseless Aer simulator** for the same circuits, to show what *should* happen against what the device actually does.

**The honest metrics** (since wall-clock ns/op does not transfer):

1. Classical wall-clock to find the marked item — on-rig, the usual way.
2. Quantum **success probability vs search-space size N** on real hardware — the marked-item probability. The ideal simulator sits near 1.0; the real device collapses toward random (1/N) as circuit depth grows. *The collapse is the story.*
3. **Theoretical crossover N** — where √N Grover iterations × per-iteration gate cost would overtake the linear scan — plotted as an asymptotic line, clearly labelled theory-not-measurement, annotated with the logical-qubit count and gate fidelity a fault-tolerant machine would need to reach it.

## What the post contains (section by section)

1. **Hook** — the promise ("√N speedup", "breaks RSA") vs "here's what happens when you actually run it."
2. **The experiment** — Grover, classical vs real quantum, named backends, why this problem.
3. **Headline result** — the success-probability collapse chart (chart 1). Classical is boringly always-correct; the device drowns in noise past a tiny N.
4. **Mechanism** — gate error compounded over depth, T1/T2 decoherence, no error correction in NISQ. The √N gate-count advantage is real and eaten by per-gate error and error-correction overhead.
5. **The asymptotic crossover** (chart 3, theory) — where Grover *would* win, and the fault-tolerance requirements to get there.
6. **Where advantage IS landing now** — honest survey: the 2026 materials-simulation claims, why quantum-simulation problems are the natural early win, why that's a different class from search/sort/finance. Fresh vendor claims flagged as awaiting replication.
7. **The finance angle** (sidebar) — QAOA portfolio optimization / amplitude-estimation Monte Carlo: heavily researched, promissory, no production advantage. Honest read for a trading-desk reader.
8. **Takeaway** — quantum is real and advancing; the first practical-advantage claims are landing in 2026; but for the classical-data, latency-sensitive workloads this site is about, classical silicon wins today and for the foreseeable horizon. The post's value is the measurement, not the prophecy.
9. **Methodology note** — explicit departure disclosure (below).

## Charts

- **Chart 1 (headline):** Grover success probability vs N — three series: ideal simulator (flat, high), real NISQ backend (collapsing), classical reference (always correct). Reuse `<TimeVsN>`'s axis machinery if it adapts to a probability y-axis; otherwise a small new component — decide at brief time, don't fork pre-emptively.
- **Chart 2:** circuit depth / gate count vs N for Grover, annotated with the backend's per-gate error rate and the resulting compounded fidelity. Shows *why* chart 1 collapses.
- **Chart 3 (theory, clearly labelled):** asymptotic classical O(N) vs Grover O(√N) per-op cost, crossover marked far off-scale to the right, annotated with the hardware needed to reach it. The one non-empirical chart in the project — label it as such so the hostile cross-read doesn't treat it as a measured claim.

## Methodology departure — handling

- Post header and index card both carry a "special edition / outside the standard methodology" marker. Do not let it contaminate the cross-demo consistency the hostile cross-reads enforce.
- **Do not shoehorn quantum backend metadata into the locked perf schema.** A quantum "machine block" is a different shape: backend name, qubit topology, native gate set, T1/T2, readout error, calibration timestamp. Give it a separate, clearly-namespaced JSON file and document it as quantum-specific.
- Reproducibility caveat stated on-page: cloud backends recalibrate, so exact numbers won't reproduce. Pin the backend, the calibration timestamp, and the transpiled circuit; archive the raw job-results JSON alongside the post data.

## §A — Pilot questions (must resolve before the brief)

The pilot is throwaway (no committed JSON, no chart-ready output), same shape as demo 6/7 §1. It exists because almost nothing here is calibrated.

1. **Largest N where the real device beats random guessing.** This bounds the whole story. If even N = 4 is pure noise, chart 1 is "instant collapse" — still valid, just blunter. If success probability holds to N = 16+, the curve is richer. *The thesis survives either way, but the brief can't commit to the chart's shape until this resolves.*
2. **Backend access.** Does the IBM free tier give enough shots and tolerable queue times for a clean success-probability curve across the N range? If not, what's the minimum paid spend — and is it justified for one post? Bound it before committing.
3. **Grover vs a shallower contrast.** Bernstein–Vazirani is a shallow circuit that the hardware can often run cleanly. Worth a contrast pair ("the shallow circuit works, the deep one drowns")? Pilot decides whether that strengthens or clutters the post.
4. **Finance sidebar depth.** QAOA on real hardware is a rabbit hole. Run a token instance, or keep §7 a referenced-literature paragraph? Default: paragraph, unless the pilot shows a token QAOA run is cheap and clean.
5. **Cadence placement.** Does this get a demo number, or sit off-cadence as a `/special` or `/notes` entry? Editorial — it affects the index card, the methodology page's demo total, and whether the cross-read includes it in the demos-1–N consistency sweep. Default: off-cadence special, to protect the methodology total's meaning.

## Out of scope

- Any change to demos 1–N code, prose, JSON, the locked schema, or the methodology page's four commitments. This post lives outside them by design.
- Rolling a custom quantum simulator (use Qiskit Aer).
- Shor's algorithm beyond a toy Q-Day sidebar — a meaningful factoring instance cannot run on NISQ hardware, and the toy instances are widely "compiled-circuit" cheats. Reference, don't run.
- Any claim or implied claim of a quantum win on a finance workload.
- Treating the 2026 vendor advantage announcements as settled fact — cite them as claimed and recent.
- The capture itself (cloud job submission) and any spend approval — user task, like every reference-machine capture.

## Open items for the brief (once the pilot lands)

1. **If the free tier can't deliver a usable curve** (question 2), stop and surface the spend decision to the user before writing the brief — don't quietly assume a paid backend.
2. **If N-collapse is immediate** (question 1 resolves to N ≤ 4), reframe chart 1 from "collapse curve" to "single-N bar: ideal vs device vs classical," and say so in the brief rather than forcing a curve that isn't there.
3. **If a field-state recheck at brief time** shows a *classical-data or finance* advantage claim has appeared and held up, the survey section (§6/§7) needs rewriting and the takeaway softens — flag it, don't paper over it.
