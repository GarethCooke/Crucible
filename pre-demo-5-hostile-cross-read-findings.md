# Crucible — hostile cross-read findings (task 11)

**Read date:** 2026-05-19
**Method:** Back-to-back read of all four shipped post MDX files in chronological order (demo 3 first by date 2026-05-14, then 2, 1, 4), then a second pass in numeric order. Watching for the four drift classes called out in the task brief: statistical convention drift, Zen 2 / CCX framing consistency, repeated or contradictory caveats, tonal shifts. Source files: the four `site/src/posts/0[1-4]-*.mdx` as shipped after the task-1–10 polish wave.
**Scope:** Prose, structure, footers, link integrity, numerical self-consistency. Not C++, not JSON, not chart components.

Each individual post has already passed a skeptical review pass — and it shows. The findings below are about what the back-to-back read surfaces that isolated reads cannot.

---

## Summary

| #    | Severity | Demo | Class         | One-line                                                                                                                                                                             |
| ---- | -------- | ---- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| C-1  | Critical | 4    | Bug           | Broken `[Methodology]` markdown link (no URL) — line 244                                                                                                                             |
| C-2  | Critical | 3    | Stale         | `cset + sudo` reference in Reproducing-this — contradicts methodology cleanup intent — line 240                                                                                      |
| C-3  | Critical | 1    | Factual       | Footer says "isolated cores 4–7" — conflates kernel isolation (0-7) with pin set (4-7)                                                                                               |
| M-1  | Material | 4    | Numerical     | Prose says "100–130 ns" floor at lines 197-198; reported p50 is 132 ns at lines 152, 211, 213                                                                                        |
| M-2  | Material | all  | Drift         | "Reproducing this" present in 2 & 3, absent in 1 & 4                                                                                                                                 |
| M-3  | Material | all  | Drift         | "Takeaway" section present in 1 & 4, absent in 2 & 3                                                                                                                                 |
| M-4  | Material | all  | Drift         | GCC version: "13" (demos 2, 3) vs "13.3" (demos 1, 4) in footers                                                                                                                     |
| M-5  | Material | all  | Drift         | Statistical-convention disclosure uneven — demo 1 explicit, demos 2 & 3 silent, demo 4 chart-only                                                                                    |
| M-6  | Material | all  | Drift         | Repetition count: demo 2 says "20 repetitions", demo 4 says "30 runs"; demos 1 & 3 silent                                                                                            |
| M-7  | Material | 2, 3 | Bug           | Relative source-code links (`bench/demos/.../*.cpp`) likely 404 in deploy                                                                                                            |
| M-8  | Material | 4    | Drift         | "L3 slice" terminology (lines 132, 196, 198) — Zen 2 CCX L3 is a dedicated per-CCX cache, not a slice                                                                                |
| M-9  | Material | 4    | Quality       | Title + summary + lede + Setup all open with the same producer/consumer framing — triple/quadruple repetition                                                                        |
| M-10 | Material | 4    | Quality       | "Similarly close: 172 vs 148" (line 213) is a 16% gap framed identically to the 8% gap above it                                                                                      |
| L-1  | Low      | 1    | Drift         | Footer `-march=native` vs inline blockquote `-march=znver2` (line 92) — equivalent on this machine, inconsistent in text                                                             |
| L-2  | Low      | 3    | Possible leak | `[brief](docs/briefs/03-simd-blackscholes-brief.md)` link exposes an internal doc path — almost certainly broken at the deployed route, and the brief itself is an internal artefact |
| L-3  | Low      | all  | Style         | Demo 1 uses `_..._` for the Methodology footer link; demos 2-4 use `*...*`. Renders identically; source-level inconsistency only                                                     |
| L-4  | Low      | 4    | Style         | "Zen 2" appears three times in lines 195–198 in close proximity                                                                                                                      |
| L-5  | Low      | 4    | Tonal         | Self-referential meta-prose (line 204): "conflating them was the main flaw in an earlier version of this measurement" — no other post references its own revision history            |
| L-6  | Low      | 2    | Drift         | Section heading "What this **benchmark** doesn't show" — demos 3 and 4 use "What this doesn't show"                                                                                  |
| L-7  | Low      | 4    | Style         | Specifies `CCX1` (line 35, line 132 prose, etc.) where 2 and 3 use generic "CCX" / "intra-CCX". If the choice of CCX1 over CCX0 isn't significant, the specificity is noise          |
| L-8  | Low      | all  | Style         | Opening rhythm: demos 1-3 lead with "Same X. Same Y. Same Z." Demo 4's title preserves the rhythm but the lede paragraph doesn't follow through                                      |

12 critical + material findings, 8 low. Most are quick prose edits.

---

## Critical findings

### C-1 — Demo 4: broken `[Methodology]` markdown link

**Location:** `04-spsc-queue.mdx:244`

**Quote:**

> _Percentile values shown in charts above are computed from raw histograms in the corresponding JSON entries: log₂-subbucket-16 binning, bucket-midpoint percentile convention. Top-bucket counts and TSC drift across all 30 runs were zero. See [Methodology] for the rdtscp calibration path._

**Problem:** `[Methodology]` has no URL component. In MDX this either renders as a broken reference-style link (and there's no matching `[Methodology]: /methodology` definition anywhere in the file) or as literal `[Methodology]` text depending on the MDX/remark configuration. Either way, the reader can't click through. Demo 4's _other_ Methodology link three lines below correctly uses `[Methodology →](/methodology)`.

**Fix:** Change to `[Methodology](/methodology)` or use the same `[Methodology →](/methodology)` arrow form as the second occurrence.

---

### C-2 — Demo 3: stale `cset + sudo` reference in Reproducing-this

**Location:** `03-simd-blackscholes.mdx:240`

**Quote:**

```bash
# Full capture (reference machine, requires cset + sudo)
./scripts/run_one.sh 03-simd-blackscholes
```

**Problem:** The whole point of the harness rebuild (per `03-harness-patch-brief.md` and the methodology page cleanup) was that `cset` was abandoned in favour of `isolcpus`-based kernel isolation. The methodology page no longer mentions `cset`. This comment in demo 3 still does — and worse, it tells a reader that they'll need `cset + sudo`, which they won't and shouldn't.

This is the only `cset` reference I can find in the four posts.

**Fix:** Replace the comment with what the current pipeline actually requires:

```bash
# Full capture (reference machine, booted into the benchmark GRUB entry —
# isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7; SMT off; turbo off)
./scripts/run_one.sh 03-simd-blackscholes
```

Or whatever the actual current preconditions are; mirror demo 2's "Reproducing this" preconditions for consistency (lines 218–221).

---

### C-3 — Demo 1: footer conflates kernel isolation with thread pinning

**Location:** `01-branch-prediction.mdx:253`

**Quote:**

> _All numbers: median ns/iteration, AMD Ryzen 7 3800X at 3.9 GHz base, governor = performance, Turbo Boost off, **isolated cores 4–7**, GCC 13.3 `-O3 -march=native`._

**Problem:** Cores 0–7 are kernel-isolated on the reference machine (1–7 effective, since cpu0 can't be isolated). Cores 4–7 are the _pin set_ for benchmark threads. Saying "isolated cores 4–7" is factually wrong — and a hostile reader who's also read demo 3 ("cores 0–7 isolated, benchmarks pinned to 4–7") will spot the inconsistency immediately.

**Fix:** Match demo 3's phrasing: "cores 0–7 isolated, pinned to 4–7" — or just "pinned to cores 4–7" since the isolation set is fully documented in the methodology page.

---

## Material findings

### M-1 — Demo 4: stated floor doesn't include the actual p50

**Locations:** `04-spsc-queue.mdx:197-198` vs `:152, :211, :213`

**Quote A (the floor claim):**

> On Zen 2 with both threads on the same L3 slice, that cache-coherence round-trip plus the buffer load and store completes in roughly **100–130 nanoseconds** on Zen 2 within a CCX — the floor visible in the p50 numbers above.

**Quote B (the actual numbers):**

> p50 stays near its **132 ns** floor across the entire sweep (line 152)
> the hand-rolled implementation comes in at **132 ns** p50 (line 211, line 213)

**Problem:** 132 is outside [100, 130]. By two ns, but a hostile reader who has just read three "132 ns p50" sentences will notice that the explanation paragraph brackets _below_ the measurement.

**Fix:** Widen the range to "roughly 100–140 ns" or "around 130 ns", or anchor it: "completes in roughly 130 ns — the floor visible in the p50 numbers above." The latter is sharper and matches the prose convention everywhere else of citing single numbers.

---

### M-2 — "Reproducing this" sections appear in 2 & 3 only

**Locations:** `02-false-sharing.mdx:181-231`; `03-simd-blackscholes.mdx:230-244`. Demos 1 and 4 have no equivalent.

**Problem:** Back-to-back, a reader notices that two of four posts walk through how to rebuild and capture, and two don't. This breaks the "every post follows the same playbook" impression that the rest of the structure works hard to maintain.

There are two coherent end-states:

1. **All four have a Reproducing-this.** Closer to the original Crucible thesis ("show the work, make it reproducible"). Costs ~20 lines per post but is the strongest stance.
2. **None do; defer reproduction to the methodology page.** Methodology already covers GRUB entry, governor, isolcpus etc. Posts then only carry per-demo source-file links.

The current half-and-half state is the worst option. Recommendation: pick (1) for consistency, and migrate the demo 2 / demo 3 content into per-post sections of the methodology page or a dedicated Reproducing page if posts grow uncomfortably long.

This is a structural decision rather than a one-line fix and probably wants its own brief if scoped now.

---

### M-3 — "Takeaway" sections appear in 1 & 4 only

**Locations:** `01-branch-prediction.mdx:239-248`; `04-spsc-queue.mdx:231-240`. Demos 2 and 3 have no equivalent.

**Problem:** Mirror image of M-2. Demos 1 & 4 close with a Takeaway paragraph that re-states the headline lesson; demos 2 & 3 close with Reproducing-this and just stop.

Again, two coherent end-states:

1. **All four have a Takeaway.** Default-strong: every post tells the reader the takeaway in their own words rather than relying on the reader to extract it.
2. **None do.** The headline-numbers section in each post already states the lesson; a Takeaway risks reading as a recap.

Recommendation: (1). Demos 1 and 4 are stronger _because_ they have Takeaways — neither feels like recap. Drafting a Takeaway for demos 2 and 3 is a small Opus task.

(M-2 and M-3 together suggest the four posts evolved with slightly different shape expectations. Picking a canonical post template now and migrating all four to it is the right closeout move.)

---

### M-4 — GCC version: 13 vs 13.3

**Locations:**

| Demo | Footer compiler string                                          |
| ---- | --------------------------------------------------------------- |
| 01   | `GCC 13.3 -O3 -march=native`                                    |
| 02   | `GCC 13, -O3 -march=native`                                     |
| 03   | `GCC 13, per-variant ISA flags as documented in CMakeLists.txt` |
| 04   | `GCC 13.3, -O3 -march=native`                                   |

**Problem:** Demos 1 and 4 say "GCC 13.3"; demos 2 and 3 say "GCC 13". Either the captures ran on different patch levels (unlikely; reference machine), or two posts have less-precise compiler IDs than the other two. The hostile read assumption is "they're inconsistent because nobody checked", which is corrosive to the post's stated reproducibility ethos.

**Fix:** Pin all four to whatever was actually used. `gcc --version` on the reference machine is the source of truth; one find-and-replace.

---

### M-5 — Statistical-convention disclosure uneven across footers

**Locations:** footers of each post.

| Demo | Statistical disclosure in footer                                                                                        |
| ---- | ----------------------------------------------------------------------------------------------------------------------- |
| 01   | "All numbers: median ns/iteration" — explicit                                                                           |
| 02   | Silent. Table column header says "Median ns/op" but the footer doesn't carry a statistical statement                    |
| 03   | Silent. No statistic named anywhere in the footer; "ns/option" used throughout                                          |
| 04   | Specifies percentile convention for charts only (line 244); the prose-cited p50/p99/p99.9 numbers inherit it implicitly |

**Problem:** The task-11 brief specifically calls out "statistical convention drift (median+IQR vs p99 vs min)" — and this is where it lives. The numbers cited in the prose of demos 2 and 3 are medians (per the table columns and the JSON), but a reader can't confirm that from the footer.

**Fix:** Standardise the footer to carry a one-line statistical statement at the top of the italicised block. Suggested templates:

- For throughput/latency-median demos (1, 2, 3): _"All numbers: median ns/[unit] across N repetitions."_ Drop in actual N.
- For tail-latency demos (4): _"Latencies quoted as median (p50), p99, p99.9 from raw histograms; log₂-subbucket-16 binning, bucket-midpoint convention."_ (This is what demo 4 already says, just placed at the top of the footer rather than as a standalone first paragraph.)

This pairs naturally with M-6.

---

### M-6 — Repetition count: 20 vs 30 vs unstated

**Locations:**

- Demo 2: "20 repetitions" (line 121, "IQR/median under 0.4% across 20 repetitions")
- Demo 4: "across all 30 runs" (line 244)
- Demos 1, 3: no repetition count stated anywhere

**Problem:** A hostile reader asks "why does the false-sharing post measure 20 reps but the SPSC post measure 30, and why don't the other two say?". The legitimate answer is probably "different demos chose different rep counts based on variance characteristics" — but that's not in the post; the reader has to infer.

**Fix:** Either fold rep count into every footer (per M-5's standardised footer template), or omit it from demos 2 and 4 and rely on the JSON for that level of detail. The former is the stronger stance and is consistent with the methodology page's claim to publish full provenance.

---

### M-7 — Relative source-code links in demos 2 & 3

**Locations:**

- `02-false-sharing.mdx:185-187` — three relative-path links to `bench/demos/.../*` and `tools/*`
- `03-simd-blackscholes.mdx:87, :243-244` — three relative-path links to `bench/demos/03-simd-blackscholes/*`

**Problem:** Next.js routes don't serve `bench/...` paths. These links almost certainly 404 in deploy. They worked when the writer was looking at the repo locally, but not at `crucible.garethcooke.com`. A hostile reader clicks one of them, hits a 404, loses trust.

**Verification needed:** Click each link on the deployed site. Confirm 404 or live.

**Fix (assuming 404):** Either (a) point them at the public GitHub repo with `https://github.com/<user>/crucible/blob/main/bench/...` URLs, or (b) drop the inline links and rely on a single "Source: github.com/<user>/crucible" footer reference in each post. (a) is more reader-friendly; (b) survives repo reorganisation.

Demos 1 and 4 carry _no_ source-file links — that's a separate consistency issue but is closer to (b)'s end-state.

---

### M-8 — "L3 slice" terminology in demo 4 only

**Locations:**

- `04-spsc-queue.mdx:132` — "the shared CCX1 L3 slice without crossing the Infinity Fabric"
- `04-spsc-queue.mdx:196` — "Zen 2 with both threads on the same L3 slice"
- `04-spsc-queue.mdx:198` — implicit reference to the same

**Problem:** On Zen 2, each CCX has its own dedicated 16 MB L3 cache. "Slice" is the terminology for Intel server LLC partitions and (in a different sense) Skylake's mesh LLC — implies a partition of a single larger logical cache. Each CCX's L3 is not a slice of anything; it's a fully independent cache.

Demos 2 and 3 get this right:

- Demo 2: "shared 16 MB L3" within a CCX (line 113)
- Demo 3: "16 MB L3 per CCX" (line 94)

**Fix:** In demo 4, "CCX1 L3 slice" → "CCX1 L3" or "the L3 shared by both cores on CCX1". A search/replace on "L3 slice" in demo 4 is the smallest possible fix.

---

### M-9 — Demo 4: triple/quadruple repetition of the producer/consumer framing

**Locations:** `04-spsc-queue.mdx:4` (summary), `:7` (lede), `:12-13` (Setup section opening)

Same content paraphrased three times in the first 13 lines:

> _Line 4 (summary):_ "End-to-end enqueue→dequeue, market-data thread to strategy thread."
> _Line 7 (lede):_ "A market-data thread produces 16-byte ticks; a strategy thread consumes them. End-to-end enqueue-to-dequeue across three implementations of the same queue API…"
> _Line 12 (Setup):_ "A market-data thread produces ticks; a strategy thread consumes them. We measure the latency…"

**Problem:** None of the other three posts repeat their framing this hard. The summary, lede, and section-1 opener each carry their own job — but here they overlap so much that the first 13 lines reread as draft notes that weren't pruned.

**Fix:** Trim the Setup section opening so it doesn't restate what the lede just said. Something like:

> _Three variants on the same 16-byte `MarketTick`. We measure the latency from the moment the producer stamps the item to the moment the consumer has it in hand — the full journey across the queue._

i.e. drop the "A market-data thread produces ticks; a strategy thread consumes them" sentence from Setup since the lede already established it.

---

### M-10 — Demo 4: "similarly close" frames an 8% gap and a 16% gap identically

**Location:** `04-spsc-queue.mdx:211-213`

**Quote:**

> Under 1 MHz paced load, the hand-rolled implementation comes in at 132 ns p50 vs Boost's 122 ns — within 8%. p99.9 is **similarly close**: 172 ns hand-rolled vs 148 ns Boost.

**Problem:** (132-122)/122 ≈ 8.2%. (172-148)/148 ≈ 16.2%. The post calls these "similarly close" — that's a 2× gap in the gap. Not a contradiction, but a hostile reader scribbles "really?" in the margin. The 16% is in the same _ballpark_, not _similarly close_.

**Fix:** Cleanest is to admit the asymmetry rather than smooth it over:

> Under 1 MHz paced load, the hand-rolled implementation comes in at 132 ns p50 vs Boost's 122 ns — within 8%. The p99.9 gap is wider — 172 ns vs 148 ns, about 16% — but both are still well below the mutex variant's tail by orders of magnitude.

That keeps the "Boost validates the hand-rolled implementation" thesis intact without overclaiming on the tail equivalence.

---

## Low-priority findings

### L-1 — Demo 1: inline `-march=znver2` vs footer `-march=native`

`01-branch-prediction.mdx:92` (inline blockquote): `GCC 13.3 at -O3 -march=znver2`
`01-branch-prediction.mdx:253` (footer): `GCC 13.3 -O3 -march=native`

On the reference machine these resolve to the same thing, but the reader doesn't know that. Pick one and use it throughout. Recommendation: `-march=native` for the footer (matches demos 2 & 4); leave `-march=znver2` in the inline blockquote with a parenthetical "(`-march=native` resolves to this on the reference machine)" if the explicit ISA matters to the point being made — it does, since the auto-vectorised vpcmpgtd/vpand/vpaddd path is znver2-specific.

### L-2 — Demo 3: `[brief](docs/briefs/03-simd-blackscholes-brief.md)` link

`03-simd-blackscholes.mdx:184`. Two problems:

1. The path `docs/briefs/03-simd-blackscholes-brief.md` isn't served by Next.js; the link is almost certainly 404 in deploy.
2. The brief itself is an internal Opus→CC artefact. It contains scoping decisions, intermediate-state TODOs, and acceptance criteria written for the AI implementer — not reader-facing material.

**Recommendation:** Remove the link. The paragraph stands fine without it: the trade-off is _stated_ in the post; that's enough. If the post wants to gesture at the deeper rationale, one or two extra sentences in-post is better than linking out to a private doc.

### L-3 — Demo 1 vs 2/3/4 footer emphasis style

`01-branch-prediction.mdx:258`: `_[Methodology →](/methodology)_`
Demos 2/3/4: `*[Methodology →](/methodology)*`

Renders identically. Pure source-level inconsistency. Trivial fix — touch one character.

### L-4 — Demo 4: "Zen 2" three times in four lines

`04-spsc-queue.mdx:195-198`:

> _On Zen 2 with both threads on the same L3 slice, that cache-coherence round-trip plus the buffer load and store completes in roughly 100–130 nanoseconds **on Zen 2** within a CCX — the floor visible in the p50 numbers above._

The "on Zen 2 [...] on Zen 2 within a CCX" sequence is internally redundant. Drop one of them.

### L-5 — Demo 4: self-referential meta-prose

`04-spsc-queue.mdx:203-204`:

> _The post labels these separately because conflating them was the main flaw in an earlier version of this measurement._

No other post references its own revision history. Either bring this style to demos 1-3 (everyone gets a "what we revised in version N" callout — probably overkill) or trim it from demo 4. The point being made — that the two saturation mechanisms are genuinely different — survives without the meta-prose.

### L-6 — Demo 2: section heading "What this **benchmark** doesn't show"

`02-false-sharing.mdx:166` vs `03-simd-blackscholes.mdx:201` and `04-spsc-queue.mdx:217`.

Demo 2 adds "benchmark"; the other two don't. Trivial. Pick one and apply it everywhere; "What this doesn't show" is the shorter form and matches 2-of-3 already.

### L-7 — Demo 4: `CCX1` specificity

`04-spsc-queue.mdx:35`: "both on CCX1 of the Ryzen 7 3800X, sharing an L3 slice"
`04-spsc-queue.mdx:132`: "the shared CCX1 L3 slice"

If the choice of CCX1 over CCX0 isn't measurable (and there's no reason it would be — they're symmetric on Zen 2), the specificity is noise. Demo 2 uses generic "intra-CCX" / "cross-CCX" without naming the CCX, which is the right level of abstraction. Recommendation: generic "CCX" wherever the specific CCX number isn't a load-bearing detail.

### L-8 — Demo 4: lede doesn't follow the "Same X. Same Y. Same Z." pattern

Demos 1, 2, 3 all open with the same rhetorical rhythm:

- Demo 1: "Same code. Same data values. Same compiler flags."
- Demo 2: "Same algorithm. Same fill stream. Same machine."
- Demo 3: "Same pricing model. Same input chain. Same machine."

Demo 4's title preserves the rhythm ("Same queue API. Different tail by orders of magnitude.") but the lede paragraph opens differently. Either rewrite the demo 4 lede to follow the pattern, or accept the divergence. Honestly the title doing it is probably enough; this one is at the cosmetic end.

---

## Cross-cutting observations (not findings)

A few things showed up on the back-to-back read that aren't drift per se but are worth naming:

**The four posts read as four posts, not as a series.** Each is internally well-formed; the connective tissue is thin. The cross-link added in task 8 (demo 2 ↔ demo 4 via PaddedAtomic) is the only inline pointer between posts. The forward link in demo 1 to demo 3 ("That's a different story […], and gets its own [post](/posts/03-simd-blackscholes)") is the only other one. If the portfolio framing is "Crucible is a coherent set of demos," the inter-post links should probably be denser. Demo-5-scoping concern, not a fix-now.

**The index page does heavy lifting for series-coherence that the posts don't.** This means a reader who lands on demo 3 from a search engine has no path back to the index unless they spot the TopNav. (I haven't audited the TopNav in this read; task 9/10 covered it.) Not a finding here; just a reason the cross-link density above matters.

**The methodology page is leaned on heavily for "see methodology for details".** All four posts end with a Methodology link. None of them duplicate methodology content — good. But this means the methodology page is doing real work; task 2's Opus pass on it is the load-bearing piece.

**Demo 3 is the strongest post on a back-to-back read.** Cleanest decomposition (12% → 4× → 2×), tightest "what this doesn't show" section, most precise about caveats (the percentages are stated with bounds rather than handwaved). It's the one I'd hand to a hostile interviewer first. Demo 4 is the most ambitious — the load-sweep chart and the saturation-mechanism discussion are genuinely advanced — but it also has the most quality drift relative to its own thesis (M-1, M-8, M-9, M-10 are all demo 4).

---

## Recommendations

### Quick fixes (one CC pass)

Bundle C-1, C-2, C-3, M-1, M-4, M-8, L-1, L-2, L-3, L-4, L-5, L-6 into a single cleanup brief. All are 1–3 line text edits, all are well-defined. None require Opus judgement — the briefs already specify the fix verbatim above.

Suggested filename: `pre-demo-5-10-hostile-cross-read-cleanup-brief.md`.

### Structural decisions (need Opus + user input before scoping)

M-2 (Reproducing-this presence) and M-3 (Takeaway presence) are the same shape of question: pick a canonical post template, migrate the four posts to it. Recommendation: every post has a Takeaway (per M-3 option 1) and Reproducing-this lives on the methodology page (per M-2 option 2 — minimal posts, shared methodology). That keeps the posts tight and concentrates the reproduction guidance in one place.

If user agrees, scope as `pre-demo-5-11-post-template-canonicalisation-brief.md`.

### Verification needed

M-7 (relative source-code links): one tab open, four clicks. If they all 404, fold into the cleanup brief (replace with GitHub URLs or drop). If they all live, downgrade M-7 to low.

### Defer (demo 5+ concern)

The "four posts read as four posts, not a series" observation isn't fixable inside the existing posts without bloat. Worth keeping in mind when the index page or a future series-overview is touched — but not a pre-demo-5 task.

### Pieces task 11 explicitly _didn't_ surface

For the record, the hostile read found:

- **No statistical convention contradictions.** Drift in disclosure (M-5) but no post quotes a median where it should quote a p99, and the percentile-based demo 4 doesn't accidentally call p99.9 a "median".
- **No Zen 2 / CCX factual contradictions.** "L3 slice" terminology is mildly wrong (M-8) but the rest of the architecture description (CCD, CCX, IOD, Infinity Fabric, 16 MB L3 per CCX, 19-cycle pipeline depth, 35-cycle L3 latency) is internally consistent across the posts that mention it.
- **No numerical contradictions in headline claims.** 7× / 6.7× (demo 1), 5× / 13× (demo 2), 12% / 9× / ~10× (demo 3), the ns-per-op figures (demo 4) all round-trip cleanly against the JSON-derived percentages quoted in the prose. M-1 is a "stated range is too narrow" finding, not a "wrong number" finding.
- **No tonal whiplash.** The four posts have slightly different shapes (M-2, M-3, L-8) but the voice is consistent: technical, declarative, willing to disclose what didn't work and why. No post is significantly more or less didactic than the others.

In other words: the back-to-back read confirms the posts are individually solid. The findings here are the polish layer that lifts the set from "four good posts" to "one coherent body of work".

---

## Stop condition for task 11

This findings doc closes task 11's audit half. Triage (the next-step half) is:

1. Confirm M-7 by clicking the deployed links.
2. User decides on M-2 / M-3 (post template canonicalisation — defer or do).
3. Opus writes the cleanup brief covering all the agreed-quick-fixes.
4. CC applies the brief.
5. Mark task 11 ☑.

After which only task 12 (Amplify deploy verification, user manual) remains before demo-5 scoping begins.
