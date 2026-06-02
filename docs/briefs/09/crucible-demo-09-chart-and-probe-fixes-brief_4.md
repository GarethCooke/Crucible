# Crucible — Demo 09 chart-colour (cross-arch palette) and machine-probe fixes

Fix-up found while verifying the §5→§3 calibration loop (`demo-09-05-calibration-loop-brief.md`)
and the §7 headline capture; extended (per user decision) to make the demo 03 ↔ demo 09 pairing
colour-consistent. Three edits, all on the demo-09 feature branch. Task 2 **blocked §7** (now
captured — probe confirmed emitting 4); Task 1 **blocks §6/§8** (charts unreadable otherwise);
Task 3 **blocks §8** (the published JSON's `notes` regressed to pre-loop wording). No timing
data is re-captured — the §7 numbers are correct. No edit to demo 03's MDX or `Benchmark.tsx`;
the colour change is entirely in the global `theme.ts` palette. See `demo-09-plan.md` (§4, §6, §7).

## Context

- **`theme.ts` palette — variants collapse to one colour, in both demos.** `variantColor()`
  returns `palette[variant]` if the key exists, else `palette.series[0]`. Demo 09's JSON keys
  (`autovec`, `neon`, `scalarlibm`, `scalarpoly`) are not palette keys, so every bar/line
  resolves to `series[0]` — the libm≈autovec coincidence, the scalar_poly gap, and the NEON
  line are one colour. Demo 03's keys (`scalarlibm`, `scalarpoly`, `sse2`,
  `avx2fma`) are _also_ absent, so demo 03 renders monochrome bars too. Both
  verified against `theme.ts` / `Benchmark.tsx`. The fix establishes one shared scheme so the
  cross-arch pairing reads: analogous variants take the same `series` index in both demos.
  Filtering/labels are unaffected (loaders key off raw `r.variant`; `variantLabels` supplies
  display names where the direct components are used).
- **`machine_info.h` — `cores_physical` probe fails on aarch64.** The probe is
  `lscpu | grep '^Core(s) per socket'`, which the Pi's `lscpu` doesn't emit in that wording
  (the topology shows as clusters/cores), so `phys` is empty and the field falls back to
  `"0"`. The §5 calibration loop hand-set the _committed JSON_ to `4`, but the harness is
  untouched — the §7 capture re-runs `machine_info_json()` and re-emits `0`, clobbering the
  fix. Verified against `machine_info.h`.

## Tasks

1. **`theme.ts` — establish the Black-Scholes cross-arch colour scheme (demos 03 + 09).** In
   the `palette` object, immediately after the demo-08 block, before `series:`:

   Find:

   ```ts
     'radix_lsd':  tokens.color.chart.series[2],
     series:   tokens.color.chart.series,
   ```

   Replace with:

   ```ts
     'radix_lsd':  tokens.color.chart.series[2],
     // Black-Scholes cross-arch pairing — shared colours across demo 03 (Zen 2) and demo 09 (Pi).
     // Both demos use the same JSON keys for the scalars, so those two entries serve both.
     // Analogous variants share a series index: libm[0], poly[1], 4-wide SIMD[2] (sse2 / neon).
     'scalarlibm': tokens.color.chart.series[0],   // demo 03 + demo 09
     'scalarpoly': tokens.color.chart.series[1],   // demo 03 + demo 09
     'sse2':       tokens.color.chart.series[2],   // demo 03 — 4-wide
     'neon':       tokens.color.chart.series[2],   // demo 09 — 4-wide, same colour as sse2
     'avx2fma':    tokens.color.chart.series[3],   // demo 03 only — 8-wide
     'autovec':    tokens.color.chart.series[4],   // demo 09 only
     series:   tokens.color.chart.series,
   ```

   Five keys (the two scalars are shared between the demos). Shared concepts share a colour:
   libm `series[0]`, poly `series[1]`, 4-wide SIMD `series[2]` (`sse2` in demo 03, `neon` in
   demo 09 — same colour, the cross-arch analogue). `series[3]` (demo 03's AVX2) has no demo-09
   counterpart, so the absent colour _is_ the width ceiling; `autovec` (demo-9-only) parks at
   `series[4]`.

   **Visible change to a shipped post:** demo 03's throughput bars go from one colour to four.
   That's intended — glance at `/posts/03-simd-blackscholes` after applying. No edit to demo
   03's MDX, data, or `Benchmark.tsx`; the colours arrive purely through this global palette.

   **Keys verified against JSON (2026-06-02):** `grep -o '"variant": *"[^"]*"'
src/data/perf/03-simd-blackscholes.json | sort -u` → `avx2fma`, `scalarlibm`, `scalarpoly`,
   `sse2`. These are the real strings (demo 03's MDX prose uses `sse2_intrinsics` /
   `avx2_fma_intrinsics`, which are **not** the data keys — do not use those).

2. **`machine_info.h` — fix the `cores_physical` probe.** In `machine_info_json()`:

   Find:

   ```cpp
       const auto phys     = shell("lscpu | grep '^Core(s) per socket' | awk '{print $NF}'");
   ```

   Replace with:

   ```cpp
       const auto phys     = shell("lscpu -b -p=core | grep -v '^#' | sort -u | wc -l | tr -dc '0-9'");
   ```

   Counts unique online physical cores: 4 on the Pi, 8 on the Zen 2 box. No magic constant,
   no x86-specific wording. The `tr -dc '0-9'` guards against any stray whitespace in `wc`
   output, keeping the existing `(phys.empty() ? "0" : phys)` fallback intact.

3. **Bench source — fix the hardcoded `notes` string (same regression class as Task 2).** The
   §7 capture (2026-06-02) re-emitted `notes` with the _pre-loop_ wording ("~4.5× at 16k, ~4.8×
   at 1M", no denominator named, no autovec/poly lines), overwriting the calibration-loop edit —
   exactly as it would have overwritten `cores_physical`. The `notes` string lives hardcoded in
   the demo-09 bench source (the harness driver / registration TU that builds the JSON, _not_
   `machine_info.h`). Locate it (`grep -rn "widest unit on BCM2712" bench/`) and replace the
   literal with the corrected text below, so re-runs emit it verbatim:

   ```
   Four variants of European call option pricing on AArch64 (BCM2712 / Cortex-A76). Cross-arch companion to demo 03 (Zen 2 SSE/AVX2). scalar_poly matches demo 03's construction exactly (libm log/sqrt + poly exp/N(x)). autovec: GCC cannot cross the logf@plt barrier — asm is scalar despite -O3 NEON target; timing within 0.01% of scalar_libm at every N. scalar_poly runs ~6% faster than scalar_libm (6.4% at 16k, 6.2% at 1M) — Debian libm erfc/exp cost is not negligible. neon: hand-written float32x4_t achieves ~4.3× at 16k (4.34×) rising to ~4.8× at 1M (4.81×) over scalar_poly (pure-width denominator); neon/scalar_libm is larger (~4.6× at 16k, ~5.1× at 1M) but folds the algorithm win into the ratio. No second SIMD step: 128-bit NEON is the widest unit on BCM2712 (no SVE).
   ```

   Then either re-emit the committed `09-arm-neon.json` `notes` from the fixed source, or
   hand-patch the committed JSON's `notes` to match (the timing data is already correct and
   must not be re-captured for this). **Drop the old `cores_physical hard-set to 4` sentence** —
   the probe now returns 4 on its own (the 2026-06-02 capture confirms it), so that sentence
   would assert a manual fix that no longer happens.

## Acceptance

- `grep -n "Core(s) per socket" machine_info.h` → 0 hits; the new `lscpu -b -p=core` probe is
  present.
- `grep -n "'scalarlibm'\|'scalarpoly'\|'autovec'\|'neon'" theme.ts` → `scalarlibm`/`scalarpoly`
  at `series` indices `0`/`1`, `neon` at `2`, `autovec` at `4`; `grep -n "'sse2'\|'avx2fma'" theme.ts`
  → `sse2` at `2`, `avx2fma` at `3`. Five keys total (the two scalars are shared by both demos).
  `neon` and `sse2` must both resolve to `series[2]` (the cross-arch 4-wide colour); `series[4]`
  is demo-09-only, `series[3]` demo-03-only.
- Demo 03's keys match its JSON exactly (grep-confirmed per Task 1), so no palette entry is dead.
- `/posts/03-simd-blackscholes` now renders four distinctly-coloured bars (was monochrome);
  demo 09's bars/lines render four distinct colours, none on the `series[0]` default by accident.
- On the §7 Pi capture (or a §5 re-run on the rig): emitted JSON `machine.cores_physical == 4`,
  with no hand-editing.
- No x86 regression: the next Zen 2 capture emits `cores_physical == 8` (user check, next time
  a Zen 2 demo is recaptured — not now).
- `grep -n "4.5×\|4.5x" 09-arm-neon.json` → 0 hits in `notes`; the committed JSON's `notes`
  names `scalar_poly` as the denominator, states 4.34×/4.81× (poly) and 4.6×/5.1× (libm), the
  autovec 0.01% line, and the scalar_poly ~6% line. No `cores_physical hard-set` sentence.
- `grep -rn "4.5×\|widest unit on BCM2712" bench/` → the bench source string matches the
  corrected text (so a re-run won't regress `notes` again).

## Out of scope

- Re-running any Zen 2 capture now — verify the probe there only next time one happens.
- The hand-set `4` in the committed §5 JSON — leave it; §7 supersedes once the probe is fixed.
- The §8 MDX itself. This brief only records two constraints for it: (a) use the direct
  `<ThroughputBars>` / `<TimeVsN>` components with `variants` + `variantLabels` keyed by the
  no-underscore JSON names (`scalarlibm`, `scalarpoly`, `autovec`, `neon`) — **not** `<Benchmark>`,
  which drops `variantLabels` and would render raw `capitalize` axis labels; (b) the loaders
  filter on raw `r.variant`, so the keys must match the JSON exactly.
- Demo 03's MDX, data, labels, and `Benchmark.tsx`. Task 1 changes demo 03's bar _colours_
  only (via the global palette); it does **not** touch demo 03's axis labels (still the
  `capitalize` output, e.g. `Scalar_libm`), its prose, or its chart wiring. Making demo 03's
  _labels_ match demo 09's `variantLabels` style would mean moving demo 03 off `<Benchmark>` —
  a separate decision, not this brief.
- Any other `theme.ts` palette entries or `machine_info.h` fields.
- The cross-arch ratio-only view composition — that's §6 proper, not this brief.

## Open items for CC to flag

- If `lscpu -b -p=core` is unsupported on the Pi's util-linux, fall back to counting distinct
  values in the CORE column of the already-captured `lscpu --extended`, or `nproc` with a
  noted caveat — but **stop and report** rather than silently emitting `0`.
- If CC cannot run on the Pi to confirm `cores_physical`, the user runs §7 and verifies the
  field — do **not** hand-edit the JSON a second time.
- **Cross-arch colours applied via the global palette.** Demo 03's bars are coloured by adding
  its keys to `palette` (demo 03 still uses `<Benchmark>`, which reads `variantColor(name)`).
  No demo-03 file changes. If the grep in Task 1 shows demo 03's JSON uses different variant
  strings than its prose, **stop and report** before adding mismatched keys.
- **§6 NEON/SSE share `series[2]`.** With NEON = SSE's colour, any §6 chart that plots the Pi
  NEON line _and_ the Zen 2 SSE line together would draw them in one colour. The plan frames §6
  as NEON-ratio vs AVX2-ratio (`series[2]` vs `series[3]`, distinct) — fine — but if SSE is
  also shown, that view should override line colours or use dashes. A §6 composition decision,
  flagged not resolved here.
