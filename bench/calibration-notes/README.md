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

Rungs 4a and 4b are fresh captures in multi-user.target (no graphical session). Rung 4a replicates rung 2's workload config as a sanity check; its ratio should fall within 5 percentage points of rung 2's 1.23× (band: 1.18×–1.28×). Rung 4b adds a second T_bg thread; its ratio determines the bg-threads default.

**Current status: headless re-capture pending.** The files `rung4a-{malloc,arena}.txt` and `rung4b-{malloc,arena}.txt` currently contain gnome-terminal captures and are not reusable as lock decision data. Use the procedure below to re-capture headless, then update this table.

| Rung | bg-threads | bg-pressure-hz | bg-pressure-hz-total | bg-live-allocs | malloc p99.9 (ns) | arena p99.9 (ns) | malloc / arena | Source |
|------|-----------|---------------|---------------------|----------------|-------------------|------------------|----------------|--------|
| 4a   | 1         | 1 M           | 1 M                 | 8192           | —                 | —                | —              | pending headless |
| 4b   | 2         | 1 M           | 2 M                 | 8192           | —                 | —                | —              | pending headless |

Preliminary gnome-terminal values (not used for lock decision): 4a = 1.28×, 4b = 1.14×.

## Lock decision (pending headless capture)

Decision rule (from `demo-05-rescope-brief.md` §4):

- Rung 4b ratio ≥ 1.5× → lock `bg-threads=2`.
- 1.23× ≤ ratio < 1.5× → lock `bg-threads=2` (workload-honesty argument).
- ratio < 1.23× → keep `bg-threads=1`; the freelist-vs-arena section carries proportionally more of the post.

Update this section with the definitive one-sentence decision once headless rung 4b is captured. Example: "Locked bg-threads=1 (rule 3): headless rung 4b ratio = X.XX×."

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

After capture: read `p99_9` from `latency_ns.stats` in each file, check rung 4a sanity band, apply the decision rule above, update the lock decision table and the one-sentence decision statement.
