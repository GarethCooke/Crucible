# Crucible — Demo 2 (false sharing) final edits

Context: real data captured with 20 reps lives in `site/src/data/perf/02-false-sharing-pnl.json`. The prose post and methodology page are nearly final; this brief is the last pass before ship. All edits below are pure text — no C++, no captures, no parser changes.

## What's changing and why

The 20-rep recapture moved the 8-thread cross-CCX padded number slightly. With more reps the median sits more representatively in the distribution (cpu0 noise has a wide right tail, and 11 reps was favourable). The headline ratio is now 12.89×, which rounds to **13×** rather than 14×. Same story, slightly less dramatic, more honest.

All other ratios survive unchanged or shift by less than 1%.

## Tasks

### 1. `site/src/posts/02-false-sharing.mdx`

#### 1a. Title

Replace:

```
title: "False sharing: a 14× throughput gap from two missing bytes"
```

With:

```
title: "False sharing: a 13× throughput gap from two missing bytes"
```

#### 1b. Hook (line ~7-10)

Replace:

```
Same algorithm. Same fill stream. Same machine. Two versions of a single struct — the
only difference is 56 bytes of padding. At 8 threads, the unpadded version runs at
3.30 ns/op; the padded version reaches 0.23 ns/op. A 14× gap from a layout choice the
compiler never warned about.
```

With:

```
Same algorithm. Same fill stream. Same machine. Two versions of a single struct — the
only difference is 56 bytes of padding. At 8 threads, the unpadded version runs at
3.31 ns/op; the padded version reaches 0.26 ns/op. A 13× gap from a layout choice the
compiler never warned about.
```

#### 1c. Crossing the Fabric prose (around lines 101-104)

Replace:

```
At 4 threads, the cross-CCX unpadded result is 4.57 ns/op against intra-CCX 4t unpadded
at 3.61 ns/op — **a 1.27× additional penalty from crossing the Fabric, on top of the
5× false-sharing penalty already paid**. The cross-CCX 4t result has IQR/median under
0.02% across 11 repetitions, so the 1.27× number is reproducible to the third decimal.
```

With:

```
At 4 threads, the cross-CCX unpadded result is 4.59 ns/op against intra-CCX 4t unpadded
at 3.61 ns/op — **a 1.27× additional penalty from crossing the Fabric, on top of the
5× false-sharing penalty already paid**. The cross-CCX 4t result has IQR/median under
0.4% across 20 repetitions — reproducible to two significant figures.
```

#### 1d. "13× at 8 threads cross-CCX" section heading and opener (around lines 106-110)

Replace:

```
## 14× at 8 threads cross-CCX

At 8 threads spanning both CCXs, the gap widens. The unpadded variant settles at
3.30 ns/op; the padded variant reaches 0.23 ns/op — a **14× throughput gap** from a
single struct layout decision.
```

With:

```
## 13× at 8 threads cross-CCX

At 8 threads spanning both CCXs, the gap widens. The unpadded variant settles at
3.31 ns/op; the padded variant reaches 0.26 ns/op — a **13× throughput gap** from a
single struct layout decision.
```

#### 1e. Results table (around lines 112-119)

Replace the entire table:

```
| Configuration         | Median ns/op | Throughput (ops/sec) | IQR/median |
| --------------------- | ------------ | -------------------- | ---------- |
| Intra-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.03%      |
| Intra-CCX 4t unpadded | 3.61         | 277 M/s              | 0.09%      |
| Cross-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.31%      |
| Cross-CCX 4t unpadded | 4.57         | 219 M/s              | 0.02%      |
| Cross-CCX 8t padded   | 0.23         | 4.33 G/s             | 19%        |
| Cross-CCX 8t unpadded | 3.30         | 303 M/s              | 0.35%      |
```

With:

```
| Configuration         | Median ns/op | Throughput (ops/sec) | IQR/median |
| --------------------- | ------------ | -------------------- | ---------- |
| Intra-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.04%      |
| Intra-CCX 4t unpadded | 3.61         | 277 M/s              | 0.08%      |
| Cross-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.35%      |
| Cross-CCX 4t unpadded | 4.59         | 218 M/s              | 0.17%      |
| Cross-CCX 8t padded   | 0.26         | 3.89 G/s             | 12%        |
| Cross-CCX 8t unpadded | 3.31         | 302 M/s              | 1.4%       |
```

#### 1f. 8t caveat paragraph (around lines 121-126)

Replace:

```
The 8-thread configuration is the only one that includes cpu0, which the kernel
refuses to isolate (it's the boot CPU and handles unmigrable housekeeping). Run-to-run
variance is correspondingly higher there. The unpadded number remains robust —
false-sharing cost dwarfs cpu0 background noise — but the padded baseline has
IQR/median around 19% rather than the sub-1% seen everywhere else. The 14× headline is
real; treat the third significant figure with skepticism.
```

With:

```
The 8-thread configuration is the only one that includes cpu0, which the kernel
refuses to isolate (it's the boot CPU and handles unmigrable housekeeping). Run-to-run
variance is correspondingly higher there. The unpadded number remains robust —
false-sharing cost dwarfs cpu0 background noise — but the padded baseline has
IQR/median around 12% rather than the sub-1% seen everywhere else. The 13× headline is
real; treat the third significant figure with skepticism.
```

#### 1g. Reproducing section — repetitions reference

If the "Reproducing this" section quotes `--benchmark_repetitions=11` or any specific rep count, leave it as it is in the example command (it's an illustrative invocation). If "11 repetitions" appears anywhere in body prose, update to "20 repetitions." Search the whole file for `11 rep` and `11_rep` to be sure.

### 2. `site/src/data/perf/02-false-sharing-pnl.json`

No content changes — this is the freshly captured 20-rep JSON and is correct as-is. Verify only:

- `captured_at` is the real ISO timestamp from the 20-rep run (it is: `2026-05-16T16:58:01+00:00`).
- `machine.isolated_cpus` is `"1-7"` (it is).

### 3. `site/src/app/methodology/page.tsx`

The page already correctly states "≥20 repetitions after warmup" — leave that as-is. The 20-rep captures now back this claim.

Verify only: no surviving references to "11 repetitions" anywhere on the methodology page or elsewhere on the site.

### 4. Build verification

After edits, run:

```bash
cd site && npm run build
```

Confirm the build succeeds and the post renders with the new numbers. The CounterOverlay component picks up the JSON automatically — no chart-component changes needed.

## Acceptance criteria

- Title is exactly `"False sharing: a 13× throughput gap from two missing bytes"`.
- No "14×" survives in the post body, table, or section headers.
- No "0.23 ns/op", "3.30 ns/op", "4.57 ns/op" — all replaced with the 20-rep values.
- Table IQR/median column reads `0.04 / 0.08 / 0.35 / 0.17 / 12 / 1.4` percent in that row order.
- 8t caveat paragraph references "around 12%" not "around 19%."
- "Across 11 repetitions" replaced with "across 20 repetitions" wherever it appears in body prose.
- `npm run build` succeeds; the post page renders with the updated values.

## Out of scope

- Any code, parser, or capture changes. The 20-rep run is final.
- Other demos.
- Methodology page wording (already correct; only verify no stale "11 rep" references).
