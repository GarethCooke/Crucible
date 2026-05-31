# Crucible — Demo 09 implementation brief (§3)

Implementation brief for the demo 9 formal harness and headline capture: ARM NEON cross-arch Black-Scholes call pricing on the Pi 5 (BCM2712, Cortex-A76), the cross-arch companion to demo 3's Zen 2 SIMD shootout. Feeds `demo-09-plan.md` §4 (bench, CC), §6 (charts, Opus scope + CC apply), §7 (capture, user), and constrains §8 (MDX). The pilot (§2 + the baseline addenda) has returned GO and pinned every contingent decision; this brief commits them.

Format follows demo 7/8's implementation briefs. Bench work is on the feature branch, not `main`.

## Context

The pilot resolved the four open contingencies the plan flagged for §3:

- **Headline is the width ceiling, ~4.5×.** Hand-NEON over the demo-3-matched scalar baseline measured **4.47× at 16k, 4.78× at 1M** (pilot, throwaway bench). This is against `scalar_poly` built to demo 3's exact construction, so it is directly comparable to demo 3's `sse2/scalar_poly` (3.79× / 4.12×).
- **Two stories, not one — autovec is the second axis, and it's a null-that-isn't.** GCC's autovectoriser produced output **byte-identical to the scalar baseline** (asm-identical after address normalisation; timing within 0.1%). It cannot cross the libm `logf` call or the data-dependent edge branch. On AArch64, where NEON is on by default at `-O3`, "baseline" does not mean "free": reaching the ceiling requires hand-written branchless intrinsics. That is a genuine finding and ships as a charted line.
- **Counters populate (A1 pass).** cycles, instructions, branch-misses, cache-misses/refs all read on the A76 PMU. The `<CounterOverlay>` panel stays in.
- **Thermal pass, thin margin (A4).** `throttled=0x0` for the full soak; peak 78.5°C, ~1.5°C under the soft-throttle point, still drifting up at the end of the window. Capture is trustworthy but the before/after `get_throttled` guard is load-bearing — see §Capture environment.

Two cross-arch nuggets the pilot surfaced, both relevant to framing:

- The demo-3-spec `scalar_poly` (libm log + poly exp/N(x)) is **dead-equal to all-libm `scalar_libm`** on the A76 (within 0.05%), where the same poly swap is +11% on x86. The poly exp/N(x) advantage does not travel to ARM. Useful consequence: the baseline choice does not change the ratio, so the demo-3-matched baseline and the simplest all-libm baseline measure the same — no caveat to carry about which we picked.
- An all-poly scalar (poly log too) is ~12% _slower_ than libm on the A76 — the reverse of x86. This is **not isolated** (log change bundled with the exp/N(x) change) and does **not** ship; recorded in pilot notes only. Do not state a "poly log is slower on ARM" claim in the post.

The thesis does not rest on the exact first-step ratio. It rests on the contrast: Zen 2 takes the SSE step (~4×) **and then a second AVX2 step** (1.99× at 16k, 2.25× at 1M); the A76 has **no second step**, because 128-bit NEON is the widest unit on the BCM2712 — no SVE. That presence-vs-absence is the spine and no baseline choice touches it.

Companion docs: `demo-09-plan.md` (story angle, §6 chart intent, what-this-doesn't-show); `demo-09-arm-neon-baseline-correction-brief.md` (the shipped `scalar_poly` construction); `bench/demos/03-simd-blackscholes/` (the sibling to match for kernel, poly.h, FTZ, N-sweep, ratio denominators).

## Variant set (pinned)

Four shipped variants, parallel to demo 3's `{scalar_libm, scalar_poly, sse2, avx2fma}` — demo 9 collapses the two SIMD widths to one (the point: there is no wider unit) and adds `autovec` (the point: baseline ≠ free).

| variant       | construction                                                                                                                                | role                                                          |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `scalar_libm` | all libm (`logf`, `expf`, `erff`/`N`), **anti-autovec guard** so it is genuinely 1-wide                                                     | secondary baseline; the autovec comparand                     |
| `scalar_poly` | libm `log` + libm `sqrt` + inline poly exp (`fast_expf`) + inline poly N(x) (`ncdf_poly`), single-element serial — **demo 3's exact split** | **width-ratio denominator**                                   |
| `autovec`     | the natural libm kernel, **no anti-autovec guard**, `-O3` free autovectorisation                                                            | the "baseline ≠ free" line; expected to land on `scalar_libm` |
| `neon`        | hand-written `float32x4_t`, branchless edge handling, inline poly log/exp/N(x)                                                              | **headline**                                                  |

The `scalar_fullpoly` diagnostic (all-poly incl. log) from the pilot is **not** a shipped variant — pilot notes only.

## Tasks

### 1. Formal bench [CC]

Build `bench/demos/09-arm-neon/` with the four variants above. Mirror demo 3's `scalar_poly.cpp` / `poly.h` structure for the matched baseline. AArch64 build target, `-O3 -mcpu=cortex-a76`, FPCR FZ bit set at startup (the ARM analogue of demo 3's `_MM_SET_FLUSH_ZERO_MODE`). `run_one.sh 09-arm-neon` orchestrates the build + sweep + JSON assembly, consistent with demos 1–8.

### 2. Anti-autovec guard on `scalar_libm` and `scalar_poly` [CC]

Both scalar variants carry the guard so they are genuinely 1-wide. `autovec` is the same natural kernel with the guard removed. Verify by asm grep (acceptance below) — this is the demo 5–8 lesson and is re-checked in §5.

### 3. N-sweep [CC]

Sweep `{1024, 16384, 262144, 1048576}`, matching demo 3. **Headline N = 16384** (L2-resident, cleanest per-cycle, demo 3's cleanest-comparison point). ≥5 outer repetitions, report median ns/op and ops/sec per variant per N.

### 4. JSON output + machine block [CC]

Output to `site/src/data/perf/09-arm-neon.json`, validating against the locked schema. The **second-machine schema question** is now live: add an `arch` (and/or `soc`) field to the `machine` block to represent the Pi (AArch64 / BCM2712 / Cortex-A76) distinctly from the Zen 2 rig. If adding the field requires touching demo 1–8 JSON or the schema in a way that affects shipped demos, **stop and report** before editing — that is a cross-demo decision, not a unilateral §4 change.

### 5. Counter capture [CC bench, user run]

`<CounterOverlay>` panel stays (A1 passed). Capture cycles, instructions, branch-misses, cache-misses/refs for the headline variants. Record any raw-event fallback used for the A76 PMU mapping.

### 6. Chart set [Opus scope, CC apply — §6]

Pinned:

- `<TimeVsN>` — the N-sweep: the NEON curve (flat, cache-insensitive at this size) against the scalar curve. Within-machine.
- `<ThroughputBars>` — the width ratio, `neon` over `scalar_poly`, with `scalar_libm` and `autovec` shown coincident to make the "autovec = scalar" point visible.
- `<CounterOverlay>` — IPC and cache behaviour, headline N.
- `<CodeCompare>` — scalar inner body vs the `float32x4_t` NEON body (branchless edge handling is the visible contrast).
- **Cross-arch ratio ladder** — the §6 composition. A ratio-only view (never absolute ns/op) showing both arches' steps: Zen 2 `scalar → SSE (~4×) → AVX2 (+2×)` and Pi `scalar → NEON (~4.5×) → [no rung]`, the A76's wider-than-128-bit slot explicitly empty and labelled (no SVE). **Compose from `<ThroughputBars>`; do not fork a bespoke component.**

### 7. Capture environment [user — §7]

Stated, not assumed:

- Headless boot, core isolation `isolcpus=2,3`, capture pinned `taskset -c 3`.
- `pi-preflight.sh` green: clock pinned 2400 MHz (min=max), `get_throttled=0x0` verified **before and after** the capture run (A4 — the thin thermal margin makes the after-check mandatory).
- Capture session must not run materially longer than the §2 soak window without re-checking throttle, given the late-window upward drift.
- ≥5 outer repetitions. Output to `site/src/data/perf/09-arm-neon.json`.

### 8. Content constraints for §8 (MDX) [named here, drafted in §8]

- **Cross-link:** backward-link to demo 3 (same kernel, different ISA — the width-ceiling contrast is the spine of the pairing); a forward-link from demo 3 to demo 9 is inserted.
- **"What this doesn't show":** no cross-machine absolute ns/op comparison anywhere; result is A76-specific (a core _with_ SVE would scale past the ceiling — a possible sequel, not this post); not a claim that ARM is fast or slow.
- Methodology page documents the second reference machine and bumps the demo total to 9.

## Acceptance

### Bench codegen [CC, before capture]

- `scalar_libm`: `logf@plt` present; **zero `.4s`**; stride one element. Anti-autovec guard verified (no parallel-float ops in the hot loop).
- `scalar_poly`: `logf@plt` present, `expf@plt` and `erff@plt` absent; **zero `.4s`**; stride one element. (Matches the pilot binary — `demo-09-arm-neon-baseline-correction-brief.md`.)
- `autovec`: same natural kernel as `scalar_libm` with the guard removed; asm is scalar (zero `.4s` parallel-float compute — confirms GCC still cannot cross the `logf` barrier in the committed build).
- `neon`: `float32x4_t` ops present (`.4s`), no `bl …@plt` in the main vector loop, 4-element stride.

### Numbers reproduce (§5 preflight)

The formal harness must reproduce the pilot within tolerance at the headline N:

- `neon / scalar_poly` ≈ 4.5× at 16k, ≈ 4.8× at 1M (pilot: 4.47× / 4.78×).
- `autovec` within ~1% of `scalar_libm` at both N.
- `scalar_poly` within ~1% of `scalar_libm` at both N (the A76 poly-swap wash).
- correctness `max_abs_error` < 1e-4 all variants (pilot: 2.670e-05).
  A divergence beyond tolerance loops back to §4 or rescopes §3 — expected, not a failure.

### JSON [CC]

- `09-arm-neon.json` validates against the schema (with the agreed `arch`/`soc` field).
- All ratios derivable from committed `ops_per_sec`; no pre-computed/hand-entered ratios.
- Machine block identifies the Pi distinctly from the Zen 2 rig.

### Charts [§6]

- Every cross-arch view is ratio-only; no absolute ns/op crosses machines anywhere.
- Cross-arch ladder composed from `<ThroughputBars>`, not a new component.

## Out of scope

- The MDX prose (§8) — this brief names its constraints; it does not draft it.
- The `scalar_fullpoly` diagnostic — pilot notes only, not shipped.
- An unrolled / throughput-bound baseline — ruled out; demo 3 is single-element serial, demo 9 matches that class.
- Isolating poly-log vs libm-log on either arch — a future micro-investigation, not this demo.
- Editing demo 3's code, JSON, or prose beyond the single forward-link insertion (§8). Any width-attribution rewording in demo 3's MDX is a separate decision (flag in §9).
- The quantum special edition — post-§11, per the plan's stop condition.

## Open items

1. **Machine-block schema (§4).** The `arch`/`soc` field is the first real second-machine schema change. If it cannot be added without touching shipped demo 1–8 JSON, stop and surface the options before editing.
2. **Shared `poly.h` (§4).** The bench currently copies demo 3's polynomial math. Whether `bench/common/poly.h` is the right home is a §4 call that touches demo 3 — deferred from the pilot, decide explicitly here or defer again, but do not silently fork a third copy.
3. **Demo 3 width-attribution (§9).** Demo 3's MDX attributes its >4× SSE ratio to "loop-overhead and pipeline-fill" without isolating the libm-log→poly-log swap baked into its `scalar_poly` denominator — the same construction demo 9 now matches. Whether to add a one-line clarification to demo 3 is a §9 hostile-cross-read decision, flagged here so it is not lost.
4. **PMU raw-event fallback (§5).** If any A76 counter needs a raw-event code rather than a symbolic perf event, record it in the bench so the capture is reproducible.
