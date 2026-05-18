# Demo 02 — False Sharing: P&L Accumulators

**A 341× throughput gap from two missing bytes.**

Each thread owns one slot in a shared array of P&L accumulators. The only difference
between the two variants is whether adjacent slots share cache lines (unpadded) or each
slot owns its own line (padded). With padding, there is no shared resource to contest;
without it, every write invalidates seven neighbouring slots and forces cache-coherency
round-trips on every iteration.

## What it measures

| Config | Threads | Layout | Physical resource |
|---|---|---|---|
| IntraCCX | 1, 2, 4 | padded / unpadded | CCX1 cores (4–7), shared 16 MB L3 |
| CrossCCX | 2, 4, 8 | padded / unpadded | CCX0 + CCX1 via Infinity Fabric |

12 variants total (6 intra + 6 cross; intra/8t and cross/1t are not registered).

## Build

```bash
cd bench
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
# POST_BUILD: objdump CI step asserts >=2 movsd in worker_fn (volatile codegen guard)
```

## Capture

**Precondition: boot into the benchmark GRUB entry.**

```bash
cat /sys/devices/system/cpu/isolated   # must read: 0-7
```

If it doesn't, reboot into `Ubuntu (benchmark — cores 0-7 isolated)`. The capture
script aborts with a clear error if the precondition is not met. See
[/methodology](/methodology) for the dual-GRUB-entry setup.

```bash
# Capture all 12 variants (run from repo root)
for placement in intra-ccx cross-ccx; do
  for threads in 1 2 4 8; do
    for padded in 0 1; do
      ./tools/perf_capture.sh \
        bench/build/demos/02-false-sharing/bench_02_false_sharing_pnl \
        $placement $threads $padded
    done
  done
done
# (skips intra-ccx/8t and cross-ccx/1t — not registered in the benchmark)

# Parse each variant into the site JSON
python3 tools/parse_perf.py \
  --perf  intra-ccx_4t_unpadded.perf.json \
  --bench intra-ccx_4t_unpadded.bench.json \
  --out   site/src/data/perf/02-false-sharing-pnl.json \
  --placement intra-ccx --threads 4 --padded 0
# repeat for each variant; the script upserts into the JSON file
```

## Verify thread pinning

```bash
CRUCIBLE_PRINT_AFFINITY=1 \
  bench/build/demos/02-false-sharing/bench_02_false_sharing_pnl \
  --benchmark_filter='CrossCCX/2t/unpadded' \
  --benchmark_repetitions=1 2>&1 | grep '\[bench\]'
# Expect: one cpu in {0,1,2,3} and one in {4,5,6,7}
```

## Additional prerequisites

- SMT off: `cat /sys/devices/system/cpu/smt/active` → `0` (set in BIOS)
- `kernel.perf_event_paranoid=1`: `sudo sysctl kernel.perf_event_paranoid=1`
- `linux-tools-$(uname -r)` installed

## Re-capturing

Before re-capturing, delete the existing data file so the parser produces a clean
JSON from the patched pipeline:

```bash
rm site/src/data/perf/02-false-sharing-pnl.json
./bench/scripts/run_one.sh 02-false-sharing
```

The first invocation in the loop will initialise the file with the canonical
methodology notes; subsequent invocations append per-variant runs.
