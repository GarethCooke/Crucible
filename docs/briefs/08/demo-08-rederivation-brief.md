# Demo 08 re-derivation patch brief — boost-off recapture

Branch: `feature/boost-off-recapture`. Scope: `content/posts/08-sorting-shootout.mdx` plus archiving the pre-recapture JSON. No bench change, no recapture.

## Context

Recaptured 2026-06-05 at verified base clock. Headline results are capture-stable (5× at 67M, 1.9× vs pdqsort, 0.75 ns sorted-input, the full u64 section). Two problems: (1) the "window where radix loses" section — radix's 4K–8K bump with an explicit "this isn't noise" capacity explanation — does not reproduce: radix at 4K moved 23.1 → 6.7 ns/element, the window is gone, and N=1024 moved +35% the other way. The small-N radix band is placement-sensitive, not capacity-deterministic; the section is rewritten on both captures (demo 06 precedent), old JSON archived. (2) Radix's sorted/reverse worst-case drifted +9–11%, moving three derived figures one step.

Clock forensics: old capture (2026-05-29) at base clock — stable cells (std_sort, pdqsort, radix ≥16K) agree to ≤1%.

## Pre-flight sentinel (abort on mismatch)

`08-sorting-shootout.json`: `captured_at == "2026-06-05T06:18:37Z"`, `turbo:false`, `turbo_source:"cpb"`, `freq_max_available_mhz:3900`. Cells (random u32): `std_sort, n=67108864` == `74.18`; `radix_lsd, n=67108864` == `15.38`; `radix_lsd, n=4096` == `6.67`.

## Task 0 — archive the pre-recapture JSON

Add `site/src/data/perf/archive/08-sorting-shootout_2026-05-29.json` (byte-identical). Tasks 2–3 cite May values.

## Task 1 — cache-knee paragraph cross-reference (~line 61)

Find: `so it hits the lower tiers earlier than the markers suggest — that's the bump just left of the L1 band in the next paragraph.`
Replace: `so it hits the lower tiers earlier than the markers suggest — that's the placement-sensitive band just left of the L1 marker discussed in the next paragraph.`

## Task 2 — replace "The window where radix loses" paragraph (~line 63, full replacement)

Find the paragraph beginning `**The window where radix loses.** Look between 4,000 and 8,000 elements:` and ending `…radix is back on the floor and stays there.`

Replace with:

```
**The window where radix loses — sometimes.** The May capture of this exact code
showed radix bumping to ~19–23 ns/element between 4,000 and 8,000 elements while
`pdqsort` dipped to ~16–18 and briefly won, and the capacity arithmetic looked
clean: radix ping-pongs two n-element arrays, so at ~4 K keys the doubled footprint
is 32 KB — exactly the L1 data cache — while the in-place comparison sorts cross
that boundary at twice the element count. Then the recapture removed the window. A
rebuild and a reboot later, radix at 4 K–8 K sits at 6.7–7.3 ns/element, on the
floor, beating `pdqsort` by ~2.5×; meanwhile its N = 1 024 cell moved 35% in the
other direction between the same two captures. Capacity arithmetic predicts a
deterministic effect; two captures of identical code show a placement-dependent
one. The doubled footprint puts radix *at* the L1 boundary in that band, but
whether it pays there is decided by where the allocator and transparent huge pages
put the two buffers — a conflict between source and destination lines is an
address property, not a size property, and the address draw changes per process.
The honest statement of the trade: O(n) auxiliary memory buys the linear cost,
and in the capacity-critical band below ~16 K elements it exposes radix to
placement luck the in-place sorts don't face — costing anywhere from nothing to
a brief loss to `pdqsort`, depending on the draw. Above ~16 K both captures agree
to within a few percent and radix is on the floor for good.
```

## Task 3 — distribution figures (~lines 80–90)

Find: `it sorts already-sorted data at **0.75 ns/element**, a 35× spread from its random-data cost of ~26.`
Replace: `it sorts already-sorted data at **0.75 ns/element**, a 34× spread from its random-data cost of ~26.`

(Derivation: 25.76 / 0.75 = 34.4.)

Find: `Radix, by contrast, spans **1.8×** across all five distributions.`
Replace: `Radix, by contrast, spans **~2×** across all five distributions.`

(Derivation: 24.11 / 12.38 = 1.95; May: 1.78.)

Find: `sorted and reverse-sorted are its *worst* inputs (~21–22 ns/element), random is its *best* (~12), and few-unique sits in between (~15).`
Replace: `sorted and reverse-sorted are its *worst* inputs (~23–24 ns/element), random is its *best* (~12), and few-unique sits in between (~15).`

(Derivation: sorted 24.11, reverse 23.13, random 12.38, few_unique 14.83.)

Find: `Radix's answer is the same regardless: 12 to 22 ns/element, full stop.`
Replace: `Radix's answer is the same regardless: 12 to 24 ns/element, full stop.`

## Task 4 — footer isolation

Find: `cores 0–7 isolated (core 0 carries unavoidable kernel housekeeping)`
Replace: `cores 1–7 isolated (cpu0 cannot be kernel-isolated and carries housekeeping)`

## Task 5 — frontmatter date

`date: "2026-05-30"` → `date: "2026-06-05"`.

## Acceptance

1. Archive file exists, byte-identical.
2. `grep -c 'This isn.t noise\|~21–22\|12 to 22\|a 35× spread\|spans \*\*1\.8×\*\*'` → 0.
3. `grep -c 'placement-dependent\|placement luck'` → ≥2; `grep -c 'sometimes'` → ≥1 (section header).
4. `grep -c '~23–24'` → 1; `grep -c '12 to 24'` → 1; `grep -c '34× spread'` → 1.
5. `grep -c 'cores 0–7'` → 0; `date:` reads 2026-06-05.
6. Headline anchors untouched: `grep -c '74 ns per element\|about \*\*15\*\*\|0\.75 ns/element\|5\.2× at 32-bit to 1\.8× at 64-bit'` — counts unchanged from pre-edit (CC: record before/after).
7. CC re-derives every replacement figure from the JSON (not this brief); `npm run build` clean.

## Out of scope

- The cache-knee paragraph's surviving claims (~7–8 → ~11–12 → ~15, knee at 4M) — re-derived, hold, untouched beyond the Task 1 sentence.
- The u64 section — re-derived, holds exactly, untouched.
- Demo 01 coupling: line ~105 calls demo 01's sort "one-second"; demo 01's re-derivation moved the figure to ~1.1 s. "One-second sort" is retained as a characterization (1.096 s) — flagged, not edited. If Gareth prefers "roughly one-second", say so.
- Bench changes, chart components, other demos.

## Open items

1. Fourth exhibit for the cross-read skill check (05 exact ties, 06 within-capture structure, 07 sub-5% equivalence, 08 "isn't noise" small-N structure): confident mechanistic claims about fine structure require multi-capture support. The skill update should land with the branch merge.
2. The placement-sensitivity of radix's small-N band would be cleanly testable (N invocations, record buffer addresses vs per-run cost) — a future diagnostic if the rewritten paragraph draws challenge; not needed to ship the honest framing.
3. Clock forensics: base clock confirmed; all eight demos consistent. Correction-note ledger complete.
