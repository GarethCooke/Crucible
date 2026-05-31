# Crucible — Demo 09 (ARM NEON cross-arch) calibration-pilot scope

Scope doc for the demo 9 calibration pilot. Authored by Opus; the throwaway bench is buildable by CC (§Throwaway bench), the runs and judgement are the user's. This is **not** the implementation brief. Its job is to resolve the go/no-go questions in §A so the implementation brief can be written against measured fact, per the demos 5–8 "pilot before brief" lesson. Nothing here is committed to `site/` or `bench/demos/`; the pilot is throwaway.

## Context

The Pi 5 bench rig is up and verified capture-ready (green `pi-preflight.sh`: isolation `2-3`, governor performance, clock pinned 2400 MHz, `get_throttled=0x0`, `perf stat` functional, isolated cores idle). The runtime-setup and preflight scripts shipped via `crucible-pi-rig-setup-brief.md`.

The demo is the cross-arch companion to demo 3 (SIMD Black-Scholes on Zen 2). It is **not** "SIMD also works on ARM" — demo 3 already proved vectorisation. The reason to ship it is architectural honesty about vector width, and the proof that the methodology travels across ISA and microarchitecture.

- `03-simd-blackscholes-brief.md` / `05-mdx-rewrite-brief.md` — the x86 sibling. Black-Scholes call pricing, `poly.h` polynomial approximations (Cody 1980 `erf`, range-reduced `exp`), variants ordered to decompose algorithm win vs SIMD width win. Zen 2 finding: AVX2 is nominally 8-wide float32 but cracks into 2×128-bit µops, so the realised AVX2/SSE ratio landed ~2.0–2.25×, not 2×-clean. That µop-split nuance is part of the cross-arch story, not a footnote.
- `crucible-handover.md` — this is the "constrained-hardware differentiation" post; captures are headless, single isolated core.
- `BRIEF.md` — schema, methodology commitments, `perf_wrapper.h` captures counters by invoking `perf stat` via shell wrapper and parsing to JSON. So the pilot's counter check is a `perf stat -e ...` question, not a Google Benchmark built-in question.

## The thesis fork the pilot resolves

Two candidate framings. The pilot decides which survives and whether both do.

- **Framing B — the width ceiling (presumed headline).** The Cortex-A76 is NEON-only: 128-bit, 4-wide float32, same width as SSE, **no SVE** (SVE is an ARMv8.2 option the A76 doesn't implement). So the Black-Scholes kernel tops out at ~4× over scalar and _stays there_ — there is no wider unit to reach for, where the Zen 2 box went to AVX2. The honest punchline is "vector width is an architectural property you don't get to assume," with a cross-link to demo 3's 8-wide (µop-split-muted) AVX2. A well-told ceiling, on-brand for the hype-allergic reader.
- **Framing A — hand-NEON vs the autovectoriser (candidate secondary story).** On AArch64, NEON is part of the base ISA, so `-O3` autovectorises to NEON by default — unlike x86, where SIMD is opt-in via `-mavx2`. The question is whether hand-written NEON intrinsics still beat GCC's autovec on this kernel. If yes, that's a second axis; if autovec already matches hand-written, the axis collapses and the demo rests on Framing B alone.

Either way the demo survives. The pilot decides whether it's one story or two, and confirms Framing B's central number is real.

## Standing constraint — bake into every pilot run

**Never compare absolute ns/op across the two machines.** Different clocks, process nodes, memory — cross-machine wall-clock is the apples-to-oranges trap a hostile reader pounces on. The only portable quantity is the **within-machine speedup ratio** (NEON-over-scalar on the Pi vs AVX2-over-scalar on Zen 2). The pilot captures Pi ratios; it does not put a Pi ns/op next to a Zen 2 ns/op anywhere.

## §A — Go/no-go questions

### A1. Does the A76 PMU populate the full counter set the schema needs?

Preflight proved `cycles` works. The schema's counter-overlay story needs cycles, instructions (→ IPC), branch-misses, and cache-misses. Run, pinned to the isolated core:

```
perf stat -e cycles,instructions,branch-misses,cache-misses,cache-references \
  taskset -c 3 ./pilot_blackscholes --variant neon --n 1048576
```

Check none report `<not supported>` or `<not counted>`. The A76 has 6 programmable counters and exposes these as raw events; the risk is kernel/perf _event-name mapping_, particularly `cache-misses` (maps to a last-level event that can read oddly on BCM2712). If a generic alias misfires, try the A76 raw event (e.g. `r0017` for L2D refills) before concluding it's unavailable.

- **All present → GO.** Counter-overlay charts (IPC, branch/cache behaviour) are available; demo can carry the full demo-3-style counter story.
- **branch-misses or cache-misses genuinely unavailable → REFRAME (not no-go).** Demo leans on throughput / within-machine ratio charts and drops the counter-overlay panel. Note it in the eventual "what this doesn't show."

### A2. Where does NEON-over-scalar actually land?

Build the throwaway bench (scalar_poly + neon_intrinsics, §Throwaway bench). Measure the ratio at two N:

- **16 k** (cache-resident, ~320 KB — isolates the compute-bound case, exactly demo 3's companion-N trick).
- **1 M** (headline, spills cache — part SIMD, part bandwidth; demo 3 was honest about this).

Expected compute-bound ratio ≈ 4× (4-wide float32). Decision on the **16k** number:

- **Near 4× (say ≥ 3.5×) → GO**, Framing B is solid; the ceiling is real and chartable.
- **Well below (< 2.5×) → STOP and diagnose before committing.** Likely causes, in order: FTZ not set (subnormals in deep-OTM tails cost cycles — see A5); the "scalar" baseline got auto-NEON'd (A5 guard failed); or measurement at the wrong N. Do not write the brief on a sub-ceiling number — re-scope.

### A3. Is the autovec-vs-hand-NEON gap chartable? (decides Framing A)

Compile the **scalar_poly** kernel at `-O3 -mcpu=cortex-a76` (autovec to NEON, the default on AArch64) and compare against the hand-written **neon_intrinsics** variant at the same N.

- **Hand-written beats autovec by a chartable margin (say > 15%) → Framing A is alive** as a secondary story; the brief can include both axes.
- **Autovec matches hand-written (within ~10%) → Framing A collapses.** Demo rests on Framing B alone. This is a fine outcome — "the compiler already gets NEON for free, and even free NEON hits the same 4-wide wall" is itself a clean point.

### A4. Does the rig stay un-throttled under sustained load?

Preflight's `0x0` was at idle. The capture-trust question: run the throwaway bench in a tight loop pinned to core 3 for ~8–10 minutes (the real capture is shorter, so this is a margin), polling throughout:

```
while true; do vcgencmd measure_temp; vcgencmd get_throttled; sleep 2; done
```

- **Ends `throttled=0x0`, temp stays clear of the throttle threshold (~80–85 °C) → GO**, the cooler is adequate and captures are trustworthy.
- **Any nonzero throttle bit, or temp at threshold → STOP.** The active cooler isn't enough under sustained load; sort cooling before any authoritative capture, or every number is contaminated. This is the Pi's analogue of an enabled-boost-invalidates-the-capture failure on the Zen 2 box, and it's a hard gate on data trust.

### A5. Codegen + denormals sanity (cheap; do alongside A2)

- **NEON present in the hot loop.** `objdump -d` the neon_intrinsics object; confirm vector `fmla`/`v`-register forms in the inner loop. Confirms `-mcpu=cortex-a76` did what's intended.
- **Scalar baseline stays scalar.** The AArch64 analogue of demo 3's `-fno-tree-vectorize` guard: confirm the scalar_poly hot loop has _no_ vector ops, so the ratio in A2/A3 isn't measuring autovec-vs-autovec. If GCC autovecs it anyway, add `-fno-tree-vectorize` (or the function attribute) to the scalar baseline and note it.
- **FTZ on ARM.** AArch64 flushes denormals via the **FPCR FZ bit** (no separate DAZ; FZ covers inputs and outputs), set via inline asm / fpcr intrinsic — the ARM equivalent of x86 `_MM_SET_FLUSH_ZERO_MODE`. Demo 3's subnormal-contamination concern carries over directly: deep-OTM Black-Scholes tails produce subnormals; without FZ they cost cycles and add noise unrelated to SIMD. Set FZ at bench start in the pilot, or A2's ratio is suspect.

## Throwaway bench (buildable by CC)

Deliberately minimal — this is scaffolding to answer §A, not demo code. Lives in a scratch dir (e.g. `bench/pilot/09-arm-neon/`), is **not** wired into `run_one.sh`, **not** committed to `site/`, and is deleted or absorbed when the implementation brief lands.

- Two variants only: `scalar_poly` and `neon_intrinsics`. Reuse demo 3's `poly.h` math verbatim where it ports; the NEON variant rewrites the SSE intrinsics as their `float32x4_t` equivalents (same 4-wide coefficients).
- Inputs: same seeded generation and ranges as demo 3 (seed `0xCAFEBABE`, S/K/T/r/σ ranges), arrays `alignas(16)` (NEON is 128-bit).
- N values: 16 k and 1 M. 5 timed runs each, report median ns/op + ops/sec.
- FPCR FZ set at startup (A5).
- Built `-O3 -mcpu=cortex-a76`; scalar baseline guarded against autovec (A5).
- A correctness check against a scalar libm oracle (max abs error < 1e-4) so we know the NEON math is right before trusting its speed — same bar as demo 3.

The pilot does **not** need: the full N-sweep, the algorithm-win (libm vs poly) variant, chart components, JSON-schema conformance, or MDX. Those are implementation-brief scope.

## Outcomes → next artefact

Once §A is answered, the implementation brief is written against the results:

- A1 sets whether counter-overlay charts are in or out.
- A2 confirms (or kills) Framing B's headline number.
- A3 sets one-story-or-two.
- A4 is the data-trust gate — a fail here blocks captures regardless of A1–A3.
- A5 makes A2/A3 trustworthy.

If A2 lands near 4× and A4 stays clean, the demo is GO and I write `09-arm-neon-brief.md` (full demo-implementation shape: variants, N-sweep, machine block for the Pi, charts, prose, cross-link to demo 3, the "what this doesn't show" honesty section). If A2 comes in sub-ceiling or A4 throttles, we stop and re-scope here rather than committing a brief to a number the hardware won't give.

## Open items to flag during the pilot

1. **Machine-block schema for a second machine.** The Pi capture needs a machine block, but the current schema was written for the single Zen 2 rig (`isolated_cpus`, etc.). How a second machine is represented — and whether any field needs adding (e.g. `arch`, `soc`) — is an implementation-brief decision, but if the pilot's `perf`/`machine_info` probing surfaces something the schema can't express, note it now.
2. **`cache-misses` mapping (A1).** If the generic alias misfires, record which raw A76 event you fell back to, so the brief documents it rather than rediscovering it.
3. **Sustained-load clock reality (A4).** While polling temp, also spot-check that `scaling_cur_freq` on core 3 actually holds at 2400 MHz under load — the pin should hold it, but confirm DVFS isn't quietly dropping it independent of thermal throttle.
