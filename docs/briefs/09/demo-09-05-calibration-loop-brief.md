# Crucible — Demo 09 §5→§3 calibration loop brief

Loops the §3 implementation brief (`09-arm-neon-brief.md`) against the §5 calibration
results, per the §4→§5 loop-back path named in `demo-09-plan.md` (§43). Cleanup/remediation
style: short context, numbered quote-and-replace edits, grep-verifiable acceptance. Lands on
the demo-09 feature branch. Blocks §7 headline capture — do not recapture until the brief is
correct, because §8's prose inherits these claims and §7's headline number depends on the
denominator decision below.

## Context

The §5 calibration capture (`09-arm-neon.json`, `captured_at` 2026-06-01) reproduces the
pilot through the formal harness, but contradicts two §3 brief claims. Both are verified
against the committed JSON _and_ the committed assembly (`scalar_libm.s`, `scalar_poly.s`,
`autovec.s`, `neon_intrinsics.s`):

- **scalar_poly is 6–7% faster than scalar_libm**, not "within 0.05%." 7.04% @16k → 6.28%
  @1M. Mechanism confirmed in asm: `scalar_libm` makes `expf` + `erfcf`×2 PLT calls per
  option (`bl logf`/`bl expf`/`bl erfcf`×2); `scalar_poly` inlines exp and N(x), keeping only
  `logf`. The Debian libm `erfc`/`exp` cost is not negligible.
- **Baseline choice changes both the ratio _and_ the validity of the width-ceiling claim.**
  neon and scalar_poly are the same algorithm (identical `max_abs_error` 5.722e-05; neon is
  the 4-lane poly kernel). neon/scalar_poly = 4.32× @16k → 4.74× @1M (pure width).
  neon/scalar_libm = 4.65× @16k → **5.05×** @1M (width × the 6–7% algorithm win). A width
  ceiling headline reported against scalar_libm reads >5×, appearing to beat the 4-wide
  ceiling — wrong. scalar_poly is the only honest denominator for the stated thesis.

Also: one §4 JSON-output bug and one variant-key consistency check (below).

The "autovec ≡ scalar_libm (GCC can't cross the `logf` barrier)" finding is **unchanged and
confirmed** — autovec's asm is structurally identical to scalar_libm and the two run within
0.01% at every N. Do not touch it.

## Tasks

1. **§3 — scalar_poly/scalar_libm equivalence claim.** Find the sentence asserting the two
   scalar variants are equal (CC quoted it as containing **"within 0.05%"**). Replace the
   equivalence claim with:

   > `scalar_poly` runs 6–7% faster than `scalar_libm` (7.0% at 16k narrowing to 6.3% at
   > 1M). The gap is the algorithm, not the harness: `scalar_libm` pays libm `exp` and two
   > `erfc` calls per option, which `scalar_poly` inlines as polynomial approximations
   > (verified in the committed asm — `scalar_libm` emits `bl expf` + `bl erfcf`×2 in the
   > hot path, `scalar_poly` emits neither).

2. **§3 — baseline-invariance claim.** Find the sentence stating the baseline choice does not
   affect the speedup (CC quoted it as **"baseline choice does not change the ratio"**).
   Replace with:

   > The baseline choice changes both the number and the meaning. `neon` and `scalar_poly`
   > share the same polynomial kernel (identical `max_abs_error`, 5.722e-05) — `neon` is its
   > 4-lane form — so `neon`/`scalar_poly` is the pure vector-width speedup: ≈4.3× at 16k,
   > rising to ≈4.7–4.8× at 262k–1M as fixed per-call overhead amortises. `neon`/`scalar_libm`
   > is larger (≈4.65× at 16k → ≈5.05× at 1M) only because it folds the 6–7% algorithm win
   > into the ratio. **A vector-width claim must use `scalar_poly` as the denominator**: a
   > 4-wide unit cannot deliver a width speedup above 4×, so the >5× figure against
   > `scalar_libm` would silently smuggle the algorithm win into "width" and read as beating
   > the very ceiling this post is about.

3. **§3 — headline number.** Grep §3 for the headline ratio and set it to the scalar_poly
   denominator: **≈4.3× at 16k, ≈4.7× at 1M**. Phrase the ceiling as the 4-wide _packing_
   limit realised at ≈4.3–4.8× (the residual above 4× is reduced loop overhead, not a wider
   unit) — not "exactly 4×." Do not state a 5× figure anywhere as the width result.

4. **§3 — autovec coincidence wording.** Grep §3 for the autovec-coincident claim and make it
   precise: autovec is coincident with **scalar_libm** (0.01% at every N), _not_ with
   scalar_poly. The `<ThroughputBars>` panel therefore shows three scalar-tier levels, not
   two: `scalar_libm ≈ autovec` (coincident), `scalar_poly` 6–7% below them, `neon` 4.3–4.7×
   below `scalar_poly`.

5. **§4 JSON output — two fixes** (fold here; cheap, blocks clean §7):
   - `machine.cores_physical` is `0` (probe failed). Set the probe to report **4**, or
     hard-set 4 with a comment, for the Cortex-A76 / BCM2712. Re-emit the §5 JSON so the
     machine block is correct before §7 reuses the harness.
   - Variant keys in the JSON are `"scalarlibm"` / `"scalarpoly"`; prose and chart labels use
     `scalar_libm` / `scalar_poly`. Pick one spelling and make the JSON keys, the
     `<ThroughputBars>` / `<TimeVsN>` loaders, and the prose agree. Confirm which form the
     chart components already expect before renaming either side.

## Acceptance

- `grep -n '0\.05%' 09-arm-neon-brief.md` → 0 hits.
- `grep -n 'does not change the ratio' 09-arm-neon-brief.md` → 0 hits.
- §3 headline cites 4.3× (16k) and 4.7× (1M); no `5×`/`5.0×`/`5.05×` appears as the width
  result anywhere in the brief.
- §3 names `scalar_poly` as the width-ceiling denominator and states the libm-baseline figure
  is width × algorithm.
- §3 autovec sentence names `scalar_libm` (not `scalar_poly`) as the coincident variant.
- Re-emitted JSON: `machine.cores_physical == 4`; variant keys consistent with the chart
  loaders (grep the loader for the accepted key spelling, confirm a match).
- All numerical claims in §3 derive from `09-arm-neon.json` to one significant figure, not
  from the brief's prior prose.

## Out of scope

- §7 headline recapture — user task on the Pi rig, _after_ this loop lands. (The denominator
  decision in Task 2/3 is what §7's headline number must report.)
- Any demo 3 prose, code, or JSON. The cross-arch ratio framing is untouched here.
- The cross-machine absolute-ns/op prohibition — stays banned (plan §18, §52).
- The autovec/`logf`-barrier finding — confirmed correct, do not edit.
- Re-deriving the polynomial or the NEON kernel — numbers are trustworthy; only framing moves.

## Open items for CC to flag

- **I drafted this without `09-arm-neon-brief.md` in front of me** — only the two verbatim
  fragments CC quoted (`"within 0.05%"`, `"does not change the ratio"`). For Tasks 1–4, match
  the surrounding sentence by grep and preserve the rest of the paragraph. If a claim isn't
  present as quoted, or §3 already reads differently, **stop and report** rather than inventing
  text to replace.
- **Do not put CC's "~14µs per call" overhead figure in prose.** It is wrong by ~1000× —
  actual per-call wall time at 1M is ~14.6 ms (neon) / ~69 ms (poly). If the pilot-vs-formal
  16k divergence (13.40 → 14.04 ns) needs explaining at all, the correct statement is that
  neon's small-N points carry proportionally more fixed per-iteration harness overhead because
  neon's per-call compute is ~4–5× smaller than scalar's — and that belongs in notes, not a
  headline claim, unless a diagnostic pass confirms it.
- **Whether to surface the algorithm-win decomposition in the post body** (the 6–7% poly-vs-libm
  line) or keep it brief-only is editorial — Gareth's call. The plan (§66) left the
  algorithm-win line as editorial, defaulting to a pure width story. If the body stays
  pure-width, the decomposition still has to live in the brief so §3 isn't internally
  contradictory.
