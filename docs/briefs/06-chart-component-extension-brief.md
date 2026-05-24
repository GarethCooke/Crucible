# Crucible — Demo 6 chart-component extension brief (§5)

**Opus → CC handoff. Resolves §5 of `demo-06-plan.md`. Companion to the demo 6 MDX draft (`site/src/posts/06-aos-vs-soa.mdx` on the feature branch).**

---

## 1. Context

§5 of `demo-06-plan.md` poses the question: extend `<TimeVsN>` with cache-tier band markers, or introduce a new `<CacheStaircase>` component?

The headline capture (`site/src/data/perf/06-aos-vs-soa.json`, 135 retained rows) settles it on data shape. Three observations from the capture:

- **There is no staircase.** AoS K=1 across N shows an L2-resident floor (~1.3 ns) blending into an L3 plateau (1.48–1.51 ns, flat across the whole tier), one cliff at the L3→DRAM boundary (~4.1×), and a noisy DRAM band. The L1→L2 and within-L3 tiers don't earn distinguishable steps in `ns_per_op`. A component named `<CacheStaircase>` would render features the data doesn't contain.
- **The most useful overlay is a single L3 vertical line.** Optionally an L2 line as well, mostly to anchor the eye on the floor. Anything beyond that adds clutter for no information gain.
- **The supporting chart the post needs isn't a cliff view at all.** It's a K-sweep: AoS-vs-SoA at a fixed N (DRAM-bound), x-axis = K, y-axis = ns/element. Same underlying line-chart primitive as `<TimeVsN>`, different x-axis.

### Decision

**Extend `<TimeVsN>` additively. Do not introduce `<CacheStaircase>`.** Four new optional props (`kFilter`, `nFilter`, `xAxis`, `thresholdMarkers`). Existing demo 1 usage unchanged. One small addition to `<ThroughputBars>` (`kFilter` accepting an array) for the SIMD-comparison view. All other charts in the codebase untouched.

### Dependency on the MDX draft

The demo 6 MDX (separate file, on the feature branch) uses four chart embeds:

1. `<TimeVsN variants={["aos-scalar"]} kFilter={1} thresholdMarkers={[...]} />` — AoS K=1 cliff view.
2. `<TimeVsN variants={["soa-scalar"]} kFilter={1} thresholdMarkers={[...]} />` — same shape, SoA.
3. `<TimeVsN variants={["aos-scalar","soa-scalar"]} kFilter="all" nFilter={1048576} xAxis="k" />` — K-sweep, AoS vs SoA, at DRAM-bound N.
4. `<ThroughputBars variants={["soa-scalar","soa-autovec"]} targetN={1048576} kFilter={[1, 16]} />` — SIMD speedup at two K values.

This brief's contract is what those four embeds need. If CC implementation diverges from the contract, surface it before merging and the MDX is adjusted to match.

---

## 2. Goals

- `<TimeVsN>` supports filtering by K (single value or "all" for stacked lines), filtering by N (for K-sweep mode), x-axis swap to K, and one or two threshold markers per chart.
- `<ThroughputBars>` supports a K-value array, rendering side-by-side bar groups one group per K.
- Demo 1's existing `<TimeVsN>` invocations render identically. Demo 3's existing `<ThroughputBars>` invocations render identically.
- Threshold-marker positions are explicit (passed as props), not derived. Auto-derivation from `machine` block + per-variant byte footprint is a future-demo concern, not in scope here.

---

## 3. `<TimeVsN>` — additive props

### 3.1 Props interface

```ts
interface TimeVsNProps {
  slug: string;
  variants: string[];
  yAxisLabel?: string;
  title?: string;

  // additions:
  kFilter?: number | "all";
  nFilter?: number;
  xAxis?: "n" | "k";
  thresholdMarkers?: Array<{ label: string; n: number }>;
}
```

### 3.2 Behavioural contract

**`kFilter` — number, "all", or undefined.**

- `undefined` (default): preserve current behaviour. If the JSON's `runs[]` has no `k` field (demo 1's data), filter is a no-op. If `k` is present and multi-valued, current behaviour is undefined — flag during implementation; demo 6 always passes `kFilter` explicitly.
- `kFilter={1}` (numeric): include only runs where `run.k === 1`. One line per variant.
- `kFilter="all"`: include all K values from `runs[]`. One line per `(variant, k)` combination. See §3.3 for legend rules.

**`nFilter` — number or undefined.**

- `undefined` (default): all `n` values plotted on the x-axis (current behaviour when `xAxis="n"`).
- `nFilter={1048576}`: include only runs at this N. Required when `xAxis="k"` to collapse the N dimension.

**`xAxis` — "n" or "k", default "n".**

- `"n"` (default): N on x-axis. K on the line dimension (filtered or stacked per `kFilter`). Current behaviour.
- `"k"`: K on x-axis. N must be collapsed via `nFilter`; if `nFilter` is missing while `xAxis="k"`, render the `<NoData />` box and log a console warning. Don't render an arbitrary slice.

**`thresholdMarkers` — array of `{ label, n }` or undefined.**

- `undefined` (default): no markers (current behaviour).
- Array: render one vertical line per entry at x = `n` (when `xAxis="n"`). When `xAxis="k"`, ignore the array silently — these are N-domain markers, meaningless on the K axis.
- Labels are short strings the MDX provides ("L2", "L3"). The component doesn't compute them.

### 3.3 Legend rules when `kFilter="all"`

5 K values × 2 variants = up to 10 lines. Treatments to avoid an unreadable legend:

- Variant determines colour (existing variant-colour mapping in `theme.ts`).
- K determines line-style: K=1 solid, K=2 dashed, K=4 dotted, K=8 dash-dot, K=16 long-dash. (Adjust to whatever the existing chart-line vocabulary supports — the only constraint is that K is visually distinguishable within a variant.)
- Legend entry per `(variant, k)`: format `"aos-scalar (K=1)"`. Two-column legend if more than five entries, to stop horizontal overflow.
- If the chart library makes a clean K-fan-out impractical, fall back to: one chart per variant, K as the only line-dimension. Surface that during implementation and the MDX swaps to two adjacent `<TimeVsN>` invocations.

### 3.4 Visual contract for `thresholdMarkers`

- Render as a vertical line behind the data series (low z-order, drawn before the line traces).
- 1 px stroke, dashed pattern (4–2 or chart library's nearest equivalent).
- Colour: use a muted foreground token from `theme.ts` (whatever was added in pre-demo-5 brief 6 / brief 7 — a "subdued" or "muted-foreground" colour, theme-aware for light/dark modes). Not the variant palette.
- Label position: top of the line, offset 4 px to the right, vertically aligned to just below the chart's top padding. Small text (~10 px).
- If two markers have x-coordinates close enough that labels would overlap horizontally, the right marker's label moves below the left marker's label. Don't auto-hide.
- Markers don't appear in the legend.

### 3.5 The threshold values demo 6 passes

For reference (not part of the component contract — these come from the MDX):

```tsx
// AoS chart (struct size 128 B): L2 at N=4096, L3 at N=131072
thresholdMarkers={[
  { label: "L2", n: 4096 },
  { label: "L3", n: 131072 },
]}

// SoA K=1 chart (8 B per element): L3 at N=2097152 (off the right edge of the
// sweep — that's the point), L2 at N=65536
thresholdMarkers={[
  { label: "L2", n: 65536 },
  { label: "L3", n: 2097152 },
]}
```

CC: verify the SoA chart's L3 marker (N=2097152) renders gracefully when it sits beyond the chart's data extent. Acceptable behaviour: clipped at the right edge with the label suppressed; or the chart's x-axis auto-extends to include it. Don't crash; don't push the data off-axis.

---

## 4. `<ThroughputBars>` — additive prop

### 4.1 Props interface

```ts
interface ThroughputBarsProps {
  slug: string;
  variants: string[];
  targetN: number;
  title?: string;

  // addition:
  kFilter?: number | number[];
}
```

### 4.2 Behavioural contract

- `kFilter` undefined: current behaviour. If JSON has no `k` field, no-op.
- `kFilter={1}` (number): include only runs at K=1. One bar per variant.
- `kFilter={[1, 16]}` (array): render bars in groups, one group per K value. Each group shows all variants. Group label below the group: "K=1", "K=16".

### 4.3 Fallback if the array form is non-trivial

If the chart library's bar-grouping support requires non-trivial refactoring, fall back to splitting the MDX into two adjacent `<ThroughputBars>` calls with `kFilter={1}` and `kFilter={16}` respectively. Surface during implementation; the MDX adjustment is two lines.

---

## 5. Data shape assumptions

This brief assumes the captured JSON has the following per-run fields populated:

- `variant` (string) — `"aos-scalar"`, `"soa-scalar"`, `"soa-autovec"`.
- `n` (integer) — working-set size in elements.
- `k` (integer, 1–16) — fields-touched-per-element.
- `ns_per_op.median` (number) — the metric every chart in this brief reads.

If the captured JSON's K field is named differently (`fields_touched`, `k_hot`, etc.), use whatever name the JSON actually uses and adjust the prop name to match for consistency. The contract above uses `kFilter` because `k` is the natural reading; if the JSON field is `fields_touched`, rename to `fieldsFilter` and surface for MDX adjustment.

CC: confirm the field name in `site/src/data/perf/06-aos-vs-soa.json` before implementing and reconcile against this brief.

---

## 6. Acceptance criteria

- [ ] `<TimeVsN>` accepts `kFilter`, `nFilter`, `xAxis`, `thresholdMarkers`. All four are optional.
- [ ] Demo 1's existing `<TimeVsN>` invocations (`site/src/posts/01-branch-prediction.mdx`) render byte-identically before and after the change. Manual diff of dev-server output.
- [ ] `kFilter={1}` with demo 6 data renders one line per variant; `kFilter="all"` renders the K fan-out per §3.3.
- [ ] `xAxis="k"` with `nFilter={1048576}` renders K on the x-axis; missing `nFilter` produces the `<NoData />` box and a console warning, not a crash.
- [ ] `thresholdMarkers` renders per §3.4. Two markers ("L2", "L3") on the AoS K=1 chart in the demo 6 MDX preview render without label overlap.
- [ ] A `thresholdMarkers` entry beyond the data's x-extent doesn't crash, doesn't push data off-axis, and either clips the label or auto-extends the axis. Behaviour is documented in a one-line comment in the component.
- [ ] `<ThroughputBars>` accepts `kFilter` as number or array. If array form is implemented: bars render in groups per §4.2. If fallback path: surface and the MDX is updated to use two adjacent calls.
- [ ] Demo 3's existing `<ThroughputBars>` invocations render unchanged.
- [ ] `npm run build` from the feature branch passes with zero new warnings.
- [ ] Lighthouse score on the demo 6 preview page is within 5 points of demo 5's score, and no new layout-shift warnings appear. (Mirrors pre-demo-5 brief 8's a11y bar.)
- [ ] Markers, K-stacks, and threshold lines render correctly in both light and dark mode (pre-demo-5 brief 6's `useTheme` / `getColors` apparatus.)

---

## 7. Out of scope

- **A `<CacheStaircase>` component.** Decision above; the data has no staircase to render.
- **Auto-derivation of threshold positions** from `machine.l*_*_per_*` plus a per-variant `bytes_per_element` field. Defer to a future demo if its data shape demands it. The MDX passes explicit `n` values; that's enough.
- **N-06 — consolidating MDX chart usage onto `<Benchmark chart="...">`.** Tracked from the pre-demo-5 site review, not addressed by the chart-refactor brief that landed. Stays out of scope here; this brief extends the direct-chart-component surface that posts 01–03 already use. If N-06 lands later, the `kFilter` / `nFilter` / `xAxis` / `thresholdMarkers` props get forwarded through `<Benchmark>`'s dispatcher with no further chart-component change.
- **Cross-CCX / multi-thread chart shapes.** Same scope rule as demos 4 and 5.
- **A new `xAxis="bytes"` mode** (bytes-touched-per-element on x-axis). The K sweep delivers the same insight without a new axis kind.
- **Theme.ts changes** beyond reusing the muted-foreground token added in pre-demo-5 brief 6. If no such token exists, add one with the smallest viable diff and flag.

---

## 8. Notes for CC

- This is an additive change. The two existing chart components in scope (`<TimeVsN>`, `<ThroughputBars>`) gain optional props; existing invocations are not modified.
- The complexity budget for the whole brief is ~150 lines of TypeScript across the two component files plus theme additions. If your implementation exceeds 300 lines, stop and surface — something in the contract is harder than it looked and we want to discuss before merging.
- Implement `<TimeVsN>` first; the K-sweep and threshold-marker features are independent and can land in either order. `<ThroughputBars>` change is small and can land last.
- The demo 6 MDX (on the feature branch) is the integration test. After implementation, run the dev server against the feature branch and verify all four chart embeds render. Per-branch Amplify preview is the user-acceptance step.
- If anything in §3 or §4 conflicts with how the chart components are currently structured beyond ~20 lines of additive change to either file, surface and we adjust the brief — don't push a refactor through under the cover of this brief.
