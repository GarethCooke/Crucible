# Crucible — Demo 07 §1 Stage 2 pilot bench (insert-mix sensitivity)

Implementation brief for Claude Code. Second of two throwaway pilots under `demo-07-plan_1.md` §1. Sibling of `demo-07-stage1-pilot-brief.md`. Lives under `bench/pilots/07-flatmap-vs-hashmap-stage2/` — separate from Stage 1, intentionally not sharing code. Produces stdout output only.

## Context

Stage 1 ran. The data on three back-to-back runs is consistent:

- `absl::flat_hash_map` wins at every N from 8 to ~10⁶, sitting at 3–9 ns.
- `std::unordered_map` is a distant but stable second at 14–21 ns across the same range.
- The three sorted containers (`std::map`, `std::vector<pair>+lower_bound`, `boost::container::flat_map`) grow logarithmically and lose decisively from N≈64 upward.
- The `vec+lb` and `boost::flat` lines are within run-to-run noise of each other; the open item about collapsing them is resolved (collapse to one line on chart 1).

The original demo 7 thesis — "small maps stay sorted" — is dead. The new working thesis is **"the crossover doesn't exist; use `absl::flat_hash_map`, and notice that the standard one costs 5×."**

Stage 2 now asks a different question than the original §1 scope envisioned. With the lookup-only ranking settled, the new questions are:

1. Does insert cost narrow the `absl::flat` ↔ `std::unordered_map` gap at any reasonable mix? (If `std::unord` is meaningfully cheaper to mutate, the constant-factor story has nuance.)
2. Does insert cost let any sorted container catch up to either hash map at any N? (Default expectation: no, because sorted-array insert is O(N) memmove and tree insert is O(log N) with allocator overhead. Sanity check.)
3. Where does `boost::flat_map`'s O(N) shift on insert start to dominate its O(log N) lookup advantage over `std::map`? (Side observation for the post; not headline.)

Stage 0 is resolved: `boost::container::flat_map` is the substitute for `std::flat_map`. Dependencies are already wired up (Stage 1 established this).

Predecessors:

- `demo-07-stage1-pilot-brief.md` — directory layout, dependency assumptions, output style conventions.
- `demo-07-plan_1.md` §1 — pilot rationale, reframe conditions.

No branch expectation. Output is stdout; the directory is deletable wholesale once the `07-...-brief.md` (§2 of the demo 7 plan) lands.

## Location and shape

New directory `bench/pilots/07-flatmap-vs-hashmap-stage2/`, sibling to the Stage 1 pilot directory. **Do not** consolidate the two into a shared common/ subdirectory or extract shared headers — pilot code is throwaway and the duplication has a shelf life of about a week. Acceptance enforces this.

Files:

- `bench/pilots/07-flatmap-vs-hashmap-stage2/stage2.cpp` — the bench.
- `bench/pilots/07-flatmap-vs-hashmap-stage2/CMakeLists.txt` — minimal target, modelled on Stage 1's.
- `bench/pilots/07-flatmap-vs-hashmap-stage2/README.md` — one paragraph: throwaway, scope brief reference, delete-after note.

Wire into `bench/CMakeLists.txt` under the existing `CRUCIBLE_BUILD_PILOTS` option Stage 1 introduced (or whatever pattern Stage 1 actually landed on — match it):

```cmake
if(CRUCIBLE_BUILD_PILOTS)
  add_subdirectory(pilots/07-flatmap-vs-hashmap-stage1)
  add_subdirectory(pilots/07-flatmap-vs-hashmap-stage2)   # new
endif()
```

## Workload

**Steady-state, fixed-size map.** This is the key design choice — it keeps N as a clean independent variable across the insert_pct sweep. Each modifying op is an erase+insert pair, so the map size stays at N regardless of insert_pct.

The terminology will need clarifying when the post is written: `insert_pct` here is really "the fraction of ops that mutate the structure." That's a §2-brief / MDX decision; the pilot output uses `insert_pct` per the original scope.

### Op sequence (precomputed, outside the timed region)

1. `std::mt19937_64 key_rng(42);` — generate `2*N` distinct `uint64_t` keys via rejection on `std::unordered_set`. First `N` keys form the initial population; remaining `N` keys form an insertion pool.
2. `std::mt19937_64 op_rng(1337);` — used only for permuting the FIND/MODIFY assignment and choosing which live key each op touches. Separate seed so it's reproducible across implementations.
3. Build `std::vector<Op> ops` of size `ITERATIONS`. Each `Op` has:
   - `Kind kind;` — `FIND` or `MODIFY`.
   - `Key target;` — the key to find, or for MODIFY, the key to erase.
   - `Key replacement;` — for MODIFY, the new key to insert. Unused for FIND.
4. Assign exactly `floor(ITERATIONS * insert_pct / 100)` ops as MODIFY and the rest as FIND. Shuffle the assignment vector deterministically with `op_rng` so the pattern is interleaved, not bunched.
5. Walk the assignment vector. Maintain a `std::vector<Key> live` (initialised to the first `N` keys). For each op:
   - **FIND:** pick `idx = op_rng() % live.size()`. Record `target = live[idx]`.
   - **MODIFY:** pick `idx = op_rng() % live.size()`. Record `target = live[idx]`. Take the next unused key from the insertion pool as `replacement`. Update `live[idx] = replacement` for the next iteration's bookkeeping. (When the pool runs out, recycle erased keys back into a free list.)

The pool-recycling case will trigger for any insert_pct > 0 once `ITERATIONS > N` — which is always. A simple free-list (`std::vector<Key> freed;`) holding keys that have been erased works: prefer a fresh pool key when the pool has any left, otherwise pop from `freed`.

### Timed loop

```cpp
Val total = 0;
const auto t0 = std::chrono::steady_clock::now();
for (std::size_t i = 0; i < ITERATIONS; ++i) {
    const Op& o = ops[i];
    if (o.kind == FIND) {
        total ^= find_one(m, o.target);
    } else {
        erase_one(m, o.target);
        insert_one(m, o.replacement, o.replacement ^ 0xDEADBEEFULL);
    }
}
const auto t1 = std::chrono::steady_clock::now();
volatile Val sink = total;
(void)sink;
```

Use `^=` (Stage 1's run-3 spot-check confirmed this defeats DCE without changing the underlying timings). The `if/else` branch is the same across all five implementations, so it's a fair confound.

### Per-implementation interface

```cpp
// FIND: returns Val, used in XOR accumulator.
Val find_one(const M&, Key);

// MODIFY components:
void erase_one(M&, Key);
void insert_one(M&, Key, Val);
```

For `std::vector<pair>+lower_bound`, implement these explicitly:

```cpp
Val find_one(const M_sorted_vec& v, Key k) {
    auto it = std::lower_bound(v.begin(), v.end(), k,
        [](const auto& p, Key kk) { return p.first < kk; });
    return it->second;   // hit guaranteed by workload
}

void erase_one(M_sorted_vec& v, Key k) {
    auto it = std::lower_bound(v.begin(), v.end(), k,
        [](const auto& p, Key kk) { return p.first < kk; });
    v.erase(it);  // hit guaranteed
}

void insert_one(M_sorted_vec& v, Key k, Val val) {
    auto it = std::lower_bound(v.begin(), v.end(), k,
        [](const auto& p, Key kk) { return p.first < kk; });
    v.insert(it, {k, val});  // new key guaranteed
}
```

The other four containers use their standard APIs (`find`, `erase`, `insert` or `emplace`).

### Sweep parameters

```cpp
constexpr std::array<int, 3> N_VALUES = { 256, 4096, 65536 };
constexpr std::array<int, 6> INSERT_PCTS = { 0, 10, 25, 50, 75, 90 };
```

`N=256` — comfortably in L1, all containers near their best case, cleanest constant-factor read.
`N=4096` — mid-range, cache-tier transition territory.
`N=65536` — large, where `boost::flat`'s O(N) shifts on insert start to bite hard.

`insert_pct=0` is the baseline (degenerate Stage 1 cross-check at three Ns).
`insert_pct ∈ {10, 25, 50, 75, 90}` traces the curve. Stop at 90 — at 100% there are no lookups, which is a different workload entirely.

### Iteration tiers

Modifying ops are 5–100× more expensive than lookups, so iteration counts come down accordingly:

```cpp
std::size_t iters_for(int N) {
    if (N <= 256)   return 2'000'000;
    if (N <= 4096)  return 500'000;
    return 100'000;  // 65536
}
```

Same skip rule as Stage 1: if a single cell's wall time exceeds 5 s, abort that cell, record `--`, continue. Expected casualty: `boost::flat` and `vec+lb` at `N=65536, insert_pct=90` may exceed budget. Acceptable.

## Tasks

### 1. `stage2.cpp`

Single translation unit. Same includes as Stage 1's `stage1.cpp` (Stage 1 already established the dependency surface). Implement the workload spec above. Print one table per N (three tables total).

### 2. `CMakeLists.txt`

Defines an executable `stage2_07` from `stage2.cpp`. Link the same Boost and absl targets Stage 1 linked. `target_compile_features(stage2_07 PRIVATE cxx_std_20)`. Match Stage 1's flag choices exactly — no LTO, no extra flags.

### 3. `README.md`

One paragraph. Throwaway, references this brief and `demo-07-plan_1.md` §1. Names Stage 1's directory as a sibling.

### 4. Output format

Three tables, one per N, separated by blank lines:

```
Stage 2: insert-mix sensitivity — ns_per_op (steady state, erase+insert on modify)
-------------------------------------------------------------------------------
N = 256
  insert_pct      std::map        vec+lb   boost::flat    std::unord    absl::flat
          0%         ...           ...           ...           ...           ...
         10%
         25%
         50%
         75%
         90%

N = 4096
  insert_pct      std::map        vec+lb   boost::flat    std::unord    absl::flat
          0%
         ...

N = 65536
  ...

-------------------------------------------------------------------------------
host=<hostname>  kernel=<uname -r>  gcc=<__VERSION__>  CRUCIBLE_TURBO=<env>  ts=<ISO8601>
```

Right-align numeric columns to one decimal place. `--` for skipped cells. Single provenance line at the end.

## Acceptance

### Build

- `cmake -S . -B build -DCRUCIBLE_BUILD_PILOTS=ON` succeeds.
- `cmake --build build --target stage2_07` succeeds, no warnings under the project's standard warning set.
- With `CRUCIBLE_BUILD_PILOTS=OFF` (default), no Stage 2 target is generated. Stage 1's target is also unaffected.

### Output

- `./build/bench/pilots/07-flatmap-vs-hashmap-stage2/stage2_07` runs in under 15 minutes on the reference machine.
- Stdout contains exactly three N-blocks (header + 6 data rows each), separated by blank lines, then one provenance line. No other output.
- Every numeric cell is a positive decimal, or `--` for cells that hit the 5 s skip.
- No file is written under `site/src/data/perf/` or anywhere outside the build directory.

### Source hygiene

- `stage2.cpp` is a single file, under 500 lines.
- **No header files added under `bench/common/`.** No `include/` directory created inside the pilot. The duplication with `stage1.cpp` (uniform interface, includes block) is intentional and not to be lifted.
- No edits to existing files under `bench/demos/`, `bench/scripts/`, or `bench/common/`.
- No edits to `stage1.cpp` or Stage 1's `CMakeLists.txt`.
- The only edit to `bench/CMakeLists.txt` is the addition of the second `add_subdirectory(pilots/07-flatmap-vs-hashmap-stage2)` line inside the existing `CRUCIBLE_BUILD_PILOTS` block.

## Out of scope

- **Statistical rigour.** Single-run, eyeball-level, same as Stage 1. The user will run the binary 2–3 times if a cell looks noisy.
- **Refactoring across the two pilots.** No shared headers, no extracted common code, no `bench/pilots/common/`. Both pilots get deleted together.
- **Pure-insert (`insert_pct=100`) workload.** Different semantics (no lookups means no XOR accumulator means a DCE concern revisits). Not in scope.
- **Growing-map workload** (pre-populate to N/2, let it grow). Considered and rejected: confounds N with insert_pct. The steady-state choice is deliberate.
- **Erase-only or insert-only timing breakdowns.** Use a profiler if a specific implementation's modify cost is mysterious; the pilot doesn't decompose it.
- **Perf counters.** Same as Stage 1.
- **`cset shield --exec` wrapping.** Same as Stage 1.
- **`bench/demos/07-flatmap-vs-hashmap/`** — the real harness. **Do not** create or touch under this brief.

## Open items for CC to flag

1. **If Stage 1's directory isn't there** (e.g. you're starting from a checkout that pre-dates Stage 1's merge): the dependency wiring, the `CRUCIBLE_BUILD_PILOTS` option, and the linkage targets may not exist yet. **Stop and report.** Stage 2 depends on Stage 1's CMake plumbing landing first.

2. **If `boost::container::flat_map::erase(iterator)` is unusually slow** (e.g. one implementation choice triggers a reallocation per call), the `N=65536, insert_pct ≥ 50` cells may exceed 5 s and skip. That's expected and informative — do not "fix" by reducing the iteration count for that implementation only. Asymmetric iter counts would silently invalidate the per-row comparison.

3. **If a cell at insert_pct=0 shows results materially different from Stage 1** at the matching N (say >30% deviation on the same implementation), something has drifted in the harness — most likely the op-sequence precompute is leaking into the timed loop, or the XOR accumulator isn't actually sinking. **Stop and report**, comparing the insert_pct=0 row against Stage 1's published numbers for that N.

4. **If you find yourself wanting to add a `--reps N` median-of-N flag** because the output is noisy: don't. Run the binary multiple times like Stage 1 did. The pilot stays single-run.

5. **If the live-set bookkeeping in the precompute is hot enough to be visible** at very high `insert_pct` (you can spot this by timing the precompute and comparing to the timed loop): note it in the stdout output and continue. Pilot fidelity tolerates a small precompute cost; the brief budget doesn't include re-engineering the precompute into something faster.

## Notes for CC

Half a day. The harness is one new file plus one CMake line. If it's taking longer, the workload spec was probably under-specified — stop and ask before guessing.
