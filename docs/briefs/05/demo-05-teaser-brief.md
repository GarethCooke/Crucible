# Crucible — Demo 05 teaser brief

Companion to `BRIEF.md`, `crucible-handover.md`, and `05-allocators-brief.md` (the implementation brief). This brief lands a small placeholder for demo 5 on the live site so visitors see a fifth post is coming, while the substantive implementation work proceeds isolated on a feature branch.

## Why this brief

Demo 5 (allocators, cross-thread Order pipeline) is a multi-week effort across C++, data capture, prose, and a new chart component. The user is creating a feature branch (`demo-5-allocators` or similar) for that work, with per-branch Amplify preview deployments enabled.

This brief is the small change that lands on `main` *first*: a teaser card on the index page and a stub post page with a "what's coming" tease. Visitors to crucible.garethcooke.com see five cards rather than four, and a "What makes this post interesting" pitch on the demo 5 page. When the feature branch eventually merges to main, its merge replaces the stub MDX content with the real post and flips the post's `status` frontmatter from `in-progress` to absent.

The visual pattern is the one from garethcooke.com's project cards: an amber pill with a small bullet dot, labelled "In Progress."

## Scope

In scope:

- New MDX file at `site/src/posts/05-allocators.mdx` (stub content with WIP frontmatter).
- New component `StatusPill` for the index card indicator.
- New component `InProgressNotice` for the post page header callout.
- Frontmatter schema extension to support `status` and `expectedAt` fields.
- Index page update to render the status pill and place the demo 5 card last.

Out of scope:

- Anything under `bench/`.
- Any file under `site/src/data/perf/`.
- Any chart component changes.
- Branch creation, Amplify per-branch preview setup (user steps).
- The substantive demo 5 work itself (separate brief).

## Changes

### 1. New file — `site/src/posts/05-allocators.mdx`

Frontmatter:

```yaml
---
title: "Allocators: cross-thread order pipeline"
date: "2026-05-20"
status: "in-progress"
expectedAt: "June 2026"
excerpt: "Cross-thread Order lifecycle benchmarked across three allocator strategies — malloc, freelist with return queue, and arena with batch handoff. Median vs tail under realistic background heap pressure."
---
```

Body template — wording adjustable, structure is the constraint:

````mdx
<InProgressNotice expectedAt="June 2026" />

## The thesis

In a cross-thread trading pipeline, the allocator design is a derivative of the threading model. The right choice depends on whether your latency budget lives in the median or the tail.

Every `new Order(...)` you write looks like it costs 20 ns. Under realistic background heap pressure, that median hides a p99.9 tail of microseconds — the latencies that determine whether your strategy reacts in time.

This post benchmarks three allocator strategies for an Order pipeline where the producer thread constructs orders and the consumer thread frees them after processing — the threading model every real system uses, and the one that breaks naïve thread-local pools.

## What the post will cover

Three variants of allocation for ~64 B `Order` objects flowing producer → consumer through an SPSC queue, reusing the queue primitive from [Demo 4](/posts/04-spsc-queue):

1. **Cross-thread `new`/`delete`** — glibc's per-arena allocator. The baseline most real systems run because it just works.
2. **Freelist with return queue** — producer keeps a thread-local freelist; consumer pushes used Orders onto a return SPSC back to the producer for replenishment. The "magazine" pattern simplified.
3. **Arena with batch handoff** — producer bump-allocates from a rotating slab; consumer publishes drain progress; producer recycles slabs once fully consumed.

The headline chart will be the end-to-end latency CCDF — alloc-to-free time across all three variants with p50 / p99 / p99.9 markers. Supporting view: a sweep of p99.9 latency vs background heap-pressure intensity, showing the malloc tail growing while the pool variants stay flat.

## What makes the post interesting

There's a non-obvious result hiding in the data — the answer isn't simply "use a pool." The right pool depends on whether your latency budget is in the median or the tail, and the trade-off between freelist-style and arena-style allocators isn't free.

Expected to ship in June 2026.
````

### 2. New component — `site/src/components/StatusPill.tsx`

The amber-pill indicator used on the index card. API:

```tsx
type PostStatus = "in-progress" | "shipped";

interface Props {
  status?: PostStatus;
  className?: string;
}

export function StatusPill({ status, className }: Props) {
  if (!status || status === "shipped") return null;

  if (status === "in-progress") {
    return (
      <span
        className={`inline-flex items-center gap-1.5 rounded-full border border-amber-500/30 bg-amber-500/10 px-2.5 py-0.5 text-xs font-medium text-amber-300 ${className ?? ""}`}
      >
        <span aria-hidden className="size-1.5 rounded-full bg-amber-400" />
        In Progress
      </span>
    );
  }

  return null;
}
```

Notes:

- Visual target: matches the screenshot pattern from garethcooke.com — amber pill, small bullet dot left of label, slightly muted text.
- If the project already has design tokens for warning/amber colours (the bench code-review cleanup brief flagged `@theme {}` token registration), use those tokens rather than literal Tailwind utilities. CC: surface which pattern is in play.
- Component is forward-compatible: adding `"draft"` or `"deferred"` to the union later just requires extending the conditional.

### 3. New component — `site/src/components/InProgressNotice.tsx`

The larger callout shown at the top of a WIP post body. API:

```tsx
interface Props {
  expectedAt: string;
}

export function InProgressNotice({ expectedAt }: Props) {
  return (
    <div className="my-6 rounded-md border border-amber-500/30 bg-amber-500/5 px-4 py-3 text-sm">
      <p className="font-medium text-amber-300">This post is in progress.</p>
      <p className="mt-1 text-amber-200/80">
        Expected to land in {expectedAt}. The implementation and measurements aren't complete — what follows is a tease of what the post will cover.
      </p>
    </div>
  );
}
```

Register this in the MDX `components` map (alongside `<Benchmark>` and chart components) so it can be used directly inside `.mdx` files.

### 4. Index page change — `site/src/app/page.tsx` (or wherever the listing lives)

Update the post-listing logic:

- Read `status` and `expectedAt` from each post's frontmatter alongside the existing fields (title, date, excerpt).
- When rendering a card with `status === "in-progress"`, render `<StatusPill status="in-progress" />` adjacent to the date. The card itself remains linkable to `/posts/<slug>`.
- The four existing shipped cards must be visually unchanged — no shifted layout, no new spacing, no regression.

**Sorting.** Demo 5's card must appear last in the listing. If the existing sort is by post-number prefix (extracted from filename or an explicit number field), `05-allocators.mdx` lands last naturally and no change is needed. If the existing sort is by `date` descending, the stub's `2026-05-20` date would push demo 5 to the top of the list, which is wrong. CC: surface the current sort behaviour and propose the minimal fix if it's date-based. Acceptable answers: add an explicit `order` field to frontmatter, sort by file-name prefix, or use a far-future date for `in-progress` posts.

### 5. Frontmatter type extension

Wherever post frontmatter types are declared in TypeScript (most likely `site/src/lib/posts.ts` or similar), add two optional fields:

```ts
status?: "in-progress" | "shipped";
expectedAt?: string;
```

If frontmatter is currently parsed as `any` and no typed schema exists, leave the implementation untyped — don't introduce a typing layer as part of this brief. Flag for a future cleanup.

## Acceptance criteria

- `site/src/posts/05-allocators.mdx` exists with the specified frontmatter and the four-section tease body (`<InProgressNotice>`, "The thesis", "What the post will cover", "What makes the post interesting").
- `npm run build` succeeds with zero new warnings.
- The index page renders five cards. The demo 5 card is **last** in the listing and carries an amber "In Progress" pill near the date.
- Clicking the demo 5 card navigates to `/posts/05-allocators`.
- `/posts/05-allocators` renders with the post title, the `<InProgressNotice>` callout at the top, and the tease prose. No chart components are present, no JSON is fetched, no console errors.
- Lighthouse Performance ≥ 90 and Accessibility ≥ 90 on `/posts/05-allocators` (matches the bar for the four shipped posts).
- The four existing shipped post cards are visually unchanged — diff the rendered DOM against pre-change if needed.
- Build artefact (`out/` or equivalent static export) includes the new post page and its index entry.

## Out of scope

- Anything under `bench/`.
- Any chart component changes.
- Any JSON creation or modification.
- Feature branch creation, Amplify configuration, per-branch preview deploy setup (user steps).
- The substantive demo 5 work — see `05-allocators-brief.md`.

## Open items for CC to flag

- If the existing index sort is by date descending (not post-number prefix), surface this and propose the minimal fix before implementing per §4.
- If `excerpt` is not currently a frontmatter field consumed by the index, note whether the index needs updating to display it. If excerpts aren't shown on the index, the field is still useful for SEO and `<head>` metadata; leave it set in frontmatter regardless.
- If `site/src/components/` uses a `.module.css` or styled-components pattern instead of Tailwind utility classes, adapt the component implementations accordingly and flag.
- If a status-pill or callout-style component already exists in the codebase under a different name (e.g. a generic `<Badge>` or `<Callout>`), prefer the existing component over introducing a new one. Note the choice in the PR description.
- If the project's design tokens registration (per `pre-demo-5-09-minor-cleanup-brief.md`) covers amber/warning colours, use the tokens. If not, literal Tailwind utilities are acceptable for this brief; a follow-up can register them later.

## Notes for CC

- This brief lands on `main` and should be a small, low-risk PR. No data captures, no benchmark builds, no chart changes. If the PR diff exceeds ~250 lines net, something has scope-crept.
- The stub MDX body is a template. Wording adjustments are welcome; the four-section structure (`<InProgressNotice>` + "The thesis" + "What the post will cover" + "What makes the post interesting") is the constraint.
- When the feature branch (`demo-5-allocators` or similar) eventually merges to main, the merge will overwrite the stub MDX with the real post and remove the `status: "in-progress"` and `expectedAt` frontmatter fields. The `StatusPill` and `InProgressNotice` components remain available for future use.
