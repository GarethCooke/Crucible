# Crucible — minor cleanup brief

**Pre-demo-5 brief 9 of 9. The N-series findings from both reviews, packaged as a single small cleanup PR.**

---

## 1. Context

Both reviews flagged a dozen-plus `Minor` findings: stylistic, comment-level, naming, dependency hygiene. Individually trivial; collectively a tidy-up that makes the codebase visibly cared-for. Land last in the pre-demo-5 sequence so the bigger refactors aren't blocked behind cosmetic changes.

Findings included (verbatim list — refer to the two review files for full context):

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

Change the un-tagged opening fence to ```` ```text ````. No content change.

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
3. Inline `style` attributes that *only* set theme-var colours can be dropped entirely; inline styles that also set non-themable properties keep the structure but lose the colour line.

This is a sweep that touches many files lightly. Stretch goal — if the migration grows beyond ~30 minutes, defer the per-component migration to a follow-up and ship only the `@theme {}` registration in this brief. The registration alone enables future code to use the utilities without re-touching the inline-style files.

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

### Cross-cutting

- [ ] Full `bench/` build passes.
- [ ] `npm run build` succeeds.
- [ ] No shipped JSON modified by this brief.
- [ ] No re-capture required for any demo.
