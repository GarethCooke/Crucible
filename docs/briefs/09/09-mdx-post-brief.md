# Crucible — Demo 09 §8: MDX post (replace the teaser stub)

Implementation brief for CC, drafted by Opus. Replaces the teaser stub
`site/src/posts/09-arm-neon.mdx` on the demo-09 feature branch with the shipped post.
Companion to `09-arm-neon-brief.md` (§3, the implementation spec) and
`crucible-demo-09-chart-and-probe-fixes-brief.md` (chart palette + probe + notes). Lives in
`docs/briefs/09/`. Does **not** merge to main — that's §11 (user). See `demo-09-plan.md` §8.

## Context

- The §7 headline capture is committed and verified: `site/src/data/perf/09-arm-neon.json`,
  `captured_at` 2026-06-02. All numbers below are from that file — **CC must re-derive every
  figure in prose from the JSON, not from this brief**, to one significant figure.
- The chart palette is in place (`theme.ts`): `scalarlibm`→series[0], `scalarpoly`→series[1],
  `sse2`/`neon`→series[2], `avx2fma`→series[3], `autovec`→series[4]. Demo 9's four keys resolve
  to four distinct colours; `neon` deliberately shares SSE's colour for the cross-arch pairing.
- The post currently rendering is the teaser stub: `status: "in-progress"`, `<InProgressNotice>`,
  an `expectedAt`/"what this will cover" body. This brief overwrites that body wholesale.
- Three editorial decisions are settled (Gareth): (1) autovec gets **its own chart line**;
  (2) the scalar_poly ~6% algorithm-win is **shown in the body**; (3) a **CodeCompare** panel
  (scalar vs `float32x4_t` NEON) is included.

## The post — thesis and what it must say

**Headline — the width ceiling.** The Cortex-A76 is NEON-only: 128-bit, 4-wide float32, the
same width as SSE, no SVE. The Black-Scholes call-pricing kernel tops out near 4× over scalar
and stays there — no wider unit to reach for, where the Zen 2 box (demo 3) went on to AVX2.
The punchline: vector width is an architectural property you don't get to assume.

**The numbers (from the JSON — CC verifies):**

- NEON over scalar (poly): **≈4.3× at 16k (4.34×) rising to ≈4.8× at 1M (4.81×)**; 4.76× at
  262k. This is the headline ratio, on the `scalarpoly` denominator (same kernel as NEON).
- At N=1024 the ratio is only **≈3.1× (3.06×)** — below ceiling because fixed per-call
  overhead dominates when the kernel is tiny; it amortises out by 16k. Name this so the small-N
  point doesn't read as contradicting the ceiling.
- NEON ns/op is flat (~14 ns: 14.09 at 16k, 13.60 at 262k, 13.70 at 1M); scalar (poly) sits
  ~61–66 ns. GFLOPs ~9 (NEON) vs ~1.5 (scalar).
- **The algorithm-win decomposition (body, per decision 2):** `scalar_libm` → `scalar_poly` is
  a ~6% win (6.4% at 16k, 6.2% at 1M) from replacing libm `exp`/`erfc` with inlined polynomials.
  `scalar_poly` → NEON is the ~4.3–4.8× **width** win. The headline denominator is `scalar_poly`
  because NEON _is_ the 4-lane poly kernel — measuring against `scalar_libm` would give a larger
  number (4.6× at 16k → **5.1×** at 1M) that folds the algorithm win into "width" and reads as
  beating the 4-wide ceiling. State this explicitly: the honest width number uses the same-kernel
  baseline.
- **autovec (per decision 1, its own line):** `autovec` is within **0.08%** of `scalar_libm` at
  every N — GCC did not vectorise it (`-O3` on an `-mcpu=cortex-a76` target). The committed asm
  confirms the autovec loop is scalar (no `.4s` ops; the `logf@plt` barrier blocks the
  autovectoriser). So the chart shows autovec's line sitting _on top of_ scalar_libm — the visual
  point being that on AArch64, where SIMD is on by default at `-O3`, the compiler still couldn't
  cross the transcendental-call barrier, and the hand-written intrinsics are doing real work the
  autovectoriser cannot.
- **Correctness:** NEON and scalar_poly agree with the libm reference to `max_abs_error`
  5.722e-05 (< 1e-4 tolerance); autovec and scalar_libm are bit-exact (0.0). The SIMD win is not
  bought with accuracy.

**What the post does NOT claim** (must be a named section, mirroring the plan story angle):

- No cross-machine absolute ns/op comparison — different clocks, nodes, memory. The only portable
  quantity across the Pi and the Zen 2 box is the within-machine speedup ratio.
- Not that ARM is "fast" or "slow", nor that this generalises to all of ARM — it is A76-specific.
  A core _with_ SVE would scale past the 4-wide ceiling; that's a possible sequel, not this post.

## Tasks

### 1. Frontmatter

Strip the teaser fields and promote to a shipped post. Remove `status: "in-progress"` and
`expectedAt` (and any `<InProgressNotice>` import/usage in the body). Match the frontmatter
shape of the most recently shipped post (demo 8, `08-sorting-shootout.mdx`) field-for-field —
`title`, `date`, `summary`/`description`, `tags`, ordering index, whatever demo 8 carries.
**Grep demo 8's frontmatter and mirror its keys**; do not invent fields.

### 2. Body — adapt demo 7/8 section structure

Mirror the section skeleton of `08-sorting-shootout.mdx` (intro → setup/workload → results with
charts → mechanism → what-this-doesn't-claim → reproducing → footer). Write the prose to the
thesis and numbers above. Required body elements:

- Intro framing the width ceiling (not "SIMD works on ARM" — demo 3 proved vectorisation).
- A short **decomposition** passage: algorithm win (~6%, scalar_libm→scalar_poly) vs width win
  (~4.3–4.8×, scalar_poly→NEON), and why the headline uses the scalar_poly denominator.
- The **autovec** aside: GCC didn't vectorise; the line coincides with scalar_libm; asm-confirmed.
- The **small-N** caveat: 1k is ~3.1× because fixed per-call overhead dominates; amortises by 16k.
- A **"What this doesn't show"** section per the bullets above (cross-machine, A76-specific, SVE).

### 3. Charts — direct components, all four variants

Use the direct `<ThroughputBars>` / `<TimeVsN>` components (the demo 7/8 path), **not**
`<Benchmark>` (it drops `variantLabels` and would render `capitalize`d raw keys). Pass
`variantLabels` mapping the no-underscore JSON keys to display names, e.g.
`{ scalarlibm: 'scalar (libm)', scalarpoly: 'scalar (poly)', autovec: 'autovec −O3', neon: 'NEON (hand)' }`
— confirm the display strings with Gareth's preference at review if unsure, but the keys must be
the no-underscore JSON forms.

- **`<TimeVsN slug="09-arm-neon">`** — the N-sweep, all four variants, `stat="median"`,
  `xAxis="n"`, `xScale="log"`, `yAxisLabel` in ns/option. This is the ceiling visual: NEON flat
  ~14 ns, the three scalar lines bunched ~61–73 ns, **autovec's line on top of scalar_libm**
  (decision 1). Keep y-axis linear so the ~4–5× gap is visceral; note `yAxisLog` as a fallback
  if the bunching is unreadable.
- **`<ThroughputBars slug="09-arm-neon">`** — per-variant ns/op at the headline N
  (`targetN={16384}`), all four variants, so the reader can read the 4.3× directly; optionally a
  second instance at `targetN={1048576}` for the memory-bound point. Within-machine absolute ns is
  fine here (same machine).
- **Cross-arch ratio view** — the Pi NEON ratio vs the Zen 2 demo-3 AVX2/SSE ratios. This is the
  one place a cross-machine comparison appears and it must be **ratio-only, never absolute ns/op**.
  Per §6, compose from existing components or a small ratio table — **do not fork a bespoke chart**.
  CC must pull demo 3's ratios from `03-simd-blackscholes.json` (grep its `runs[]`), not from the
  plan's prose estimates. See Open items.
- **`<CounterOverlay>`** — include **only** if the JSON carries branch-miss / cache-miss
  counters. The committed `09-arm-neon.json` runs carry `instructions_per_cycle` but not
  miss-counters; if that's all there is, either render an IPC-only overlay or omit the panel.
  Do not fabricate counters. (Plan A1.)

### 4. CodeCompare panel (decision 3)

Add a `<CodeCompare>` panel contrasting the scalar kernel with the `float32x4_t` NEON kernel.
Pull both snippets **verbatim from the committed source** under `bench/demos/09-arm-neon/` — do
not paraphrase or reconstruct the code. Match how demo 3 uses `<CodeCompare>` (it has the
analogous scalar-vs-SSE/AVX2 panel); mirror its props and snippet length.

### 5. Cross-links

- **Backward link, demo 9 → demo 3** (mandatory, per plan §8): the x86 SIMD sibling, same kernel,
  different ISA — the width-ceiling contrast is the spine of the pairing. Place per the demo 7/8
  cross-link convention.
- **Forward link, demo 3 → demo 9:** the plan (§8) calls for this, **but** open item §68 says the
  demo-3 forward-link is batched into `demo-03-batched-edit-brief.md`. **Do not add it here
  without checking** whether that brief already specs/applies it — see Open items. Avoid a
  double-applied or conflicting link.
- Standard nav/cross-links to the conventional anchor demos per the demo 7/8 footer pattern.

### 6. Footer (standardised)

Demo 8's cross-read flagged a missing standardised footer as a material finding — demo 9 must
ship with the full footer. Reflect the **Pi** machine block, not the Zen 2 one: Cortex-A76 /
BCM2712 / Pi 5, the Pi kernel and GCC version from the JSON `machine` block, `isolated_cpus`
`2-3`, capture pinned to core 3 (`taskset -c 3`), turbo off via pinned 2400 MHz clock +
`get_throttled=0x0` (not the Zen 2 `CRUCIBLE_TURBO=off`). Pull every footer value from the JSON
`machine` block verbatim. Methodology link in the same form as demo 8's footer.

### 7. Summary table

A small per-variant summary (mirror demo 8's takeaway/summary block): variant, display name,
ns/op at the headline N, ratio vs scalar_poly. Every cell grounded in the JSON.

### 8. Methodology page — second reference machine

Document the Pi as the second reference machine (Cortex-A76 / BCM2712 / AArch64, the Pi-specific
isolation mechanism: `isolcpus=2,3` + `taskset -c 3` + IRQ affinity, clock-pin instead of
`cset`/`CRUCIBLE_TURBO`), and **bump the demo total to 9**. Locate the demo-count and machine
description in the methodology page and update both. Do not restructure the page.

## Acceptance

### Post

- `grep -n 'in-progress\|expectedAt\|InProgressNotice' site/src/posts/09-arm-neon.mdx` → 0 hits.
- The post imports and renders `<ThroughputBars>` and `<TimeVsN>` (not `<Benchmark>`); both pass
  `variants` and `variantLabels` keyed by `scalarlibm`/`scalarpoly`/`autovec`/`neon`.
- A `<CodeCompare>` panel is present with scalar and NEON snippets that match the committed
  `bench/demos/09-arm-neon/` source (diff the snippet against the file).
- The "what this doesn't show" section is present and names: no cross-machine absolute ns/op;
  A76-specific; SVE caveat.

### Numbers (all grounded in `09-arm-neon.json`, 1 sig fig)

- Headline ratio in prose = `scalarpoly.median / neon.median` at the cited N: 4.3× at 16384,
  4.8× at 1048576. No `5×`/`5.1×` stated as the _width_ result (5.1× may appear only when
  explicitly labelled as the libm-baseline figure that folds in the algorithm win).
- The ~6% algorithm-win figure = `(scalarlibm − scalarpoly)/scalarlibm` at the cited N.
- autovec-vs-scalar_libm stated as within ~0.1% / "did not vectorise"; matches the JSON medians.
- Correctness figure 5.722e-05 matches `max_abs_error_vs_scalar_libm` for neon/scalarpoly.
- Footer machine values match `.machine` verbatim (CPU, kernel, compiler, `isolated_cpus`,
  governor, turbo).

### Cross-arch / methodology

- The cross-arch view shows **ratios only**; `grep` the post for any sentence comparing Pi and
  Zen 2 **absolute** ns/op → must be none.
- Demo 3's ratios in the cross-arch view derive from `03-simd-blackscholes.json`, not from prose.
- Methodology page demo count reads 9; the Pi machine is described.

### Build

- `cd site && npm run build` succeeds; `/posts/09-arm-neon` renders without a NoData panel on any
  chart.

## Out of scope

- Merging to main, the Amplify deploy, and the live-site check (§11/§12 — user).
- Re-capturing or editing `09-arm-neon.json` timing data — it is verified and frozen.
- The §9 hostile cross-read and §10 pre-merge review — separate tasks after this lands.
- Demo 3's prose, data, or code **except** the single forward-link — and even that only if it is
  _not_ already owned by `demo-03-batched-edit-brief.md` (see Open items).
- The `bench/common/poly.h` decoupling refactor — tracked post-ship (`bench-common-polyh-split-stub.md`).
- Any change to the chart components, `theme.ts`, or `Benchmark.tsx` — the fixes brief owns those.
- Re-running the §7 capture for any reason.

## Open items for CC to flag

1. **Demo-3 forward-link ownership.** If `demo-03-batched-edit-brief.md` already specifies or has
   applied the demo 3 → demo 9 forward-link, **do not add it again** — note that it's handled
   there and skip Task 5's forward-link. If neither brief has applied it, add it here and say so.
   Do not leave demo 3 with two forward-links or none.
2. **Demo-3 cross-arch numbers.** Pull SSE/AVX2 ratios from `03-simd-blackscholes.json`. If demo
   3's variant set or N-grid doesn't line up with demo 9's (so a like-for-like ratio comparison
   isn't clean), **stop and report** the mismatch rather than forcing a comparison — the
   cross-arch view is the honesty-critical panel.
3. **Counter overlay.** If `09-arm-neon.json` has no branch/cache-miss counters, decide IPC-only
   vs omit and note which; do not synthesise counter data. (Plan A1.)
4. **CodeCompare source.** If the scalar and NEON kernels aren't cleanly separable into two
   comparable snippets (e.g. heavy shared scaffolding), flag it and propose the snippet boundaries
   rather than trimming silently.
5. **variantLabels display strings.** The keys are fixed (no-underscore JSON forms); the human
   labels are editorial. If unsure of Gareth's preferred wording, use the defaults above and
   surface the choice at review.
6. **§3 brief reconciliation.** This brief was scoped from `demo-09-plan.md` and the JSON, not
   from `09-arm-neon-brief.md` directly. If the §3 brief's section structure or claims differ from
   what's specified here, **follow §3 and report the delta** — §3 is the implementation contract.
