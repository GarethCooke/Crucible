# Brief — demo 9 §9 hostile cross-read cleanup

**Source findings:** `demo-09-hostile-cross-read-findings.md` (plan §9). Addresses M-1, M-2, M-3, L-1, L-2, L-3, L-4.

## Context

Verbatim quote-and-replace edits to two shipped/feature-branch MDX files. No code, no JSON, no chart components.

The substantive item is **M-1**: the demo 9 "pure width win" framing claims `scalar_poly` is "the exact kernel NEON runs, minus the vectorisation." It isn't — `scalar_poly` keeps libm `log` and scalar `sqrt`, while the NEON kernel uses a polynomial `log` (`vec_logf_neon`, no PLT) and a vector `fsqrt`. Confirmed against source: `scalar_poly.cpp` header (`// libm log + libm sqrt + inline poly exp/N(x)`), `poly.h:134` ("scalar_poly.cpp uses std::log directly"), `poly.h` flop-count comment (scalar_poly 98 flops/option, SIMD variants 125 — the +27 is the poly `log`), and `neon_intrinsics.cpp:30,34`. The decision (Gareth, 2026-06-02) is **reword, not rebuild** — name the `log`/`sqrt` substitution, use the 98-vs-125 flop gap as a strengthening point, and reconcile the measured 4.3–4.8× against the nominal ~4× lane ceiling. Demo 3 carries the identical defect and gets the matching wording fix in the same pass.

All replacement prose below is final — apply verbatim, no paraphrase.

---

## Tasks

### M-1 — demo 9 (`site/src/posts/09-arm-neon.mdx`)

**Task 1 — scalar (poly) variant description (~line 30).** Replace:

> **scalar (poly)** — replaces the libm transcendentals with inlined polynomial approximations (a polynomial `exp` and normal CDF), still one option at a time. This isolates the _algorithm_ win — avoiding the libm call overhead — from the _width_ win that comes later, and runs ~6% faster than scalar (libm). It is also the width-ratio denominator: the exact kernel NEON runs, minus the vectorisation, so NEON-over-poly is a clean 4-wide comparison. Using `scalar_libm` as the denominator would give a larger number that folds the algorithm win into "width"; the honest width measurement uses the equal-math baseline.

with:

> **scalar (poly)** — replaces libm's `exp` and normal CDF with inlined polynomial approximations, still one option at a time. This isolates the _algorithm_ win — avoiding the libm `exp`/`erfc` dispatch — from the _width_ win that comes later, and runs ~6% faster than scalar (libm). It is the width-ratio denominator: it shares the dominant polynomial math (`exp`, `N(x)`) with the NEON kernel. Using `scalar_libm` as the denominator instead would fold the `exp`/`erfc` algorithm win into "width" and overstate what lane count buys; scalar_poly is the closer baseline. (One residual difference — the `log` and `sqrt` paths — is accounted for under _Decomposing the speedup_.)

**Task 2 — width-win paragraph (~line 83).** Replace:

> **Width win: ~4.3–4.8× (scalar poly → NEON).** The hand-written `float32x4_t` kernel processes four options per loop iteration using the same polynomial math as `scalar_poly`, widened to four lanes. This is the pure width win.

with:

> **Width win: ~4.3–4.8× (scalar poly → NEON).** The hand-written `float32x4_t` kernel prices four options per loop iteration. It shares scalar_poly's polynomial `exp` and `N(x)`, but does two things scalar_poly doesn't: it replaces libm `log` with a polynomial `log` (`vec_logf_neon`, no PLT call) and scalar `sqrt` with a vector `fsqrt`. So the ratio is not lane width alone, and the two differences pull in opposite directions. First, the polynomial `log` _adds_ arithmetic: NEON evaluates ~125 flops per option against scalar_poly's ~98 — about 28% more work — and still finishes 4.3× ahead, which is the clearest evidence the lanes are doing real parallel work. Second, the libm `log` in the scalar baseline is slower than the polynomial `log` NEON uses, so the denominator is inflated and the measured ratio sits _above_ the nominal 4-wide ceiling. The pure-lane component is ~4×; the remainder is the `log` substitution plus the per-call overhead the wide loop amortises. The architectural ceiling the headline names is that ~4× lane factor — there is no wider unit to reach for — and the measured 4.3–4.8× is that factor plus these two effects, not a wider unit at work.

**Task 3 — headline-denominator paragraph (~line 85).** Replace:

> The headline denominator is `scalar_poly` because the NEON kernel _is_ the four-lane poly kernel — measuring against `scalar_libm` would give 65.4/14.1 = **4.6×** at 16k and 70.2/13.7 = **5.1×** at 1M, but those figures fold the algorithm win into "width" and overstate what lane count buys you.

with:

> The headline denominator is `scalar_poly` because it shares the dominant poly math with the NEON kernel — measuring against `scalar_libm` would give 65.4/14.1 = **4.6×** at 16k and 70.2/13.7 = **5.1×** at 1M, but those figures fold the `exp`/`erfc` algorithm win into "width" and overstate what lane count buys you.

(Leave the rest of the paragraph — the "5.1× number is not wrong…" sentences — unchanged.)

**Task 4 — code-walkthrough paragraph + link verb (~line 121, also closes L-3).** Replace:

> The polynomial helpers (`vec_logf_neon`, `vec_expf_neon`, `vec_ncdf_neon`) in [`poly_neon.h`](https://github.com/GarethCooke/Crucible/tree/master/bench/demos/09-arm-neon/poly_neon.h) are the same Horner evaluations as the scalar equivalents, widened to `float32x4_t`. No PLT calls appear in the main vector loop; `vsqrtq_f32` emits a single hardware `fsqrt` instruction.

with:

> The `exp` and normal-CDF helpers (`vec_expf_neon`, `vec_ncdf_neon`) in [`poly_neon.h`](https://github.com/GarethCooke/Crucible/blob/master/bench/demos/09-arm-neon/poly_neon.h) are width-ports of the same Horner evaluations scalar_poly uses (`fast_expf`, `ncdf_poly`). `vec_logf_neon` has no scalar counterpart in scalar_poly — which calls libm `log` — so it is the one piece of math the NEON kernel adds rather than widens. No PLT calls appear in the main vector loop; `vsqrtq_f32` emits a single hardware `fsqrt` instruction.

(The leading "The scalar variant is one call per option…" sentence is unchanged.)

### M-1 — demo 3 (`site/src/posts/03-simd-blackscholes.mdx`)

**Task 5 — variant 3 description (~lines 40–41).** Replace:

> 3. **`sse2_intrinsics`** — 4-wide `__m128`, manual intrinsics. Same polynomial math as variant 2, widened to four lanes.

with:

> 3. **`sse2_intrinsics`** — 4-wide `__m128`, manual intrinsics. Shares variant 2's polynomial `exp` and `N(x)`, widened to four lanes, and additionally vectorises `log` (which variant 2 leaves to libm, since a libm `log` can't be issued into a SIMD register).

**Task 6 — CodeCompare caption (~line 88).** Replace `same algorithm, different width` with `same polynomial core, different width`. Full sentence becomes:

> The `CodeCompare` shows the most informative diff — same polynomial core, different width.

**Task 7 — Step 2→3 reconciliation (~lines 151–153).** Replace:

> slightly above clean 4× width because the scalar variant carries some loop-overhead and pipeline-fill cost the SIMD variant amortises.

with:

> slightly above clean 4× width because the scalar variant keeps a libm `log` the SSE variant replaces with a vectorised polynomial, and carries loop-overhead and pipeline-fill cost the SIMD variant amortises.

### M-2 — demo 9, "flat at ~14 ns" vs the small-N number (~line 46)

**Task 8.** Replace:

> Three scalar lines cluster between 61–73 ns/option across the sweep. NEON sits flat at ~14 ns.

with:

> Three scalar lines cluster between 61–73 ns/option across the sweep. NEON drops from ~22 ns at the smallest N to ~14 ns once per-call overhead amortises (see _The small-N caveat_) and holds flat there.

(The rest of the line — "The autovec line coincides with `scalar_libm`…" onward — is unchanged.)

### M-3 — demo 9, "Debian 14's libm" misattribution (~line 81)

**Task 9.** Replace:

> because Debian 14's libm AArch64 implementation carries less dispatch overhead than the x86 one

with:

> because the AArch64 glibc `libm` carries less `exp`/`erfc` dispatch overhead than the x86 one

### L-4 (optional) — demo 9, autovec≡libm tolerance (~lines 28, 125)

**Task 10.** In both locations replace `within 0.1%` with `within 0.01%`:

- line 28: "the timing tracks it within 0.1%" → "the timing tracks it within 0.01%"
- line 125: "within 0.1% across the full sweep" → "within 0.01% across the full sweep"

Apply only if the §5 / open-item A3 record of "0.01% (byte-identical asm)" is the authoritative figure. If A3 is unavailable or says otherwise, skip and flag.

### L-1, L-2 — JSON spot-checks (verify only, no edit unless mismatch)

**Task 11 (L-1).** Confirm the cross-arch table (`09-arm-neon.mdx` ~lines 141–142) against the JSON, one sig fig:

- `scalarpoly / sse2` from `site/src/data/perf/03-simd-blackscholes.json`: 3.8× @ N=16384, 4.1× @ N=1048576.
- `scalarpoly / avx2fma` from the same file: 7.5× @ 16k, 9.3× @ 1M.
- `scalarpoly / neon` from `site/src/data/perf/09-arm-neon.json`: 4.3× @ 16k, 4.8× @ 1M.

If any cell is off by more than one sig fig, **stop and flag** — do not silently edit the table; the discrepancy routes back to Opus.

**Task 12 (L-2).** Confirm the scalar-band upper bound "73" in the line-46 sentence against `09-arm-neon.json`: take the max median `ns_per_op` across all three scalar variants over the full N-sweep. If it does not round to 73, replace `73` in that sentence with the actual rounded max.

---

## Acceptance

**Demo 9 (`09-arm-neon.mdx`):**

- `grep -c "exact kernel NEON runs"` → 0; `grep -c "This is the pure width win"` → 0; `grep -c "the NEON kernel \*is\* the four-lane poly kernel"` → 0.
- `grep -c "same Horner evaluations as the scalar equivalents"` → 0; `grep -c "tree/master/bench/demos/09-arm-neon/poly_neon.h"` → 0 (link now `/blob/`).
- `grep -c "NEON sits flat at ~14 ns"` → 0; the line-46 sentence now mentions "~22 ns at the smallest N".
- `grep -c "Debian 14"` → 0; `grep -c "AArch64 glibc"` → 1.
- New flop figures present: `grep -c "125 flops"` → 1 and `grep -c "98"` finds the per-option count in the width-win paragraph.
- If Task 10 applied: `grep -c "within 0.1%"` → 0.

**Demo 3 (`03-simd-blackscholes.mdx`):**

- `grep -c "Same polynomial\s*math as variant 2, widened to four lanes"` → 0; new variant-3 text mentions "additionally vectorises `log`".
- `grep -c "same algorithm, different width"` → 0; `grep -c "same polynomial core, different width"` → 1.
- Step 2→3 paragraph now contains "keeps a libm `log` the SSE variant replaces".

**Cross-cutting:**

- The branch deploy renders both posts cleanly (no MDX parse error from the edited blocks).
- L-1 spot-check passed (or flagged); L-2 confirmed (or "73" corrected).
- The M-1, M-2, M-3 findings in `demo-09-hostile-cross-read-findings.md` are now satisfied.

## Out of scope

- The benchmark code, `poly.h`, `poly_neon.h`, `scalar_poly.cpp`, any CMake or build flags — this is the **reword** path; do **not** change `bs_call_poly` to call `fast_logf`, and do not re-capture.
- Any committed JSON values (Tasks 11–12 are read-only checks).
- Demo 9's intro (lines 7–9) and summary frontmatter — the "tops out at ~4.3× … and stops" framing is about the absence of a wider unit and remains correct after these edits; leave it.
- The 6% algorithm-win number — unchanged (the reword does not move scalar_poly's math, so the 6% libm→poly figure stands).
- Demo 7's `/tree/`-verb `benchmark.cpp` link — same class as L-3 but a different post; see Open items.
- The methodology page — its §8 second-machine update and demo-total bump are checked in §10, not here.

## Open items for CC to flag

- If the line numbers have drifted (the files are edited iteratively), match on the quoted text, not the line number; if a quoted OLD block is **not found verbatim**, stop and report rather than fuzzy-matching — the post may have changed since the read.
- If Task 11's JSON ratios disagree with the table by more than one sig fig, stop and flag; this would reopen M-1's numbers, not just the wording.
- Demo 7 (`07-flatmap-vs-hashmap.mdx`) has the same `/tree/`-instead-of-`/blob/` file link for `benchmark.cpp` (L-3 noted it as pre-existing). Not fixed here per scope; flag for a future minor-cleanup pass if you want series-wide link hygiene.
