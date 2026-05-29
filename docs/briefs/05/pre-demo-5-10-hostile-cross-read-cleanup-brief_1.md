# Crucible — hostile cross-read cleanup brief

**Pre-demo-5 brief 10. Translates the findings in `pre-demo-5-hostile-cross-read-findings.md` (task 11 audit) into a single CC pass over the four post MDX files.**

---

## 1. Context

Task 11's hostile cross-read of the four shipped posts surfaced 12 critical/material findings and 8 low-priority drifts. After Opus + user triage, this brief bundles all the precise-text edits into a single PR. Structural choices already settled in chat:

- **M-2 — drop "Reproducing this" from demos 2 & 3** (current half-and-half is the worst option; methodology page is the single source of truth for reproduction). Disposes of C-2 (demo 3 stale `cset + sudo`) and M-7 (broken relative source-code links in demos 2 & 3) as a side-effect — they all live inside the section being deleted.
- **M-3 — add "Takeaway" to demos 2 & 3** to match demos 1 & 4. Prose drafted in §3 and §4 below.
- **M-4 — GCC version normalised to `GCC 13.3`** across all four footers (already correct in demos 1 & 4; demos 2 & 3 currently say "GCC 13"). If the reference machine actually ran a different patch level, CC should `gcc --version` on the machine and use that; otherwise apply `13.3` as specified.

**Deferred to its own brief (not in this PR):**

- **M-5 + M-6 — statistical-convention disclosure and repetition counts in footers.** Touches every post's footer and wants a chosen template; user-signoff first. Will land as `pre-demo-5-11-footer-normalisation-brief.md`.

**Dropped (no action):**

- **L-8 — demo 4 lede rhythm.** Cosmetic, title carries the "Same X. Different Y" rhythm; lede paragraph can stand as written.

---

## 2. Demo 01 — `site/src/posts/01-branch-prediction.mdx`

### 2.1 — C-3 — Footer: "isolated cores 4–7" → "cores 0–7 isolated, pinned to 4–7"

**Location:** line 253 (footer italicised block, first line).

**Find:**

```
_All numbers: median ns/iteration, AMD Ryzen 7 3800X at 3.9 GHz base,
governor = performance, Turbo Boost off, isolated cores 4–7, GCC 13.3 `-O3 -march=native`._
```

**Replace with:**

```
_All numbers: median ns/iteration, AMD Ryzen 7 3800X at 3.9 GHz base,
governor = performance, Turbo Boost off, cores 0–7 isolated, pinned to 4–7,
GCC 13.3 `-O3 -march=native`._
```

(Matches demo 3's footer phrasing — kernel isolation set vs benchmark pin set are correctly distinguished.)

### 2.2 — L-1 — Inline `-march=znver2` consistency

**Location:** the blockquote at lines 91–94.

**Current:**

```
> Without the `no-tree-vectorize` attribute, GCC 13.3 at `-O3 -march=znver2` turns this same
> ternary into `vpcmpgtd`/`vpand`/`vpaddd` — an 8-wide masked add that beats the cmov version
> by a further ~8×. That's a different story (SIMD width, not branch behaviour), and gets its
> own [post](/posts/03-simd-blackscholes).
```

**Replace with:**

```
> Without the `no-tree-vectorize` attribute, GCC 13.3 at `-O3 -march=native` (which resolves
> to `-march=znver2` on the reference machine) turns this same ternary into
> `vpcmpgtd`/`vpand`/`vpaddd` — an 8-wide masked add that beats the cmov version by a further
> ~8×. That's a different story (SIMD width, not branch behaviour), and gets its own
> [post](/posts/03-simd-blackscholes).
```

Keeps the technically precise `znver2` ISA name (which matters — the auto-vectorised path is znver2-specific) without introducing a footer/inline mismatch.

### 2.3 — L-3 — Footer link emphasis style

**Location:** line 258.

**Find:** `_[Methodology →](/methodology)_`

**Replace with:** `*[Methodology →](/methodology)*`

(Matches demos 2/3/4. Renders identically; source-level consistency only.)

---

## 3. Demo 02 — `site/src/posts/02-false-sharing.mdx`

### 3.1 — M-2 — Drop the entire "Reproducing this" section

**Location:** lines 181–231 — from `## Reproducing this` through the final code block before the `---` separator. Delete the whole section.

**What's being removed:**
- The section heading `## Reproducing this`
- The "Source files committed to the repo:" bulleted list with the three broken relative-path links (M-7)
- The "Per-variant capture (example…)" bash block
- The "For the L1D-specific miss counter…" bash block
- The pre-flight paragraph
- The `CRUCIBLE_PRINT_AFFINITY` bash block

**Leave intact:** the `---` separator and the footer block that follows it (machine specs + Methodology link).

### 3.2 — M-3 — Add Takeaway section

**Location:** insert a new section **between** the current `## What this benchmark doesn't show` section and the `---` separator preceding the footer.

(After 3.1 above, the preceding section will be `## What this benchmark doesn't show` directly followed by `---`. Insert the new Takeaway between them.)

**Text to insert:**

```markdown
## Takeaway

False sharing is a 13× throughput collapse from two missing bytes of padding — a
layout regression the compiler will never warn about. The mechanism is universal
(write-write coherency traffic on a shared cache line) but the magnitudes are
hardware-specific: 5× within a Zen 2 CCX, 13× once the Infinity Fabric is in
the loop, milder on Intel monolithic dies. The fix is a single `alignas(64)` —
and a `static_assert` that turns the discipline into a compile-time invariant,
as [demo 4's `PaddedAtomic<T>`](/posts/04-spsc-queue) does.

When per-thread state lives in an array, the default layout is almost always
wrong. Pad to a cache line, assert it, move on.

---
```

(Note: the trailing `---` in the inserted block replaces the existing `---` already there. Net effect: the new Takeaway sits where the old Reproducing-this used to lead, the footer follows the same `---` it always did.)

### 3.3 — M-4 — GCC version

**Location:** line 236 (the footer italics).

**Find:** `GCC 13, -O3 -march=native.`

**Replace with:** `GCC 13.3, -O3 -march=native.`

### 3.4 — L-6 — Section heading "What this benchmark doesn't show"

**Location:** line 166.

**Find:** `## What this benchmark doesn't show`

**Replace with:** `## What this doesn't show`

(Matches demos 3 and 4.)

---

## 4. Demo 03 — `site/src/posts/03-simd-blackscholes.mdx`

### 4.1 — M-2 — Drop the entire "Reproducing this" section

**Location:** lines 230–244 — from `## Reproducing this` through the two source-file link lines (`Benchmark: …`, `Polynomial helpers: …`). Delete the whole section.

**What's being removed:**
- The section heading `## Reproducing this`
- The bash block with the stale `cset + sudo` comment (this is what C-2 fixed indirectly — it's deleted along with the section)
- The two relative-path source-file links at the bottom (M-7 — also deleted by removal)

**Leave intact:** the `---` separator and the footer that follows.

### 4.2 — M-3 — Add Takeaway section

**Location:** insert a new section **between** the current `## What this doesn't show` section and the `---` separator preceding the footer.

(After 4.1 above, the preceding section will be `## What this doesn't show` directly followed by `---`. Insert the new Takeaway between them.)

**Text to insert:**

```markdown
## Takeaway

A 10× spread across four implementations of the same model decomposes cleanly:
12% from swapping libm's `erfc` for a polynomial approximation, then 9× from
widening to 8 lanes of AVX2 + FMA. The 12% step is unremarkable in isolation —
but it's the gate. There is no `_mm256_erfc_ps`, so the SIMD wins are
unreachable until the algorithm step happens first.

On Zen 2 the AVX2/SSE ratio lands near 2× rather than a theoretical 4× because
each 256-bit instruction splits into two 128-bit µops internally — FMA reclaims
what µop split costs you. On Zen 3+ and Sapphire Rapids, where 256-bit ops
dispatch natively, the same code path would be closer to a clean 4×.

---
```

(Same convention as 3.2 — the trailing `---` in the inserted block replaces the existing one before the footer.)

### 4.3 — L-2 — Remove the `[brief]` link

**Location:** line 184.

**Find:**

```
This was a deliberate trade-off — documented in the
[brief](docs/briefs/03-simd-blackscholes-brief.md). The alternatives:
```

**Replace with:**

```
This was a deliberate trade-off. The alternatives:
```

(The brief is an internal Opus→CC artefact; the relative path doesn't resolve on the deployed site anyway. The paragraph stands fine without the link — the trade-off is fully stated in the post.)

### 4.4 — M-4 — GCC version

**Location:** line 250 (footer italics).

**Find:** `GCC 13, per-variant ISA flags as documented in CMakeLists.txt.`

**Replace with:** `GCC 13.3, per-variant ISA flags as documented in CMakeLists.txt.`

---

## 5. Demo 04 — `site/src/posts/04-spsc-queue.mdx`

### 5.1 — C-1 — Fix broken `[Methodology]` markdown link

**Location:** line 244.

**Find:**

```
See [Methodology] for the rdtscp calibration path._
```

**Replace with:**

```
See [Methodology](/methodology) for the rdtscp calibration path._
```

### 5.2 — M-1 + M-8 + L-4 — Rewrite the "100–130 ns floor" paragraph

**Location:** lines 195–198 (the paragraph immediately under "Why the tail collapses", starting "None of that happens on the lock-free path.").

**Find:**

```
None of that happens on the lock-free path. The consumer spins until it sees the
producer's `tail_` store, then loads the item. On Zen 2 with both threads on the
same L3 slice, that cache-coherence round-trip plus the buffer load and store completes in roughly
100–130 nanoseconds on Zen 2 within a CCX — the floor visible in the p50 numbers above.
```

**Replace with:**

```
None of that happens on the lock-free path. The consumer spins until it sees the
producer's `tail_` store, then loads the item. On Zen 2, with both cores on the
same CCX sharing an L3, that cache-coherence round-trip plus the buffer load and
store completes in roughly 130 ns — the floor visible in the p50 numbers above.
```

Three fixes folded in: M-1 (range "100–130" replaced with "roughly 130" — anchors to the actual 132 ns p50 measurement), M-8 ("L3 slice" → "an L3" — Zen 2 CCX L3 is a dedicated cache, not a slice), L-4 (dropped the second "on Zen 2" — was redundant).

### 5.3 — M-9 — Trim lede triple-repetition

**Location:** lines 11–13 (Setup section opening).

**Find:**

```
## Setup

A market-data thread produces ticks; a strategy thread consumes them. We measure
the latency from the moment the producer stamps the item to the moment the
consumer has it in hand — the full journey across the queue. Three variants on
the same 16-byte `MarketTick`:
```

**Replace with:**

```
## Setup

Three variants on the same 16-byte `MarketTick`. We measure latency from the
moment the producer stamps the item to the moment the consumer has it in hand —
the full journey across the queue:
```

(The lede paragraph above Setup already establishes the producer/consumer framing twice — once in the post summary, once in line 7. Setup no longer needs to restate it.)

### 5.4 — M-10 — Rephrase "similarly close" (172 vs 148 ns gap is 16%, not 8%)

**Location:** lines 211–213 (the Boost comparison paragraph).

**Find:**

```
Under 1 MHz paced load, the hand-rolled
implementation comes in at 132 ns p50 vs Boost's 122 ns — within 8%. p99.9 is
similarly close: 172 ns hand-rolled vs 148 ns Boost. That's the credibility check:
```

**Replace with:**

```
Under 1 MHz paced load, the hand-rolled
implementation comes in at 132 ns p50 vs Boost's 122 ns — within 8%. The p99.9
gap is wider — 172 ns vs 148 ns, about 16% — but both are still orders of
magnitude inside the mutex variant's tail. That's the credibility check:
```

(Frames the 8% and 16% honestly instead of collapsing them into a single "similarly close". The thesis — Boost validates the hand-rolled implementation — survives.)

### 5.5 — L-5 — Remove self-referential meta-prose

**Location:** lines 203–204.

**Find:**

```
This is the mechanism behind the hockey-stick in the load-sweep chart above, not a
change in the per-op cost. The post labels these separately because conflating
them was the main flaw in an earlier version of this measurement.
```

**Replace with:**

```
This is the mechanism behind the hockey-stick in the load-sweep chart above, not a
change in the per-op cost. The two saturation regimes are genuinely different and
worth labelling separately.
```

(Keeps the load-bearing claim — that the two regimes are distinct — without referencing the post's own revision history.)

### 5.6 — L-7 — `CCX1` → `CCX` where the specific CCX number isn't significant

**Locations:** lines 35, 132.

**Find (line 35):** `Producer pinned to core 4, consumer to core 5 — both on CCX1 of the Ryzen 7 3800X, sharing an L3 slice. Same-CCX only; cross-CCX is deferred.`

**Replace with:** `Producer pinned to core 4, consumer to core 5 — both on the same CCX of the Ryzen 7 3800X, sharing an L3. Same-CCX only; cross-CCX is deferred.`

(Also drops "slice" per M-8.)

**Find (line 132):** `inter-core handoff is serviced by the shared CCX1 L3 slice without crossing the Infinity Fabric.`

**Replace with:** `inter-core handoff is serviced by the shared CCX L3 without crossing the Infinity Fabric.`

(Footer at line 246 — `producer core 4 + consumer core 5 (same CCX1)` — leave as-is. The footer documents which physical cores were used and the CCX they belong to; that's a reproducibility detail and the specific CCX matters there.)

---

## 6. Acceptance criteria

- [ ] **Demo 01**: footer says `cores 0–7 isolated, pinned to 4–7`. Inline blockquote at line 91-ish says `-march=native` with the `znver2` parenthetical. Methodology link uses asterisks `*`.
- [ ] **Demo 02**: no "Reproducing this" section. Takeaway section present, ends with the "Pad to a cache line, assert it, move on" sentence. Footer says `GCC 13.3`. Section heading is `What this doesn't show` (no "benchmark").
- [ ] **Demo 03**: no "Reproducing this" section. Takeaway section present, ends with "closer to a clean 4×". No `[brief]` link in the "Why hand-roll" section. Footer says `GCC 13.3`.
- [ ] **Demo 04**: `[Methodology](/methodology)` link works on line 244. Paragraph at line ~195 says "roughly 130 ns" and "an L3" (not "L3 slice") and only one "on Zen 2". Setup section opens with "Three variants on the same 16-byte `MarketTick`." Boost comparison paragraph distinguishes the 8% and 16% gaps. No "earlier version of this measurement" phrase. Lines 35 and 132 say "CCX" not "CCX1" (line 246 footer keeps "CCX1").
- [ ] All four MDX files: `npm run build` completes without MDX parse errors.
- [ ] Dev server (`npm run dev`): each modified post renders without console errors. Click-through verified for: the new `[Methodology](/methodology)` link in demo 4 (must reach `/methodology`), the `[demo 4's PaddedAtomic<T>](/posts/04-spsc-queue)` cross-link in demo 2's new Takeaway (must reach demo 4 — this is the same route prefix as the task-8 cross-link, so should work).
- [ ] `git diff --stat` shows only the four MDX files modified. No JSON, no component, no methodology page touched.
- [ ] `pre-demo-5-review-tasks.md` task 11 marked ☑.

---

## 7. Out of scope

- **Footer normalisation (M-5 + M-6)** — statistical-convention disclosure and repetition counts in the four footers. Wants a chosen template and user signoff. Will land as `pre-demo-5-11-footer-normalisation-brief.md`. Don't touch the footer beyond the specific edits called out in §2.1, §3.3, §4.4, and §5.2 above.
- **Methodology page edits.** All four posts link to `/methodology`; that page is task 2's Opus pass and is handled separately.
- **Index page summaries.** Task 3 (index audit) is its own thing; the post summaries here in the frontmatter (`summary:`) are unchanged.
- **JSON, charts, components.** Pure MDX prose edits only. No data files, no React, no chart props.
- **Demo 04 lede rhythm (L-8).** Dropped — title carries the rhythm; lede can stand.
- **Cross-link density between posts.** Findings doc noted "four posts read as four posts, not a series" — a demo-5+ concern, not pre-demo-5 polish.

---

## 8. Notes for CC

Six edits in demo 4, three or four in each of the others — none individually large; the volume comes from the count. Two structural moves (Reproducing-this deletion + Takeaway insertion in demos 2 & 3) are the only ones with non-trivial line-count change.

Order suggestion: do the deletions first (3.1, 4.1), then the insertions (3.2, 4.2), then the small edits in any order. This keeps line-number references valid in each file as you work top-to-bottom — most of the §2 and §5 small edits sit above where the line-count changes in §3 and §4.

For the two new Takeaway sections (3.2 and 4.2): the prose is final, not a sketch. Apply verbatim. If you find the cross-link route prefix in demo 2's Takeaway needs adjusting (currently `[demo 4's \`PaddedAtomic<T>\`](/posts/04-spsc-queue)`), match whatever prefix the existing task-8 cross-link in demo 2 uses — they should be identical.

If the reference machine actually has GCC at a patch level other than 13.3, use that everywhere instead. `gcc --version` is the source of truth; `13.3` is the brief's default because it's already in two of four posts. If you do override, also update demo 1's footer (line 253) and demo 4's footer (line 247) so all four are consistent.

After this lands, task 11 of `pre-demo-5-review-tasks.md` closes. Remaining: task 12 (Amplify deploy verification, user manual), plus the deferred M-5/M-6 footer-normalisation brief. Then demo 5 scoping opens.
