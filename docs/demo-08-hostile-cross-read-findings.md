# Crucible — demo 8 hostile cross-read findings (plan §8)

**Read date:** 2026-05-30
**Method:** Back-to-back read of demo 8 (`08-sorting-shootout.mdx`) against demos 1–7 as shipped, watching for the drift classes named in `demo-08-plan.md` §8: statistical-convention drift, Zen 2 framing consistency, methodology consistency, tonal drift, repeated/contradictory caveats — **and specifically whether the headline avoids the over-used "crossover" framing**. Every numerical claim cross-checked against the captured `08-sorting-shootout.json` (66 cells: 63 u32 + 3 u64; variants `std_sort` / `pdqsort` / `radix_lsd`; five distributions).
**Scope:** Prose, structure, frontmatter, footers, cross-link integrity, numerical self-consistency, convention reconciliation. Not C++, not the JSON schema, not chart-component code. Per the standing instruction, the "cores 0–7 isolated" footer shorthand is treated as load-bearing only on the methodology page.
**Coverage:** All of demos 1–8 read. The `/methodology` page source and the index/loader code were **not** in the provided file set — items that depend on them are listed under Coverage boundaries, not asserted.

---

## Summary

| #   | Severity | Area          | Class       | One-line                                                                                                                                                                |
| --- | -------- | ------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M-1 | Material | demo 8 footer | Convention  | No standardised machine-spec footer and no `*[Methodology →]*` link — every one of demos 1–7 carries both                                                               |
| M-2 | Material | demo 8 links  | Structural  | Plan §7's mandated backward-links to demo 1 and demo 6/7 are absent; demos 1, 6, 7 all forward-link **to** demo 8 unreciprocated                                        |
| M-3 | Material | demo 8        | Factual     | Cache-band markers use the single-array footprint, but the small-N radix bump is explained by the doubled footprint — they disagree by exactly 2× (demo-7 M-3 analogue) |
| M-4 | Material | demo 8        | Numerical   | "few-unique keys are better" (`:85`) reads false against the JSON on the natural parse — few-unique (14.75) is slower than random (12.20)                               |
| M-5 | Material | demo 8        | Statistical | "p99" / "tail-latency" framing borrows demos 4/5's measured-percentile vocabulary; demo 8 measures cross-distribution medians, not a latency distribution               |
| L-1 | Low      | demo 8        | Convention  | Frontmatter adds `slug` / `demo` / `tags`; demos 1–7 use only `title` / `date` / `summary` — and the post's own note says "match demo 7 exactly"                        |
| L-2 | Low      | demo 8        | Cleanup     | A `{/* NOTE TO CC … */}` authoring comment (`:10-13`) ships in the production MDX; no other demo carries one                                                            |
| L-3 | Low      | demo 8        | Drift       | "The crossover lives in the key width" (`:97`) — the word the §8 mandate flags reappears in the body; headline correctly avoids it                                      |
| L-4 | Low      | demo 8        | Copy        | "on a array of plain integers" (`:15`) → "an array"                                                                                                                     |
| L-5 | Low      | demo 8        | Numerical   | "slightly slower on sorted" (`:85`) undersells a ~1.8× gap; "comparison sorts fastest on pre-sorted" is true for pdqsort but `std::sort` is fastest on _reverse_        |
| L-6 | Low      | demo 8        | Tonal       | First-person "the cleanest demonstration I know" (`:85`) — singular "I"; demo 2 has one too, so not unique but warmer than the norm                                     |

5 material + 6 low. **The §8 primary check passes: the headline avoids "crossover"** (M-1, M-2, L-1..L-6 are independent of it). M-1, M-2, L-1, L-2, L-3, L-4, L-6 are mechanical edits. M-3, M-4, M-5, L-5 are wording fixes that need a one-line judgement call first.

---

## Material findings

### M-1 — Demo 8 has no standardised footer

**Location:** end of `08-sorting-shootout.mdx` (after the "Reproducing this" section, `:112`).

**Problem:** Every shipped post closes with an italic machine-spec footer — demos 1/2/3 (`*AMD Ryzen 7 3800X, Zen 2 (SMT off), 3.9 GHz base, governor = performance, turbo disabled …, cores 0–7 isolated, pinned to 4–7. Headless Ubuntu 24.04. GCC 13.3, -O3 -march=native. 20 outer repetitions, median reported (throughput convention).*`), demos 6/7 (the same shape with `5 outer repetitions per cell … (working-set-sweep convention)`), demos 4/5 (the tail-latency variant plus a histogram-provenance line). Demos 1/3/4/5/7 then close with `*[Methodology →](/methodology)*`. Demo 8 has **neither**. Its "Reproducing this" prose routes to `/methodology` inline, but the post is the only one of eight that never states Zen 2 / SMT-off / turbo-disabled / governor / core-isolation / GCC version / `-march` / rep count / convention label in the canonical footer block. This is the single largest structural inconsistency in the post and the one a back-to-back reader notices first.

**Fix:** Append the demo-6/7-shaped footer, then the methodology link. From the JSON: `cpu_affinity` 4-7, `isolated_cpus` 1-7, `-O3 -march=native -std=c++20`, 5 reps/cell, working-set sweep:
_`AMD Ryzen 7 3800X, Zen 2 (SMT off), 3.9 GHz base, governor = performance, turbo disabled (BIOS Core Performance Boost off), cores 0–7 isolated, single isolated core (4–7). Headless Ubuntu 24.04. GCC 13.3, -O3 -march=native -std=c++20. 5 outer repetitions per cell, median ns_per_op reported (working-set-sweep convention)._`followed by`_[Methodology →](/methodology)_`. (CC: confirm the pin wording against demo 6/7 — the single-thread sweeps say "single thread pinned to core 4"; demo 8 is also single-threaded, so match that register rather than the throughput demos' "4–7".)

---

### M-2 — Demo 8's mandated backward cross-links are missing

**Locations:** body of `08-sorting-shootout.mdx`; the only internal links are demo 4 (`:93`), demo 5 (`:93`), `/methodology` (`:106`, `:112`).

**Problem:** Plan §7 specified demo 8 should **backward-link to demo 1** (demo 1 makes the _downstream_ loop branch-predictable by sorting; demo 8 measures what the sort itself costs — the clean pairing) and **to demo 6/7** (the cache staircase demo 8 reuses). Neither link is present. Meanwhile all three inbound links exist and are pointed at demo 8:

- demo 1 `:249` — "[Demo 8] measures what the sort itself costs … radix's data-independent runtime makes it the p99 winner …"
- demo 6 `:210` — "[Demo 8] reuses the same cache-tier band markers on the radix sort line …"
- demo 7 `:308` — "a case where the L3 boundary marks a _cost rise_ rather than a crossover — [demo 8] runs a sorting sweep across the same tiers …"

So three posts send the reader to demo 8 and demo 8 reciprocates to none of them. Demo 8 _did_ add links to demos 4 and 5 (the tail-latency through-line — accurate and welcome, but not what §7 asked for). The demo-1 pairing in particular is the editorial spine of the post and is the one missing entirely.

**Fix:** Add a back-link to demo 1 where the post talks about sort cost vs downstream predictability (the intro or the "What this doesn't show" close is natural), and a back-link to demo 6 or 7 at the cache-knee paragraph (`:66`), since that paragraph is literally about the band markers demo 6/7 established. The inbound framings are reframe-safe, so any reciprocal wording works.

---

### M-3 — Cache-band markers and the radix footprint use two different conventions

**Locations:** `:55-59` (`thresholdMarkers`), `:66` ("the band markers … sit on the radix line"), `:68` (the small-N bump explanation).

**Problem:** The markers are placed at the **single-array** footprint: L1d at N=8192 (8192×4 = 32 KiB), L2 at N=131072 (512 KiB), L3 at N=4194304 (16 MiB). Line 66 says they "sit on the radix line" and explains the L3 knee with the single-array figure ("Four million 32-bit keys is 16 MB — the size of this machine's L3 slice"). But line 68 explains the small-N radix bump with the **doubled** footprint: "radix works on two n-element arrays at once, its working set is _twice_ the input. At ~4 K keys that doubled footprint is 32 KB — exactly the L1 data cache." Both can't be the literal mechanism for the same line:

- By the doubled-footprint logic, radix crosses L1 (32 KiB) at **N≈4096** — and the data agrees (the bump is at 4096→8192: radix 23.08 / 19.41, pdqsort briefly wins at 15.64 / 18.33). But the L1d **marker sits at 8192**, a factor of 2 to the right of where the prose says radix fights L1.
- By the same doubled logic, radix would hit 16 MiB (L3) at **N≈2097152**, not 4194304 — yet the L3 knee in the data is at ~4–8M, which fits the _single_-array figure the markers use.

A cache-aware reader — the target audience — sees the L1d band at 8192 while the text locates radix's L1 capacity bite at 4096, and the two cache stories silently swap footprint conventions. This is exactly the demo-7 M-3 class. Note demo 7 _fixed_ its version by adding a caveat (`07-flatmap-vs-hashmap.mdx:85-86`: "earlier than the markers suggest — visible in `absl::flat_hash_map` departing its flat region before the L1 marker"). Demo 8 instead asserts clean alignment.

**Fix (one-line judgement call, then edit):** Add the demo-7-style caveat under the chart or in the knee paragraph — e.g. _"The band markers are the single-array footprint; radix's ping-pong scratch buffer doubles its working set, so it crosses each tier at roughly half the marked N — which is why the small-N bump sits left of the L1d band."_ That converts an apparent contradiction into the very feature the next paragraph explains.

---

### M-4 — "few-unique keys are better" is false against the JSON on the natural reading

**Location:** `08-sorting-shootout.mdx:85`

**Quote:** _"…random keys happen to be no worse, and few-unique keys are better because the high passes collapse into a single bucket."_

**Problem:** At 4M, radix's medians are random = 12.20, few_unique = 14.75, sorted = 21.76 ns/element. The sentence runs sorted (slow) → random ("no worse") → few-unique ("better"), so "better" most naturally reads as _better than random_ — which is false: few-unique (14.75) is **slower** than random (12.20). The intended meaning is "better than the sorted/sequential worst case," which is true, but the comparison baseline established two clauses earlier is random. This is the demo-7 M-1 pattern (a ranking claim that a reader pulling the JSON sees is wrong). The mechanism itself (high passes collapse into one bucket → fewer scattered writes) is sound; only the baseline is muddled.

**Fix:** State radix's actual order explicitly — best on random (12), worst on sorted/reverse (~21–22), few-unique and sawtooth in between (15–17) — and attach "better" to the sorted worst case rather than to random. E.g. _"random is radix's best case at ~12; sorted and reverse are its worst at ~21–22 because sequential keys fan the scatter across all 256 buckets every pass; few-unique sits between them, since the high-order passes collapse into a single bucket."_

---

### M-5 — "p99 / tail-latency" borrows the measured-percentile vocabulary of demos 4/5

**Locations:** summary (`:6`, "the one you want on a hot path's p99"), tag `"tail-latency"` (`:7`), the "argument for a hot path" section (`:89-93`).

**Problem:** Demos 4 and 5 earn the words _p50 / p99 / p99.9_ by measuring a latency distribution — 5 runs × 1M timed samples, percentiles from merged histograms (their footers say so explicitly). Demo 8 measures **median ns_per_op across five input distributions**; its JSON `p99` field is run-to-run stability of that median (e.g. radix at 67M: median 14.82, p99 14.98, IQR 0.09 — essentially the median), not a per-sort latency tail. The body is mostly careful — it defines "tail" as _worst input_ ("what's the worst input going to do to me", "no input that blows out its tail") — but the **summary** ("hot path's p99") and the **tag** ("tail-latency") imply a percentile measurement the demo didn't make, and the cross-link to demos 4/5 invites the reader to read demo 8's "p99" as the same instrument. §8 names statistical-convention drift specifically; this is the clearest instance.

**Fix:** Reframe the summary as worst-case-input robustness rather than a percentile — e.g. _"…why a data-independent sort is the safe instrument when a worst-case input on a hot path is what you're paid to bound."_ Keep the body's careful "worst input" wording; the `"tail-latency"` tag is defensible only if the post is read as input-robustness, so either keep it and let the body carry the distinction, or swap to `"latency"` / `"determinism"`. This is the softest of the five — the argument is legitimate; the vocabulary just over-reaches the measurement.

---

## Low findings

### L-1 — Frontmatter shape diverges from demos 1–7

Demos 1–7 use exactly `title` / `date` / `summary`. Demo 8 adds `slug`, `demo`, and `tags` (`:2-7`). The post's own `{/* NOTE TO CC */}` says "frontmatter shape and import paths must match demo 7's shipped MDX exactly" — and it doesn't. Demos 1–7 render in the index without these fields, so the loader must derive slug/demo number elsewhere; demo 8's extra keys are at best redundant. **Fix:** strip `slug` / `demo` / `tags` to match demo 7, **or** confirm with §9 that the loader tolerates/uses them (likely a teaser-stub residue from §0 that §7 didn't remove). Rendering impact is a loader/code question, hence Low here.

### L-2 — A NOTE TO CC comment ships in the production MDX

`:10-13` carries `{/* NOTE TO CC: frontmatter shape … do not edit numerals without re-deriving from the JSON. */}`. It's an MDX comment so it won't render, but it's an authoring artefact and no other demo ships one. **Fix:** delete the block.

### L-3 — "crossover" reappears in the body

`:97` — "The crossover lives in the key width." The §8 mandate (and the demo-7 L-1 carry-forward) was to avoid the over-used "crossover" framing. The **headline and opening correctly avoid it** (the title uses the "wall / walk around it" mechanism framing the plan recommended — the primary §8 check passes). But the word resurfaces once in the body, and a reader arriving via demo 7's inbound link ("a cost rise _rather than a crossover_") meets "the crossover lives in the key width" two screens later. The usage is repurposed (key-width, not N) and arguably clever, so this is editorial. **User call:** rephrase to "the trade lives in the key width" / "the break-even is in the key width," or leave it as a deliberate repurpose.

### L-4 — Article typo

`:15` — "on a array of plain integers" → "on **an** array of plain integers."

### L-5 — Two small precision points in the distribution paragraph

`:85` calls radix "slightly slower on sorted input (~22) than on random (~12)" — that's ~1.8×, the entire width of radix's distribution spread, so "slightly" undersells it (the surrounding point is that radix's spread is _narrow relative to the comparison sorts_, which is fair, but "slightly" is the wrong word for a near-doubling). Separately, "the comparison sorts are _fastest_ on pre-sorted input" is true for `pdqsort` (sorted 0.75) but `std::sort` is actually fastest on **reverse** (7.08 vs sorted 9.58). **Fix:** "noticeably slower on sorted" or quote the ~1.8×; and either say "fastest on _ordered_ input" or attribute the pre-sorted-best claim to pdqsort specifically.

### L-6 — First-person "I"

`:85` — "the cleanest demonstration I know." Demo 2 also uses a single "I", so this isn't unique, but the corpus is otherwise impersonal or "we" (demos 1, 4). Optional tonal note; leave or soften to "the cleanest demonstration of why" per the user's preference.

---

## Checked and clean (recorded so they aren't re-flagged)

- **§8 primary check — headline avoids "crossover": PASS.** Title is the "wall / walk around it" mechanism framing; the opening and the chart captions are mechanism- and tail-framed. The only "crossover" is the repurposed body line in L-3.
- **Every headline number matches the JSON to the stated precision.** Opening 74 / ~15 ns at 67M (4.99× ≈ "five-times"); chart caption "5× faster than std::sort, 1.9× than pdqsort" (4.99× / 1.94×); std_sort "~9 → ~74" (9.03 → 74.02); radix knee "flat ~11 until ~4M, bends to ~15" (11–12 through 2–4M, 14–15 at 8–67M); small-N bump 4K–8K (radix 23/19, pdqsort 16/18, pdqsort wins both); distribution spreads (std_sort 9.0×, pdqsort ~35× — strictly 36.5× full-range / 34× random-vs-sorted, "35×" is a fair round, radix 1.78×); pdqsort sorted 0.75, sawtooth 27.5 "no faster than random" (27.5 vs 25.7); key-width 5.2× → 1.8×, pdqsort overtakes radix at u64 (26.3 vs 35.1), radix still beats std::sort (35 vs 64). All verified.
- **Single consistent slug.** Frontmatter `slug`, every chart `slug=` prop, and the JSON `demo` field are all `08-sorting-shootout` — no post-slug/data-slug split (unlike demo 7's `07-no-crossover`). Clean.
- **`thresholdMarkers` prop name matches demos 6/7.** (Whether the extended `<TimeVsN>`/`<ThroughputBars>` accept `distributionFilter` / `keyTypeFilter` / `distGrouped` / `targetN` is a component-code question — §9.)
- **`status: "in-progress"` and `expectedAt` correctly removed** from the teaser stub.
- **"What this doesn't show" is well-bounded** (`:99-108`): fixed-width unsigned keys only, key width decisive, bare keys, single-threaded/one-machine — matches the defensive-scope pattern of demos 5/7, and the "use radix" takeaway is correctly hedged ("the default is a fine default").
- **Cache facts consistent with the corpus.** 32 KiB L1d / 512 KiB L2 / 16 MiB-per-CCX L3 agree with demos 1/6/7; "L3 slice" continues the existing (loose) demos-4/5 usage; decimal "16 MB / 32 KB" matches the corpus majority (demos 2–6) — the binary/decimal split (demos 1 and 7 use KiB/MiB) is a pre-existing project-wide inconsistency, not a demo-8 regression.
- **std::sort "shape is almost entirely log₂ n"** (`:21`) is defensible across the bulk range (16K–67M is roughly linear in the doubling count); the early 1K–8K cache transition is the one place it's loose, and the contrast it draws against the cache-shaped radix line holds.
- **Cross-links to demos 4/5 are accurate and reframe-safe** (the tail/distribution-not-average through-line); not what §7 mandated, but correct on their own terms.
- **"per element" framing is consistent** with the pre-demo-5 ns-per-op units fix; the JSON `notes` confirm `ns_per_op` = ns per element sorted.

---

## Coverage boundaries (could not verify from the provided files)

- **Methodology page demo-count bump to 8** (plan §7) — `/methodology` source not provided. Verify in §9.
- **Chart-component props** (`distributionFilter`, `keyTypeFilter`, `distGrouped`, `targetN`) — component code not in scope for a prose cross-read (per the demo-7 read's scoping). Confirm the extended `<TimeVsN>` / `<ThroughputBars>` accept them in §9.
- **Index render / pill removal / eight-card layout** — site code, not provided; plan §10/§11 (user) covers it.

---

## Recommendations

**Quick-fix bundle (one CC pass).** M-1 (footer), M-2 (two back-links), L-1 (frontmatter strip — pending the §9 loader confirmation), L-2 (delete the comment), L-4 (typo). Verbatim or near-verbatim edits; fixes specified above. Bundle as `demo-08-09-hostile-cross-read-cleanup-brief.md`.

**Need a one-line decision first.** M-3 (markers caveat — copy the demo-7 wording), M-4 (rewrite the distribution baseline), M-5 (summary/tag reframe), L-5 (precision wording). Settle the four wordings, then fold into the same brief.

**Editorial, defer to the user.** L-3 ("crossover" in the body) and L-6 (first-person "I").

**The cross-read is complete** — demos 1–8 all read. No outstanding coverage gap before §9 (pre-merge review), subject to the three Coverage-boundary items above which §9 owns.

---

## Stop condition for §8

Audit complete across all eight posts. Triage: (1) settle the M-3 / M-4 / M-5 / L-5 wordings; (2) Opus writes the cleanup brief; (3) CC applies (with the L-1 loader check); (4) mark §8 ☑. Then §9 (pre-merge review) and §10 (merge) remain.
