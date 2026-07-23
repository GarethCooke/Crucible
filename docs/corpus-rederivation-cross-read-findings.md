# Crucible — full-corpus review: re-derivation + cross-read findings and applied edits

**Read date:** 2026-06-11
**Method:** Per the re-derivation playbook and hostile cross-read skill: sentinel pre-flight on all nine JSONs, then both read passes over all nine post MDX files, with every chart-feeding and prose-cited statistic re-derived from the uploaded (2026-06-05 boost-off, cpb-verified) JSONs. The conversation's tracked read-through edits were checked against the current copies and applied where still live. Edits were applied directly to the uploaded MDX (19 exact-match replacements, all asserted unique before write); the corrected files accompany this doc.
**Scope:** Prose, structure, footers, numerical self-consistency, cross-demo coupling. Not C++, not chart components, no shipped-JSON edits.

Sentinel pre-flight: all seven Machine-1 JSONs pass (`captured_at` 2026-06-05, `turbo:false`, `turbo_source:cpb`, `freq_max_available_mhz:3900`). Demo 09 is Machine 2 (Pi 5, 2026-06-02, unaffected by the boost question). The overload-modes JSON is a diagnostic side-capture with a minimal meta block — see F-1.

The corpus is in much better shape than the project copies suggested: the Demo 03 µop correction, the 11% reconciliation, Demo 02's 13.6× re-derivation, and the Demo 04 rewrite (new intro + two-equilibria section) were already in the uploaded copies and **verify against the JSONs**. The findings below are the residue.

---

## Status of the conversation's tracked items

| Item | Status |
| --- | --- |
| 01 — TAGE mechanism wording ("memorise the shuffle", "history register", "effective history depth") | Still live → **applied** (E-1…E-4) |
| 02 — `unmigrable` → `unmigratable` | Still live → **applied** (E-5) |
| 03 — drop "at all" from opening hook | Still live → **applied** (E-6; Takeaway occurrence preserved, grep count = 1) |
| 03 — delete "The audience knows Black-Scholes." | Still live → **applied** (E-7) |
| 03 — 11% vs 12% | **Already resolved upstream**; 11% confirmed correct against new JSON (47.7048/43.1019 = 1.107 → 10.7% ≈ 11%) |
| 03 — µop-split correction | **Already applied upstream**; verified — single-µop story, 0.99/1.00 ex_ret_cops, peak re-derived on native 256-bit units (125 GF, 22%), instruction-economy arithmetic closes (3.0× fewer instr × 0.75 IPC ≈ 2.25× measured) |
| 04 — "bistable" | **Adjudication reversed, kept.** The overload-modes capture (50 runs/cell, mode classification, process-uniformity) measures exactly the per-process two-equilibria latching the word claims, and the post's new section grounds it. Earlier objection (made before this data existed) withdrawn. Table values 1.3 µs / 225 µs / 0.38 µs / 42 µs / 68 µs and the ~40% / ~95% splits all match the JSON. |
| 04 — numbers-forward intro | **Already applied upstream**; verified against paced-1 MHz JSON except the ratio — see E-8 |

## Applied edits (19)

**E-1…E-4, Demo 01.** The "Random is in the eye of the predictor" section now carries the load-bearing fact that the buffer is built once and replayed for thousands of timed passes (the answer to "don't we reseed" — no, and reuse is the precondition for the finding); "memorise the entire seed-42 shuffle" → per-position history-context association; "effective history depth" → capacity framing, with the gradual 30%-at-10K transition cited as the evidence for capacity saturation over a history-window cliff; "short enough to fit in its history register" removed; the large-N "no such pattern exists in this shuffle" claim scoped to "at this scale" so it no longer contradicts the small-N finding. All table figures (1.37%/30.4%/49.8%/50.0%, 1.04×/1.91×/5.51×/7.19×) verified exact against JSON.

**E-5, Demo 02.** `unmigrable` → `unmigratable` (line ~140). All other Demo 02 numbers verified: 13.6× (13.578), 9.4× perfect-scaling bound, 2.9× thread-scaling anomaly, every IQR/median in the table, counter narrative (94%/0.20, 95%/0.11) exact. The `int64_t` counters bullet was verified correct earlier (8-byte type alignment ≠ 64-byte line alignment) — untouched by design.

**E-6, E-7, Demo 03.** Opening hook now ends "…makes the SIMD wins reachable."; "The audience knows Black-Scholes." deleted. The Takeaway's separate "reachable at all" (SoA/Demo 6 sentence) preserved — post-edit grep count is exactly 1.

**E-8…E-10, Demo 04.** `~12×` → `~13×` in summary, intro, and Takeaway. Derivation: mutex p50 1696 ns vs hand-rolled 122 / Boost 140; against the quoted "~130 ns" the ratio is 13.0× (12.1× vs Boost alone, 13.9× vs hand-rolled). The quoted latencies are right; the stated ratio wasn't self-consistent with them. **Veto point:** if the intended comparison was specifically vs Boost, revert to ~12× and change "~130 ns" to "~140 ns" instead.

**E-11, Demo 04.** Sub-saturation description corrected against the sweep: lock-free pair 120–150 ns and flat ✓, but mutex p50 runs **0.9–3.1 µs** across the sub-saturation range, *highest at the lowest offered loads* (3.1 µs at 100 kHz, 0.9 µs at 3 MHz) — the prior "around 1–1.7 µs… lines are flat" was contradicted by the capture. New text ties the shape to the existing wake-up-hump paragraph.

**E-12, Demo 04.** "(10 processes × 5 timed runs, performance governor, shielded)" → "(10 processes × 5 timed runs)". The overload-modes meta records `governor:"unknown"` and `shielded:false`; "shielded" additionally collides with the retired-cset convention. See F-1.

**E-13, Demo 04.** Boost-comparison quantisation sentence updated: buckets are 4–8 ns in the 122–180 ns range (log₂-subbucket-16), p99 gap = one bucket, p50 gap (122→140) = two to three. The previous "about one bucket each" was written for the old 132-vs-140 figures.

**E-14, E-15, Demo 05.** Cross-CCX p50s named per variant (arena 408; malloc and freelist 488) and the false "one histogram bucket apart" removed (the gap is five 16 ns subbuckets); "roughly doubles" → "more than doubles" (2.0–2.6×). Pools' cross-CCX p99.9 "within one bucket" → "within two buckets" (720 vs 784, 32 ns subbuckets), and "2.2–2.5×" → "2.2–2.4×" to match both the data (2.20/2.39) and the Takeaway's own range. Everything else in Demo 05 verified exact, including the 344→376→360 malloc pressure shape point-for-point and all six max values.

**E-16, Demo 06.** Takeaway #2 threshold corrected. Old text: "'Large enough'… is somewhere between 128 KB and 16 MB… Below 128 KB even AoS at K=1 fits in L1" — 128 KB is 4× the 32 KB L1d, and the measured cliff sits at L3 capacity (plateau at 8 MB, mid-cliff at 16 MB, DRAM by 32 MB). New text states the L3 threshold with the measured bracket and quantifies the below-cliff gap honestly (~1.5–2× cache-resident: 1.56× at L2, 1.94× on the L3 plateau). All other Demo 06 figures verified exact (1.31/1.49–1.50/3.07/5.37, 6.97×, full K-sweep ratio column, 2.53×/3.99× SIMD, 0.223/0.0022 LLC).

**E-17, Demo 07.** "climb three orders of magnitude" → "more than two orders" for the sorted-vector lines' own climb (108.7 → 17,331 ns = 159×). The genuine three-order figure — the 770×/835× gap vs the hash maps — is stated correctly elsewhere and untouched. All other figures verified exact (771.7/836.7 from JSON; no-crossover thesis confirmed at every extracted N; std::map's small-N edge real).

**E-18, E-19, Demo 09.** "within 0.01%" → "within 0.1%" in both autovec passages: the measured autovec-vs-scalar_libm deltas are 0.078% (N=1024), 0.001%, 0.004%, 0.017% — two of four Ns violate the old bound. Cross-arch table verified against the recaptured Demo 03 JSON (3.8×/4.1×/7.6×/9.3× all exact), so the playbook's 03↔09 coupling check passes; "a touch under 4×" holds (3.804).

**Demo 08: zero edits.** Every figure verified — the 5.2×→1.8× key-width collapse, 0.75 ns sorted pdqsort, ~35× spread, radix's ~2× distribution span (1.95 measured), knee placement at 16 MB. Cleanest post in the corpus.

---

## Flagged, not edited (Gareth's call or CC follow-up)

**F-1 (Material) — Demo 04 governor-flip claim.** "changing the CPU governor from performance to schedutil flips mutex from mostly-shallow to mostly-deep" has no committed capture behind it; the overload-modes JSON is single-governor and its meta doesn't even record which. Either commit the schedutil cells from the bimode_diag session or soften the sentence. Related hardening: `bimode_diag.sh` should probe and emit governor/kernel into meta (it currently writes "unknown") — candidate for the cumulative capture-hardening brief.

**F-2 (Material) — Demo 03 ex_ret_cops provenance.** The 0.99/1.00 µops-per-instruction figures are asserted in prose and in the JSON `notes`, but there are no per-variant `ex_ret_cops`/`ex_ret_instr` fields in the runs. Schema addition (fold `uop_diag.sh` output into the capture) belongs in the capture-hardening brief; until then the claim rests on the notes-level assertion.

**F-3 (Low) — Demo 09 JSON notes still say "within 0.01% … at every N".** Prose fixed (E-18/19); the shipped JSON notes field carries the same stale bound. Shipped-JSON edits are out of scope for this pass by standing convention — queue for the next Demo 09 touch.

**F-4 (Low) — convention mix, Demo 09 vs Demo 03.** Demo 09's "6.4%/6.2%" are ns-reduction figures; Demo 03's "11%" is a throughput ratio. Like-for-like the contrast is 6.4% vs 9.6% (reduction) or 6.8% vs 10.7% (ratio). The qualitative claim (narrower on A76) holds either way; harmonising would touch the 09 JSON notes too.

**F-5 (Low) — Demo 04 overload table column.** "processes deep / shallow" but the mutex "~5%" is the run fraction (2/50); at process level it's 0–1 of 10. The "~" carries it; tighten to "share of runs deep" if touched again.

**F-6 (Low) — Demo 06 thesis wording.** "Below L3, layout doesn't matter much" against a measured 1.5–2× cache-resident gap. Defensible relative to the 7× headline; a hostile reader may still poke. The corrected Takeaway #2 now quantifies it, which partially defuses this.

**F-7 (Low) — Demo 02 cpu0 sentence.** Minimal one-word fix applied; the fuller rephrase ("hosts per-CPU kernel threads — timers, RCU callbacks — the scheduler can't migrate off it") remains on offer.

**F-8 (Low) — tonal.** Demo 08's "the cleanest demonstration I know" is the corpus's only first-person singular. Demo 03's "fits comfortably in L2" at N=16k is 384 KB of 512 KB (75%) — "comfortably" is generous.

**F-9 (housekeeping) — earlier cleanup brief partially superseded.** `pre-demo-5-readthrough-prose-cleanup-brief.md`: tasks 1, 3, 5 (the MDX edits) are superseded by this pass; tasks 2 and 4 (source-brief back-fixes to `02b-false-sharing-prose-rewrite-brief.md` and `05-mdx-rewrite-brief.md`) remain valid for CC — note `05-mdx-rewrite-brief.md` also still carries the stale 12% figure in its Edit-3 block, worth fixing in the same touch.

---

## What didn't surface

No broken links found in the read (the C-1 class from the pre-demo-5 read is fixed; Demo 04's Methodology link now has its URL). Footers are consistent across all nine posts — machine line, truthful turbo wording per the recapture, correct per-post convention tags (throughput / tail-latency-distribution / working-set-sweep), Methodology link. Cache-size constants agree everywhere (32 KB L1d, 512 KB L2, 16 MB L3/CCX). Cross-demo references all check out: 02↔04 PaddedAtomic, 01→06/07/08, 06↔03/05/07/08, 09↔03 (numerically verified), 08↔01 (the one-second sort matches Demo 01's measured 1.096 s). The ratio framing checks the playbook demanded all pass: Demo 07's no-crossover thesis survives at base clock; Demo 06's "SoA wins everywhere it should" holds; Demo 03's headline didn't collapse.

**Next concrete step:** Gareth eyeballs the eight edited files (especially the two judgement-adjacent edits: 04's ~13× and 06's rewritten Takeaway #2), then CC lands them plus the F-9 source-brief back-fixes; F-1 and F-2 fold into the cumulative capture-hardening brief.
