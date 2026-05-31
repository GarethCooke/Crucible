# Crucible — Demo 09 pilot: scalar_poly baseline correction

Implementation brief for Claude Code (build + codegen verify) and the user (rig capture). **Supersedes the `scalar_poly` construction in `demo-09-arm-neon-pilot-addendum-brief.md`** — specifically its "zero libm calls in the hot loop" acceptance criterion, which produced a denominator that diverges from demo 3. Throwaway pilot work under `bench/pilot/09-arm-neon/`: no JSON, no chart, no commit to `site/`. Findings feed `demo-09-plan.md` §3.

## Context

The demo-3 baseline check (findings in-thread) established that demo 3's width-ratio denominator is `scalar_poly` built as: **`std::log` + `std::sqrt` (libm) + poly exp (`fast_expf`) + poly N(x) (`ncdf_poly`)**, single-element serial. Demo 3 reports its width win as `sse2 / scalar_poly` = 4.121× (1M) / 3.785× (16k), with libm log deliberately retained in the denominator.

The previous addendum built demo 9's `scalar_poly` with poly log too (zero libm calls). The tell that these are different constructions: demo 3's `scalar_poly` is **+11% faster** than `scalar_libm`, while demo 9's is **~12% slower** — opposite signs, because on the A76 the hand-poly `logf` Horner chain is slower than glibc's table `logf`, whereas on x86 the poly exp/N(x) swap is a net win. Same name, different denominator. For the §6 cross-arch comparison to be apples-to-apples, demo 9's width denominator must match demo 3's exact transcendental split.

Two changes: relabel the existing full-poly variant as a diagnostic, and build a new demo-3-spec `scalar_poly`.

Companion docs:

- `demo-09-arm-neon-pilot-addendum-brief.md` — the prior addendum this corrects.
- `demo-09-plan.md` — §6 (cross-arch ratio), §3 (the brief this feeds).
- `bench/demos/03-simd-blackscholes/scalar_poly.cpp` + `poly.h` — the construction to match.

No branch, no merge, no deploy. Pilot bench only.

## Tasks

### 1. Relabel the existing full-poly variant → `scalar_fullpoly` [CC]

The current `scalar_poly` (poly log + poly exp + poly N(x), zero libm calls) is kept as a diagnostic under the name `scalar_fullpoly`. No code change to its body — only the `--variant` label. Its captured medians (67.829 ns @ 16k, 72.690 ns @ 1M) stand as-is; **no re-capture required**, the binary is unchanged. Confirm the relabel does not perturb the `scalar_libm`, `neon`, or `autovec` binaries.

### 2. Build the new `scalar_poly` to demo-3 spec [CC]

Add `scalar_poly` matching `bench/demos/03-simd-blackscholes/scalar_poly.cpp`'s transcendental split exactly:

- `std::log` and `std::sqrt` — **libm**, called per element (not the poly log).
- exp — inline `fast_expf` polynomial (the same poly.h math demo 9 lifted from demo 3).
- N(x) — inline `ncdf_poly` polynomial.
- Single-element serial loop, one option per iteration, no unrolling, no multi-accumulator interleaving — mirror demo 3's `for (i…) C[i] = bs_call_poly(...)` structure.

Reuse the poly.h demo 9 already shares with demo 3; do not introduce a second coefficient set.

### 3. Verify codegen — acceptance inverts from the prior brief [CC]

Disassemble `price_scalar_poly` and post before any capture:

- `bl\s+.*logf@plt` is **present** (and `sqrtf@plt` as applicable) — libm log is retained, matching demo 3.
- No `expf@plt` and no `erff@plt` — exp and N(x) are the inline polynomials.
- Zero `.4s` ops (the `.2s` exp-bit-trick is fine); loop stride is one element (`add xN, xN, #0x1`).

### 4. Capture the new `scalar_poly` [user]

Pi rig, `pi-preflight.sh` green before and after, `taskset -c 3`:

- `--variant scalar_poly --n 16384`, 5 runs.
- `--variant scalar_poly --n 1048576`, 5 runs.

Record median ns/op and printed `max_abs_error` at each N.

## Acceptance

### scalar_poly codegen [CC, before capture]

- `logf@plt` present in `price_scalar_poly`; `expf@plt` and `erff@plt` absent.
- Zero `.4s`; stride one element.
- Posted to the thread before the user captures.

### scalar_poly correctness [user]

- Printed `max_abs_error` < 1e-4 at both N. (Libm log is more accurate than the poly log, so expect error ≤ the full-poly figure; a large regression means the exp/N(x) port has a bug.)

### Timing captured [user]

- `scalar_poly` (demo-3 spec) has a 5-run median at 16k and 1M.
- `scalar_fullpoly` retains its existing medians (67.829 / 72.690).

### Sanity checks (flags for §3, not gates)

- New `scalar_poly` median sits **between** `scalar_libm` and `scalar_fullpoly` in ns/op, and — mirroring demo 3's sign — is at or slightly faster than `scalar_libm` (poly exp/N(x) is the net win; libm log retained). If it lands the other side of `scalar_libm`, record it — the A76 exp/N(x) poly may behave unlike x86, which is itself §3 material.
- `neon / scalar_poly` (demo-3 spec) is the width ratio comparable to demo 3's 4.121× / 3.785×. Record it; the cross-arch delta vs demo 3 is §6 material, not a gate.

## Out of scope

- Any commit to `site/`, any JSON, any chart — pilot is throwaway.
- Any edit to demo 3 — code, JSON, or prose. (A possible one-line clarification to demo 3's width-attribution wording is a separate decision; not this brief.)
- The unrolled / throughput-bound baseline — ruled out: demo 3 is single-element serial, so demo 9 matches that class.
- The §3 implementation brief and the §6 chart decision — both wait on this.
- Changing or re-capturing `scalar_libm`, `neon`, `autovec`, or `scalar_fullpoly` — all in hand.

## Open items for CC to flag

1. **poly.h drift.** If demo 9's lifted poly.h has diverged from demo 3's (different coefficients or polynomial order for exp / N(x)), the new `scalar_poly` is not a true demo-3 analogue — stop and report the drift rather than proceeding. The denominators must share the same exp/N(x) math for the cross-arch ratio to mean anything.

2. **std::log codegen.** If the Pi toolchain inlines `std::log`/`std::sqrt` to something other than a libm-backed call (a builtin, a different routine), confirm the intent still matches demo 3 (libm-backed log in the denominator). If the codegen diverges from demo 3's in a way that changes the log implementation, flag it before capture.

3. **Correctness regression.** If `max_abs_error` exceeds 1e-4, the exp/N(x) port has a bug — stop before timing.
