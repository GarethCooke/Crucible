# Crucible — Demo 08 plan

Tracking doc for demo 8 (sorting shootout: `std::sort` vs `pdqsort` vs radix sort on integer keys, across N and input distribution). The teaser stub ships to `main` first (§0, per a forthcoming `demo-08-teaser-brief.md`); substantive work then proceeds on a feature branch.

This plan applies the lessons from demos 5–7:

1. **Preflight calibration is a task, and the pilot may reframe the thesis.** Demo 8's headline is pilot-contingent: it depends on the radix-vs-comparison crossover sitting at a chartable N, and on the input-distribution sensitivity being large enough to carry chart 2. The pilot confirms both before the brief commits.
2. **Capture environment is explicit.** Headless boot, single isolated core, matching demos 1–7. Stated in the brief, not assumed.
3. **`sudo cset shield --reset` is a precondition** of every fresh capture session (now in `BRIEF.md` per the demo 6 close-out). Named in §2's brief and §6's capture checklist as defence in depth.

## Story angle (provisional — pilot confirms)

`std::sort` is the default everyone reaches for, and it is rarely the actual winner. The post measures two things at once:

- **Why a non-comparison sort can win.** `std::sort` (introsort) is bounded by the comparison lower bound, Ω(n log n). Radix sort sidesteps it — it's O(n · w/r) for w-bit keys at r bits per pass — by exploiting that the keys are fixed-width integers. Not magic; a different cost model. Past some N, radix pulls ahead.
- **Why input shape decides the comparison-sort race.** `pdqsort` (pattern-defeating quicksort) detects sorted runs and few-unique-key inputs and avoids quicksort's worst case; `std::sort` is more uniform; radix is nearly distribution-insensitive. On random data the comparison sorts cluster; on structured data they spread dramatically.

**Headline framing — NOT "crossover."** The demo 7 hostile cross-read (L-1) flagged that demos 6 and 7 both negate "crossover"; a third would read as a tic. Lead instead with the mechanism ("the comparison lower bound is a wall `std::sort` can't climb; integer keys let you go around it") or with the **tail-latency hook**: radix's runtime is essentially data-independent, so it's a p99 win on a hot-path sort even where its median isn't best. The tail-latency angle ties demo 8 to the through-line from demos 4 and 5 and is the strongest pull for the capital-markets reader.

**What the post does NOT claim:** that radix is universally faster (it loses at small N and as key width grows); that `std::sort` is bad (it's a fine default); that these results transfer to non-integer or variable-width keys (they don't — comparison sorts are the only general option there).

## Tasks

| #   | Task                                                                                                                                                                                                                                                                                                                                                                              | Model                | Status |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | ------ |
| 0   | Teaser stub on `main`. `site/src/posts/08-sorting-shootout.mdx` exists, eight-card index renders, "In Progress" pill on demo 8. Per a forthcoming `demo-08-teaser-brief.md`.                                                                                                                                                                                                       | CC                   | ☑      |
| 1   | **Calibration pilot.** Throwaway bench (no JSON, no chart, no commit-ready output) on the reference machine. Goals: (a) confirm the radix-vs-comparison crossover sits at a chartable N (not N≈8, not N>10⁹); (b) confirm the time-vs-N curve shows cache-tier inflections from L2 upward; (c) confirm input-distribution sensitivity is real and quantifiable (chart 2 depends on it); (d) confirm the destructive-sort harness pattern (pristine-buffer restore outside the timed region) gives stable numbers. Output: notes for the brief. | Opus scope, user run | ☑      |
| 2   | **Write `08-sorting-shootout-brief.md`.** Implementation brief in the format of `07-flatmap-vs-hashmap-brief.md`. Explicit capture-environment field. Variant list, key type(s), N range, and input distributions pinned from §1 findings. The destructive-sort re-randomization hazard named explicitly in the harness spec. `cset shield --reset` in the precondition list. | Opus                 | ☑      |
| 3   | **Bench implementation.** `bench/demos/08-sorting-shootout/` with the variants (`std::sort`, `pdqsort`, hand-rolled LSD radix for u32; optionally a tuned-library radix line and `std::stable_sort` — §1/§2 decide). N-sweep harness, input-distribution parameter, JSON output matching schema. **Harness must restore a pristine input buffer each iteration via `memcpy` from a master copy, with the copy outside the timed region** (`PauseTiming`/`ResumeTiming` or equivalent). `benchmark::DoNotOptimize` on a checksum so the sort isn't elided. `run_one.sh 08-sorting-shootout` orchestrates the capture. | CC                   | ☑      |
| 4   | **Preflight calibration** (post-harness). Run §2's calibration against the built harness. Confirm §1 reproduces through the formal pipeline — in particular that iteration-2 numbers match iteration-1 (proves the pristine-buffer restore works; if they diverge, the destructive-sort bug is present). If findings diverge, loop back to §3 or rescope §2. | CC + user            | ☑      |
| 5   | **Chart-component check.** Chart 1 (time-vs-N staircase, all variants, random input) reuses `<TimeVsN>` with cache-tier band markers from demo 6/7 — verify it takes the data as-is. Chart 2 (distribution sensitivity at a fixed large N across random/sorted/reverse/few-unique/sawtooth) needs a grouped view — decide between repeated `<ThroughputBars>` calls per distribution vs a small grouped-bar extension. Resist forking a bespoke "SortChart"; extend or compose. | Opus scope, CC apply | ☑      |
| 6   | **Headline capture.** Reference machine, headless boot, single isolated core, `sudo cset shield --reset`, `CRUCIBLE_TURBO=off`, ≥5 outer repetitions. Output to `site/src/data/perf/08-sorting-shootout.json`. JSON validates against the locked schema. | user (manual)        | ☑      |
| 7   | **MDX post.** Replace the teaser stub on the feature branch. Adapt the section structure from demo 7. Remove `status: "in-progress"` and `expectedAt`. Cross-links: **backward-link to demo 1** (demo 1 showed sorting makes the *downstream* loop branch-predictable; demo 8 measures what the sort itself costs — a clean pairing) and to demo 6/7 (cache staircase); forward-links inserted from demo 1, 6, 7 to demo 8. Methodology page — demo total bumped to 8 if it references one. | Opus draft, CC apply | ☑      |
| 8   | **Hostile-reviewer cross-read.** Single-post version of pre-demo-5 task 11. Read demo 8 back-to-back with 1–7. Watch for: statistical convention drift, Zen 2 framing consistency, methodology consistency, tonal drift, repeated/contradictory caveats — **and specifically whether the headline avoids the over-used "crossover" framing** (see Story angle). | Opus                 | ☐      |
| 9   | **Pre-merge review.** Final check of MDX against data, methodology, and the conventions of demos 1–7. | Opus                 | ☐      |
| 10  | **Merge to main.** Feature branch merged. Stub MDX overwritten. JSON committed. Index renders eight fully shipped cards (no pill on demo 8). Amplify auto-deploys. | user (manual)        | ☐      |
| 11  | **Post-ship verification.** `crucible.garethcooke.com/posts/08-sorting-shootout` resolves, all charts render cleanly, demo 8 card shows no pill. Portfolio cross-link still correct. | user (manual)        | ☐      |

## Dependency notes

- §1 blocks §2. Pilot before brief — the demo 5/6/7 lesson.
- §2 blocks §3 and §6.
- §3 blocks §4. §4 can loop back to §2 or §3 if findings diverge — expected, not a failure mode.
- §5 can run in parallel with §3 and §4. `<TimeVsN>` is already extended; most of §5 is verification plus the chart-2 grouped-view decision. Demo 6/7 JSON suffices for chart-shape sanity-checking during development.
- §6 blocks §7 (the post needs the JSON to render).
- §7 blocks §8 and §9. Both block §10.
- §11 is independent; can be done any time post-merge.

## Lessons from demos 5–7 applied to this plan

- **§1 exists at all.** The headline is pilot-contingent on the crossover N and the distribution sensitivity both being chartable. If either isn't, the thesis reframes before §2 commits.
- **The destructive-sort hazard is named up front.** Sorting mutates its input; an unrestored buffer measures the best case on every iteration after the first. This is the demo-specific analogue of demo 4's warmup contamination — surfaced in §1, §3, and §4 so it can't slip through.
- **`<TimeVsN>` reuse, not fork.** Chart 1 inherits the cache-tier band work directly. Chart 2 is a composition/small-extension decision, not a new component.
- **Headline avoids "crossover."** A concrete carry-forward from the demo 7 hostile cross-read (L-1). §8 checks it explicitly.
- **Capture environment in §2's brief explicitly.** Headless, single isolated core. Stated, not assumed.
- **`sudo cset shield --reset` is a precondition.** In `BRIEF.md`; named in §2 and §6 as a reminder.
- **No backlog brief-format change.** Demo 7's shape worked. Keeping it.

## Open items (to be resolved during §1 / §2)

- **Crossover N location.** Pilot decides. Radix should win at large N for u32; the small-N regime where comparison sorts win sets the chart's left edge. If radix wins everywhere chartable, or nowhere, the framing shifts.
- **Radix implementation.** Hand-rolled LSD radix for u32 (4× 8-bit passes) is the clearest and matches the project's "roll one, call out the simplifying assumptions" ethos. Optionally add a tuned-library line (`boost::sort::spreadsort` or `ska_sort`) as the "what production radix looks like" contrast. Default: hand-rolled LSD as the radix line; tuned library as an optional second line if it doesn't clutter chart 1.
- **`pdqsort` source.** Vendor the header (Orson Peters, zlib licence). Confirm zlib-on-MIT compatibility (permissive, fine) and call out the vendored dependency in the post and README.
- **Key type and width.** u32 keys as the headline. u64 as a key-width callout (8 passes vs 4 → radix's advantage shrinks) — full chart or sidebar paragraph, editorial. Default: u32 headline, u64 as a callout.
- **Bare keys vs key+payload.** Bare u32 keys for the headline (stability moot, scatter cost minimal). Key+payload as a possible sidebar — payload size inflates the radix scatter cost and makes stability visible (LSD radix is stable; `std::sort` and `pdqsort` are not). Default: bare keys headline.
- **`std::stable_sort` line.** Include on the headline chart, or one-line callout on the stability/merge-sort cost? Default: callout, to keep chart 1 readable.
- **Input distributions for chart 2.** random / sorted / reverse-sorted / few-unique / sawtooth is the candidate set. Pilot confirms which produce a chartable spread; drop any that duplicate another's shape.
- **Chart 2 component shape.** Repeated `<ThroughputBars>` per distribution, or a grouped-bar extension. §5 decides; editorial lean toward whichever keeps the five-distribution view legible.

## Stop condition

Demo 8 ships when §10 lands: feature branch merged to main, stub MDX overwritten, JSON committed, index renders eight fully shipped cards with no in-progress pill on demo 8, Amplify has redeployed, and §11 confirms the live site. Then either scope demo 9 (remaining handover candidate: ARM NEON cross-arch on the Pi 5) or stand up the quantum "measuring the gap" special edition (`quantum-measuring-the-gap-scope.md`), field-state rechecked at brief time.
