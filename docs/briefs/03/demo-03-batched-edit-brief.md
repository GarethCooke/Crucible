# Crucible — Demo 03 batched edit (drop at demo 9 §8/§9)

Implementation brief for Claude Code. Three small edits to the shipped demo 3, batched into **one reviewed touch** rather than three drive-bys. Lands when demo 3 is getting its forward-link to demo 9 anyway (demo 9 §8/§9). Each edit is independently gated; none changes demo 3's measured numbers or its compiled bench.

## Context

Demo 9 (ARM NEON, the cross-arch sibling) accumulated three small changes that all land in demo 3:

1. **Arch backfill** — the demo 9 §6 cross-arch ratio ladder compares the Pi (A76) against the Zen 2 rig and pulls each arch's identity from the JSON `machine` block. Demo 9's block now carries an `arch`/`soc` field; demo 3 needs the same so the ladder's Zen 2 rung is labelled from data, not hardcoded in the chart.
2. **Forward-link** — the plan's §8 calls for a link from demo 3 to demo 9 (the same kernel on a different ISA; the width-ceiling contrast is the spine of the pairing). Demo 3 already back-links nothing to demo 9 (demo 9 didn't exist when it shipped).
3. **Coupling comment** — demo 9's bench includes demo 3's `poly.h` via a cross-demo relative include. That coupling is currently invisible from demo 3's side. A one-line comment makes it visible so a future demo-3 refactor knows demo 9 depends on the header. (The proper fix — splitting shared math into `bench/common/poly.h` — is a separate post-ship refactor; this is only the visibility mitigation.)

These touch a shipped demo, so each carries a gate that proves no behavioural change.

Companion docs: `demo-09-plan.md` (§6 ladder, §8 cross-links); `09-arm-neon-brief.md` (the demo 9 implementation brief, machine-block field, chart set).

## Tasks

### 1. Arch backfill — `site/src/data/perf/03-simd-blackscholes.json` [CC]

Add `arch` and `soc` to demo 3's `machine` block, **mirroring demo 9's exact field names and value conventions** (read `09-arm-neon.json`'s machine block first and match casing/format — e.g. if demo 9 uses `"arch": "aarch64"`, demo 3 uses `"arch": "x86_64"`; if `"soc"` carries a model string, match the style). Additive only — touch nothing else in the block, no `ops_per_sec`, no ratios.

### 2. Forward-link — `site/src/posts/03-simd-blackscholes.mdx` [CC, wording from §8 draft]

Insert a single forward-link to demo 9 at the natural spot — the closing/related section, or where demo 3 discusses the SSE→AVX2 width steps (the contrast demo 9 completes). Suggested sentence (adjust to demo 3's voice in the §8 pass):

> The same kernel on a Cortex-A76 — 128-bit NEON, no wider unit to reach for — is in [demo 9](…), where the width ceiling has no second step.

One link, minimal prose. Do **not** reword demo 3's existing width-attribution (that is the separate §9 decision — see Out of scope).

### 3. Coupling comment — demo 3's `poly.h` [CC]

Add one comment line near the top:

> `// Also consumed by bench/demos/09-arm-neon (cross-demo include). See demo-09 plan; a bench/common/ split is the tracked post-ship fix.`

Comment only. No code, no coefficient, no accounting change.

## Acceptance

- **JSON (task 1):** `03-simd-blackscholes.json` validates against the schema with the new fields; every `ops_per_sec` and every derivable ratio is byte-unchanged from before the edit (diff shows only the two added metadata lines). Field names/values match `09-arm-neon.json` exactly.
- **Bench unchanged (tasks 1 + 3):** demo 3's variant binaries (`scalar_libm`, `scalar_poly`, `sse2`, `avx2fma`) are asm-identical before and after — the JSON is data and the `poly.h` change is a comment, so codegen must not move. Confirm by `objdump` diff (address-normalised) on at least `scalar_poly` and `avx2fma`.
- **MDX (task 2):** the post renders; the demo 9 link resolves; no other prose changed (diff is the single inserted link sentence).
- **No recapture:** because the binaries are identical, demo 3's committed numbers stand — do not re-run demo 3's harness.

## Out of scope

- **Demo 3's width-attribution wording.** Its MDX attributes the >4× SSE ratio to "loop-overhead and pipeline-fill" without isolating the libm-log→poly-log swap in its `scalar_poly` denominator. Whether to clarify that is the demo 9 §9 hostile-cross-read decision — **not** this brief. Do not touch that sentence here.
- **The `bench/common/poly.h` split.** Post-ship refactor, separate stub brief. This brief only adds the visibility comment.
- **Backfilling arch/soc into demos 1–2, 4–8.** Not needed — demo 3 is the only cross-arch comparand. A full backfill is a future tidy if §9 flags the asymmetry.
- Any change to demo 3's coefficients, kernel, or flop accounting.

## Open items

1. **Field-name drift.** If demo 9's machine block turns out to use field names or value formats that read awkwardly for x86 (e.g. a field that only makes sense for the Pi), flag it before backfilling — better to fix the schema field once than to populate demo 3 with an ill-fitting value.
2. **Link target.** If demo 9's published slug differs from `09-arm-neon`, use the actual slug; confirm against the shipped route before merging the link.
