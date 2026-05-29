# Crucible — Demo 07: No crossover

Implementation brief for Claude Code. Builds the demo 7 bench harness, captures its data, and prepares the site-side charts. Lands on the `demo-07` feature branch (assumed extant — see Open item 1). Replaces nothing on `main`; the teaser stub at `site/src/posts/07-flatmap-vs-hashmap.mdx` is unaffected until the §7 MDX task in `demo-07-plan_1.md` lands separately.

## Context

Demo 7's original thesis was "most maps in your code are too small for the hash map to win." Two calibration pilots in `bench/pilots/07-flatmap-vs-hashmap-stage1/` and `bench/pilots/07-flatmap-vs-hashmap-stage2/` killed that thesis. The reframed headline is **"there is no crossover; use `absl::flat_hash_map`; the standard library's hash map costs you 3–5× and you didn't have to live with that."**

Stage 0 resolved: `std::flat_map` is not available in the project's toolchain. `boost::container::flat_map` is the substitute, called out in the post's prose.

Stage 1 findings: across N ∈ [8, 10⁶], `absl::flat_hash_map` wins lookup-only at every N. The `vec+lb` and `boost::container::flat_map` lines are within run-to-run noise of each other — collapse to one "sorted array" line on chart 1. `std::map` keeps its own line because it tracks separately at high N.

Stage 2 findings: across N ∈ {256, 4096, 65536} and modify-mix ∈ {0, 10, 25, 50, 75, 90}%, hash maps stay roughly flat (absl: 3.8–50.7 ns; std::unord: 26.2–140.3 ns) while sorted arrays collapse catastrophically at scale (boost::flat at N=65536, 90% modify: 21610 ns). `std::map` holds up far better than the sorted arrays under modification because tree insert beats bulk memmove.

Predecessors:

- `BRIEF.md` — tech stack, methodology commitments, reference machine.
- `crucible-handover.md` — directory layout, demo-cycle conventions.
- `demo-07-plan_1.md` — the demo 7 task plan; this brief implements §3, §4, and the CC-applicable parts of §5.
- `06-aos-vs-soa-brief.md` — the format precedent this brief follows.
- `demo-07-stage1-pilot-brief.md`, `demo-07-stage2-pilot-brief.md` — the pilot briefs whose output this brief turns into a real harness.
- `bench/pilots/07-flatmap-vs-hashmap-stage{1,2}/result.txt` (if committed to the feature branch — Open item 2) — the actual pilot data this harness must reproduce.

`sudo cset shield --reset` is a precondition of every capture session on this machine. Named in the capture-session checklist below; expected to be hoisted to `BRIEF.md`'s global precondition list separately (per `demo-07-plan_1.md`).

## Story angle

**Thesis (one paragraph).** Most C++ code reaches for `std::unordered_map` when it wants a hash map and `std::map` when it wants order. Both choices are worse than they need to be. `absl::flat_hash_map` beats `std::unordered_map` by 3–5× at every N and every workload mix we tested; sorted containers lose decisively from N≈64 upward and collapse catastrophically under modification at scale. There is no crossover where sorted containers come back — not at small N, not at low modify mix, not at any combination we measured. The relevant question is not "ordered vs unordered" or "small vs large" but "is there a reason not to use abseil here?"

**What the post does NOT claim.**

- Does **not** claim `std::unordered_map` is bad in absolute terms — only that it's a 3–5× regression against a freely available alternative.
- Does **not** compare against other open hash maps (robin_hood, tsl, F14, ankerl::unordered_dense). A future post might.
- Does **not** address ordered iteration. `std::map` keeps the ability to iterate in key order; if you need that, you need it. This post is about lookup-mix workloads.
- Does **not** address insertion of pre-sorted data. The pilot used random keys; the post says so.
- Does **not** claim the result generalises to all hash functions. `absl::Hash<uint64_t>` is pinned for both `std::unordered_map` and `absl::flat_hash_map`; the comparison is container, not hash.
- Does **not** address pathological workloads (adversarial keys, very large values).

## Workload

Two workloads, both feeding into one JSON output. Same five implementations across both.

**Implementations (five):**

1. `std::map<uint64_t, uint64_t>` — variant id `std_map`.
2. `std::vector<std::pair<uint64_t, uint64_t>>` + `std::lower_bound` — variant id `sorted_vec`.
3. `boost::container::flat_map<uint64_t, uint64_t>` — variant id `boost_flat`.
4. `std::unordered_map<uint64_t, uint64_t, absl::Hash<uint64_t>>` — variant id `std_unord`.
5. `absl::flat_hash_map<uint64_t, uint64_t>` (with default `absl::Hash`) — variant id `absl_flat`.

**Workload A — lookup-only (feeds chart 1).** Pre-populate the map with N random `uint64_t` keys. Time `find()` operations on a precomputed lookup sequence (100% hit rate, 4096-entry mod-indexed cycle). N sweep: `{8, 16, 32, 64, 128, 256, 512, 1024, 4096, 16384, 65536, 262144, 1048576, 4194304}`.

**Workload B — modify-mix (feeds chart 3).** Steady-state, fixed-size map. Each op is either `find()` or `erase()`+`insert()` (a "modify"). `modify_pct` is the fraction of ops that modify. Sweep: `modify_pct ∈ {0, 10, 25, 50, 75, 90}` at `N ∈ {256, 4096, 65536}`. **Note the terminology shift** — the pilot called this `insert_pct`; the formal harness and JSON call it `modify_pct` because erase+insert is what's actually measured. The post will explain this in one sentence.

**Key generation.** `std::mt19937_64(seed=42)` for the populated keys, with rejection on a `std::unordered_set` to guarantee distinctness. `std::mt19937_64(seed=1337)` for the op sequence. Reproducible across runs and across implementations.

**Statistic.** Median of ≥5 outer repetitions per cell. Report median + IQR per the project's standing convention. **Do not** carry over the pilot's single-run discipline — pilot data showed visible noise (cf. `std::map` at N=65536, 75% → 90% modify going 900 → 540 ns in the Stage 2 output, which is run-to-run jitter, not a real curve).

## Schema

Add to `site/src/data/perf/07-no-crossover.json`. Follow the post-patch machine block (per `pre-demo-5-json-audit-findings.md` / `references/required-fields.md`): `turbo`, `governor`, `isolated_cpus`, `captured_at`, plus the patched sub-fields (`isolated_cpus_requested`, `_effective`, `_source`, `cpu_affinity`, `lscpu_extended`).

Per-run fields in `runs[]`:

- `variant` — one of the five variant ids above.
- `n` — integer, the map size.
- `workload` — `"lookup"` or `"modify_mix"`.
- `modify_pct` — integer in `[0, 90]`. Always present; `0` for `workload="lookup"`.
- `ns_per_op.stats` — `{median, iqr_lo, iqr_hi, min, max, n_reps}`. Same shape demos 1–6 use.
- `compile_flags` — per-variant compile flags string (machine block has no `compiler_flags`).
- `notes` — optional free-form string.

Row counts: workload A produces `14 N × 5 variants = 70` runs. Workload B produces `3 N × 6 modify_pct × 5 variants = 90` runs. Some overlap at `(N ∈ {256, 4096, 65536}, modify_pct=0)` — keep both rows, distinguished by `workload`. Chart 1 filters on `workload=="lookup"`; chart 3 filters on `workload=="modify_mix"`.

## Tasks

### 1. Create `bench/demos/07-no-crossover/`

Mirror demo 6's directory layout. Files:

- `bench/demos/07-no-crossover/CMakeLists.txt`
- `bench/demos/07-no-crossover/benchmark.cpp`
- `bench/demos/07-no-crossover/README.md` — one paragraph, points to the post and the pilot directories.

Link the same Boost and absl targets the pilots use. C++20. Standard project flags. `target_link_libraries` includes `bench_common` for the machine-block code per the existing demo pattern.

### 2. Write `benchmark.cpp`

Use Google Benchmark, matching demos 1–6. Five `BENCHMARK_REGISTER_F`-style entries (or a templated registration, your call — match whatever idiom demos 4 and 6 use). Argument vector covers the lookup-only sweep and the modify-mix sweep; distinguish via either a separate benchmark function pair (`BM_Lookup<Variant>` / `BM_ModifyMix<Variant>`) or a workload-tag argument.

**Key reproduction discipline.** The pilot's key generation logic (mt19937_64 seeds 42 and 1337, distinctness via unordered_set) must be reused verbatim — the formal harness's `(workload="lookup", n=N, modify_pct=0)` cells should match the pilot's Stage 1 output for the same N to within ≥1 sigma of the pilot's run-to-run noise band. If they don't, see Open item 5.

**XOR accumulator pattern.** Use `total ^= find_one(m, k);` as in the pilot, with `volatile Val sink = total; (void)sink;` after the loop. `+=` works too but the pilot's spot-check used `^=`, so match.

**Modify-mix workload semantics.** Steady-state fixed-size, per the Stage 2 brief: pre-populate to N from `keys[0..N-1]`; insertion pool is `keys[N..2N-1]`; on modify, erase a random live key and insert from the pool (or from a free-list of recently-erased keys when the pool exhausts). Bookkeeping arrays precomputed outside the timed region.

**Per-variant compile flags.** All five variants compile with `-O3 -march=native -DNDEBUG`. Record this in each run's `compile_flags`. No per-variant divergence expected; do not invent per-variant flag differences.

### 3. JSON emission and `bench/scripts/assemble_results.py`

The bench writes one Google Benchmark JSON file per run-cell-rep into the per-demo output directory; the assembly script aggregates into `site/src/data/perf/07-no-crossover.json`.

Check whether `bench/scripts/assemble_results.py` is the right entrypoint or whether demo 7 needs a `assemble_results_07.py` sibling (per the M10 finding in `pre-demo-5-bench-code-review-findings.md`, the demo 03 assembly was split). If demo 7's two-workload structure doesn't fit the generic assembler, create `assemble_results_07.py` and follow the demo 03 precedent — **do not** modify the generic `assemble_results.py` in ways that affect demos 1–6's JSON regeneration.

Verify the output validates against the locked schema by regenerating against the post-patch machine block.

### 4. `bench/scripts/run_one.sh 07-no-crossover` orchestration

Add a `07-no-crossover` case to `run_one.sh`. The capture command runs the bench binary under `sudo cset shield --exec` (per the project precondition), passes through `CRUCIBLE_TURBO=off`, sets `--benchmark_repetitions=5` (or whatever the demos-1–6 convention is — match it), captures stdout, strips `cset:` lines per the established sanitisation, sanitises control characters per the harness fix recorded in `userMemories`, and invokes the assembler.

Do not add a new pre-flight check that's specific to demo 7 unless one is genuinely needed. The existing SMT / governor / isolated-cpu checks (per `pre-demo-5-02-bench-preflight-checks-brief.md`) cover the bases.

### 5. Preflight calibration step

Add a `bench/demos/07-no-crossover/calibrate.sh` (or extend the run_one.sh `07-no-crossover` case with a `--calibrate` flag, matching demo 6's pattern). The calibration runs a fast, reduced-rep version of the workload (1 rep, N values restricted to `{256, 4096, 65536}`, modify_pct values restricted to `{0, 50, 90}`) and prints a short table to stdout.

Compare against the committed pilot output (Open item 2). If `absl::flat` at `(N=4096, modify_pct=0, lookup)` is outside `[3.0, 5.0]` ns, or `std::unord` at the same cell is outside `[20.0, 35.0]` ns, **stop and report**. This is the §4 calibration of the demo 7 plan.

### 6. Site-side: chart component verification

Read `site/src/components/charts/TimeVsN.tsx`. Verify:

- It accepts an `xAxis` prop and handles `xAxis="n"` (used by demos 1, 6) and `xAxis="modify_pct"` (new for demo 7). Demo 6 already shipped `xAxis="k"` per the plan; the demo 7 axis is `modify_pct`. If `TimeVsN` only switches on a hardcoded list, extend it minimally — propose the extension as a one-line change and apply.
- It accepts cache-tier band markers (added in demo 6) and these render only when explicitly requested. Chart 1 uses them; chart 3 does not.

**Do not** fork a `<MapCrossover>` or any other new chart component. Extend `TimeVsN` if needed; that's the demo 7 plan's stated intent.

`<ThroughputBars>` is used unchanged for chart 2 (three calls with different N filters). Verify the existing component handles the demo 7 JSON shape; if it filters by `variants` and `n` only, demo 7's `workload` field needs to be added to the filter or the JSON pre-filtered at load.

### 7. Cross-reference open-item resolutions from `demo-07-plan_1.md`

For the brief author's benefit, the open items the pilots resolved (these don't need CC action — listed here so the brief is self-contained):

- N upper bound: 4194304 attempted in Stage 1; the largest-N row was sometimes skipped. Keep 4194304 in the lookup-only sweep; the JSON will carry a `--`-equivalent (omitted row) where the cell exceeds budget.
- `std::map` on chart 1: yes, its own line. Stage 1 showed it tracking the sorted-array trio at small N but diverging at large N.
- Workload-mix split for chart 3: covered by Workload B above.
- Key distribution: random, documented.
- `std::flat_map` vs `boost::flat_map`: boost, documented.
- Primitive (`vec+lb`) vs library (`boost::flat`) line collapse: collapse to one "sorted array" line on chart 1; **but** the JSON keeps both `sorted_vec` and `boost_flat` variants — collapse happens at chart-render time, not at capture time. This preserves the data should a future post want to surface the boost vs vec gap.

## Acceptance

### Bench

- `bench/demos/07-no-crossover/` exists with `CMakeLists.txt`, `benchmark.cpp`, `README.md`.
- `cmake --build build --target bench_07-no-crossover` succeeds, no warnings under the project's standard warning set.
- The binary registers exactly 5 variants × 2 workloads = 10 benchmark families (or a single family with variant + workload args, depending on idiom).
- `bench/scripts/run_one.sh 07-no-crossover` runs end-to-end on a development machine with reduced reps (set `CRUCIBLE_REPS=2` or the equivalent existing knob) and produces a valid JSON output under `site/src/data/perf/07-no-crossover.json` (or a staging path; **do not** commit headline data from a dev machine).

### Schema

- `site/src/data/perf/07-no-crossover.json` validates against the locked schema. `jq '.machine'` shows all post-patch fields per `references/required-fields.md`.
- `jq '.runs | length'` is ≥ 70 + 90 = 160 (allowing for `--` skip rows being omitted, not zero-filled).
- Every run has `workload`, `n`, `modify_pct`, `variant`, `ns_per_op.stats` populated.
- `jq '.runs | map(.workload) | unique'` returns `["lookup", "modify_mix"]`.
- `jq '.runs | map(.variant) | unique'` returns the five variant ids in some order.

### Preflight calibration

- `bench/demos/07-no-crossover/calibrate.sh` (or `run_one.sh 07-no-crossover --calibrate`) exits 0 on the reference machine with output within the named bounds.
- The calibration's `absl::flat, N=4096, modify_pct=0, workload=lookup` cell matches the pilot to ≥1σ of the pilot's run-to-run noise band.

### Site

- `TimeVsN` accepts `xAxis="modify_pct"` without error when given a `workload="modify_mix"` JSON slice.
- `npm run build` under `site/` succeeds with the new JSON file present (chart components don't need an MDX consumer yet — the MDX task is §7 of the demo 7 plan and lives in a separate brief).
- No site-side changes outside `site/src/components/charts/TimeVsN.tsx` (if extended) and `site/src/data/perf/07-no-crossover.json` (if a dev-stage capture is committed; otherwise no site-side data change).

### Cross-cutting

- No edits to `bench/demos/01-...` through `bench/demos/06-...`.
- No edits to `bench/common/` beyond what's strictly needed for demo 7 to link. If a common helper would be useful but is not strictly needed, surface it in a follow-up brief — do not add it under this brief.
- No edits to `bench/pilots/07-flatmap-vs-hashmap-stage{1,2}/`.
- No edits to `site/src/posts/`. The MDX task is separate.
- No edits to `site/src/app/methodology/`. Methodology page review is the §7 / §9 Opus tasks.
- `bench/scripts/assemble_results.py` is either unchanged, or, if a demo-7-specific assembler is needed, the new script (`assemble_results_07.py`) is added without touching the generic one.

## Out of scope

- **§6 headline capture.** The user runs this on the reference machine under headless boot with `sudo cset shield --reset`, `CRUCIBLE_TURBO=off`, ≥5 outer reps. Output to `site/src/data/perf/07-no-crossover.json` is committed by the user.
- **§7 MDX.** Replacing the teaser stub, writing the post, cross-links to demos 1 and 6 — separate brief, Opus draft + CC apply.
- **§8 hostile cross-read.** Opus task.
- **§9 pre-merge review.** Opus task.
- **§10 merge to main.** User task.
- **§11 post-ship verification.** User task.
- **Methodology page updates.** Reviewed during §7. Not touched here.
- **Index page update.** Demo 7's card already exists on the index (the teaser shipped to main in §0). The "In Progress" pill removal is part of §7's MDX work, not this brief.
- **Robin-hood / F14 / ankerl / tsl comparisons.** Future post candidate, named explicitly in the demo 8 candidate list in `demo-07-plan_1.md`'s Stop condition.
- **Pure-insert (modify_pct=100) workload.** Out of scope per the pilot — different semantics, no lookups to XOR-accumulate.
- **Insertion of pre-sorted data.** Random keys throughout.
- **Custom hash functions other than `absl::Hash`.** Pinned.
- **Refactoring or DRYing pilot code.** The pilots remain throwaway and untouched. Their existence on the feature branch (Open item 2) is for evidence, not for inheritance.

## Open items for CC to flag

1. **If the `demo-07` feature branch doesn't exist yet,** stop and report. This brief assumes the branch exists with the teaser stub from §0 of `demo-07-plan_1.md` already on it (or at minimum that `main` has the teaser, which the branch was forked from). Don't create the branch unprompted — branch creation is a user action.

2. **If `bench/pilots/07-flatmap-vs-hashmap-stage{1,2}/` are not present on the feature branch** (i.e. the user hasn't yet committed them per the previous turn's recommendation), the calibration step (task 5) cannot compare against pilot output. **Stop and report** — the user-side commit of the pilot output is a precondition.

3. **`absl::Hash<std::uint64_t>` for `std::unordered_map`.** The pilots used `std::unordered_map<Key, Val, absl::Hash<Key>>`. Verify this still compiles cleanly with the toolchain at demo 7 capture time. If a future toolchain rejects it, fall back to `std::hash<std::uint64_t>` for `std::unordered_map` only — and flag the substitution in the JSON's `notes` field and surface it for the §7 MDX. **Do not silently change the hash function** — the comparison fairness depends on both unordered candidates using the same hash.

4. **Boost component linkage.** `boost::container::flat_map` may be header-only on the reference machine's distribution. If `find_package(Boost COMPONENTS container)` fails when run from `bench/demos/07-no-crossover/CMakeLists.txt` (even though the pilot succeeded), follow the pilot's resolution exactly — don't fight the distribution.

5. **If the calibration step's lookup-only cells don't match the pilot output to ≥1σ,** the harness has drifted from the pilot. Most likely cause: DCE leak in the timed loop (the `volatile sink` line is load-bearing), the XOR accumulator was changed to `+=` and the compiler is doing something clever, or key-generation seeds drifted. **Stop and report** rather than iterate silently.

6. **If the `std::map` row at `N=65536, modify_pct ∈ {75, 90}` shows non-monotonic curve** (as the pilot did: 900 → 540 ns), that's run-to-run noise — ≥5 outer reps should smooth it. If non-monotonicity persists at ≥5 reps, something else is happening; flag it. Don't smooth artificially.

7. **`<TimeVsN>` extension.** If the component already handles arbitrary `xAxis` strings, no extension needed — verify and move on. If it switches on a hardcoded list, propose the extension as a small diff and apply. **Do not** introduce a new chart component for the modify-mix view.

8. **Per-variant compile_flags.** The brief says all five variants use `-O3 -march=native -DNDEBUG`. If the project's existing CMake adds further flags via a shared `target_compile_options(bench_common ...)` block, those propagate and the per-variant string should include them. Match the established demos-1–6 convention exactly — don't guess.

## Notes for CC

Expected work: 1–2 days. The bench code is conceptually small (the pilots covered most of the design); the time goes into Google Benchmark wiring, JSON assembly, and the calibration script.

If a task's path feels longer than its expected effort, stop and report — the brief was probably under-specified for that step.
