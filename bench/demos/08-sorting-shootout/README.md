# Demo 08 — Sorting Shootout

`std::sort` vs `pdqsort` vs hand-rolled LSD radix on `u32` and `u64` keys.

## Variants

| Variant | Description |
|---|---|
| `std_sort` | `std::sort(begin, end)` — libstdc++ introsort. The default. |
| `pdqsort` | Orson Peters' pattern-defeating quicksort (vendored header, zlib licence). |
| `radix_lsd` | Hand-rolled LSD radix, 8 bits per pass, `sizeof(T)` passes. |

`pdqsort.h` is vendored from <https://github.com/orlp/pdqsort> (zlib licence, permissive; compatible with the repo's MIT licence). Licence text is preserved in the header.

## Input distributions

| Distribution | Description | Seed |
|---|---|---|
| `random` | Uniform over full key range | `MASTER_SEED_U32 = 0xC0FFEE42` (u32), `MASTER_SEED_U64 = 0xDEADBEEF1234` (u64) |
| `sorted` | `0, 1, …, n-1` | same seed (RNG not used) |
| `reverse` | `n-1, …, 1, 0` | same seed (RNG not used) |
| `few_unique` | Uniform over `[0, 99]` | same seed |
| `sawtooth` | `i % (n/8)`, eight repeating ramps | same seed (RNG not used) |

## Benchmark sets

- **Set A** — N-sweep: `distribution=random`, `key_type=u32`, N = 2¹⁰ … 2²⁶ (powers of two), 5 repetitions each variant.
- **Set B** — Distribution sweep: `key_type=u32`, N=2²² (4 194 304), all five distributions, 5 repetitions each variant.
  - `random` at N=2²² comes from Set A (no duplicate registration).
- **Set C** — u64 confirmation: `key_type=u64`, `distribution=random`, N=2²², 5 repetitions. Used for the key-width callout in the post.

## Harness note: the destructive-sort restore

Sorting mutates its input. Without a per-iteration restore, every iteration after the first measures the sort's sorted-input cost — a pathological best case. This affects the comparison sorts asymmetrically: `std::sort` and `pdqsort` collapse toward their sorted-input cost; radix is unaffected. The harness restores a pristine master copy with `memcpy` inside `state.PauseTiming()` each iteration.

Run `--verify-restore` before the headline capture to confirm the restore mechanism is working:

```
./bench/scripts/run_one.sh 08-sorting-shootout --verify-restore
# or, after building:
./bench/build/demos/08-sorting-shootout/bench_08_sorting_shootout --verify-restore
```

Expected output: per-rep ns/elem for the WITH-restore mode should be steady (no downward trend). The WITHOUT-restore mode will collapse from rep 1 onward — that is the expected demonstration of the bug.

**Restore verification result (headline capture):** [TO BE FILLED AFTER CAPTURE — "PASS" or "FAIL: stop and do not publish"]

## DoNotOptimize / ClobberMemory disassembly check

`benchmark::DoNotOptimize(work.data())` and `benchmark::ClobberMemory()` prevent the sort from being elided. Verify via:

```
objdump -d bench/build/demos/08-sorting-shootout/bench_08_sorting_shootout \
  | grep -A 50 "<_ZN.*BM_Sort.*Ev>"
```

The disassembly of the timed region should contain the actual sort instructions (for radix: counter loops; for std::sort: introsort; for pdqsort: pattern-detection + quicksort). A missing sort (just the memcpy) would indicate elision — the `DoNotOptimize` guard prevents this.

**Disassembly check result (headline capture):** [TO BE FILLED — "Sort not elided: confirmed" or specific note]

## Build

```bash
cmake -B bench/build -S bench -DCMAKE_BUILD_TYPE=Release
cmake --build bench/build --parallel
```

## Capture (headline — isolated boot required)

See `bench/scripts/run_one.sh 08-sorting-shootout` and the preconditions in `docs/briefs/08/08-sorting-shootout-brief.md §Preconditions`.
