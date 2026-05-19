# Crucible — `ns_per_op` units fix brief

**Pre-demo-5 brief 1 of 9. Priority: ship first — fixes a visible factual bug on demo 01's live page.**

---

## 1. Context

Demo 01's headline `<ThroughputBars>` chart currently renders as (live screenshot, 2026-05-19):

- Branchless: `22,688,279.66 ns/op`
- Sorted: `18,549,246.33 ns/op`
- Unsorted: `123,807,593.08 ns/op`

These are eight-digit pass-times over N = 33,554,432 elements being displayed as per-operation times. The target audience (hedge-fund / cap-markets perf engineers) spots this in two seconds; for a v1 portfolio demo this is the most acutely embarrassing kind of bug.

Root cause is a unit divergence inside a single JSON file. In `bench/scripts/assemble_results.py:84`:

```python
"ns_per_op": bench_stats(times),   # times = [r["real_time"] for r in reps]
```

Google Benchmark's `real_time` is per-outer-iteration — one full pass over all N elements. No division by N occurs anywhere in this code path. Yet inside the same script (line ~68), `sort_cost_32m.ns_per_op` **does** divide by `sort_n = 33554432`, so it's genuinely per-element. The same `01-branch-prediction.json` therefore contains two `ns_per_op` keys with different units differing by ~33M×.

The bug is masked in one chart and amplified in another:

- `TimeVsNChart.tsx` silently compensates — its render path divides by N at display time:

  ```ts
  const nsPerElem = (r: TimeVsNRun) =>
    (r.ns_per_op[stat] ?? r.ns_per_op.median) / r.n;
  ```

  Whoever authored TimeVsN knew the JSON values were per-pass and applied the correction at consume time. Once the JSON is fixed in source, this compensation will produce values 1/N too small — fixing one bug creates another.

- `ThroughputBarsChart.tsx` trusts the field at face value, using `ns_per_op[stat]` directly with the label `"ns/op"`. This is what's producing the absurd live numbers.

Demo 02's path (`tools/parse_perf.py:96`) correctly divides by `ops_per_iter`, so its `ns_per_op` is per-element. Demos 03/04 use `assemble_results_03.py` / `assemble_results_04.py` — assumed-but-unverified to share the same defect. Cross-demo audit is part of the fix (§6).

The schema intent in `BRIEF.md` was always per-element (`"ns_per_op": { "median": 1.21, ... }`). `assemble_results.py` drifted from that intent silently — the headline-grade portfolio demo has been shipping with eight-digit "ns/op" values since the harness was patched.

---

## 2. Goals

- `runs[*].ns_per_op` in every demo's site-facing JSON is per-element nanoseconds, consistent with `sort_cost_32m.ns_per_op` and demo 02's `parse_perf.py` semantics.
- `<ThroughputBars>` on demo 01 displays sensible single-digit ns/op values.
- `<TimeVsN>` on demo 01 renders the same curve shape as before the fix (compensation removed at display, equal correction applied at source — net unchanged).
- No chart silently compensates for upstream unit ambiguity anywhere in the codebase.

---

## 3. Patch `bench/scripts/assemble_results.py`

Single-line change at line 84:

```python
# BEFORE:
"ns_per_op": bench_stats(times),

# AFTER:
"ns_per_op": bench_stats([t / n for t in times] if n > 0 else times),
```

The `n > 0` guard is defensive — if `n` failed to parse from the benchmark name, the fallback preserves current behaviour rather than crashing. Demo 01's benchmark naming follows the `BM_XXX/N` pattern that `parse_bench_name()` handles, so `n` will always parse and the fallback is never reached for demo 01.

Note that `ops_per_sec` is already computed correctly elsewhere in `assemble_results.py` (the live screenshot's throughput numbers, if displayed, are correct). Confirm no second adjustment is needed — `ops_per_sec` may currently be computed as `1e9 / median_ns × n` to back out from per-pass to per-element rate; once `ns_per_op` is per-element, `ops_per_sec` should become `1e9 / median_ns` (no `× n`). Read the surrounding code and adjust so the round-trip identity `ops_per_sec × ns_per_op_median / 1e9 ≈ 1` holds in the new JSON.

---

## 4. Patch `site/src/components/charts/TimeVsNChart.tsx`

Remove the compensation. Locate the line:

```ts
const nsPerElem = (r: TimeVsNRun) =>
  (r.ns_per_op[stat] ?? r.ns_per_op.median) / r.n;
```

Replace with:

```ts
const nsPerElem = (r: TimeVsNRun) => r.ns_per_op[stat] ?? r.ns_per_op.median;
```

The helper name can stay (`nsPerElem`) — the _physical meaning_ of the value is now per-element, which is what the helper claims. Likewise the y-axis label "ns per element" in the chart should stay. The change is purely that the per-element value now arrives correctly from the JSON rather than being computed at display time.

Also remove the comment `// Y values: ns per element = ns_per_op[stat] / n  (per-element cost)` since it no longer reflects the implementation.

---

## 5. Re-capture demo 01

The raw Google Benchmark JSON output (input to `assemble_results.py`) was in `/tmp/` and has since been cleared. Re-running the assembler over old raw output is not possible; demo 01 must be re-captured end-to-end.

```bash
./bench/scripts/run_one.sh 01-branch-prediction
```

Sanity-check the new JSON before committing. Per-element values should land roughly:

| variant    | N=32M        | rough order                            |
| ---------- | ------------ | -------------------------------------- |
| Sorted     | ~0.5–1 ns/op | bandwidth-bound, predictor learned     |
| Branchless | ~0.5–1 ns/op | branchless `cmov`, no predictor needed |
| Unsorted   | ~3–5 ns/op   | ~50% miss rate × ~15-cycle penalty / N |

These are sanity bounds, not assertions — actual numbers will vary with the post-`crucible-cc-brief-fix-01-branch-prediction.md` configuration (function-level `no-tree-vectorize`, `no-if-conversion`). The hard check is the round-trip identity (§7).

Pre-capture preconditions remain as documented elsewhere:

- `CRUCIBLE_TURBO=off` exported, verified via `cpupower frequency-info`
- Boot under the benchmark GRUB entry (governor=performance, `isolcpus=0-7`, SMT off)
- `setcap cap_perf_event=ep` on the binary if `perf_event_paranoid` is not relaxed

---

## 6. Cross-demo audit

The same defect may exist in `assemble_results_03.py` and `assemble_results_04.py`. Before declaring this brief done, read each and confirm whether the `bench_stats(times)` pattern is present without a divide-by-N.

| demo | assembler path                     | status to confirm                                |
| ---- | ---------------------------------- | ------------------------------------------------ |
| 01   | `assemble_results.py` (this brief) | patched + re-captured                            |
| 02   | `tools/parse_perf.py`              | already correct (`/ ops_per_iter`); no action    |
| 03   | `assemble_results_03.py`           | **read; patch if needed; re-capture if patched** |
| 04   | `assemble_results_04.py`           | **read; patch if needed; re-capture if patched** |

If 03 has the same defect: its primary chart is `<ThroughputBars>` showing scalar / SSE2 / AVX2 / AVX2+FMA at fixed N=1M. The bug would inflate displayed `ns/op` by 1M×. Visual inspection of the live demo 03 page is the fast check — if the numbers look reasonable now (sub-30 ns/op for SIMD variants), 03 is fine; if they're millions, 03 has the same bug.

If 04 has the same defect: demo 04's primary chart is `<LatencyVsLoad>` consuming `latency_ns.stats` (a different field), so the visible-bug risk is lower. But any `ns_per_op` field in 04's JSON would be wrong and should still be fixed.

Apply the same patch and re-capture each affected demo. Treat each as a sub-task with its own JSON-diff verification.

---

## 7. Acceptance checklist

- [ ] `bench/scripts/assemble_results.py:84` divides by `n` (with the `n > 0` guard).
- [ ] `ops_per_sec` computation in `assemble_results.py` adjusted if it previously back-computed using N (round-trip identity must hold; see below).
- [ ] `site/src/components/charts/TimeVsNChart.tsx` no longer divides by `r.n` at display time; stale comment removed.
- [ ] Demo 01 re-captured under the standard preconditions; new `01-branch-prediction.json` committed.
- [ ] Round-trip identity holds per row in the new JSON: `runs[i].ops_per_sec × runs[i].ns_per_op.median / 1e9` ∈ [0.999, 1.001].
- [ ] Live demo 01 `<ThroughputBars>` chart labels show single-digit `X.XX ns/op` for all three bars.
- [ ] Live demo 01 `<TimeVsN>` chart curve shape qualitatively unchanged from pre-fix screenshot (sorted ≈ branchless flat at low end, unsorted gap widens then narrows at largest N).
- [ ] `sort_cost_32m.ns_per_op` annotation (already per-element, ~30 ns) still displays correctly wherever surfaced.
- [ ] `assemble_results_03.py` audited; patched and demo 03 re-captured if defect present.
- [ ] `assemble_results_04.py` audited; patched and demo 04 re-captured if defect present.
- [ ] `grep -E "ns/?op|nanosec" site/src/posts/01-branch-prediction.mdx` — any quoted figures reconciled against new JSON (qualitative claims like "~6× difference" verified against actual ratio; specific numbers updated if shifted).
- [ ] Captured-at timestamp(s) in re-captured JSON(s) updated.

---

## 8. Out of scope

- Other pre-demo-5 bench findings (C2 sweep drift, M3/M4 preflight checks, DRY cleanup, etc.) — separate briefs.
- Field rename (`ns_per_op` → `ns_per_element`) — name is fine once units are consistent.
- Adding a programmatic invariant check (`sanity_check.py` round-trip assertion) — could be added later; not blocking.
- Updating post 01 prose structure or framing — only number reconciliation is in scope; prose rewrite is a separate concern if needed after the new numbers land.
