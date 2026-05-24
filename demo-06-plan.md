# Crucible — Demo 06 plan

Tracking doc for demo 6 (AoS vs SoA across the cache-hierarchy staircase). The teaser stub has shipped on `main` (per `demo-06-teaser-brief.md`); the substantive work proceeds on a feature branch.

This plan applies the three lessons logged in the demo 5 detour notes:

1. **Preflight calibration is a task, not an afterthought.** If the post's thesis depends on a specific magnitude or crossover existing on the reference machine, prove it before writing the implementation brief.
2. **Capture environment is an explicit field.** Headless boot, matching demos 1–5. Stated in the brief, not assumed.
3. **`sudo cset shield --reset` is a precondition** of every fresh capture session on this machine (cpuset v1 / PID 1 affinity gotcha). Already in the calibration-notes README from demo 5; surface it in the demo 6 brief too.

## Tasks

| #   | Task                                                                                                                                                                                                                                                                                                                                                                                                                                 | Model                | Status |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------- | ------ |
| 0   | Teaser stub on `main`. `site/src/posts/06-aos-vs-soa.mdx` exists, six-card index renders, "In Progress" pill on demo 6.                                                                                                                                                                                                                                                                                                              | CC                   | ☑      |
| 1   | **Calibration pilot.** Quick, throwaway bench (no JSON, no chart, no commit-ready output) on the reference machine. Goals: confirm the cache-tier staircase is cleanly visible at the chosen struct size; confirm the AoS↔SoA crossover exists at a reasonable point in the access-pattern axis; confirm at least one working-set tier shows a multiple-of-2 separation between layouts. Output: notes for the implementation brief. | Opus scope, user run | ☑      |
| 2   | **Write `06-aos-vs-soa-brief.md`.** Implementation brief in the format of `05-allocators-brief.md`. Explicit capture-environment field. Preflight-calibration step baked in (separate from §1 — a formal calibration that runs against the real harness once it exists). `cset shield --reset` named in the precondition list. Struct size, field count, sweep ranges, and access-pattern grain set from §1 findings.                | Opus                 | ☑      |
| 3   | **Bench implementation.** `bench/demos/06-aos-vs-soa/` with struct definition, AoS + SoA layouts, working-set sweep harness, access-pattern parameter, JSON output matching schema, perf-counter capture (cache miss rate). `run_one.sh 06-aos-vs-soa` orchestrates the full capture.                                                                                                                                                | CC                   | ☑      |
| 4   | **Preflight calibration** (post-harness). Run the calibration step from §2's brief against the built harness. Confirm the §1 findings reproduce through the formal pipeline. If they don't, loop back to §3 or rescope §2 before the headline.                                                                                                                                                                                       | CC + user            | ☑      |
| 5   | **Chart-component decision and implementation.** Decide: extend `<TimeVsN>` with cache-tier band markers, or introduce a new `<CacheStaircase>` component. Reuse the existing line-chart primitive (whatever demo 4's load-sweep / demo 5's `<PressureSweep>` settled on) for the access-pattern-crossover supporting view. Reuse `<ThroughputBars>` unchanged for the vectorised hot-column comparison.                             | Opus scope, CC apply | ☐      |
| 6   | **Headline capture.** Reference machine, headless boot, `sudo cset shield --reset`, `CRUCIBLE_TURBO=off`, ≥5 outer repetitions. Output to `site/src/data/perf/06-aos-vs-soa.json`. JSON validates against the locked schema.                                                                                                                                                                                                         | user (manual)        | ☑      |
| 7   | **MDX post.** Replace the teaser stub on the feature branch. Adapt the section structure from demo 5. Remove `status: "in-progress"` and `expectedAt`. Cross-links: forward-link from demo 1 (cache-hierarchy intro) and demo 3 (SIMD) inserted; backward-link from demo 6 to those two added. Methodology page reviewed — does it reference a demo total that needs bumping?                                                        | Opus draft, CC apply | ☑      |
| 8   | **Hostile-reviewer cross-read.** Single-post version of pre-demo-5 task 11. Read demo 6 back-to-back with 1–5. Watch for: statistical convention drift (median+IQR vs p99 vs min), Zen 2 / CCX framing consistency, methodology consistency (headless declared in the post or methodology link), tonal drift, repeated or contradictory caveats.                                                                                     | Opus                 | ☐      |
| 9   | **Pre-merge review.** Final check of MDX against data, methodology, and the conventions established by demos 1–5. Mirrors pre-demo-5 phase 2 task 26.                                                                                                                                                                                                                                                                                | Opus                 | ☐      |
| 10  | **Merge to main.** Feature branch merged. Stub MDX overwritten. JSON committed. Index renders six fully shipped cards (no pill on demo 6). Amplify auto-deploys.                                                                                                                                                                                                                                                                     | user (manual)        | ☐      |
| 11  | **Post-ship verification.** `crucible.garethcooke.com/posts/06-aos-vs-soa` resolves, all charts render cleanly, demo 6 card on the index shows no pill. Portfolio cross-link (`garethcooke.com/projects/crucible`) still points correctly.                                                                                                                                                                                           | user (manual)        | ☐      |

## Dependency notes

- §1 blocks §2. The lesson from demo 5 is that the brief should be informed by empirical reality, not aspiration.
- §2 blocks §3. §3 blocks §4 and §6.
- §4 can loop back to §2 or §3 if findings diverge from §1. This is expected, not a failure mode — same shape as demo 5's calibration ladder.
- §5 can run in parallel with §3 and §4 (component work doesn't need real data; mock or demo 1's existing JSON suffices for development).
- §6 blocks §7 (the post needs the JSON to render).
- §7 blocks §8 and §9. Both block §10.
- §11 is independent; can be done any time post-merge.

## Lessons from demo 5 applied to this plan

- **§1 exists at all.** The original demo 5 brief committed to a 2× p99.9 target that the workload couldn't deliver; calibration discovered this after the brief was written. Demo 6's §1 is a deliberate up-front pilot before any brief commits to numbers. Since demo 6's headline is _qualitative_ ("the crossover isn't where you think") more than _quantitative_, the calibration risk is lower than demo 5's — but cheap to do, and the brief will be sharper for it.
- **Capture environment is in §2's brief explicitly.** Headless. Stated, not assumed. Avoids the late-stage methodology-consistency fix that demo 5 needed.
- **`sudo cset shield --reset` is a precondition.** Named in §2's brief, named in the capture-session checklist for §6.
- **No demo 6 backlog brief format change yet.** Demo 5's `Phase 2` shape worked. Keeping it.

## Open items (to be resolved during §1 / §2)

- Struct shape: total size and field count. A 64 B single-cache-line struct shows no AoS-side waste; the demo needs a wider struct to make the crossover visible. Likely 128 B or 256 B with 4–16 fields. §1 settles this.
- Inner-loop computation: bytes-touched only, or a real reduction (sum, predicate, dot product)? A real reduction is more honest and produces meaningful `ns_per_op`; bytes-touched isolates memory cost but loses interpretability. Default: a real reduction.
- Vectorised path scope: scalar SoA vs auto-vectorised SoA vs intrinsic SoA. Probably just scalar vs auto-vec — intrinsics duplicate demo 3 without adding to demo 6's thesis.
- Random vs sequential access within the working set: sequential matches the option-chain-scan framing; random is a different demo entirely. Pick sequential and call it out.
- Chart component: extend `<TimeVsN>` or introduce `<CacheStaircase>`. §5 decides; the decision is partly aesthetic (band markers for L1/L2/L3/DRAM are the differentiator) and partly DRY-discipline (extending an existing component beats forking one).
- Does `BRIEF.md` or `crucible-handover.md` need the `cset shield --reset` precondition hoisted into the global precondition checklist? Demo 5's detour notes flagged this; demo 6 is a good moment to either do it or explicitly defer. Probably a one-line edit; folding it into §2 is fine.

## Stop condition

Demo 6 ships when §10 lands: feature branch merged to main, stub MDX overwritten, JSON committed, index renders six fully shipped cards with no in-progress pill on demo 6, Amplify has redeployed, and §11 confirms the live site. Then begin scoping demo 7 (current top candidate: hash-map shootout, per the runner-up in the demo 6 scoping conversation).
