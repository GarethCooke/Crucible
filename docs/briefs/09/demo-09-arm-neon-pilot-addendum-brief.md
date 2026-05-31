# Crucible — Demo 09 pilot addendum: scalar-poly baseline + autovec timing

Implementation brief for Claude Code (build + codegen verify) and the user (rig captures). Extends the §2 calibration pilot under `bench/pilot/09-arm-neon/`. Throwaway pilot work: **no JSON, no chart, no commit to `site/`.** Findings feed `demo-09-plan.md` §3 (the implementation brief). Self-contained; depends on the existing pilot bench from `demo-09-arm-neon-pilot-bench-brief.md`.

## Context

The first pilot pass (A1–A5) returned a conditional GO, but two measurements the variant set didn't cover have to land before §3 can pin the story:

- **The headline ratio is not a clean width ratio.** NEON over scalar measured 4.47× at 16k and 4.77× at 1M — _above_ the 4-wide ceiling. The disassembly explains it: the scalar variant calls libm `logf` per element (and `sqrtf` on the negative path), while the NEON main loop uses an inline polynomial log/exp and is call-free. So the ratio conflates the 4-wide width win with a transcendental-implementation win. A width-isolating baseline is needed: the same inline polynomial as NEON, run 1-wide.
- **Autovec did not vectorise.** The autovec disassembly is the _same 496-instruction stream as the scalar baseline_ (identical after address normalisation, zero `.4s` float ops, same three libm calls, stride-1 loop). GCC's autovectoriser won't cross the `logf` call or the data-dependent edge branch. This is a finding, not a null result — it is the "NEON is baseline but not free" point. But it currently rests on asm alone; it needs a timing line so the chart shows autovec sitting on the scalar curve as real data.

Companion docs:

- `demo-09-plan.md` — §2 (calibration pilot), §3 (the brief this feeds), and the "Algorithm-win line" open item.
- `demo-09-arm-neon-pilot-bench-brief.md` — the existing pilot harness (5 runs, median, FTZ-at-startup, correctness print, `--variant`/`--n` dispatch). This addendum slots into it; do not refactor it.

No branch, no merge, no deploy. Pilot bench only.

## Tasks

### 1. Add the `scalar_poly` variant [CC build + verify; user run]

A scalar baseline that runs the **same numerical algorithm as the NEON kernel** — identical polynomial log/exp/sqrt — one element per loop iteration. The point is apples-to-apples: only the lane count differs between this and NEON, so the `scalar_poly → neon` ratio isolates vector width.

**1a [CC] — implement.** Add `scalar_poly` to the pilot bench's `--variant` dispatch. Reuse the NEON kernel's polynomial coefficients and evaluation sequence — do **not** invent a second coefficient set. If the NEON kernel inlines its constants in intrinsic immediates rather than naming them, lift the coefficient set and the eval steps into a shared scalar helper (`float`-typed twin of the `float32x4_t` body) that both variants reference, so the two paths cannot drift. No libm calls in the hot loop — the log and exp are the inline polynomials, the sqrt is `fsqrt` (scalar), the edge handling matches what NEON does branchlessly, expressed in scalar form.

**1b [CC] — build and verify codegen.** Build with the same flags and target as the existing variants (`-O3 -mcpu=cortex-a76`, FPCR FZ set at startup). Disassemble `price_scalar_poly` and post, before the user runs anything:

- `grep -E 'bl\s+.*(logf|expf|sqrtf)@plt'` over the function returns **zero** hits.
- `grep -cE '\.4s' ` over the function returns **0** (the `.2s` exp-bit-trick — `shl v..2s, #23`, `movi v..2s` — is scalar and is fine; only `.4s` parallel-float would indicate accidental vectorisation).
- The loop back-edge increments by one element (`add xN, xN, #0x1`, not `#0x4`).

**1c [user] — capture.** On the Pi rig, `pi-preflight.sh` green before and after, `taskset -c 3`:

- `--variant scalar_poly --n 16384`, 5 runs.
- `--variant scalar_poly --n 1048576`, 5 runs.

Record median ns/op and the printed `max_abs_error` for each.

### 2. Capture autovec timing [user run; CC only if dispatch wiring is needed]

The autovec binary already exists and its asm is verified scalar-identical. This run captures it as a timing line so the "autovec lands on scalar" finding is data, not assertion.

**2a [user] — capture.** Same conditions as 1c:

- `--variant autovec --n 16384`, 5 runs.
- `--variant autovec --n 1048576`, 5 runs.

Record median ns/op and `max_abs_error` for each.

(If `autovec` was only built as a standalone object for the asm dump and is not in the pilot binary's `--variant` dispatch, CC wires it in first — see Open items.)

## Acceptance

### scalar_poly codegen [CC, before captures]

- No `bl .*(logf|expf|sqrtf)@plt` in `price_scalar_poly`.
- Zero `.4s` ops in `price_scalar_poly`; loop stride is one element.
- Posted to the thread before the user captures.

### scalar_poly correctness [user]

- Printed `max_abs_error` < 1e-4 at both N (expected ≈ 2.67e-5, matching NEON, since it is the same polynomial). If it is materially different from the NEON figure, the port diverged — stop.

### Timing captured [user]

- scalar_poly and autovec each have a 5-run median at 16k and at 1M.

### Sanity checks (not gates — flags for §3)

- `autovec` median is within a few percent of the **scalar-libm** median at each N (confirms the asm-identity prediction; a large gap would mean the binaries differ in a way the asm didn't show — flag it).
- `scalar_poly` median is **below** scalar-libm (the inline poly is faster than the libm call).
- `scalar_poly → neon` ratio lands near 4× at 16k. If it is still materially above 4× with matched polynomials, that is a residual FMA/scheduling finding for §3 to frame — record it, do not treat it as a blocker.

## Out of scope

- Any commit to `site/`, any JSON, any chart component — the pilot is throwaway.
- Any change to demos 1–8 prose, code, or JSON.
- The formal demo-09 harness (`bench/demos/09-arm-neon/`) — that is §4, after §3.
- Re-running or disturbing the existing scalar-libm and NEON captures — they are in hand.
- The `bench/common/poly.h` shared-header decision and any change to demo 3 — deferred per the plan's open items.
- The methodology-page and machine-block-schema decisions — §4/§8.

## Open items for CC to flag

1. **Coefficient sharing.** If the NEON kernel's polynomial cannot be referenced by a scalar twin without hand-copying a second coefficient set (e.g. constants baked into intrinsic immediates), stop and report how you propose to share them rather than duplicating. Divergent coefficients make `scalar_poly` a different algorithm and defeat the width-isolation purpose.

2. **Autovec dispatch.** If `autovec` is not already in the pilot binary's `--variant` dispatch, wire it in. If wiring it in would perturb the existing scalar or neon binaries (changed flags, relinking that alters their codegen), stop and report rather than risk invalidating captures already in hand.

3. **Residual libm in scalar_poly.** If the `scalar_poly` hot loop still emits any `logf`/`expf`/`sqrtf@plt` call after 1a, the port is incomplete — stop and report. Do not measure a half-poly baseline; a baseline that still calls libm is the confound we are removing.

4. **Correctness regression.** If `scalar_poly` correctness comes in above 1e-4, the poly port has a bug — stop before timing.

## Notes for CC

Keep the existing pilot harness unchanged — 5 runs, median, FTZ-at-startup, correctness print, dispatch and reporting all as-is. `scalar_poly` slots into the same machinery; this is one variant added, not a harness change.
