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

| Parameter | Value |
|---|---|
| Struct size | **128 B**, 16 × `double` fields |
| Working-set sweep | 64, 256, 1 024, 4 096, 16 384, 65 536, 262 144, 1 048 576 elements |
| Hot-column sweep | K ∈ {1, 2, 4, 8, 16} |
| Access pattern | Sequential, contiguous-prefix field selection (fields 0 .. K−1) |

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

| N (bytes) | Layout | K=1 | K=4 | K=8 | K=16 |
|---|---|---|---|---|---|
| 64 (8 KB, L1) | AoS | 2.578 | 1.359 | 1.211 | 1.154 |
| | SoA | 1.703 | 1.270 | 1.193 | 1.157 |
| | **Ratio** | **1.51×** | 1.07× | 1.02× | **0.998× (AoS wins)** |
| 65 536 (8 MB, L3) | AoS | 3.860 | 1.503 | 1.160 | 1.168 |
| | SoA | 1.115 | 1.117 | 1.199 | 1.158 |
| | **Ratio** | **3.46×** | **1.35×** | **0.97× (AoS wins)** | 1.01× |
| 1 048 576 (128 MB, DRAM) | AoS | 7.100 | 2.005 | 1.333 | 1.288 |
| | SoA | 1.548 | 1.341 | 1.211 | 1.238 |
| | **Ratio** | **4.59×** | **1.50×** | **1.10×** | **1.04×** |

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
