# Crucible — `bench/common/poly.h` split (post-ship stub)

**Status: stub.** Flesh out at execution time. Do **not** run before demo 9 ships (§11) — demo 3 is a live dependency of in-flight demo 9 work until then, and this refactor touches it.

## Context

Demos 3 and 9 share the Black-Scholes transcendental polynomials. Demo 9's bench currently reaches them via a cross-demo relative include of demo 3's `poly.h` (`../03-simd-blackscholes/poly.h`). Two problems:

1. **Invisible coupling.** Demo 9's build depends on demo 3's directory layout; a future demo-3 refactor breaks demo 9 with no signal from demo 3's side. (Mitigated for now by a visibility comment added in the demo-3 batched edit — but visibility is not decoupling.)
2. **Mixed concerns.** `poly.h` bundles genuinely shared math (`fast_expf`, `fast_logf`, `ncdf_poly`) with per-demo flop-accounting constants (the scalar-vs-SIMD flops/option split). Promoting the file wholesale would bless demo-3-specific accounting as "common," which is its own small dishonesty.

The clean fix is a **split**, not a move: shared polynomials to a real common home, accounting stays local.

## Intended tasks (refine at execution)

1. Create `bench/common/poly.h` containing only the shared transcendental polynomials and their coefficients.
2. Leave per-demo flop-accounting / kernel-specific constants in each demo's own bench.
3. Update include paths in demo 3 **and** demo 9 to the common header; remove the cross-demo relative include and the visibility comment it replaced.
4. Confirm both demos still build under their respective targets (`-mcpu=cortex-a76` for demo 9; demo 3's x86 flags).

## Acceptance (the gate that makes touching two shipped demos safe)

- Variant binaries for **both** demos are asm-identical before and after, address-normalised — zero behavioural change. (`scalar_poly`, `sse2`, `avx2fma` for demo 3; `scalar_libm`, `scalar_poly`, `autovec`, `neon` for demo 9.)
- Both demos' committed JSON is unchanged; **no recapture** of either.
- No coefficient or polynomial-order change in the move — a pure relocation.

## When

Post-§11, as a standalone refactor with its own review. Not bundled into any demo's feature work.
