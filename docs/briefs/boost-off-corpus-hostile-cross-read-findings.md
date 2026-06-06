# Crucible — hostile cross-read findings (boost-off re-derived corpus, pre-merge gate for `feature/boost-off-recapture`)

**Read date:** 2026-06-06
**Method:** Back-to-back read of the eight patched Machine 1 post MDX files in chronological order (03 → 02 → 01 → 04/05/06/07/08, dated 2026-05-14 through 2026-06-05), then a second pass in numeric order, plus demo 09's demo-03 citations. Every absolute figure and ratio re-derived against the nine 2026-06-05 JSONs (incl. both 05 files and the 04 overload-modes file). Boost-incident checks 1–7 from the handover layered on top of the standard drift classes. Demo 01 asm quotes diffed against the regenerated `01-branch-prediction.disasm.txt`.
**Scope:** Prose, structure, footers, link integrity, numerical self-consistency, cross-demo references, and (per handover checks 4–5) the new-capture JSON metadata where it ships to the site. Not C++, not chart components, not the methodology page.

The per-demo re-derivation wave shows: five of the eight posts (01, 02, 03, 07, 08) re-derive completely — every table cell, ratio, and counter claim round-trips against the 2026-06-05 data, and the demo 01 inner-loop asm quotes are byte-identical to the regenerated disasm. The findings concentrate in demo 04 (a surviving pre-recapture framing cluster), demo 06 (a partially-patched headline table plus the stale `l1d.replacement` explanation), and a thin layer of stale-capture digits elsewhere.

---

## Summary

| #   | Severity | Demo      | Class             | One-line                                                                                                                                                                |
| --- | -------- | --------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C-1 | Critical | 04        | Numerical/framing | Sub-saturation mutex-vs-lockfree cluster contradicts JSON: "similar at the median", "a few hundred ns above", "tens of microseconds" tail gap (×3 incl. Takeaway)       |
| C-2 | Critical | 06        | Stale             | `l1d.replacement` named twice with the wrong mechanism ("doesn't subscribe on this kernel") — contradicts the remediation conclusion the correction note will publish   |
| M-1 | Material | 04        | Numerical         | "8–10 of every 10 processes are internally uniform" — boost @50 MHz is 4/10 in the overload JSON                                                                        |
| M-2 | Material | 05        | Numerical         | Paced throughput "1,000,241–1,000,243 ops/s in this capture" vs JSON 1,000,246–1,000,247 — stale-capture digits quoted to 7 sig figs                                    |
| M-3 | Material | 06        | Numerical         | Headline K=1 table: N=131 072 quoted 3.41 ns vs JSON 3.07; plateau band quoted 1.48–1.51 vs JSON 1.49–1.50 (1.48 repeated in thesis §)                                  |
| M-4 | Material | 06        | Factual           | "eight-point plateau from N=8 K to N=65 K" — four points in this sweep grid                                                                                             |
| M-5 | Material | 09        | Cross-ref         | "On Zen 2 the same step delivered 12%" — demo 03's re-derived algorithm win is 11%                                                                                      |
| M-6 | Material | 02 (JSON) | Stale data        | All 12 run `notes` in the recaptured `02-false-sharing-pnl.json` still say `l1d event: l1d.replacement (verify with perf list…)`                                        |
| M-7 | Material | 05 (JSON) | Data integrity    | `05-allocators-cross-ccx.json` `machine.cpu_affinity: "4-7"` contradicts its own config (consumer on core 1, CCX0)                                                      |
| L-1 | Low      | 04        | Factual           | Footer "Top-bucket counts and TSC drift across all 5 runs were zero" — `calibration_drift_pct` is 0.0001 in three runs                                                  |
| L-2 | Low      | 04        | Numerical         | "about 1.8 items deep on average" (×2) vs JSON `depth_mean` 1.67/1.71                                                                                                   |
| L-3 | Low      | 07        | Numerical         | "~4× higher at small N (15.9 ns vs 3.5 ns)" — ratio is 4.55×                                                                                                            |
| L-4 | Low      | 08        | Consistency       | pdqsort distribution spread "34×" in one paragraph, "35×" in the next section (25.764/0.746 = 34.5)                                                                     |
| L-5 | Low      | 09        | Numerical         | Cross-arch table AVX2 @16k "7.5×" — re-derives 7.57×, rounds 7.6×                                                                                                       |
| L-6 | Low      | 05        | Consistency       | "exactly 344 ns … the most reproducible number" vs same capture's paced run showing pool p99.9 = 328 (different mode, one bucket — hostile-reviewer bait, not an error) |
| L-7 | Low      | 01        | Unverifiable      | Blockquote: autovectorised ternary "beats the cmov version by a further ~8×" — not derivable from any shipped JSON                                                      |

---

## Findings

### C-1 — Demo 04: the sub-saturation mutex-vs-lockfree characterisation did not survive the recapture

**Locations:** frontmatter summary; intro paragraph; "What happens as offered load rises" ("the mutex a few hundred ns above"); "Headline" section and Takeaway ("the p99.9 difference between mutex and lock-free is tens of microseconds", "the tens-of-microseconds latency gap is kernel-boundary cost", "the lock-free path's tail runs tens of microseconds tighter than the mutex's, every run").

**What the JSON says** (`04-spsc-queue.json`, paced @1 MHz): lock-free p50 = 122/140 ns, p99.9 = 180 ns; mutex p50 = **1 696 ns**, p99.9 = **3 776 ns**.

- "All three look similar at the median": the mutex median is **12–14× the lock-free median** at 1 MHz. Not similar by any reading.
- "The mutex a few hundred ns above [the lock-free floor]": the gap is ~0.9–3 µs across the entire sub-saturation sweep (best mutex p50 anywhere: 1 056 ns @9.18 MHz).
- "Tens of microseconds" tail gap: the p99.9 difference at 1 MHz is **≈3.6 µs**; the worst sub-saturation mutex p99.9 in the sweep is 8 960 ns (@9.18 MHz). The gap is single-digit microseconds everywhere below saturation. Tens of microseconds only appears in the _overload deep modes_, which the post treats as a separate (bistable) phenomenon.

This is the exact half-patched-corpus failure class: the percentile digits in the Boost-comparison section were patched (122/140/164/172/180 all re-derive), but the surrounding characterisation — summary, intro, load-sweep prose, Takeaway — still describes a different capture. A hostile reviewer opens the JSON, divides two numbers, and dismisses the post. **Disposition: own-brief** (prose rewrite of the framing cluster; the honest story — mutex ~1.7 µs median / ~3.8 µs p99.9 vs lock-free ~130 ns / 180 ns, i.e. ~12× median and ~20× p99.9, plus orders of magnitude in overload — is arguably _stronger_ than the stale one).

### C-2 — Demo 06: stale `l1d.replacement` explanation, twice

**Locations:** setup section ("`perf_capture.sh` doesn't subscribe to `l1d.replacement` on this kernel") and "What this doesn't show" ("This capture's `perf_capture.sh` doesn't subscribe to `l1d.replacement`, so the L1D row in the JSON is null").

The remediation established that `l1d.replacement` is an Intel event name that was **never valid on this Zen 2 machine** — demo 02's pipeline now uses `L1-dcache-load-misses`. Demo 06 attributes the null counter to a kernel-subscription gap, which is the pre-remediation misunderstanding, names the dead event as if it were the right one, and will directly contradict the methodology correction note. The factual disclosure (the field is null in all 135 cells — confirmed) is fine; the mechanism sentence is what must change. If a demo-06 recapture with the corrected event is not planned, the honest wording is "the capture pipeline's original L1D event name (`l1d.replacement`) was never valid on this AMD part; this capture predates the corrected event, so the field is null." **Disposition: own-brief** (fold with M-3/M-4 into a single demo-06 patch brief).

### M-1 — Demo 04: process-uniformity claim overgeneralised

"At a fixed over-saturation load, 8–10 of every 10 processes are internally uniform." Overload JSON: mutex 8–10/10 at all points ✓; boost saturated 9/10, @16 10/10, @28 8/10 — but **@50 MHz boost is 4/10**. The hand-rolled exception is already handled in prose; the boost @50 point is not. Scope the claim ("at moderate over-saturation" or per the table's points) or cite the 4/10 as the deep-overload erosion it is. **Disposition: fold into the C-1 demo-04 brief.**

### M-2 — Demo 05: stale-capture throughput digits

"All three variants sustain close to 1 M/s (1,000,241–1,000,243 ops/s in this capture)." JSON paced runs: 1 000 246 / 1 000 246 / 1 000 247. Directionally meaningless, but a 7-significant-figure verbatim claim that fails round-trip is precisely what the re-derivation gate exists to catch; "in this capture" makes it worse. **Disposition: cleanup-brief** (one-line replacement: "1,000,246–1,000,247").

### M-3 / M-4 — Demo 06: headline table cells not fully re-derived; plateau miscounted

The K=1 AoS table: N=131 072 quoted **3.41** ns vs JSON **3.0653** (mid-cliff point — capture-noisy, which is exactly why it must quote this capture); plateau band quoted **1.48–1.51** vs JSON 1.494–1.500 (and "1.48" repeated twice in the thesis section's L2→L3 step arithmetic). Everything else in the post re-derives exactly (1.31, 5.36/5.32/5.37, 0.77, 6.97×, the full K sweep, both SIMD inversions, LLC 0.223/0.0022). Separately, "the eight-point plateau from N=8 K to N=65 K" describes four grid points (8 192/16 384/32 768/65 536) — likely a denser May-grid leftover. **Disposition: own-brief with C-2** (demo-06 patch brief; verbatim replacements: 3.07; band 1.49–1.50; "~14%" for the L2 step if 1.50 is used; "four-point plateau").

### M-5 — Demo 09: demo-03 citation of the algorithm win is stale

"On Zen 2 the same step delivered 12%; on the A76 it's narrower." Demo 03's re-derived figure is **11%** (47.7048 → 43.1019 at N=1M), stated three times in demo 03 including the summary. A back-to-back reader sees 11% vs 12% across adjacent posts. The directional claim ("narrower on the A76") survives either way. The other demo-09 citations re-derive: SSE2 3.8× @16k ("a touch under 4×" still true at 3.805), 4.1× @1M, AVX2 9.3× @1M, "nearly doubled again". **Disposition: cleanup-brief** (single-digit edit, 12% → 11%).

### M-6 — Demo 02 JSON: recaptured data still self-describes the dead event

All 12 run `notes` strings in `02-false-sharing-pnl.json` (captured 2026-06-05) end with `l1d event: l1d.replacement (verify with perf list | grep -i l1d on reference machine)`. The post prose is clean (no event names anywhere — confirmed by grep), but the shipped data file describes the counter it no longer uses, in the same `notes`-re-emitted-from-a-hardcoded-string bug class demo 09 already hit and fixed (`cores_physical`/notes regression). Handover check 4 says no shipped artefact may describe the old event. **Disposition: own-brief, bench-side** — fix the notes emission in the demo-02 capture path at source, correct the committed JSON strings (no number changes), same pattern as the demo-09 notes fix.

### M-7 — Demo 05 cross-CCX JSON: machine block contradicts its own configuration

`05-allocators-cross-ccx.json` has `machine.cpu_affinity: "4-7"` while its `notes` (and the post) state consumer on core 1 (CCX0). The affinity field is evidently captured from the harness default rather than the run's actual placement — a "machine state derived from intent, not measurement" residue of exactly the class the boost incident was. Demo 02's JSON gets this right (`cpu_affinity: "0-7"` for its 8t-inclusive matrix). **Disposition: bundle with M-6** in the bench-side brief (emit effective affinity per capture; correct the committed field).

### Low findings

- **L-1 (04):** footer claims TSC drift "were zero"; three runs show `calibration_drift_pct` 0.0001. Reword: "zero top-bucket counts; TSC drift ≤0.0001%".
- **L-2 (04):** mutex depth "about 1.8 items" (×2) vs `depth_mean` 1.67 (paced) / 1.71 (sweep). Use "~1.7".
- **L-3 (07):** "~4× higher" for std_unord vs absl at N=64; 15.92/3.50 = 4.55×. "~4.5×" (the quoted ns values are correct).
- **L-4 (08):** "a 34× spread" then "ranges 35× across input shapes" for the same 34.5 ratio. Pick one rounding.
- **L-5 (09):** cross-arch table AVX2 @16k "7.5×"; 44.1492/5.8287 = 7.57× → 7.6×. (All other table cells re-derive.)
- **L-6 (05):** the "exactly 344 ns … most reproducible number" emphasis sits one bucket from the same capture's paced-mode pool p99.9 of 328. Not an error (different dataset/mode, and the post discloses bucket-level resolution elsewhere) — but a one-clause acknowledgement ("the paced headline run, a different mode, sits one bucket below at 328") would close the door a hostile reviewer will otherwise try.
- **L-7 (01):** the blockquote's "beats the cmov version by a further ~8×" for the autovectorised ternary is not derivable from any shipped JSON. Pre-existing, qualitative, width-plausible. Defer; candidate for a one-word hedge ("roughly") or a future measured aside.

---

## What the read did _not_ surface

- **No surviving boosted-era absolutes in demos 01, 02, 03, 07, 08.** Every quoted figure in those five posts re-derives from the 2026-06-05 JSONs, including every table cell, every counter (IPC, miss rates, LLC), every IQR/median percentage in demo 02's table, and demo 08's full distribution matrix. Nothing reconciles with the ~10–15%-faster old corpus.
- **Ratio/framing survival is clean where the digits are clean.** Demo 07's no-crossover thesis verified mechanically: `absl_flat` is fastest in **every** cell of the new JSON (all 14 N × both workloads × all modify fractions). Demo 06's "SoA wins at K=1, converges by K=8" framing matches the new ratios exactly. Demo 03's decomposition (11% gate, 4.1× SSE, 1.991×/2.252× AVX2/SSE, ~10× spread, 27 GFLOPS ≈ 22% of peak) re-derives line by line. Demo 02's 13.6×/5×/1.21×/9.4× chain re-derives, including the perfect-scaling counterfactual.
- **Demo 01 asm quotes match the regenerated disasm byte-for-byte** — both inner loops, all addresses, operands, and the `jle`/`cmovg` instructions; the cosmetic `endbr64`/padding changes sit outside the quoted regions.
- **No stale tooling.** Zero references to `cset`, `sudo cset`, or `CRUCIBLE_TURBO` in any post.
- **Capture-condition statements are uniform and true.** All eight footers say "3.9 GHz base … turbo disabled (BIOS Core Performance Boost off)" — which is now genuinely the rig state; the JSONs all carry `turbo:false, turbo_source:"cpb", freq_max_available_mhz:3900`, captured 2026-06-05+. No post over-claims about MAXMHZ.
- **Conventions footers intact.** The three-convention structure survives the patch wave: throughput convention (01–03, 20 reps), tail-latency-distribution (04–05, 5 × 1M merged histograms), working-set-sweep (06–08, 5 reps/cell), each named verbatim in its footer.
- **Link integrity:** all internal links well-formed; 02↔04 cross-links present in both directions; 03→09 and 03→06 forward links present; demo 06's in-page anchor resolves under rehype-slug.
- **No tonal whiplash.** The two-captures honesty register introduced in 05/06/08 ("the May capture showed X; the recapture says otherwise") is consistent across the three posts that use it and reads as a deliberate series feature, not drift.

## Recommendations

**Own-brief 1 — demo 04 framing patch (C-1, M-1, L-1, L-2).** The only finding requiring real prose judgement. Rewrite the summary, intro, load-sweep floor sentence, and Takeaway around the new numbers: lock-free ~130 ns / 180 ns p99.9 vs mutex ~1.7 µs / ~3.8 µs at 1 MHz — ~12× at the median, ~20× at p99.9, kernel-boundary cost; "orders of magnitude" reserved for the overload modes where it is true. Scope the process-uniformity claim to the table's points. Footer drift wording. Opus drafts; the corrected story is stronger than the stale one.

**Own-brief 2 — demo 06 patch (C-2, M-3, M-4).** Verbatim find-and-replace: the two `l1d.replacement` mechanism sentences (corrected wording above), table cell 3.41 → 3.07, band 1.48–1.51 → 1.49–1.50 (+ thesis-section 1.48s and the ~15% step → ~14%), "eight-point" → "four-point".

**Own-brief 3 — bench-side data fixes (M-6, M-7).** Fix the demo-02 notes emission and the cross-CCX affinity capture at source (the demo-09 `notes`-regression pattern); correct the two committed JSONs. No numeric content changes, so no MDX knock-on.

**Cleanup brief (M-2, M-5, L-3, L-4, L-5, optionally L-6).** Six one-line edits across 05, 07, 08, 09; all replacements specified verbatim above.

**Defer:** L-7 (demo 01 ~8× aside).

## Go/no-go

**No-go as the corpus stands; go after a small, fully-specified patch wave.** C-1 is a load-bearing framing failure in demo 04 that a JSON-reading reviewer would use to dismiss the series — exactly what the merge gate exists to block — and C-2 would put a shipped post in direct contradiction with the methodology correction note. Neither requires recapture; both are prose/data-string patches against data already verified good. Demos 01, 02, 03, 07, 08 are merge-ready now. Once briefs 1–3 and the cleanup brief land (and the demo-04/06 edits re-verify against the same JSONs), the corpus is consistent and the correction note + merge can proceed.

**Stop condition:** next concrete step is drafting the demo-04 framing brief (own-brief 1), since it gates the longest re-review loop.
