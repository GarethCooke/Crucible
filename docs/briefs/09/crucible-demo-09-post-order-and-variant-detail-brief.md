# Crucible — Demo 09 post: variant order + variant descriptions

Patch brief for CC, drafted by Opus. Three edits to the demo 09 post on the feature branch:
(1) revert the throughput-bar order so NEON is last, (2) enforce a single variant order across
chart, table, and prose, (3) expand the "Four variants" section with a real description of each.
Supersedes the demo-09 ordering set in `crucible-demo-03-09-bar-consistency-brief.md` (Task 1,
demo-09 part only — demo 03's order there stays). Does not merge (§11, user).

## Context

The bar-consistency brief set demo 09's `<ThroughputBars>` order to
`['scalarlibm', 'scalarpoly', 'neon', 'autovec']` — NEON in position 3, autovec last. That
leaves a tall scalar-speed `autovec` bar dangling after the short NEON bar (the chart drops then
jumps back up), and it disagrees with the variants table, which reads `libm, autovec, poly, neon`.

The canonical order is **`scalarlibm, autovec, scalarpoly, neon`** — slowest→fastest (65.37,
65.37, 61.19, 14.09 ns at 16k), NEON (the payoff) last, autovec adjacent to its identical libm
twin. This is the same slowest→fastest principle demo 03 uses (`libm, poly, sse2, avx2fma`), and
it tells the ceiling story when the two charts sit side by side: both reach the yellow 4-wide bar;
demo 03 continues to a purple AVX2 bar; demo 09 stops at yellow — the absent bar is the ceiling.

The 4th-bar colour difference (demo 09 NEON = yellow last; demo 03 AVX2 = purple last) is
**intentional and must not be "fixed"** — yellow = the 4-wide step (SSE/NEON, the cross-arch
match), purple = the 8-wide AVX2 step that has no ARM counterpart. Matching them would imply
NEON ≈ AVX2, which the post must never claim.

## Tasks

### 1. Revert the demo 09 throughput-bar order

In `site/src/posts/09-arm-neon.mdx`, set the `variants` prop on every `<ThroughputBars>`
instance to:

```
variants={['scalarlibm', 'autovec', 'scalarpoly', 'neon']}
```

Leave `variantLabels` and the demo 03 chart untouched. If `<TimeVsN>` passes an explicit
`variants` order or drives a legend order, set it to the same sequence so the line legend matches.

### 2. One order across chart, table, and prose

The variant sequence **`scalar (libm) → autovec → scalar (poly) → NEON (hand)`** must be used
identically in:

- the `<ThroughputBars>` `variants` prop (Task 1),
- the "Four variants" table rows (already in this order — verify unchanged),
- the first prose passage that introduces the variants, and
- every later passage that walks through them.

Find any prose that introduces or lists the variants in a different order (e.g. leading with NEON,
or libm→poly→NEON→autovec) and reorder it to match. The reader should never meet the four
variants in two different sequences.

### 3. Expand the "Four variants" section

The table notes are too terse to explain what each variant _is_. Add a short prose description per
variant — either as a paragraph under the table or by expanding the table's NOTES column — in the
canonical order. Use this copy (tighten to fit the house voice; keep every claim as written, since
they're asm/JSON-grounded):

> **scalar (libm)** — the honest baseline. Prices one option at a time, taking its transcendentals
> straight from the system math library (`std::log`, `std::exp`, and the error function behind the
> normal CDF). Built with `-fno-tree-vectorize` so the compiler cannot quietly vectorise it — this
> is genuinely scalar code, confirmed in the emitted assembly.
>
> **autovec** — the same libm-based kernel as scalar (libm), but with the anti-vectorisation guard
> removed, so `-O3` is free to autovectorise. On AArch64 NEON is part of the baseline ISA and GCC
> vectorises by default — the question is whether it _can_ here. It can't: the libm `log`/`exp`/
> `erfc` calls are opaque barriers the autovectoriser won't cross, so the assembly comes out
> byte-identical to scalar (libm) and the timing tracks it within 0.1%. The variant exists to show
> that "just turn on `-O3`" buys nothing for this kernel.
>
> **scalar (poly)** — replaces the libm transcendentals with inlined polynomial approximations
> (a polynomial `exp` and normal CDF), still one option at a time. This isolates the _algorithm_
> win — avoiding the libm call overhead — from the _width_ win that comes later, and runs ~6%
> faster than scalar (libm). It is also the width-ratio denominator: it's the exact kernel NEON
> runs, minus the vectorisation, so NEON-over-poly is a clean 4-wide comparison.
>
> **NEON (hand)** — the poly kernel rewritten with hand-written `float32x4_t` intrinsics: four
> options priced per instruction, inline polynomials throughout (no libm calls to get in the
> autovectoriser's way). This is the SIMD variant that delivers the ~4.3× (at 16k) to ~4.8× (at 1M)
> width speedup over scalar (poly).

If the section already carries a partial version of this, merge rather than duplicate.

## Acceptance

- `grep -n "variants={\['scalarlibm', 'autovec', 'scalarpoly', 'neon'\]}" site/src/posts/09-arm-neon.mdx`
  → matches every `<ThroughputBars>` instance; no instance still reads `'neon', 'autovec'` last-two.
- On the branch deploy: demo 09 bars render left-to-right scalar (libm), autovec −O3, scalar
  (poly), NEON (hand) — heights descending 65, 65, 61, 14; NEON (yellow) last.
- The variants table, the introducing prose, and any later walk-through all list the four in the
  order libm → autovec → poly → NEON. No passage uses a different order.
- The "Four variants" section explains each variant in prose (not just clipped table notes).
- The ~6% (poly vs libm) and ~4.3×/4.8× (NEON vs poly) figures in the new prose match
  `09-arm-neon.json` to one significant figure.
- `cd site && npm run build` succeeds; `/posts/09-arm-neon` renders with no NoData panel.

## Out of scope

- Demo 03's chart, order, labels, caption, or prose — all correct as shipped; do not touch.
- The `theme.ts` palette — the 4th-bar colour difference is intentional (see Context); do not
  add or change any palette entry to make the last bars match.
- Any timing data or JSON.
- Merge / deploy / live-site check (§11/§12, user).
- The §9 hostile cross-read — separate task, runs after this lands.

## Open items for CC to flag

1. **Literal "autovec then neon" adjacency.** The canonical order places `poly` between `autovec`
   and `neon` (`libm, autovec, poly, neon`) because that's slowest→fastest and matches the table.
   Do **not** instead produce `libm, poly, autovec, neon` (autovec immediately before neon) — that
   bumps a tall autovec bar between poly and NEON and breaks the descent. If anything in the repo
   suggests the adjacent form, flag it rather than applying it.
2. **TimeVsN legend/series order.** If `<TimeVsN>` doesn't take an explicit order and renders in
   JSON order, leave it — but if its legend ends up in a different order than the bars/table,
   flag it so the order can be made consistent there too.
3. **Variant-description placement.** Paragraph-under-table vs expanded NOTES column is an editorial
   call; pick whichever fits demo 7/8's section style and note which you chose.
