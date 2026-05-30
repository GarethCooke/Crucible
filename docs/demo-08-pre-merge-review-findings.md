# Crucible — Demo 08 pre-merge review (plan §9)

**Review date:** 2026-05-30 (updated with JSON in hand)
**Method:** Final check of `08-sorting-shootout.mdx` against three sources — (1) the captured data `08-sorting-shootout.json`, (2) the methodology page `app/methodology/page.tsx`, and (3) the conventions established by the seven shipped posts `0[1-7]-*.mdx`. **Every numerical claim in the prose was re-derived from the JSON medians programmatically.** Footers, statistical-convention statements, machine spec, chart props, and cross-links were diffed against demos 1–7.
**Scope:** Prose, numbers, footer, link/slug integrity, methodology alignment, chart-prop conventions, cross-demo consistency. Not C++ source, not chart-component source (but see C-2 — new props the components must support), not the bench README, not the index page (file not in this review set — see L-2).

The post is numerically clean — and unusually so. Every figure quoted in the prose matches the JSON medians to its stated precision: the 74 vs 15 ns/element headline, the 5× / 1.9× gaps at 67 M, `pdqsort`'s 0.75 ns on sorted data and its ~35× spread, radix's 1.8× span, the per-distribution values (~12/~15/~21–22), the 9× `std::sort` distribution range, and the 5.2×→1.8× key-width shift all verify. The "tidy inversion" — comparison sorts fastest on ordered input, radix fastest on random — is exactly what the data shows. Slug identity is clean, the headline retires "crossover" per §8, and the demo-1 pairing is accurate and reciprocated. The findings below are one merge-blocker the prose review can't close (chart-component support), a handful of consistency/methodology items, and editorial residue.

---

## Summary

| #   | Severity              | Class       | One-line                                                                                                                                                                                                                                                                                                   |
| --- | --------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C-1 | ~~Critical~~ Resolved | Verify      | JSON now in hand. **All prose numbers re-derived from medians — every one correct.** See "Verified clean."                                                                                                                                                                                                 |
| C-2 | Critical              | Verify      | Four charts use new props (`distributionFilter`, `keyTypeFilter`, `distGrouped`, `stat`) absent from demos 1–7. The JSON carries the matching fields, but confirm `TimeVsN`/`ThroughputBars` actually read them or the charts render empty/wrong.                                                          |
| M-1 | Material              | Consistency | Methodology page lists the working-set-sweep convention as "(demos 6, 7)"; demo 8's footer claims it. Add demo 8.                                                                                                                                                                                          |
| M-2 | Material              | Consistency | Radix L3-knee at ~4 M is _correct_ in the data (16 MB single-array = L3), but the explanation contradicts the ping-pong doubling the same paragraph applies to the L1 bump (which would put the L3 spill at 2 M). Add a reconciling clause.                                                                |
| M-3 | Material              | Attribution | `pdqsort` is vendored (orlp, zlib) — stated in the JSON `notes`, required by the plan "in the post and README," but never disclosed in the post.                                                                                                                                                           |
| M-4 | Material              | Cross-demo  | Demo 1's `std::sort` ≈ 31 ns/elem (1.0 s / 32 M) vs demo 8's ~72 ns/elem at the adjacent ~33 M point — but only on **random** keys. Demo 8's `std::sort` on few-unique data is ~29 ns/elem, matching demo 1. Confound confirmed; add a one-line note so the cross-link doesn't read as a 2× contradiction. |
| M-5 | Material              | Verify      | Footer says "single thread pinned to **core 4** (CCX1)"; JSON `cpu_affinity` is **"4-7"** (the whole shield set). Demo-7 M-1 redux. Confirm the capture taskset-pinned to one core vs floated across the CCX.                                                                                              |
| L-1 | Low                   | Consistency | Footer `*Source:` line (bench dir · JSON) present in demos 6 & 7, absent in demo 8 — which adapts demo 7's structure. Add it.                                                                                                                                                                              |
| L-2 | Low                   | Verify      | Index card not in review set — confirm at merge: links `/posts/08-sorting-shootout`, final title, no in-progress pill. (Also confirm the README half of M-3.)                                                                                                                                              |
| L-3 | Low                   | Quality     | Charts pass no `variantLabels` / `title` / `yAxisLabel`; demos 6 & 7 pass all three. The legend will render raw JSON keys `std_sort`, `pdqsort`, `radix_lsd`.                                                                                                                                              |
| L-4 | Low                   | Editorial   | Body reintroduces "crossover" at L89 ("The crossover lives in the key width") — the word the headline and §8 were careful to retire.                                                                                                                                                                       |
| L-5 | Low                   | Quality     | "Radix essentially flat at ~11 ns/element until ~4 M" (L58) smooths a real dip: radix is ~6–8 from N=1 K to 32 K, reaching ~11 only at 131 K. And "bends upward to ~15" is the 67 M endpoint, not the 4 M value (~12) — clarify.                                                                           |
| L-6 | Low                   | Quality     | "A 64-bit key is eight byte-passes instead of four, so the linear cost doubles" (L89) — the _pass count_ doubles, but measured radix cost rises 2.9× (12.2 → 35.1); the extra is the wider keys' bandwidth/footprint.                                                                                      |
| L-7 | Low                   | Consistency | JSON `compile_flags` is `-O3 -march=native -std=c++20` — no `-DNDEBUG`, where demo 7 recorded it and the methodology Release recipe implies it. Practical risk here is low (std::sort/pdqsort asserts aren't NDEBUG-gated), but confirm. Plus a footer punctuation nit.                                    |

1 critical-to-verify (C-1 resolved), 5 material, 7 low. **No numerical errors — every quoted figure matches the data.**

---

## Critical

### C-1 — Resolved: all prose numbers verified against the medians

With `08-sorting-shootout.json` in hand, every figure was re-derived. They all hold — see "Verified clean" for the cell-by-cell record. No action.

### C-2 — Charts use four props with no precedent in demos 1–7

**Location:** `08-sorting-shootout.mdx:42-52` (`<TimeVsN>`) and `:66-73` (`<ThroughputBars>`).

**Problem:** Demo 8 introduces `distributionFilter`, `keyTypeFilter`, `distGrouped`, and `stat` — none of which appear in demos 1–7, which drive these components with `workloadFilter`, `kFilter`, `nFilter`, `xAxis`, `targetN`, `thresholdMarkers`. The JSON _does_ carry the matching axes — every run has `distribution` (`random`/`sorted`/`reverse`/`few_unique`/`sawtooth`), `key_type` (`u32`/`u64`), and `ns_per_op.median` — so the props are semantically grounded. The `distGrouped={true}` grouped-bar view is the §5 "extend, don't fork" decision. But whether the components _read_ these props is unverified (component source out of scope). If any is silently ignored, the chart renders empty or wrong — the demo-8 analogue of demo 7's C-1.

**Action before merge:** Render the page; confirm all four charts populate. Confirm in source that `distributionFilter`, `keyTypeFilter`, `distGrouped`, and `stat` are wired (§5 was to land the grouped-view extension and the filter props). With u64 present in the JSON for only 3 cells (4 M random, all three variants), confirm `keyTypeFilter="u32"` actually excludes those u64 cells from chart 1 and chart 2 rather than mixing them in.

---

## Material

### M-1 — Methodology page omits demo 8 from the working-set-sweep convention

**Location:** `app/methodology/page.tsx` — Commitment 4, working-set-sweep `<li>`: "(demos 6, 7)" vs `08-sorting-shootout.mdx:108` footer: "(working-set-sweep convention)".

**Problem:** Demo 8 claims the working-set-sweep convention in its footer, but the methodology page's enumeration still reads "(demos 6, 7)." A reader following the footer pointer finds demo 8 unlisted. Plan §7 anticipated this ("demo total bumped to 8 if it references one"), but the page carries per-convention demo lists, not a single total — so the fix is this specific list.

**Action:** Change the working-set-sweep bullet to "(demos 6, 7, 8)". The other two lists (throughput "1, 2, 3"; tail-latency "4, 5") are correct as-is.

### M-2 — Radix L3-knee explanation contradicts the post's own doubling caveat

**Location:** `08-sorting-shootout.mdx:58`.

**Problem:** The paragraph applies the ping-pong factor correctly at L1: radix's working set is 2× the input, so at ~4 K keys the doubled footprint is 32 KB = L1, and the data confirms a real bump there (radix random jumps to 23.1 ns @4 K, 19.4 @8 K, against a ~7.6 floor at 32 K). But at L3 it drops the factor: "Four million 32-bit keys is 16 MB — the size of this machine's L3 slice." The _data agrees the knee is there_ — radix random is 12.2 @4 M, bending to 14.1 @8 M — so the number is right. The inconsistency is in the reasoning: by the same doubling the post applies at L1, radix's 32 MB working set at 4 M should already have spilled L3 at ~2 M (2 M × 4 B × 2 = 16 MB). It hadn't (radix is 11.4 @2 M, still on the plateau). So the doubling model that governs the L1 bump does _not_ govern the L3 knee, and the post doesn't say why.

**Action:** Keep ~4 M (the data backs it) and add a clause: at the L3/DRAM boundary the two arrays are _streamed_ sequentially, not held co-resident the way the small-N L1 working set is, so the single-array footprint is the right yardstick there — which is why the knee sits at the single-array 16 MB point, not the doubled one. Without that, a reader who accepts the L1-bump reasoning computes the L3 knee at 2 M and finds prose and chart disagreeing.

### M-3 — Vendored `pdqsort` is never disclosed in the post

**Location:** `08-sorting-shootout.mdx` — `pdqsort` introduced L75; "Reproducing this" L102-104. JSON `notes`: "pdqsort vendored from github.com/orlp/pdqsort (zlib licence)."

**Problem:** The capture metadata records the vendored dependency and licence; the post treats `pdqsort` as if it were standard-library furniture. The plan required the call-out "in the post and README," and demo 7 handled its exact analogue (substituting `boost::flat_map` for an unavailable `std::flat_map`) with a dedicated section. Demo 8 has no equivalent — a plan-compliance gap and an attribution obligation for third-party code.

**Action:** Add a one-line disclosure where `pdqsort` is first named or in "Reproducing this": Orson Peters' implementation, vendored as a header under the zlib licence. README half is L-2 territory — confirm separately.

### M-4 — `std::sort`-on-32M figure conflicts with demo 1 by ~2× (confound confirmed)

**Location:** `01-branch-prediction.mdx:243` ("`std::sort` on 32 M integers takes ~1.0 s … measured, not estimated") vs the demo 8 `std::sort` curve.

**Problem:** 1.0 s / 32 M ≈ **31 ns/element**. Demo 8's `std::sort` on **random** u32 is 72.3 ns/elem at the adjacent ~33 M sweep point (74.0 @67 M) — a ~2.3× gap between two posts that now link each other directly (demo 1 → 8 at `01:249`, demo 8 → 1 at `08:100`). The JSON resolves it: demo 8's `std::sort` on **few-unique** u32 is **28.8 ns/elem @4 M**, right on top of demo 1's 31. The branch-prediction workload uses small-range keys (it branches on `x < 128`), i.e. effectively few-unique — exactly the distribution where `std::sort` is cheap, and which demo 8 itself shows is ~9× faster than random for `std::sort`. So the figures aren't contradictory; demo 1's number lines up with demo 8's _structured_ data, not its random headline. But the cross-link invites the apples-to-oranges comparison and neither post flags it.

**Action:** Add a half-sentence near the demo-1 pairing (L100) noting demo 1's figure is on its narrow-range keys (`std::sort`'s easy case), not the random headline. (Full confirmation of demo 1's exact distribution wants demo 1's JSON, which wasn't in this set — but the alignment with demo 8's few-unique cell is strong.)

### M-5 — Footer claims single-core pin; JSON records the 4-core shield set

**Location:** `08-sorting-shootout.mdx:108` ("single thread pinned to **core 4** (CCX1)") vs JSON `machine.cpu_affinity` = **"4-7"** (`isolated_cpus_effective` = "1-7").

**Problem:** This is demo 7's M-1 in a new guise. Demo 8 took demo 6's single-core _wording_ ("core 4"), but the JSON records `cpu_affinity: "4-7"` — the whole CCX1 shield set, the same value demo 7 recorded and described as "CCX1 (cores 4–7)." If the capture only set the `cset` shield to 4-7 and didn't additionally `taskset` the single-threaded process to core 4, the thread could migrate across the four cores during a run — which for a working-set sweep adds cross-core L1/L2 eviction variance the sweep is trying to suppress, and would make the footer's "core 4" an overclaim.

**Action:** Determine which is true (user/capture question, not a CC edit). If the process was pinned to core 4 (`taskset -c 4`) inside the shield, the footer is right and `cpu_affinity` just records the shield — note it and move on. If it floated across 4-7, either correct the footer to "CCX1 (cores 4–7)" like demo 7, or recapture single-pinned to match demo 6's convention for the sweep family. The 5-rep IQRs in the JSON are tight (e.g. 0.0015 on the sample cell), which is mild evidence against heavy migration — but confirm.

---

## Low

### L-1 — Footer `*Source:` line missing

**Location:** `08-sorting-shootout.mdx:106-110` vs `06-aos-vs-soa.mdx:216`, `07-flatmap-vs-hashmap.mdx:319`.

Demos 6 and 7 — the template §7 told demo 8 to follow — close with `*Source: [bench dir] · [JSON].*` before the methodology link. Demo 8 omits it. (Demos 1–5 also lack it, so it's a recent convention, not universal — but demo 8 sits next to 6 and 7 and adopts their shape, and the JSON link is what makes numbers checkable.)

**Fix:** Add `*Source: [bench/demos/08-sorting-shootout/](…/tree/master/bench/demos/08-sorting-shootout) · [JSON](…/blob/master/site/src/data/perf/08-sorting-shootout.json).*`

### L-2 — Index card not verified

Not in this review set. Plan §10/§11 require the card to link `/posts/08-sorting-shootout`, show the final title, and carry no in-progress pill once the stub is overwritten. Confirm at merge — along with the README `pdqsort` disclosure (M-3).

### L-3 — Charts pass no display labels, titles, or axis labels

**Location:** `08-sorting-shootout.mdx:42-52`, `:66-73`.

Every chart in demos 6/7 carries `variantLabels`, `title`, `yAxisLabel` (demo 7 hoists them into `export const` blocks). Demo 8 passes none — so the legend renders the raw JSON keys `std_sort`/`pdqsort`/`radix_lsd`, and the charts have no caption or Y-axis label. Functional, but below the 6/7 bar.

**Fix:** Add a label map (`std::sort` / `pdqsort` / `LSD radix`), a `title` per chart, and `yAxisLabel="ns per element"`.

### L-4 — Body reintroduces the "crossover" motif

**Location:** `08-sorting-shootout.mdx:89` — "The crossover lives in the key width…"

The headline scrupulously avoids "crossover" (the §8 carry-forward, after demos 6 "…not a crossover" and 7 "No crossover"). The body uses it once, in a literal sense (where comparison sorts overtake radix). Defensible, but a reader who clocked the 6/7 repetition will clock its return. Editorial: "the trade-off lives in the key width" retires it fully.

### L-5 — Radix-floor smoothing and an ambiguous endpoint readout

**Location:** `08-sorting-shootout.mdx:58`.

Two clarity issues, both confirmed against the data:

1. "Radix is essentially flat at ~11 ns/element until about 4 million keys" smooths a real dip. Radix random is 6.1 @1 K, ~7.3 @2 K, then the 4 K–8 K bump, then **~7.6–8.1 at 16 K–32 K**, only reaching ~11 at 131 K and ~12 at 4 M. The chart shows a curve that dips well below 11 and rises into it, not a flat 11. (Demo 7's L-4 in reverse — there a bump was smoothed; here a dip is.) "Climbs from ~7 to ~12 across the L1-to-L3 region" would match the chart.
2. "Then it bends upward to ~15" — ~15 is the 33 M–67 M endpoint (15.1 / 14.8), not the 4 M value (12.2). As written it can be read as radix @4 M = 15, contradicting L77's ~12 for the same cell. Clarify: "…then climbs to ~15 by the end of the sweep."

### L-6 — "The linear cost doubles" understates the measured 64-bit jump

**Location:** `08-sorting-shootout.mdx:89`.

"A 64-bit key is eight byte-passes instead of four, so the linear cost doubles." The _pass count_ (the w/r term) doubles, but measured radix cost rises **2.9×** (12.2 → 35.1 ns/elem @4 M random) — the extra is the wider keys doubling the bytes moved per pass and the array footprint, pushing deeper into DRAM. A reader checking 35/12 ≈ 2.9 against "doubles" sees the gap. Either say "the pass count doubles" (precise about the asymptotic term) or note the measured cost nearly triples once memory traffic is counted.

### L-7 — Build-flag provenance and a footer nit

**Location:** JSON `compile_flags` = `-O3 -march=native -std=c++20`; `08-sorting-shootout.mdx:108`.

The footer accurately reflects the recorded flags — but those flags carry no `-DNDEBUG`, where demo 7 recorded `-DNDEBUG` and the methodology "Building and reproducing" block uses `-DCMAKE_BUILD_TYPE=Release` (which defines it). Practical impact is likely nil for this code — libstdc++'s `std::sort` asserts are gated on `_GLIBCXX_ASSERTIONS`, not plain `NDEBUG`, and orlp's `pdqsort` has no hot-path asserts — and the numbers cohere with theory, which is mild reassurance nothing is being inflated. Still, confirm the capture intended asserts-on, since it diverges from the Release recipe and from demo 7.
Trailing nit: footer reads "…(CCX1). Headless Ubuntu 24.04" (sentence break) where demos 6/7 use a comma ("…(CCX1), headless"). Cosmetic.

---

## Verified clean (for the record)

All re-derived from the JSON medians (`ns_per_op.median`, ns per element). Listed so the next pass doesn't re-litigate.

**Headline (L7, L13, L54):** `std::sort` random u32 = 9.03 @1 K and 74.02 @67 M ✓ ("~9 … ~74"). Radix = 14.82 @67 M ✓ ("~15"). `std::sort`/radix @67 M = 4.99× ✓ ("5×"); `pdqsort`/radix @67 M = 1.94× ✓ ("1.9×"). ✓

**Distribution @4 M, u32 (the `<ThroughputBars distGrouped>` cell):** `pdqsort` sorted = 0.754 ✓ ("0.75"); `pdqsort` random = 25.71 ✓ ("~26"); random/sorted spread = 34.1× (post: "35×" — rounds up from 34.1; full max/min, with sawtooth as the true worst, is 36.5×). `std::sort` spread = 63.91 (random) / 7.08 (reverse) = 9.02× ✓ ("roughly 9×"). Radix spread = 21.76 (sorted) / 12.20 (random) = 1.78× ✓ ("1.8×"). ✓

**Radix per-distribution @4 M (L77, L85):** sorted 21.76, reverse 21.04 ✓ ("~21–22, its worst"); random 12.20 ✓ ("~12, its best"); few-unique 14.75 ✓ ("~15, in between"); full range 12–22 ✓ ("12 to 22, full stop"). The inversion (comparison sorts fastest on ordered, radix fastest on random) holds in every cell. ✓

**Sawtooth (L79):** `pdqsort` sawtooth = 27.50 ✓ ("~27.5"), vs random 25.71 — "no faster than random" ✓ (marginally slower). ✓

**Radix-loses window (L60):** radix random 23.08 @4 K, 19.41 @8 K ✓ ("~20–23"); `pdqsort` 15.65 @4 K, 18.33 @8 K ✓ ("~16–18"); `pdqsort` beats radix at both 4 K and 8 K ✓ ("briefly wins"); radix back to 8.07 @16 K ✓ ("back on the floor above ~16 K"). The doubled-footprint arithmetic (4 K × 4 B × 2 = 32 KB = L1) is exact. ✓

**Key width @4 M random (L89):** `std::sort`/radix = 5.24× u32 → 1.83× u64 ✓ ("5.2× → 1.8×"); radix u64 = 35.05 ✓ ("~35"); `pdqsort` u64 = 26.33 ✓ ("~26"), overtaking radix ✓; radix (35.05) still beats `std::sort` (64.22) on u64 ✓. ✓

**Slug identity:** route `08-sorting-shootout` (filename), both charts' `slug`, JSON `demo` field, and §6 path all agree. No split identity. ✓

**Machine block vs footer:** CPU Ryzen 7 3800X, SMT off (`smt_enabled: false`), turbo off (`turbo: false`), governor performance, GCC 13.3.0, isolated 1-7 — all match the footer and the methodology reference machine. ✓ (pinning wording is M-5; flags are L-7)

**Frontmatter / dates:** `status`/`expectedAt` removed per §7; `date: "2026-05-30"` vs `captured_at: 2026-05-29T23:52Z` — that's 00:52 on the 30th in London (BST), so the post date matches local capture time. ✓

**Headline avoids "crossover"** per §8 (body usage is L-4). **Demo-1 pairing** (payoff vs price) accurate and reciprocated; demo 8's p99-on-data-independence framing matches the inbound link's description. **Cross-links** all route-correct: outbound 1/4/5/6/7 + methodology; inbound forward-links from demo 6 (`06:210`) and demo 7 (`07:308`). **Destructive-sort hazard** surfaced in "Reproducing this," matching the JSON `notes` (master-copy restore via PauseTiming/ResumeTiming) and plan §3. **CodeCompare** radix snippet is correct LSD (4 byte-passes, even swap count lands in `a`). **Statistical-convention** footer string is verbatim-consistent with demos 6/7 (the methodology _list_ is M-1). ✓
