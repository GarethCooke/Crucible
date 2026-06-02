# Crucible — special edition pilot scope: "Measuring the Gap" (Grover on NISQ)

Throwaway pilot scope, for Opus/user. **Not a committable brief, and not chart-ready output** — same shape as the demo 6/7 §1 pilots and the demo 9 pilot. Companion to `quantum-measuring-the-gap-scope.md` (the master scope sketch); this doc structures the runs that resolve that doc's §A questions before any implementation brief is written. The implementation brief is written *after* this pilot lands, per the demo 5/6/7 lesson and the brief-author anti-pattern against committing numerical targets pre-calibration.

Nothing here is committed to `site/` or git history. Runs live in `Crucible/quantum/pilot/`; raw job dumps go to `Crucible/quantum/pilot/scratch/` (gitignored). The pilot produces *notes for the brief*, nothing else.

## Context

- The master scope fixes the thesis (measure the gap between the √N promise and the silicon; classical wins decisively today; show precisely why). That is not in question here. This pilot only calibrates the *shape* of the evidence.
- Field-state recheck is **done** (2026-06-02). No survey rewrite needed: the 2026 practical-advantage claims remain quantum-simulation/physics class (Q-CTRL Fermi-Hubbard on IBM hardware the headline), none classical-data or finance. The finance angle stays "promissory, no production win" — upgraded to cite a real on-hardware par result rather than pure literature. Master-scope open-item #3 did **not** fire.
- Literature priors on Grover-on-NISQ are strong and bound the pilot risk: better-than-classical success has been shown only at n=3 and n=4 qubits; the largest implementation (n=8) did not beat classical; even n≤5 better-than-classical required error suppression + measurement-error mitigation. So the collapse this post is built on is well-attested, and Q1 (below) is very likely to resolve at the low end.
- Environment is set: `Crucible/quantum/.venv` (Windows side, fine for all of this), `qiskit` + `qiskit-ibm-runtime` + `qiskit-aer` installed, IBM Open Plan account live (10 min QPU runtime per 28-day rolling window; 180-min one-time unlock available after 20 cumulative minutes logged).
- Starter script: `grover_pilot.py` (companion to this doc). Aer-by-default; hardware submission is a separate, explicit call.

## Resolves these master-scope §A questions

| Q | Question | Resolved by | Verdict needed |
|---|----------|-------------|----------------|
| 1 | Largest N where the real device beats random guessing | Run 1 | The N at which device success probability falls to ~1/N |
| 2 | Free-tier sufficiency / paid-spend decision | Run 0 | QPU-seconds per circuit → does the full capture fit free tier |
| 3 | Grover vs a shallower contrast (Bernstein–Vazirani) | Run 2 | Does BV stay clean where Grover drowns → contrast pair in or out |
| 4 | Finance sidebar depth (token QAOA vs paragraph) | Run 3 (contingent) | Default paragraph unless a token QAOA run is cheap and clean |
| 5 | Cadence placement (`/special` vs demo number) | editorial | Not a run — decide at brief time (default: off-cadence special) |

## Runs

Run them in order. Each hardware submission is gated on the circuit being verified correct on Aer first (free, local) — a wrong circuit burns real minutes on noise. Do not submit anything to hardware that has not first returned the marked state as the clear mode on the simulator.

### Run 0 — Meter one job (resolves Q2). Do this first, day 1.
- Build the smallest Grover: n=3 (N=8), one marked state.
- Verify on Aer: the marked basis state is the dominant outcome at the optimal iteration count.
- Submit that **one** verified circuit to hardware via SamplerV2 at the intended shot count (start at 4096).
- Read QPU execution time from `job.usage()` **and** the Platform Workloads page (the page is ground truth; the API value is a convenience). Record both.
- Multiply out: QPU-seconds × (N points) × (marked-state samples) × (outer reps) × (mitigation overhead factor). That product, against 10 min/window and the 180-min unlock, *is* the answer to Q2.
- **If one verified 3-qubit job already eats an implausible fraction of the 10-min window, stop and surface the spend decision before Run 1** — do not quietly assume a paid backend (master-scope open-item #1).

### Run 1 — Success-probability sweep (resolves Q1, the headline).
- Sweep n ∈ {3, 4, 5} (N ∈ {8, 16, 32}). Aer-verify each before submitting.
- For each N: report device success probability against the Aer reference (near 1.0) and the classical floor (1/N). Average over multiple marked states per N, not a single cherry-picked target — the single-marked-state numbers in the literature look better than the honest multi-state average, and the post's credibility depends on the honest one.
- Record where the device curve falls to ~1/N. That N is the collapse point and bounds chart 1's shape.
- **If collapse is immediate — N ≤ 4 is already pure noise — do not force a curve.** Note it, and the brief reframes chart 1 from "collapse curve" to a single-N bar (ideal vs device vs classical), per master-scope open-item #2. The thesis survives either way; the chart shape does not.
- Apply error suppression (dynamical decoupling) + measurement-error mitigation as available, since the literature says better-than-classical isn't observed without them. Record what was applied — it's part of the honest method, and a mitigation-on vs mitigation-off pair may itself be a teachable panel (flag, don't commit).
- **Teaching-chart data (Aer-only, free).** While verifying, also run the iteration sweep at one N (n=4 is the clean choice) via `grover_pilot.py --n 4 --sweep`. This captures P(marked) vs iteration count — the amplitude-amplification oscillation: ~1/N at zero iterations, climbing to a peak at the optimal count, then *falling* past it (over-rotation). It costs no QPU time, it's the ideal behaviour the noisy device fails to reproduce, and it's the data behind the "how Grover actually works" explainer. Capture it regardless of how the inline-vs-companion explainer question settles, so the teaching chart is de-risked before the brief.

### Run 2 — Shallow-circuit contrast (resolves Q3).
- Build Bernstein–Vazirani at comparable n. Aer-verify (BV recovers the hidden string in one query, near-deterministic).
- Submit at the same N points as Run 1.
- The question: does the shallow circuit stay clean where deep Grover drowns? If yes and the contrast reads in one chart without clutter → contrast pair is in ("the shallow circuit works, the deep one doesn't"). If it muddies the headline → out, keep the post on Grover alone.
- This is a budget call as much as an editorial one — it roughly doubles the hardware spend. Weigh against the Run 0 number before committing.

### Run 3 — Token QAOA (contingent, resolves Q4). Default: do not run.
- Only attempt if Runs 0–2 leave comfortable budget headroom **and** a 2–4 asset toy QAOA instance transpiles to something the backend can run cleanly.
- Default outcome is **skip** — §7 stays a referenced-literature paragraph (now citable to the real on-hardware par results from the field recheck). Run this only if it's demonstrably cheap and clean; a noisy half-result is worse than an honest paragraph.

## Exit criteria (what "pilot done" means)

The pilot is done when the notes file can state, with hardware evidence:
- The collapse N (Q1), and therefore whether chart 1 is a curve or a single-N bar.
- The measured QPU-seconds per circuit and the resulting full-capture budget (Q2), and therefore whether free tier + the 180-min unlock suffices or a spend decision is live.
- A go/no-go on the BV contrast pair (Q3) and the QAOA sidebar (Q4).
- The mitigation stack that was needed to see signal, recorded for the method section.

None of these is a committed number in advance — they are outcomes the runs report.

## Out of scope

- Any committed JSON, chart component, MDX, or `site/` change. This is a pilot; its only output is notes.
- Any change to demos 1–9 code, prose, JSON, the locked perf schema, or the methodology page's four commitments. This post lives outside them by design.
- The C++ classical linear-scan baseline timing. That is a later, separate capture on the **Ubuntu reference rig** (isolated cores, perf, turbo off, the normal Crucible way) — *not* the convenient Windows/MinGW toolchain, which is fine for developing the baseline but must not become the source of the published microsecond figure. The pilot does not need it.
- Rolling a custom simulator (use Aer). Shor beyond a reference (does not run meaningfully on NISQ).
- Spend approval and the cloud job submissions themselves — user tasks on the account, like every reference capture.

## Open items to flag during the pilot

- If `job.usage()` and the Workloads page disagree on QPU time, trust the Workloads page and note the discrepancy — the API surface here has moved and may be reporting a different quantity.
- If the SamplerV2 result-access path in `grover_pilot.py` errors (the V2 PUB/result API is the most version-sensitive part of the script), fix it against current Qiskit docs and note the working pattern — do not assume the scaffold's exact calls are current.
- If a 28-day window's 10 minutes runs out mid-sweep, stop and wait for the window to roll rather than reaching for paid spend, unless Run 0's budget math already justified the spend and you flagged it.
- If the honest multi-marked-state average in Run 1 collapses noticeably faster than single-state runs, that *is* the result — report the average, not the flattering single-state number.
