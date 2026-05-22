# Demo 05 — Background-pressure calibration ladder

Pre-headline calibration data for `bench_05_allocators`. Two distinct evidence classes exist: rungs 1–3b were captured in a graphical (gnome-terminal) session and drove the decision to drop the 2× p99.9 target; rungs 4a and 4b are captured headless (multi-user.target) to match the headline methodology and drive the bg-threads lock decision. The two classes are kept separate because absolute latency values differ slightly between graphical and headless environments — ratio comparisons are robust to this, but lock decisions require measurement-grade data.

## Rescope evidence (gnome-terminal)

All rungs: `--mode paced`, `--offered-rate-hz 1000000`, `--malloc-tuning arena1`.

| Rung | bg-threads | bg-pressure-hz | bg-live-allocs | malloc p99.9 (ns) | arena p99.9 (ns) | malloc / arena |
|------|-----------|---------------|----------------|-------------------|------------------|----------------|
| 1    | 1         | 1 M           | 512 (default)  | 328               | 344              | 0.95×          |
| 2    | 1         | 1 M           | 8192 (default) | 424               | 344              | **1.23×**      |
| 3a   | 1         | 2 M           | 8192           | 376               | 344              | 1.09×          |
| 3b   | 1         | 3 M           | 8192           | 376               | 328              | 1.15×          |

Rungs 1 and 2 raw JSON was not retained (captured before the brief was written). Rungs 3a and 3b JSON at `rung3a-{malloc,arena}.txt` and `rung3b-{malloc,arena}.txt`.

Note: rungs 3a and 3b were captured with aggregate-semantics pacing (`bg_pressure_hz / bg_threads`); with `bg_threads=1` this is identical to per-thread semantics, so the data is valid.

**Rescope conclusion:** defaults (bg-threads=1, bg-pressure-hz=1M, bg-live-allocs=8192) produce the best separation (1.23× at rung 2). Raising `bg-pressure-hz` narrows the gap. The 2× target is unreachable on this workload. Decision: drop the 2× target; write the post against the observed 30–50% effect. See `demo-05-rescope-brief.md`.

## Lock decision data (headless)

Rungs 4a and 4b are headless captures in multi-user.target (no graphical session). Rung 4a replicates rung 2's workload config as a sanity check; its ratio falls within the +5 percentage-point band (1.18×–1.28×) defined by the followup brief. Rung 4b adds a second T_bg thread; its ratio determines the bg-threads default.

JSON at `rung4a-{malloc,arena}.txt` and `rung4b-{malloc,arena}.txt`.

| Rung | bg-threads | bg-pressure-hz | bg-pressure-hz-total | bg-live-allocs | malloc p99.9 (ns) | arena p99.9 (ns) | malloc / arena |
|------|-----------|---------------|---------------------|----------------|-------------------|------------------|----------------|
| 4a   | 1         | 1 M           | 1 M                 | 8192           | 440               | 344              | **1.28×**      |
| 4b   | 2         | 1 M           | 2 M                 | 8192           | 392               | 344              | **1.14×**      |

Sanity check on rung 4a: 1.28× vs gnome-terminal rung 2's 1.23× is a 5 pp delta, at the upper edge of the band. The graphical-vs-headless gap on identical workload is ~4% on malloc p99.9 (440 vs 424), zero on arena. Sample-noise-plus-environment, not a methodology problem.

## Lock decision

**Locked bg-threads=1 (rule 3): headless rung 4b ratio = 1.14×, below the 1.23× threshold.**

Decision rule (from `demo-05-rescope-brief.md` §4):

- Rung 4b ratio ≥ 1.5× → lock `bg-threads=2`.
- 1.23× ≤ ratio < 1.5× → lock `bg-threads=2` (workload-honesty argument).
- ratio < 1.23× → keep `bg-threads=1`; the freelist-vs-arena section carries proportionally more of the post.

Worth recording: bg-threads=2 produced *narrower* separation than bg-threads=1, not wider. The followup brief's "workload honesty" argument predicted the opposite — more concurrent background allocators should compound pressure on the producer thread's allocation path. The likely mechanism is that two T_bg threads serialise on glibc's arena lock (per-thread arenas notwithstanding, the cross-thread-free path still acquires it), reducing how much new fragmentation each thread induces per unit time and how often the producer races against background activity. Not a finding worth a callout in the post, but informative for future allocator-themed demos: more background-pressure threads is not a monotonic dial on malloc tail-latency stress.

Future calibration ladders for this demo are headless by default.

## Headless capture procedure

```bash
# Drop to multi-user.target:
sudo systemctl isolate multi-user.target

# Log in at the console (tty1). Then:
export CRUCIBLE_TURBO=off
sudo cpupower frequency-set -g performance
sudo cset shield --reset
cat /sys/devices/system/cpu/smt/active        # expect 0
taskset -cp 1                                  # expect 0-7

cd ~/Development/Projects/Crucible
BIN=./bench/build/demos/05-allocators/bench_05_allocators

# Rung 4a captures (bg-threads=1):
$BIN cross-thread-malloc --mode paced --bg-threads 1 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4a-malloc.txt
$BIN arena-batch-handoff --mode paced --bg-threads 1 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4a-arena.txt

# Rung 4b captures (bg-threads=2):
$BIN cross-thread-malloc --mode paced --bg-threads 2 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4b-malloc.txt
$BIN arena-batch-handoff --mode paced --bg-threads 2 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4b-arena.txt

# Return to graphical:
sudo systemctl isolate graphical.target
```
