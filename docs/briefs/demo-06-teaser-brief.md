# Crucible — Demo 06 teaser brief

Companion to `BRIEF.md`, `crucible-handover.md`, and `demo-05-teaser-brief.md` (the precedent for this brief's shape and the source of the components it relies on). The full implementation brief (`06-aos-vs-soa-brief.md`) is still to be scoped — this teaser lands first.

## Why this brief

Demo 6 (AoS vs SoA across the cache-hierarchy staircase) is the next demo in the Crucible series. The user is creating a feature branch (`demo-6-aos-soa` or similar) for that work, with per-branch Amplify preview deployments enabled.

This brief is the small change that lands on `main` *first*: a teaser card on the index page and a stub post page with a "what's coming" tease. Visitors to crucible.garethcooke.com see six cards rather than five, and a "what makes this post interesting" pitch on the demo 6 page. When the feature branch eventually merges to main, its merge replaces the stub MDX content with the real post and removes the `status` and `expectedAt` frontmatter fields.

The teaser infrastructure — `<StatusPill>`, `<InProgressNotice>`, the `status` / `expectedAt` frontmatter fields, the index-page handling for in-progress cards — all landed with `demo-05-teaser-brief.md` and shipped with demo 5. This brief reuses that infrastructure unchanged.

## Scope

In scope:

- New MDX file at `site/src/posts/06-aos-vs-soa.mdx` (stub content with WIP frontmatter).

Out of scope:

- Anything under `bench/`.
- Any file under `site/src/data/perf/`.
- Any chart component changes.
- Any change to `<StatusPill>`, `<InProgressNotice>`, the index-page rendering logic, or the frontmatter type schema. All four landed with demo 5's teaser and are now considered stable infrastructure.
- Branch creation, Amplify per-branch preview setup (user steps).
- The substantive demo 6 work itself (separate implementation brief, not yet written).

## Changes

### 1. New file — `site/src/posts/06-aos-vs-soa.mdx`

Frontmatter:

```yaml
---
title: "AoS vs SoA: the cache-line staircase"
date: "2026-05-22"
status: "in-progress"
expectedAt: "August 2026"
excerpt: "Array-of-structs vs struct-of-arrays under a working-set sweep through L1, L2, L3, and DRAM. The crossover isn't where conventional wisdom says it is — and SIMD moves it further."
---
```

Body template — wording adjustable, structure is the constraint:

`````mdx
<InProgressNotice expectedAt="August 2026" />

## The thesis

The right memory layout is a function of the access pattern, not a universal preference. In a hot inner loop over structured data the cache line is the smallest unit of useful work — and what fraction of the bytes you load per cache line you actually *use* determines whether array-of-structs or struct-of-arrays wins.

"Everyone says SoA wins" isn't wrong because of theory; it's wrong because the conditions under which it's right are narrower than the slogan suggests. When the struct fits in a single cache line, AoS loads the whole line either way. When the inner loop touches all of a wider struct's fields, AoS still wins by locality. SoA's advantage shows up exactly where the inner loop touches a hot column of a wide struct — and grows from there as the working set falls out of cache.

This post benchmarks AoS and SoA across two axes — working-set size from L1 to DRAM, and the fraction of struct fields touched per element — on the kind of struct a capital-markets row aggregator actually holds.

## What the post will cover

Two layouts of a struct of N fields, sized to span multiple cache lines:

1. **Array of structs (AoS)** — the natural C++ default. Each struct contiguous; the whole struct loaded per cache line whether you need every field or not.
2. **Struct of arrays (SoA)** — each field in its own parallel array. Cold fields never touched, never loaded.

Two axes of variation:

- **Working-set size** — sweeping the array across L1 (32 KB), L2 (512 KB), L3 (16 MB on Zen 2), and DRAM. The canonical latency staircase. Counter overlay confirms the cache misses appear where the staircase predicts them.
- **Access pattern** — how many of the struct's fields the inner loop touches per element, from a single hot column up to all fields.

Headline chart: time-per-element vs working-set on a log-log axis with cache-tier boundaries marked, one curve per layout. Supporting view: the access-pattern crossover at a fixed working-set size — where SoA's lead narrows and AoS catches up. Plus a vectorised pass for the SoA hot-column case, [cross-linking back to Demo 3](/posts/03-simd-blackscholes) — auto-vectorisation only kicks in cleanly under SoA, and the speedup compounds with the layout advantage.

## What makes the post interesting

The crossover isn't where conventional wisdom says it is. Once you start measuring under realistic struct sizes and access patterns, "always pick SoA" fragments into a small decision table: how big is the struct, how many fields the loop touches, where the working set sits on the staircase.

Capital-markets framing: option-chain Greeks compute on a different subset of the per-option record than full-price scans. The layout decision is a derivative of which signals the inner loop consumes.

Expected to ship in August 2026.
`````

## Acceptance criteria

- `site/src/posts/06-aos-vs-soa.mdx` exists with the specified frontmatter and the four-section tease body (`<InProgressNotice>`, "The thesis", "What the post will cover", "What makes the post interesting").
- `npm run build` succeeds with zero new warnings.
- The index page renders six cards. The demo 6 card is **last** in the listing and carries an amber "In Progress" pill near the date — visually identical to the way demo 5's card rendered before it shipped.
- Clicking the demo 6 card navigates to `/posts/06-aos-vs-soa`.
- `/posts/06-aos-vs-soa` renders with the post title, the `<InProgressNotice>` callout at the top, and the tease prose. No chart components are present, no JSON is fetched, no console errors.
- Lighthouse Performance ≥ 90 and Accessibility ≥ 90 on `/posts/06-aos-vs-soa` (matches the bar for the five shipped posts).
- The five existing shipped post cards are visually unchanged.

## Out of scope

(restated)

- Any change to `<StatusPill>`, `<InProgressNotice>`, the index-page rendering or sort logic, or the frontmatter type schema. All four landed with demo 5's teaser and are considered stable.
- Any chart component changes.
- Any JSON creation or modification.
- Feature branch creation, Amplify configuration, per-branch preview deploy setup (user steps).
- The substantive demo 6 work — see the forthcoming `06-aos-vs-soa-brief.md` (not yet written).

## Open items for CC to flag

- If the teaser infrastructure from demo 5 has drifted in any way (the `status` frontmatter field is no longer read, `<InProgressNotice>` has been removed or renamed, the index page no longer renders the pill, the sort no longer puts in-progress posts last) — stop and surface this in the PR. This brief assumes that infrastructure is intact and unchanged from demo 5's teaser landing.
- If any copy on the site hardcodes the demo count ("five demos so far" on a landing or about page, in the README, in `<head>` metadata) — update to six, or generalise to "ongoing series." Likely none, but worth a quick grep.
- If the `expectedAt` value should be tightened or loosened from "August 2026" before the brief ships, flag for the user — it's a single-field edit.

## Notes for CC

- This brief lands on `main` and should be a very small, low-risk PR — smaller than demo 5's teaser, because the components and schema already exist. If the PR touches anything beyond `site/src/posts/06-aos-vs-soa.mdx`, justify it in the PR description.
- The stub MDX body is a template. Wording adjustments are welcome; the four-section structure (`<InProgressNotice>` + "The thesis" + "What the post will cover" + "What makes the post interesting") is the constraint.
- When the feature branch (`demo-6-aos-soa` or similar) eventually merges to main, the merge will overwrite the stub MDX with the real post and remove the `status: "in-progress"` and `expectedAt` frontmatter fields.
