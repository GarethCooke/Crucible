# Crucible — Demo 09 ARM NEON pilot bench (throwaway)

Implementation brief for Claude Code. Builds a **throwaway** calibration bench under `bench/pilot/09-arm-neon/` to answer the go/no-go questions in `demo-09-arm-neon-pilot-scope.md`. This is scaffolding, not demo code: it is **not** wired into `run_one.sh`, **not** committed to `site/`, and is deleted or absorbed when the demo 9 implementation brief lands. It runs on the **Pi 5 rig only** (AArch64).

## Context

The Pi 5 bench rig is capture-ready (green `pi-preflight.sh`: isolation `2-3`, governor performance, clock pinned 2400 MHz, `get_throttled=0x0`, `perf stat` functional). Scripts shipped via `crucible-pi-rig-setup-brief.md`.

This bench exists to resolve five questions before the demo 9 implementation brief is written. Read `demo-09-arm-neon-pilot-scope.md` for the full rationale and decision rules — this brief builds the tool; the user runs it and adjudicates §A.

- `03-simd-blackscholes-brief.md` — the x86 sibling. Reuse its math. Variants live in `bench/demos/03-simd-blackscholes/`; `poly.h` carries the polynomial `exp` (range-reduced) and `erf`/`N(x)` (Cody 1980 / A&S 7.1.26) approximations, and `scalar_poly` is the scalar polynomial variant whose SSE sibling (`sse2_intrinsics`, 4-wide `__m128`) is the structural template for the NEON port.
- `BRIEF.md` — counters are captured by invoking `perf stat` via shell wrapper. The pilot's counter check (A1) is therefore a `perf stat -e ...` question, run by the user against the built binary; this brief does **not** build a counter-capture path.

The reference machine for this bench is the **Pi 5** (BCM2712, Cortex-A76, AArch64). Build with `-mcpu=cortex-a76`. **Do not** use `-march=native` or `-mtune=native`.

## Tasks

### 1. Create `bench/pilot/09-arm-neon/poly_neon.h`

Port the demo 3 polynomial kernels to NEON `float32x4_t`. Two callable price functions over aligned arrays:

- `price_scalar(const float* S,K,T,r,sigma, float* C, size_t n)` — scalar polynomial path. Reuse `bench/demos/03-simd-blackscholes/`'s `poly.h` scalar approximations **verbatim** where they port (the `exp`/`erf` math is ISA-neutral). This is the A2/A3 baseline.
- `price_neon(...)` — the same math, hand-vectorised 4-wide with NEON intrinsics (`<arm_neon.h>`: `float32x4_t`, `vld1q_f32` aligned loads, `vfmaq_f32` for FMA, `vmulq/vaddq/vsubq`, etc.). Same polynomial coefficients as the scalar path — this is a width port, not a different approximation.

Process the array in 4-wide chunks; handle the `n % 4` tail with a scalar remainder loop. Inputs/outputs are `float`, 16-byte aligned (NEON is 128-bit).

Keep the polynomial coefficients in one shared place so scalar and NEON provably use identical constants (an A3 fairness requirement — the gap must be width, not different math).

### 2. Set FPCR flush-to-zero at startup

Provide a `set_ftz()` that sets the **FPCR FZ bit (bit 24)** via inline asm (`mrs`/`msr fpcr`) or the fpcr builtin. AArch64 has no separate DAZ — FZ covers denormal inputs and outputs. Call it once at bench start. This is the ARM analogue of demo 3's `_MM_SET_FLUSH_ZERO_MODE`; without it, deep-OTM subnormals contaminate the timing (see scope §A5). Print a one-line confirmation that FZ is set (read FPCR back and check the bit).

### 3. Create `bench/pilot/09-arm-neon/pilot_blackscholes.cpp`

A single binary, no Google Benchmark dependency required (keep it self-contained and trivial to run under `taskset`):

- **Input generation** identical to demo 3: seeded `std::mt19937` seed `0xCAFEBABE`, ranges S∈[50,150], K∈[50,150], T∈[0.05,2.0], r∈[0.0,0.08], σ∈[0.1,0.6]. Arrays `alignas(16)`. Generate once at startup, off the timed path.
- **CLI:** `--variant {scalar|neon}` and `--n {N}`. Default N = 1048576.
- **Timing:** 5 timed runs of the priced loop over all N options; report **median ns/op** and **ops/sec** to stdout, one clean line per run plus a summary line. Use a steady clock; sink the output array with a volatile read or equivalent so the loop isn't optimised away.
- **Correctness gate:** before timing, price a small sample with a scalar **libm oracle** (`std::exp`/`std::erf` from `<cmath>`) and assert `max_abs_error < 1e-4` against the variant under test. Abort with a clear message if it fails — we do not trust a speed number from math that's wrong. Same bar as demo 3.
- Call `set_ftz()` (Task 2) before any pricing.

### 4. Create `bench/pilot/09-arm-neon/CMakeLists.txt`

Build `pilot_blackscholes` with `-O3 -mcpu=cortex-a76`. Two notes:

- The **scalar baseline must stay scalar.** NEON is baseline on AArch64, so `-O3` will autovectorise `price_scalar` by default — which would make A2/A3 measure autovec-vs-autovec. Compile the translation unit (or the `price_scalar` function via attribute) with `-fno-tree-vectorize` so the baseline is genuinely scalar. The NEON path is hand-written intrinsics and is unaffected.
- Emit an assembly dump of both hot loops (`price_scalar`, `price_neon`) under `bench/pilot/09-arm-neon/asm/` so the user can eyeball A5 (vector `fmla`/`v`-regs present in NEON, absent in scalar) without re-deriving the build.

### 5. Create `bench/pilot/09-arm-neon/README.md`

Short. State that this is a throwaway pilot bench, not demo code; that it answers `demo-09-arm-neon-pilot-scope.md` §A; and give the exact run lines the user executes on the rig:

```
# A2/A3 — ratios at the two N
taskset -c 3 ./pilot_blackscholes --variant scalar --n 16384
taskset -c 3 ./pilot_blackscholes --variant neon   --n 16384
taskset -c 3 ./pilot_blackscholes --variant scalar --n 1048576
taskset -c 3 ./pilot_blackscholes --variant neon   --n 1048576

# A1 — full counter set
perf stat -e cycles,instructions,branch-misses,cache-misses,cache-references \
  taskset -c 3 ./pilot_blackscholes --variant neon --n 1048576

# A5 — codegen eyeball
objdump -d ./pilot_blackscholes | less   # or inspect asm/ dumps
```

Note that A4 (sustained-load thermal soak) and the temp/throttle polling loop are run by the user per the scope doc — not part of this binary.

## Acceptance

- `bench/pilot/09-arm-neon/` contains `poly_neon.h`, `pilot_blackscholes.cpp`, `CMakeLists.txt`, `README.md`.
- `cmake --build` of the pilot target succeeds on the Pi with `-mcpu=cortex-a76`; binary runs and prints median ns/op + ops/sec for both variants and both N.
- Correctness gate active: running either variant prices the oracle sample and asserts `max_abs_error < 1e-4` before timing.
- `set_ftz()` is called before any pricing and prints confirmation the FPCR FZ bit is set.
- `asm/` contains dumps of both hot loops; `grep -E 'fmla|v[0-9]+\.4s' asm/price_neon*.s` returns matches (NEON present), and the equivalent grep on the scalar dump returns **none** (scalar baseline genuinely scalar).
- Scalar and NEON paths use the same polynomial coefficients from a single shared definition (grep shows one coefficient source, referenced by both).
- `git status` shows new files **only** under `bench/pilot/09-arm-neon/`. No changes anywhere in `bench/demos/`, `bench/scripts/`, `bench/common/`, or `site/`.

## Out of scope

- **Anything in `bench/demos/`.** Do not add a demo directory, do not touch demo 3's `poly.h` (copy/include the math; if a shared header is the cleaner route, propose it as a follow-up — do not refactor demo 3 here).
- **Wiring into `run_one.sh` / `run_all.sh` / the JSON schema / `machine_info.h`.** The pilot is run by hand under `taskset`. Capture-path integration is implementation-brief scope.
- **Chart components, MDX, `site/` anything.**
- **The algorithm-win variant** (libm vs poly) and the **full N-sweep** (1k/256k). The pilot needs only 16k and 1M and only the scalar/NEON pair.
- **The counter-capture code path.** A1 is answered by the user running `perf stat` against the binary; do not build perf invocation into the bench.
- **A4 thermal soak.** User runs the polling loop from the scope doc; not this binary's job.

## Open items for CC to flag

1. **Scalar baseline still autovectorising.** If, after `-fno-tree-vectorize`, the scalar `asm/` dump _still_ shows NEON in the hot loop (GCC can vectorise via other passes), **stop and flag** — try the per-function `__attribute__((optimize("no-tree-vectorize")))` and, if that also fails, report it rather than shipping a baseline that secretly uses NEON. A2/A3 are meaningless if the baseline is vectorised.
2. **NEON `erf`/`exp` accuracy.** If the NEON port can't hit `max_abs_error < 1e-4` (intrinsic reciprocal/sqrt estimates `vrecpeq`/`vrsqrteq` are lower-precision than their scalar counterparts and may need a Newton-Raphson refinement step), **flag and propose** — either add the refinement step (and note the cost) or relax to 1e-3 with an explicit justification. Do not silently ship a NEON path that's less accurate than the scope assumes.
3. **`poly.h` portability.** If parts of demo 3's `poly.h` are SSE-specific and don't cleanly provide the scalar math (e.g. the scalar path there leans on `__m128` helpers), extract just the ISA-neutral scalar polynomial into the pilot rather than dragging SSE headers onto the Pi. Note what you had to lift.
4. **Shared-header temptation.** If lifting the polynomial math suggests a `bench/common/poly.h`, that's plausibly the right move for the eventual demo — but it touches demo 3, so **do not do it in this brief.** Note it as a follow-up for the implementation brief to decide.
