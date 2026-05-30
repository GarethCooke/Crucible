# Crucible — Demo 08 pre-merge fix brief

Implementation brief for CC, on the demo 8 feature branch, **before** the §10 merge to `main`. It closes the actionable findings in `demo-08-pre-merge-review-findings.md` (plan §9). Companion docs: `demo-08-plan.md` (§9 → §10), `BRIEF.md`, the methodology page, and demos 6/7 as the convention template. All edits are to `site/src/posts/08-sorting-shootout.mdx`, `site/app/methodology/page.tsx`, and the bench README — nothing else.

## Context

The pre-merge review re-derived every prose number from `site/src/data/perf/08-sorting-shootout.json`; **all numbers are correct**, so this brief touches no JSON and no figures. What remains is one render-and-verify check on the charts, a set of prose/footer consistency edits with exact quote-and-replace text, the methodology demo-list bump, and the vendored-dependency disclosure the plan required. Two findings (footer pinning wording, `-DNDEBUG`) are capture questions for the user, not CC edits — see Preconditions.

Correction to the review: the findings doc says "four charts" in C-2; the post has **two** data charts — one `<TimeVsN>` (L42) and one `<ThroughputBars>` (L66). The `<CodeCompare>` at L21 is code, not data. Task 1 is scoped to those two.

## Preconditions (user — verify before the gated edits)

These gate Task 6 only. The rest of the brief is independent of them.

- **P1 — pinning wording (review M-5).** The footer says "single thread pinned to **core 4** (CCX1)"; the JSON `machine.cpu_affinity` is **"4-7"** (the `cset` shield set). Confirm whether the capture additionally pinned the single-threaded process to one core (e.g. `taskset -c 4`) inside the shield, or left it free across 4–7. **If single-core-pinned:** the wording is correct; Task 6 applies the punctuation fix only. **If free-floating:** do not keep "core 4" silently — either reword to "CCX1 (cores 4–7)" (matching demo 7's footer) or schedule a recapture pinned to one core (matching demo 6's sweep convention). CC applies whichever the user states; absent a decision, leave the pinning wording unchanged and flag (see Open items).
- **P2 — `-DNDEBUG` (review L-7).** The JSON `compile_flags` is `-O3 -march=native -std=c++20`, with no `-DNDEBUG`, where demo 7 recorded it and the methodology Release recipe implies it. Practical risk is low here (libstdc++ `std::sort` asserts are gated on `_GLIBCXX_ASSERTIONS`, not plain `NDEBUG`; orlp's `pdqsort` has no hot-path asserts). This is a capture/recapture decision for the user, **not** a CC edit. If the user is content, no action — the footer correctly reflects the flags as captured.

## Tasks

### 1 — Verify both charts render against the JSON (review C-2)

Render demo 8 locally and open `/posts/08-sorting-shootout`. Confirm both data charts populate with non-empty series:

- `<TimeVsN>` (L42): three lines (`std_sort`, `pdqsort`, `radix_lsd`) on **random u32 keys only** — the 3 u64 cells and the four non-random distributions excluded.
- `<ThroughputBars distGrouped>` (L66): the three variants grouped across all five distributions at N = 4,194,304, **u32 only**.

These charts use four props with no precedent in demos 1–7: `distributionFilter`, `keyTypeFilter` (both charts), `distGrouped`, and `stat` (bars). The JSON carries `distribution`, `key_type`, and `ns_per_op.median` per run, so the filters map to real fields. Confirm in the chart-component source that all four props are actually read. If they are and both charts render correctly → done. If a prop is silently ignored or a chart renders empty/mixed → **Open items** (do not improvise a grouped-bar view).

### 2 — Reconcile the radix cache-knee paragraph (review M-2, L-5)

In `08-sorting-shootout.mdx`, replace the entire paragraph beginning `**The cache knee on the radix line.**` (L58) with:

> **The cache knee on the radix line.** Setting aside the small-N bump discussed below, radix climbs gently from ~7–8 ns/element in the L1/L2 region to ~11–12 by a few hundred thousand keys, then bends upward to ~15 at the right edge of the sweep. The bend sits just past four million keys, and four million 32-bit keys is 16 MB — the size of this machine's L3 slice. Past that point the scatter writes spill to main memory and radix becomes bandwidth-bound rather than compute-bound. The comparison sorts don't show this knee nearly as clearly, because their `log n` growth swamps it. The band markers — the same cache-tier bands [demo 6](/posts/06-aos-vs-soa) and [demo 7](/posts/07-flatmap-vs-hashmap) introduced — sit on the radix line for that reason: it's the one variant whose curve is shaped by the cache hierarchy rather than by its own asymptotics. The markers mark the single-array footprint, and that needs a qualification in each direction. At small N, radix's ping-pong scratch buffer doubles its working set, so it hits the lower tiers earlier than the markers suggest — that's the bump just left of the L1 band in the next paragraph. At the L3 boundary the doubling does _not_ move the knee: the two arrays are streamed sequentially rather than held resident together, so the single-array 16 MB footprint is the line that bites — which is why the knee sits at four million keys, not at two.

Rationale (do not include in the post): the data shows radix's L3 spill at 4 M (12.2 → 14.1 ns between 4 M and 8 M), and radix still flat at 2 M (11.4) — so the single-array attribution is correct, but the post must explain why the doubling that governs the L1 bump doesn't move the L3 knee. The floor is also not flat at 11; it's ~7.6 at 32 K rising to ~12 at 4 M.

### 3 — Disclose the vendored `pdqsort` dependency (review M-3)

In the "Reproducing this" section (L104), find:

> The benchmark harness, the radix implementation, and the capture script are in the repository under `bench/demos/08-sorting-shootout/`.

Append, in the same sentence-flow:

> `pdqsort` is Orson Peters' pattern-defeating quicksort, vendored into that directory as a single header under the zlib licence.

### 4 — Defuse the demo-1 cross-link comparison (review M-4)

At L100, find:

> and this post measures its _price_.

Replace with:

> and this post measures its _price_. (Demo 1's one-second sort is on its small-range keys — `std::sort`'s easy case; the ~5× headline here is against random keys, the hard one. Same operation, opposite end of the input-shape sensitivity this post is about.)

### 5 — Editorial fixes in the key-width paragraph (review L-4, L-6)

In the paragraph at L89, two replacements:

- **L-4** — find `The crossover lives in the key width:` → replace with `The balance tips on the key width:`
- **L-6** — find `so the linear cost doubles while the comparison sorts grow only with` → replace with `so radix's pass count doubles — and because the wider keys move twice the bytes per pass, its measured per-element cost nearly triples — while the comparison sorts grow only with`

After this, `grep -c crossover 08-sorting-shootout.mdx` must return `0`.

### 6 — Footer: punctuation + Source line (review L-1, L-7-punctuation; gated on P1 for pinning)

In the footer machine-spec line, find `single thread pinned to core 4 (CCX1). Headless Ubuntu 24.04.` and replace with `single thread pinned to core 4 (CCX1), headless Ubuntu 24.04.` — comma and lowercase, matching demos 6/7. **If P1 resolves to free-floating**, substitute the pinning wording per the user's decision in the same edit; otherwise leave "core 4" as written.

Then add a `*Source:*` line between the machine-spec italic line and the `*[Methodology →]*` line, matching demos 6/7:

> _Source: [`bench/demos/08-sorting-shootout/`](https://github.com/GarethCooke/Crucible/tree/master/bench/demos/08-sorting-shootout) · [JSON](https://github.com/GarethCooke/Crucible/blob/master/site/src/data/perf/08-sorting-shootout.json)._

### 7 — Chart labels, titles, axis (review L-3)

Add display props to both charts to match the demo 6/7 bar. Use this label map on **both**:

> `variantLabels={{ std_sort: "std::sort", pdqsort: "pdqsort", radix_lsd: "LSD radix" }}`

- `<TimeVsN>` (L42): add the `variantLabels` above, plus `yAxisLabel="ns per element"` and `title="Per-element sort cost vs N — random u32 keys, log-log"`.
- `<ThroughputBars>` (L66): add the `variantLabels` above, plus `title="Sort cost across input distributions — N = 4,194,304 (u32)"`.

Keep the existing props (`slug`, filters, `variants`, `thresholdMarkers`, `targetN`, `distGrouped`, `stat`) unchanged. If `variantLabels` / `title` / `yAxisLabel` are not accepted by these components, that is the same component-support question as Task 1 — flag rather than forcing it.

### 8 — Methodology page: add demo 8 to the sweep list (review M-1)

In `site/app/methodology/page.tsx`, Commitment 4, find `<strong>Working-set sweep</strong> (demos 6, 7):` and replace with `<strong>Working-set sweep</strong> (demos 6, 7, 8):`. Leave the throughput ("demos 1, 2, 3") and tail-latency ("demos 4, 5") lists unchanged.

### 9 — Bench README: pdqsort disclosure (review M-3, README half)

In `bench/demos/08-sorting-shootout/README.md`, confirm the vendored-`pdqsort` provenance (orlp, zlib licence) is stated. If absent, add a one-line note matching the JSON `notes` field. **If it is already present, skip this task and say so** — the plan wanted it "in the post and README," and Task 3 covers the post.

## Acceptance

- **Charts (Task 1, 7):** both data charts render with non-empty series; `<TimeVsN>` shows three random-u32 lines, `<ThroughputBars>` shows three variants across five distributions at 4 M, u32 only. Legends read `std::sort` / `pdqsort` / `LSD radix`, not raw keys.
- **Prose (Tasks 2–5):** `grep -c "crossover" site/src/posts/08-sorting-shootout.mdx` → `0`. `grep -c "the linear cost doubles" …` → `0`. The radix-knee paragraph contains the streamed-vs-resident clause. The demo-1 paragraph contains the small-range-keys parenthetical. The "Reproducing this" section names Orson Peters / zlib.
- **Footer (Task 6):** `grep -c "(CCX1), headless" …` → `1`. `grep -c "^\*Source:" …` → `1`, linking both the bench dir and the JSON.
- **Methodology (Task 8):** `grep -c "(demos 6, 7, 8)" site/app/methodology/page.tsx` → `1`; `grep -c "(demos 6, 7)" …` → `0`.
- **Build:** `cd site && npm run build` succeeds; the page renders with no MDX or component errors.
- **No number changed:** `git diff` touches no numeral in the prose. The only edits are the replacements named above.

## Out of scope

- **`site/src/data/perf/08-sorting-shootout.json`** — verified clean; do not touch. No figure in the prose changes.
- **C++ source, the harness, the radix/pdqsort implementation** — no behavioural change in this brief.
- **The index page** — verified separately at merge (§10/§11): demo 8 card links `/posts/08-sorting-shootout`, shows the final title, carries no in-progress pill. Not edited here.
- **Recapturing JSON** — a user task on the reference machine; only relevant if P1 or P2 resolves that way.
- **Demos 1–7 prose, code, or JSON** — the demo-1 edit is in _demo 8's_ file (Task 4); do not edit `01-branch-prediction.mdx`.
- **Any new chart component or grouped-bar view** — if `distGrouped` isn't supported, that's a flag, not a build (Open items).

## Open items for CC to flag

- **If a chart prop (`distributionFilter`, `keyTypeFilter`, `distGrouped`, `stat`, `variantLabels`, `title`, `yAxisLabel`) is not read by the component**, the chart will render empty, mixed, or unlabelled. Do **not** improvise a fix — especially not a bespoke grouped-bar component for `distGrouped`. Stop and report which prop is unwired and what the chart currently shows; plan §5 was supposed to land these, so a gap here means §5 didn't fully ship and needs its own brief.
- **If P1 is unresolved when you reach Task 6**, apply the punctuation fix but leave the "core 4" wording untouched, and flag that the footer pinning wording is pending the user's capture answer.
- **If the radix-knee paragraph (Task 2) no longer matches the rendered chart** — e.g. the chart shows the bend somewhere other than ~4 M — stop and report; the prose was reconciled to the JSON medians, so a mismatch means the chart is reading different data than the review did.
- **If `bench/demos/08-sorting-shootout/README.md` does not exist** (only the post and JSON shipped), flag it rather than creating one — that's a plan-structure question, not a drive-by file creation.
