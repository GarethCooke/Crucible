# Crucible — Demo 07: std::flat_map vs hash map — the no-crossover result

Implementation brief for Claude Code. Lands on the demo-7 feature branch and replaces the teaser stub on merge to `main`. The bench and headline capture are already done; this brief drives §7 of `demo-07-plan_1.md` (the MDX post itself), plus the small surrounding work the pilot's outcome forces.

## Context

Seventh demo in the Crucible series. Builds on:

- `BRIEF.md` — locked schema, methodology, reference machine, `cset shield --reset` precondition (hoisted at demo 6 close-out).
- `crucible-handover.md` — per-demo process and lessons from demos 1–6.
- `demo-07-plan_1.md` — the tracking doc this brief lives under. §0/§1/§3/§6 are complete; §5 (chart-component check) and §7 (MDX) are this brief's focus.
- Demo 6 (cache staircase) — provides `<TimeVsN>` with cache-tier band markers. This demo reuses that component directly for the headline chart, and extends it with `xAxis="modify_pct"` for the modify-mix sensitivity chart (the demo 6 plan flagged this small extension as expected).
- Demo 1 (branch prediction / cache hierarchy intro) — the post forward-links to demo 1's cache-hierarchy framing and back-links from there.
- `site/src/data/perf/07-flatmap-vs-hashmap.json` — the captured headline data (160 runs: 70 lookup + 90 modify_mix; 5 variants; captured 2026-05-26 on the reference machine, headless boot, `cset shield`, turbo off, governor=performance).

The existing `site/src/posts/07-flatmap-vs-hashmap.mdx` is the in-progress teaser stub committed on `main` at §0. Its current thesis paragraph ("the interesting question isn't whether the crossover exists; it's where it sits") **does not survive contact with the data** — see the next section. The teaser stub is replaced wholesale by this brief; no incremental editing of the teaser's prose. CC starts from the demo 6 post's section structure and writes the demo 7 post fresh against the JSON.

When the feature branch merges to main, the merge replaces the stub MDX with the full post and removes the `status: "in-progress"` and `expectedAt` frontmatter fields. Per-branch Amplify preview is used for chart-render review during development; merge to main only after §8 and §9 of the plan are clean.

## The pilot resolved with a thesis reframe

The plan anticipated this. `demo-07-plan_1.md` §1 explicitly says: *"if the crossover sits at N < 8 (yawn) or N > 10K (overclaim), the thesis reframes before the brief commits."* The data resolves further than that: on this machine, with these implementations, **there is no crossover in the swept range**. `absl::flat_hash_map` is the fastest variant at every N from 8 to 4 M, in both pure-lookup and modify-mixed workloads.

The headline picture from `07-flatmap-vs-hashmap.json`:

- On lookup, `absl_flat` is ~3–4× faster than `std_unord` (the second-best) for N ≤ 1 K, narrowing to ~1.6× at N = 4 M as both hash maps hit DRAM. Against the sorted-vector primitives (`sorted_vec`, `boost_flat`), the gap widens with N — ~3× at N = 8, ~13× at N = 1 K, ~24× at N = 4 M.
- On modify-mix at non-trivial N, the sorted-vector primitives collapse. At N = 65536, 90% modify, `sorted_vec` and `boost_flat` are ~780× slower than `absl_flat` (~17 µs/op vs ~22 ns/op). This is the most striking number in the dataset; the post should not bury it.
- `std::flat_map` is not present in the variants — `boost::flat_map` was substituted, per the plan's "if libstdc++ doesn't ship a usable `std::flat_map`, fall back" branch. The substitution is load-bearing on the post's framing and must be called out (see Task 7).

The reframed thesis the post should land:

> *On this machine, the "small map → flat structure" folklore does not survive contact with a current open-addressing hash map. `absl::flat_hash_map` wins at every N tested, from 8 entries to 4 million, in both pure-lookup and modify-mixed workloads. Even `std::unordered_map` beats the sorted-vector primitives at small N — the folklore is wrong in a more comprehensive way than the conventional "use flat_map at small N" version of it suggests. And under any modify load at non-trivial N, the sorted-vector primitives degrade catastrophically: their O(N) insert/erase amplifies the modify fraction into 10×–1000× slowdowns. The actionable takeaway is unromantic: reach for `absl::flat_hash_map` by default, regardless of size.*

What the post does **not** claim:

- Not "open-addressing hash maps are fastest on every machine." The Ryzen 7 3800X / Zen 2 / single-CCX context is stated; another machine could move the small-N picture (where absolute differences are nanoseconds).
- Not "every hash map beats sorted vector." This is one open-addressing implementation (`absl::flat_hash_map`) and one chaining implementation (`std::unordered_map`), both with the same hash function (`absl::Hash` — verify, see Open Items). Folly, robin_hood, ankerl, ska::flat_hash_map — all explicitly out of scope and named as future work in "What this doesn't show."
- Not a claim about `std::flat_map`. The variant is `boost::flat_map`; the substitution and its rationale must be in the post.
- Not a claim about cache-cold lookups, contended access, expensive-hash keys (strings), or custom hashers. Steady-state, hot-cache, single-thread, `uint64_t` keys. State this explicitly.

## Tasks

### 1. Frontmatter rewrite — `site/src/posts/07-flatmap-vs-hashmap.mdx`

Replace the existing frontmatter block (lines 1–7) with:

```yaml
---
title: "No crossover: absl::flat_hash_map wins at every N and workload mix"
date: "2026-05-26"
summary: "Five map implementations swept from N=8 to N≈4M on a Zen 2 CCX. The 'small map → flat structure' folklore expected a crossover; the data found none. absl::flat_hash_map is fastest at every N, in both pure-lookup and modify-mixed workloads, and the sorted-vector primitives collapse under any modify load at non-trivial N."
---
```

`status: "in-progress"` and `expectedAt: "June 2026"` are removed. The `date` field is the capture date (`captured_at` in the JSON, truncated to YYYY-MM-DD). Title matches the JSON's `title` field — keep them in sync.

Remove the `<InProgressNotice expectedAt="June 2026" />` element at line 9.

### 2. Thesis section — replace lines 11–15 ("## The thesis" paragraph)

The current thesis ("the interesting question isn't _whether_ the crossover exists; it's _where it sits_") is the pilot-pre-reframe story. Replace it wholesale with the reframed thesis from the "pilot resolved" section above. Keep it to one or two paragraphs — the post's first job is to set the new story straight without preamble.

The voice is the demo 6 voice (terse, claim-first, no throat-clearing). Do not lead with "Surprisingly, …" or "Interestingly, …" — that signals the writer was surprised, which makes the reader question the methodology rather than the folklore. Lead with the claim.

### 3. Setup section — variants, workload, key distribution

After the thesis, a short section that introduces the five variants and the two workloads. Use the JSON's `runs[*].variant` strings as the canonical short names, and provide the human-readable names as a small reference (chart display names will follow this mapping — see Task 5):

| JSON name     | Display name              | One-line description                                  |
| ------------- | ------------------------- | ----------------------------------------------------- |
| `std_map`     | `std::map`                | Red-black tree; node-based; included as baseline.     |
| `sorted_vec`  | `std::vector<pair> + lower_bound` | Sorted contiguous primitive.                  |
| `boost_flat`  | `boost::flat_map`         | Library wrapper over the sorted-vector primitive.     |
| `std_unord`   | `std::unordered_map`      | Chaining hash map; `absl::Hash` as hasher.            |
| `absl_flat`   | `absl::flat_hash_map`     | Open-addressing hash map; `absl::Hash` as hasher.     |

Workload description (one paragraph), sourced from the JSON's `notes` field:

> *Two workloads. **Lookup**: 4096-entry cyclic index over a populated map, 100% hit rate, steady-state, hot cache. **Modify-mix**: steady-state erase+insert at a configurable modify fraction (0%, 10%, 25%, 50%, 75%, 90%). Keys generated by `mt19937_64(seed=42)` with distinctness via `unordered_set`; op sequence by `mt19937_64(seed=1337)`. 5 outer repetitions per cell; reported number is the median of repetitions.*

The `notes` field in the JSON is the source of truth for this paragraph — derive from it, don't paraphrase loosely.

### 4. Headline chart — `<TimeVsN>` lookup sweep

One chart, log-log axes, all five variants on it. Read from `07-flatmap-vs-hashmap.json` filtered to `workload === "lookup"`. X axis is `n` from 8 to 4 194 304 (14 points); Y axis is `ns_per_op.median`. Use the cache-tier band markers from demo 6 — L1 / L2 / L3 / DRAM, sourced from the reference machine's actual sizes (32 KiB L1d, 512 KiB L2, 16 MiB L3 per CCX; verify against `lscpu --caches` on the reference machine, do not hardcode from memory — see Open Items).

Cache-band purpose on this chart: the bands explain *why* the curves bend where they do. The hash-map curves bend gently at L2 → L3 (still under 10 ns/op); the sorted-vector and std::map curves bend hard at the same boundaries because each lookup traverses more cache lines.

Following the chart, one paragraph that points the reader at what to see — written from the JSON, not from this brief:

- `absl_flat` floor sits near the L1 hit cost across most of the small-N range; it doesn't degrade meaningfully until N crosses out of L1.
- `std_unord` shows the same shape as `absl_flat` but offset upward — chaining vs probing, identical hasher.
- `sorted_vec` and `boost_flat` track each other almost exactly across the entire range (they are the same primitive). At small N the wrapper overhead is invisible; at large N the gap is within measurement noise.
- `std_map` is the worst at large N (node-based, every hop is a likely L2/L3 miss); it is *not* uniformly the worst at small N where the tree fits in L1 and the branch predictor handles the walk well — explicitly call this out.

Numerical claims in this paragraph must derive from the JSON. CC fact-checks every number cited in the prose against `ns_per_op.median` to one significant figure.

### 5. `<TimeVsN>` display-name mapping

`<TimeVsN>` needs a JSON-name → display-name mapping for the legend and tooltips (the JSON uses `absl_flat`, the post should render `absl::flat_hash_map`). Demo 6 had a different variant set; extend the component's display-name table rather than hardcoding per-post mappings. The mapping is in Task 3's table.

If the component currently has variant labels hardcoded inside it, refactor to accept a `variantLabels` prop (an object mapping JSON names to display names). Update demo 6's invocation site to pass its own mapping explicitly — no behavioural change.

### 6. Throughput bars — three discrete N points

Three `<ThroughputBars>` calls, one each at N = 64 (small / L1), N = 4096 (medium / L2), N = 1 048 576 (large / DRAM-bound). Each shows all five variants; bar height is `1e9 / ns_per_op.median` (ops/sec). Read from the lookup runs (`workload === "lookup"`, `modify_pct === 0`).

The point of this chart is to make the *ratios* visible at three distinct cache tiers — the log-log line chart compresses them. Single paragraph after: at every tier the ranking is the same, and the gap between `absl_flat` and the rest changes shape across tiers (widening against the sorted-vector primitives, narrowing against `std_unord` as N grows).

### 7. Modify-mix chart — `<TimeVsN>` with `xAxis="modify_pct"`

The demo 6 plan flagged this as a small extension to `<TimeVsN>`. Add `xAxis="modify_pct"` support if not already present: the X axis is `modify_pct` (linear, 0–90), Y axis is `ns_per_op.median` (log), filtered by a fixed `n`. Render three panels (or three calls) at N = 256, N = 4096, N = 65536 — the three N values the modify_mix workload was captured at.

The chart's job is to make the sorted-vector collapse impossible to miss. At N = 65536, the `sorted_vec` and `boost_flat` lines climb from ~108 ns/op at 0% modify to ~17 µs/op at 90% modify — three orders of magnitude on a log axis, well above the hash-map lines which barely move.

The accompanying paragraph names the mechanism: `sorted_vec` and `boost_flat` are O(N) per insert/erase (shifting elements in a contiguous container); the hash maps are O(1) amortised. The modify_pct axis is effectively dialling up the multiplier on an O(N) operation.

### 8. The `boost::flat_map` substitution paragraph

A short, honest paragraph after the modify-mix chart (or as a side note where it fits naturally). State:

- The post's variant set substituted `boost::flat_map` for `std::flat_map` because libstdc++ at the toolchain version used did not ship a usable implementation. The bench README documents this — link to it.
- `boost::flat_map` and `sorted_vec` are the same underlying primitive (sorted contiguous storage + `lower_bound`); their lookup curves track each other to within noise on the headline chart, which is the empirical confirmation that the substitution doesn't change the story.
- The substitution is named in the title-card framing of the variant table, not buried in a footnote.

### 9. "What this doesn't show" section

A defensive section before the takeaway, listing the explicit scoping decisions:

- Other open-addressing hash maps (folly F14, robin_hood, ankerl, ska::flat_hash_map) are not compared. The story may move materially against any of these — future post.
- Other key types (strings, expensive-hash custom keys, small structs). `uint64_t` keys with `absl::Hash` is the cheapest possible hash; sorted-vector's `lower_bound` cost scales with the comparator, which is also cheap for `uint64_t`. A string-keyed sweep is a different demo.
- Cache-cold lookups. The lookup workload is steady-state with a 4096-entry cyclic index over a populated map; the map structure is hot in cache. A cold-cache pattern would change the picture, especially for `sorted_vec` where `lower_bound`'s sequential reads prefetch well.
- Multi-thread / contended access. Single-thread throughout.
- `std::flat_map` (substituted for `boost::flat_map` — see Task 8). If a future libstdc++ ships a measurably different `std::flat_map`, the comparison may need a refresh.
- Hash function variations. Both hash maps use `absl::Hash`; using the standard `std::hash<uint64_t>` (the identity function) would change `std_unord`'s numbers. The post pins the hasher and says so.
- `std::map`'s small-N edge against `sorted_vec` and `boost_flat`: real, reproducible, but tiny in absolute terms (a few nanoseconds at N ≤ 32). The post mentions it once and doesn't elevate it to a thesis — `absl_flat` still beats `std::map` at every N.

The bar for this section: a skeptical reviewer who already distrusts the methodology should not be able to point at the chart and ask "what about X?" without finding X named here.

### 10. Cross-links

Add forward-links into demo 7 from demos 1 and 6, and back-links from demo 7 to both:

- In `site/src/posts/01-branch-prediction.mdx`: in whatever section introduces the cache-hierarchy framing, add a short forward-link to demo 7 ("the same cache-tier picture shows up again when comparing map data structures — see demo 7").
- In `site/src/posts/06-aos-vs-soa.mdx`: in the post's "what this doesn't show" or takeaway region, forward-link to demo 7 ("the cache-staircase pattern repeats with map data structures — see demo 7").
- In demo 7: back-link to demo 1 in the cache-hierarchy aside, and to demo 6 in the cache-band-annotation paragraph.

Each cross-link is one sentence at most. Do not restructure the predecessor posts; just insert the link.

### 11. Methodology page

`site/src/app/methodology/page.tsx` — if it references a demo count or enumerates the demos, bump to 7 and add demo 7 to the list. If it does not reference a count, leave it alone. `grep -n 'demo' site/src/app/methodology/page.tsx` to confirm scope before editing.

### 12. Index page

The index card for demo 7 must render without the `In Progress` pill after merge (because the frontmatter no longer says `in-progress`). Confirm by loading the dev site after the frontmatter change.

## Acceptance

### Bench / data (verification only — no changes)

- `site/src/data/perf/07-flatmap-vs-hashmap.json` is unchanged from the captured artefact (`captured_at: "2026-05-26T13:02:08Z"`). No re-capture, no re-pretty-printing, no field edits.
- `runs.length === 160`. 70 with `workload === "lookup"`, 90 with `workload === "modify_mix"`.
- Variants set: `["absl_flat", "boost_flat", "sorted_vec", "std_map", "std_unord"]` exactly.
- Lookup sweep: 14 N values per variant (`8, 16, 32, 64, 128, 256, 512, 1024, 4096, 16384, 65536, 262144, 1048576, 4194304`).
- Modify-mix grid: 3 N × 6 modify_pct = 18 cells per variant. N ∈ `{256, 4096, 65536}`; modify_pct ∈ `{0, 10, 25, 50, 75, 90}`.
- `machine` block conforms to the post-patch schema (cpu, cores_*, smt_enabled, ram_*, compiler, kernel, governor, turbo, isolated_cpus, isolated_cpus_requested, isolated_cpus_effective, isolated_cpus_source, cpu_affinity, lscpu_extended) — confirm by structural compare with demo 6's JSON.
- `ns_per_op.max >= ns_per_op.p99` and `ns_per_op.p99 >= ns_per_op.median` for every run (sanity, no demo-4-style regression).

### Site / charts

- `<TimeVsN>` renders the lookup-sweep headline with five variants and cache-tier band annotations. Log-log axes. Display names match the Task 3 table (not the raw JSON snake-case).
- `<TimeVsN>` `xAxis="modify_pct"` mode renders the modify-mix chart at N ∈ {256, 4096, 65536}. The sorted-vector lines extend up to ~17 µs/op at N=65536, pct=90; the chart must not clip them — log-Y axis with sufficient range.
- Three `<ThroughputBars>` for N = 64, 4096, 1048576, all five variants each.
- No console errors on any chart.
- Cross-links from demos 1 and 6 to demo 7 resolve. Back-links from demo 7 to demos 1 and 6 resolve.
- Lighthouse Performance ≥ 90 and Accessibility ≥ 90 on `/posts/07-flatmap-vs-hashmap` (matching demos 1–6).
- Index card for demo 7 renders without the `In Progress` pill.

### Post (prose)

- Frontmatter has no `status` or `expectedAt`. Title matches the JSON's `title` field character-for-character.
- The phrase "where the crossover sits" no longer appears in the post — replaced by the no-crossover framing. `grep -n "where the crossover" site/src/posts/07-flatmap-vs-hashmap.mdx` returns zero hits.
- The phrase "no crossover" or equivalent ("absl_flat wins at every N", "no crossover in the swept range") appears in the thesis section.
- All numerical claims in the prose are derived from the JSON, not this brief. Any sentence asserting an "Nx" ratio matches the JSON's `ns_per_op.median` for the cited cells to one significant figure. CC writes a one-paragraph check note in the PR description listing the cited numbers and the cells they came from.
- The "What this doesn't show" section names at minimum: other open-addressing hash maps (folly / robin_hood / ankerl / ska); other key types (strings); cache-cold lookups; multi-thread; the `std::flat_map` → `boost::flat_map` substitution; the `absl::Hash` pinning.
- The `boost::flat_map` substitution is acknowledged near the variant introduction, not buried.
- Capital-markets framing is at most one paragraph (config maps in trading systems are small; the folklore advice was load-bearing on a real design choice). Do not let it become a recurring drumbeat — this is a data-structures post.
- No internal contradictions: every reference to "N variants" agrees on 5; every reference to "the swept N range" agrees on 8 to ~4M; the sweep-point counts in prose agree with the JSON.

## Out of scope

- Re-running the bench or re-capturing the JSON. The data is locked. Any "improvement" to the bench invalidates the headline picture.
- Any modifications to `bench/demos/07-flatmap-vs-hashmap/` source. The bench is shipped as-is. If a bench bug surfaces during the post write, flag it — do not fix it in this brief.
- Any modifications to demos 1–6 code, JSON, or prose **except** the one-sentence cross-link forward-pointer in demo 1 and demo 6 (Task 10). The cross-link is the only edit to demos 1–6 this brief authorises.
- A comparison against folly F14, robin_hood, ankerl, ska, tessil, or any other hash-map library. Named as future work in "What this doesn't show."
- A comparison against `std::flat_map` once libstdc++ ships it. Same — named as future work.
- A string-keyed sweep, a small-struct-keyed sweep, or any expensive-hash variation.
- A cache-cold or contended-access variant.
- Forking `<TimeVsN>` into a new component. Extend it if needed (`xAxis="modify_pct"` support); do not fork.
- Any change to the locked schema or to `BRIEF.md` / `crucible-handover.md`.
- Hostile-reviewer cross-read (§8 in the plan) and pre-merge review (§9). Those are separate Opus passes after this brief lands.

## Open items for CC to flag

1. **`absl::Hash` pinning on `std::unordered_map`.** The plan committed to pinning `absl::Hash` as the hasher for both `std_unord` and `absl_flat` to factor out hash-function differences. Verify this in `bench/demos/07-flatmap-vs-hashmap/` source — search for the type alias or template parameter where `std::unordered_map` is instantiated. If it uses `std::hash<uint64_t>` (the identity) instead of `absl::Hash`, **stop and flag** — that is a confounding variable. The post's framing depends on this control being in place. The JSON does not record the hasher, so this is an out-of-band confirmation step.

2. **`boost::flat_map` substitution rationale.** Confirm the bench README (`bench/demos/07-flatmap-vs-hashmap/README.md` or equivalent) documents why `boost::flat_map` was used in place of `std::flat_map` — toolchain version, the specific libstdc++ version that lacks it, the date checked. If the README does not document this, draft a one-paragraph addition for it as part of this brief's work and surface it in the PR. The post (Task 8) links to that README.

3. **Cache-tier band sizes.** L1d / L2 / L3 sizes for `<TimeVsN>`'s annotation must match the reference machine's actual sizes (per `lscpu --caches` or `/sys/devices/system/cpu/cpu*/cache`). The Ryzen 7 3800X has 32 KiB L1d per core, 512 KiB L2 per core, 16 MiB L3 per CCX (two CCXs). Do not hardcode from memory; read from a verified source. Convert to the same units as the X axis (entries, given a known sizeof(pair<uint64_t, uint64_t>) = 16 B plus per-implementation overhead). If `<TimeVsN>` takes the bands in bytes vs entries differently than demo 6 invoked it, fix the convention rather than work around it — surface the choice.

4. **modify_mix `pct=0` baseline vs lookup-only.** The JSON has both `(workload=lookup, n=256, modify_pct=0, absl_flat) ≈ 3.55 ns` and `(workload=modify_mix, n=256, modify_pct=0, absl_flat) ≈ 3.00 ns` — a ~15% difference at the same nominal cell. This is presumably because the modify_mix code path with pct=0 still dispatches through a different op-selection routine than the pure-lookup workload. The two are not interchangeable. Charts in Task 4 (lookup headline) must read from `workload === "lookup"`; charts in Task 7 (modify-mix) must read from `workload === "modify_mix"`. Do not mix sources within a chart. If this constraint is awkward in `<TimeVsN>`'s filter API, flag rather than work around it.

5. **`<TimeVsN>` `xAxis="modify_pct"` extension scope.** If extending the component to accept `xAxis="modify_pct"` requires touching its filter / sweep-detection logic in a non-trivial way, surface the diff before merging. Demo 6's plan anticipated "small extension expected" — if it turns out to be larger, that's worth knowing.

6. **Variant ordering on charts.** Choose an ordering that makes the story legible — likely `absl_flat`, `std_unord`, `std_map`, `boost_flat`, `sorted_vec` (fastest first on the lookup headline; clusters the two sorted-vector primitives together; keeps `std_map` between the hash maps and the sorted-vector group). Lock the ordering once and apply it consistently across the headline chart, the throughput bars, and the modify-mix panels — do not let the order shift across charts.

7. **`std::map` small-N quirk.** The data shows `std_map` beating `sorted_vec` and `boost_flat` at N ∈ {8, 16, 32} in pure lookup by a few nanoseconds. This is real, reproducible, and minor. The post mentions it once in the headline-chart paragraph; do **not** turn it into a thesis or a section — it is a footnote-grade observation. If during writing it starts to grow into something larger, that's a signal the post is losing focus.

8. **Cross-link prose voice.** The forward-links from demos 1 and 6 to demo 7 must match the existing voice of those posts — they are mature shipped posts and the inserted sentence should not read as a bolt-on. If the cleanest insertion point isn't obvious, surface two options for the PR rather than guess.

## Notes for CC

- This is a post-rewrite job, not a fresh implementation. The bench is built, the data is captured, the JSON is committed (or will be on this branch). Resist the urge to "improve" the bench while writing the post — any C++ change invalidates the headline picture.
- Write the thesis paragraph first, before drilling into chart specs. The reframed thesis is the post's load-bearing claim; if it doesn't read cleanly in two paragraphs, the rest of the post will be polishing scaffold around a wobbly centre.
- Numerical claims after capture, not before: every "N×" ratio or "X ns" in the prose is derived from the JSON, not from this brief's quoted magnitudes. The brief's magnitudes are anchors for scoping the story; the post's magnitudes are the ground truth.
- The most striking number in the dataset (sorted_vec at N=65536, 90% modify ≈ 17 µs/op, ~780× absl_flat) carries the modify-mix section. Let the chart do the heavy lifting; the prose names the mechanism (O(N) insert/erase × modify_pct) and moves on.
- Section order (adapt from demo 6): hook → thesis → setup (variants + workload) → headline lookup chart → throughput bars → modify-mix chart → mechanism / why → boost substitution → what this doesn't show → reproducing this → takeaway. Length comparable to demo 6.
- The takeaway is unromantic on purpose: "reach for `absl::flat_hash_map` by default." Do not soften it into "consider" or "it depends" — the data does not say "it depends" within the conditions tested. The defensive framing lives in "What this doesn't show," not in the takeaway.
