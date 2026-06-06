# Demo 06 re-derivation patch brief — boost-off recapture

Branch: `feature/boost-off-recapture`. Scope: `content/posts/06-aos-vs-soa.mdx` plus archiving the pre-recapture JSON. No bench-code change, no chart-component change, no recapture.

## Context

Demo 06 recaptured 2026-06-05 at verified base clock. The post's anchor cells are exceptionally stable across captures (SoA K=1 at N=1M: 0.7699 ns in both; autovec ratios identical), so this is a numeric patch — single-rounding-step edits — plus one paragraph rework: the shipped "DRAM band is non-monotonic … a real signal rather than measurement noise" claim does not reproduce (the dip at N=262k/524k flattened to ~5.3 ns), and is reframed using both captures per the demo-05 precedent. Clock forensics: old capture (2026-05-23) at base clock; deltas in stable cells ≤1%.

## Pre-flight sentinel (abort on mismatch)

`06-aos-vs-soa.json`: `captured_at == "2026-06-05T06:09:35Z"`, `turbo:false`, `turbo_source:"cpb"`, `freq_max_available_mhz:3900`. Cell `aos-scalar, n=1048576, k=1` median == `5.3656`; `soa-scalar, n=1048576, k=1` median == `0.7699`.

## Task 0 — archive the pre-recapture JSON

Add `site/src/data/perf/archive/06-aos-vs-soa_2026-05-23.json` (the old file, byte-identical). The rewritten DRAM-band paragraph cites the May capture's values; they must trace to committed data. Archive only — not chart-loaded.

## Task 1 — cliff ratio (line 93)

Find: `L2-resident floor 1.31 → DRAM band 5.37 = **4.11× cliff**.`
Replace: `L2-resident floor 1.31 → DRAM band 5.37 = **4.08× cliff**.`

(Derivation: 5.3656 / 1.3135 = 4.085.)

## Task 2 — DRAM-band paragraph (line 95, full replacement)

Find the paragraph beginning `The DRAM band is non-monotonic — N = 262 144 lands at 4.17 ns,` and ending `…not as a clean rising line.`

Replace with:

```
The DRAM band has capture-dependent structure. In this capture it is nearly flat —
N = 262 144 at 5.36 ns, N = 524 288 at 5.32 ns, N = 1 048 576 at 5.37 ns. The May
capture of the same code showed a pronounced dip instead: 4.17 and 3.99 ns at the
two middle points, with within-capture IQR/median of at most 1.7% — tight enough
that, read alone, the dip looked like a real microarchitectural signal. The
recapture says otherwise: a clean rebuild and reboot later, the dip is gone. The
likely mechanism is the one that makes it non-reproducible — page placement and
transparent-huge-page promotion are decided per process at allocation time, and
TLB reach and DRAM bank parallelism follow from that draw. Within-capture
tightness is not across-capture stability. None of this touches the cliff: the
band should be read as "above L3 capacity, AoS-K=1 costs roughly 4–5.5 ns/element,
with structure inside that band that belongs to the capture, not the code," and
the N = 1 048 576 anchor itself is capture-stable at 5.37 ns.
```

## Task 3 — headline ratio blockquote (line 111)

Find: `> **AoS K=1 / SoA K=1, N = 1 048 576: 6.98×**`
Replace: `> **AoS K=1 / SoA K=1, N = 1 048 576: 6.97×**`

(Derivation: 5.3656 / 0.7699 = 6.969.)

## Task 4 — K-sweep table (lines 147–153)

Find:

```
| 1   | 5.37        | 0.77        | **6.98×** | 8.00×               |
| 2   | (cliff)     | (sub-L3)    | 3.37×     | 4.00×               |
| 4   | (cliff)     | (cliff)     | 1.31×     | 2.00×               |
| 8   | 6.49        | 6.30        | 1.03×     | 1.00×               |
| 16  | 12.63       | 12.62       | 1.00×     | 1.00×               |
```

Replace:

```
| 1   | 5.37        | 0.77        | **6.97×** | 8.00×               |
| 2   | (cliff)     | (sub-L3)    | 3.38×     | 4.00×               |
| 4   | (cliff)     | (cliff)     | 1.31×     | 2.00×               |
| 8   | 6.55        | 6.30        | 1.04×     | 1.00×               |
| 16  | 12.60       | 12.61       | 1.00×     | 1.00×               |
```

(Derivations: K=2 5.2751/1.5615? — CC: re-derive each ratio from the JSON medians directly; expected values 3.38, 1.31, 6.5454/6.2987 = 1.04, 12.6019/12.6107 = 1.00.)

## Task 5 — autovec bullets (line 175)

Find: `- **K = 16, DRAM-saturated**: SoA scalar 12.62 ns/element; SoA autovec 5.01 ns. Speedup **2.52×**.`
Replace: `- **K = 16, DRAM-saturated**: SoA scalar 12.61 ns/element; SoA autovec 4.99 ns. Speedup **2.53×**.`

(Derivation: 12.6107 / 4.9883 = 2.528. The K=1 bullet — 0.77 / 0.19 / 3.99× — re-derives unchanged; do not edit.)

## Task 6 — footer isolation

Find: `cores 0–7 isolated (core 0 carries unavoidable kernel housekeeping)`
Replace: `cores 1–7 isolated (cpu0 cannot be kernel-isolated and carries housekeeping)`

## Task 7 — frontmatter date

`date: "2026-05-24"` → `date: "2026-06-05"`.

## Acceptance

1. Archive file exists, byte-identical to the old JSON.
2. `grep -c '6\.98×\|4\.11×\|3\.37×\|1\.03×\|5\.01 ns\|2\.52×'` → 0; `grep -c '6\.97×'` → 2 (blockquote + table).
3. `grep -c 'real signal rather than measurement noise'` → 0; `grep -c 'capture-dependent structure'` → 1; `grep -c 'Within-capture tightness'` → 1.
4. `grep -c '4\.17'` → 1 (inside the rewritten paragraph, attributed to the May capture only).
5. `grep -c 'cores 0–7'` → 0; `date:` reads 2026-06-05.
6. LLC bullets (~0.23, ~0.0022, ~100×) and the 0.77/0.19/3.99× anchors are untouched — `git diff` shows no edits to those lines.
7. `npm run build` clean; all four charts render (data-driven, no component edits).

## Out of scope

- `l1d_misses_per_op` is null in all 135 runs of both captures while LLC is populated — the prose never cites it, so no claim is affected, but the schema carries a dead field. Route to the standing capture-hardening brief (fix the event or drop the field), not this patch.
- Chart components and `<Benchmark>`/`<TimeVsN>` blocks.
- The "What this doesn't show" bullets — re-checked, accurate, untouched.
- Other demos, methodology page, correction note.

## Open items

1. The DRAM-band rework is the second instance (after demo 05) of the within-capture-variance ≠ across-capture-stability lesson — strengthens the case for the proposed hostile-cross-read skill check (exact ties / fine structure require multi-capture support).
2. Clock forensics: base clock confirmed for the old capture; pattern now consistent across all six audited demos. Correction-note input.
