# Crucible — Demo 05: plot the no-pressure baseline on the sweep lines

Implementation brief for Claude Code. Replaces the divergence-gate approach in the previous Demo 05 sweep brief with the version that actually shows the rise: each variant's no-pressure value becomes the leftmost point of its line. Touches `PressureSweepChart.tsx` and two prose passages in `05-allocators.mdx`. **Render + prose only — no JSON, no data change.** Supersedes `crucible-demo-05-sweep-reference-fix-brief.md` (its gate + dashed-reference machinery is removed here). Companion to `BRIEF.md`, `crucible-handover.md`.

## Context

The Demo 05 sweep numbers are correct against the committed June capture (`2026-06-05T06:07:50Z`, `turbo:false`/`cpb`). p99.9, from `05-allocators.json`:

- malloc: 344 (no pressure) → 376 across 100k–1.39M → 360 at 2.68M and up.
- freelist: 344 at every sweep point, no-pressure included.
- arena: 344 at every sweep point, no-pressure included.

The prose says malloc "rises from 344 … to 376 … then settles back to 360." Accurate, but **invisible on the chart**: "no pressure" is 0 ops/sec, which has no place on a log x-axis, so the no-pressure value is currently drawn as a horizontal dashed _reference_ (the previous brief's gate left only malloc's). The solid malloc line therefore starts at its first _pressure_ point (376) and only ever steps **down** to 360 — there is no upward segment anywhere on it. The "rise from 344" lives entirely in the gap between a dashed line and the 376 plateau; and because all three variants are 344 at no pressure, that dashed line reads as the pools' line, not malloc's baseline. The three lines never share a visible 344 origin even though all three baselines are 344.

The fix: stop drawing no-pressure as a reference and plot it as the **leftmost point of each variant's line**, at a categorical "none" slot left of the log scale. All three lines then start together at 344; malloc visibly climbs 344 → 376 → 360 while the pools run flat. The dashed-reference machinery is removed.

The working tree currently carries the previous brief's change (uncommitted): `REFERENCE_TOL_NS` at `PressureSweepChart.tsx:29`, the per-variant gate at `:165–194`, the legend gate at `:225`, and the matching "dashed line marks malloc's p99.9 …" prose. This brief replaces that approach.

## Preconditions

Before editing, re-confirm the committed JSON is the June boost-off capture. If it fails, **stop and report**.

```python
import json
d = json.load(open('site/src/data/perf/05-allocators.json'))  # adjust to repo path
assert d['captured_at'] == '2026-06-05T06:07:50Z'
assert d['machine']['turbo'] is False and d['machine']['turbo_source'] == 'cpb'
def p999(v, bg):
    return next(r['latency_ns']['stats']['p99_9'] for r in d['runs']
               if r['variant'] == v and r['background_pressure_hz'] == bg)
assert p999('cross-thread-malloc', None) == 344 and p999('cross-thread-malloc', 100000) == 376
assert p999('cross-thread-malloc', 2682695) == 360
assert p999('freelist-return-queue', None) == 344 and p999('arena-batch-handoff', None) == 344
print('JSON sentinel OK')
```

Confirm `05-allocators.mdx` is the June version (`date: "2026-06-05"`, contains `settles back to 360 from 2.7 M/s up`). If it's the May draft, **stop and flag**.

## Tasks

### 1. Plot each variant's no-pressure value as the leftmost point of its line

**File:** `site/src/components/charts/PressureSweepChart.tsx`.

**Remove** the dashed-reference machinery from the previous brief:

- `REFERENCE_TOL_NS` (`:29`), the per-variant divergence gate and `anyReferenceDrawn` tracking (`:165–194`), the reference-line draw itself, and the `anyReferenceDrawn`-gated "no pressure" legend entry (`:225`). The "no pressure" legend entry goes away entirely.

**Add** a no-pressure anchor to each variant's line:

- Introduce a categorical "none" x-position at the far left of the plot, left of the log scale's first tick, separated from the log region by a visible gap (a small axis break). It must not read as a numeric pressure value.
- For each variant, prepend `(x = none, y = that variant's no-pressure p99.9)` to its series — sourced from `baselineRuns` (the `background_pressure_hz == null` run), the same data the references used.
- Draw the connecting segment from the "none" anchor to the first log point (100k) so each line is continuous. Malloc's segment then visibly rises 344 → 376; the pools' segments are flat at 344.
- Label the "none" slot on the x-axis (e.g. `none` or `0`), visually distinct from the log ticks.

Recommended honest touch (implement or flag): render the bridge segment (none → 100k) dashed, since it crosses the axis break and isn't a continuous log interval. Keep the rest of each line solid in its series colour.

End state for Demo 05: three lines starting together at 344 on the left; malloc climbs to 376 across the band and steps to 360; freelist and arena flat at 344 (arena drawn over freelist). No horizontal dashed reference lines; no "no pressure" legend entry.

### 2. Update the two prose passages to the new chart convention

**File:** `05-allocators.mdx`. The malloc paragraph ("Its p99.9 rises from 344 … to 376 … settles back to 360") is now directly visible — **leave it unchanged**. Update the two passages that describe the dashed reference, which no longer exists. Hard-wrap to ~80 cols.

**2a. Intro parenthetical (line 164).** Find:

```
a no-T_bg baseline (the faint dashed reference line)
```

Replace with:

```
a no-T_bg baseline (plotted as each line's leftmost point, left of the log scale)
```

**2b. Reference-line paragraph (lines 185–187 — the "dashed line marks malloc's …" text from the previous brief).** Find verbatim:

```
The dashed line marks malloc's p99.9 with no background pressure (344 ns); the gap
up to its solid sweep line is the moderate-pressure rise. It's the only reference
drawn — both pools sit on 344 ns at every sweep point, baseline included, so their
no-pressure references coincide with their sweep lines and aren't shown separately.
```

Replace with:

```
Each line's leftmost point, set apart from the log scale, is that variant's p99.9
with no background pressure — all three sit at 344 ns, so the lines start together.
Only malloc departs from it, climbing to 376 ns under moderate pressure before
settling at 360; the pools stay on the 344 ns line across the whole sweep.
```

2b wording is the proposed editorial form — adjust before routing if you'd phrase it differently.

## Acceptance

### Site

- `cd site && npm run build` succeeds.
- Dashed-reference machinery is gone: `grep -n "REFERENCE_TOL_NS\|anyReferenceDrawn" site/src/components/charts/PressureSweepChart.tsx` returns zero hits.
- Visual: the malloc line has a visible upward segment from 344 (leftmost "none" anchor) to 376 (first pressure point); all three lines share the 344 left endpoint; no horizontal dashed reference line; no "no pressure" legend entry.
- The "none" anchor is visually separated from the log ticks (gap/break), not sitting on a numeric pressure value.

### Post

- `grep -n "faint dashed reference line\|The dashed line marks malloc\|references coincide with their sweep lines" 05-allocators.mdx` returns zero hits.
- `grep -n "plotted as each line's leftmost point\|the lines start together" 05-allocators.mdx` returns the two new passages.
- The malloc "rises from 344 … to 376 … settles back to 360" sentence is unchanged and now matches a visible upward segment.

## Out of scope

- Any change to `05-allocators.json` or other committed JSON. Data is correct; render + prose only.
- The numerical values 344 / 376 / 360 — they match the JSON; do not alter.
- The pools/malloc analysis paragraphs beyond 2a/2b — the malloc rise sentence stays as written.
- Cross-CCX section and its capture (`05-allocators-cross-ccx`).
- Refreshing the project-knowledge MDX snapshot (Opus/user task).
- Other demos' MDX/charts/JSON; series-palette / colour-blind work (separate brief).

## Open items for CC to flag

1. **JSON / MDX version.** If either Precondition fails (capture isn't the June boost-off corpus; MDX is the May draft), stop and report.
2. **Axis-break rendering.** The categorical "none" slot plus a clean break from the log scale is the one piece of real chart surgery. If the x-scale in `PressureSweepChart.tsx` doesn't accommodate a categorical leftmost slot without a larger refactor, implement the simplest honest version (a fixed left-margin slot with a gap before the log axis) and flag the approach rather than forcing a scale rewrite.
3. **Bridge-segment style.** If dashing the none→100k segment fights the existing line-rendering path, ship it solid and flag — the anchor point and the visible rise are the requirement; the dashed bridge is a nicety.
4. **Domain.** The current x-domain runs to 100M with no data past 10M. Tightening the log region to 100k–10M would use the space better but is optional — if you change it, say so; if not, leave it.
5. **Other consumers.** `PressureSweepChart` is used only by Demo 05 in the current MDX set. If the repo has another consumer, verify the no-pressure-anchor change is sensible there or scope it to Demo 05 and flag.
