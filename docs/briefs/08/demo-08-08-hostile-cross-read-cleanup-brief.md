# Crucible — demo 8 hostile cross-read cleanup brief

**The fix bundle from `demo-08-hostile-cross-read-findings.md` (demo-08-plan.md §8), packaged as one small PR on the demo 8 feature branch. Lands before §9 (pre-merge review).** All edits are to `site/src/posts/08-sorting-shootout.mdx` unless stated. No JSON, no C++, no recapture. Follows the same shape as the `demo-07-08-hostile-cross-read-cleanup-brief.md` predecessor.

---

## 1. Context

The §8 cross-read read demo 8 against demos 1–7 and the captured `08-sorting-shootout.json`. The headline checks pass (the "crossover" framing is correctly avoided in the title/opening, and every numeral matches the JSON). What remains is one structural omission (no footer), one missing-cross-link set the plan mandated, three wording fixes where the prose drifts from the data or the corpus conventions, and a handful of hygiene items.

This brief carries the verbatim edits. Two items are **not** auto-applied — they go to the user (see §5). Two items have a real ground-truth dependency CC must resolve before editing (see §6).

Line numbers are as of the cross-read; CC should grep the quoted text rather than trust the line.

---

## 2. Material fixes

### 2.1 M-1 — Add the standardised footer (and the Methodology link)

Demo 8 is the only one of eight posts with no machine-spec footer and no closing `*[Methodology →]*`. Append both at the very end of the file, after the "Reproducing this" paragraph. Match the demo 6/7 single-thread-sweep shape; pull the values from the JSON `machine` block (`-O3 -march=native -std=c++20`, 5 reps/cell, working-set sweep):

```
---

*AMD Ryzen 7 3800X, Zen 2 (SMT off), 3.9 GHz base, governor = performance, turbo disabled (BIOS Core Performance Boost off), cores 0–7 isolated (core 0 carries unavoidable kernel housekeeping), single thread pinned to cores 4–7 (CCX1). Headless Ubuntu 24.04. GCC 13.3, -O3 -march=native -std=c++20. 5 outer repetitions per cell, median ns_per_op reported (working-set-sweep convention).*

*[Methodology →](/methodology)*
```

**The pin wording is the one value to check, not guess — see Open item 6.1.** Everything else is fixed from the JSON.

### 2.2 M-2 — Add the two backward cross-links the plan mandated

Plan §7 specified a back-link to demo 1 and to demo 6/7. Demos 1, 6, and 7 all forward-link _to_ demo 8 already; demo 8 reciprocates to neither. Two edits:

**(a) demo 6 / 7 link**, at the cache-knee paragraph (the sentence beginning "The band markers on the chart sit on the radix line for that reason"). Replace:

> The band markers on the chart sit on the radix line for that reason

with:

> The band markers — the same cache-tier bands [demo 6](/posts/06-aos-vs-soa) and [demo 7](/posts/07-flatmap-vs-hashmap) introduced — sit on the radix line for that reason

**(b) demo 1 link**, appended to the closing takeaway paragraph (the one ending "…on this one shape of problem you can do better."). Append:

> It pairs with [demo 1](/posts/01-branch-prediction) from the other side: demo 1 measured the _payoff_ of sorting — a branch-predictable downstream loop — and this post measures its _price_.

(The existing demo 4 / demo 5 links stay — they carry the tail/distribution through-line and are correct; they just weren't what §7 asked for.)

### 2.3 M-3 — Caveat the band markers against radix's doubled footprint

The markers are placed at the single-array footprint (32 KiB at N=8 K, 512 KiB at 128 K, 16 MiB at 4 M), but the small-N bump in the next paragraph is explained by radix's _doubled_ working set — so the L1 bite lands at ~4 K, left of the 8 K marker. Demo 7 fixed the identical class (`07-flatmap-vs-hashmap.mdx:85-86`) with a one-line caveat; demo 8 asserts clean alignment instead. Append to the end of the cache-knee paragraph (after "…rather than by its own asymptotics."):

> One caveat on the bands: they mark the single-array footprint. Radix's ping-pong scratch buffer doubles its working set at small N, so it crosses the lower tiers earlier than the markers suggest — that's the bump just left of the L1 band in the next paragraph.

This is the **safe** wording (it matches demo 7's fix and doesn't over-claim). A richer version that also explains why the _L3_ knee still tracks the single-array figure is available if wanted — see Open item 6.2 — but the line above is sufficient and is what should ship unless the user asks for more.

### 2.4 M-4 + L-5 — Rewrite the distribution-preference sentence

"few-unique keys are better" reads false on the natural parse: at 4 M, radix's medians are random 12.2, few_unique 14.75, sorted 21.76 — few-unique is _slower_ than random, not better. The fix also folds in L-5 (radix's "slightly slower on sorted" undersells a ~1.8× gap; "comparison sorts fastest on pre-sorted" is true for pdqsort but `std::sort` is fastest on _reverse_). Replace:

> The comparison sorts are _fastest_ on pre-sorted input and slowest on random. Radix is the reverse — it's actually slightly **slower** on sorted input (~22 ns/element) than on random (~12). Sequential keys make every byte of the key vary across the full range, which fans the scatter writes across all 256 buckets on every pass; random keys happen to be no worse, and few-unique keys are better because the high passes collapse into a single bucket.

with:

> The comparison sorts are _fastest_ on ordered input — sorted or reverse-sorted — and slowest on random. Radix is the reverse: sorted and reverse-sorted are its _worst_ inputs (~21–22 ns/element), random is its _best_ (~12), and few-unique sits in between (~15). Sequential keys make the high-order bytes vary across the full range, fanning the scatter writes across all 256 buckets on every pass; few-unique collapses those high passes into a single bucket, so it beats the sorted worst case without matching random.

Leave the surrounding sentences ("There's a tidy inversion buried in those numbers." / "Same operation, opposite preference. …") unchanged.

### 2.5 M-5 — Reframe the summary off "p99"

The summary attributes a _measured percentile_ to the sort. Demo 8 measures cross-distribution medians; its JSON `p99` is run-to-run stability (≈ the median), not a latency tail — unlike demos 4/5, which earn p50/p99/p99.9 from 1 M-sample histograms. The body is careful (it frames "tail" as worst input); only the summary overreaches. In the frontmatter `summary`, replace:

> and why the data-independent sort is the one you want on a hot path's p99.

with:

> and why a data-independent sort is the one you want when a worst-case input on a hot path is what you have to bound.

The body's "p99 spike" usage (in the hot-path section) is fine as written — it refers to the _downstream system's_ p99, not a measured sort percentile — so leave it. The `"tail-latency"` frontmatter tag is defensible once the summary is reframed; leave it unless the user prefers `"latency"`.

---

## 3. Hygiene fixes

### 3.1 L-2 — Delete the shipped NOTE TO CC comment

Remove the MDX comment block (lines 10–13), the one beginning `{/* NOTE TO CC: frontmatter shape and import paths…`. It's an authoring artefact; no other demo ships one.

### 3.2 L-4 — Article typo

In the opening paragraph, replace "on a array of plain integers" with "on **an** array of plain integers".

### 3.3 L-1 — Normalise the frontmatter — **conditional, see Open item 6.3**

Demo 8's frontmatter carries `slug`, `demo`, and `tags`; demos 1–7 use only `title` / `date` / `summary`. **Do not strip these blind** — first confirm the loader doesn't read them (Open item 6.3). If the loader ignores them, delete the three keys so the shape matches demos 1–7. If the loader _uses_ any of them, leave them and note the divergence in the PR instead.

---

## 4. Acceptance

- [ ] **M-1**: `grep -n 'working-set-sweep convention' site/src/posts/08-sorting-shootout.mdx` returns one hit; `grep -n 'Methodology →' …08…mdx` returns one hit; the footer is the last content in the file.
- [ ] **M-2**: `grep -nE '/posts/01-branch-prediction|/posts/06-aos-vs-soa|/posts/07-flatmap-vs-hashmap' …08…mdx` returns the three new links (demo 1, 6, 7).
- [ ] **M-3**: the cache-knee paragraph contains "single-array footprint"; the claim "sit on the radix line" is no longer unqualified.
- [ ] **M-4**: `grep -n 'few-unique keys are better' …08…mdx` returns **zero**; the replacement text is present with random as the best case (~12) and few-unique between (~15).
- [ ] **M-5**: `grep -n "hot path's p99" …08…mdx` returns **zero** (frontmatter reframed).
- [ ] **L-2**: `grep -n 'NOTE TO CC' …08…mdx` returns **zero**.
- [ ] **L-4**: `grep -n 'a array' …08…mdx` returns **zero**.
- [ ] **L-1**: frontmatter keys match demos 1–7 **or** the loader-dependence is documented in the PR (per 6.3).
- [ ] All prose numerals still match the JSON (no numeral was touched except the descriptive ranges in M-4, which are re-derived above).
- [ ] `npm run build` succeeds; demo 8 renders with both charts.
- [ ] `git diff --stat` shows only `site/src/posts/08-sorting-shootout.mdx` changed (plus the loader file only if 6.3 forces a read-only check — no loader edits in this brief).

---

## 5. Editorial — surface to the user, do **not** auto-apply

- **L-3 — "crossover" in the body.** `…:97` says "The crossover lives in the key width." The §8 mandate flags the word; the headline correctly avoids it, but a reader arriving via demo 7's "a cost rise _rather than a crossover_" inbound link meets it two screens later. The usage is repurposed (key-width, not N), so it may be a deliberate keep. Proposed alternative if the user wants it gone: "The trade lives in the key width" or "The break-even is in the key width." Flag and propose; don't edit.
- **L-6 — first-person "I".** `…:85` "the cleanest demonstration I know." Demo 2 also uses one "I", so it isn't unique, but the corpus norm is impersonal/"we". Optional softening: "the cleanest demonstration of how these two families…". User call.

---

## 6. Open items for CC to flag

- **6.1 — Footer pin wording.** The JSON `cpu_affinity` is `4-7`, so the footer above says "pinned to cores 4–7". Demos 6 and 7 (also single-threaded sweeps) say "single thread pinned to core 4 (CCX1)". If the demo 8 capture was actually fixed to one core (check `run_one.sh` / the `taskset` or `cset` invocation in the harness), switch to the demo-6 "core 4 (CCX1)" wording. If it floated across 4–7 as `cpu_affinity` indicates, keep "cores 4–7". Match what the run did — don't guess.
- **6.2 — M-3 richer wording (optional).** If the user wants the caveat to also explain why the _L3_ knee tracks the single-array figure while the L1 bump tracks the doubled one: the physical reading is that at small N both arrays must stay resident (doubled footprint governs), whereas at the L3→DRAM transition the scatter writes stream rather than stay resident (single-array read footprint governs). Only assert this if the user signs off on the mechanism; the §2.3 wording is safe without it.
- **6.3 — Frontmatter loader dependence (blocks L-1).** Before stripping `slug` / `demo` / `tags`, grep the post loader and index for reads of those frontmatter fields — likely `site/src/app/posts/[slug]/page.tsx`, the index/card component, and any `getPostBySlug`/frontmatter-parsing helper. Demos 1–7 render without these fields, so the loader must derive slug/demo number another way; the fields are probably teaser-stub residue (§0) that §7 didn't remove. **If any field is read, do not strip it** — leave it and note the divergence. Stripping a field the index uses would break the demo 8 card.

---

## 7. Out of scope

- Any change to demos 1–7 prose, code, or JSON. Their inbound links to demo 8 are correct and stay.
- The `/methodology` page (the demo-count bump is a §7/§9 concern; this brief doesn't touch it).
- Chart-component code — whether the extended `<TimeVsN>` / `<ThroughputBars>` accept `distributionFilter` / `keyTypeFilter` / `distGrouped` / `targetN` is the §9 pre-merge review's job, not a prose cleanup.
- Recapturing any JSON.
- The corpus-wide binary-vs-decimal unit inconsistency (demos 1/7 use KiB/MiB, the rest decimal); demo 8 follows the majority — not a regression, not in scope.

---

## 8. Stop condition

PR merged into the demo 8 feature branch with §4 green and §6 resolved (6.1 wording fixed from the harness, 6.3 loader checked, 6.2 left as default unless the user opts in). §5 editorial items raised with the user separately. Then §8 → ☑ and §9 (pre-merge review) proceeds.
