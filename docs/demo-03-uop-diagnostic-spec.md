# Demo 03 µop diagnostic — capture spec

Purpose: empirically settle whether Zen 2 (3800X) executes 256-bit AVX2 instructions as single µops or splits them 2×128-bit, using our own PMU counters rather than documentation alone. Gates the C-1 thesis-correction brief for demo 03's step 3→4 section.

## Registered prediction (before capture, pilot discipline)

Public µarch documentation (WikiChip Zen 2, AMD Zen 2 disclosures) says Zen 2 widened the FPU datapath to 256 bits and decodes AVX-256 as FastPath Single — i.e. **no split**. Predicted outcome:

- **µops-per-instruction for the avx2fma kernel ≈ µops-per-instruction for the sse2 kernel** (both ~1.0–1.3; loads-with-op and div/sqrt legitimately multi-op on any µarch).
- If the shipped µop-split story were correct, the avx2fma ratio would be ≈ 2× the sse2 ratio.

The decision rule is the *comparison between kernels*, not an absolute 1.0 threshold — that controls for instruction classes that are multi-op regardless of width.

## Procedure

Standard rig state: `sudo cset shield --reset`, performance governor, turbo off (verify cpb), headless `multi-user.target`, pinned to an isolated core (taskset to core 4).

1. Confirm the retired-µops event name on Family 17h:
   `perf list | grep -i -e ret.*uop -e ret.*ops`
   Expected symbolic name on Zen 2 is `ex_ret_uops`; if absent, use raw event `r0C1` (PMCx0C1, Retired Uops). Retired instructions: `instructions` (or `ex_ret_instr`).
2. For each of the three kernels — `avx2fma`, `sse2`, and `scalarpoly` as control — run the demo-03 bench filtered to that variant at N=1,048,576 with enough repetitions for a multi-second measurement window:
   `taskset -c 4 perf stat -e instructions,ex_ret_uops ./bench_03 --benchmark_filter=<variant>.*1048576 --benchmark_repetitions=20`
3. Record per-kernel: instructions, retired µops, computed µops/instruction, plus `captured_at` timestamp and turbo state (cpb) alongside.

Raw `perf stat` text output is sufficient — this is a diagnostic, not a headline capture; it does not enter the JSON pipeline.

## Interpretation

| Outcome | Verdict | Consequence |
|---|---|---|
| avx2fma µops/inst ≈ sse2 µops/inst (within ~20%) | No split — Zen 2 native 256-bit confirmed on our silicon | C-1 thesis rewrite proceeds; corrected section cites this measurement |
| avx2fma ratio ≈ 2× sse2 ratio | Split — shipped story stands, documentation reading wrong | C-1 downgraded; step 3→4 retained with the diagnostic added as evidence |
| Anything in between / unstable | Stop and discuss | No rewrite until understood |

## Out of scope

- No MDX edits ride this capture.
- N sweep not needed; N=1M only.
- The numeric patch brief (`demo-03-rederivation-brief.md`) is independent and can be applied before, during, or after this capture.
