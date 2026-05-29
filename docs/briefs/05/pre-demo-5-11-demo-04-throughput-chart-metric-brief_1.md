# Crucible — demo 4 throughput chart metric fix brief

**Pre-demo-5 brief 11. Switches the saturated throughput bar chart on `/posts/04-spsc-queue` from median ns/op to ops/sec, so the chart's metric matches its section heading, the surrounding prose, and the rest of the site's `throughput-bars` usage.**

---

## 1. Context

Task 11's hostile cross-read flagged a charting bug on `/posts/04-spsc-queue`:
the chart under `## Throughput` is titled "end-to-end tail latency" and shows bars
that range from 344 ns/op (hand-rolled) to 176,128 ns/op (mutex) — a 512×
visual ratio. Surrounding prose claims the gap between lock-free and mutex is
"often within a small multiple" and the lock-free win is "about determinism, not
raw rate." That contradiction is real: the chart is plotting per-item median
latency at saturation, while the section is talking about throughput.

CC's investigation confirmed:

- All three variants measure the same unit (single enqueue/dequeue pair). No bench harness asymmetry.
- The JSON contains `ops_per_sec` per variant per mode, computed as `total_items / wall_ns_total`. Hand-rolled and Boost both cap at ~14.7–14.9 M/s saturated; mutex caps at ~5.7 M/s.
- The chart title bug is downstream of `data.title` being a file-global string used by every chart in the post.

The chart is being plotted in the wrong space for its section. **Hand-rolled and Boost have essentially identical saturated throughput (within 1.4%)** — the 196× visual gap between their bars is queue residency, not rate. Mutex is the only variant whose *throughput* is materially lower (~2.6× lower than lock-free), which is the "small multiple" the prose refers to.

Cross-check against demo 3: its `chart="throughput-bars"` invocations plot options-per-second (titled "Options priced per second at N=16k…") and use "higher is better" framing. Demo 4 is the odd post out — same chart type, different metric. This brief brings demo 4 into line.

---

## 2. Investigation (must complete before implementation)

Before touching code, establish how the throughput-bars component currently picks its metric. The fix shape depends on what you find.

### 2.1 — How does demo 3's throughput-bars chart get to ops/sec?

**File:** `site/src/components/charts/ThroughputBarsChart.tsx` (or wherever the throughput-bars renderer lives — locate via the `chart="throughput-bars"` dispatch in `Benchmark.tsx`).

Read the component. Identify:

- Which field on the data object it reads to compute bar heights for demo 3.
- Whether demo 3's path is `targetN`-gated (`if (targetN) plot data.byN[targetN].ops_per_sec`) or mode-gated or unconditional.
- Whether the component has any awareness of `mode="saturated"` vs `mode="paced"`.

### 2.2 — How does demo 4's invocation currently land on median ns/op?

Same component, different result. Identify the branch in the component that fires for demo 4's props (`mode="saturated"`, no `targetN`, `stat="median"`).

Most likely answer: there's a `stat="median"`-driven branch that pulls `data.median_ns_per_op` (or similar) when no `targetN` is given. Confirm.

### 2.3 — Confirm `ops_per_sec` is at a reachable JSON path for demo 4 saturated mode

**File:** `site/src/data/perf/04-spsc-queue.json`.

Locate the saturated-mode entries for each of the three variants. Confirm each carries an `ops_per_sec` field (CC's earlier report says it does — verify the path). Note the exact JSON path so it can be referenced in the component change.

If the field is named differently than demo 3's (e.g. `throughput_ops_s` vs `options_per_sec`), that mismatch is the underlying cause — and the fix becomes "make the JSON field name consistent" rather than "change the component". Decide which side to harmonise; the JSON side is preferable (data layer should be canonical, components shouldn't have to know per-demo field names).

### 2.4 — Decide on fix shape

Two options depending on what 2.1–2.3 reveal:

- **(i) The component already supports ops/sec given the right input.** Then the fix is purely on the MDX/JSON side: pass the right prop, or rename the JSON field, or both.
- **(ii) The component is hardcoded to plot ns/op for the demo-4 prop combination.** Then the component needs an extra branch (or, better, a `metric` prop that selects).

Write a one-paragraph finding in the chat before implementing — same shape as the previous investigation note. User signs off, then proceed to §3.

---

## 3. Implementation

The exact patches depend on §2's findings. The shape below is the most likely path; adjust if investigation reveals a different structure.

### 3.1 — Component change (if needed)

If §2.4 lands on option (ii), the cleanest fix is a new `metric` prop on `ThroughputBarsChart` that defaults to whatever demo 3 currently uses (probably `ops_per_sec`). Demo 4's MDX then passes `metric="ops_per_sec"` explicitly.

If the component already does the right thing for an `ops_per_sec`-shaped data path (option (i)), no component change — go to §3.2.

### 3.2 — MDX change in `04-spsc-queue.mdx`

**Location:** lines 168–174 (the saturated throughput-bars chart, currently the only chart in the `## Throughput` section).

**Find:**

```mdx
<Benchmark
  slug="04-spsc-queue"
  chart="throughput-bars"
  mode="saturated"
  variants={["lockfree-handrolled", "lockfree-boost", "mutex-condvar"]}
  stat="median"
/>
```

**Replace with** (exact form depends on §3.1's resolution — the form below assumes a `metric` prop was added; drop `metric=` if the component picks unconditionally):

```mdx
<Benchmark
  slug="04-spsc-queue"
  chart="throughput-bars"
  mode="saturated"
  variants={["lockfree-handrolled", "lockfree-boost", "mutex-condvar"]}
  metric="ops_per_sec"
  title="Saturated throughput (ops/sec, producer flat-out — higher is better)"
/>
```

Removed `stat="median"` (only meaningful for histogram-derived metrics, irrelevant for a derived rate). Added explicit `title` (also fixes the C-1-adjacent bug CC identified — demos that don't pass `title` inherit the misleading file-global `data.title`).

### 3.3 — Y-axis number formatting

The bars will now run 0 → ~15 M ops/sec. Confirm the chart's y-axis formatter handles M/G suffix gracefully (look for an existing pattern in demo 3's throughput-bars chart — its bars are in the 10⁷–10⁸ range and already render cleanly, so the formatter probably already does the right thing). If demo 3 shows "1.50 × 10⁸ ops/sec" cleanly, demo 4 will too. If demo 3 has hardcoded formatting that doesn't extend, add an explicit formatter to the component.

### 3.4 — Prose changes in `04-spsc-queue.mdx`

**Location:** lines 176–184 (the prose paragraph immediately under the chart).

**Find:**

```
Saturated throughput: the producer runs flat-out with no pacing. The gap between
lock-free and mutex is smaller than the tail gap — often within a small multiple. The mutex fast path (lock uncontested, no condvar wake-up) is cheap. The cost
shows up as determinism, not rate.

A nuance on the throughput numbers above: they reflect _steady-state_ behaviour with the producer flat-out and the queue at capacity. For Boost specifically, this slightly understates peak rate — the load sweep shows it transiently reaching ~19.8 M/s when the queue is at intermediate depth, before settling into the lower steady-state rate as the queue fills. The hand-rolled variant doesn't show this gap because its queue never reaches capacity (see the saturation discussion above). Mutex doesn't show it because its steady-state and transient rates are both bound by condvar wake-up cost, which doesn't vary with queue depth.

**The lock-free win is about determinism, not raw rate.**
```

**Replace with:**

```
Saturated throughput: the producer runs flat-out with no pacing. Hand-rolled and
Boost cap at near-identical rates — 14.7 M/s and 14.9 M/s respectively, within
1.4%. Both are limited by the producer's per-iteration cost (timestamp, `try_push`,
spin) rather than anything queue-implementation-specific. The latency distribution
is what separates them under load (see the histograms above): Boost runs with its
queue near capacity at saturation, hand-rolled with its queue near empty, so an
item resident in Boost's queue waits ~200× longer end-to-end. Same throughput,
very different residency.

Mutex caps lower, at ~5.7 M/s — about 2.6× slower than lock-free. That's the
"small multiple" rate gap: small enough that a throughput-only view would
undersell how different these queues actually are. The tail-latency view
above is where the gap explodes by orders of magnitude.

A nuance for the Boost number: the steady-state ~14.9 M/s shown here is slightly
below its transient peak — the load sweep shows Boost briefly reaching ~19.8 M/s
when the queue is at intermediate depth, before settling lower as the queue fills.
Hand-rolled doesn't show this gap because its queue never fills. Mutex doesn't
show it because both steady-state and transient rates are bound by condvar
wake-up cost, which is depth-independent.

**The lock-free win is about determinism, not raw rate.**
```

The new prose makes three substantive improvements over the old:

1. States the hand-rolled / Boost throughput tie explicitly — a finding the chart now visualises and the old prose only implied.
2. Explains *why* Boost's bars in earlier charts look so much worse despite identical throughput (queue residency, not rate).
3. The "small multiple" line is now attached to the correct comparison (lock-free vs mutex, 2.6×) rather than implicitly applied to the visually-512× chart it sits under.

---

## 4. Acceptance criteria

- [ ] **Investigation note posted in chat** before any code changes, summarising §2.1–§2.3 findings and confirming §2.4's choice between options (i) and (ii).
- [ ] Demo 4's throughput chart renders three bars in ops/sec: hand-rolled and Boost roughly equal at ~14.7–14.9 M/s, mutex at ~5.7 M/s. Bar order matches the MDX `variants` array (hand-rolled, Boost, mutex).
- [ ] Chart title reads "Saturated throughput (ops/sec, producer flat-out — higher is better)" — not "end-to-end tail latency".
- [ ] Y-axis labels are human-readable (e.g. `15 M`, `10 M`, `5 M`, `0`), not raw integers (`14735844`).
- [ ] **No regression in demo 3's throughput-bars charts.** Specifically the L2-resident and fully-amortised charts on `/posts/03-simd-blackscholes` should render identically to before this PR. If a component change was needed (option ii), verify by side-by-side screenshot.
- [ ] Prose under the chart (lines ~176–190 post-edit) flows naturally, mentions the hand-rolled/Boost throughput tie, and attaches the "small multiple" framing to the mutex-vs-lock-free comparison rather than to the visual ratio.
- [ ] `npm run build` clean. Dev server renders the page without console errors.
- [ ] `git diff --stat` shows changes confined to: `04-spsc-queue.mdx`, optionally `ThroughputBarsChart.tsx` (if §3.1), optionally `Benchmark.tsx` (if a new prop needed plumbing), optionally `site/src/data/perf/04-spsc-queue.json` (only if §2.3 found a JSON field rename was the cleanest fix). No bench-side files touched. No other MDX files touched.

---

## 5. Out of scope

- **The hostile-cross-read cleanup brief (`pre-demo-5-10-…`).** Lands after this, so the demo 4 prose edits there (Setup trim, "similarly close" rephrase, etc.) apply to whatever shape demo 4 settles into post-this-brief.
- **Other charts on demo 4.** The latency-histogram CCDF/PDF, the latency-vs-load sweep, and the counter overlays are not in scope. They show what they should show; only the saturated throughput chart had this metric/section mismatch.
- **Other posts' chart metrics.** Verified by cross-check: demo 1's throughput-bars and time-vs-n charts, demo 2's counter overlays and throughput bars, demo 3's two throughput-bars charts. None show the same mismatch. Only demo 4's saturated throughput chart was affected.
- **JSON regeneration / recapture.** The data is fine; only the rendering metric is wrong. No bench rerun needed.

---

## 6. Notes for CC

The investigation step is load-bearing — do not skip it. Posting the §2 findings in chat before implementing gives user one shot to redirect if the fix shape turns out to be different than this brief's most-likely-path guess. Specifically: if §2.3 reveals the JSON field is named something other than `ops_per_sec` for demo 4, or if demo 3 and demo 4 use *different* JSON field names for the same conceptual metric, that's a finding that wants user input before patching.

Sanity check after rendering: bar heights for the two lock-free variants should be visually indistinguishable (within 1.4%). If hand-rolled comes out visually 5× shorter than Boost, you've plotted the wrong field — likely the median ns/op of a different mode, or `1 / ns_per_op` instead of `ops_per_sec`. The number 14.7 M/s and 14.9 M/s should appear as labels above the lock-free bars; if they don't, stop and re-check.

After this lands and the hostile-cross-read cleanup lands, the pre-demo-5 review work is done except for task 12 (Amplify deploy verification, user manual). At that point demo 5 scoping opens.
