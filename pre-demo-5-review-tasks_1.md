# Crucible — pre-demo-5 review task list

Context: demos 1-4 are shipped, each has had a skeptical review pass. Before scoping demo 5, run this pass across the project as a whole. Companion to `BRIEF.md` and `crucible-handover.md`.

Model column: **CC** = Claude Code (implementation), **Opus** = in-chat scoping/judgment, **user** = manual step.

| #   | Task                                                                                                                                                                                                                                                                                       | Model                  | Status |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------- | ------ |
| 1   | Audit JSON machine blocks across demos 1-4. Verify `turbo`, `isolated_cpus`, `governor`, no stale `compiler_flags` field, all consistent post-harness-patch. Demos 1, 3, 4 were originally captured with broken turbo reporting (per `03-harness-patch-brief.md`) — confirm reruns landed. | CC                     | ☑      |
| 2   | Methodology page read-through against current shipped state. Should reflect: dual GRUB entry, `cpupower` turbo verification, `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7`, no `cset` references, statistical conventions matching what the posts actually report.                            | Opus                   | ☑      |
| 3   | Index page audit — all four posts listed, dates real and chronological, ordering sensible, summaries match the rewritten prose (not stale from earlier captures).                                                                                                                          | CC                     | ☑      |
| 4   | README accuracy post-harness-churn. Should cover: `CRUCIBLE_TURBO` env var contract, benchmark GRUB entry precondition, `perf_event_paranoid` / `setcap cap_perf_event=ep` resolution, current build + capture commands.                                                                   | CC                     | ☑      |
| 5   | Full code review — `bench/` (C++ harness, `common/`, all four demos). Use `code-review` skill. Focus: DRY across demos, harness asymmetries between variants, defensive asserts, idiom drift between demo 1 (oldest) and demo 4 (newest).                                                  | CC + code-review skill | ☑      |
| 6   | Full code review — `site/` (components, charts, MDX plumbing, data loaders). Use `code-review` skill. Focus: chart component DRY, data-loading patterns, theme usage, MDX consistency across the four posts.                                                                               | CC + code-review skill | ☑      |
| 7   | Triage code-review findings into remediation briefs. Anything material gets its own brief in the established format; anything trivial gets folded into a single cleanup brief.                                                                                                             | Opus                   | ☑      |
| 8   | Cross-links between cache-line-themed posts. Demo 4's `PaddedAtomic` static-assert is a direct echo of demo 2's thesis — a single sentence in each direction strengthens both.                                                                                                             | Opus scope, CC apply   | ☑      |
| 9   | Lighthouse ≥90 verification on demos 2, 3, 4 post pages. (Was acceptance criterion for demo 1 only; chart-heavy pages drift.)                                                                                                                                                              | CC                     | ☑      |
| 10  | Mobile rendering pass on all four posts. Charts are where this falls over — `<LatencyHistogram>` and `<CounterOverlay>` in particular.                                                                                                                                                     | CC                     | ☑      |
| 11  | Hostile-reviewer cross-read of all four posts in sequence. Each demo has been defended in isolation; this is the back-to-back pass. Watch for: statistical convention drift (median+IQR vs p99 vs min), Zen 2 / CCX framing consistency, repeated or contradictory caveats, tonal shifts.  | Opus                   | ☐      |
| 12  | Amplify deploy verification (`crucible.garethcooke.com` resolves and serves current build) + portfolio cross-link confirm (`garethcooke.com/projects/crucible` card exists, links out, matches FrontierView pattern).                                                                      | user (manual)          | ☐      |

## Dependency notes

- Tasks 1-6 can run in parallel — they're audits, no fixes yet.
- Task 7 is the funnel — everything from 5 and 6 lands here as briefs before any code changes.
- Tasks 8-10 are polish; can run after 7's briefs are scoped, in parallel with each other.
- Task 11 is the final gate before demo 5 scoping. Anything it surfaces is either a quick fix or a deferred brief.
- Task 12 is independent of the rest; can be done any time the site is in a deployable state.

## Stop condition

All twelve done, or any deferred items written up as their own briefs and pushed into the demo-5+ backlog. Then scope demo 5 (allocators, per the handover discussion).
