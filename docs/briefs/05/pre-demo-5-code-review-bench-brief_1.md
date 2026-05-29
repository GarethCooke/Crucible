# Crucible — pre-demo-5 code review brief (`bench/`)

Companion to `BRIEF.md` and `crucible-handover.md`. Full code review of the C++ surface across the four shipped demos. **Use the `code-review` skill** — it defines methodology and DRY priorities. This brief layers project-specific focus areas on top.

## Scope

In scope:

- `bench/common/` — `machine_info.h`, `perf_wrapper.h`, `stats.h`, `histogram.h`, any other shared headers.
- `bench/demos/01-branch-prediction/`
- `bench/demos/02-false-sharing/`
- `bench/demos/03-simd-blackscholes/`
- `bench/demos/04-spsc-queue/`
- `bench/scripts/` — `run_one.sh`, `run_all.sh`.
- `bench/tools/` — `parse_perf.py` and anything else.
- `bench/CMakeLists.txt` and per-demo `CMakeLists.txt`.

Out of scope:

- Anything under `site/` (separate brief).
- Recapturing data.
- Scoping new demos.
- Tuning the harness for speed (correctness-first).

## Focus areas

The skill defines general code-review priorities. On top of those, the following are project-specific concerns that warrant disproportionate attention. None of these are exhaustive — they're places the reviewer should _not_ skim past.

1. **DRY across demos.** Demo 1 was the v1 demo; by demo 4 the team learned patterns (verify-warmup flags, paced vs sweep modes, `percentile_convention` in JSON, `rdtscp_ordered`, defensive `static_assert`s). Flag where older demos use weaker patterns since refined, and where shared logic is re-implemented per demo instead of lifted to `common/`.

2. **Harness asymmetries between variants within a demo.** Demo 4's fix-up brief flagged timestamp placement (mutex variant timestamping inside the lock) and queue-bound asymmetry (unbounded `std::queue` vs bounded lock-free). Audit whether similar asymmetries exist in other demos:
   - Demo 1: do `sorted` and `unsorted` use identical compile flags, pinning, warmup?
   - Demo 2: do `padded` and `unpadded` use identical iteration count, barrier topology, fill data?
   - Demo 3: do `scalar_libm`, `scalar_poly`, `sse2`, `avx2_fma` use identical warmup and inner-loop framing?

3. **Defensive `static_assert`s.** Demo 4 added `static_assert(sizeof(PaddedAtomic) == 64, ...)` and head/tail cache-line separation asserts. Demo 2's `Strategy` / `PaddedStrategy` has analogous structural assumptions — confirm `static_assert`s protect them. Flag any other place a layout/alignment assumption silently underpins a demo's claim.

4. **Volatile / atomic usage in demo 2.** The post defends `volatile double` as the minimal mechanism to force the memory traffic the demo is about (vs `std::atomic_ref`, which would add fence overhead irrelevant to the false-sharing story). Confirm the code uses `volatile` consistently and not a hybrid. Confirm the CI assertion on `objdump` output (per `02-false-sharing-remediation-brief.md` §4) is wired into the build and actually runs.

5. **TSC and timing in demo 4.** `rdtscp_ordered` correctness, TSC calibration drift handling, `percentile_convention` reporting (must be bucket midpoint per the fix-up brief — verify the code matches the JSON claim), histogram top-bucket spillover (must be zero; the post's claim depends on it).

6. **Script robustness.** `run_one.sh` should fail loud — not silently fall back — when any of the following hold at capture time:
   - `CRUCIBLE_TURBO` is unset.
   - `/sys/devices/system/cpu/isolated` does not match the expected value.
   - SMT is enabled (`/sys/devices/system/cpu/smt/active` ≠ 0).
   - Governor is not `performance`.

   Audit each precondition: is it checked? Does the failure message name the fix? Does the script exit non-zero?

7. **`parse_perf.py`.** This file was the source of demo 2's parser bug (per `02-false-sharing-remediation-brief.md` §1 — Google Benchmark `real_time` is already per-iteration, but it was being divided by `iterations` again). Verify the fix is in place and look for analogous double-counting in other parse paths — e.g. demo 1's branch-miss-per-op derivation, demo 3's IPC, anywhere `runs[]` aggregates are computed.

8. **Idiom and style consistency.** C++20 feature usage, error handling, RAII, `#include` hygiene, naming. Flag drift between demos (e.g. demo 1 using one pattern, demo 4 using another for the same thing). The reviewer should pick the better pattern and recommend it, not default to "leave alone."

## Deliverable format

Output a single findings document at `pre-demo-5-bench-code-review-findings.md` in the repo root. Structure:

```
# Crucible bench/ code review — findings

## Critical
(Issues that affect correctness of any post's shipped claims, or would block a future demo from being defensible.)

## Material
(Issues that don't break shipped claims but should be fixed before scoping demo 5: real DRY violations, missing defensive asserts, asymmetric harness paths, etc.)

## Minor
(Stylistic, naming, comments. Worth a sweep but not urgent.)
```

Each finding contains:

- **Location:** file + line range, or function name.
- **Observation:** what's there.
- **Problem:** why it matters — concrete: which post's claim is at risk, or what future demo it'd block.
- **Suggested fix:** one-line or short paragraph.
- **Severity:** critical / material / minor.

**Do not implement fixes in this task. Findings only.** Fixes get scoped into remediation briefs by Opus after triage.

## Acceptance

- Findings doc exists at the named path.
- Every demo (01, 02, 03, 04) has been touched — an explicit "no critical or material findings" note is fine if true.
- Every focus area above has been considered — explicit "n/a" or "no findings" per area is fine.
- Critical findings, if any, reference a specific shipped post claim they affect.

## Out of scope

- Implementation of any fix.
- Site-side code (separate brief).
- New demos.
- Performance-tuning the harness itself.

## Open items for CC to flag

- If any focus area is unverifiable from code alone (e.g. a claim about TSC stability that needs a live machine), say so in the findings doc.
- If a finding requires recapture to confirm, mark it explicitly so the user knows.
- If the `code-review` skill's general priorities surface something not covered by the focus areas above, include it.
