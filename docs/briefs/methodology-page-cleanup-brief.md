# Crucible — methodology page cleanup brief

Read `BRIEF.md`, `crucible-handover.md`, and `pre-demo-5-review-tasks.md` for project context. This brief addresses task 2 (pre-demo-5 methodology page read-through). Page-text only — no script, schema, or JSON changes.

## Context

The pre-demo-5 review of `/methodology` (live at `https://crucible.garethcooke.com/methodology`, source at `site/src/app/methodology/page.tsx`) flagged one content gap, two verification dependencies, and several structural / cosmetic issues. This brief consolidates them.

The page survived the harness patch (`03-harness-patch-brief.md`) cleanly on the big swaps — `cpupower`-based turbo verification, the new `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` cmdline, and the removal of `cset` references all landed. The remaining issues are listed below.

## Goals

- `/methodology` matches operational reality: dual-GRUB-entry, the actual repetition floor used in shipped JSONs, the actual JSON field name for isolated cores.
- No methodological claim on the page outruns what scripts actually do.
- Repetitive boot-parameter prose consolidated; rendering glitches resolved.

## Scope

### 1. Verify three claims against shipped state before editing

Don't ship items 5–7 without these findings.

**1a. JSON field name for isolated cores.** Three names are in circulation: `BRIEF.md`'s schema says `isolated_cores`; `pre-demo-5-review-tasks.md` task 1 says `isolated_cpus`; the methodology page currently cites `machine.cpu_affinity`. Open all four shipped JSONs at `site/src/data/perf/*.json` and report the actual field name. If the JSONs disagree among themselves, pause and flag — that's a schema-consistency problem that needs resolution before this brief lands.

**1b. IRQ-affinity steering.** The page asserts: _"The wrapper also steers IRQ affinity to non-benchmark cores via `/proc/irq/_/smp_affinity`for the duration of each run."* No brief in project history specifies this. Grep`bench/scripts/`and`tools/`(and anywhere else runner code might live) for`smp_affinity`or`/proc/irq`. Report whether the claim has a code source.

**1c. Repetition count.** The page says _"Each benchmark runs ≥20 repetitions after warmup."_ Demo 2's brief originally specified `--benchmark_repetitions=11`. Open each shipped JSON and read its `repetitions` field (name may vary — adjust accordingly). Report the minimum value across the four demos.

Findings go in the PR description / chat reply alongside the edits.

### 2. Add dual-GRUB-entry mention (critical gap)

The reference machine has two GRUB entries: a standard entry for development, and a benchmark entry that boots with `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7`. This was the resolution agreed in `02-false-sharing-remediation-brief_1.md` and is currently invisible to a page reader.

Add a paragraph inside commitment 3 (or end of the reference-machine block — your call on placement) along these lines:

> Boot parameters are scoped to a dedicated GRUB entry — "Ubuntu (benchmark — cores 0-7 isolated)" — distinct from the standard entry used for development. Capture runs require booting the benchmark entry; the runner aborts if `/sys/devices/system/cpu/isolated` does not report `0-7`.

The "runner aborts" claim is verifiable via the runner script — confirm it before including. If the abort guard isn't actually in the script, drop that sentence and flag it (it should be — see `02-false-sharing-remediation-brief_1.md` task 3).

### 3. Consolidate boot-parameter restatements

The kernel cmdline `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` and the "pin to cores 4–7 via taskset" detail appear in four places on the page:

- Reference-machine table "Boot" row
- "Boot parameters" sub-paragraph immediately after the table
- Commitment 3 main paragraph
- Commitment 3 "Cross-CCX results" sub-paragraph

Reduce to two: the table row (terse), and commitment 3 (canonical, single paragraph). Drop the standalone "Boot parameters" sub-paragraph after the table — its content is covered by commitment 3. Trim the "Cross-CCX results" sub-paragraph so it begins at the cpu0 caveat; it should not restate the kernel cmdline that commitment 3's first sentence already states.

### 4. Reconcile "8 cores / 16 threads" with "SMT disabled"

Reference-machine CPU line reads _"AMD Ryzen 7 3800X — 8 cores / 16 threads, Zen 2"_. The BIOS row immediately below says "SMT disabled". Commitment 3 then asserts `lscpu` reports 8 CPUs. A careful reader pauses on the 16-threads figure.

Change the CPU line to one of:

- "AMD Ryzen 7 3800X (Zen 2) — 8 physical cores; SMT disabled in BIOS, 8 logical CPUs exposed"
- "AMD Ryzen 7 3800X (Zen 2) — 8C/16T silicon, SMT disabled, 8 logical CPUs exposed during benchmarks"

The goal is no implication that benchmarks run on 16 logical threads.

### 5. Update repetition-count claim per finding 1c

State the actual minimum observed across the four shipped JSONs. If the floor is N:

> Each benchmark runs ≥N outer repetitions (Google Benchmark `--benchmark_repetitions`); aggregates (median, IQR, min) are computed across those repetitions.

Naming "outer repetitions" explicitly closes the Google Benchmark ambiguity between `--benchmark_repetitions` and `--benchmark_iterations`.

If the minimum is below 11, stop and flag — that's a methodology violation, not a documentation fix.

### 6. Align field-name reference per finding 1a

Wherever the page currently says `machine.cpu_affinity`, replace with whatever name finding 1a establishes is in use across all four shipped JSONs. Do not invent or normalise — match the JSON.

### 7. Resolve IRQ-affinity sentence per finding 1b

If finding 1b confirms the runner steers IRQ affinity: leave the sentence, but tighten it to name the specific script that does the steering (e.g. _"the per-demo wrapper script steers IRQ affinity…"_).

If finding 1b returns nothing: remove the sentence entirely. An aspirational methodology claim is worse than not addressing the topic.

### 8. Cosmetic fixes

**"ISASSE4.2"** in the reference-machine table — there's no separator between the "ISA" label and the value. Other rows in the same table render the label / value pair with proper spacing. Inspect the table-row template (probably a JSX component or a styled label/value pair) and fix the ISA row to match.

**"- –" double-dash in best-practice list** — each bullet appears to render with a stray en-dash before the text content. Likely an MDX/Markdown source issue: the list source may have items starting with "– Inputs…" inside a `<ul>` (so the markup yields a bullet _plus_ a leading en-dash in the text). Inspect the source for that list and remove the leading en-dash from each item — standard `<li>` markup alone should suffice.

## Acceptance criteria

- `/methodology` mentions the dual GRUB entry (entry name appears, or at minimum the dual-entry concept is named explicitly).
- `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` appears at most twice on the rendered page.
- Reference-machine CPU line creates no implication that 16 logical threads are in use during benchmarks.
- Repetition-count claim matches the minimum value observed across the four shipped JSONs; "outer repetitions" or equivalent disambiguation present.
- Page's reference to the isolated-cores JSON field matches whatever name the JSONs actually use across all four demos.
- IRQ-affinity sentence either has a verified runner-script source named, or is removed.
- "ISASSE4.2" reads as "ISA · SSE4.2" (or equivalent — match the separator style of the other table rows).
- Best-practice bullets render without a stray en-dash prefix on each item.
- `cpupower frequency-info` remains as the turbo-verification mechanism (don't regress this).
- No `cset` references appear anywhere on the page (don't regress this either).
- `npm run build` succeeds; `/methodology` renders without console errors.

## Out of scope

- Scripts, schema, JSON contents. If finding 1 surfaces inconsistencies, flag back rather than fixing them here.
- README. Task 4 in `pre-demo-5-review-tasks.md` covers it.
- Any demo post content. Existing cross-references to `/methodology` from demo posts stay as-is.
- The statistical-convention list itself (median / min / p99 / p99.9 / IQR) — the list is correct as it stands; clarification of "repetitions" wording in item 5 is the only stat-related change.
- The site header / nav / footer.

## Open questions for CC to flag during implementation

- If the four JSONs disagree on the isolated-cores field name (finding 1a), pause — schema consistency comes before this brief.
- If any shipped JSON's repetition count is below 11, flag loudly — methodology violation, not a doc fix.
- If the runner script does not actually abort on missing `/sys/devices/system/cpu/isolated == 0-7`, flag — that's a missing guard from `02-false-sharing-remediation-brief_1.md` task 3, separate from this brief but worth surfacing now.
- If the IRQ-affinity steering is partially present (some scripts, not others), describe the actual state in the PR description rather than guessing at page wording.
