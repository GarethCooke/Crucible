# Crucible — Demo 3 MDX prose rewrite

## Context

Demo 3 (`site/src/posts/03-simd-blackscholes.mdx`) was reviewed against the verified JSON capture at `site/src/data/perf/03-simd-blackscholes.json` (turbo confirmed off, isolation confirmed `0-7`, capture date `2026-05-17`). Several framing claims in the current MDX are contradicted by the numbers sitting one scroll below them:

1. **"~30× spread" headline.** Actual largest ratio is `avx2fma / scalar_libm` at N=1M = 216.69M / 20.97M = **10.34×**. There is no defensible reading of the JSON that produces 30×.
2. **"Roughly half the speedup comes from the math" framing.** Time saved at N=1M: total = 43.09 ns/option, algorithm step (libm→poly) saves 4.99 ns of that = **11.6% of time saved**. In log-multiplicative terms, log(1.116)/log(10.34) = **4.7%**. Not half. Algorithm step is small _as a standalone contribution_; what's true is that it's the _enabling condition_ for vectorisation (libm's `erfc` doesn't vectorise — you have to swap in a polynomial form before SIMD is on the table).
3. **"Memory bandwidth caps the gain at N=1M" framing.** Ops/sec for every variant is flat or slightly rising from N=262k to N=1M:

   | Variant     | N=262k  | N=1M    | Δ     |
   | ----------- | ------- | ------- | ----- |
   | scalar_libm | 20.95M  | 20.97M  | +0.1% |
   | scalar_poly | 23.39M  | 23.40M  | +0.0% |
   | sse2        | 95.80M  | 96.21M  | +0.4% |
   | avx2fma     | 214.60M | 216.69M | +1.0% |

   If bandwidth were the constraint, throughput would _drop_ crossing the L3 boundary (16 MB per CCX on Zen 2; the N=1M working set of 20 MB input + 4 MB output exceeds it). It doesn't. The workload is compute-bound at the inner loop. Arithmetic intensity supports this: 216M ops/sec × 24 B/op = 5.2 GB/s, ~20% of DDR4-3200 dual-channel sustained bandwidth.

4. **"Predicted <2×, got 1.96×" framing.** N=16k AVX2/SSE ratio is **1.995×** (essentially exactly 2.0). N=1M ratio is **2.252×**. The prediction-confirmation framing currently in the post is borderline at N=16k and disconfirmed at N=1M. The honest story: µop-split costs ~half the theoretical 2× width win, FMA's two-flops-per-µop recovers most of it, net is hairline-under-2× at the cleanest measurement point and creeps above 2× when the loop is fully amortised. The IPC numbers tell this directly — SSE IPC 1.21, AVX2 IPC 0.91, ratio = 0.75, exactly what you'd expect when each AVX2 instruction consumes two issue slots.
5. **Footer asserts "turbo enabled".** Now demonstrably false. Should read "turbo disabled".

The underlying engineering (hand-rolled SIMD `exp`/`log`/`ncdf`, FMA Horner, correctness oracle, alignment checks, FTZ/DAZ) is sound and a strong signal for the audience. The current prose works against it.

## Goal

Rewrite the post so the claims in the prose match the numbers in the JSON. Keep the engineering content intact; replace overclaiming with the honest contrarian story (algorithm-as-gate-not-contribution; µop split costs you ~half the width win and FMA recovers it).

## Scope

All edits below are in `site/src/posts/03-simd-blackscholes.mdx`. The JSON, C++ source, and chart components are NOT in scope — they're correct as-is.

### Edit 1 — Frontmatter title

**Current:**

```
title: "Black-Scholes: same model, four implementations, ~30× spread"
```

**New:**

```
title: "Black-Scholes: same model, four implementations, ~10× spread"
```

### Edit 2 — Frontmatter summary

**Current:**

```
summary: "Roughly half the speedup comes from the math, not the SIMD. Scalar polynomial approximations beat libm before a single AVX2 instruction appears."
```

**New:**

```
summary: "Polynomial approximations buy 12% on their own — but they're the gate to a 9× SIMD win that libm's erfc can't reach."
```

### Edit 3 — Opening hook (lines 7–10)

**Current:**

```
Same pricing model. Same input chain. Same machine. Four implementations — and the
spread from slowest to fastest is around 30×. The surprising part: roughly half that
gap comes from replacing `std::exp` and `std::erfc` with polynomial approximations,
before a single SIMD instruction appears in the hot loop.
```

**New:**

```
Same pricing model. Same input chain. Same machine. Four implementations — and the
spread from slowest to fastest is around 10×. The interesting part: most of the gap
is SIMD, but you can't get there from libm. `std::erfc` doesn't vectorise. Swapping
it for a polynomial approximation buys a modest 12% on its own — and is the gate
that makes the SIMD wins reachable at all.
```

### Edit 4 — Headline numbers section (lines 89–91)

The headline chart currently shows only N=1M. The post's argument about µop split vs FMA recovery is cleanest when both N=16k (compute-bound, fits in L2) and N=1M (fully amortised) are shown. If the chart component supports `targetN`, render both.

**Current:**

```mdx
## Headline numbers

<ThroughputBars
  slug="03-simd-blackscholes"
  targetN={1048576}
  title="Options priced per second at N=1M (higher is better)"
/>
```

**New:**

```mdx
## Headline numbers

Two views of the same data: at N=16,384 the entire working set fits comfortably in
L2 (per-core), giving the cleanest per-cycle compute comparison. At N=1,048,576
the input is 20 MB — larger than the 16 MB L3 per CCX — but the workload is
compute-bound anyway, so throughput per option is essentially identical to the
L2-resident case.

<ThroughputBars
  slug="03-simd-blackscholes"
  targetN={16384}
  title="Options priced per second at N=16k — L2-resident, compute-bound (higher is better)"
/>

<ThroughputBars
  slug="03-simd-blackscholes"
  targetN={1048576}
  title="Options priced per second at N=1M — fully amortised (higher is better)"
/>
```

If the chart component doesn't support `targetN` for arbitrary values yet, keep a single chart at N=1M and add a small inline table comparing the two Ns for SSE and AVX2 specifically. The numbers to use, from the JSON:

| Variant    | N=16k ops/sec | N=1M ops/sec | Ratio |
| ---------- | ------------- | ------------ | ----- |
| sse2       | 86.42M        | 96.21M       | 1.11× |
| avx2fma    | 172.40M       | 216.69M      | 1.26× |
| AVX2 / SSE | 1.995×        | 2.252×       | —     |

### Edit 5 — "Decomposing the speedup" section, Step 1→2 paragraph (lines 95–110)

**Current paragraph (Step 1→2):** Claims "the first win, independent of SIMD" — fine. Claims it's roughly half the journey — false. The libm-precision-vs-needed-precision discussion is good and should stay; only the framing around magnitude needs to change.

**Rewrite the opening sentence(s) of the Step 1→2 paragraph to:**

```
**Step 1 → 2: the algorithm gate.** Replacing `std::exp` / `std::erfc` with
polynomial approximations gives a modest 12% standalone speedup (47.7 ns/option →
42.7 ns/option at N=1M). On its own that's unremarkable. What it actually does is
open the door to the SIMD wins below — there is no `_mm256_erfc_ps`. libm's `erfc`
is a branch-and-lookup-table dispatch that doesn't translate to a SIMD register;
you have to switch to a polynomial form before you can widen to four or eight
lanes. The polynomial is the gate, not the prize.
```

The "libm's `expf` and `erfcf` are designed for full float precision (~1.2e-7 ULP error)..." discussion that follows is good. Keep it. It explains _why_ the polynomial is acceptable (the precision libm provides isn't precision Black-Scholes needs).

### Edit 6 — "Decomposing the speedup" section, Step 2→3 paragraph (lines 112–116)

**Current:**

```
**Step 2 → 3: SSE width win.** Widening from 1 to 4 lanes with `__m128` gives
a real throughput gain but below 4×. The bottlenecks: the `div` (S/K and the
final σ√T division) and `sqrt` are not 4× cheaper in SSE — their throughput
improves with width but their latency doesn't vanish. Memory bandwidth starts to
matter at N = 1M (20 MB input, larger than the 512 KB L2 per core on Zen 2).
```

The bandwidth claim is contradicted by the data and must go. The div/sqrt non-scaling claim is fine.

**New:**

```
**Step 2 → 3: SSE width win.** Widening from 1 to 4 lanes with `__m128` gives a
4.1× throughput gain at N=1M — slightly above clean 4× width because the scalar
variant carries some loop-overhead and pipeline-fill cost the SIMD variant
amortises. The main brake on a higher ratio is that `div` and `sqrt` aren't 4×
cheaper in SSE — their throughput improves with width but the latency-bound
operations don't disappear.
```

### Edit 7 — "Decomposing the speedup" section, Step 3→4 paragraph (lines 118–130)

The current paragraph has two issues: (a) the duplicate setup-then-results structure (lines 119–127 and 128–130 say substantially the same thing), and (b) the framing that the prediction was confirmed when at N=1M it wasn't.

**Replace lines 118–130 with:**

```
**Step 3 → 4: AVX2 + FMA — and the Zen 2 µop-split fingerprint.**

*Going in:* Zen 2 implements 256-bit AVX2 by splitting each instruction into two
128-bit µops internally. One `vfmadd256ps` consumes two execution-port slots
where Zen 3 would consume one. On µop count alone, this halves the theoretical
width advantage of 8-wide AVX2 over 4-wide SSE. The prediction was that AVX2
would land *under* 2× SSE on this CPU.

*What actually landed:* at N=16,384 — the cleanest comparison, with the working
set in L2 and per-iteration overhead amortised — AVX2/SSE is **1.995×**. Right at
the threshold, exactly as the µop-split argument predicts. At N=1,048,576 the
ratio rises to **2.252×** as the fixed per-iteration harness cost dissolves
further.

The IPC counters expose the µop split directly: SSE retires 1.21 instructions per
cycle, AVX2 retires 0.91 — a 0.75 ratio, almost exactly what you'd expect if each
AVX2 instruction occupies two issue slots. But each retired AVX2 instruction is
also doing ~2.5× the work of a retired SSE instruction (8 lanes plus FMA's two
flops per multiply-add, vs 4 lanes of separate mul + add). Multiply those out:
0.75 × 2.5 ≈ 1.9× — and the rest is small effects (register pressure, scheduling,
amortisation). The headline ratio doesn't come from AVX2 magically being 2× SSE;
it comes from FMA reclaiming what µop split costs you.
```

### Edit 8 — Drop the section break that's now redundant

Lines 128–130 of the current MDX (the second "AVX2-vs-SSE ratios at N=16k... will tell different stories" paragraph) are subsumed by Edit 7's rewrite. Remove them.

### Edit 9 — "What this doesn't show" section (lines 168–177)

Add three items to make the disclosures match what was actually measured.

**Insert before the existing `- **AVX-512**:` bullet:**

```
- **GFLOPS for `scalar_libm`** is computed against the polynomial-variant flop
  count (98 flops/option). libm's `erfc` is internally far more than that —
  branch-heavy dispatch, lookup tables, and conditional polynomial branches. The
  reported 2.05 GFLOPS for `scalar_libm` is therefore "throughput-equivalent
  flops if libm did the same math as the polynomial variant," not a measurement
  of libm's actual flop rate. Treat it as a *throughput* number, not a
  *computational density* number.
- **Per-iteration harness overhead.** At N=1024 every variant runs ~5–6× slower
  per option than at N=1M because the perf-counter start/stop and function-call
  cost per iteration is fixed and amortises across N. Small-N numbers are
  measurement-floor-bound, not compute-bound. The charts above use N≥16k for
  this reason; the full sweep including N=1024 is in the JSON for
  reproducibility.
- **% of theoretical peak.** Zen 2 base-clock theoretical peak for 256-bit FMA
  is roughly 62 GFLOPS per core (2 FMA pipes × 1 256-bit FMA per 2 cycles × 8
  lanes × 2 flops × 3.9 GHz). The AVX2 variant lands at 27 GFLOPS = ~44% of
  peak. Division, square root, and the polynomial cascades (which can't all
  pipeline as pure FMA) are the gap.
```

### Edit 10 — Footer line about machine state

**Current (line 197–198):**

```
*AMD Ryzen 7 3800X, Zen 2, 3.9 GHz base, governor = performance, turbo enabled,
SMT off (BIOS), GCC 13, per-variant ISA flags as documented in CMakeLists.txt.*
```

**New:**

```
*AMD Ryzen 7 3800X, Zen 2, 3.9 GHz base, governor = performance, turbo disabled
(verified via cpupower), SMT off (BIOS), cores 0–7 isolated, benchmarks pinned
to 4–7, GCC 13, per-variant ISA flags as documented in CMakeLists.txt.*
```

### Edit 11 — Notes field in JSON

This isn't an MDX edit but a one-line JSON change to bring the `notes` field into agreement with the new prose. The current note says "Zen 2 µop-split: AVX2/SSE < 2× predicted." which is now misleading given the post owns 2.25× at N=1M.

**Change `runs[...]` JSON `notes` field (top-level, line 380 of the JSON) from:**

```
Four variants of European call option pricing under Black-Scholes. Speedup decomposed into algorithm win (poly vs libm) and SIMD width win (SSE 4-wide → AVX2+FMA 8-wide). Zen 2 µop-split: AVX2/SSE < 2× predicted.
```

**To:**

```
Four variants of European call option pricing under Black-Scholes. Speedup decomposed into algorithm gate (poly vs libm, 12%) and SIMD width (SSE 4-wide, AVX2+FMA 8-wide). Zen 2 µop-split visible in IPC (SSE 1.21, AVX2 0.91); FMA recovers most of the lost width. AVX2/SSE = 1.995× at N=16k, 2.252× at N=1M.
```

## Acceptance criteria

- Title, summary, and hook reflect ~10× spread, not 30×.
- No claim in the post says or implies the algorithm step is half (or any substantial fraction) of the speedup.
- No claim in the post says the workload is bandwidth-limited at N=1M.
- The µop-split discussion owns the actual N=1M ratio of 2.25× rather than framing it as a prediction failure.
- IPC numbers (1.21 / 0.91) appear in the prose as direct evidence for µop split.
- Footer says "turbo disabled, verified via cpupower" and mentions core isolation.
- "What this doesn't show" includes the GFLOPS caveat for `scalar_libm`, the harness-overhead caveat for small N, and a peak-of-theoretical contextualisation.
- JSON `notes` field aligned with the new framing.
- No duplicate paragraphs.
- Build still passes; existing chart and `CodeCompare` calls still render.

## Out of scope

- Chart component changes. If `<ThroughputBars>` doesn't yet support `targetN` for arbitrary values, fall back to the inline-table workaround in Edit 4.
- Schema changes to `ns_per_op` semantics (tracked separately).
- Any change to C++ source, JSON capture, or methodology page.
- Reruns. The current JSON is final for this demo.

## Open questions for CC to flag during implementation

- Confirm `<ThroughputBars targetN={16384} ... />` renders correctly. If `targetN` only supports a single hardcoded value or only the maximum N in the JSON, surface that and we'll either extend the component (separate brief) or accept the inline-table fallback for this demo.
- The current `<CodeCompare>` block uses `labels={["scalar_poly (variant 2)", "avx2_fma (variant 4)"]}` and shows the most informative diff. No change needed, but flag if you spot a way to make it tighter.
- The "Why hand-roll the polynomials?" section (lines 149–166 in the current MDX) is unchanged by this brief but worth a final read-through against the new framing — make sure nothing in it now contradicts the rewritten decomposition section.
