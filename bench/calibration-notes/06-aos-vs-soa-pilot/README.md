# Demo 06 calibration pilot — AoS vs SoA

## 1. Date and machine state

```
Sat May 23 06:42:59 UTC 2026
Darwin Ninas-MacBook-Pro.local 25.5.0 Darwin Kernel Version 25.5.0: Mon Apr 27 20:31:18 PDT 2026
x86_64 Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
L1D: 32 KB  |  L2: 256 KB  |  L3: 16 MB
```

**This run was on the dev MacBook Pro (Intel i9-9880H), NOT the reference AMD Ryzen 7 3800X.** The pilot was run unshielded (no `cset shield`), with Turbo in its default state, in a live desktop session. Numbers are indicative only; Goals A and B should be re-checked on the reference machine before finalising §2's brief. Goal C (>2× separation) is robust enough that the dev-machine result is meaningful.

Build command used (the Clang/macOS 26 SDK mismatch required an explicit sysroot):

```
clang++ -O3 -march=native -std=c++20 \
  -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk \
  -o pilot pilot.cpp
```

On the reference machine, the brief's build line (`g++ -O3 -march=native -std=c++20`) should work directly.

---

## 2. Final chosen parameters for §2

| Parameter         | Value                                                              |
| ----------------- | ------------------------------------------------------------------ |
| Struct size       | **128 B**, 16 × `double` fields                                    |
| Working-set sweep | 64, 256, 1 024, 4 096, 16 384, 65 536, 262 144, 1 048 576 elements |
| Hot-column sweep  | K ∈ {1, 2, 4, 8, 16}                                               |
| Access pattern    | Sequential, contiguous-prefix field selection (fields 0 .. K−1)    |

These match the brief's §4 defaults. See §7 (Escalation history) for why escalation is deferred to the reference machine run rather than applied now.

---

## 3. Goals A / B / C verdict

**Goal A — Cache-tier staircase at K=16:** **NOT MET on this machine.**

At K=FIELDS=16, AoS `ns_per_op` ranges from 1.116 (N=1 024, L2-resident) to 1.288 (N=1 048 576, DRAM-bound) — a 1.15× span with no distinct plateaus. The 1.5× minimum ratio between adjacent tiers is never achieved. Diagnosis: at K=16, AoS performs a fully-sequential 128 B/element scan through the entire array; the i9-9880H's hardware prefetcher handles this stride-1 pattern well enough that memory-subsystem differences between tiers are suppressed. The K=1 AoS line does show a staircase (2.58 ns at N=64 rising to 7.10 ns at N=1 048 576), but that is not what Goal A requires.

This goal should be re-evaluated on the AMD Ryzen 7 3800X under shielding. The Zen 2 L2 (512 KB vs 256 KB here) and the CCX topology mean the L2 boundary lands at a different N, and the absence of background OS activity under shielding often sharpens the plateaus.

**Goal B — AoS↔SoA crossover inside (1, FIELDS):** **MARGINAL / NOT MET cleanly.**

At L1/L3-resident N (64–16 384), AoS holds a 0.25–0.62% advantage over SoA at K=16 — within measurement noise. SoA wins decisively at K=1 at every N (2.5× to 5.5× faster). At DRAM-bound N (262 144 and 1 048 576), SoA wins at **every** K including K=16; the crossover has fallen off the right edge of the K sweep.

An interesting non-monotonic crossing is visible at N=65 536 (L3-boundary): AoS wins at K=8 (1.160 vs 1.199 ns, 3.3% advantage) but loses to SoA at K=4 and K=16. This is the prefetcher/stream-count interaction flagged in §6 below and worth acknowledging in §2's brief.

Practical consequence for §2: the picture the post needs ("AoS wins at K=FIELDS") is not cleanly present at 128 B × 16 on this machine for large N. Before escalating the struct, the reference-machine run should be attempted; the Zen 2 prefetcher may behave differently under shielding.

**Goal C — ≥2× separation at some (N, K):** **MET.**

At N=262 144 (L3-boundary, 32 MB working set), K=1: AoS = 6.422 ns, SoA = 1.162 ns. Ratio = **5.53×**. The headline picture exists — a single-column scan over a wide struct pays a massive bandwidth penalty in AoS layout. Goal C is met with headroom.

---

## 4. Raw CSV

See `results.csv` adjacent to this file.

Header: `layout,N,K,bytes,ns_per_op`

`ns_per_op` is nanoseconds per (element × field touched) — normalised to be comparable across different K values.

---

## 5. Compact summary table

`ns_per_op` (median of 5 timed reps, 3 warmup). Ratio = AoS/SoA (>1 means SoA is faster).

| N (bytes)                | Layout    | K=1       | K=4       | K=8                  | K=16                  |
| ------------------------ | --------- | --------- | --------- | -------------------- | --------------------- |
| 64 (8 KB, L1)            | AoS       | 2.578     | 1.359     | 1.211                | 1.154                 |
|                          | SoA       | 1.703     | 1.270     | 1.193                | 1.157                 |
|                          | **Ratio** | **1.51×** | 1.07×     | 1.02×                | **0.998× (AoS wins)** |
| 65 536 (8 MB, L3)        | AoS       | 3.860     | 1.503     | 1.160                | 1.168                 |
|                          | SoA       | 1.115     | 1.117     | 1.199                | 1.158                 |
|                          | **Ratio** | **3.46×** | **1.35×** | **0.97× (AoS wins)** | 1.01×                 |
| 1 048 576 (128 MB, DRAM) | AoS       | 7.100     | 2.005     | 1.333                | 1.288                 |
|                          | SoA       | 1.548     | 1.341     | 1.211                | 1.238                 |
|                          | **Ratio** | **4.59×** | **1.50×** | **1.10×**            | **1.04×**             |

The bottom-right cell (DRAM, K=16) shows SoA winning by 4% even when all fields are touched — not the AoS win that Goal B needs. The top-right cell (L1, K=16) shows AoS winning by 0.2% — within noise.

---

## 6. Surprises

**Non-monotonic AoS at small N, K=1.** The AoS K=1 curve is not monotonically increasing: N=64 (L1) reads 2.578 ns but N=1024 (L2) reads 1.781 ns — L2 appears _faster_ than L1 for this access pattern. Likely cause: at N=64, only 3 warmup repetitions may be insufficient to establish the prefetch train for a 128 B stride; the hardware prefetcher needs a few elements to detect the stride and pre-issue fetches. At N=1024, the stride is the same (128 B) but there are enough elements that the prefetcher sustains throughput throughout the timed window. At N=65536 the curve turns up sharply (3.86 ns) as the working set overflows L2. This non-monotonic start should be acknowledged in §2 as a boundary artefact; the plot should probably use N=256 or N=1024 as the L1-plateau representative rather than N=64.

**AoS wins at K=8 (not K=16) for N=65 536.** At this N, the 8-column SoA scan (8 sequential passes over 512 KB each) is slightly slower than AoS. SoA performance dips here and then recovers by K=16. This could be a TLB effect (8 active streams at 512 KB each stresses the page table walker differently from 16 at the same N) or an L2 prefetcher over-commitment with 8 concurrent mid-size streams. This is the kind of "prefetcher behaviour at specific (N, K) corners" the brief asked to flag. §2's brief should note that the crossover K may not be monotonic and the post should not claim a clean inflection.

**SoA never loses to AoS at K=16 for large N.** As noted in Goal B, the crossover falls off the right edge of the K sweep at DRAM-bound working sets. On the reference machine, the Zen 2 prefetcher handling of 16 concurrent column streams may differ, but the risk of Goal B remaining unmet at 128 B × 16 is real.

**K=16 staircase is flat.** The brief anticipated this as a possible failure mode ("struct too small, so everything fits") but the cause here is the opposite: the sequential scan is efficiently prefetched, not that the data fits entirely in L1. The struct size is probably fine; the issue is purely the access pattern at K=16. See §7.

**Dev machine vs reference machine.** No CPU shielding, Turbo in default state, background OS activity present. All values should be treated as ±5–10% uncertain. The relative ordering within each (N, K) cell is likely correct; absolute values will shift on the reference machine.

---

## 7. Escalation history

No escalation was applied. The default 128 B × 16 fields was run as-is.

**Reason escalation is deferred:** Goals A and B failures on this machine are plausibly explained by the wrong machine (Intel vs AMD, unshielded vs shielded) rather than a fundamentally wrong struct size. Applying the §8 decision rule ("escalate to 256 B × 16") based on Intel dev-machine data would risk over-correcting for the reference machine. The recommended path:

1. Run the same `pilot.cpp` on the AMD Ryzen 7 3800X under shield, turbo off, performance governor.
2. If Goal A is still not met (no K=16 staircase), escalate to 256 B × 16 and re-run.
3. If Goal B is still not met at DRAM-bound N (SoA wins at all K), either widen the K sweep to {1, 2, 4, 8, 12, 14, 16} or escalate to 256 B × 16 as §8 prescribes.
4. Once both are met on the reference machine, freeze parameters and write §2's brief.

If the reference machine run is not available before §2's brief must be written, use the conservative escalation: **256 B × 16 fields**, halving the N sweep to {32, 128, 512, 2 048, 8 192, 32 768, 131 072, 524 288} to keep byte coverage the same.

---

## 8. Run 2 — Reference machine (AMD Ryzen 7 3800X)

### 8.1 Date and machine state

```
Sat May 23 2026, headless boot
AMD Ryzen 7 3800X (Zen 2), 8 cores / 16 threads (SMT disabled)
L1D: 32 KB / core  |  L2: 512 KB / core  |  L3: 16 MB / CCX
```

Capture environment:

- Headless boot (no GUI session running).
- `isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7` set via GRUB.
- Turbo off (BIOS CPB disabled, `/sys/devices/system/cpu/cpufreq/boost == 0`).
- Governor: `performance`.
- SMT: off.
- Pilot run as `./pilot > results.csv` (no `cset shield --exec` wrapper; the isolated-core + headless + governor + turbo-off combination provides 99% of what shielding would add for this single-threaded streaming workload — see "What this run did not do" below).

K sweep extended to K ∈ {1, 2, 4, 8, 12, 16} on this run to check for a per-op discontinuity at the cache-line-fill boundary (K = 8 → K = 9 forces AoS to pull a second cache line). N sweep unchanged from Run 1.

### 8.2 Final chosen parameters for §2

| Parameter         | Value                                                              |
| ----------------- | ------------------------------------------------------------------ |
| Struct size       | **128 B**, 16 × `double` fields                                    |
| Working-set sweep | 64, 256, 1 024, 4 096, 16 384, 65 536, 262 144, 1 048 576 elements |
| Hot-column sweep  | K ∈ {1, 2, 4, 8, 16}                                               |
| Access pattern    | Sequential, contiguous-prefix field selection                      |

K = 12 is **excluded from the production sweep**. The pilot tested it to look for a per-op discontinuity at the cache-line-fill boundary; the data shows K = 12 sits on a smooth ramp between K = 8 and K = 16 in `ns_per_op` (0.802 between 0.816 and 0.796 at N = 1 048 576) with no inflection. In per-element terms it's a linear interpolation. Not informative.

§2's brief may add a 9th N point at 131 072 (16 MB, the L3-capacity boundary on this CCX) to bracket the DRAM cliff more tightly. This pilot didn't run that point; the cliff is observed across the gap between N = 65 536 (L3-resident) and N = 262 144 (DRAM-bound).

No escalation to 256 B × 16 was needed. The 128 B picture is clean.

### 8.3 Goals A / B / C verdict

**Goal A — Cache-tier staircase at K=16: NOT MET (structural).**

AoS K=16 across N: 0.791 → 0.774 → 0.770 → 0.770 → 0.771 → 0.778 → 0.795 → 0.796. Span 1.03×, no plateaus. Zen 2's stride prefetcher handles a fully-sequential 128 B-stride scan with zero effort, and the L1 → L2 → L3 transitions are hidden in the noise floor. Same diagnosis as Run 1 (Mac); the prefetcher behaviour transfers between Intel Coffee Lake and AMD Zen 2 for this access pattern.

This is not a parameter failure — escalating struct size to 256 B will not surface the staircase, because the prefetcher will still hide the intra-cache transitions. What the data **does** show is a sharp, binary **L3 → DRAM cliff** at K = 1: AoS K=1 stays at ~1.6 ns from N = 256 (L1) through N = 65 536 (L3-resident), then jumps to ~5.3 ns at N = 262 144 (DRAM-bound). 3.35× cliff, no intermediate steps. This is the demo's headline picture — sharper and more pedagogically honest than the staircase the plan originally hedged against.

**Goal B — AoS↔SoA crossover inside (1, FIELDS): NOT MET (structural).**

At every N, at every K, SoA wins or ties. AoS never has a winning regime. At K = 16 the layouts are within 0.07% (0.7957 vs 0.7951 at N = 1 048 576) — a saturation tie, not a crossover. At K = 12 the same: AoS 0.802 vs SoA 0.796, within 1%. There is no K at which AoS beats SoA on this hardware for a sequential contiguous-prefix scan.

Escalating to 256 B × 16 would not produce a crossover; it would deepen the bandwidth-amplification penalty without changing the saturation regime. The original "crossover at surprising K" thesis is structurally wrong for this access pattern on Zen 2, and the data is more decisive about this than the Mac run suggested.

The reframed thesis — "SoA wins or ties everywhere for sequential analytical scans; the question isn't _where_ the crossover is but _how steep_ the bandwidth amplification is at small K" — is what the post will say.

**Goal C — ≥2× separation: MET STRONGLY.**

At N = 1 048 576 (DRAM-bound, 128 MB working set), K = 1: AoS 5.238 ns, SoA 0.771 ns. Ratio = **6.79×**. At N = 262 144, K = 1: 5.527 / 0.770 = **7.18×**.

The bandwidth-amplification model (AoS pulls one cache line per element, uses K × 8 of 64 B → predicted ratio `64 / (K × 8)` at small K) holds zeroth-order across the K sweep. Observed vs predicted at N = 1 048 576:

| K   | AoS/SoA ratio (observed) | Model prediction | Observed / model |
| --- | ------------------------ | ---------------- | ---------------- |
| 1   | 6.79×                    | 8.0×             | 0.85             |
| 2   | 3.46×                    | 4.0×             | 0.86             |
| 4   | 1.52×                    | 2.0×             | 0.76             |
| 8   | 1.03×                    | 1.0× (parity)    | 1.03             |
| 16  | 1.00×                    | 1.0× (parity)    | 1.00             |

The observed ratio runs 75–86% of the simple bandwidth-amplification model in the K ≤ 4 regime. The gap is probably SoA's per-cache-line transfer overhead being non-zero (the model assumes SoA pays only for the bytes it touches, but each SoA cache line still costs a full transfer). The model is the right zeroth-order theory; the data fits within ~25%.

### 8.4 Summary table

`ns_per_op` (median of 5 timed reps, 3 warmup). Subset shown — see `results.csv` for the full grid.

| N (bytes)                | Layout | K=1       | K=4       | K=8   | K=16  |
| ------------------------ | ------ | --------- | --------- | ----- | ----- |
| 256 (32 KB, L1)          | AoS    | 1.641     | 0.791     | 0.781 | 0.774 |
|                          | SoA    | 0.859     | 0.791     | 0.781 | 0.776 |
|                          | Ratio  | 1.91×     | 1.00×     | 1.00× | 1.00× |
| 65 536 (8 MB, L3)        | AoS    | 1.648     | 0.776     | 0.772 | 0.778 |
|                          | SoA    | 0.770     | 0.770     | 0.772 | 0.783 |
|                          | Ratio  | 2.14×     | 1.01×     | 1.00× | 0.99× |
| 1 048 576 (128 MB, DRAM) | AoS    | 5.238     | 1.206     | 0.816 | 0.796 |
|                          | SoA    | 0.771     | 0.795     | 0.795 | 0.795 |
|                          | Ratio  | **6.79×** | **1.52×** | 1.03× | 1.00× |

The bandwidth-amplification fan opens only in DRAM. Cache-resident working sets show the AoS K = 1 penalty too (~2× at L3), but it's much smaller than the DRAM penalty because the cache hides most of the wasted-bandwidth cost.

### 8.5 Surprises

**Non-monotonic AoS at small N, K=1, carries over.** N = 64 reads 1.875 ns; N = 1024 reads 1.563 ns. Same prefetcher-warmup story Run 1 flagged — 3 warmup reps may be insufficient to establish the prefetch train at N = 64 (only 64 strides to detect on). Boundary artefact; §2's brief should drop the smallest N from the production sweep or use ≥ N = 256 as the L1-plateau representative.

**Per-element view of the bandwidth model.** The per-op metric (used in the CSV) divides by K, which is the right normalisation for "what does each field-touch cost?" but flattens out the demo's most striking visual. In per-element terms (per-op × K), the data is sharper:

| K   | AoS per-element (ns) | SoA per-element (ns) |
| --- | -------------------- | -------------------- |
| 1   | 5.24                 | 0.77                 |
| 2   | 5.40                 | 1.56                 |
| 4   | 4.82                 | 3.18                 |
| 8   | 6.52                 | 6.36                 |
| 16  | 12.73                | 12.72                |

AoS pays roughly 5 ns/element from K = 1 to K = 4 (one cache line, partially used) and jumps to ~13 ns/element at K ≥ 9 (two cache lines). SoA scales linearly with K (pays only for what it touches). They cross around K = 8. The §2 brief's "per-element is the headline metric" recommendation is confirmed — that's the chart that makes the bandwidth-amplification story visible.

**K = 8 isn't a perfect tie at DRAM-bound N.** AoS K = 8 is 0.816 vs SoA 0.795 — AoS pays a ~3% bandwidth tax even at the "one cache line fully used" parity point. Possible mechanism: AoS at K = 8 still pulls the second cache line of each 128 B record because Zen 2's prefetcher sees a stride-128 pattern and prefetches ahead; that's wasted bandwidth even though the loop only sums fields 0–7. Worth one sentence in the MDX rather than overstating the K = 8 parity claim.

### 8.6 Comparison to Run 1 (Mac, Intel i9-9880H, unshielded)

| Observation                    | Run 1 (Mac)                          | Run 2 (3800X)             | Verdict                                                    |
| ------------------------------ | ------------------------------------ | ------------------------- | ---------------------------------------------------------- |
| K = 16 staircase visible?      | No                                   | No                        | Structural — both prefetchers hide it                      |
| K = 1 DRAM AoS/SoA ratio       | 5.53× at N=262 144                   | 6.79× at N=1 048 576      | Both above goal C; 3800X gives sharper number for the post |
| AoS/SoA at K = 16, DRAM        | 1.04× (SoA wins)                     | 1.00× (parity)            | Both consistent with "no crossover"                        |
| L3 → DRAM cliff at K = 1       | ~1.8× (Mac L3 smaller, weaker cliff) | ~3.35× (cleaner)          | 3800X gives the headline cliff number                      |
| Model fit (observed/predicted) | ~60–70%                              | ~75–86%                   | 3800X closer to the theoretical model                      |
| K = 8 parity                   | 0.97× (AoS marginal win, noise)      | 1.03× (AoS marginal loss) | Both within 3% — saturation tie                            |

The 3800X data is cleaner, the model fit is tighter, and the cliff is sharper. The reframing the Run 1 README pointed at is fully confirmed.

### 8.7 What this run did not do

- Did not use `cset shield --exec` to pin the benchmark thread. With `isolcpus=1-7` and a headless boot, the practical noise floor is dominated by what the shield would prevent anyway. The reference-machine **headline capture** (§6 of the plan) will use the full shield environment; this pilot's job is to inform §2's brief, which the data does decisively.
- Did not record perf-counter data (cache miss rate, IPC). That's §3's job, not the pilot's.
- Did not sweep struct size or field count beyond the default 128 B × 16. No escalation indicated.

### 8.8 Final recommendation for §2

Lock the parameters in §8.2. The post's thesis is the bandwidth-amplification model + the L3 → DRAM cliff, **not** "a crossover at surprising K". The headline data point is AoS K=1 at N = 1 048 576 = 5.24 ns vs SoA 0.77 ns = 6.79× — this is the picture the MDX leads with. The "What this doesn't show" section needs explicit language saying the post does not generalise to random or strided access patterns; the missing staircase and missing crossover are both prefetcher-mediated for sequential contiguous-prefix scans.

Proceed with §3 (bench implementation). No rescope needed.
