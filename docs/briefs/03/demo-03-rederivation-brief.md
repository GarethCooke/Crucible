# Demo 03 re-derivation patch brief (numeric pass) — boost-off recapture

Branch: `feature/boost-off-recapture`. Scope: `content/posts/03-simd-blackscholes.mdx` plus two single-token edits in `content/posts/09-arm-neon.mdx` (03→09 ratio coupling, playbook-mandated).

## Context

Demo 03 was recaptured 2026-06-05 at verified base clock. Clock forensics against the old JSON (2026-05-18) show deltas ≤0.6% at 1M — the old capture also ran at base clock; ratios are stable and the scalar baseline shows no vectorisation drift. This brief applies the numeric corrections only.

**The step 3→4 section is FENCED.** A Critical finding (C-1) established that the µop-split mechanism attributed to Zen 2 describes Zen/Zen+; Zen 2 has native 256-bit datapaths. The section, takeaway ¶2, and the "Zen 3+" bullet will be rewritten in a separate thesis-correction brief after a µop diagnostic capture (spec: `demo-03-uop-diagnostic-spec.md`). Do not touch those passages in this brief, including the stale `1.995×` figure inside the fenced section — it dies with the rewrite.

## Pre-flight sentinel (mandatory — abort on mismatch)

Verify in `03-simd-blackscholes.json` (site data copy):

- `captured_at` == `"2026-06-05T06:00:37Z"`
- `machine.turbo` == `false`, `machine.turbo_source` == `"cpb"`, `machine.freq_max_available_mhz` == `3900`
- run `variant=="avx2fma", n==1048576` has `ns_per_op.median` == `4.6156`
- run `variant=="scalarpoly", n==1048576` has `ns_per_op.median` == `43.1019`

Any mismatch → stop, report, do not edit.

## Tasks — 03-simd-blackscholes.mdx

### T1 — Frontmatter summary

Find: `summary: "Polynomial approximations buy 12% on their own — but they're the gate to a 9× SIMD win that libm's erfc can't reach."`
Replace: `summary: "Polynomial approximations buy 11% on their own — but they're the gate to a 9× SIMD win that libm's erfc can't reach."`

### T2 — Intro percentage

Find: `it for a polynomial approximation buys a modest 12% on its own — and is the gate`
Replace: `it for a polynomial approximation buys a modest 11% on its own — and is the gate`

### T3 — Step 1→2 figures

Find: `polynomial approximations gives a modest 12% standalone speedup (47.7 ns/option →
42.7 ns/option at N=1M).`

Replace: `polynomial approximations gives a modest 11% standalone speedup (47.7 ns/option →
43.1 ns/option at N=1M).`

(Derivation: 47.7048 / 43.1019 = 1.1068.)

### T4 — N=1024 overhead bullet (pre-existing defect; false against old JSON too)

Find: `- **Per-iteration harness overhead.** At N=1024 every variant runs ~5–6× slower
  per option than at N=1M because the perf-counter start/stop and function-call
  cost per iteration is fixed and amortises across N. Small-N numbers are
  measurement-floor-bound, not compute-bound.`

Replace: `- **Per-iteration harness overhead.** The per-iteration cost (perf-counter
  start/stop, function-call entry) is fixed, so at N=1024 it inflates per-option
  time in proportion to how fast the kernel is: AVX2 runs ~5× slower per option
  than at N=1M, SSE ~3×, and the scalar variants ~25–40% slower. Small-N numbers
  are measurement-floor-bound, not compute-bound.`

(Derivation, N=1024 vs N=1M medians: avx2fma 5.30×, sse2 2.91×, scalarpoly 1.41×, scalarlibm 1.24×. The shipped "every variant ~5–6×" was true of no variant except AVX2 in either capture.)

### T5 — Takeaway percentages (¶1 only — do NOT touch ¶2, it is fenced)

Find: `12% from swapping libm's \`erfc\` for a polynomial approximation, then 9× from`
Replace: `11% from swapping libm's \`erfc\` for a polynomial approximation, then 9× from`

Find: `widening to 8 lanes of AVX2 + FMA. The 12% step is unremarkable in isolation —`
Replace: `widening to 8 lanes of AVX2 + FMA. The 11% step is unremarkable in isolation —`

### T6 — Footer isolation correction (pre-existing defect)

Find: `cores 0–7 isolated, benchmarks pinned to 4–7`
Replace: `cores 1–7 isolated, benchmarks pinned to 4–7`

(JSON: `isolated_cpus_effective: "1-7"`; the shipped "0–7" traces to the old capture's `isolated_cpus_requested` field.)

## Tasks — 09-arm-neon.mdx (03→09 coupling)

The find-strings below were taken from the project-knowledge copy of 09; the working tree carries §9/§10 edits. **CC: locate these against the working tree; if the surrounding text has drifted, match on the cited figure and report the actual context before editing.**

### T7 — Cross-arch table, AVX2 16k cell

Find: `| Zen 2 / Ryzen 3800X | AVX2+FMA (8-wide) | 256-bit | 7.5× | 9.3× |`
Replace: `| Zen 2 / Ryzen 3800X | AVX2+FMA (8-wide) | 256-bit | 7.6× | 9.3× |`

(Derivation from new 03 JSON: 44.1492 / 5.8287 = 7.574 → 7.6×. Old capture gave 7.533 → 7.5×; the recapture moves the rounding.)

### T8 — Zen 2 algorithm-step reference

Find: `On Zen 2 the same step delivered 12%; on the A76 it's narrower,`
Replace: `On Zen 2 the same step delivered 11%; on the A76 it's narrower,`

("Narrower" still holds: A76 step is ~6%.)

## Acceptance criteria

Against `03-simd-blackscholes.mdx`:
1. `grep -c '12%'` → 0; `grep -c '11%'` → 5
2. `grep -c '42\.7 ns/option'` → 0; `grep -c '43\.1 ns/option'` → 1
3. `grep -c 'every variant runs'` → 0; `grep -c '~5× slower per option'` → 1
4. `grep -c 'cores 0–7'` → 0; `grep -c 'cores 1–7 isolated'` → 1
5. `grep -c '1\.995×'` → 1 (UNCHANGED — fenced; it is removed by the thesis brief, not this one)

Against `09-arm-neon.mdx`:
6. `grep -c '7\.5×'` → 0; `grep -c '7\.6×'` → 1
7. `grep -c 'delivered 12%'` → 0; `grep -c 'delivered 11%'` → 1

## Out of scope

- **The entire "Step 3 → 4" block** (from `**Step 3 → 4: AVX2 + FMA` through the `0.75 × 2.5 ≈ 1.9×` paragraph), **takeaway ¶2** ("On Zen 2 the AVX2/SSE ratio lands near 2×…"), and the **"Zen 3+" bullet** in "What this doesn't show" — all pending the C-1 thesis-correction brief gated on the µop diagnostic capture.
- The JSON `notes` field ("Zen 2 µop-split: AVX2/SSE < 2× predicted") — bench-side constant; fix rides the thesis brief or the hardening brief.
- The demo-03 batched-edit brief (arch/soc backfill, poly.h comment) — separate, gated on demo 09 §11 merge. No line collisions with this brief's tasks.
- All other demos, methodology page, correction note.
- 09's other Zen 2 references (SSE2 3.8×/4.1×, AVX2 9.3×, "~4.3×"/"~4.8×" Pi figures) — re-verified, hold. Do not edit.

## Open items

1. **C-1 thesis-correction brief** — written after the µop diagnostic lands (spec in `demo-03-uop-diagnostic-spec.md`). Replacement narrative drafted then: AVX2+FMA lands at/above the 2× nominal width ratio; FMA instruction economy (49.2 → 16.4 inst/option measured) versus non-width-scaling div/sqrt; "theoretical 4×" framing dropped.
2. Old shipped figure "42.7 ns/option" did not match even the old JSON (42.8419) — likely from a pre-May capture; noted for the correction note's provenance audit.
3. Clock forensics: demo 03's old capture at base clock (deltas ≤0.6%), same verdict as demo 02 — accumulating evidence for the "boost verification was absent, not boost was on" correction-note framing.
