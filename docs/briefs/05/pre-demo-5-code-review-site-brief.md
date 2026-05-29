# Crucible — pre-demo-5 code review brief (`site/`)

Companion to `BRIEF.md` and `crucible-handover.md`. Full code review of the Next.js + MDX surface across the four shipped demos. **Use the `code-review` skill.** This brief layers project-specific focus areas on top.

## Scope

In scope:

- `site/src/app/` — `page.tsx` (index), `methodology/`, `posts/[slug]/page.tsx`, any layout / loading files.
- `site/src/components/` — `CodeCompare.tsx`, `Benchmark.tsx`, anything else.
- `site/src/components/charts/` — `theme.ts`, `ThroughputBars`, `TimeVsN`, `LatencyHistogram`, `CounterOverlay`.
- `site/src/data/perf/` — the four JSON files (schema consistency only, not values).
- `site/src/posts/` — all four MDX files (structure and component usage, not prose).
- `site/src/lib/` or equivalent — any data loading, type definitions, utilities.
- `site/next.config.mjs`, `site/tailwind.config.ts`, `site/tsconfig.json`, `site/package.json`.

Out of scope:

- Anything under `bench/` (separate brief).
- MDX prose content (handled in the hostile cross-read Opus task).
- Methodology page content (Opus task).
- Visual design polish.

## Focus areas

1. **Chart component DRY.** All four charts should share axis treatment, legend, tooltip behaviour, and color palette via `theme.ts`. Flag where chart-local code duplicates what `theme.ts` provides or should provide. The four charts entered the codebase at different times (`ThroughputBars` from v1, `CounterOverlay` from demo 2, `LatencyHistogram` from demo 4) — drift is likely.

2. **Data-loading pattern.** Each chart filters the per-demo JSON by some combination of `variants`, `topology`, `threads`, `padded`, `n`, and — newest, from demo 4 — `mode` and `offered_rate_hz`. Flag where this filter logic is repeated per chart vs lifted to a shared loader. Flag where a chart silently breaks (or silently renders something misleading) when an older demo's JSON lacks a field a newer chart expects.

3. **TypeScript types for the JSON schema.** Is the per-demo JSON shape modelled as a shared type, or inlined per chart? If shared, does it cover the additive schema (`mode`, `offered_rate_hz`, `percentile_convention`, `top_bucket_count`, `calibration_drift_pct`) without making them required where they shouldn't be? `runs[]` has accumulated optional fields across demos — the type should match.

4. **MDX consistency across the four posts.**
   - Frontmatter shape — same keys in the same order? (`title`, `date`, `summary`, `slug`, etc.)
   - Heading levels — `h1` reserved for post title only? `h2` for major sections?
   - Code-block fence usage — language tags, line-highlight syntax, file-name annotations.
   - Component invocation patterns — `<Benchmark>` vs direct chart-component use; `<CodeCompare>` props consistency.

5. **`CodeCompare.tsx`.** Shiki integration approach — vendored theme vs CDN (per `BRIEF.md` open item — was this resolved?), client vs server rendering, props contract. `labels` prop usage (demo 1 uses it for "Sorted/Unsorted"; others may not need it but should be consistent).

6. **Methodology page (code only).** Audit `site/src/app/methodology/page.tsx` (or wherever it lives) for structural issues: static MDX vs hardcoded React tree, broken anchors, missing references. **The content of the page is Opus task 2 — don't audit content here, only structure and code health.**

7. **Accessibility and color.**
   - Chart color palette color-blind-safe (Okabe-Ito or equivalent)?
   - Alt text on any non-decorative SVG/visual elements?
   - Reasonable ARIA on interactive elements (tooltips, links)?
   - Tab order sane through a post page?
   - Sufficient contrast for the dark theme + cyan accent?

8. **Tailwind v4 churn.** `BRIEF.md` flagged Tailwind v4 + Next.js 14 static export as a possible churn area. Flag any v3 idioms still in the codebase (`@layer` patterns, `tailwind.config.ts` shape, custom CSS that duplicates a v4 utility).

9. **Static export integrity.** `next.config.mjs` should be `output: 'export'`. Flag any dynamic-only patterns that would break static export: server actions, ISR, dynamic route params without `generateStaticParams`, runtime API routes, etc.

10. **Lighthouse-relevant code smells.** Not a Lighthouse run (that's a later task — `pre-demo-5-lighthouse-mobile-brief.md`), but smell-checks worth catching now:
    - `<Image>` dimensions set; no layout-shift triggers.
    - Fonts preloaded; no FOUT.
    - JS bundle composition sensible (no accidental D3-everything import).
    - No `console.log` spam in prod build.
    - No unused dependencies in `package.json`.

## Deliverable format

Output a single findings document at `pre-demo-5-site-code-review-findings.md` in the repo root. Structure mirrors the bench/ findings doc:

```
# Crucible site/ code review — findings

## Critical
(Affects what a visitor sees in a shipped post, or breaks the build.)

## Material
(Real DRY violations, missing types, silent-failure paths in components.)

## Minor
(Stylistic, naming, comments, dependency hygiene.)
```

Each finding: **Location**, **Observation**, **Problem**, **Suggested fix**, **Severity**.

**Do not implement fixes in this task. Findings only.**

## Acceptance

- Findings doc exists at the named path.
- All four chart components have been touched.
- All four post MDX files have been touched (structurally — prose is out of scope).
- Every focus area has been considered — explicit "no findings" is fine.
- Critical findings, if any, reference the rendered post or page they affect.

## Out of scope

- Prose changes in any MDX (Opus task).
- Methodology page content (Opus task).
- New components.
- Visual design changes.
- Fixes for any finding.

## Open items for CC to flag

- If the data-loader pattern is currently good — i.e. one shared loader for the per-demo JSON, used by all charts — say so explicitly. The expectation is some drift, but if there isn't, that's information worth recording.
- If any chart silently mis-renders on an older demo's JSON, treat as **critical** and name the specific demo + chart combination.
- If a finding can only be confirmed at runtime (e.g. tab order, FOUT), say so — it'll feed into the lighthouse/mobile brief.
- If the `code-review` skill surfaces something not covered by the focus areas above, include it.
