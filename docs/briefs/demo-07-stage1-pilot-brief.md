# Crucible — Demo 07 §1 Stage 1 pilot bench

Implementation brief for Claude Code. Throwaway bench for the demo 7 calibration pilot's Stage 1 (lookup-only crossover sweep). Lives outside `bench/demos/`, produces stdout output only, never commits, never touches the site. Companion to the §1 scope established in chat (preceding message); precedes `07-flatmap-vs-hashmap-brief.md` (still to be written).

## Context

§1 of `demo-07-plan_1.md` calls for a calibration pilot. Stage 0 (verify `std::flat_map` availability) has been resolved out-of-band: `std::flat_map` is **not** available in the project's toolchain. The pilot, the §2 brief, and the downstream post will use `boost::container::flat_map` and call out the substitution in prose.

This brief implements **Stage 1 only** — five implementations, lookup-only sweep across N — and prints a `ns_per_op` table. Stage 2 (insert-mix sensitivity) is a separate, smaller brief that will follow once Stage 1's table is in hand and the headline N range is pinned.

This is a **pilot**: no JSON schema, no Google Benchmark, no perf counters, no commit-ready output, no `run_one.sh` orchestration. Single-run, eyeball-level. The point is to produce the Stage 1 table fast.

Predecessor / companion docs:

- `BRIEF.md` — tech stack (C++20, GCC 13+, CMake ≥3.20), reference machine.
- `crucible-handover.md` — directory layout and naming conventions.
- `demo-07-plan_1.md` §1 — pilot rationale, reframe conditions.

No branch expectation. The pilot can live on `main` or any throwaway branch; nothing it produces is committable to `site/`.

## Location and shape

Put everything under a new directory `bench/pilots/07-flatmap-vs-hashmap-stage1/`. This is a new sibling of `bench/demos/`, intentionally separate so:

- `bench/demos/` stays the authoritative home for shipped harnesses.
- Adding/removing files in `bench/pilots/` doesn't perturb existing CMake targets under `bench/demos/`.
- The whole pilot directory can be deleted wholesale once the §2 brief locks in.

Files:

- `bench/pilots/07-flatmap-vs-hashmap-stage1/stage1.cpp` — the bench itself.
- `bench/pilots/07-flatmap-vs-hashmap-stage1/CMakeLists.txt` — minimal target.
- `bench/pilots/07-flatmap-vs-hashmap-stage1/README.md` — single paragraph: "Throwaway. See `demo-07-plan_1.md` §1 and the Stage 1 scope brief. Delete after §2 brief is locked in."

Wire `bench/pilots/07-flatmap-vs-hashmap-stage1/` into the top-level `bench/CMakeLists.txt` via `add_subdirectory(...)` guarded by an option defaulted to `OFF`, so the pilot is opt-in and CI / normal demo builds are unaffected:

```cmake
option(CRUCIBLE_BUILD_PILOTS "Build throwaway pilot benches under bench/pilots/" OFF)
if(CRUCIBLE_BUILD_PILOTS)
  add_subdirectory(pilots/07-flatmap-vs-hashmap-stage1)
endif()
```

(If `bench/CMakeLists.txt` already has an established pattern for opt-in / experimental targets — see Open items — match it instead.)

## Tasks

### 1. `stage1.cpp` — the bench

Single translation unit. Includes:

- `<chrono>`, `<cstdint>`, `<cstdio>`, `<random>`, `<string>`, `<vector>`, `<utility>`, `<algorithm>`
- `<map>`, `<unordered_map>`
- `<boost/container/flat_map.hpp>`
- `<absl/container/flat_hash_map.h>`
- `<absl/hash/hash.h>`

Type aliases:

```cpp
using Key = std::uint64_t;
using Val = std::uint64_t;

using M_ordered    = std::map<Key, Val>;
using M_sorted_vec = std::vector<std::pair<Key, Val>>;
using M_flat       = boost::container::flat_map<Key, Val>;
using M_unordered  = std::unordered_map<Key, Val, absl::Hash<Key>>;
using M_absl       = absl::flat_hash_map<Key, Val, absl::Hash<Key>>;
```

Uniform interface per implementation: a `populate(M&, keys, vals)` overload and a `find_one(const M&, Key) -> Val` overload. For `M_sorted_vec`, `populate` reserves N, emplaces pairs, then sorts by `.first`; `find_one` does `std::lower_bound` on `.first` and returns the matched `.second` (the workload guarantees a hit, so the `it->first == k` branch is taken every time).

The sweep:

```cpp
constexpr std::array<int, 14> N_VALUES = {
    8, 16, 32, 64, 128, 256, 512,
    1024, 4096, 16384, 65536, 262144, 1048576, 4194304
};
```

For each `N` × each implementation, run `time_lookup<M>(N) -> double` (returning `ns_per_op`):

1. **Key generation.** `std::mt19937_64 rng(42);` Generate `N` distinct `Key`s. Use rejection on a `std::unordered_set` until N unique keys are collected — distinctness matters because duplicates would silently change the effective N.
2. **Value generation.** `vals[i] = keys[i] ^ 0xDEADBEEFULL;` — deterministic, cheap.
3. **Populate** the map (outside the timed region).
4. **Lookup sequence.** Build `std::array<int, 4096> lookup_idx;` filled with `std::mt19937_64(1337)() % N` — separate RNG so the sequence is reproducible across implementations.
5. **Iteration count:**

   ```cpp
   const std::size_t ITERATIONS = (N <= 1024) ? 10'000'000ULL
                                  : (N <= 65536) ? 1'000'000ULL
                                  : 100'000ULL;
   ```

   These targets each cell at roughly 0.1–2 s wall time on the reference machine. Adjust the breakpoints if a first run shows cells outside that band.

6. **Time the inner loop** with `std::chrono::steady_clock`:

   ```cpp
   Val total = 0;
   const auto t0 = std::chrono::steady_clock::now();
   for (std::size_t i = 0; i < ITERATIONS; ++i) {
       const Key k = keys[lookup_idx[i & 4095]];
       total += find_one(m, k);
   }
   const auto t1 = std::chrono::steady_clock::now();
   volatile Val sink = total;  // defeat DCE
   (void)sink;
   ```

7. **Return** `ns_per_op = (t1 - t0).count() (ns) / ITERATIONS`.

**Skip rule.** If a single cell's wall time exceeds 5 s, abort that cell, record `--`, and continue. Don't retry with reduced ITERATIONS — surfacing the cell as `--` is informative.

### 2. Output

Print to stdout a single fixed-width table. Approximate shape:

```
Stage 1: lookup-only crossover sweep — ns_per_op (100% hit rate, random keys)
-------------------------------------------------------------------------------
      N    std::map   vec+lb   boost::flat   std::unord   absl::flat
       8       12.4      8.1           9.2         18.7         11.9
      16        ...
      ...
 4194304        ...
-------------------------------------------------------------------------------
host=<hostname>  kernel=<uname -r>  gcc=<__VERSION__>  CRUCIBLE_TURBO=<env>  ts=<ISO8601>
```

Right-align numeric columns to one decimal place. `--` for skipped cells. The final provenance line is a single line; capture `CRUCIBLE_TURBO` from `getenv` (empty string if unset is fine).

### 3. `CMakeLists.txt`

`bench/pilots/07-flatmap-vs-hashmap-stage1/CMakeLists.txt`:

- Defines an executable `stage1_07` from `stage1.cpp` (the demo-prefixed name avoids any future collision with another `stage1`).
- Links Boost (`Boost::container` if that target exists in the project; otherwise header-only — see Open items) and absl (`absl::flat_hash_map`, `absl::hash`).
- `target_compile_features(stage1_07 PRIVATE cxx_std_20)`.
- Match the project's standard release flags (`-O3 -march=native` per `BRIEF.md`); do **not** enable LTO and do **not** add any flag not already used elsewhere in `bench/`.
- Does **not** install, does **not** register a test, does **not** add to any aggregate `all_demos` / `all_bench` target.

### 4. `README.md`

One paragraph. Explicit: "throwaway, expected lifetime ~1 week, delete after `07-flatmap-vs-hashmap-brief.md` is locked in." Names the parent documents (`demo-07-plan_1.md` §1, this brief).

## Acceptance

### Build

- `cmake -S . -B build -DCRUCIBLE_BUILD_PILOTS=ON` succeeds.
- `cmake --build build --target stage1_07` succeeds, no warnings under the project's standard warning set.
- With `CRUCIBLE_BUILD_PILOTS=OFF` (the default), no pilot target is generated and the existing demo targets still build identically.

### Output

- `./build/bench/pilots/07-flatmap-vs-hashmap-stage1/stage1_07` runs to completion in under 10 minutes on the reference machine.
- Stdout contains exactly one header block, one data row per N (14 rows), one provenance line. No other output.
- Every numeric cell is a positive decimal; otherwise `--`.
- No file is written under `site/src/data/perf/`.
- No file is written anywhere outside the build directory.

### Source hygiene

- `stage1.cpp` is a single file, under 400 lines.
- No header files added under `bench/common/`.
- No edits to existing files under `bench/demos/`, `bench/scripts/`, or `bench/common/`.
- The only edit to existing CMake is the `option(...)` + `add_subdirectory(...)` block in `bench/CMakeLists.txt` (or its equivalent under the existing opt-in pattern).

## Out of scope

- **JSON output.** Stage 1 produces a stdout table; nothing more.
- **Google Benchmark.** Single-loop `std::chrono` timing is sufficient at pilot fidelity.
- **Perf counters.** Demo 7's §4 preflight may add cache-miss counters; not here.
- **Statistical rigour** — no IQR, no p99, no confidence intervals. Single-run, eyeball-level.
- **Stage 2 (insert-mix sensitivity).** Separate brief, written once Stage 1's table is in hand.
- **`cset shield --exec` wrapping.** Pilot doesn't require core isolation; if Stage 1's first run shows unstable orderings, that question gets a separate decision (and a re-run under `cset shield --exec`), not a harness edit here.
- **`run_one.sh` or any orchestrating shell.** Invoke `./build/.../stage1_07` directly.
- **`bench/demos/07-flatmap-vs-hashmap/`** — that directory belongs to §3 of the demo 7 plan (the real harness). **Do not** create it under this brief, even speculatively.
- **`site/`, methodology page, MDX, index page.** Untouched.
- **Headless boot requirements.** Pilot tolerates a graphical session; the §6 headline capture will lock down boot environment.

## Open items for CC to flag

1. **Are `boost::container` and `absl::flat_hash_map` already available in the project's CMake configuration?** Grep `bench/CMakeLists.txt` and any `bench/cmake/`-equivalent for `find_package(Boost...)`, `FetchContent_Declare(absl...)`, or existing `Boost::...` / `absl::...` targets. If **both** are already wired up, link against the existing targets. If **either** is missing, **stop and report** with one paragraph naming the missing dependency, what's already present, and a suggested `find_package` or `FetchContent` snippet. Do not install system packages, vendor sources, or modify the top-level CMake to add a new external dependency without surfacing it first — that decision belongs to the user.

2. **Existing opt-in / experimental-target pattern.** If `bench/CMakeLists.txt` already has an option for samples / experiments / scratch targets, match it (name, default, gating idiom) instead of introducing `CRUCIBLE_BUILD_PILOTS`. The pattern matters more than the name. If no pattern exists, the name proposed above is fine.

3. **`Boost::container` linkage variant.** `boost::container::flat_map` is compiled-library on some distributions, header-only on others. If `find_package(Boost COMPONENTS container)` fails on the reference machine, fall back to header-only inclusion via `Boost::headers` (or whatever the project's header-only target name is) and adjust the link line. Don't fight the distribution.

4. **If `absl::Hash<std::uint64_t>` doesn't compile cleanly** (unusual but possible on very old absl), fall back to `std::hash<std::uint64_t>` for `M_unordered` and absl's default hash for `M_absl`. **Flag the substitution explicitly in the stdout provenance line** — the brief assumes both use `absl::Hash` for parity.

5. **If the largest N (4194304) pushes a single cell past 5 s on first run,** drop the largest N entry from `N_VALUES` rather than further reducing `ITERATIONS`. The high-N rows exist to show all lines flattening; one missing row doesn't compromise the eyeball read.

6. **If a first quick run looks suspicious** (e.g. `std::map` faster than `absl::flat_hash_map` at every N, or all five columns within 5% of each other at every N), **stop and surface the output**. Most likely cause is DCE eliding the lookup; the `volatile Val sink = total;` line is load-bearing. Don't iterate on the harness silently.

## Notes for CC

Time budget: half a day, including a first run on the reference machine. The harness is intentionally simple — if it's taking longer, something has drifted from the brief.
