# Crucible — Demo 05: workload escalation + framing revision brief

Companion to `BRIEF.md`, `crucible-handover.md`, and `05-allocators-brief.md` (the original implementation brief). This brief revises that brief in two ways — one workload change, one framing change — based on pre-headline calibration data captured on the reference machine.

The original brief stands except where this brief explicitly overrides it. Variants, hardware pinning of P/C, schema, chart contracts, post structure (with the framing-revision noted below), and acceptance for capture/build all remain as previously specified.

## Context

The calibration ladder CC was asked to run before headline capture has been completed by the user. Four rungs were captured. All raw JSON outputs are committed at `bench/calibration-notes/rung*-{malloc,arena}.txt`.

Summary of the rung-by-rung p99.9 latencies (ns):

| Rung | bg-pressure-hz | bg-live-allocs | malloc p99.9 | arena p99.9 | malloc / arena |
|------|----------------|----------------|--------------|-------------|----------------|
| 1    | 1 M (default)  | 512            | 328          | 344         | 0.95×          |
| 2    | 1 M            | 8192 (default) | 424          | 344         | **1.23×**      |
| 3a   | 2 M            | 8192           | 376          | 344         | 1.09×          |
| 3b   | 3 M            | 8192           | 376          | 328         | 1.15×          |

Two findings drove the re-scope decision:

1. **The defaults are the best-separating config.** Raising `bg-pressure-hz` past 1 M *narrowed* the malloc-vs-arena gap rather than widened it. The likely mechanism: at higher churn rate, the same malloc blocks get re-touched fast enough to stay warm in cache, masking the fragmentation tail that the slower rate exposes. The original brief's "if separation is below 2×, raise pressure up to 3M/s" escalation strategy assumes a monotonic relationship that doesn't hold for this workload.

2. **The 2× p99.9 target is unreachable on this knob.** Best observed is 1.23× at rung 2 (everything at default). Per open-item-5 of the original brief — "If at 3 M/sec the separation is still below 2× **stop and flag** — the demo's premise is in trouble and we need to re-scope before writing the post." — this is that stop.

The data is consistent with a real, defensible finding: arena p99.9 is rock-stable at 328–344 ns across all four configs (variance well within sample noise), while malloc p99.9 varies 328 → 424 depending on heap-pressure parameters, never better than arena. The direction of the original thesis holds; the magnitude is 30–50%, not 2×+.

## Decisions made by Opus

Two decisions are pre-made for CC; CC executes against them rather than re-deciding.

**Decision A — drop the 2× target from the demo's acceptance criteria.** The post will be written against the actual observed magnitude. "Arena allocator gives ~30% better tail under realistic background heap pressure" is the headline finding for the malloc-vs-arena comparison. The phrase "2× malloc/arena p99.9 ratio" is removed from the brief's open-item-5; the new wording is in §4 below.

**Decision B (light) — one workload-honesty escalation.** The original `background_pressure.h` spawns a single T_bg thread. Glibc's cross-thread-free cost manifests through arena-lock contention; a single background thread substantially undersells that contention because it competes for the arena lock only with the producer. Adding a second background-pressure thread on the same CCX more honestly represents "other subsystems sharing the heap," which is the demo's premise. CC adds support for N background threads and re-runs the calibration with `bg-threads ∈ {1, 2}` to confirm whether the wider workload also widens the malloc/arena gap. If it does, that becomes the headline config. If it doesn't, `bg-threads=1` remains the default and the freelist-vs-arena section carries proportionally more of the post.

Decisions **not** in scope for CC: re-pitching the demo, changing the variants, switching allocator under test (no jemalloc), expanding to NUMA crossing, or changing the order-pipeline framing. All of those remain ruled out by the original brief.

## Tasks

### 1. Add `--bg-threads N` CLI flag

Default value: `1` (matches current behaviour, so the existing calibration JSON remains comparable). Accept values 1–4. Values >4 are an error and the binary aborts with a diagnostic; the headline workload doesn't go that wide.

`pressure_config.bg_threads` is already serialised into the per-run JSON (the calibration outputs already show `"bg_threads":1`); wire the CLI value through to that field. Reject `--bg-threads 0` — that's what `--bg-pressure-hz 0` is for.

### 2. Multi-thread `T_bg` implementation

In `bench/demos/05-allocators/background_pressure.h`, generalise from one loop to N. Each thread:

- Has its own `std::vector<void*> live;` — **no shared state across T_bg threads.** Sharing `live` would introduce a different category of contention (a lock on the vector itself) that has nothing to do with allocator behaviour and would contaminate the measurement.
- Uses its own `std::mt19937` seeded deterministically — `42 + thread_idx` is fine; the value isn't important, the determinism is.
- Pacing is independent: each thread targets `bg-pressure-hz` ops/sec; aggregate background churn is `N × bg-pressure-hz`. The `bg-pressure-hz` CLI parameter retains its per-thread semantics; document this clearly in the JSON (see §3).
- Pre-fill identical to current code (512 initial allocations from the size-class set).

Pinning:

- `bg-threads=1`: core 6 (unchanged from current).
- `bg-threads=2`: cores 6 and 7. Producer 4, consumer 5, T_bg threads 6 and 7 — uses all of CCX1 and keeps the headline workload within one CCX, consistent with the rest of the post.
- `bg-threads=3` or `bg-threads=4`: would spill across to CCX0 and change the locality story. CC supports these values for completeness (the demo's `pressure_sweep` mode or a future side experiment may use them), but **the headline must not use bg-threads > 2.** This is a hard constraint.

Affinity verification at thread start is per the original brief: `sched_getcpu()` against expected core; mismatch aborts.

### 3. JSON schema additions

Two additive fields on the per-run object, both inside `pressure_config`:

- `bg_threads` — integer, already serialised. CC's only change here is wiring it from the CLI value rather than the hardcoded `1`.
- `bg_pressure_hz_total` — integer, equal to `bg-pressure-hz × bg-threads`. Optional but recommended; makes downstream chart axes unambiguous. If CC judges it adds avoidable schema surface, omit and document the per-thread semantics in the demo README instead.

Demos 01–04 JSON unchanged. The original brief's schema acceptance criterion still holds.

### 4. Calibration re-run

Run the same rung structure as the user's previous ladder, but varying `bg-threads` at the rung-2 defaults (the best-separating config so far):

- Rung 4a: `bg-threads=1`, `bg-pressure-hz=1M`, `bg-live-allocs=8192`. **This is identical to the user's rung 2 — use the existing JSON in `bench/calibration-notes/rung2-*.txt` rather than re-running. Pasting the file path into the calibration log is sufficient.**
- Rung 4b: `bg-threads=2`, `bg-pressure-hz=1M`, `bg-live-allocs=8192`.

Capture both variants (`cross-thread-malloc` and `arena-batch-handoff`) for the new rung. The `freelist-return-queue` variant is not required for the calibration step — its measurement story is independent of malloc/arena tail and is captured fully in the headline run later.

Output: append per-rung JSON to `bench/calibration-notes/rung4{a,b}-{malloc,arena}.txt` in the same single-JSON-object-per-file format the existing files use.

Decision rule for what to do with the result:

- **If rung 4b's malloc/arena p99.9 ratio ≥ 1.5×**: lock `bg-threads=2` as the headline default. Update the demo README and the post's "Background heap pressure" section accordingly (note in §5 below). The headline malloc-vs-arena story now has enough magnitude to carry a non-trivial fraction of the post.
- **If rung 4b's ratio is between 1.23× and 1.5×**: also lock `bg-threads=2` as the headline default (the wider workload is more honest regardless of the marginal gain). The post's framing balance shifts further toward the freelist-vs-arena section.
- **If rung 4b's ratio is ≤ 1.23× (no improvement over single-thread T_bg)**: keep `bg-threads=1` as the default. The post is anchored on freelist-vs-arena. Surface the negative result in the README — the negative result is itself a finding about how glibc's per-thread arenas insulate the producer thread from background-thread contention.

In all three cases, the 2× target is gone. CC does not raise pressure further; CC does not try `bg-threads=3` or `bg-threads=4` for the headline. If 4b's separation is below 1.23× and CC wants to flag that the result is surprising and worth a third rung before locking the decision, that's allowed — but only on its way to Opus, not as an autonomous escalation.

### 5. Update `05-allocators-brief.md` framing language

CC edits the original brief in-place. Three localised edits — the rest of the brief is unchanged.

**Edit 1.** In the "Background pressure thread (T_bg)" section, where the brief currently says:

> Calibration: the default background pressure for the paced headline measurement is **1,000,000 ops/sec** of mixed-size churn. Confirm during implementation that this is sustained on the reference machine (T_bg's pacing loop doesn't fall behind by more than ~5%) and that it produces a visible separation between malloc and pool variants in the headline latency distribution. If at 1M/s the separation is too small (<2× p99.9 ratio), raise to 3M/s. If T_bg can't sustain 3M/s on the reference machine, the demo is in trouble and we need to re-scope — flag immediately, don't paper over it.

Replace with:

> Calibration: the default background pressure for the paced headline measurement is **1,000,000 ops/sec per T_bg thread** of mixed-size churn, with the number of T_bg threads selected by the calibration step (see open item 5'). Confirm during implementation that each thread sustains its target rate on the reference machine (pacing loop doesn't fall behind by more than ~5%). The malloc-vs-arena p99.9 separation is expected to be approximately 30–50% under the chosen headline config; if the captured separation differs from this band by more than 10 percentage points, surface it before writing the post.

**Edit 2.** Replace open item 5 in the original brief with:

> 5'. **Calibration of background pressure default.** The headline config is `bg-pressure-hz=1M`, `bg-live-allocs=8192`, `bg-threads=N` where N ∈ {1, 2} is chosen by the calibration step in `demo-05-rescope-brief.md`. The malloc-vs-arena p99.9 separation under the chosen config is the working magnitude for the post — quote whatever the data actually shows. The earlier "2× p99.9 ratio" target was retired after the pre-headline calibration ladder showed it unreachable on this workload; the post will be written against the observed effect.

**Edit 3.** In the "Post structure (MDX)" section, the order of sections 7 and 8 is reversed:

- Section 7 becomes the freelist-vs-arena trade-off (previously section 8).
- Section 8 becomes the pressure sweep (previously section 7).

The intent: the freelist-vs-arena finding is now the post's structural climax rather than a coda. Update the section labels (`*The freelist-vs-arena trade-off*` ahead of `*Pressure sweep*`) and any internal cross-references. The pressure-sweep section's content doesn't change — it's still the proof that arena's tail is decoupled from heap pressure while malloc's isn't — it just lands after the trade-off discussion rather than before it.

All other framing language in the original brief stands. Do not edit the "What this doesn't show" list, the variant descriptions, the acceptance criteria, or the hardware-gotchas section.

### 6. Commit calibration evidence

The user has already moved the four existing rung outputs to `bench/calibration-notes/`. CC adds the new rung 4b output to the same directory and commits all of it with a single message referencing this brief:

```
demo 05: rescope calibration data (drops 2× target per demo-05-rescope-brief)
```

A short `bench/calibration-notes/README.md` summarises the table from §Context above, the decision taken in §4, and the path forward. One paragraph each is enough.

## Acceptance criteria

- [ ] `bench_05_allocators --bg-threads N` accepts integer 1–4, defaults to 1, aborts cleanly on 0 or >4.
- [ ] `bg_threads` field in JSON output reflects the CLI value.
- [ ] Multi-thread T_bg: each thread has its own `live` vector and own RNG; affinity is verified at thread start.
- [ ] `bg-threads=2` pins to cores 6 and 7; `bg-threads=1` to core 6 (unchanged).
- [ ] Rung 4b JSON captured at `bench/calibration-notes/rung4b-{malloc,arena}.txt`.
- [ ] Decision applied per §4 rules. `bg-threads` default in `benchmark.cpp` reflects the decision.
- [ ] `05-allocators-brief.md` edits 1, 2, and 3 applied; the rest of that brief unchanged.
- [ ] `bench/calibration-notes/README.md` exists with the rung table + decision summary.
- [ ] All four existing demos' JSON unchanged.

## Out of scope

- Headline capture (`run_one.sh 05-allocators`). Happens after this brief lands and the original brief's remaining acceptance criteria still apply.
- The cross-CCX side experiment. Original brief's hardware-gotchas section governs that, unchanged.
- MDX writing. Happens after headline capture, against the data the capture produces.
- The freelist variant in this brief's calibration step. The freelist's measurement story is independent; full data is captured during the headline run.
- Any change to the variants, the SPSC queue contract, the order struct, the consumer work weight, or the chart components.
- Re-running rungs 1, 2, 3a, 3b. The existing data stands; the brief is additive to it.
- The "calibration_drift_pct" field surfaced in the existing JSON. Not in scope for this brief; flag separately if anomalous in the 4b run.

## Open items for CC to flag

1. **Per-thread vs aggregate pacing semantics.** This brief specifies `bg-pressure-hz` as per-thread. If CC reads the existing implementation and finds the brief's "per-thread" reading is inconsistent with what the calibration JSON actually represents (e.g., if the current single-thread implementation's `bg-pressure-hz` was already specifying aggregate), surface this before locking. The fix is documentation, not code, but it has to be right.

2. **Rung 4b ratio surprises.** If 4b's malloc/arena p99.9 ratio is anywhere outside the band 0.9× to 2.0×, stop and flag before applying the §4 decision. The expected range based on rung 2 (1.23× at single-thread) extending to multi-thread is roughly 1.2×–1.6×; an extreme value either way is calibration-suspect.

3. **T_bg lockstep at high churn.** With deterministic seeds offset by 1, two T_bg threads may exhibit correlated allocation patterns (similar size choices at similar times). If the measured aggregate churn rate consistently falls below `2 × bg-pressure-hz` by more than 5%, investigate whether the threads are blocking each other in glibc's arena. Don't paper over with a random-seed change; surface the observation first.

4. **Core 7 isolation for `bg-threads=2`.** Verify that the bench harness's preflight check (`assert_isolated_cores`) accepts core 7 being used by T_bg. If the check is strict about which cores are "available for benchmark work," extend its definition rather than disabling the check.

5. **README copy.** The user's `bench/calibration-notes/README.md` is short and factual — it is not promotional text and not a substitute for the demo's own README. If CC wants to add the same magnitude-band caveat ("expected p99.9 separation 30–50%") to the demo 05 README itself rather than only the calibration-notes README, do that and flag the duplication for Opus to deduplicate later.

## Notes for CC

- The original brief budgeted ~4–6 days of CC time, staged. This brief is a small mid-stream revision; budget ~half a day for tasks 1–3 (CLI + multi-thread + JSON), then a calibration re-run, then the in-place brief edits. Don't reopen the demo's architecture.

- The calibration data is the evidence. If something CC sees during implementation suggests the rung-2 number is suspect (e.g., the 0.0000% calibration drift on most rungs looks artificial — should it really be exactly zero?), surface it rather than silently working around it. The four committed JSON files are the source of truth for the framing change; if they're wrong, the framing change is wrong.

- The framing revision strengthens the post, it doesn't weaken it. The original 2× target was aspirational based on what was hoped a glibc tail might look like under stress; the actual finding is more nuanced and the freelist-vs-arena tradeoff carries it cleanly. The post Opus and the user are writing is a better post than the original brief's headline would have produced.

- Do not start the MDX. The MDX is written after headline capture, against post-capture data, per the original brief. This brief explicitly does not authorise post writing.
