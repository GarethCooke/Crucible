# Crucible — Demo 08 companion explainer: "How LSD radix sort actually works"

Implementation brief for Claude Code. Adds a standalone companion explainer to demo 08, following the pattern established by `grover-explained` for the quantum special edition: a hand-written route that renders an MDX file, linked inline from the parent post, with **no index card**. Introduces the site's first animated interactive component. Self-contained; depends on no other in-flight brief.

## Context

Demo 08 (`site/src/posts/08-sorting-shootout.mdx`) is shipped and live. It explains *why* a radix sort walks around the comparison lower bound and charts what that costs, but it never shows the sort moving. The `<CodeCompare>` block at lines 21–36 shows the four-pass byte-wise loop; nothing on the page shows histogram → prefix sum → scatter → ping-pong actually executing, and nothing demonstrates *why* least-significant-digit-first is correct (stability).

The precedent this brief follows, verified in the repo at time of writing:

- `site/src/posts/special/grover-explained.mdx` — companion MDX. Lives in a **subdirectory** of `src/posts/`.
- `site/src/app/special/measuring-the-gap/grover-explained/page.tsx` — hand-written route. Reads the MDX with `readFile` + `gray-matter`, renders with `MDXRemote`, supplies its own back-nav, marker chip, and header from frontmatter.
- `site/src/lib/posts.ts` — `getAllPosts()` calls `readdir(POSTS_DIR)` **non-recursively** and filters `.endsWith('.mdx')`. A subdirectory name has no `.mdx` suffix, so anything under `src/posts/<subdir>/` is invisible to the index and to `generateStaticParams()`. **This is the mechanism that keeps the companion off the index — preserve it.**
- The Grover explainer is reachable only from an inline link mid-post in `app/special/measuring-the-gap/page.tsx`. It has no card on `/`.

Two structural differences from the Grover case that this brief has to handle:

1. **The parent is a dynamic route.** `measuring-the-gap` is a static route (`app/special/measuring-the-gap/page.tsx`), so nesting a child under it is trivially safe. Demo 08 is served by `app/posts/[slug]/page.tsx` with `generateStaticParams()`. Nesting a child under `/posts/08-sorting-shootout/` creates a static path segment as a sibling of a dynamic one, under `output: 'export'`. Task 3 requires this to be proven, not assumed.
2. **The Grover page passes no `components` map to `MDXRemote`** — that MDX is pure prose. This one embeds a component, so the new route must pass one.

Stack facts relevant here (verified in `site/package.json`, `site/next.config.mjs`): Next 14.2.35 App Router, React 18.3.1, `output: 'export'`, Tailwind v4, d3 available, **no animation library** — animation is CSS transitions plus `setTimeout`/`requestAnimationFrame`.

Branch from `master`, single PR. No JSON, no bench code, no capture involved anywhere in this brief.

## Preconditions

Verify all of the following before making any change. If any fail, **stop and report** rather than adapting.

1. `site/src/posts/08-sorting-shootout.mdx` exists and `grep -c 'CodeCompare' site/src/posts/08-sorting-shootout.mdx` returns `1`.
2. `grep -rn 'RadixSort' site/src/` returns **zero** hits. If a component of that name already exists, stop — the name is taken and the brief needs revising.
3. `ls site/src/app/posts/` shows only `[slug]`. If any static segment already exists under `app/posts/`, stop and report — the routing question in Task 3 has a precedent this brief hasn't accounted for.
4. `site/src/lib/posts.ts` still uses `readdir` + `.endsWith('.mdx')` filtering. If post enumeration has changed to a recursive walk, **stop** — placing the MDX in a subdirectory will no longer keep it off the index, and the file location needs rethinking.
5. `npm run build` succeeds on a clean checkout **before** any edit. Record that it passes; a build failure after Task 3 is only meaningful against a known-good baseline.

## Reference implementation

A working prototype of the animation is supplied alongside this brief as `radix-sort-explainer.html` (single-file HTML, plain JS, hardcoded light-mode palette). It is a **behavioural reference, not source to copy**. Port the behaviour and the interaction model; do not port its markup, its inline CSS, or its colour values. Task 2 is the authority on what the React component must do — where the prototype and this brief disagree, the brief wins.

## Tasks

### 1. Create the companion MDX

Create `site/src/posts/companions/08-radix-explained.mdx` with exactly the content below. The `companions/` subdirectory is new; create it. Do not place this file at `src/posts/` root — that would give it an index card and a `/posts/...` slug route, both of which are wrong.

````mdx
---
title: "How LSD radix sort actually works"
summary: "A companion to the main post. The post measures what a radix sort costs and why it beats std::sort on integer keys; this shows the sort actually moving the data — count, position, scatter, one digit at a time — with the step a benchmark can't show you made visible. No prior background assumed."
date: "2026-06-05"
---

A companion to the main post. The [main post](/posts/08-sorting-shootout) measures what a radix sort *costs* and why it walks around the comparison wall on fixed-width integer keys; this page is about the mechanism underneath — what "sort by distributing keys into buckets" actually compiles to, and why starting from the *least*-significant digit is the part that makes it correct. If you can read a little pseudocode, you can follow it.

---

## The one idea: sort by digit, never compare

`std::sort` works by comparing pairs of keys. Radix sort never compares anything. Given keys that are fixed-width integers, it looks at **one digit at a time** and drops each key into a bucket for that digit — and if you do this from the least-significant digit up to the most, the keys come out fully sorted. That's the whole trick. The main post explains why sidestepping comparison lets radix beat the Ω(n log n) wall; this page shows the machine doing it.

The animation runs the real algorithm on a small array — eight two-digit numbers, base 10, so you can read every step. (The real code uses a bigger radix for cache reasons, which is the last section here; the mechanism is identical.)

## One pass, three phases

<RadixSort />

Each pass over the array is a **counting sort** on one digit, and it's three sweeps:

1. **Count.** Walk the array; for each key, increment a counter for its current digit. At the end you know how many keys fall in each bucket — but nothing has moved yet.
2. **Positions** (the prefix sum). Turn those counts into *starting positions* in the output. Bucket 0 starts at 0; bucket 1 starts wherever bucket 0's run ends; bucket 2 after that. It's a running total across the buckets, and it's the step that decides where each bucket's block of keys will live.
3. **Scatter.** Walk the array again; write each key into its bucket's current position, then advance that position by one. Keys with the same digit land in consecutive slots, in the order the sweep met them.

Then the output buffer becomes the input for the next digit, and you repeat. Four passes for a 32-bit key, and you're done.

## Why least-significant-first works

Watch the scatter closely — it's the part a benchmark can't show you. Because both the count sweep and the scatter sweep run left-to-right, and the scatter advances each bucket's pointer as it writes, two keys with the same digit come out in the **same relative order they went in**. That property has a name: the pass is *stable*.

Stability is the reason the whole thing works. Follow the four keys the animation highlights at the end — `42 43 45 48`:

```
start       45 12 48 91 42 18 43 15
after ones  91 12 42 43 45 15 48 18   ← ordered by the last digit
after tens  12 15 18 42 43 45 48 91   ← ordered by both, i.e. sorted
```

Pass 2 groups the keys by their tens digit, so `42 43 45 48` end up together in the "4" group. Their order *within* that group — 2, 3, 5, 8 — is exactly what pass 1 left behind, because pass 2's stable scatter never reorders keys that share a tens digit. The ones-digit ordering survives underneath the tens-digit ordering. Do that for every digit position and you have sorted the whole key, one digit at a time, without a single comparison.

It has to be least-significant-*first* for this to hold: each pass refines the previous one only because stability preserves it. Go most-significant-first and each pass would scramble the previous pass's work — unless you recursed separately into every bucket, which is a different, more complicated algorithm.

## Why bytes, not decimal digits

The demo uses base 10 because ten buckets are easy to look at. The real code uses **base 256 — one byte per pass** — so a 32-bit key is four passes and a 64-bit key is eight. Two reasons the byte is the right radix:

- **The histogram stays in L1.** 256 counters is a couple of kilobytes; it lives in the fastest cache, and the count sweep becomes a stream of cheap increments.
- **Extracting a byte is one instruction.** `(k >> shift) & 0xFF` is a shift and a mask — no division, no branch. A decimal digit would cost a divide per key per pass.

The passes-per-key is also the knob the main post's key-width result turns on: a wider key means more passes, which is why radix's lead over `std::sort` erodes as keys get wider — the [main post](/posts/08-sorting-shootout) measures exactly how much between 32- and 64-bit keys. Everything else about the three phases is unchanged; only the bucket count and the pass count move.

## What it costs, and when to reach for something else

Radix buys its linear cost with memory. It needs a second array the size of the input to scatter into, and it ping-pongs between the two — the O(n) scratch buffer the main post charges it for, and the reason the small-N picture there is messier than the asymptotics suggest.

The precondition is also strict: the keys have to decompose into fixed-width digits. Floating-point, strings, variable-length records — anything you can only order by comparing — radix can't touch, and `std::sort` is the right default there. What radix gives you, on the narrow shape where it applies, is a sort whose cost doesn't depend on the *order* of the input at all. That's the property that matters when the thing you're bounding is a tail, not an average — which is where the main post picks the argument back up.

## Further reading

1. **CLRS, *Introduction to Algorithms*, §8.2–8.3** — counting sort and radix sort, the canonical treatment. The count / prefix-sum / scatter above is straight out of §8.2.
2. **McIlroy, Bostic & McIlroy, "Engineering Radix Sort," *Computing Systems* 6(1), 1993, pp. 5–27.** The practical engineering paper. It's aimed at string keys sorted byte-by-byte left to right, and presents three methods — including the in-place "American flag" sort — but the cache and bucket-handling lessons carry straight over. PDF via [Doug McIlroy's publications page](https://www.cs.dartmouth.edu/~doug/pubs.html).
3. **Malte Skarupke, ["I Wrote a Faster Sorting Algorithm"](https://probablydance.com/2016/12/27/i-wrote-a-faster-sorting-algorithm/)** — a modern, heavily engineered radix sort with an honest account of where it wins and loses against a good comparison sort.

## What you don't need to follow this

- The most-significant-digit (MSD) variants. They recurse into buckets and can beat LSD on some inputs; the LSD version here is the one in the demo and the easiest to see whole.
- SIMD, software prefetch, and the other tricks production radix sorts use to hide the scatter's memory latency. They make it faster; they don't change what it's doing.
````

Do **not** add `special: true` to this frontmatter — that flag belongs to the special-edition family, and this is a companion to a numbered demo. Nothing reads it on this route in any case; the marker chip is hardcoded in Task 3.

### 2. Build the `RadixSort` component

Create `site/src/components/RadixSort.tsx`. Place it at `components/` root, **not** in `components/charts/`: everything in `charts/` loads a per-demo JSON through `@/lib/perf-data`, and this component reads no data and has no `slug`. Do not touch `lib/perf-types.ts` or any JSON schema.

**Contract.** `'use client'`. Named export `RadixSort`. No required props. `<RadixSort />` is the only call site.

**Data model.** Fixed input `[45, 12, 48, 91, 42, 18, 43, 15]`, base 10, two passes (ones then tens). These values are load-bearing — the MDX prose in Task 1 quotes the intermediate and final orderings, and the closing highlight of `42 43 45 48` is the payoff for the stability section. Do not change them.

Precompute the **entire animation as an immutable array of frames** in a `useMemo`, then render frame `i`. Do not mutate state incrementally as the animation plays: stepping backward must be exact, and a frame-indexed model gets that for free. Each frame holds: pass index, phase, per-key position (`row: 'in' | 'out'`, slot), the ten bucket counts, the ten bucket offsets plus how many are revealed, which input slot is being read, which bucket is active, which key was just placed, which output slots are filled, which source line to highlight, and the narration string.

**Phases, in order, per pass.** `count` (one frame per key — increment that digit's counter), `offsets` (one frame per bucket — running total becomes that bucket's start position), `scatter` (one frame per key — key moves to output slot, bucket pointer advances), then `swap` (output becomes input for the next pass) or, after the last pass, `done` (lift the sorted array back to the input row and highlight the four keys whose tens digit is 4).

**Layout.** Three bands: input array (top), ten buckets showing digit / count / position (middle), scratch array (bottom). Keys are persistent absolutely-positioned elements moved with `transform: translate(...)` and a CSS transition, so they visibly fly between rows. Each key renders both its digits with the digit being sorted on at full opacity and the other dimmed.

**Code panel.** Alongside the narration, show the four-line base-256 loop with the line corresponding to the current phase highlighted:

```
for (auto k : a) ++count[(k>>s)&0xFF];        // 1 histogram
for (b) { count[b]=sum; sum+=cnt[b]; }        // 2 prefix sum
for (auto k : a) tmp[count[(k>>s)&0xFF]++]=k; // 3 scatter
a.swap(tmp);                                  // 4 ping-pong
```

This is the bridge between the base-10 toy and the real code in the parent post — it is not optional.

**Controls.** Reset, Back, Play/Pause, Step, and a speed slider. **The slider must map left → slow, right → fast.** The naive binding of slider value straight to the `setTimeout` delay inverts this; invert it explicitly (`delay = min + max - value`) and leave a comment saying so.

**Theming.** All colours from CSS custom properties (`--text-primary`, `--text-secondary`, `--text-muted`, `--bg-card`, `--border-color`) so the component tracks the light/dark toggle with no JS. For the three phase accents, import `tokens` from `@/lib/design-tokens` and use `tokens.color.chart.series[0]` (count/read), `series[2]` (bucket/offsets), and `series[4]` (just-placed). Introduce no new colour values. Do **not** use `tokens.color.dark.*` — those are dark-theme-only and will not follow the toggle. `useTheme()` should not be needed; if the implementation appears to require it, stop and report rather than reaching for it.

**Accessibility.** This is the site's first animated component and there is currently no reduced-motion handling anywhere in `site/src/` — establish it here:

- **No autoplay.** The component renders frame 0 and waits for input.
- Under `@media (prefers-reduced-motion: reduce)`, set the key-cell transition duration to `0ms` so stepping jumps rather than slides. Play must still work; only the tweening goes away.
- Controls are real `<button>` elements, reachable and operable by keyboard.
- The narration region is `aria-live="polite"` so a screen reader follows the steps.
- The stage carries a text alternative describing what is being animated.

**Responsive.** The stage must not overflow horizontally at a 375 px viewport. Either scale the stage or allow the array rows to wrap; the ten buckets are the binding constraint. Verify against the mobile check in Acceptance.

### 3. Create the route

Create `site/src/app/posts/08-sorting-shootout/radix-explained/page.tsx`, mirroring `site/src/app/special/measuring-the-gap/grover-explained/page.tsx` with these deltas:

- `SOURCE` points at `src/posts/companions/08-radix-explained.mdx`.
- `metadata.title` = `"How LSD radix sort actually works"`; `metadata.description` = the frontmatter summary.
- Back-nav links point at `/posts/08-sorting-shootout` with the label `← The comparison lower bound is a wall`, and `/` labelled `All posts`.
- The marker chip reads **`Companion explainer`** — not "Special edition — companion explainer". This is a companion to a numbered demo, not a special edition, and the chip must not imply the post sits outside the standard methodology.
- Pass `components={{ RadixSort }}` to `MDXRemote`. The Grover page passes no components map; this one must.
- Keep the same rehype/remark plugin set as the Grover page (`remarkGfm`, `rehypeSlug`, `rehypeAutolinkHeadings`, `rehypePrettyCode` with `SYNTAX_THEME`). `remarkMath`/`rehypeKatex` are not needed — there is no maths in this MDX.
- Footer: single back link to `/posts/08-sorting-shootout`.

**Routing verification — this is a gate, not a checkbox.** This introduces `app/posts/08-sorting-shootout/` as a static segment sibling to `app/posts/[slug]/`. After creating the route, prove all three:

1. `npm run build` succeeds.
2. `out/posts/08-sorting-shootout.html` (or `out/posts/08-sorting-shootout/index.html`) exists and contains the parent post's H1 text.
3. `out/posts/08-sorting-shootout/radix-explained/index.html` exists and contains the string `How LSD radix sort actually works`.

**If the build fails, or if the parent post's static output disappears or 404s, stop and report before doing anything else.** Do not attempt to fix it by adding a static `app/posts/08-sorting-shootout/page.tsx` that duplicates the `[slug]` renderer — that path leads to two renderers for one shipped post and is not acceptable. The named fallback is to move the route to `site/src/app/explainers/radix-sort/page.tsx` (URL `/explainers/radix-sort`), which collides with nothing; if you take the fallback, update the Task 4 link target to match and say so explicitly in the PR description. Report which route shipped either way.

### 4. Link it from the parent post

In `site/src/posts/08-sorting-shootout.mdx`, insert a link immediately after the closing `/>` of the `<CodeCompare>` block (currently line 36) and before `## The race across N` (currently line 38). Mirrors how `measuring-the-gap` links its explainer — inline, at the point the mechanism first matters, standalone paragraph with a trailing arrow.

Find:

```mdx
/>

## The race across N
```

Replace with:

```mdx
/>

Three phases per pass — count, position, scatter — and a stability property that's the reason least-significant-digit-first works at all. For a step-by-step walkthrough of the mechanism: [How LSD radix sort actually works →](/posts/08-sorting-shootout/radix-explained)

## The race across N
```

This is the **only** permitted edit to `08-sorting-shootout.mdx`. Do not touch its prose, its numbers, its frontmatter, or any other component invocation.

## Acceptance

### Build and routing

- `npm run build` succeeds from `site/`.
- `out/posts/08-sorting-shootout/radix-explained/index.html` exists and contains `How LSD radix sort actually works`.
- The parent post's static output still exists and still contains its H1.
- `npm run lint` produces no new errors relative to the pre-change baseline.

### Index isolation

- `grep -rn 'radix-explained' site/src/app/page.tsx` returns **zero** hits.
- The built index (`out/index.html`) contains exactly the nine numbered post cards and the one special edition it contained before this change — no tenth card. Verify by diffing the card list against a pre-change build.
- `site/src/lib/posts.ts` is unmodified: `git diff --stat site/src/lib/posts.ts` is empty.

### Component

- `grep -c 'use client' site/src/components/RadixSort.tsx` returns `1`.
- `grep -n 'tokens.color.dark' site/src/components/RadixSort.tsx` returns zero hits.
- `grep -n 'prefers-reduced-motion' site/src/components/RadixSort.tsx` returns at least one hit.
- No `localStorage`, `sessionStorage`, or `fetch` anywhere in the component.
- Stepping forward to the final frame and back to frame 0 returns the display to its exact initial state (frame-indexed rendering, verified by inspection of the state model — no incremental mutation).
- The speed slider's leftmost position is slower than its rightmost position. State the measured frame interval at each end in the PR description.
- At a 375 px viewport the stage does not overflow horizontally.

### Content integrity

- The component's input array is exactly `[45, 12, 48, 91, 42, 18, 43, 15]`, and the orderings in the MDX prose block (`after ones`, `after tens`) match what the animation actually produces. Run the trace and check, don't assume — if they disagree, **the animation is right and the prose is wrong**; stop and report rather than silently editing either.
- The final frame highlights exactly the four keys with tens digit 4: `42 43 45 48`.
- `grep -c 'ns/element\|ns per element' site/src/posts/companions/08-radix-explained.mdx` returns `0`. This page carries **no** measured figures — every numerical claim stays in the parent post where it derives from JSON.

### Untouched

- `git diff --stat` shows changes confined to: the new MDX, the new component, the new route, and the single three-line insertion in `08-sorting-shootout.mdx`.
- `git diff site/src/data/` is empty.
- `git diff bench/` is empty.

## Out of scope

- Any change to `08-sorting-shootout.json` or any other file under `site/src/data/` — this brief involves no measurement and no recapture.
- Any change to `bench/demos/08-sorting-shootout/` or any other bench code.
- Any change to demo 08's prose beyond the single link insertion in Task 4.
- Companion explainers for any other demo. If this pattern is worth repeating, that's a separate brief per demo.
- Any change to `lib/posts.ts`, the index page, or the post-enumeration model. The companion stays off the index by living in a subdirectory; do not add a filter, a flag, or a `companion:` frontmatter field to achieve it.
- Generalising the route into a `app/posts/[slug]/[companion]/` dynamic segment. Tempting, and wrong for one instance — revisit if a second companion is ever commissioned.
- MSD radix, American flag sort, SIMD radix, or any additional algorithm visualisation.
- Adding the explainer to the methodology page or to any cross-demo consistency sweep. It contains no measurements, so it is not in scope for hostile cross-reads of numerical claims.
- A static SVG still of each phase for print/scan-reading, and a standalone "why bytes, not bits" cache visual. Both were considered and deferred; if wanted, they follow as a separate brief.

## Open items for CC to flag

1. **Route nesting under a dynamic segment.** If `npm run build` fails after Task 3, or if the parent post's static output is missing or 404s, **stop and report before attempting any fix.** Take the `/explainers/radix-sort` fallback named in Task 3 only after reporting. Do not add a duplicate static renderer for the parent post under any circumstances — demo 08 is shipped and live, and breaking it to add a companion is a strictly worse outcome than shipping the companion at a flatter URL.

2. **Post enumeration has changed.** If `getAllPosts()` no longer does a non-recursive `readdir` (Precondition 4), placing the MDX in `companions/` will not keep it off the index. Stop and report — the fix is an editorial decision about whether the companion gets a card, not a CC one.

3. **Prose and animation disagree.** If the trace produced by the component does not match the `after ones` / `after tens` orderings quoted in the MDX, stop and report with both sequences. Do not edit the prose to match, and do not edit the input array to match the prose — one of the two is wrong and which one is a question for Opus.

4. **Reduced-motion approach.** If `prefers-reduced-motion` cannot be handled in CSS alone and appears to need a JS media-query listener, implement it in CSS-only form and flag the limitation rather than adding a hook. This is the first instance of a pattern the site will reuse; it should be the simplest thing that works.

5. **Ten buckets at 375 px.** If the ten-bucket row cannot be made to fit at a 375 px viewport without shrinking the digits below legibility, stop and flag with a screenshot before choosing between horizontal scroll, two-row wrap, or a scaled stage. This is a design call, not an implementation detail.

## Notes for CC

Stage as four commits matching the four tasks — the routing commit is the one most likely to need reverting on its own, and it should be isolated.

The prototype (`radix-sort-explainer.html`) is worth opening in a browser before writing any code; the interaction model is easier to absorb by using it than by reading a spec of it.
