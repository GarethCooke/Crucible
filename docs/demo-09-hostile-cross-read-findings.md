# Crucible — demo 9 hostile cross-read findings (plan §9)

**Read date:** 2026-06-02
**Method:** Single-post hostile cross-read of demo 9 (`09-arm-neon.mdx`, on the feature branch, post-§6 bar-consistency fix) read back-to-back against demos 1–8 as shipped — first in chronological order by post date (3 → 2 → 1 → 4 → 5 → 6 → 7 → 8 → 9), then in numeric order. Particular attention to the five drift classes named in `demo-09-plan.md` §9: **cross-machine honesty (no absolute ns/op comparison anywhere)**, statistical-convention drift, second-machine methodology framing consistent with the Zen 2 demos, tonal drift, repeated/contradictory caveats. Demo 9's headline ratios cross-checked against demo 3's stated ratios; demo 9's internal numbers checked for self-consistency.
**Scope:** Prose, structure, footers, cross-link integrity, numerical self-consistency, cross-machine framing. Not C++, not the JSON schema, not chart-component code. The methodology page is not in this read set (not uploaded) — its second-machine documentation is flagged as a verification item, not graded here.

Demo 9 is a careful post and the cross-machine discipline — the single biggest risk for the first second-machine demo — holds throughout. No Critical findings: no broken links, no stale tooling references, no factual error in a footer. The findings below are one load-bearing methodological overclaim (inherited from demo 3), one chart-description self-contradiction, one factual misattribution, and a short list of spot-checks.

---

## Summary

| #   | Severity | Demo  | Class       | One-line                                                                                                                                                                                                                                                                                                             |
| --- | -------- | ----- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M-1 | Material | 9 (3) | Methodology | "scalar_poly is the exact kernel NEON runs, minus the vectorisation" overclaims — code comment shows scalar_poly keeps libm `log`+`sqrt` while NEON uses poly `log` + hw `fsqrt`; the 4.3× "pure width win" folds in a `log`/`sqrt` swap. Internal tension with line 121. Inherited from demo 3. — lines 30, 90, 121 |
| M-2 | Material | 9     | Numerical   | "NEON sits flat at ~14 ns" describes a chart that the post's own small-N caveat says is 22.0 ns at N=1024 — line 46 vs 131–133                                                                                                                                                                                       |
| M-3 | Material | 9     | Factual     | "Debian 14's libm" — there is no Debian 14; the "14" is the GCC major version from the package string; libm is glibc — line 81                                                                                                                                                                                       |
| L-1 | Low      | 9     | Verify      | Cross-arch table's Zen 2 SSE 3.8×@16k and NEON 4.8×@1M aren't stated in demo 3 prose — spot-check `03-simd-blackscholes.json` (everything else round-trips) — lines 141–142                                                                                                                                          |
| L-2 | Low      | 9     | Verify      | "Three scalar lines cluster between 61–73 ns" — the 73 upper bound isn't matched by any cited number (max cited scalar is 70.2) — line 46                                                                                                                                                                            |
| L-3 | Low      | 9 (7) | Link        | GitHub file link for `poly_neon.h` uses `/tree/` rather than `/blob/` (works via redirect; pre-existing in demo 7) — line 121                                                                                                                                                                                        |
| L-4 | Low      | 9     | Numerical   | Post says autovec ≡ scalar_libm "within 0.1%"; plan §5/A3 recorded "to 0.01%" (byte-identical asm). Post is accurate but looser than the data — optional tighten — lines 28, 125                                                                                                                                     |

Three material, four low. M-2, M-3 and L-2/L-4 are verbatim text edits. M-1 needs a one-line ground-truth check before wording is settled. L-1 is a JSON spot-check.

---

### M-1 — Demo 9: the "pure width win" denominator isn't the same kernel

**Location:** `09-arm-neon.mdx:30`, with the supporting code comment at `:90` and the contradicting prose at `:121`.

**Quote (the claim):**

> It is also the width-ratio denominator: the exact kernel NEON runs, minus the vectorisation, so NEON-over-poly is a clean 4-wide comparison.

**Quote (the code comment, scalar_poly side of the CodeCompare):**

> `// bs_call_poly: libm log + libm sqrt + inline poly exp/N(x)`

**Quote (the NEON side, line 121):**

> The polynomial helpers (`vec_logf_neon`, `vec_expf_neon`, `vec_ncdf_neon`) … are the same Horner evaluations as the scalar equivalents, widened to `float32x4_t`. No PLT calls appear in the main vector loop; `vsqrtq_f32` emits a single hardware `fsqrt` instruction.

**Problem:** The post's central decomposition rests on `scalar_poly` being "the exact kernel NEON runs, minus the vectorisation," making NEON ÷ scalar_poly a "pure width win" and the 4.3×/4.8× the headline width number. But by the post's own code comment, `scalar_poly` retains **libm `log` and libm `sqrt`**, while the NEON kernel uses a **vectorised polynomial log** (`vec_logf_neon`, explicitly "no PLT calls") and a **hardware `fsqrt`** (`vsqrtq_f32`). So NEON ÷ scalar_poly does not isolate lane count alone — it also folds in a libm-`log` → poly-`log` substitution and a libm-`sqrt` → hardware-`sqrt` substitution. The denominator is not the numerator-minus-vectorisation.

There is also a straight internal contradiction: line 121 says the NEON poly helpers are "the same Horner evaluations as the scalar equivalents" — implying `scalar_poly` evaluates a scalar polynomial `log` — while line 90 says `scalar_poly` calls libm `log`. Both cannot be true.

This is exactly the seam a quant/perf reviewer pulls on: "your 'pure width' baseline uses a different transcendental path than your SIMD kernel, so your 4.3× bundles an algorithm change into 'width.'" The magnitude is probably modest — `log` and `sqrt` are a small share of the per-option work next to the matched `exp` and two `N(x)` poly evaluations — but the _cleanliness_ claim is overstated, and the headline number inherits the impurity.

**Note — inherited from demo 3.** Demo 3 has the identical variant design: its `scalar_poly` also keeps `std::log`/`std::sqrt` as libm (`03-simd-blackscholes.mdx:39`) while its SSE2/AVX2 variants compute a vectorised `log_SK` (they must — libm `log` can't be issued into a SIMD register). So demo 3's "SSE width win" carries the same `log`/`sqrt` impurity. Any wording fix here should be considered for demo 3 too, for consistency.

**Recommendation:** Ground-truth check first — confirm what `scalar_poly` actually calls for `log` and `sqrt` in the committed build. Then either (a) soften the wording: drop "the exact kernel NEON runs, minus the vectorisation" / "pure width win" and state that the width ratio also reflects a libm-`log`/`sqrt` → poly-`log`/hw-`sqrt` swap that the scalar baseline doesn't share (a few % at most, but name it); or (b) rebuild `scalar_poly` to use the scalar polynomial `log` and `sqrt` so the denominator genuinely is NEON-minus-vectorisation, and fix the line-90 comment. Either path closes the line-121 contradiction.

---

### M-2 — Demo 9: "NEON sits flat at ~14 ns" contradicts the post's own small-N number

**Location:** `09-arm-neon.mdx:46` (chart description) vs `:131–133` (small-N caveat).

**Quote:**

> Three scalar lines cluster between 61–73 ns/option across the sweep. NEON sits flat at ~14 ns.

**Problem:** This describes the `TimeVsN` chart at `:36–44`, which spans the full sweep including N=1024. The post's own small-N caveat at `:133` states NEON is **22.0 ns** at N=1024 (ratio 3.1×), only reaching ~14 ns by N=16k. So on the chart being described, the NEON line is visibly _not_ flat at the left edge — it starts at 22 and falls to 14. The asymmetry is the tell: the scalar lines get an honest band (61–73), but NEON gets a single point (~14) that the post later contradicts. This is the same class as the canonical pre-demo-5 M-1 (prose "100–130 ns floor" vs charted 132 ns p50).

**Recommendation:** Give NEON a band or a hedge consistent with the small-N section, e.g. "NEON drops from ~22 ns at the smallest N to ~14 ns once per-call overhead amortises (see the small-N caveat) and holds there." The existing trailing clause ("doesn't vary with N once the per-call overhead amortises") already gestures at this; the bald "sits flat at ~14 ns" is the part to fix.

---

### M-3 — Demo 9: "Debian 14's libm" is a misattribution

**Location:** `09-arm-neon.mdx:81`.

**Quote:**

> On Zen 2 the same step delivered 12%; on the A76 it's narrower, because Debian 14's libm AArch64 implementation carries less dispatch overhead than the x86 one.

**Problem:** Two slips a knowledgeable reader catches immediately. (1) There is no Debian 14 — the footer's compiler string is `gcc (Debian 14.2.0-19) 14.2.0`, where "14" is the **GCC major version** (Debian package revision -19), not a Debian release number; current Debian is 13 (Trixie), and Raspberry Pi OS is Trixie-based. (2) `libm` ships in **glibc**, not in GCC or the "Debian" toolchain string, so attributing the dispatch-overhead difference to "Debian 14's libm" is the wrong component. The underlying causal claim (AArch64 glibc `libm` may carry less dispatch overhead than x86 glibc `libm`) could well be true, but as worded it's checkable and wrong, which is precisely the kind of thing the hype-allergic audience uses to discount the whole post.

**Recommendation:** Reword to name the right component, e.g. "because the AArch64 glibc `libm` carries less dispatch overhead than the x86 one" — and drop the version label. Confirm the actual OS image / glibc version if you want to keep a version reference at all.

---

### L-1 — Demo 9: cross-arch table values need a JSON spot-check

**Location:** `09-arm-neon.mdx:141–142` (and the footnote at `:145`).

The cross-arch table round-trips against everything demo 3 _states in prose_: Zen 2 SSE @1M = 4.1× (demo 3 `:152`); AVX2 @1M ≈ 9.3× (demo 3 headline/takeaway "9×"); and the AVX2/SSE µop-split ratios (1.995× @16k, 2.252× @1M, demo 3 `:168–169`) reproduce the table's AVX2 column from its SSE column (3.8 × 1.995 ≈ 7.5; 4.1 × 2.252 ≈ 9.3). But the **3.8× SSE @16k** and **4.8× NEON @1M** are not stated in demo 3 prose and can't be confirmed from the read alone.

**Recommendation:** Confirm 3.8× (= scalarpoly/sse2 @16k) and the NEON 4.3×/4.8× against `03-simd-blackscholes.json` and `09-arm-neon.json` respectively. Low because everything checkable checks out; this is closing the last two cells.

---

### L-2 — Demo 9: the "73 ns" upper bound of the scalar band isn't cited anywhere

**Location:** `09-arm-neon.mdx:46`.

The scalar band is given as "61–73 ns/option." The lower bound (61) matches scalar_poly @16k (61.2). The highest scalar value cited anywhere in the post is 70.2 (scalar_libm @1M, `:85`); nothing cited reaches 73. The 73 is plausibly scalar_libm or autovec at N=1024 (≈ 67.4 × 1.06 ≈ 71.5+), but it's uncited.

**Recommendation:** Spot-check the scalar-band max against the JSON; adjust to the actual figure if 73 is a stale or rounded-up value.

---

### L-3 — Demo 9: GitHub file link uses `/tree/` instead of `/blob/`

**Location:** `09-arm-neon.mdx:121`.

`[`poly_neon.h`](https://github.com/.../tree/master/bench/demos/09-arm-neon/poly_neon.h)` points at a file with the `/tree/` verb; GitHub's convention is `/blob/` for files (`/tree/` for directories). GitHub auto-redirects, so it isn't broken. Demo 7 has the same pattern for `benchmark.cpp` (`07-flatmap-vs-hashmap.mdx:68`), so this is pre-existing and consistent, not new drift.

**Recommendation:** Optional. If touched, change `/tree/` → `/blob/` for the file link, and consider the same on demo 7 for consistency.

---

### L-4 — Demo 9: autovec≡libm tolerance is looser in the post than in the plan

**Location:** `09-arm-neon.mdx:28`, `:125`.

The post says autovec tracks scalar_libm "within 0.1%." The plan (§5 outcome, open item A3) recorded "to 0.01% (byte-identical asm)." The post is accurate and internally consistent (it also states the asm is byte-identical), just an order of magnitude looser than the data supports.

**Recommendation:** Optional. If the byte-identical-asm finding is solid, the tighter "<0.01%, byte-identical assembly" is the stronger and more honest statement. Not an error as written.

---

## What the read did _not_ surface (verified clean)

- **Cross-machine honesty holds — completely.** This was the headline risk for the first second-machine demo, and the post is disciplined about it: it states the rule up front (`:15`), restates it at the cross-arch table (`:137`, `:147`) and in "what this doesn't show" (`:153`), and the cross-arch table is ratio-only. Absolute ns/op are never set beside each other across rigs. Even the 12%-vs-6% algorithm-win comparison (`:81`) is a comparison of _within-machine ratios_, which is exactly the portable quantity the post licenses — the only issue there is the "Debian 14" wording (M-3), not the comparison itself.
- **Statistical convention is consistent and correctly chosen.** Demo 9 uses the throughput convention (20 outer reps, median ns_per_op), matching demos 1, 2, 3 — the throughput/compute-bound family — rather than the 5-rep working-set convention of demos 6/7/8. This is the right call: it's the same compute-bound kernel as demo 3, and demo 1 already establishes the precedent of a `TimeVsN` sweep under the throughput convention. No fourth convention is introduced.
- **The second-machine footer is a clean, complete adaptation.** Hardware, clock, governor, turbo state (`get_throttled=0x0`), kernel, compiler, core isolation (`isolcpus=2,3`), pinning (`taskset -c 3`), rep count, convention label, and a correctness ledger are all present. The Pi-appropriate mechanisms (pinned clock instead of `CRUCIBLE_TURBO=off`; `taskset` instead of `cset shield`) match the plan and don't contradict the Zen 2 footers — they translate them. The `isolcpus=2,3` body/footer agreement is internally consistent.
- **Bidirectional demo 3 ↔ demo 9 cross-link is present and accurate.** Demo 9 links back to demo 3 (`:7`, `:13`); demo 3 now carries the forward link (`03-simd-blackscholes.mdx:263–264`), correctly framed as the width-ceiling sibling.
- **No "crossover" reuse.** The headline is the width ceiling ("vector width is not a given"), distinct from the demos 6/7 "no crossover" framing that was flagged as overused.
- **Variant naming is consistent.** No-underscore JSON keys (`scalarlibm`/`scalarpoly`/`autovec`/`neon`) in chart props with a `variantLabels` map; underscored forms in prose (`scalar_poly`, `scalar_libm`) matching demo 3's prose convention. Charts use the direct `<TimeVsN>`/`<ThroughputBars>` components with `variantLabels`, per the plan's note to avoid `<Benchmark>`.
- **Demo 9's own numbers are self-consistent.** 61.2/14.1 = 4.34× (4.3×); 65.9/13.7 = 4.81× (4.8×); algorithm win 6.4%@16k (65.4→61.2) and ~6.2%@1M; 65.4/14.1 = 4.6× and 70.2/13.7 = 5.1× (`:85`); small-N 67.4/22.0 = 3.06× (3.1×). All round-trip.
- **Architecture facts are correct.** Cortex-A76 is NEON-only (no SVE), 128-bit/4-wide float32, 512 KB per-core L2; the SVE-sequel framing (`:149`, `:155`) is accurate.
- **No broken markdown links** (the demo-4 C-1 class) — every link carries a URL.
- **Correctness numbers** (max_abs_error 5.722e-05 for NEON and scalar_poly; autovec/scalar_libm bit-exact) sit under the established <1e-4 threshold convention.

---

## Recommendations (triage preview)

**Settle one open question, then bundle.** M-1 is the only finding that needs a decision before wording can be committed: confirm `scalar_poly`'s actual `log`/`sqrt` calls, then choose reword-vs-rebuild (and decide whether demo 3 gets the same wording fix for consistency). That's a one-line ground-truth check on the rig plus an editorial call.

**Verbatim cleanup bundle (one CC pass).** M-2, M-3, and — once decided — the M-1 wording, plus optional L-3/L-4, are quote-and-replace text edits. Bundle as `demo-09-09-hostile-cross-read-cleanup-brief.md` per the naming convention (numbered by the cross-read task that produced them).

**Two JSON spot-checks (user/CC, off-rig).** L-1 (cross-arch table cells) and L-2 (scalar-band max) — confirm against the committed JSON; fold any correction into the cleanup brief.

**One verification outside this read set.** The methodology page is not in this read (not uploaded). Before merge, confirm §8's methodology update landed: second reference machine documented, demo total bumped to 9, and the statistical-conventions list still reconciles (demo 9's throughput-convention N-sweep is consistent with demo 1, so no new convention should be needed). Not graded here — flagged for the §10 pre-merge review.

**Stop condition for §9.** Cross-read complete; demos 1–9 all read. Triage: (1) resolve M-1's ground-truth + wording call; (2) Opus writes the cleanup brief covering M-1–M-3 (+ optional L-3/L-4); (3) CC applies; (4) confirm L-1/L-2 against JSON; (5) mark §9 ☑. Then §10 (pre-merge review) and §11 (merge) remain.
