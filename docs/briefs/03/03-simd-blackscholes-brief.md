# Crucible Demo 3 — SIMD: scalar vs SSE vs AVX2 (Black-Scholes call pricing)

Third demo in the Crucible series. Builds on the v1 scaffold from `BRIEF.md` — reuses `<CodeCompare>` and `<ThroughputBars>`, adds no new components. Independent of demo 2 (false sharing); can ship before or after it.

## Story angle

Vectorisation gains on a workload the hedge-fund audience already understands: pricing a chain of European call options under Black-Scholes. Four variants, ordered to isolate where the speedup comes from:

1. Algorithm win — scalar `std::exp` / `std::erf` vs scalar polynomial approximations. You can win before reaching for SIMD.
2. Width win — same polynomial math, widened from scalar → SSE (4-wide) → AVX2+FMA (8-wide).

The Zen 2 µop-split caveat becomes a falsifiable prediction rather than a disclaimer: AVX2 should beat SSE, but by less than 2× on this hardware (Zen 2 cracks 256-bit AVX2 into 2×128-bit µops; full 256-bit dispatch starts at Zen 3). State the prediction up front in the post, measure it, discuss what came back.

## Workload

European call option pricing, Black-Scholes:

```
C  = S·N(d1) − K·e^(−rT)·N(d2)
d1 = (ln(S/K) + (r + σ²/2)T) / (σ√T)
d2 = d1 − σ√T
```

Input: arrays of `S`, `K`, `T`, `r`, `σ` (all `float`, aligned to 32 bytes). Output: array of `C`.

Headline chain size: **N = 1,048,576** options. Also capture N = 1k, 16k, 256k, 1M — useful for follow-up `<TimeVsN>` material, and 16k specifically isolates the compute-bound case (fits in L2; see Hardware gotchas).

Inputs generated once at startup from a seeded `std::mt19937` (fixed seed `0xCAFEBABE`), ranges:

- S ∈ [50, 150]
- K ∈ [50, 150]
- T ∈ [0.05, 2.0]
- r ∈ [0.0, 0.08]
- σ ∈ [0.1, 0.6]

## Variants

Four variants in `bench/demos/03-simd-blackscholes/`. Each in its own translation unit, compiled with its own ISA flags via `target_compile_options`, registered as a separate Google Benchmark case. **Do not rely on `-march=native` for variants 2–3** — on this machine it would silently grant AVX2 to the SSE variant and contaminate the comparison.

### 1. `scalar_libm`

Reference / correctness oracle. Single price loop using `std::exp`, `std::log`, `std::sqrt`, `std::erf` from `<cmath>`.
Flags: `-O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2`.

### 2. `scalar_poly`

Same loop, transcendentals replaced with polynomial approximations:

- `exp`: range-reduce by `log2(e)`, polynomial on `[-0.5, 0.5]`, reconstruct via `ldexp`
- `erf` (or `N(x)` directly): Abramowitz & Stegun 7.1.26 (5-term rational) or Cody (1980) `erfc`
- `log`, `sqrt`: libm versions are fine — they aren't the hot path the way `exp` / `erf` are

Flags: `-O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2`. Isolates the algorithmic win independent of SIMD.

### 3. `sse2_intrinsics`

4-wide using `__m128` and SSE2/SSE4.1 intrinsics. Aligned loads (`_mm_load_ps`). Polynomial approximations vectorised, same coefficients as variant 2.
Flags: `-O3 -msse4.2 -mno-avx -mno-avx2 -mno-fma`.

### 4. `avx2_fma_intrinsics`

8-wide using `__m256` and AVX2 + FMA. `_mm256_fmadd_ps` throughout the polynomial evaluation (Horner's method with FMA). Aligned loads.
Flags: `-O3 -mavx -mavx2 -mfma`.

Polynomial coefficients live in `poly.h` and are shared between variants 2–4 — no chance of one path drifting from another. Source citation in comments.

### Why hand-roll the polynomials rather than pull in Sleef / Vectorclass / SVML

Deliberate choice. The alternatives:

- **Sleef** — well-engineered vectorised libm; would give a faster, more accurate result with less code
- **Agner Fog's Vectorclass** — clean C++ wrapper, similar story
- **Intel SVML** — closed-source, not portable to the toolchain in question

Reasons to do it by hand for this post:

1. **The post's claim is about understanding the transformation, not about shipping fast Black-Scholes.** Pulling Sleef would reduce variants 3–4 to a 20-line wrapper — readers learn nothing about how vectorised transcendentals actually work. Hand-rolling Horner's method with `_mm256_fmadd_ps` is the part a quant dev wants to see you can write.
2. **No external build dependency.** The repo currently has zero third-party C++ deps beyond Google Benchmark. Adding Sleef means a submodule, a build-system change, and a footnote on every chart about which Sleef version produced the numbers. Not worth it for one demo.
3. **The algorithm-win column (variant 1 → variant 2) requires hand-rolled scalar polynomials anyway.** Once those exist, vectorising them for variants 3–4 is a small additional step. Pulling Sleef _only_ for variants 3–4 means variant 2 and variants 3–4 are using different approximations and the speedup decomposition stops being clean.
4. **Cody 1980 and Abramowitz & Stegun 7.1.26 are well-trodden ground.** Not novel numerical work — a 30-year-old recipe, cited in comments, with a correctness check pinning the result against libm to 1e-4. Small risk surface.

State this trade-off briefly in the post's "What this doesn't show" section — readers shipping real pricing code should reach for Sleef or a vendor library, not copy `poly.h`.

## What to record per variant

Per the existing schema (`ns_per_op` stats + `ops_per_sec`). Additions for this demo:

- `instructions_per_cycle` — from `perf stat`
- `gflops` — derived. Count flops per option exactly in `poly.h` comments (rough estimate: ~30 fp ops per call price including the transcendentals) and use that count; don't hand-wave
- `max_abs_error_vs_scalar_libm` — per-variant correctness check against variant 1
- `variant_isa`: `"sse4.2"` (variants 1–2 don't use SSE intrinsics but compile at SSE4.2 baseline), `"sse4.2"`, `"avx2+fma"` — labels the chart layer can render without inferring from variant names
- `compile_flags` — per-run, since flags now differ per variant. **Schema extension; additive, won't break v1 demo's JSON.**

## Hardware gotchas — bake these into the implementation, not just the post

**Denormals.** Set FTZ + DAZ at benchmark start:

```cpp
_MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);
_MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);
```

Black-Scholes produces subnormals in deep-OTM tails; without FTZ those cost 50+ cycles each on Zen 2 and contaminate the benchmark with noise that has nothing to do with SIMD.

**Alignment.** All input/output arrays `alignas(32)`. The harness verifies alignment at startup and aborts on violation — silent unaligned loads would mask a real SSE-vs-AVX comparison.

**AVX↔SSE transition.** Less of a penalty on Zen 2 than on Skylake, but each variant is a self-contained TU with its own ISA flags and `run_one.sh` runs them in separate process invocations. No mixing in one binary's hot loop.

**Autovec verification.** The point of variants 1–2 is that the compiler can't autovec `std::exp` / `std::erf`. Verify by inspecting the inner-loop assembly of `scalar_libm` and `scalar_poly` — there should be no `vmovaps` / `vfmadd` in the hot loop. Commit the dumps under `bench/demos/03-simd-blackscholes/asm/` for the record. If GCC partially autovecs anyway, also annotate the hot function with `__attribute__((optimize("no-tree-vectorize")))`.

**Working-set sizing.** 1M × 5 floats × 4 bytes = 20 MB — doesn't fit in L2 (512 KB per core on Zen 2), spills to L3 or DRAM. Headline N = 1M is therefore part SIMD test, part memory-bandwidth test. Be honest about that in the post. The 16k companion run (16k × 20 bytes = 320 KB, fits in L2) isolates the compute-bound case. Both numbers in the JSON, the post contrasts them.

**Zen 2 µop split.** Document the prediction (AVX2 < 2× SSE on this hardware) in the demo's `README.md` and the MDX post; report what was actually measured.

## Build / file layout

```
bench/demos/03-simd-blackscholes/
├── CMakeLists.txt
├── README.md                          # variant table, ISA flags, gotchas
├── benchmark.cpp                      # Google Benchmark registration, input gen
├── scalar_libm.cpp                    # variant 1
├── scalar_poly.cpp                    # variant 2
├── sse2_intrinsics.cpp                # variant 3
├── avx2_fma_intrinsics.cpp            # variant 4
├── poly.h                             # shared polynomial coefficients + sources
├── verify.cpp                         # correctness check (separate target)
└── asm/                               # committed disassembly dumps
    ├── scalar_libm.s
    ├── scalar_poly.s
    ├── sse2_intrinsics.s
    └── avx2_fma_intrinsics.s
```

`verify.cpp` builds as a separate target invoked by `run_one.sh` before the benchmark proper. Keeps the benchmark binary lean and means a correctness regression fails fast and visibly rather than silently corrupting a chart.

## Site additions

- `site/src/data/perf/03-simd-blackscholes.json` — emitted by `scripts/run_one.sh 03-simd-blackscholes`
- `site/src/posts/03-simd-blackscholes.mdx`

No new components.

## MDX post structure

1. **Hook.** "Same pricing model, four implementations, ~30× spread top to bottom — and roughly half the speedup is from the math, not the SIMD."
2. **The workload.** One paragraph plus the formula. The audience knows BS; don't over-explain.
3. **Variants.** `<CodeCompare>` showing `scalar_poly` vs `avx2_fma_intrinsics` (the most informative diff — same algorithm, different width). Reference the repo for the other two.
4. **Headline chart.** `<ThroughputBars>` showing all four variants at N = 1M, median ns/op. Caption: "Options priced per second, higher is better."
5. **Decomposing the speedup.** Algorithm win (1→2), SSE width win (2→3), AVX2 width win (3→4). State the Zen 2 prediction up front and report whether it held.
6. **Precision.** State `max_abs_error_vs_scalar_libm` for variants 2–4. Explicitly discuss whether the tradeoff is acceptable for a pricing context — don't gloss.
7. **What this doesn't show.** AVX-512 isn't on this hardware. Zen 4 / Sapphire Rapids would tell a different story. Implied volatility (the inverse problem) is a separate post.
8. **Methodology link.**

## Acceptance criteria

- `cmake --build build --target 03-simd-blackscholes` succeeds with the documented per-variant flags
- `./scripts/run_one.sh 03-simd-blackscholes` produces JSON matching the schema, with four variants and at least the N = 1M run (plus 16k companion)
- Correctness: `max_abs_error_vs_scalar_libm` < 1e-4 for variants 2–4 across the full input range (tighten to 1e-5 if achievable with the chosen polynomial)
- Assembly dumps committed under `asm/`; inner loop of `avx2_fma_intrinsics.s` contains `vfmadd` instructions and no calls to libm
- The post renders the code comparison and the throughput bars
- AVX2-vs-SSE speedup reported faithfully — not silently inflated if it lands below 2×

## Open items for CC to flag

- Whether `-fno-tree-vectorize` alone is sufficient to defeat autovec of the scalar variants on the installed GCC, or whether `__attribute__((optimize(...)))` on the hot function is also needed.
- Exact flop count per option for the `gflops` derivation — count and document in `poly.h` comments alongside the polynomial.
- Specific polynomial sources to use: Cody (1980) for `erf` and a standard range-reduced minimax polynomial for `exp` are the defaults. If CC finds a cleaner well-cited alternative during implementation, fine — cite it in `poly.h` and keep variants 2–4 using the same coefficients.

## Out of scope (this demo)

- Put options — trivial extension via put-call parity, mention in the post
- American options — different problem, different demo
- Implied volatility — inverse problem, separate post
- AVX-512 — deferred to rented-bare-metal post
- GPU comparison — deferred
- Vectorised RNG for input generation — one-time cost, off the hot path
