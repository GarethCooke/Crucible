# Crucible · CC Brief: `01-branch-prediction` final-text edits

**Context.** The benchmark, verifier, parser, and JSON capture are all final and correct. JSON lives at `site/src/data/perf/01-branch-prediction.json` (captured 2026-05-18). Disassembly lives at `site/src/data/perf/01-branch-prediction_disasm.txt`. The MDX is substantively right but a final-pass review against the JSON surfaced ten edits — two asm corrections, three branchless walk-backs (the post overstates), a headline-number consistency pass, one missing finding (genuinely interesting, see §4), and three minor numeric/factual fixes.

**All edits below are pure text in `site/src/posts/01-branch-prediction.mdx`. No C++, no capture, no parser, no JSON changes.**

**Priority order.** (1) asm corrections, (2) headline-number consistency, (3) branchless walk-backs, (4) add the small-N memorisation finding, (5) minor numeric fixes, (6) build verify.

---

## 1. Asm corrections

### 1a. `sum_threshold` — addresses are stale

The current asm block (lines 58–67) uses addresses `b8d0`/`b8d3`/`b8d6`/`b8d8`/`b8db`/`b8df`/`b8e2`. Those are from the _v1_ binary. The fresh capture uses `bbd0`/`bbd3`/`bbd6`/`bbd8`/`bbdb`/`bbdf`/`bbe2`. Instructions are identical; only the addresses changed.

Replace:

```asm
; sum_threshold inner loop — seven instructions, one data-dependent branch
b8d0:  movslq (%rax),%rdx        ; load x  (sign-extend i32 → i64)
b8d3:  cmp    $0x7f,%edx         ; x − 127  (sets flags)
b8d6:  jle    b8db               ; ← the branch: skip add if x ≤ 127
b8d8:  add    %rdx,%rsi          ; sum += x
b8db:  add    $0x4,%rax          ; advance pointer
b8df:  cmp    %rcx,%rax          ; ptr == end?
b8e2:  jne    b8d0               ; loop
```

With:

```asm
; sum_threshold inner loop — seven instructions, one data-dependent branch
bbd0:  movslq (%rax),%rdx        ; load x  (sign-extend i32 → i64)
bbd3:  cmp    $0x7f,%edx         ; x − 127  (sets flags)
bbd6:  jle    bbdb               ; ← the branch: skip add if x ≤ 127
bbd8:  add    %rdx,%rsi          ; sum += x
bbdb:  add    $0x4,%rax          ; advance pointer
bbdf:  cmp    %rcx,%rax          ; ptr == end?
bbe2:  jne    bbd0               ; loop
```

Verify against `site/src/data/perf/01-branch-prediction_disasm.txt` lines 8–14.

### 1b. `sum_threshold_branchless` — replace placeholder asm with real disasm

The current block (lines 72–82) uses `xxxx:` placeholder addresses _and_ a contrived instruction pattern (`xorl/cmpl/cmovg/addq`) that isn't what GCC actually emits. The real pattern is more interesting and worth showing honestly.

Replace:

```asm
; sum_threshold_branchless inner loop — cmov replaces the branch entirely
xxxx:  movslq (%rax),%rdx        ; load x
xxxx:  xorl   %ecx,%ecx          ; tmp = 0
xxxx:  cmpl   $0x7f,%edx         ; x − 127
xxxx:  cmovg  %edx,%ecx          ; tmp = x if x > 127 else 0  ← no jump
xxxx:  addq   %rcx,%rsi          ; sum += tmp
xxxx:  addq   $0x4,%rax          ; advance pointer
xxxx:  cmpq   %r9,%rax           ; ptr == end?
xxxx:  jne    xxxx               ; loop
```

With (verified against disasm lines 285–292):

```asm
; sum_threshold_branchless inner loop — eight instructions, no data-dependent branch
bc00:  movslq (%rax),%rdx        ; load x  (sign-extend i32 → i64)
bc03:  mov    %rdx,%rsi          ; save x in rsi for the compare
bc06:  add    %rcx,%rdx          ; rdx = sum + x  (speculatively compute the new sum)
bc09:  cmp    $0x7f,%esi         ; x − 127
bc0c:  cmovg  %rdx,%rcx          ; commit: sum = (sum + x) iff x > 127  ← no jump
bc10:  add    $0x4,%rax          ; advance pointer
bc14:  cmp    %rax,%rdi          ; ptr == end?
bc17:  jne    bc00               ; loop
```

Also replace the prose paragraph immediately after (currently lines 84–86):

```
The `cmovg` (conditional move if greater) evaluates both the `sum += x` and
`sum += 0` paths, writes the correct result, and moves on — no branch, no
speculation, no pipeline flush on a misprediction.
```

With:

```
GCC compiles the ternary into a small surprise: rather than zeroing a temp and
conditionally moving `x` into it, it pre-computes the candidate new sum
(`rdx = sum + x`) **unconditionally**, then uses `cmovg` to commit that candidate
into the live accumulator only when `x > 127`. The wrong-path add happens every
iteration and is silently discarded — no branch, no speculation rollback, and
crucially no mispredict penalty even on adversarial input.
```

This is the second time the post lands the "GCC is doing something non-obvious" theme — it reinforces the v1.1 originality angle (compiler-as-adversary) rather than papering over it.

---

## 2. Headline number consistency — pick 7× and commit

The JSON shows the actual sorted-vs-unsorted ratio is 6.68× at N=32M and peaks at 7.17× at N=1M (L3-resident). The current post variously says "6×", "6.8×", and "roughly 7×" in different places. They need to converge.

**Decision: use 7× everywhere except the precise body number.** Reasoning:

- The peak across the curve is 7.2× and the headline N is 6.7×; both round to 7× cleanly.
- "6×" reads as understatement; "7×" is honest given the peak and rounds correctly from 6.68.
- Where a specific N is being discussed, use the precise number (6.7× at 32M, 7.2× at 1M).

### 2a. Front-matter summary (line 4)

Replace:

```
summary: "Same code. Same data. Three variants. Why does one run 6× faster — and why does the branchless version beat both?"
```

With (also fixes the "beat both" overstatement — see §3a):

```
summary: "Same code. Same data. Three variants. Why does one run 7× faster — and why does the branchless version close most of the gap without sorting anything?"
```

### 2b. Hook (lines 7–9)

Replace:

```
Same code. Same data values. Same compiler flags. Yet one version runs
roughly six times faster than the other on identical hardware, and a third
version eliminates the performance gap entirely without sorting anything.
```

With:

```
Same code. Same data values. Same compiler flags. Yet one version runs
roughly seven times faster than the other on identical hardware, and a third
version closes most of the gap without sorting anything.
```

### 2c. Cache-hierarchy intro (line 141)

Replace:

```
The 6× headline is measured at N = 32 M (128 MiB), where both variants are
partially DRAM-bound. Looking across all six sizes reveals a more interesting
story:
```

With:

```
The 6.7× headline is measured at N = 32 M (128 MiB), where both variants are
DRAM-bound. Looking across all six sizes reveals a more interesting story:
```

### 2d. DRAM-bound number (line 161)

Replace:

```
- **N = 32 M (DRAM-bound)**: both variants are bandwidth-limited; mispredict
  cost overlaps with memory-wait cycles. The absolute gap stays substantial
  but the ratio compresses to **~6.8×** — the _floor_ of the effect, not the
  peak.
```

With:

```
- **N = 32 M (DRAM-bound)**: both variants are bandwidth-limited; mispredict
  cost overlaps with memory-wait cycles. The absolute gap stays substantial
  but the ratio settles at **6.7×** — the _floor_ of the effect, not the peak.
```

### 2e. Cache-resident peak (line 157)

The existing "roughly **7×**" is correct (actual 7.17×). Leave as-is. Optionally tighten to "**7.2×**" for precision; either works.

### 2f. Takeaway (line 200)

Replace:

```
Two O(n) algorithms with identical instruction counts can differ by 6× in
wall time if one is predictor-friendly and the other is not. And both can
lose to the same loop written branchlessly. The classic branch-prediction
demo is not really a lesson about sorting — it is a lesson about how much
performance is hiding in the control-flow shape of your hot loop.
```

With:

```
Two O(n) algorithms with identical instruction counts can differ by 7× in
wall time if one is predictor-friendly and the other is not. The classic
branch-prediction demo is not really a lesson about sorting — it is a lesson
about how much performance is hiding in the control-flow shape of your hot
loop, and how readily the modern predictor will reward you for working with it.
```

Note: "And both can lose to the same loop written branchlessly" is removed because it's false (see §3). The branchless variant doesn't beat sorted; it beats unsorted by ~5.5× and trails sorted by ~22%.

---

## 3. Branchless walk-backs

The post overstates branchless in three places. JSON confirms branchless is **slower than sorted at every measured N** (1.03× to 1.26× slower), settling at ~1.22× slower from L3-resident through DRAM. Branchless beats unsorted by ~5.5× — substantial — but does not match sorted, let alone beat it.

### 3a. Hook (already covered in §2b above)

Replace "eliminates the performance gap entirely" with "closes most of the gap." ✓

### 3b. TimeVsN narrative (lines 163–165)

The current claim "Branchless tracks sorted closely at small N (no branch, no mispredict, same access pattern) and tracks the floor at large N (both variants become bandwidth-bound regardless of branch behaviour)." is wrong about large N. At N=32M branchless is 22% slower than sorted, not tracking the floor.

Replace:

```
Branchless tracks sorted closely at small N (no branch, no mispredict, same
access pattern) and tracks the floor at large N (both variants become
bandwidth-bound regardless of branch behaviour).
```

With:

```
Branchless tracks sorted within a few percent at small N, then diverges to
**~22% slower** as N grows. The cmov path pre-computes `sum + x` on every
iteration and discards it half the time via the conditional move; well-predicted
sorted skips the add entirely when `x < 128`. At a 50/50 split with near-zero
mispredicts, that "skip half the work" advantage is exactly the ~22% gap we
measure. Branchless still beats unsorted by ~5.5× — but a perfectly-predicted
branch beats branchless on this workload.
```

This is honest and substantively more interesting: it ties the empirical 22% gap directly to the asm-level insight from §1b. The "GCC pre-computes the candidate sum unconditionally" detail pays off twice — once in the asm narration, once in the cost analysis.

### 3c. "Strictly better" caveat (lines 185–188)

Replace:

```
One caveat: branchless trades a possible-skip for a guaranteed-execute.
If the predicate is very rarely true and the unselected work is expensive,
a well-predicted branch can win. For the 50/50 case studied here, the cmov
path is strictly better.
```

With:

```
One caveat: branchless trades a possible-skip for a guaranteed-execute.
The cmov path computes the candidate result on every iteration and conditionally
commits it; a well-predicted branch skips the work entirely on the not-taken
path. For the 50/50 case studied here, branchless soundly beats unpredictable
branching — but a perfectly-predicted branch still edges ahead by about 22%
on this workload because it does half the adds. Branchless wins when the
predicate is unpredictable, *not* when it's merely binary.
```

---

## 4. Add the small-N memorisation finding

The JSON contains a fascinating data point the post currently misses: at N=1024, the unsorted variant's mispredict rate is **1.27% (not 50%)**, IPC is **1.61 (not 0.45)**, and the sorted-vs-unsorted ratio collapses to **1.04× (not 7×)**.

This is the TAGE caveat (line 131–137) made empirical. With only 1024 branches in the loop, Zen 2's TAGE predictor has enough history capacity to effectively memorise the entire pseudo-random sequence. The 50% mispredict rate only emerges once N exceeds the predictor's effective history depth — somewhere between 10 K and 100 K on this part (mispredict rate jumps from 1.27% at N=1024 to 30% at N=10240 to 50% at N=100K+).

Add a new sub-section between the existing cache-hierarchy bullets (around line 162) and the "Branchless tracks…" paragraph. Suggested heading and content:

```mdx
### "Random" is in the eye of the predictor

The small-N rows in the chart above conceal a finding worth pulling out. At
N = 1024, the unsorted variant runs at **1.04× of sorted** — essentially no
gap — with a measured mispredict rate of just **1.27%** and IPC of **1.61**.

With only 1024 branches in the loop, TAGE has enough history capacity to
effectively memorise the entire seed-42 shuffle. The same pseudo-random
sequence that produces 50% mispredicts at N ≥ 100 K is, at N = 1024, almost
perfectly learnable. The 50% rate emerges only once N exceeds the predictor's
effective history depth — somewhere between 10 K and 100 K on this Zen 2 part:

| N         | unsorted miss rate | unsorted IPC | sorted/unsorted ratio |
| --------- | ------------------ | ------------ | --------------------- |
| 1,024     | 1.27%              | 1.61         | 1.04×                 |
| 10,240    | 30.3%              | 0.63         | 1.91×                 |
| 102,400   | 49.8%              | 0.45         | 5.50×                 |
| 1,048,576 | 50.0%              | 0.45         | 7.17×                 |

"Random" is not a property of the data alone — it is a property of the data
_relative to the predictor's memory_. Cryptographically random data is random
to TAGE; pseudo-random data short enough to fit in its history register is not.
For a demo on a textbook-classic benchmark, this is the most surprising row in
the table.
```

This addition is what genuinely earns the post's space among the existing literature on this benchmark. Place it before the "Branchless tracks…" paragraph from §3b — the order should be: cache-hierarchy bullets → small-N memorisation finding → branchless-vs-sorted analysis.

---

## 5. Minor numeric and factual fixes

### 5a. IPC unsorted at 32M (line 136–137)

Replace:

```
converges on the 50% ceiling for a fair binary outcome. IPC drops to **0.44**
as the pipeline repeatedly flushes and restarts.
```

With:

```
converges on the 50% ceiling for a fair binary outcome. IPC drops to **0.45**
as the pipeline repeatedly flushes and restarts.
```

JSON value is 0.452. Round to two figures: 0.45.

### 5b. "fits in L1/L2" (line 151)

Replace:

```
- **Small N (≤ 10 K)**: the array fits in L1/L2. Cache latency is minimal for
  both variants; the predictor also needs a few iterations to warm up, so the
  gap is compressed.
```

With:

```
- **Small N (≤ 10 K)**: 1 K elements fit in L1 (4 KiB), 10 K fits comfortably
  in L2 (40 KiB vs Zen 2's 512 KiB L2). Cache latency is minimal for both
  variants, and at small N the predictor can memorise the sequence (see below),
  so the gap is compressed.
```

The "predictor needs to warm up" framing is wrong — what's actually happening is the predictor _succeeds_ at small N (memorises the sequence), not that it warms up slowly. The corrected text is honest and forward-references the §4 finding.

### 5c. Sort cost precision (line 192)

Optional. Current "~1.0 s" is fine; tighten to "~1.04 s" if precision is preferred (JSON: `sort_cost_32m.wall_seconds: 1.043`). Either works.

---

## 6. Optional reframe — lead with the surprise

The §4 small-N memorisation finding is, frankly, the most novel thing in the post. Worth considering whether to lead the hook with it. Current hook is the canonical "sorted is 7× faster" setup, which works but is well-trodden. An alternative hook:

```
Same code. Same data values. Same compiler flags. At 32 M elements, one version
runs **7× faster** than the other. At 1024 elements, the gap collapses to
**1.04×** — the same "random" data that defeats the branch predictor at
production scale is almost perfectly predictable at toy scale, because TAGE
remembers more than you think.
```

This is more arresting and surfaces the demo's actual contribution earlier. Leaving the call here as a stylistic judgement — the existing hook is fine, the alternative is better. Take it or leave it.

---

## 7. Build / verify

```bash
cd site && npm run build
```

Visual verification on `npm run dev`:

- Asm snippets render with `bbd0` (not `b8d0`) for sum_threshold and `bc00` (not `xxxx`) for branchless.
- Branchless asm shows the pre-computed-add pattern (`mov %rdx,%rsi; add %rcx,%rdx; cmovg %rdx,%rcx`), not the placeholder zero-and-cmov pattern.
- Hook reads "seven times faster" and "closes most of the gap."
- Cache-hierarchy section contains "6.7×" at 32M.
- New "Random is in the eye of the predictor" subsection renders with the table.
- TimeVsN narrative no longer claims branchless "tracks the floor at large N."
- "Strictly better" claim is gone.
- IPC reads 0.45 not 0.44.
- "L1/L2" claim corrected.

No `b8d0`, `xxxx:`, "6×", "6.8×", "eliminates the performance gap", "tracks the floor at large N", or "strictly better" should survive anywhere in the body.

---

## Acceptance criteria

- [ ] Asm block for `sum_threshold` uses addresses `bbd0`–`bbe2`.
- [ ] Asm block for `sum_threshold_branchless` uses real addresses `bc00`–`bc17` and the real instruction pattern (`mov %rdx,%rsi; add %rcx,%rdx; cmp $0x7f,%esi; cmovg %rdx,%rcx`).
- [ ] Prose after the branchless asm explains the pre-computed-add behaviour.
- [ ] Front-matter summary uses "7×" and "closes most of the gap."
- [ ] Hook uses "seven times faster" and "closes most of the gap."
- [ ] Cache-hierarchy intro says "6.7× headline."
- [ ] DRAM-bound bullet says "settles at 6.7×."
- [ ] Takeaway says "differ by 7×."
- [ ] No "6×", "6.8×", "eliminates the performance gap entirely", "strictly better", "tracks the floor at large N", or "tracks sorted closely at small N… tracks the floor at large N" survives in the body.
- [ ] New "Random is in the eye of the predictor" subsection exists with the four-row table.
- [ ] IPC unsorted reads 0.45.
- [ ] "L1/L2" claim corrected to reflect that 10K fits in L2 (not L1).
- [ ] `npm run build` succeeds.
- [ ] Post renders cleanly on `npm run dev`; no stale Tailwind/MDX errors from the table addition.

---

## Out of scope

- C++, capture, parser, or JSON changes. The 2026-05-18 capture is final.
- Other demos. Demo 3 is the next thing on the roadmap; nothing here preempts it (the SIMD footnote at lines 88–91 already forward-links).
- Methodology page changes.
- Component changes. `<CodeCompare>`, `<Benchmark>`, `<CounterOverlay>`, `<TimeVsN>` are all working; only their MDX consumers change.
- Rewriting the asm rendering. The existing fenced ` ```asm ` blocks are fine; just update the contents.
- Re-running the benchmark. The numbers are correct; the prose is what's wrong.
