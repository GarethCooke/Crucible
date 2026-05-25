# Crucible — Demo 07 teaser brief

Companion to `BRIEF.md`, `crucible-handover.md`, `demo-07-plan.md`, and a forthcoming `07-flatmap-vs-hashmap-brief.md` (the implementation brief). This brief lands a small placeholder for demo 7 on the live site so visitors see a seventh post is coming, while the substantive implementation work proceeds isolated on a feature branch.

## Why this brief

Demo 7 (`std::flat_map` vs hash map crossover across the cache hierarchy) follows the same staging pattern as demos 5 and 6: a stub on `main`, substantive work on a feature branch, then merge.

Because the teaser infrastructure already exists — `StatusPill`, `InProgressNotice`, the `status` / `expectedAt` frontmatter fields, and whatever sort logic demos 5 and 6 settled — this brief is substantially smaller than `demo-05-teaser-brief.md`. The only new artefact is the MDX stub file itself.

## Scope

In scope:

- New MDX file at `site/src/posts/07-flatmap-vs-hashmap.mdx` (stub content with WIP frontmatter).
- Index-page render verification: the existing card list now shows seven cards, with demo 7 last and carrying the "In Progress" pill.

Out of scope:

- Any new component (`StatusPill`, `InProgressNotice` already exist).
- Any frontmatter schema change (`status` and `expectedAt` already supported).
- Any change to the index-page sort logic (settled in demo 5; reused unchanged in demo 6).
- Anything under `bench/`.
- Any file under `site/src/data/perf/`.
- Any chart component changes.
- Branch creation, Amplify per-branch preview setup (user steps).
- The substantive demo 7 work itself (separate brief, to follow §1 calibration pilot).

## Changes

### 1. New file — `site/src/posts/07-flatmap-vs-hashmap.mdx`

Frontmatter:

```yaml
---
title: "std::flat_map vs hash map: where the crossover actually sits"
date: "<commit date>"
status: "in-progress"
expectedAt: "July 2026"
excerpt: "Five map implementations swept from N=16 to N≈10⁶ on the same machine. Where does the sorted-vector primitive stop beating the hash map? And does the answer depend on the workload mix more than the size?"
---
```

`date`: set to the actual commit date of the stub PR. The previous demos' stubs all used the commit date, not a forward-dated placeholder.

Body template — wording adjustable, structure is the constraint:

```mdx
<InProgressNotice expectedAt="July 2026" />

## The thesis

Most C++ code reaches for `std::unordered_map` (or, if it's paying attention, `absl::flat_hash_map`) regardless of how many entries the map will hold. For the maps that show up most often in real code — small ones, holding tens to a few hundred entries — that's the wrong default.

When the working set fits in L1, a sorted vector with `std::lower_bound` beats a hash table on cache locality alone. The hash function, the bucket arithmetic, the probe sequence — they're all overhead the sorted vector skips. The interesting question isn't _whether_ the crossover exists; it's _where it sits_ on a real machine, and _how the workload mix moves it_.

## What the post will cover

Five implementations swept from N = 16 to N ≈ 10⁶ on the reference machine, with cache-hierarchy bands (L1, L2, L3, DRAM) drawn on the chart so you can see why the curves bend where they do:

1. `std::map` — red-black tree, included as the worst-case baseline.
2. `std::vector<std::pair<K, V>> + std::lower_bound` — the sorted-vector primitive.
3. `std::flat_map` — C++23's sorted-container adaptor.
4. `std::unordered_map` — the standard hash map most code reaches for.
5. `absl::flat_hash_map` — open-addressing, the current best-in-class for general use.

The headline chart is the time-per-lookup curve across the N sweep, with the crossover where the hash maps start winning. Supporting views: throughput bars at three discrete N (small / medium / large) that show the ranking inverting across scales, and an insert-mix sweep that shows how the picture shifts as the workload moves from pure-lookup toward insert-heavy.

## What makes the post interesting

The "flat structure beats hash map at small N" result is folklore in C++ perf circles but rarely measured precisely. This post puts a number on it for a specific machine, draws the cache-hierarchy bands so you can see _why_ the crossover is where it is, and shows how far the answer moves when the workload mix changes. The actionable takeaway: if your map has fewer than ~X entries (where X depends on key type, workload mix, and machine), the contiguous primitive is the right default — and we'll publish the X.

Expected to ship in July 2026.
```

## Acceptance criteria

- `site/src/posts/07-flatmap-vs-hashmap.mdx` exists with the specified frontmatter and the four-section tease body (`<InProgressNotice>`, "The thesis", "What the post will cover", "What makes the post interesting").
- `npm run build` succeeds with zero new warnings.
- The index page renders seven cards. The demo 7 card is **last** in the listing and carries the existing amber "In Progress" pill near the date — matching the visual treatment used for demos 5 and 6 while in-progress.
- Clicking the demo 7 card navigates to `/posts/07-flatmap-vs-hashmap`.
- `/posts/07-flatmap-vs-hashmap` renders with the post title, the `<InProgressNotice>` callout at the top, and the tease prose. No chart components are present, no JSON is fetched, no console errors.
- Lighthouse Performance ≥ 90 and Accessibility ≥ 90 on `/posts/07-flatmap-vs-hashmap` (matches the bar for the six shipped posts).
- The six existing post cards (demos 1–6) are visually unchanged.

## Out of scope

- Anything under `bench/`.
- Any chart component changes.
- Any JSON creation or modification.
- Component or schema changes — see §Scope. If a regression is found in `StatusPill` / `InProgressNotice` / the sort logic, stop and flag rather than fix inside this brief.
- Feature branch creation, Amplify configuration, per-branch preview deploy setup (user steps).
- The substantive demo 7 work — see the forthcoming `07-flatmap-vs-hashmap-brief.md`.

## Open items for CC to flag

- If the index sort logic settled in demo 5 has drifted since (e.g. demo 6's merge changed it), surface and stop before forcing a fix into this brief.
- If `StatusPill` or `InProgressNotice` no longer behave as `demo-05-teaser-brief.md` specified (renamed, moved, refactored), surface and stop.
- If `npm run build` reports new warnings that don't reproduce on a clean rebuild of the previous tree state, surface — it's likely a toolchain or dependency issue, not something this brief should be patching.

## Notes for CC

- This brief lands on `main` and should be a small, low-risk PR. No data captures, no benchmark builds, no chart changes, no component work. If the PR diff exceeds ~60 lines net, something has scope-crept — most likely a component or schema change that shouldn't be in this brief.
- The stub MDX body is a template. Wording adjustments are welcome; the four-section structure (`<InProgressNotice>` + "The thesis" + "What the post will cover" + "What makes the post interesting") is the constraint.
- The teaser body is pilot-contingent: if §1's calibration pilot reframes the thesis materially (the way demo 6's pilot did), the stub may need a small body edit before the implementation brief is written. That edit, if needed, is a separate follow-up — not part of this brief.
- When the feature branch (`demo-7-flatmap-vs-hashmap` or similar) eventually merges to `main`, the merge will overwrite the stub MDX with the real post and remove the `status: "in-progress"` and `expectedAt` frontmatter fields.
