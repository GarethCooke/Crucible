# Demo 09 — ARM NEON calibration pilot (throwaway)

This is a **throwaway** pilot bench.  It answers the §A go/no-go questions in
`demo-09-arm-neon-pilot-scope.md` before the demo 9 implementation brief is
written.  It is **not** wired into `run_one.sh`, not committed to `site/`, and
will be deleted or absorbed when the implementation brief lands.

**Target hardware:** Pi 5 rig only (BCM2712, Cortex-A76, AArch64).

## Build (on the Pi 5 rig)

```bash
cd bench/pilot/09-arm-neon
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

The post-build step runs `dump_asm.sh` and writes `asm/price_neon.s` and
`asm/price_scalar.s`.

## Automated pilot runner

`run_pilot.sh` executes all five go/no-go tasks in sequence with validation at each step.
Run it on the Pi 5 rig:

```bash
cd bench/pilot/09-arm-neon

./run_pilot.sh          # expects a pre-built binary in build/
./run_pilot.sh --build  # cmake build + run
```

The script runs tasks in this order: **A5 → A1 → A2/A3 → A4**.
A5 (codegen check) comes first because a vectorisation failure in the scalar baseline
would make the A2/A3 ratios meaningless — the script aborts early if that guard fails.

| Task | What it checks | Outcome |
|------|---------------|---------|
| A5 | NEON ops present in `asm/price_neon.s`; none in `asm/price_scalar.s` | **FAIL → abort** |
| A1 | All 5 `perf stat` counters available (no `<not supported>`) | **REFRAME** if any missing |
| A2 | NEON-over-scalar ratio at N=16k (compute-bound) | ≥3.5× **GO** · 2.5–3.5× **WARN** · <2.5× **STOP** |
| A3 | Hand-NEON advantage % at N=16k (decides Framing A) | >15% **GO** · ≤10% **COLLAPSE** (fine) |
| A4 | 8-min thermal soak on core 3; polls temp + throttle every 2s | Any throttle bit **STOP** · temp ≥80°C **WARN** |

Run output and the A4 soak poll log are saved to `pilot_logs/`.

---

## Manual run lines

### A2/A3 — NEON-over-scalar ratio at two N

```bash
# Cache-resident (isolates compute-bound case, ~320 KB)
taskset -c 3 ./build/pilot_blackscholes --variant scalar --n 16384
taskset -c 3 ./build/pilot_blackscholes --variant neon   --n 16384

# Headline N (spills cache)
taskset -c 3 ./build/pilot_blackscholes --variant scalar --n 1048576
taskset -c 3 ./build/pilot_blackscholes --variant neon   --n 1048576
```

Expected compute-bound ratio (16k) ≈ 4× (Cortex-A76 is 4-wide float32 NEON,
no SVE).  See scope §A2 for the go/no-go decision rules.

### A1 — full counter set

```bash
perf stat -e cycles,instructions,branch-misses,cache-misses,cache-references \
  taskset -c 3 ./build/pilot_blackscholes --variant neon --n 1048576
```

Check none report `<not supported>` or `<not counted>`.

### A5 — codegen eyeball

```bash
# NEON must be present in price_neon
grep -E 'fmla|v[0-9]+\.4s' asm/price_neon.s

# Scalar baseline must have no vector ops
grep -E 'fmla|v[0-9]+\.4s' asm/price_scalar.s   # expect: no matches

# Or inspect the full dump
less asm/pilot_full.s
objdump -d --demangle --no-show-raw-insn ./build/pilot_blackscholes | less
```

### A4 — sustained-load thermal soak

Run the bench in a tight loop pinned to core 3 for ~8–10 minutes while polling:

```bash
while true; do vcgencmd measure_temp; vcgencmd get_throttled; sleep 2; done
```

A4 is a user judgement call — see scope §A4 for pass/fail criteria.
