# Crucible — minor cleanup brief

**Pre-demo-5 brief 9 of 9. The N-series findings from both reviews, packaged as a single small cleanup PR.**

---

## 1. Context

Both reviews flagged a dozen-plus `Minor` findings: stylistic, comment-level, naming, dependency hygiene. Individually trivial; collectively a tidy-up that makes the codebase visibly cared-for. Land last in the pre-demo-5 sequence so the bigger refactors aren't blocked behind cosmetic changes.

This brief was extended after tasks 9 (Lighthouse) and 10 (mobile) completed, to absorb three small additional items that don't justify their own briefs: two Lighthouse residue items (L-01, L-02) and one cross-cutting MDX pipeline item (X-01). They share the "small, isolated, hygienic" character of the N-series cleanup and land in the same PR. The headline mobile findings (M02-1, M03-1, M04-1, M04-2, M04-3) live in brief 10; the Lighthouse D3 wildcard imports (M-02) live in brief 08.

Findings included (verbatim list — refer to the source files for full context):

**Bench side** (`pre-demo-5-bench-code-review-findings.md`):

- **N1** — Demo 04 mutex-condvar `deq_ts == 0` items in histogram
- **N2** — Demo 02 `check_smt_off()` silent skip on missing sysfs
- **N3** — `--machine-info` argv scanning inconsistent across demos
- **N4** — Demo 01 `BM_Sort_32M` missing PerfCounters comment
- **N6** — `bench/tests/CMakeLists.txt` macOS SDK hardcoding

**Site side** (`pre-demo-5-site-code-review-findings.md`):

- **N-01** — Magic font-size values `10` and `9` in chart renderers
- **N-02** — `BranchMissOverlayChart` hardcodes `N = 32 M` in label
- **N-03** — Post 03 Black-Scholes formula uses un-tagged code fence
- **N-04** — Methodology page `<code>` inline styles inconsistent with `.prose code`
- **N-05** — Methodology page `h2` sections lack `id` attributes
- **N-06** — MDX component invocation convention inconsistent (`<Benchmark>` vs direct chart components)
- **N-08** — CSS custom properties not registered as Tailwind `@theme` tokens

**Lighthouse residue** (`pre-demo-5-lighthouse-findings.md`):

- **L-01** — Umami preconnect missing (~300 ms saved per page)
- **L-02** — Legacy JS polyfills shipped in `chunks/117-*.js` (~11 KB)

**Cross-cutting** (`pre-demo-5-mobile-findings.md`, "Cross-cutting note" section):

- **X-01** — `remark-gfm` plugin absent from MDX pipeline; markdown tables in demos 1 and 2 render as pipe-separated text rather than HTML `<table>` elements

Two N-series items are explicitly handled elsewhere and **not** in this brief:

- **N5 (bench, `machine_info.h` popen dedup)** → folded into brief 3 (DRY cleanup) because it shares the refactoring shape with M1/M7/M8/M9.
- **N-07 (site, Next.js 15 params typing)** → not actionable until the Next.js 15 upgrade; record in the handover doc instead.

---

## 2. Bench-side cleanup

### 2.1 N1 — Demo 04 mutex-condvar zero-timestamp items

**File:** `bench/demos/04-spsc-queue/benchmark.cpp:460–465`.

After logging the WARN for `deq_ts[i] == 0`, skip the item rather than passing it to `bin_run`:

```cpp
for (size_t i = 0; i < ITEMS; ++i) {
    if (deq_ts[i] == 0) {
        fprintf(stderr, "WARN: mutex-condvar item %zu not consumed\n", i);
        continue;  // skip — passing zero would underflow uint64_t in bin_run
    }
    bin_run(result, deq_ts[i] - enq_ts[i]);
}
```

The `continue` prevents histogram contamination if a consumer exits early. The WARN remains for observability.

### 2.2 N2 — Demo 02 `check_smt_off()` silent skip

**File:** `bench/demos/02-false-sharing/false_sharing_pnl.cpp:79–82`.

Before the early return on `!f.is_open()`, emit a warning to stderr:

```cpp
if (!f.is_open()) {
    fprintf(stderr, "WARNING: /sys/devices/system/cpu/smt/active not found — "
                    "SMT check skipped (kernel may lack CONFIG_SCHED_SMT)\n");
    return;
}
```

This mirrors the `assert_smt_off()` behaviour in `bench/scripts/lib.sh` introduced by brief 2.

### 2.3 N3 — `--machine-info` argv handling

Standardise all four demos on the demo 04 pattern (check `argv[1]` only, using `std::string_view`):

```cpp
if (argc > 1 && std::string_view(argv[1]) == "--machine-info") {
    print_machine_info_json();
    return 0;
}
```

Update in:

- `bench/demos/01-branch-prediction/benchmark.cpp:154–158` (currently scans all argv)
- `bench/demos/02-false-sharing/false_sharing_pnl.cpp:232` (uses `std::string`)
- `bench/demos/03-simd-blackscholes/benchmark.cpp:144–148` (currently scans all argv)

Demo 04 is already correct; no change there.

### 2.4 N4 — Demo 01 `BM_Sort_32M` PerfCounters comment

**File:** `bench/demos/01-branch-prediction/benchmark.cpp:124–135`.

Add one line above `BM_Sort_32M`:

```cpp
// PerfCounters intentionally omitted — this benchmark measures sort wall time
// only, not branch behaviour. See sort_cost_32m in assemble_results.py.
```

### 2.5 N6 — macOS SDK hardcoding

**File:** `bench/tests/CMakeLists.txt:6–10`.

Two options:

**(a) Make discovery dynamic on macOS:**

```cmake
if(APPLE)
    execute_process(
        COMMAND xcrun --show-sdk-path
        OUTPUT_VARIABLE CMAKE_OSX_SYSROOT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()
```

**(b) Remove the workaround entirely** if the underlying Xcode issue it documents has been resolved. The reference machine is Linux; the macOS path is only relevant if someone builds the tests on a Mac. CC should try a fresh build on the macOS dev machine without the workaround; if it succeeds, delete the block. If it fails, use option (a).

Document the decision in the PR.

---

## 3. Site-side cleanup

### 3.1 N-01 — Chart font-size tokens

**File:** `site/src/lib/design-tokens.ts` and every chart file.

Add to `tokens.chart`:

```ts
chart: {
  // … existing
  annotationSize: 10,
  captionSize: 9,
}
```

Export from `theme.ts`. Replace literal `10` and `9` font-size values in chart renderers with `typography.annotationSize` and `typography.captionSize` respectively.

Grep scope: `site/src/components/charts/*Chart.tsx` for `font-size.*['"]?10` and `['"]?9`. Expected matches: value labels, axis titles, legend labels, annotation text.

### 3.2 N-02 — `BranchMissOverlayChart` N label

**File:** `site/src/components/charts/CounterOverlayChart.tsx:337`.

Add `maxN: number` to `BranchMissOverlayChart` props. The parent (`CounterOverlay.tsx:47` per the review) already computes max N from the run data; pass it down.

Format with the same SI suffix formatter `TimeVsNChart` uses (e.g., `formatSI(maxN)` → `"32 M"`). Replace the hardcoded text:

```tsx
.text(`branch misses / op  ·  N = ${formatSI(maxN)}`)
```

If the SI formatter isn't already exported from a shared module, extract it from `TimeVsNChart` to `site/src/lib/format.ts` (or similar) and import from both places.

### 3.3 N-03 — Black-Scholes formula code fence

**File:** `site/src/posts/03-simd-blackscholes.mdx:18–24`.

Change the un-tagged opening fence to ` ```text `. No content change.

### 3.4 N-04 — Methodology page inline `<code>` styling

**File:** `site/src/app/methodology/page.tsx`.

The methodology page renders inside `<div className="max-w-2xl fu">` (no `.prose` wrapper). Pick one:

**(a) Wrap content in `.prose`:**

```tsx
<div className="max-w-2xl prose prose-invert">
  {/* existing methodology page content */}
</div>
```

This inherits all `.prose code` styling (background box, border, padding, colour) and removes the need for inline `style={{ color: 'var(--cyan)' }}` on each `<code>` element. Sweep the file for inline `<code style={...}>` and replace with bare `<code>`.

**(b) Add a `methodology-code` class:**

Define in `globals.css` with the same properties as `.prose code`. Apply to each `<code>` element. Removes inline styles but introduces a parallel class.

Option (a) is the cleaner choice unless `.prose` causes typography conflicts with the existing methodology page layout (h2 sizes, paragraph spacing, etc.). CC should preview both and pick.

### 3.5 N-05 — Methodology page heading IDs

**File:** `site/src/app/methodology/page.tsx`.

Add `id` attributes to the four `<h2>` elements:

```tsx
<h2 id="reference-machine" className="…">Reference machine</h2>
<h2 id="commitments" className="…">Four non-negotiable commitments</h2>
<h2 id="best-practices" className="…">Additional best-practice items</h2>
<h2 id="references" className="…">References</h2>
```

Slug values are illustrative — match whatever the post pages' heading-id slugification produces if there's a shared convention.

### 3.6 N-06 — MDX component convention

The cleanest path is to migrate all four posts to use `<Benchmark chart="...">` exclusively. Posts 01, 02, 03 currently call direct chart components (`<ThroughputBars>`, `<CounterOverlay>`, `<TimeVsN>`).

Steps:

1. For each direct chart invocation in posts 01–03, rewrite as `<Benchmark slug="..." chart="..." [mode="..."] [variants="..."] />`.
2. Verify each rendered post still shows the same chart with the same data.
3. Once all four posts use `<Benchmark>` exclusively, remove `ThroughputBars`, `CounterOverlay`, `TimeVsN` from the `components` map in `site/src/app/posts/[slug]/page.tsx`.
4. The direct chart server components themselves stay (`<Benchmark>` uses them internally); only the MDX entry points are removed.

After this, MDX authors have one chart API to learn. The direct chart components are no longer part of the post-author surface.

If migration scope feels heavy, an alternative is to leave the existing posts alone and only enforce the convention for new posts (demo 5+). Document the decision either way in the PR.

### 3.7 N-08 — Tailwind `@theme` tokens for semantic colours

**File:** `site/src/app/globals.css`.

In the existing `@theme {}` block, add semantic-token aliases:

```css
@theme {
  /* existing accent and surface tokens */
  --color-text-primary: var(--text-primary);
  --color-text-muted: var(--text-muted);
  --color-text-secondary: var(--text-secondary);
  --color-bg-card: var(--bg-card);
  --color-border-color: var(--border-color);
  --color-cyan: var(--cyan);
  /* … any others used in inline styles */
}
```

Once registered, Tailwind generates utilities like `text-text-muted` and `bg-bg-card`. Migration:

1. Grep for `style={{ color: 'var(--text-` and `style={{ background: 'var(--bg-` across `site/src`.
2. For each match, replace with the equivalent Tailwind utility class.
3. Inline `style` attributes that _only_ set theme-var colours can be dropped entirely; inline styles that also set non-themable properties keep the structure but lose the colour line.

This is a sweep that touches many files lightly. Stretch goal — if the migration grows beyond ~30 minutes, defer the per-component migration to a follow-up and ship only the `@theme {}` registration in this brief. The registration alone enables future code to use the utilities without re-touching the inline-style files.

### 3.8 L-01 — Umami preconnect

**File:** `site/src/app/layout.tsx` (the root layout where the document head is composed).

The Lighthouse audit (`pre-demo-5-lighthouse-findings.md`) flagged ~300 ms of avoidable wait against `https://api-gateway.umami.dev` because the analytics script connects without a preconnect hint. Add one:

```tsx
<head>
  {/* … existing head children */}
  <link rel="preconnect" href="https://api-gateway.umami.dev" />
</head>
```

If the layout uses Next.js's `metadata` API or `next/script` rather than directly rendering `<head>`, add the link via the equivalent Next mechanism (a `<link>` rendered as a child in the `app/` layout root works in the App Router). Two-line change; preserves analytics behaviour, just starts the handshake earlier.

Manual verification: Lighthouse re-run on any post page shows the preconnect audit no longer firing; LCP shifts down by ~200–300 ms.

### 3.9 L-02 — Legacy JS polyfills

**File:** `site/.browserslistrc` (or the `browserslist` field in `site/package.json`); audit `site/next.config.mjs` for any explicit transpile-target override.

The Lighthouse audit flagged ~11 KB of legacy polyfills in `chunks/117-*.js`. Fix is to bump the browser baseline so Next.js's SWC compiler stops emitting downlevel transforms for browsers that no longer matter for this audience.

A reasonable starting point:

```
> 0.5%
last 2 versions
not dead
not op_mini all
not ie 11
```

For a perf-focused site with a developer audience, a tighter target gives a smaller bundle:

```
last 2 Chrome versions
last 2 Firefox versions
last 2 Safari versions
last 2 Edge versions
```

CC chooses; the second is more aggressive. Either way, verify the build still passes and pages render in the target browsers (a smoke test in Chrome stable is sufficient — the audience is unlikely to use anything outside this set).

If `next.config.mjs` has any explicit `target`, `swcMinify`, or `compiler.legacyBrowsers` setting affecting transpile output, audit and align it with the browserslist.

Manual verification: Lighthouse re-run on any post page no longer flags the legacy-JS audit for `chunks/117-*.js`. The chunk filename will change after rebuild; verify the JS payload size in the Network tab drops by approximately 11 KB.

### 3.10 X-01 — `remark-gfm` plugin in MDX pipeline

**File:** the MDX configuration — likely `site/next.config.mjs` (if MDX is configured via `@next/mdx`), or a dedicated MDX config file alongside it. Grep for `createMDX` or `remarkPlugins` to locate.

The mobile audit cross-cutting note (`pre-demo-5-mobile-findings.md`, "Cross-cutting note" section) found that markdown tables in demo 1 (`01-branch-prediction.mdx` lines 179–184) and demo 2 (`02-false-sharing.mdx` lines 130–136) render as pipe-separated paragraph text rather than HTML `<table>` elements. Root cause: the MDX pipeline does not include `remark-gfm`, so GitHub Flavoured Markdown table syntax is passed through as literal text.

Install and register:

```bash
npm install remark-gfm
```

In the MDX config:

```js
import remarkGfm from "remark-gfm";

const withMDX = createMDX({
  options: {
    remarkPlugins: [remarkGfm],
    // … existing rehypePlugins etc. preserved
  },
});
```

Once active, the existing markdown tables in demos 1 and 2 render as HTML tables without further edits. Verify both pages.

Styling note: `.prose` (from `@tailwindcss/typography`, which the post pages already use) styles tables by default — borders, padding, header-row weight. The rendered tables should inherit the design without additional CSS. If a table looks visually off after the plugin lands (e.g. overflows narrow viewports), that's a styling concern for a follow-up brief, not a `remark-gfm` regression.

Manual verification: demo 1 and demo 2 post pages now show their summary tables as proper HTML tables with visible borders and a distinct header row. No regression elsewhere on the site — `remark-gfm` also enables strikethrough, task lists, and autolinks, but none of those are used in the current posts; existing content renders identically.

---

## 4. Not in this brief

- **N5 (bench, `machine_info.h`)** → brief 3.
- **N-07 (site, Next.js 15 params)** → no action; record in handover doc as a known forward-compat item.
- **The "not-a-finding" items** at the end of the site review are confirmed-passing checks, not work items.

---

## 5. Acceptance checklist

### Bench

- [ ] **N1**: Demo 04 mutex-condvar skips items with `deq_ts == 0` in `bin_run` accumulation.
- [ ] **N2**: Demo 02 `check_smt_off()` prints stderr warning when sysfs file is absent.
- [ ] **N3**: All four demos use the demo-04 `--machine-info` pattern (`argv[1]` + `std::string_view`).
- [ ] **N4**: `BM_Sort_32M` carries a one-line comment explaining PerfCounters omission.
- [ ] **N6**: macOS SDK path is either removed (if no longer needed) or discovered via `xcrun`.

### Site

- [ ] **N-01**: `tokens.chart.annotationSize` and `captionSize` defined; chart renderers use the tokens, no literal `10`/`9` font sizes remain.
- [ ] **N-02**: `BranchMissOverlayChart` accepts `maxN` prop; footer label uses formatted value, not hardcoded `"32 M"`.
- [ ] **N-03**: Post 03 Black-Scholes fence has explicit `text` language tag.
- [ ] **N-04**: Methodology page inline `<code>` styling consistent with `.prose code` (via wrapper or class).
- [ ] **N-05**: All four methodology `<h2>` elements have `id` attributes; manual test: `#commitments` (or chosen slug) scrolls to the right section.
- [ ] **N-06**: Convention decided and documented; if migrating, posts 01–03 use `<Benchmark>` exclusively and direct chart components removed from MDX `components` map.
- [ ] **N-08**: `@theme {}` block registers semantic colour tokens. (Per-component inline-style migration: full sweep if scope allows, else registration only with sweep deferred.)

### Lighthouse residue and MDX pipeline

- [ ] **L-01**: `<link rel="preconnect" href="https://api-gateway.umami.dev">` present in rendered HTML head; Lighthouse no longer flags the preconnect audit.
- [ ] **L-02**: Browserslist updated; Lighthouse no longer flags the `chunks/117-*.js` legacy-JS audit; total JS payload reduced by approximately 11 KB.
- [ ] **X-01**: `remark-gfm` installed and registered in MDX pipeline; demos 1 and 2 markdown tables render as HTML `<table>` elements with `.prose` styling; no regression on other posts.

### Cross-cutting

- [ ] Full `bench/` build passes.
- [ ] `npm run build` succeeds (especially relevant after browserslist and MDX pipeline changes).
- [ ] No shipped JSON modified by this brief.
- [ ] No re-capture required for any demo.
