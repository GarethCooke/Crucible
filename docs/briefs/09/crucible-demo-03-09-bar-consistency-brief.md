# Crucible — Demo 03 ↔ Demo 09 throughput-bar consistency + caption fix

Patch brief for CC, drafted by Opus. Aligns the demo 03 and demo 09 throughput-bar charts so
the cross-arch pairing reads consistently (matching order, labels, and the already-correct
cross-arch palette), and fixes a caption/metric mismatch on demo 03's headline chart. Lands on
the demo-09 feature branch alongside the §8 post. Companion to `09-mdx-post-brief.md` and
`crucible-demo-09-chart-and-probe-fixes-brief.md` (which set the shared `theme.ts` palette).
Does not merge to main (§11, user).

## Context

The cross-arch colours are already correct (`theme.ts`: libm→series[0] cyan, poly→series[1]
red, `sse2`/`neon`→series[2] yellow, `avx2fma`→series[3], `autovec`→series[4]). The remaining
inconsistency is **bar order** and **labels**, caused by the two demos using different chart
components:

- Demo 03 renders via `<Benchmark slug="03-simd-blackscholes" chart="throughput-bars">`.
  `Benchmark.tsx` filters by `variants` but does **not** reorder to the caller's order, and
  passes no `variantLabels` to `ThroughputBarsChart` — so demo 03 shows alphabetical order
  (`avx2fma, scalarlibm, scalarpoly, sse2` — SIMD bars split to opposite ends) with raw
  `capitalize`d labels (`Scalarlibm`, `Avx2fma`).
- Demo 09 uses the direct `<ThroughputBars>` component, which honours `variants` order and
  `variantLabels`.

Fix: move demo 03's throughput-bars to the same direct `<ThroughputBars>` component demo 09
uses, with an explicit width-progression order and matching `variantLabels`. This fixes order
and labels in one move and makes cyan/red/yellow land in the same positions in both charts.

Separately, demo 03's headline chart caption describes a throughput metric ("Options priced
per second … higher is better") while the bars plot `ns/op` (lower is better). Correct the
caption to match the metric actually shown.

## Tasks

### 1. Demo 09 — pin the throughput-bar order

In `site/src/posts/09-arm-neon.mdx`, set the `<ThroughputBars>` `variants` prop order to:

```
variants={['scalarlibm', 'scalarpoly', 'neon', 'autovec']}
```

(scalar → scalar → 4-wide SIMD → autovec). Leave `variantLabels` as shipped
(`scalar (libm)`, `scalar (poly)`, `NEON (hand)`, `autovec −O3`). Apply to every
`<ThroughputBars>` instance in the post (both the N=16,384 and N=1,048,576 panels if both
exist) so the order is identical across them.

### 2. Demo 03 — switch to the direct component, matching order + labels

In `site/src/posts/03-simd-blackscholes.mdx`, replace the throughput-bars `<Benchmark>` usage:

Find (the throughput-bars Benchmark call — match the actual attributes in the file; this is the
shape, not a verbatim quote):

```mdx
<Benchmark slug="03-simd-blackscholes" chart="throughput-bars" ... />
```

Replace with the direct component:

```mdx
<ThroughputBars
  slug="03-simd-blackscholes"
  variants={["scalarlibm", "scalarpoly", "sse2", "avx2fma"]}
  variantLabels={{
    scalarlibm: "scalar (libm)",
    scalarpoly: "scalar (poly)",
    sse2: "SSE2",
    avx2fma: "AVX2+FMA",
  }}
  targetN={16384}
/>
```

Notes:

- Order is scalar → scalar → 4-wide (SSE2) → 8-wide (AVX2), matching demo 09's positions 1-3
  (libm, poly, 4-wide) so cyan/red/yellow align across the two charts.
- Carry over any props the original `<Benchmark>` call set that still apply (`stat`, `title`,
  `targetN`/`n`). If the original used `n=` rather than `targetN=`, use `targetN=` (the direct
  component's prop). Preserve whatever N the demo 03 chart was already showing — do **not**
  change which N is displayed.
- Ensure `<ThroughputBars>` is imported in `03-simd-blackscholes.mdx` (demo 09 shows the import
  path; mirror it). If demo 03 has more than one throughput-bars chart, apply the same swap to
  each, keeping the same `variants` order.
- `variantLabels` display strings: match demo 09's casing/style. `sse2`/`avx2fma` have no demo-09
  counterpart, so `SSE2` / `AVX2+FMA` are proposed — if Gareth prefers other wording, that's an
  editorial tweak (see Open items).

### 3. Demo 03 — fix the headline-chart caption/metric mismatch

In `03-simd-blackscholes.mdx`, the headline throughput-bars chart's caption reads to the effect
of "Options priced per second … (higher is better)" while the chart plots median `ns/op` (lower
is better). Correct the **caption text** to describe `ns/op` / lower-is-better (e.g. "Median
ns/option at N=16k — L2-resident, compute-bound (lower is better)"), matching the metric the
chart actually renders. Do not change the chart's metric or data — only the caption prose.
If, instead, the _intent_ was a per-second throughput chart, **stop and flag** rather than
guessing which way to reconcile (see Open items).

## Acceptance

- `grep -n "chart=\"throughput-bars\"" site/src/posts/03-simd-blackscholes.mdx` → 0 hits (the
  `<Benchmark>` throughput-bars usage is gone); `<ThroughputBars` is present with
  `variants={['scalarlibm', 'scalarpoly', 'sse2', 'avx2fma']}` and a `variantLabels` map.
- `grep -n "variants={\['scalarlibm', 'scalarpoly', 'neon', 'autovec'\]}" site/src/posts/09-arm-neon.mdx`
  → matches every `<ThroughputBars>` instance.
- Rendered order, both posts (visual check on the branch deploy):
  - Demo 03: scalar (libm), scalar (poly), SSE2, AVX2+FMA — cyan, red, yellow, purple, descending.
  - Demo 09: scalar (libm), scalar (poly), NEON, autovec − cyan, red, yellow, blue.
  - The cyan / red / yellow bars occupy positions 1 / 2 / 3 in **both** charts.
- Demo 03 labels render as `scalar (libm)` / `scalar (poly)` / `SSE2` / `AVX2+FMA` — no raw
  `Scalarlibm` / `Avx2fma` capitalized keys.
- Demo 03's headline-chart caption states `ns/op` / lower-is-better, consistent with the bars.
- `cd site && npm run build` succeeds; both posts render with no NoData panel.

## Out of scope

- The cross-arch palette in `theme.ts` — already correct; do not touch.
- Any demo 03 prose, data, or other charts beyond the throughput-bars component swap and the one
  caption sentence. In particular: demo 03's `<TimeVsN>` / `<CodeCompare>` / counter charts, its
  numbers, and its JSON are untouched.
- Demo 03's forward-link to demo 09 (already applied per `demo-03-batched-edit-brief.md`).
- Re-capturing or editing any JSON.
- Merge / deploy / live-site check (§11/§12, user).

## Open items for CC to flag

1. **Demo 03 N / props parity.** If the original demo 03 `<Benchmark>` throughput-bars call
   showed an N other than 16,384, preserve that N in the `<ThroughputBars>` swap — do not
   silently change which N is displayed. If demo 03 has two throughput panels at different Ns,
   keep both, same variant order.
2. **Caption intent.** If the demo 03 headline chart was meant to be a per-second throughput
   view (higher-is-better) rather than ns/op, **stop and flag** — the fix is then a metric/axis
   change, not a caption edit, and that's a different decision. Default assumption: the bars
   (ns/op) are right and the caption is stale.
3. **`variantLabels` wording for SSE2/AVX2.** `SSE2` / `AVX2+FMA` are proposed; if Gareth's
   preferred labels differ, use those. Keys (`sse2`, `avx2fma`) are fixed — they must match the
   demo 03 JSON variant strings exactly (confirmed: `sse2`, `avx2fma`).
4. **Other `<Benchmark>` usages in demo 03.** This brief swaps only the throughput-bars chart. If
   demo 03 uses `<Benchmark>` for other chart types (latency, counter), leave those as-is — they
   don't have the order/label problem and aren't part of the pairing.
