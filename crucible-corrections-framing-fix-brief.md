# Crucible — methodology Corrections section, framing fix

CC brief, branch `feature/boost-off-recapture`. The Corrections section was added to `site/src/app/methodology/page.tsx` (~lines 483–559, dated 2026-06-06) with a framing that the re-derivation results have since contradicted. This brief replaces that section's body with evidence-supported wording. **Commitment #2 (Part A, ~250–289) is correct and must not be touched** — it describes present-tense mechanism and makes no historical claim.

## Context

The current Corrections text states the original corpus was "captured with AMD Core Performance Boost **enabled**." The recapture disproved that: figures round-trip to within 1% of the originals, with compute-bound demos (01, 03, 08) reproducing exactly. For compute-bound work, ns/op scales near-linearly with clock — an exact round-trip at a confirmed 3900 MHz means the originals were already at base clock, so boost was _not_ effectively engaging. The defensible claim is that boost state was **unverified** (the `machine.turbo` field was an env-var echo, and the committed `lscpu` 4560 ceiling is cosmetic on this `acpi-cpufreq` board — it neither confirmed nor refuted the claim), and that re-verification at a confirmed base clock shows the published numbers were accurate. The note must not assert boost was enabled (unsupported) — a correction note containing an unsupported claim undermines its own purpose.

## Task

Replace the body of the `<h2 id="corrections">` section with the prose below, preserving the heading, its `id`, the date, and the surrounding JSX structure. Slot the paragraphs into the existing component shape.

> **2026-06-06 — Boost-state verification in the original Machine 1 corpus.**
>
> The benchmarks for demos 01–08, as originally published, carried a `machine.turbo` field that was not a real measurement: it was echoed from an operator-set environment variable (`CRUCIBLE_TURBO`) rather than read from hardware, so the corpus's boost state was in effect unverified. The `lscpu` output committed alongside each result showed the 4560 MHz boost _ceiling_ — but on this AMD `acpi-cpufreq` board that ceiling is reported whether or not boost is active, so it neither confirmed nor refuted the "turbo off" claim.
>
> We rebuilt boost detection to read real kernel sysfs signals (the per-CPU `cpb` flag, cross-checked against the available-frequency list), added a hard capture-time gate that aborts if boost is enabled, and recaptured the entire Machine 1 corpus at a confirmed 3900 MHz base clock.
>
> **Effect on results.** The recaptured figures round-trip to within 1% of the originals — the compute-bound demos (01, 03, 08) reproduce exactly — which confirms the original captures were already running at base clock and the published numbers were accurate. The same-session speedup ratios each post is built on were unchanged throughout. Two posts, demos 04 and 06, required prose corrections unrelated to clock — [FILL: one-line summary of the demo-04 correction; one-line summary of the demo-06 correction] — while their underlying ratios were intact. Demo 02's L1 cache counter (`l1d.replacement`) returned null in all twelve original runs and was never cited in the post; the recapture substitutes `L1-dcache-load-misses`, with no numeric impact.
>
> The raw `lscpu` capture committed with every result is what made this auditable: the underlying data was honest even where the derived field was not. The detection logic that replaced it is described under Turbo Boost disabled (`#commitments`) above.

## Acceptance

- The Corrections section no longer asserts boost was enabled: `grep -i "boost.*enabled" site/src/app/methodology/page.tsx` returns only the capture-gate mention in commitment #2 ("aborts if boost is detected as enabled"), not a historical claim about the corpus.
- The section contains the round-trip-within-1% statement and the "already running at base clock / published numbers were accurate" conclusion.
- The demo-04 and demo-06 one-line corrections are filled (not left as `[FILL]`), and the demo-02 null-counter sentence is present.
- `<h2 id="corrections">`, the 2026-06-06 date, the forward reference to `#commitments`, and the surrounding structure are intact.

## Out of scope

- Commitment #2 (Part A) — correct as-is, do not edit.
- The JSON data, the demo posts themselves (the 04/06 prose fixes are their own already-landed changes), and the branch merge.

## Open items for CC to flag

- The `[FILL]` summaries for demos 04 and 06 must come from those demos' re-derivation patch briefs / findings — pull the actual corrections, do not invent them. If the specifics aren't to hand, flag and leave a precise marker rather than guessing.
