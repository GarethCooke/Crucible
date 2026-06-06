# Demo 07 re-derivation patch brief — boost-off recapture

Branch: `feature/boost-off-recapture`. Scope: `content/posts/07-flatmap-vs-hashmap.mdx` plus archiving the pre-recapture JSON. No bench change, no recapture.

## Context

Recaptured 2026-06-05 at verified base clock. The no-crossover thesis holds in both captures at every N and workload. One variant drifted: `boost_flat` runs ~8–11% over `sorted_vec` in the new capture (modify-heavy: 18.8 vs 17.3 µs; lookup N=32–64: +8–10%) where the May capture had them within ~1–3%. `sorted_vec`, `absl`, `std_unord`, `std_map` are stable to rounding. Consequences: the "~780× gap" headline splits (770× sorted_vec, 835× boost), and the "under 5% for N ≥ 16" equivalence sub-claim is dead. Neither JSON records the Boost version, so apt-upgraded headers vs rebuild layout cannot be distinguished — the prose acknowledges the drift in one sentence and the old JSON is archived for derivability.

Clock forensics: old capture (2026-05-26) at base clock — stable cells agree to ≤1%.

## Pre-flight sentinel (abort on mismatch)

`07-no-crossover.json`: `captured_at == "2026-06-05T06:13:31Z"`, `turbo:false`, `turbo_source:"cpb"`, `freq_max_available_mhz:3900`. Cells: `absl_flat, lookup, n=4194304` median == `18.67`; `sorted_vec, modify_mix, n=65536, modify_pct=90` == `17331.1`; `boost_flat` same cell == `18789.6`.

## Task 0 — archive the pre-recapture JSON

Add `site/src/data/perf/archive/07-no-crossover_2026-05-26.json` (byte-identical). The drift sentence in Task 5 cites the May values.

## Task 1 — intro gap sentence

Find:

```
10×–1000× slowdowns. At N = 65536 and 90% modify, `sorted_vec` and
`boost::flat_map` land at ~17 µs/op against `absl::flat_hash_map`'s ~22 ns/op —
a ~780× gap.
```

Replace:

```
10×–1000× slowdowns. At N = 65536 and 90% modify, `sorted_vec` lands at
~17.3 µs/op and `boost::flat_map` at ~18.8 µs/op against `absl::flat_hash_map`'s
~22 ns/op — gaps of roughly 770× and 835×.
```

(Derivations: 17331.1/22.5 = 770; 18789.6/22.5 = 835.)

## Task 2 — absl/std_unord bullet values

Find: `but sits ~4× higher at small N (14.2 ns vs. 3.5 ns at`
Replace: `but sits ~4× higher at small N (15.9 ns vs. 3.5 ns at`

Find: `N = 64), narrowing to ~1.6× at N = 4 M (29.3 ns vs. 18.5 ns) as both hit`
Replace: `N = 64), narrowing to ~1.6× at N = 4 M (29.3 ns vs. 18.7 ns) as both hit`

(Derivations: std_unord N=64 = 15.92; absl N=4M = 18.67, 29.26/18.67 = 1.57.)

Also, in the absl bullet above it: `At N = 4 M it reaches ~18.5 ns/op` → `At N = 4 M it reaches ~18.7 ns/op`.

## Task 3 — equivalence bullet and ratios

Find:

```
  within ~11% across the entire range (under 5% for N ≥ 16) — they are the same
  sorted-contiguous primitive; the residual is Boost's container bookkeeping over
  a raw vector. Against `absl::flat_hash_map` the gap widens monotonically: ~3× at
  N = 8 (11.4 ns vs. 3.5 ns), ~13× at N = 1 024 (48.3 ns vs. 3.8 ns), ~24× at
  N = 4 M (437.5 ns vs. 18.5 ns). Binary search's O(log N) pointer walk
```

Replace:

```
  within ~10% across the entire range — they are the same
  sorted-contiguous primitive; the residual is Boost's container bookkeeping over
  a raw vector, and its size moves between builds (see the modify-mix section).
  Against `absl::flat_hash_map` the gap widens monotonically: ~3× at
  N = 8 (11.1 ns vs. 3.5 ns), ~12× at N = 1 024 (47.6 ns vs. 3.8 ns), ~23× at
  N = 4 M (435.7 ns vs. 18.7 ns). Binary search's O(log N) pointer walk
```

(Derivations: 11.06/3.49 = 3.17; 47.60/3.84 = 12.4; 435.72/18.67 = 23.3. Max boost/sorted lookup divergence in this capture: 10.1% at N=64.)

## Task 4 — 4M convergence cluster

Locate the sentence containing `~440–460 ns/op cluster` and `roughly 24× slower` (CC: match verbatim from the file). Change the range to `~435–455 ns/op` and the multiple to `roughly 23–24×`.

(Derivation: 4M lookups — sorted_vec 435.7, std_map 455.0, boost 455.1.)

## Task 5 — the 65536/90% paragraph

Find:

```
At N = 65 536, 90% modify: `sorted_vec` lands at **~17 308 ns/op** (~17.3 µs),
`boost::flat_map` at **~17 217 ns/op** (~17.2 µs), `absl::flat_hash_map` at
**~22 ns/op**. That is a **~780× gap**.
```

Replace:

```
At N = 65 536, 90% modify: `sorted_vec` lands at **~17 331 ns/op** (~17.3 µs),
`boost::flat_map` at **~18 790 ns/op** (~18.8 µs), `absl::flat_hash_map` at
**~22 ns/op**. That is a gap of **roughly 770× and 835×**. (The ~8% offset
between Boost and the raw vector is build-sensitive bookkeeping, not structure —
the May capture of identical code had the two within 1%; the
three-orders-of-magnitude collapse is the capture-stable part.)
```

Keep the following sentence (`The hash-map lines barely move…`) unchanged.

## Task 6 — second equivalence reference (~line 249)

Find: `to within ~11% at small N (under 5% for N ≥ 16) across the entire sweep`
Replace: `to within ~10% across the entire sweep`

## Task 7 — O(N) arithmetic sentence

Find: `is almost entirely O(N) erase+insert — hence the ~17 µs/op observed.`
Replace: `is almost entirely O(N) erase+insert — hence the ~17–19 µs/op observed.`

## Task 8 — footer isolation

Find: `cores 0–7 isolated (core 0` … `carries unavoidable kernel housekeeping)` (spans two lines)
Replace the `0–7` with `1–7` and the parenthetical opening with `(cpu0 cannot be kernel-isolated and carries housekeeping)`, preserving the rest of the footer line.

## Task 9 — frontmatter date

`date: "2026-05-26"` → `date: "2026-06-05"`.

## Acceptance

1. Archive file exists, byte-identical.
2. `grep -c '~780×\|17 217\|17 308\|under 5% for N\|14\.2 ns\|48\.3 ns\|437\.5 ns\|18\.5 ns'` → 0.
3. `grep -c '770×'` → 2 (intro + paragraph); `grep -c '835×'` → 2; `grep -c '18 790\|18\.8 µs'` → ≥2.
4. `grep -c 'build-sensitive'` → 1; `grep -c '~10% across the entire'` → 2.
5. `grep -c 'cores 0–7'` → 0; `date:` reads 2026-06-05.
6. CC re-derives every replacement ratio from the JSON medians (not from this brief) and reports any disagreement before committing.
7. `npm run build` clean; charts render (data-driven).

## Out of scope

- Bench changes and recaptures. The drift's cause (Boost header upgrade vs rebuild layout) is not resolvable from the data and is not chased here.
- Chart components; the "What this doesn't show" section (re-checked, accurate).
- Other demos, methodology, correction note.

## Open items

1. **Record library versions in the machine block** (Boost, Abseil, glibc) — without them, single-variant drift like this is unattributable. Schema addition for the standing hardening brief; would have settled today's question in one field.
2. The "under 5%" failure is the third instance of the tight-claim lesson (05: exact ties; 06: within-capture structure; 07: sub-5% equivalence). The cross-read skill check proposal now has three exhibits.
3. Clock forensics: base clock confirmed; seven demos consistent.
