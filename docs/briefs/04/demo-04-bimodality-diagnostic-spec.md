# Demo 04 overload-bimodality diagnostic — instrumentation brief + rig protocol

Decision (A), 2026-06-05. Same shape as `crucible-demo-04-spike-diagnostic-brief.md`: a small CC instrumentation pre-task, then a reference-machine protocol for Gareth. No MDX edits ride this; the demo-04 rescope is gated on its outcome.

## Question under test

Between the 2026-05-18 capture (kernel 6.8.0-111) and the 2026-06-05 capture (6.8.0-117), the over-saturation behaviour of mutex-condvar and lockfree-boost flipped qualitatively: the deep-queue equilibrium (mutex p50 ~190 µs at capacity; boost p50 10–19 µs at intermediate depth; boost ceiling ~14.9 M/s) vanished, replaced by a shallow equilibrium (mutex p50 ~1 µs, cap 4.05 M/s; boost p50 ~424 ns, ceiling 17.2–18.2 M/s). Hand-rolled is qualitatively stable but its stall spike wandered (16 MHz → 28/50 MHz), as the intermittency model predicts.

## Registered hypotheses (before measurement)

- **H1 — bimodal run-to-run.** Both equilibria are stable at the same operating point on the current kernel; which one an iteration settles into is stochastic (startup phase, first wake timing). Discriminating observable: mixed deep/shallow iterations within the same invocation set on kernel 117.
- **H2 — deterministic kernel shift.** 111→117 changed futex/scheduler behaviour such that the deep mode is no longer reachable. Discriminating observable: all-shallow on 117 across ≥30 iterations per point; (optional Phase 2) all-deep when re-run under the old kernel.
- **H3 — neither.** All-deep again, or something unclassifiable → the 2026-06-05 capture was itself anomalous; stop and discuss before touching anything.

No prose is written until one of these wins.

## Phase 0 — CC instrumentation pre-task

**File:** `bench/demos/04-spsc-queue/benchmark.cpp`, post-run analysis region only (same constraint as the spike-diagnostic brief: producer/consumer hot loops and timestamping byte-for-byte unchanged).

### Task 0.1 — per-iteration stats line

The binary currently merges its 5 internal iterations into one histogram (`stats.count` = 5M, `items_measured` = 1M). Mode flips between iterations are invisible in the merge. Emit, per iteration, one stderr line in the DIAG family:

```
ITER <variant> mode=<mode> offered=<hz> k=<i>/<n>: p50=NNN ns  p99.9=NNN ns  mean=NNN ns  achieved=N.NN M/s
```

computed over that iteration's items only. The merged JSON output is unchanged — no schema touch.

### Task 0.2 — mean queue depth via Little's law

Append to the same ITER line: `depth_mean=NN.N` computed as `achieved_rate × mean_latency` (Little's law over that iteration; both quantities already computed in 0.1 — no new measurement, no hot-loop touch). Classification key: deep mode ⇒ depth_mean in the hundreds (toward 1024); shallow mode ⇒ single digits.

### Task 0.3 — iterations flag (conditional)

If the binary does not already expose the internal iteration count as a CLI flag, add `--iterations N` (default 5, current behaviour). Not strictly required for the protocol — the per-ITER lines carry the signal — but it makes targeted reruns cheaper. Skip if it already exists; report which.

### Phase 0 acceptance

- Builds clean; all demos build; `git diff` confined to post-run analysis + arg parsing.
- A local run prints exactly N ITER lines per invocation with plausible non-negative values, and `depth_mean` ≈ achieved × mean within rounding.
- Emitted JSON byte-compatible with the existing schema (no new fields, same shapes).
- Existing DIAG (max_enq_gap / max_deq_gap / backlog) lines still print — the protocol piggybacks on them for stall incidence.

## Phase 1 — rig protocol (Gareth)

Preconditions: `sudo cset shield --reset`, governor performance, cpb off (verify), headless `multi-user.target`, **`perf_event_paranoid` ≤ 0 (verify — it now persists, but check)**, standard pinning.

For each variant in {mutex-condvar, lockfree-boost, lockfree-handrolled} × each point in {saturated mode; sweep points 16152813 Hz, 28419019 Hz, 50000000 Hz}:

- 10 invocations, stderr captured per invocation (→ 50 ITER samples per variant×point with default iterations=5).
- Keep wall-clock order in the logs (stall clustering was time-correlated last time; mode flips may be too).

Total ≈ 120 invocations; at ~1–7 s each plus overhead, well under an hour. A wrapper in the spirit of `uop_diag.sh` is fine — say the word and I'll generate one against the actual CLI once Phase 0 lands.

**Classification rule (mechanical):** an iteration is _deep_ if `depth_mean > 100` (equivalently p50 > 10 µs), _shallow_ if `depth_mean < 10`; anything between is _indeterminate_ and reported, not binned.

**Deliverable:** the raw stderr logs (or a tarball). I'll do the mode-count table and the H1/H2/H3 call.

## Phase 2 — optional, only if Phase 1 is all-shallow (H2 leaning)

Boot the previous kernel (6.8.0-111 should still be in GRUB; `grep menuentry /boot/grub/grub.cfg` to confirm) and repeat Phase 1 at reduced scope (mutex + boost, saturated + 28.4 MHz, 5 invocations each). All-deep under 111 + all-shallow under 117 = H2 confirmed with the cleanest possible evidence. If the old kernel is no longer installed, skip — H2 can stand on Phase 1 plus the two captures, stated with appropriate hedging.

## Interpretation → rescope mapping

| Phase 1 outcome                               | Verdict             | Demo 04 rescope direction                                                                                                                                                                |
| --------------------------------------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mixed deep/shallow iterations on 117          | H1 bimodal          | Overload section rewritten around the two equilibria as the _finding_; headline recapture moves to mode-aware reporting and ≥20 iterations/point; merged percentiles at overload retired |
| All-shallow on 117 (±Phase 2 all-deep on 111) | H2 kernel-sensitive | Overload section rewritten around environment sensitivity, with both captures shown; claims pinned to kernel version; spike prose generalised to position-free wording                   |
| All-deep, or unclassifiable                   | H3                  | Stop and discuss — the 06-05 capture itself becomes the object of investigation                                                                                                          |

Either H1 or H2 also kills, definitively: the "14.7 vs 14.9 coincidence" paragraph, the "~3× slower Boost consumer" claim (boost drains 17–18 M/s shallow-mode), the mutex 190 µs plateau as an unconditional claim, and every position-specific spike sentence.

## Out of scope

- All MDX edits, chart-component changes, and the clamp-threshold question — these belong to the rescope brief after the verdict.
- Restoring queue-depth fields to the published JSON schema. Flagged as a rider for the rescope: the shipped prose cites depths that exist in neither JSON, so whatever survives the rescope must either publish `depth_mean` per run or stop citing depths. Deliberate schema decision, taken then.
- The headline recapture itself (runs-per-point decision is an output of this diagnostic, not an input).
- Demo 02's pending hardening brief — separate, though this protocol's paranoid check is a preview of it.

## Open items

1. Phase 0 may reveal the 5 internal iterations share process-level warmup state (e.g. one queue allocation reused) — if so, iteration-level mode flips and invocation-level flips are different phenomena; CC should report how iterations are structured so the protocol's unit of analysis is right.
2. If DIAG lines show the hand-rolled stall incidence has changed materially from the May diagnostic (~8/50 runs), note it — environmental interference level is a moving target and the rescope prose should avoid hard incidence numbers.
