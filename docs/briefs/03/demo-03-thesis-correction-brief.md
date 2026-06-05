# Demo 03 thesis-correction brief (C-1, C-2) — Zen 2 µop-split mechanism is wrong

Branch: `feature/boost-off-recapture`. Scope: `content/posts/03-simd-blackscholes.mdx` (prose), `site/src/data/perf/03-simd-blackscholes.json` (`notes` field), and `bench/demos/03-simd-blackscholes/` (the source constant that emits the JSON `notes`). Composes with `demo-03-rederivation-brief.md` (numeric pass) — no line overlap; apply in either order.

## Context

The shipped post explains the AVX2/SSE result with a Zen 2 µop-split mechanism ("256-bit AVX2 splits into two 128-bit µops"). That describes Zen/Zen+, not Zen 2 — Zen 2 widened the FP datapath to 256 bits and executes 256-bit ops as single µops.

This was verified on the reference machine, not just from documentation. Diagnostic capture `uop_diag_20260605T115352Z.txt` (core 4, N=1M, 20 reps, `instructions` vs `ex_ret_cops`):

| kernel     | instructions   | ex_ret_cops    | µops/instruction |
| ---------- | -------------- | -------------- | ---------------- |
| avx2fma    | 51,945,436,195 | 51,667,991,496 | **0.9947**       |
| sse2       | 67,256,090,137 | 66,986,856,266 | **0.9960**       |
| scalarpoly | 80,686,292,793 | 87,917,244,540 | 1.0896           |

avx2fma ≈ sse2 to within 0.1% — single-µop execution, no split. A 128-bit crack would put avx2fma near 2× sse2.

Two findings follow, same root cause:

- **C-1**: the step 3→4 mechanism, its IPC decomposition, the section header, takeaway ¶2, and the "Zen 3+" bullet are built on the wrong microarchitecture.
- **C-2**: the "% of theoretical peak" figure derives peak from "1 256-bit FMA per 2 cycles" (the split tax), giving 62 GFLOPS. Native Zen 2 does two 256-bit FMAs per cycle → ~125 GFLOPS/core; AVX2's 27 GFLOPS is ~22% of peak, not 44%.

The _measurements_ are unaffected — only the explanation and the derived peak%.

## Pre-flight sentinel

Same as the numeric brief: `03-simd-blackscholes.json` `captured_at == "2026-06-05T06:00:37Z"`, `turbo:false`, `turbo_source:"cpb"`, `freq_max_available_mhz:3900`. Plus confirm the diagnostic file `uop_diag_20260605T115352Z.txt` is the source for the µop figures cited below. Abort on mismatch.

## Tasks — 03-simd-blackscholes.mdx

### T1 — Replace the entire Step 3→4 block

Find (verbatim, the header line through the end of the IPC paragraph):

```
**Step 3 → 4: AVX2 + FMA — and the Zen 2 µop-split fingerprint.**

*Going in:* Zen 2 implements 256-bit AVX2 by splitting each instruction into two
128-bit µops internally. One `vfmadd256ps` consumes two execution-port slots
where Zen 3 would consume one. On µop count alone, this halves the theoretical
width advantage of 8-wide AVX2 over 4-wide SSE. The prediction was that AVX2
would land *under* 2× SSE on this CPU.

*What actually landed:* at N=16,384 — the cleanest comparison, with the working
set in L2 and per-iteration overhead amortised — AVX2/SSE is **1.995×**. Right at
the threshold, exactly as the µop-split argument predicts. At N=1,048,576 the
ratio rises to **2.252×** as the fixed per-iteration harness cost dissolves
further.

The IPC counters expose the µop split directly: SSE retires 1.21 instructions per
cycle, AVX2 retires 0.91 — a 0.75 ratio, almost exactly what you'd expect if each
AVX2 instruction occupies two issue slots. But each retired AVX2 instruction is
also doing ~2.5× the work of a retired SSE instruction (8 lanes plus FMA's two
flops per multiply-add, vs 4 lanes of separate mul + add). Multiply those out:
0.75 × 2.5 ≈ 1.9× — and the rest is small effects (register pressure, scheduling,
amortisation). The headline ratio doesn't come from AVX2 magically being 2× SSE;
it comes from FMA reclaiming what µop split costs you.
```

Replace with:

```
**Step 3 → 4: AVX2 + FMA — width scaling at the lane-count ceiling.**

*Going in:* Zen 2 widened the entire FP datapath to 256 bits, so a 256-bit AVX2
instruction issues as a single µop — unlike Zen and Zen+, which cracked each
256-bit op into two 128-bit µops. This is measurable on the reference machine
with the retired-µop counter (`ex_ret_cops`): the AVX2 kernel retires **0.99 µops
per instruction**, indistinguishable from SSE's **1.00**, not the ~2× a 128-bit
split would force. So the honest expectation is plain width scaling — 8 lanes over
4 is **2×** — with FMA folding each multiply-add into a single instruction on top.

*What actually landed:* at N=16,384 — the cleanest comparison, with the working
set in L2 and per-iteration overhead amortised — AVX2/SSE is **1.991×**, right at
the lane-width ratio. At N=1,048,576 it rises to **2.252×**, just above 2× as
FMA's instruction economy shows through and the fixed per-iteration harness cost
dissolves.

The counters show where the win comes from and where it leaks. Per option, the
AVX2 kernel retires **2.9× fewer instructions** than SSE (≈17 vs ≈50) — roughly 2×
from width, the rest from FMA fusing the multiply-adds in the Horner cascades.
That instruction economy is partly handed back by lower IPC: SSE sustains **1.21**
instructions per cycle against AVX2's **0.91** (a 0.75 ratio), because the
remaining AVX2 work is dominated by `div` and `sqrt` — which don't get cheaper
with width — and by the serial polynomial dependency chains, leaving fewer
independent instructions to fill the issue ports. Net it out: 2.9× fewer
instructions × 0.75 IPC ≈ **2.2×**, the measured throughput gain. The result is
honest width scaling plus FMA, not the reclaiming of a split penalty that does
not exist on this core.
```

(Derivations: µops/inst 0.9947 / 0.9960; AVX2/SSE 11.6045/5.8287 = 1.991 @16k, 10.3958/4.6156 = 2.252 @1M; inst/option from the diagnostic — avx2 51.945e9/(20·144·1048576) = 17.2, sse2 67.256e9/(20·64·1048576) = 50.1, ratio 2.91; IPC 1.213/0.909 = 0.749; 2.91 × 0.749 = 2.18 ≈ 2.2.)

### T2 — Takeaway ¶2

Find:

```
On Zen 2 the AVX2/SSE ratio lands near 2× rather than a theoretical 4× because
each 256-bit instruction splits into two 128-bit µops internally — FMA reclaims
what µop split costs you. On Zen 3+ and Sapphire Rapids, where 256-bit ops
dispatch natively, the same code path would be closer to a clean 4×.
```

Replace with:

```
On Zen 2 the AVX2/SSE ratio lands near 2× because that is the lane-width ratio —
8 lanes over 4 — not because of a µop-split penalty: Zen 2 executes 256-bit AVX2
as single µops (measured at ~1 µop per instruction, the same as SSE). FMA nudges
the ratio just above 2× at large N by cutting instruction count. Zen 3, Zen 4, and
Sapphire Rapids also execute 256-bit natively, so the lane-width ceiling is the
same 2× there — going wider needs a wider ISA (AVX-512), not a newer 256-bit core.
```

### T3 — "% of theoretical peak" bullet (C-2)

Find:

```
- **% of theoretical peak.** Zen 2 base-clock theoretical peak for 256-bit FMA
  is roughly 62 GFLOPS per core (2 FMA pipes × 1 256-bit FMA per 2 cycles × 8
  lanes × 2 flops × 3.9 GHz). The AVX2 variant lands at 27 GFLOPS = ~44% of
  peak. Division, square root, and the polynomial cascades (which can't all
  pipeline as pure FMA) are the gap.
```

Replace with:

```
- **% of theoretical peak.** Zen 2's base-clock peak for 256-bit FMA is roughly
  125 GFLOPS per core (2 FMA units × one 256-bit FMA each per cycle × 8 lanes ×
  2 flops × 3.9 GHz). The AVX2 variant lands at 27 GFLOPS = ~22% of peak.
  Division, square root, and the polynomial cascades (which can't all pipeline as
  pure FMA) are the gap.
```

(Derivation: 2 × 1 × 8 × 2 × 3.9 = 124.8 GFLOPS; 27.085 / 124.8 = 21.7%. Zen 2 issues two AVX-256 ops/cycle via two FMA-capable pipes — WikiChip/AMD Zen 2 disclosures.)

### T4 — "Zen 3+" bullet in "What this doesn't show"

Find:

```
- **Zen 3+**: Zen 3 and Sapphire Rapids dispatch 256-bit ops natively; the AVX2/SSE
  ratio would be closer to 2× there.
```

Replace with:

```
- **Wider ISA, not a newer core.** Zen 3, Zen 4, and Sapphire Rapids also execute
  256-bit AVX2 natively (as Zen 2 already does), so the AVX2/SSE ratio stays near
  the 2× lane-width ceiling on them too. Beating it needs AVX-512's 16 lanes — see
  the AVX-512 note above — not a newer 256-bit core.
```

## Tasks — JSON and bench source (bench-side)

### T5 — site data JSON `notes` field

In `site/src/data/perf/03-simd-blackscholes.json`, find the trailing `notes` value:

`"...Zen 2 \u03bcop-split: AVX2/SSE < 2\u00d7 predicted."`

Replace the µop-split clause with:

`"...Zen 2 executes 256-bit AVX2 as single \u00b5ops (verified ex_ret_cops \u22481.0/instr); AVX2/SSE \u22482\u00d7 = lane-width ratio."`

### T6 — bench source constant

The same string is emitted by the demo-03 bench (search `bench/demos/03-simd-blackscholes/` for the `notes`/`µop-split` literal). Update it to match T5 so a future recapture does not regress the JSON. If the literal is assembled in `assemble_results.py`, fix it there instead. Report which file carried it.

## Acceptance criteria

Against `03-simd-blackscholes.mdx`:

1. `grep -c 'µop-split\|splits into two\|split penalty\|occupies two issue slots'` → 0
2. `grep -c '1\.995×'` → 0; `grep -c '1\.991×'` → 1
3. `grep -c '0\.75 × 2\.5'` → 0; `grep -c '2\.9× fewer instructions'` → 1
4. `grep -c '62 GFLOPS'` → 0; `grep -c '125 GFLOPS'` → 1; `grep -c '~44% of'` → 0; `grep -c '~22% of peak'` → 1
5. `grep -c 'closer to a clean 4×\|closer to 2× there'` → 0
6. `grep -ci 'ex_ret_cops'` → 1 (the measured-µop citation in step 3→4)

Against the JSON: 7. `grep -c 'op-split'` → 0 in `03-simd-blackscholes.json`

## Out of scope

- All numeric edits owned by `demo-03-rederivation-brief.md` (12%→11%, footer, N=1024 bullet, 09 coupling). This brief does not touch them.
- **Supersedes** acceptance criterion 5 of the numeric brief ("1.995× unchanged → 1"): once this brief applies, 1.995× is gone (→1.991× inside the rewritten block). If the numeric brief is applied first, that criterion is expected to flip when this brief lands; if this brief is applied first, the numeric brief never sees 1.995×. Either order is consistent.
- The demo-03 batched-edit brief (arch/soc, poly.h) — separate, gated on demo 09.
- Other demos. 09 was checked: it cites demo 03 throughput ratios only (handled in the numeric brief), never the µop mechanism — no thesis coupling.

## Open items

1. The `perf_event_paranoid<=0` precondition bit the first diagnostic run (counters returned access errors at paranoid=4). Now pinned to 0 on the rig. This is the still-owed `prepare_bench.sh` hardening item from the demo-02 register — assert paranoid<=0 in the capture preflight so a wrong value aborts loudly. Track separately.
2. C-2 (peak GFLOPS) should be noted in the methodology correction-note pass as a shipped factual error, alongside the µop mechanism — both stem from a Zen-1 model of Zen 2.
3. The diagnostic established a reusable rig recipe (`uop_diag.sh`); worth keeping for any future µarch claim that needs counter-level backing.
