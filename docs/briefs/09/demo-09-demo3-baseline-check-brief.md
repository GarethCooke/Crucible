# Crucible — Demo 09 §3 precondition: demo 3 scalar-baseline check

Investigation brief for Claude Code. **Read-only — no edits to any demo, no commits.** CC reads demo 3's bench, JSON, and MDX, classifies its scalar baseline, and posts findings to the thread. Opus uses the findings to decide whether demo 9 needs an unrolled `scalar_poly` variant before §3 commits a headline. Self-contained; blocks `demo-09-plan.md` §3.

## Context

Demo 9's pilot addendum surfaced that none of its three scalar baselines yields a clean ~4× width ratio against hand-NEON: scalar-libm uses a fast table-log (different algorithm), autovec is byte-identical to scalar-libm, and the matched-polynomial `scalar_poly` is latency-bound (an 8-deep serial Horner chain), so it runs below its own throughput ceiling and the ratio overshoots to 5.1–5.4×. The architectural width ceiling is ~4×; the overshoot is baseline inefficiency, not width.

To land a clean measured ~4×, demo 9 would add an unrolled `scalar_poly` (independent accumulators, throughput-bound). Whether to do that depends entirely on **how demo 3 built and reported its own scalar baseline** — the `demo-09-plan.md` §6 cross-arch comparison (Pi NEON ratio vs Zen 2 AVX2 ratio) is only honest if both demos measure the same kind of ratio against the same kind of baseline. Matching demo 3 matters more than reaching a purer number in demo 9 alone.

This brief answers that question and nothing else.

Companion docs:

- `demo-09-plan.md` — §6 (cross-arch ratio view), the width-ceiling thesis, the demo 3 cross-link.
- `demo-09-arm-neon-pilot-addendum-brief.md` — the addendum whose results raised this.

## Findings to report

Read demo 3's artefacts (bench under `bench/demos/03-*/`, JSON under `site/src/data/perf/03-*.json`, post under `site/src/posts/03-*.mdx`). For each item, report with file path and, where it's a number or a claim, the exact value or a short quote.

### 1. Scalar baseline construction

- Where is demo 3's scalar baseline kernel, and is its math the **same Black-Scholes call-pricing kernel** as demo 9 (same transcendentals: log, exp/erf, sqrt), or a different workload?
- Does the scalar baseline use **libm** transcendentals (`expf`/`logf`/`erff`) or an **inline polynomial**?
- Is the scalar loop **single-element serial**, or **unrolled / multi-accumulator** (i.e. does it process several independent elements per iteration with separate accumulator chains)?
- Classify it: **latency-bound** (a single serial dependency chain, like demo 9's `scalar_poly`) or **throughput-bound** (independent chains interleaved so the FP units stay busy). If the source alone doesn't settle this, build the demo 3 bench in a **scratch directory** and `objdump` the scalar baseline — look for a serial Horner chain (each `fmadd`/`mulps`+`addps` reading the previous result) vs interleaved independent accumulators. Report the evidence either way.

### 2. Reported ratios and their denominator

- What speedup numbers does demo 3 report (scalar→SSE, SSE→AVX2, scalar→AVX2)? Pull them from the JSON, not the prose.
- Which variant is the **denominator** for each ratio (i.e. what is "1×")?
- Confirm they are **within-machine** ratios (no cross-machine absolute comparison).

### 3. How the post frames the width claim

- Does demo 3 make a width-ceiling / "this is what the unit gives you" style claim, and against which baseline? Quote the relevant sentence (keep it short).
- Note whether the ~4× SSE-over-scalar figure (referenced in `demo-09-plan.md`) is stated against the libm scalar, an inline-poly scalar, or an unrolled scalar.

### 4. Methodology parity

- Does demo 3 set x86 flush-to-zero (`_MM_SET_FLUSH_ZERO_MODE` / `_MM_SET_DENORMALS_ZERO_MODE`), the analogue of demo 9's FPCR FZ bit?
- Same N-sweep style and repetitions convention as the demo 9 pilot (cache-resident N for the headline, ≥5 reps, median)?
- Anything else that would make the two demos' ratios methodologically non-comparable beyond the baseline question.

## Decision rule (why these findings matter — for context, not for CC to act on)

- If demo 3's scalar baseline is **throughput-bound / efficient** → demo 9 adds an unrolled `scalar_poly` so its headline ratio is measured against the same kind of baseline (expected ~4×).
- If demo 3's scalar baseline is **naive (libm or single-element serial)** → demo 9 matches that baseline and both demos carry the same caveat about the observed ratio being baseline-dependent.

CC does not make this call — it reports the findings and stops.

## Acceptance

- Each of items 1–4 answered with a file path and, where applicable, the exact JSON figure or a short quoted sentence from the MDX.
- The scalar baseline is classified latency-bound vs throughput-bound with stated evidence (source structure, and `objdump` of a scratch build if source was ambiguous).
- No file under `bench/demos/03-*/`, `site/src/data/perf/03-*.json`, or `site/src/posts/03-*.mdx` is modified; `git status` is clean apart from any scratch build directory, which is not committed.

## Out of scope

- Any edit to demo 3 — code, JSON, or prose. Read-only.
- Any edit to demo 9 or its pilot bench.
- Building the unrolled `scalar_poly` variant — that is a follow-up addendum, decided after these findings.
- Touching the committed demo 3 build artefacts; any rebuild for `objdump` goes in a scratch directory and is discarded.
- The §3 brief itself, and the §6 chart decision — both wait on this.

## Open items for CC to flag

1. **Bench not where expected.** If demo 3's bench is not under `bench/demos/03-*/` or is structured differently than demos 5–8, report where it actually lives rather than guessing — do not infer the baseline from the MDX alone.

2. **Kernel mismatch.** If demo 3's workload is a materially different kernel from demo 9's Black-Scholes (different transcendentals, different N regime), flag it prominently — that is a larger §6 comparability problem than the baseline question, and Opus needs to know before §3.

3. **Ambiguous classification.** If source inspection cannot settle latency- vs throughput-bound, do the scratch `objdump` rather than reporting "unclear" — the classification is the load-bearing output of this brief.
