# Crucible — Demo 06 calibration pilot brief

Pilot brief for §1 of `demo-06-plan.md`. Throwaway. No JSON ships, no chart component is touched, no code lands on a branch. Output is a notes file under `bench/calibration-notes/` that `06-aos-vs-soa-brief.md` (§2) reads to set struct size, field count, sweep ranges, and hot-column grain.

## 1. Context

Demo 5's detour notes recorded the lesson: the implementation brief had committed to a 2× p99.9 target that the workload couldn't deliver, and the rescope came mid-implementation rather than pre-implementation. Demo 6's plan therefore inserts a pre-brief calibration step. This is it.

The demo 6 thesis ("for a wide struct under a sparse hot-column scan, SoA wins at small K and the crossover with AoS is not where you'd naïvely place it") is more qualitative than demo 5's quantitative magnitude claim, so the pilot's bar is lower — but it's still where every parameter in §2's brief gets pinned to empirical reality on the reference machine.

What §2's brief will need from this pilot:

- A final struct size and field count, with one-line rationale.
- A working-set sweep that spans L1 → DRAM with at least two points per tier.
- A hot-column-fraction sweep (`K` out of `FIELDS`) that brackets the AoS↔SoA crossover.
- Confirmation that at least one working-set tier shows a multiple-of-2 separation between layouts at some K — i.e. the headline picture exists at all on this machine.
- Any surprises (TLB cliffs, prefetcher behaviour, anomalies the prose will have to address).

What this brief is **not**:

- Not a harness for the production demo. The pilot harness is single-file, no Google Benchmark dependency, no JSON output, no perf-counter capture. None of it gets committed.
- Not a magnitude commitment. The acceptance criterion is "the picture is visible", not a specific factor.
- Not a methodology-locked capture. Headless boot is preferred but not required for the pilot; we're not shipping these numbers.

## 2. Goals (verbatim from §1 of the plan, with concrete criteria)

**A. Cache-tier staircase cleanly visible at the chosen struct size.**

Concrete: on the AoS layout at K = FIELDS (touch every field), the `ns_per_op` curve across N shows at least three visibly distinct plateaus: L1-resident, L2-resident, L3-or-DRAM. "Visibly distinct" = each plateau is ≥1.5× the previous one. If the staircase is flat or has only one inflection, the struct size is wrong (either too small, so everything fits, or too large, so even the smallest N spills) and §4's decision rules apply.

**B. AoS↔SoA crossover exists at a reasonable point in the access-pattern axis.**

Concrete: at some working-set tier `N`, AoS is _faster_ than SoA at K = FIELDS, and SoA is _faster_ than AoS at K = 1. "Reasonable point" means the crossover K falls strictly inside the open interval (1, FIELDS) — not at the boundary. If AoS wins at every K or SoA wins at every K, the post has no story.

**C. At least one working-set tier shows a multiple-of-2 separation between layouts.**

Concrete: at some `(N, K)` pair, `max(t_AoS, t_SoA) / min(t_AoS, t_SoA) ≥ 2.0`. This is the demo's headline picture existing at all. The expected location is `K = 1` (or small) at an L3- or DRAM-resident `N`, where AoS pulls a full cache line per element and uses 1/16 of the bytes.

All three are eyeball-grade on the pilot data; precise numbers come from §4's post-harness re-calibration.

## 3. Reference-machine cache geometry

AMD Ryzen 7 3800X, Zen 2 (per `BRIEF.md`). Pinning to one isolated core within a single CCX.

| Tier | Size           | Element count at 64 B/struct | at 128 B/struct | at 256 B/struct |
| ---- | -------------- | ---------------------------- | --------------- | --------------- |
| L1D  | 32 KB / core   | 512                          | 256             | 128             |
| L2   | 512 KB / core  | 8 192                        | 4 096           | 2 048           |
| L3   | 16 MB / CCX    | 262 144                      | 131 072         | 65 536          |
| DRAM | anything above | —                            | —               | —               |

Caveat: these are _raw_ cache capacities; with eviction policy, prefetcher state, and L3 sharing across the four cores in the CCX (under isolation, the other three are idle, so effectively all of L3 is available to the pinned core), practical residency is somewhat less than nominal. Treat the boundaries as the centre of a ~2× transition zone, not a hard step.

## 4. Candidate parameters (the starting point — §1 may move them)

### 4.1 Struct shape

**Default proposal:** 128 B / element, 16 × 8 B fields (`double` or `int64_t`).

Rationale:

- 64 B is one cache line. AoS at K = 1 still pulls one cache line per element and SoA also pulls one cache line per element (no wasted bandwidth on AoS) — no crossover, demo dies.
- 128 B is two cache lines. AoS at K = 1 pulls 128 B per element, uses 8 B of it (6.25 % bandwidth efficiency). SoA at K = 1 pulls one cache line per 8 elements. Bandwidth ratio at K = 1 is 16:1 in SoA's favour at DRAM. Crossover at intermediate K is the demo's headline.
- 256 B is four cache lines. Same story as 128 B but stronger. Use this if 128 B's separation at K = 1 is weaker than 2× in goal C.
- Field count 16 gives a useful K-sweep grain (1, 2, 4, 8, 16) — five points, log-spaced on a log axis, with K = 1 ≈ "the column-store ideal" and K = FIELDS ≈ "the row-store ideal".

If goal A or C fails at 128 B × 16, escalate to 256 B × 16 (wider, more cache lines wasted on AoS at small K) or to 256 B × 32 (finer K-axis granularity). Don't shrink to 64 B — the post has no story there.

### 4.2 Inner-loop computation

**Sum reduction**, per the plan's default. Each touched field is added to a running total per layout. One double per element per field is what the binary actually fetches; auto-vectorisation on a sum reduction is well understood and won't surprise the §2 brief.

Avoid: `bytes-touched-only` (memcpy-style memory-bound loop, no compute) — produces meaningless `ns_per_op` and isolates memory cost in a way that doesn't translate to the option-chain framing. The post wants to show "doing useful work over wide data", not "doing nothing over wide data".

Avoid for the pilot: `-ffast-math`, intrinsics, explicit pragma vectorisation. Scalar `-O3 -march=native` is what we want — auto-vec will fire on SoA, won't fire on the AoS gather pattern, and that's part of what the demo measures. The compiler doing its default thing here is the realistic case the post is about.

### 4.3 Working-set sweep

Eight log-spaced points across L1 → DRAM. At 128 B / struct:

| N         | Bytes  | Expected tier |
| --------- | ------ | ------------- |
| 64        | 8 KB   | L1-resident   |
| 256       | 32 KB  | L1 boundary   |
| 1 024     | 128 KB | L2-resident   |
| 4 096     | 512 KB | L2 boundary   |
| 16 384    | 2 MB   | L3-resident   |
| 65 536    | 8 MB   | L3-resident   |
| 262 144   | 32 MB  | L3 boundary   |
| 1 048 576 | 128 MB | DRAM-bound    |

Two points per tier is enough to see plateaus; eight points total is enough that an eyeball plot reads as a staircase rather than a wedge.

If the struct size is escalated to 256 B, halve every `N`. The byte sizes stay roughly the same and the expected tier in the rightmost column doesn't change.

### 4.4 Hot-column-fraction sweep

`K ∈ {1, 2, 4, 8, 16}`. Five points covering 6.25 % → 100 % field touch. For each K, the inner loop sums fields 0 .. K-1 (a contiguous prefix). Sequential field selection is fine for the pilot — the post's option-chain framing is "scan the bid/ask/vol columns", which corresponds to a prefix.

### 4.5 Access pattern

Sequential index, per the plan's resolved open item. Element i, then i+1, etc. No prefetch hints, no streaming-store hints, no `__builtin_expect`. Plain `for` loop, let the compiler and the hardware prefetcher do what they do.

## 5. Throwaway harness sketch

Single-file C++20. No CMake, no Google Benchmark, no JSON. Build, run, eyeball stdout.

### 5.1 Layout

```cpp
// bench/calibration-notes/06-aos-vs-soa-pilot/pilot.cpp
// Build: g++ -O3 -march=native -std=c++20 -o pilot pilot.cpp
// Run:   sudo -E cset shield --exec -- ./pilot 128 16 1048576

#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <random>
#include <vector>

constexpr int FIELDS = 16;
using Field = double;

struct alignas(64) AoSElement {
    Field f[FIELDS];
};

double bench_aos(const AoSElement* a, size_t n, int k) {
    double sum = 0.0;
    for (size_t i = 0; i < n; ++i)
        for (int j = 0; j < k; ++j)
            sum += a[i].f[j];
    return sum;
}

double bench_soa(const Field* const* cols, size_t n, int k) {
    double sum = 0.0;
    for (int j = 0; j < k; ++j) {
        const Field* col = cols[j];
        for (size_t i = 0; i < n; ++i)
            sum += col[i];
    }
    return sum;
}

template <typename F>
double median_ns(F&& fn, size_t n, int k) {
    using clk = std::chrono::steady_clock;
    // 3 warmup, 5 timed; ignore warmup, median of 5
    for (int i = 0; i < 3; ++i) (void) fn();
    double samples[5];
    for (int i = 0; i < 5; ++i) {
        auto t0 = clk::now();
        double s = fn();
        auto t1 = clk::now();
        // sink to defeat DCE
        if (s == 0.12345678901234567) std::abort();
        double total_ns = std::chrono::duration<double, std::nano>(t1 - t0).count();
        samples[i] = total_ns / (double(n) * double(k));  // ns per (element, field touched)
    }
    std::sort(samples, samples + 5);
    return samples[2];
}
```

### 5.2 Driver

Two nested sweeps in `main`: outer over N (eight values from §4.3), inner over K (five values from §4.4). For each cell, run AoS and SoA. Print one CSV line per (layout, N, K): `layout,N,K,ns_per_op`.

Allocations outside the timed loop. SoA columns are 16 separate `std::vector<Field>` to make the column-strided access pattern explicit; aligning each to a 64-byte boundary is enough.

Total runtime budget: ≤2 minutes per pass. With 8 N × 5 K × 2 layouts × 5 reps × ~50 ns/element at N=1M, the worst cell is ~250 ms, total ≪ 60 s.

### 5.3 Output

Stdout to a file:

```bash
sudo -E cset shield --exec -- ./pilot 128 16 > results.csv
```

The user can then `gnuplot` or paste into a spreadsheet. No formatting beyond the CSV is required.

## 6. Capture environment

The pilot does not have to match production capture-environment rigour, because nothing ships. But results that diverge from the production capture environment are useless for informing §2, so default to production:

- Reference machine.
- Headless boot is preferred but not required for the pilot. (Headless is locked-in for §6's headline capture.)
- `sudo cset shield --reset` before the pilot run, then `sudo cset shield --cpu=4 --kthread=on` to set up shielding. Same as demos 1–5.
- `sudo -E cset shield --exec -- ./pilot ...` to run inside the shield. The `-E` preserves the env, per `04-sudo-env-fix-brief.md`.
- Turbo off: `echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost`.
- Governor performance: `sudo cpupower frequency-set -g performance`.
- SMT disabled at BIOS or pin to physical core only.

`CRUCIBLE_TURBO=off` doesn't have to be set for the pilot binary — it's not consulted by this throwaway harness. The actual hardware turbo state is what matters, and the `echo 0 > .../boost` line above sets it.

## 7. Observation protocol

1. Build the pilot binary with the default 128 B × 16 fields.
2. Run inside the shield. Redirect stdout to `results.csv`.
3. Pivot to a table or quick plot: `ns_per_op` on Y, `N` on X (log axis), one line per `(layout, K)`. Ten lines total (2 layouts × 5 K values).
4. Check goal A: does the AoS K=16 line show ≥3 plateaus with ≥1.5× ratios? _(Yes / no.)_
5. Check goal B: does AoS beat SoA at K=16 _and_ lose to SoA at K=1, at any single `N`? _(Yes / no, and at which N.)_
6. Check goal C: at any `(N, K)`, does `max / min` exceed 2.0? _(Yes / no, and at which `(N, K)`.)_
7. Write the answers and the underlying CSV into the notes file (§9).

## 8. Decision rules

| Goal failed   | Diagnosis                                                       | Action                                                                                                                                                |
| ------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **A only**    | Struct too small (everything fits L1) or too large (L1 starves) | If smallest N is at or below L1 capacity: escalate struct to 256 B × 16. If largest N is well above L3: trim the largest N. Re-run.                   |
| **B only**    | Crossover off the K-axis: AoS always wins, or SoA always wins   | If AoS always wins: struct is too narrow, escalate to 256 B. If SoA always wins: K-axis is too coarse near 16; widen to K ∈ {1, 2, 4, 8, 12, 14, 16}. |
| **C only**    | Magnitudes too compressed at every (N, K)                       | Either struct too narrow (256 B should help) or working set never gets DRAM-bound (extend N to 4 M or 16 M).                                          |
| **A and B**   | Struct shape badly wrong                                        | Escalate to 256 B × 16. Re-run full sweep.                                                                                                            |
| **A and C**   | Struct too narrow                                               | Escalate to 256 B × 16.                                                                                                                               |
| **B and C**   | Probably struct too narrow; possibly K granularity too coarse   | Escalate to 256 B × 16 first; if B still fails, refine K sweep.                                                                                       |
| **All three** | Stop. The demo's thesis may not hold on this hardware           | Report findings honestly in the notes file. Discuss before rescoping or replacing demo 6.                                                             |

If escalation to 256 B × 16 doesn't recover goals B and C, the pilot has flagged a genuine demo-viability issue — same shape as demo 5's calibration ladder, where the brief had to rescope down from 2× to "honest 30 %". Demo 6's qualitative thesis can absorb a smaller separation, but it can't absorb "AoS wins everywhere" — that's the post failing to exist.

## 9. Output artefact: notes file

**Location:** `bench/calibration-notes/06-aos-vs-soa-pilot/README.md`.

(Adjacent to where `pilot.cpp` lives. The directory is created fresh; nothing here is committed unless the user explicitly wants the calibration trail in the repo, matching demo 5's pattern.)

**Required contents:**

1. **Date and machine state.** `date -u`, `uname -a`, `cpupower frequency-info | head -20`, `cat /sys/devices/system/cpu/cpufreq/boost`. One paragraph of context.

2. **Final chosen parameters for §2.** Four lines:
   - Struct size: `<N>` bytes, `<M>` × `<type>` fields.
   - Working-set sweep: `<list of N values>`.
   - Hot-column sweep: `<list of K values>`.
   - Access pattern: sequential, contiguous-prefix field selection.

3. **Goals A/B/C verdict.** Three lines, each "Met" or "Not met" with the supporting observation.

4. **The raw CSV** (or a link to `results.csv`).

5. **A compact summary table.** AoS and SoA `ns_per_op` at each (N, K) cell, plus the AoS/SoA ratio. Three rows × three columns at minimum (small/medium/large N × small/medium/large K) is sufficient if the full grid is too noisy to read.

6. **Surprises.** Free-text section for any anomaly that should be acknowledged in §2's brief or in the eventual MDX: TLB transitions sharper or softer than expected, non-monotonic curves, prefetcher behaviour at specific (N, K) corners, any divergence from the "naïve picture".

7. **Escalation history.** If the 128 B × 16 default failed and 256 B was used, record both attempts. The post may eventually want a footnote on this.

## 10. Out of scope

- JSON output schema. Defer to §2.
- Perf-counter capture (cache-miss rate, IPC). Defer to §3 — adds noise to the pilot.
- Auto-vectorised vs intrinsic SoA. Defer to §2 / §3 decision; the pilot is scalar-only.
- Random-access AoS vs SoA. Plan resolved: sequential only.
- Vectorised hot-column comparison. That's a §3/§5 chart, not a pilot question.
- `<TimeVsN>` extension or `<CacheStaircase>` component. §5.
- Cross-CCX behaviour. Single-core pin only for the pilot.
- NUMA, multiple sockets — N/A on this machine.
- Random-access seed determinism, golden values, correctness verification. The pilot doesn't ship.

## 11. Acceptance criteria

- `bench/calibration-notes/06-aos-vs-soa-pilot/README.md` exists with all seven sections from §9 populated.
- Goal A is "Met" with concrete plateau ratios named.
- Goal B is "Met" with a specific `N` at which the crossover sits between `K=1` and `K=FIELDS`, or "Not met" with the escalation step documented.
- Goal C is "Met" with a specific `(N, K)` and ratio, or "Not met" with the escalation step documented.
- A user reading just §9.2 of the notes file can write §2's brief without re-running the pilot.
- Total wall-clock time spent (build + run + write-up): ≤2 hours.

If after one escalation (128 B × 16 → 256 B × 16) goals B or C are still "Not met", **stop and discuss** before committing to §2's brief. Same stop-and-discuss discipline as demo 5's rung-4 decision: rescope rather than press on.

## 12. Open items for the user to flag back

- If the AoS K=16 staircase plateaus are at substantially different _byte_ counts than table 3's prediction (say, the L2 boundary appears at 1 MB rather than 512 KB), record the actual transition points — §2's brief should use measured, not nominal, tier sizes.
- If SoA at K = FIELDS is unexpectedly _slower_ than AoS at K = FIELDS by more than 1.3× — possible if 16 concurrent column streams overwhelm the prefetcher or TLB — flag this as a candidate "what the post should call out" rather than something to engineer away.
- If the inner-loop sum reduction auto-vectorises on SoA but not AoS, and the difference is doing meaningful work, that's exactly the demo's point; no flag needed. If it auto-vectorises on neither, flag it — the pilot may need an explicit `#pragma omp simd` or a `-fopt-info-vec` confirmation, and §2 needs to know.
- If a 256 B × 16 escalation is required, note whether the existing N sweep still covers L1 → DRAM (halve it if not, per §4.3) and confirm the final sweep in the notes.
- If `cset shield --reset` is needed before the shield set-up succeeds (the cpuset-v1 / PID 1 gotcha from demo 5), confirm — and the §2 brief can land that as a precondition with empirical justification rather than just a "demo 5 said so" reference.
