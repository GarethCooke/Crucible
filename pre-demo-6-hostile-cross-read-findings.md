# Crucible — demo 6 hostile cross-read findings (task 8)

**Read date:** 2026-05-24
**Method:** Back-to-back read of all six post MDX files in numeric order (1, 2, 3, 4, 5, 6), with each demo-6 numerical claim cross-checked against `site/src/data/perf/06-aos-vs-soa.json` and the rendered output on the feature-branch Amplify preview (`https://feature-06-aos-vs-soa.d14dcqqx5dzc76.amplifyapp.com/posts/06-aos-vs-soa`). Methodology page (`site/src/app/methodology/page.tsx`) read alongside. Watching for the four drift classes called out in the demo-06-plan task: statistical convention drift, Zen 2 / CCX framing consistency, methodology consistency (headless declared in the post or methodology link), tonal drift, repeated or contradictory caveats. Plus a residual watch on findings the pre-demo-5 read flagged as recurring patterns (footer convention drift, section-name drift, repetition-count disclosure, opening rhythm, cross-link integrity).
**Scope:** Demo 6 prose, structure, footers, link integrity, numerical self-consistency against JSON, methodology consistency with demos 1–5 and the methodology page. Not C++, not chart components, not bench harness.

---

## Summary

| #    | Severity | Demo | Class       | One-line                                                                                                                                                   |
| ---- | -------- | ---- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C-1  | Critical | 6    | Bug         | Footer JSON link is `https://github.com/your-handle/crucible/...` — unfilled placeholder, 404 on click, live on deployed site                              |
| C-2  | Critical | 6    | Numerical   | Headline table row N=131,072 says `3.72 ns`; JSON has `3.41 ns` (median); the value doesn't appear in min/median/p99                                       |
| C-3  | Critical | 6    | Bug         | Three in-text `§SIMD` links go to `#simd-escapes-compute-not-memory`; no heading on the rendered page has an `id` attribute                                |
| C-4  | Critical | 6    | Factual     | "The cross-CCX picture is in demo 4's notes" — demo 4 explicitly **defers** cross-CCX. The cross-CCX picture is in demos 2 & 5                             |
| C-5  | Critical | 6    | Stale       | `cset shield --reset` and "shielded core" in body + footer — methodology page documents `isolcpus`-only; same class as prior C-2                           |
| M-1  | Material | 6    | Numerical   | "The IQR/median spread is well under 1% at each point" — N=524,288 has IQR/median = 1.71%, N=262,144 = 1.01%                                               |
| M-2  | Material | 6    | Numerical   | Prose lists `N ∈ {1k, 4k, 8k, ..., 1M}` and "150 cells; 135 retained after dropping warm-up"; JSON has no 1k, 135 = 3×9×5 raw                              |
| M-3  | Material | 6    | Numerical   | "128 B × N covers 128 KB through 128 MB — L1 through deep DRAM" — smallest measured N=4096 is 512 KB = exactly L2 size                                     |
| M-4  | Material | 6    | Drift       | Footer is structurally unlike demos 1–5: no GCC version, no `-march` flag, no core-isolation statement; adds OS version + cset                             |
| M-5  | Material | 6    | Drift       | "methodology details ... are unchanged from demos 1–5" links to `/methodology` — but multiple items named there aren't on the page                         |
| M-6  | Material | 6    | Drift       | Demo 6 is the only post with no opening lede paragraph — opens directly with `## The setup`                                                                |
| M-7  | Material | all  | Drift       | Rep count disclosure: silent (1, 3), 20 (2), 30 (4), 5×1M (5), ≥5 (6); methodology page commits to ≥20 + only the demo-4 exception                         |
| M-8  | Material | all  | Drift       | "Reproducing this" section: present in 5 only; absent in 1, 2, 3, 4, 6. Inverse of pre-demo-5 M-2's distribution                                           |
| M-9  | Material | 6    | Unsupported | "no visible step between L1 (the smallest working sets) and L2" — JSON contains no L1-resident points to support the claim                                 |
| M-10 | Material | meth | Stale       | Methodology page commitment #4 still says "≥20 outer repetitions" with only demo 04 called out; demos 5 and 6 are now also exceptions                      |
| L-1  | Low      | 6    | Factual     | "N = 131 072 (16 MB, L3 lip) ... Mid-cliff — L3 boundary minus a margin" — N=131,072 × 128 B = 16 MB exactly = L3 capacity                                 |
| L-2  | Low      | 6    | Numerical   | K=4 table row claims AoS/SoA = 1.36×; JSON medians give 1.31× (4.133 / 3.156)                                                                              |
| L-3  | Low      | 6    | Style       | "CCX 1" (with space) in line 187 vs "CCX1" (no space) in demos 4, 5, JSON notes                                                                            |
| L-4  | Low      | 6    | Style       | "## The benchmark" (demo 6) vs "## Setup" (demo 5) — same content slot, different heading                                                                  |
| L-5  | Low      | 6    | Meta        | JSON `struct_field_count: 16` (8-byte slots in 128 B) vs prose "Twelve named fields" — same struct, two count conventions                                  |
| L-6  | Low      | 6    | Style       | "Reproduce via `bench/demos/06-aos-vs-soa/README.md`" rendered as plain text; demo 5 hyperlinks equivalent paths to GitHub                                 |
| L-7  | Low      | 6    | Tonal       | "What it has instead is more interesting" (line 17) + "this is the headline result and it survives every sanity check" (line 106) read self-congratulatory |

12 critical + material findings, 7 low. Two of the critical findings (C-1, C-3) are functional bugs on the live deployment; one (C-4) is a wrong factual claim; one (C-5) is a regression of a finding pre-demo-5 explicitly closed; one (C-2) is a direct data-vs-prose mismatch in the headline table.

---

## Critical findings

### C-1 — Demo 6: footer JSON link points to an unfilled placeholder URL

**Location:** `06-aos-vs-soa.mdx:206`

**Quote:**

> _All numbers from [`site/src/data/perf/06-aos-vs-soa.json`](https://github.com/your-handle/crucible/blob/main/site/src/data/perf/06-aos-vs-soa.json)._

**Problem:** The URL is `https://github.com/your-handle/crucible/blob/main/site/src/data/perf/06-aos-vs-soa.json` — `your-handle` is a literal placeholder string, not a username. Verified live on the feature-branch deployment: `document.querySelector('a[href*=\"06-aos-vs-soa.json\"]').href === "https://github.com/your-handle/crucible/blob/main/site/src/data/perf/06-aos-vs-soa.json"`. Clicking it produces a 404. The string appears twice in the rendered HTML (one anchor, one href). Demo 5 uses the correct form: `https://github.com/GarethCooke/Crucible/...` (and `Crucible` is capitalised in the org/repo name there, lowercase `crucible` here — that's a separate small error stacked on the placeholder).

**Fix:** Replace `your-handle/crucible` with `GarethCooke/Crucible` to match demo 5 line 179 and the calibration-notes link at demo 5 line 64.

---

### C-2 — Demo 6: headline table row for N=131,072 doesn't match the JSON

**Location:** `06-aos-vs-soa.mdx:80–86`

**Quote (the headline shape table, row 3):**

> _| N = 131 072 (16 MB, L3 lip) | 3.72 | Mid-cliff — L3 boundary minus a margin |_

**Problem:** The JSON record for `aos-scalar, n=131072, k=1` has `ns_per_op.median = 3.4097`, `min = 3.4021`, `p99 = 3.4825`, `iqr = 0.0011`. The value 3.72 doesn't appear in any aggregate for that cell. Adjacent rows in the same table (1.31 at N=4096, 5.37 at N=1,048,576) match the JSON exactly to two decimal places — so the convention is full-precision medians, and this row is the anomaly. The 8-9% delta is well outside the iqr (0.03% of median) so it isn't a rounding choice or stat-flavour swap.

**Fix:** Change `3.72` to `3.41` and re-check the surrounding prose. The "4.11× cliff" headline at line 87 uses 1.31 → 5.37 (4.107×), so it survives. But "Mid-cliff — L3 boundary minus a margin" (this row's notes column) is also wrong: N=131,072 × 128 B = exactly 16 MB = L3 capacity, _not_ "minus a margin" (see also L-1). With the corrected value 3.41, this point is _on_ the L3 boundary and roughly halfway up the cliff from the 1.50 plateau to the 5.37 DRAM band. "L3 boundary, mid-cliff" is the accurate description.

---

### C-3 — Demo 6: in-text `§SIMD` anchor links are broken on the live site

**Location:** `06-aos-vs-soa.mdx:28, 57, 202` (three occurrences); rendered at the feature-branch deployment

**Quotes:**

> _SIMD is its own twist on top — discussed in §[SIMD](#simd-escapes-compute-not-memory) — and inverts the usual intuition about where vectorisation pays._

> _it's the question §[SIMD](#simd-escapes-compute-not-memory) answers._

> _[Demo 3](/posts/03-simd-blackscholes) takes over from §[SIMD](#simd-escapes-compute-not-memory) for the compute-bound side of the SIMD question._

**Problem:** All three links target `#simd-escapes-compute-not-memory`. Querying the rendered DOM at the live deployment: `Array.from(document.querySelectorAll('h1,h2,h3,h4')).map(h => h.id)` returns `[null, null, null, null, null, null, null, null, null, null]` — _every_ heading has a null id. So none of the three links scrolls anywhere. The h2 element with text "SIMD escapes compute, not memory" exists, but the MDX → HTML pipeline isn't slugifying its id. Demo 1, 2, 3, 4, 5 have no internal-anchor links so this is the first post that exercises that pipeline; the failure is in the rendering path, not in the MDX.

**Fix:** Two options. (a) Configure the MDX pipeline to auto-slug h2 ids (rehype-slug or equivalent). Probably right answer; would also enable any later post's in-page navigation. (b) Drop the `§SIMD` links and inline the cross-reference as plain text — the three current uses are all near the heading they reference, so the navigation value is small. Recommend (a) since it's a one-line plugin add and unlocks future use; if (a) is non-trivial, (b) ships demo 6 without the broken state.

---

### C-4 — Demo 6: "cross-CCX picture is in demo 4's notes" is factually wrong

**Location:** `06-aos-vs-soa.mdx:187`

**Quote:**

> _Multi-thread / cross-CCX. Single thread, pinned to core 4, CCX 1, 16 MB L3 to itself. The cross-CCX picture is in [demo 4](/posts/04-spsc-queue)'s notes and is a different shape — once the L3 is contended, the cliff moves._

**Problem:** Demo 4 explicitly **defers** cross-CCX. Demo 4 line 236–238:

> _Cross-CCX: producer and consumer on separate CCX slices. Cache-coherence traffic crosses the Infinity Fabric; latency increases. Deferred to a future topology post._

So a reader who follows the link from demo 6 to verify the cross-CCX picture finds the opposite: a "we didn't measure this" disclaimer. The actual cross-CCX measurements live in demo 2 (intra-CCX vs cross-CCX false-sharing throughout) and demo 5 (the cross-CCX side note at lines 140–159, with measured malloc/freelist/arena comparison). The pre-demo-5 cross-read flagged that the cross-link density between posts was thin; this is the first link the post added in that direction, and it points the wrong way.

**Fix:** Change the link target to demo 5 (which has measured cross-CCX data directly relevant to the "L3 contention moves the cliff" framing demo 6 is making) or demo 2 (canonical cross-CCX measurement). Demo 5 is the better fit because its cross-CCX section uses the same vocabulary ("Infinity Fabric round-trip", "L3 domain"). Alternative phrasing: "the cross-CCX picture is in [demo 5](/posts/05-allocators)'s side note and is a different shape — the Infinity Fabric round-trip changes which working sets are bandwidth-bound in the first place."

---

### C-5 — Demo 6: reintroduces `cset shield` references that pre-demo-5 cleanup removed

**Locations:** `06-aos-vs-soa.mdx:63` (body); `06-aos-vs-soa.mdx:206` (footer)

**Quotes:**

> _(line 63)_ _The reference machine, the headless capture rules, and the methodology details (shielded core, governor `performance`, turbo off, `cset` reset, ≥5 reps median) are unchanged from [demos 1–5](/methodology)._

> _(line 206)_ _Capture: AMD Ryzen 7 3800X (Zen 2, SMT off), headless Ubuntu 24.04, `sudo cset shield --reset` before run, governor `performance`, BIOS Core Performance Boost off, ≥5 outer repetitions, median `ns_per_op` reported._

**Problem:** This is a regression of pre-demo-5 C-2 (the demo 3 "requires cset + sudo" line). The methodology page (read against `site/src/app/methodology/page.tsx`) uses `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` throughout and the word "cset" does not appear on it anywhere. Demos 1–5 in their current state likewise have zero `cset` references — every footer has been cleaned up to say "cores 0–7 isolated" or equivalent. Demo 6 reintroduces both the term "cset" and the related "shielded core" framing (the methodology page uses "isolated", not "shielded"). A reader who follows the methodology link to verify the "unchanged from demos 1–5" claim finds the opposite: no mention of cset or shielding.

(Aside: the demo-06-plan §1 lesson states `sudo cset shield --reset` _is_ in practice a real precondition due to a cpuset-v1 / PID 1 affinity gotcha logged in the demo 5 calibration-notes README. If that's accurate operationally, the right fix is to add a one-line note to the methodology page explaining that the harness invokes `cset shield --reset` as a kernel-state-cleanup step _before_ the isolcpus-based capture, rather than have demo 6 silently introduce vocabulary that contradicts the methodology page. The plan's "Open items" already flags this as a candidate edit and demo 6 is a forcing moment.)

**Fix:** Two options. (a) If `cset shield --reset` is genuinely operationally required, add a sentence to the methodology page Commitment #3 explaining its role (kernel-state cleanup, not the primary isolation mechanism). Then demo 6's body and footer can keep their references and the methodology link will support them. (b) If `cset shield --reset` is not strictly required for this demo, drop both references from demo 6 and replace "shielded core" with "isolated core" to match the methodology page's vocabulary. Either way, the contradiction between body+footer and methodology page must close.

---

## Material findings

### M-1 — Demo 6: "well under 1% at each point" is false for the middle DRAM-band point

**Location:** `06-aos-vs-soa.mdx:89`

**Quote:**

> _The DRAM band is non-monotonic — N = 262 144 lands at 4.17 ns, N = 524 288 at 3.99 ns, N = 1 048 576 at 5.37 ns. The IQR/median spread is well under 1% at each point, so it's a real signal, not measurement noise._

**Problem:** JSON for AoS K=1:

- N = 262,144: median 4.168, iqr 0.0422 → iqr/median = 1.01%
- N = 524,288: median 3.995, iqr 0.0683 → iqr/median = 1.71%
- N = 1,048,576: median 5.374, iqr 0.004 → iqr/median = 0.07%

So one of the three points has 1.71% spread — not "well under 1%". The conclusion ("real signal, not measurement noise") may still survive a stricter analysis (the 5.37 → 3.99 swing is ~25%, well above 1.71% even at the noisiest point), but the supporting premise as stated is wrong.

**Fix:** Either restate the dispersion accurately ("IQR/median ≤ 1.7% at each point, well below the 25% swing between adjacent points, so it's a real signal") or use a different point of evidence. The qualitative claim about a real microarchitectural interaction survives; the specific framing doesn't.

---

### M-2 — Demo 6: prose claims an N=1k point and 15 dropped warm-up cells; JSON has neither

**Location:** `06-aos-vs-soa.mdx:61`

**Quote:**

> _Working-set sweep N ∈ {1k, 4k, 8k, 16k, 32k, 65k, 131k, 262k, 524k, 1 048 576} elements (so 128 B × N covers 128 KB through 128 MB — L1 through deep DRAM). K ∈ {1, 2, 4, 8, 16}. Three variants. 150 cells; 135 of them retained after dropping the warm-up cells the harness emits but doesn't keep._

**Problem:** The JSON has 135 runs total, distributed exactly as 3 variants × 9 N values × 5 K values, with N values `{4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576}`. There is no N=1024 record. The "150 cells; 135 retained" framing implies 15 cells are dropped — that would be one full K-line at N=1k (3 variants × 1 N × 5 K = 15). The plain reading of the JSON is "we measured 9 N values, no warmup-discard". The prose claim describes a harness behaviour the JSON doesn't reflect.

Two ways this could be true:

- The harness _does_ run N=1024 cells as warmup and discards them before serialising. If so, the JSON's `items_warmup: 0` and the absence of any artefact of those runs is consistent with that — but then the prose listing "1k" in the N set is misleading because N=1k isn't in the published data and "L1 through deep DRAM" can't be supported from what's there.
- The harness doesn't run N=1024 at all and the prose is wrong on both points.

The JSON notes field reads: `"N: 4096–1048576 elements"` — which suggests the second interpretation.

**Fix:** Drop "1k" from the listed N set; change "150 cells; 135 of them retained after dropping the warm-up cells" to just "135 cells". If N=1024 measurements were originally planned and dropped because the harness's warmup amortisation makes them unreliable, that's worth a single sentence noting why — but the current framing reads as "we measured 150 and reported 135", which isn't what the JSON shows.

---

### M-3 — Demo 6: "L1 through deep DRAM" coverage claim isn't supported by the data

**Location:** `06-aos-vs-soa.mdx:61` (continuation of M-2)

**Quote:**

> _128 B × N covers 128 KB through 128 MB — L1 through deep DRAM._

**Problem:** Smallest N in the JSON is 4096 → 128 B × 4096 = 524,288 bytes = 512 KB, _not_ 128 KB. Zen 2 L1d is 32 KB per core; 512 KB exactly fills the 512 KB L2. So the smallest measured working set is _at_ the L2 capacity, not L1-resident. The lower bound of the sweep range is misstated (512 KB, not 128 KB), and the "L1 through deep DRAM" framing is unsupported — there are no L1-resident points in the published data.

This compounds M-9 below: the "no visible step between L1 and L2" claim at line 87 also depends on having L1-resident measurements, and there aren't any.

**Fix:** Restate as "128 B × N covers 512 KB through 128 MB — L2 through deep DRAM", or run the L1-resident points if the L1→L2 transition claim is load-bearing for the post.

---

### M-4 — Demo 6: footer is structurally unlike demos 1–5

**Location:** `06-aos-vs-soa.mdx:206`

**Quote:**

> _Capture: AMD Ryzen 7 3800X (Zen 2, SMT off), headless Ubuntu 24.04, `sudo cset shield --reset` before run, governor `performance`, BIOS Core Performance Boost off, ≥5 outer repetitions, median `ns_per_op` reported. Reproduce via `bench/demos/06-aos-vs-soa/README.md`._

**Problem:** Comparison against the other five footers:

| Field          | 1                                       | 2                       | 3                                   | 4                                               | 5                                      | 6                                 |
| -------------- | --------------------------------------- | ----------------------- | ----------------------------------- | ----------------------------------------------- | -------------------------------------- | --------------------------------- |
| Base clock     | "3.9 GHz base"                          | "3.9 GHz base"          | "3.9 GHz base"                      | absent                                          | "3.9 GHz base"                         | absent                            |
| Governor       | performance                             | performance             | performance                         | performance                                     | performance                            | performance                       |
| Turbo          | "Turbo Boost off"                       | "Turbo Boost off"       | "turbo disabled (cpupower)"         | "Turbo Boost off"                               | "turbo disabled (cpupower)"            | "BIOS Core Performance Boost off" |
| SMT            | absent                                  | "SMT off (BIOS)"        | "SMT off (BIOS)"                    | "SMT off (BIOS)"                                | "SMT off (BIOS)"                       | "SMT off"                         |
| Isolation      | "cores 0–7 isolated, pinned to 4–7"     | absent                  | "cores 0–7 isolated, pinned to 4–7" | "producer core 4 + consumer core 5 (same CCX1)" | "cores 0–7 isolated ... pinned to 4–7" | **absent**                        |
| GCC version    | "GCC 13.3"                              | "GCC 13.3"              | "GCC 13.3"                          | "GCC 13.3"                                      | "GCC 13.3"                             | **absent**                        |
| Compiler flags | `-O3 -march=native`                     | `-O3 -march=native`     | "per-variant ISA flags ..."         | `-O3 -march=native`                             | `-O3 -march=native -std=c++20`         | **absent**                        |
| OS             | absent                                  | absent                  | absent                              | absent                                          | absent                                 | "headless Ubuntu 24.04"           |
| Cset           | absent                                  | absent                  | absent                              | absent                                          | absent                                 | "sudo cset shield --reset"        |
| Rep count      | "median ns/iteration" (silent on count) | "20 repetitions" (body) | absent                              | "all 30 runs" (body)                            | "5 × 1M items" (body)                  | "≥5 outer repetitions"            |

Demo 6's footer drops four conventional fields (base clock, GCC version, compiler flags, isolation statement) and adds three previously-unused ones (Ubuntu version, cset, "headless"). Even accepting the demo-06-plan's explicit decision to surface "headless", the footer is missing four facts a reader needs to reproduce the work (GCC 13.3 / `-O3 -march=znver2 -fno-tree-vectorize` / pinning core / isolated cores) that the JSON in fact records and the prose body (`-O3 -march=znver2 -fno-tree-vectorize` mentioned at line 55, core 4 pinning at line 187) partially repeats.

**Fix:** Align demo 6's footer to demo 5's shape, keeping the new "headless Ubuntu 24.04" addition. Suggested:

> _AMD Ryzen 7 3800X, Zen 2 (SMT off), 3.9 GHz base, governor = performance, turbo disabled (BIOS Core Performance Boost off), cores 0–7 isolated, benchmarks pinned to 4–7 (single thread on core 4, CCX1). Headless Ubuntu 24.04. GCC 13.3, -O3 -march=znver2 -fno-tree-vectorize. ≥5 outer repetitions, median ns_per_op reported._

The `cset shield --reset` decision lives in C-5; the footer should drop the term if C-5 is resolved by removing it from the body, or keep it if C-5 is resolved by adding it to the methodology page.

---

### M-5 — Demo 6: "unchanged from demos 1–5" claim links to a methodology page that doesn't back several of the listed items

**Location:** `06-aos-vs-soa.mdx:63`

**Quote:**

> _The reference machine, the headless capture rules, and the methodology details (shielded core, governor `performance`, turbo off, `cset` reset, ≥5 reps median) are unchanged from [demos 1–5](/methodology)._

**Problem:** Of the five items in the parenthesis:

- "shielded core" — methodology page uses "isolated", not "shielded"; no mention of "shielded" anywhere
- "governor `performance`" — methodology Commitment #1 ✓
- "turbo off" — methodology Commitment #2 ✓
- "`cset` reset" — no mention of cset anywhere on methodology page
- "≥5 reps median" — methodology Commitment #4 says "≥20 outer repetitions" with only the demo-04 exception explicitly called out

"the headless capture rules" — no mention of "headless" anywhere on methodology page.

So a reader who clicks the methodology link to verify "unchanged from demos 1–5" finds that three of the seven items named here aren't documented on the linked page (shielded, cset, headless), one contradicts it (≥5 vs ≥20), and one (≥5) effectively asserts a methodology _change_ while claiming the methodology is unchanged. This is internally self-contradictory.

**Fix:** Make the claim true. Either update the methodology page to cover the new items (preferred — see also M-10) or drop the "unchanged from demos 1–5" framing and just state demo 6's capture conditions as a self-contained list.

---

### M-6 — Demo 6: only post in the set with no opening lede paragraph

**Location:** `06-aos-vs-soa.mdx:1–7`

**Problem:** Every other post opens with prose between frontmatter and the first `## heading`:

- Demo 1 line 7: "Same code. Same data values. Same compiler flags. Yet one version runs..."
- Demo 2 line 7: "Same algorithm. Same fill stream. Same machine. Two versions of a single struct..."
- Demo 3 line 7: "Same pricing model. Same input chain. Same machine. Four implementations..."
- Demo 4 line 7: "A market-data thread produces 16-byte ticks; a strategy thread consumes them..."
- Demo 5 line 7: "A market-data thread hands off 64-byte Orders to a risk thread..."

Demo 6 opens straight to `## The setup` with no in-body framing paragraph. The frontmatter `summary` does some of the work, but the summary is meta — it appears in card listings and SEO contexts — not the in-post lede. The result: demo 6 reads as if the article hasn't started yet when the first `##` heading appears. This is also the structural shape that triggered the pre-demo-5 L-8 finding (the opening "Same X. Same Y. Same Z." rhythm in demos 1–3 isn't a constraint demos 4–6 follow, but at least 4 and 5 still have a framing paragraph before the first section).

**Fix:** Add a 2–4 sentence in-body lede after frontmatter and before `## The setup`. The summary line is a good seed but the lede should expand it and make a concrete claim (e.g., echo the "no crossover, just a cliff" framing that the §The thesis section makes — pulled up to the lede slot so the reader meets it before getting to the benchmark plumbing).

---

### M-7 — Repetition-count disclosure drift continues across all six posts

**Location:** All six posts' footers and bodies.

**Problem:** Same pattern flagged in pre-demo-5 M-6, now extended:

| Demo | Rep count disclosure                                     |
| ---- | -------------------------------------------------------- |
| 1    | silent (footer says "median ns/iteration", no count)     |
| 2    | body line 122: "across 20 repetitions"                   |
| 3    | silent                                                   |
| 4    | body line 261: "across all 30 runs"                      |
| 5    | body line 78: "5 × 1M items per variant"                 |
| 6    | footer + body: "≥5 outer repetitions" / "≥5 reps median" |

Five disclosure conventions across six posts. The methodology page commits to ≥20 as the norm and calls out demo 4 (5 × 1M) as the only exception. So:

- Demo 2 (20 reps) matches the methodology norm
- Demo 4 (30 runs in post / 5 × 1M in methodology) — disclosures themselves contradict each other
- Demo 5 and demo 6 are silent exceptions not covered by the methodology page

**Fix:** Bring all six posts to a single shorthand. Suggested: every footer states reps inline (e.g., "5 outer reps × 1M items" for demo 4, "20 repetitions" for demo 2, "≥5 outer repetitions" for demo 6). Pair with M-10 below: update the methodology page Commitment #4 to acknowledge that the rep-count convention varies and that each post's footer states its own.

---

### M-8 — "Reproducing this" section presence is now inverted from the pre-demo-5 state

**Location:** All six posts.

**Problem:** Pre-demo-5 M-2 flagged that "Reproducing this" was present in demos 2 & 3 and absent in demos 1 & 4. Current state:

| Demo | "Reproducing this" section                                          |
| ---- | ------------------------------------------------------------------- |
| 1    | absent                                                              |
| 2    | absent (was present at pre-demo-5 time)                             |
| 3    | absent (was present at pre-demo-5 time)                             |
| 4    | absent                                                              |
| 5    | present (lines 169–181, with build commands + GitHub source link)   |
| 6    | absent (only "Reproduce via .../README.md" as plain text in footer) |

The pre-demo-5 cleanup brief proposed canonicalising by _removing_ "Reproducing this" from all posts (so reproduction guidance lived only on the methodology page). That clearly happened for demos 2 & 3, but demo 5 then re-introduced the section and demo 6 partially re-introduced it via the footer line "Reproduce via `bench/demos/06-aos-vs-soa/README.md`". The convention is unsettled.

**Fix:** Decide. Either:

- (a) every post has a "Reproducing this" section with build commands and source link — backfill 1, 2, 3, 4, 6;
- (b) only the methodology page has reproduction guidance — drop demo 5's section and demo 6's footer line.

Recommendation: (b), since the post bodies are tight and the methodology page already exists as the canonical location. Drop demo 5's section, drop demo 6's footer phrase. Add a one-line "see /methodology for build/reproduce instructions" to the methodology link in each footer if needed.

---

### M-9 — Demo 6: "no visible step between L1 and L2" isn't supported by the data

**Location:** `06-aos-vs-soa.mdx:87`

**Quote:**

> _There is no visible step between L1 (the smallest working sets) and L2, and no visible step within L3._

**Problem:** Following from M-3: the JSON's smallest N is 4096, which is exactly the L2 capacity. There are no L1-resident measurements (which would require N ≤ 256 for AoS at K=1: 256 × 128 B = 32 KB = L1d). So the claim "no visible step between L1 and L2" is unsupported — the L1→L2 transition isn't in the data. The "no visible step within L3" half of the claim _is_ supported (N=8192 → 65536 all land at 1.48–1.51 ns, near-flat).

This matters because the thesis at line 21–26 rests partly on the "cache hierarchy is binary in practice" framing. If only the L2→L3 boundary was measured cleanly, the right statement is "the L2 boundary costs ~15% and the L3 boundary costs 4×". The L1→L2 transition is also conjectured-invisible at line 24 — "Crossing the L2 boundary on the way in costs ~15% and is barely visible" — but "on the way in" reads as "from L1 to L2", which isn't measured. (Reading the chart it looks like the 15% is in fact the L2→L3 cost; if so, "on the way in" is a confusing phrasing.)

**Fix:** Either run a sub-L2 measurement (N ∈ {128, 256, 512, 1024, 2048} for AoS K=1 = 16 KB through 256 KB working set) and check the L1→L2 transition explicitly, or rephrase the thesis: "L2 and L3 boundaries differ by an order of magnitude in their cost; the L1 boundary isn't measured here." The cliff-not-staircase thesis still holds with just the L2 and L3 transitions.

---

### M-10 — Methodology page is stale relative to demos 5 and 6

**Location:** `site/src/app/methodology/page.tsx` — Commitment #4 block.

**Quote:**

> _Each benchmark runs ≥20 outer repetitions (Google Benchmark `--benchmark_repetitions`); aggregates are computed across those repetitions. The SPSC-queue demo (#04) instead captures 5 runs × 1 M timed enqueue→dequeue pairs through a custom latency pipeline, since the tail-latency distribution it reports requires per-sample timing rather than per-repetition aggregates._

**Problem:** Two unstated exceptions now exist:

- Demo 5 also uses 5 runs × 1M items per variant (line 78). Justified by the same tail-latency argument as demo 4 but not documented as such on the methodology page.
- Demo 6 uses ≥5 outer repetitions for steady-state median (line 59, line 206). The custom-latency-pipeline justification doesn't apply — demo 6 reports `ns_per_op` median, not tail percentiles. So it's a third convention without a documented reason.

Aside: the methodology page is also out of date on Commitment #3 in one respect — it documents `isolcpus=0-7` boot params with cpu0 carrying kernel work, which matches demos 1–5 footers. Demo 6 (per C-5) introduces "shielded core" and "cset shield --reset" which the page doesn't cover.

**Fix:** Update Commitment #4 to acknowledge that latency-distribution demos (currently 4 and 5) capture 5 × 1M timed samples, and that scan-throughput demos (currently 6) report ≥5 outer repetitions of `ns_per_op`. Then a reader can pattern-match any future demo's footer rep-count against a small enumerated set of conventions. Pair with M-7's per-footer disclosure; the page provides the menu, the footer picks an item.

---

## Low-severity findings

### L-1 — Demo 6: "L3 boundary minus a margin" is the wrong direction

`06-aos-vs-soa.mdx:84` table row notes column: "Mid-cliff — L3 boundary minus a margin"

N = 131,072 × 128 B = 16,777,216 B = 16 MB = the L3 capacity of CCX1 exactly. "Minus a margin" implies the working set is _below_ L3 capacity; at N=131,072 the working set is _at_ L3 capacity, with the next sweep point (N=262,144 = 32 MB) firmly past it. "L3 boundary" or "L3 capacity exactly" is right; "minus a margin" is wrong-direction. (See also C-2; both findings on the same row.)

Fix: change to "L3 boundary" or "L3 capacity, mid-cliff".

---

### L-2 — Demo 6: K=4 row ratio doesn't quite match

`06-aos-vs-soa.mdx:143` K-sweep table, K=4 row: claims AoS / SoA = 1.36×. JSON: AoS K=4 N=1M median = 4.133; SoA K=4 N=1M median = 3.156; ratio = 4.133 / 3.156 = 1.31×. Off by 0.05, or 4% of the claimed value. The K=1, K=8, K=16 ratios all match the JSON to two decimal places.

Fix: change 1.36× to 1.31×, or check whether the ratio is computed from a different stat (e.g. mean across iterations vs median across iterations). The other rows are computed from medians and they match.

---

### L-3 — Demo 6: "CCX 1" with space vs "CCX1" without

`06-aos-vs-soa.mdx:187`: "Single thread, pinned to core 4, CCX 1, 16 MB L3 to itself."

vs demo 4 footer line 263 "(same CCX1)", demo 5 footer line 195 "(all CCX1)", demo 5 body line 51–54 ("CCX1"). Demo 2 uses "CCX0" and "CCX1" (line 113) without a space. The JSON notes field for demo 6 itself uses "CCX1". So demo 6 line 187 is the one outlier. Trivial.

Fix: change "CCX 1" to "CCX1" for consistency.

---

### L-4 — Demo 6 vs demo 5: setup-section heading name

Demo 6 line 32 uses `## The benchmark` for the section that lays out the struct + variants + sweep parameters. Demo 5 uses `## Setup` (line 15) for the equivalent slot. Demo 4 uses `## Setup` (line 9). Demo 2 uses `## The setup` (line 13). Demo 1 uses `## The code` (line 11) and the setup info is distributed across several short sections.

Pattern: "Setup" or "The setup" is the prevailing convention; demo 6's "The benchmark" is an outlier. Minor.

Fix: rename to "## The setup" to match demo 2 (or "## Setup" to match demo 5). Either canonical form works; current outlier doesn't.

---

### L-5 — Demo 6: `struct_field_count: 16` in JSON vs "Twelve named fields" in prose

`06-aos-vs-soa.json` records `struct_field_count: 16` on every record. The post prose at line 51 says "Twelve named fields, two 64 B cache lines per element". Both are correct under different definitions — the struct has 12 _named_ members + 24 B of padding, and the layout supports 16 × 8-byte slots within the 128 B struct. But a reader who compares the JSON to the post sees mismatched counts.

Fix: rename the JSON field to `struct_slot_count: 16` (or `struct_eight_byte_slots`) to disambiguate; or add a parenthetical to the JSON `notes` field. Or have the prose acknowledge both numbers ("twelve named fields plus padding; the benchmark treats the struct as sixteen 8-byte slots, with K wrapping past field 11 to slot 0"). Pure metadata cleanup; doesn't affect any rendered output.

---

### L-6 — Demo 6: footer "Reproduce via ... README.md" is plain text, not a link

`06-aos-vs-soa.mdx:206`: "Reproduce via `bench/demos/06-aos-vs-soa/README.md`."

Demo 5 line 64 and 179 use the form `[\`bench/calibration-notes/README.md\`](https://github.com/GarethCooke/Crucible/blob/master/bench/calibration-notes/README.md)` — clickable. Demo 6's reference is plain monospace, no link target. A reader sees the path and has to manually navigate. Trivial.

Fix: link the path to the GitHub URL. (Couples with C-1: use the right repo name.)

---

### L-7 — Demo 6: a couple of self-congratulatory phrasings

`06-aos-vs-soa.mdx:17`: "What it has instead is more interesting."
`06-aos-vs-soa.mdx:106`: "This is the headline result and it survives every sanity check the calibration ran."

Both lean slightly into "trust me, this is good" territory. The first is "more interesting [than the expected crossover]" — fine in isolation but slightly weak as a transition. The second is unsupported by any inline detail (which sanity checks?) and could read as filler.

The previous cross-read flagged L-5 in demo 4 ("conflating them was the main flaw in an earlier version of this measurement") for a similar reason. Demo 6 isn't as bad — these are softer — but the voice does shift slightly from the declarative-and-measured tone the prior demos maintain.

Fix: line 17 could become "The data has no crossover. The mechanism is different." (Drops the value judgment.) Line 106 could just be removed; the headline number already speaks. Or replace with one concrete sanity-check that _was_ run (e.g. "Repeated five times across two reboots, IQR/median ≤ 1.7% at every measurement point.")

---

## Cross-cutting observations (not findings)

**The numerical core of demo 6 is sound.** The headline AoS/SoA ratio (6.98×), the model-vs-measurement gap (8× vs 7×), the LLC miss ratio (~100×), the SIMD speedups (3.99× and 2.52×), the K-sweep ratios at K=1, 8, 16 — all round-trip cleanly against the JSON. C-2 (the 3.72 vs 3.41 row) and L-2 (1.36× vs 1.31×) are the only numerical disagreements I found and both are bounded to single table cells. The reasoning chain — bytes-touched model → cache-tier transition → "moving the workload up a tier" — is the strongest piece of analysis in any of the six posts.

**Demo 6's framing is the most ambitious of the six.** The thesis sentence at line 26 ("a layout decision that lives at the L3 boundary. Below L3, layout doesn't matter much... Above L3, layout is the difference between an L3-resident scan and a DRAM-bound one") is one of the cleanest engineering takeaways in the series. The §SIMD section pushing back on "vectorise to go faster" intuition is also distinctive. These are real signals of the post being a step up. They also make the prose-vs-data slips above more conspicuous than they'd be in a lower-stakes demo.

**Cross-link density in the series is up.** Demos 1 and 3 now have forward links to demo 6 (matched against the demo-06-plan §7 commitment); demo 6 has backward links to demos 1, 3, 4 (the C-4 finding above notwithstanding). The pre-demo-5 cross-read flagged that the posts read "as four posts, not a series"; the new links materially change that. Demo 4 doesn't link to demo 6, and demo 2 doesn't either — both are reasonable (no obvious connection from queue-tail-latency or false-sharing to AoS/SoA); not a finding, just an observation.

**The index page state on the feature branch.** Verified: the index renders six cards, demo 6 has no "In Progress" pill, demo 5 has no pill either. The demo-06-plan task §7's "Remove `status: 'in-progress'` and `expectedAt`" commitment is satisfied. Card 6 shows the correct summary; date is 2026-05-24.

**Methodology page coverage of demo 6.** Already partly stale (see M-10). Once C-5 and M-5 are resolved, the page should also gain a one-line note about scan-throughput benchmarks (demo 6's pattern) running with fewer outer repetitions than the latency demos.

**The CCX1 specificity discussion (pre-demo-5 L-7) has effectively settled.** Demos 4, 5, 6 all converge on "if we pin to a specific CCX, it's CCX1, and we say so". Demo 2 stays generic for the body of its discussion but names CCX0/CCX1 in the architecture explanation. That's an acceptable equilibrium — the previous recommendation (go generic everywhere) hasn't been applied, and the alternative convention is now consistent. No new finding here; calling it settled.

---

## Recommendations

### Quick fixes (one CC pass)

Bundle into a single cleanup brief. All are 1–3 line text edits or small JSON-link replacements, all are well-defined:

- C-1 (your-handle → GarethCooke)
- C-2 (3.72 → 3.41, and fix the row's notes column)
- C-4 (link target demo 4 → demo 5 or demo 2)
- C-5 (drop cset references from demo 6 body+footer, **or** add cset note to methodology page — see Structural decisions)
- M-1 (rephrase IQR/median claim)
- M-2 (drop "1k" from N set, drop "150 cells, 135 retained")
- M-3 ("128 KB through 128 MB" → "512 KB through 128 MB", "L1 through deep DRAM" → "L2 through deep DRAM")
- M-4 (rebuild footer to demo-5-shape with the headless addition)
- M-5 (rewrite the "unchanged from demos 1–5" sentence)
- M-6 (add 2–4 sentence lede paragraph)
- M-9 (drop "L1 (the smallest working sets)" reference, or restate as "L2 floor")
- L-1 ("minus a margin" → drop or "L3 boundary")
- L-2 (1.36× → 1.31×)
- L-3 ("CCX 1" → "CCX1")
- L-4 ("The benchmark" → "The setup" or "Setup")
- L-6 (link the README path)
- L-7 (light tonal trim, two lines)

Suggested filename: `pre-demo-6-hostile-cross-read-cleanup-brief.md`.

### Structural decisions (need user input before scoping)

- **C-5 + M-5 + M-10**: methodology-page cset/headless/rep-count update. Three options:
  - (a) Keep the methodology page authoritative on isolation and reps; update it to acknowledge `cset shield --reset` as a kernel-state-cleanup precondition + headless boot + the new rep-count exceptions for demos 5 and 6. Demo 6's body and footer keep their references and the methodology link backs them.
  - (b) Treat the cset/headless/rep-count claims in demo 6 as drift; remove them from demo 6 to bring it back into line with the methodology page.
  - (c) A mix — methodology page updated for headless and rep-counts (which are real, durable facts), demo 6 drops cset references (which are operational housekeeping not load-bearing for the science).
    Recommendation: (c). It minimises disclosure that doesn't carry interpretive weight, and updates the methodology page on the things a reproducer actually needs to know.

- **M-7 + M-8**: rep-count disclosure canonicalisation and "Reproducing this" section canonicalisation. Both are the same shape as the pre-demo-5 M-3 / M-6 questions and could be picked up in the same brief. Recommendation: pick one rep-count format and one Reproducing-this location, apply to all six posts in a single pass.

### Verification needed

- C-3 (broken `§SIMD` anchor) requires checking whether the MDX pipeline auto-slugs h2 ids. If a one-line rehype-slug add is feasible, do it; otherwise drop the §SIMD link syntax and inline the references. Decision is a CC + user judgment call.
- L-5 (JSON `struct_field_count: 16` vs prose "Twelve named fields") needs a decision on whether the JSON field is renamed (touches the harness output schema and any other consumers) or the prose adds a clarifying sentence.

### Defer

- L-7 (self-congratulatory phrasing) is small enough to fold into the cleanup brief if CC has bandwidth, otherwise leave for a future polish pass. Not blocking.

### Pieces task 8 explicitly _didn't_ surface

For the record, the back-to-back read found:

- **No statistical-convention contradictions.** Demo 6 reports median throughout, with IQR for spread; the methodology-page commitment #4 allows this. M-1 is a "stated dispersion is wrong" finding, not a "wrong statistic" finding.
- **No Zen 2 / CCX factual contradictions.** Cache sizes (32 KB L1d, 512 KB L2, 16 MB L3 per CCX), AVX2 µop-split note (line 57 references demo 3, consistent), Infinity-Fabric framing (line 187 mentions it via cross-link to demo 4) are all internally consistent with the other five posts. The only CCX-related issue is the cross-link target (C-4), not a fact about Zen 2.
- **No tonal whiplash.** Demo 6's voice matches demos 4 and 5 — declarative, willing to disclose what didn't work. The two phrasings flagged in L-7 are bounded, not pervasive.
- **No major numerical inconsistencies between the JSON and the prose.** C-2 is one cell in the headline table; L-2 is one ratio in a five-row table; everything else round-trips clean. The wall-time and LLC-miss numbers in the §Bandwidth amplification section, the SIMD speedups, the bytes-touched-model column, the K=1/K=8/K=16 ratios — all match the JSON.
- **The cross-link from demo 1 (the new forward link added per demo-06-plan §7) works correctly.** Demo 1 line 149 "is also the headline picture in [Demo 6](/posts/06-aos-vs-soa)" lands on the right page. Demo 3 line 246–247 similarly works.

In other words: the post's analytical core is solid and the cross-links it added land correctly. The findings here are the layer between "demo 6 in isolation passes its own review" and "demo 6 sits cleanly alongside demos 1–5 and the methodology page."

---

## Stop condition for task 8

This findings doc closes task §8 of `demo-06-plan.md`. Triage (the next-step half) is:

1. User decides on the C-5 / M-5 / M-10 methodology-page-update question (recommendation: option (c) above).
2. User decides on M-7 / M-8 canonicalisation scope — accept the cross-cutting work or defer.
3. Opus writes the demo-6 cleanup brief covering C-1, C-2, C-3, C-4, M-1 through M-9 (excluding M-10 if user defers methodology-page work), and the low-severity items the user wants folded in.
4. CC applies the brief.
5. Re-run a smaller "did the fixes land cleanly" pass against the feature-branch deploy.
6. Mark task §8 ☑.

After which §9 (pre-merge review) and §10 (merge) remain.
