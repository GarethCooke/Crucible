# Demo 01 re-derivation patch brief — boost-off recapture

Branch: `feature/boost-off-recapture`. Scope: `content/posts/01-branch-prediction.mdx` only.

## Context

All Machine 1 JSONs were recaptured 2026-06-05 at true base clock (3900 MHz, CPB off) after the silent-boost discovery. The shipped Demo 01 MDX cites figures derived from the old (boosted) capture. Every chart-feeding and prose-cited statistic below has been re-derived from the new `01-branch-prediction.json` medians. Ratios held within rounding (headline 6.7× → 6.80×; peak 7.17× → 7.19×); the small-N memorisation thesis survives unchanged. The disassembly was regenerated with cosmetic address shifts (inner loops byte-identical); the MDX quotes addresses as labels, so the quoted snippets must be updated to match the committed artifact. One pre-existing defect unrelated to the recapture: the footer claims cores 0–7 isolated; effective isolation is and always was 1–7 (cpu0 cannot be isolated via isolcpus).

## Pre-flight sentinel (mandatory — abort on mismatch)

Before applying any edit, verify in `01-branch-prediction.json` (the data file the site build consumes for slug `01-branch-prediction`):

- `captured_at` == `"2026-06-05T05:55:01Z"`
- `machine.turbo` == `false`, `machine.turbo_source` == `"cpb"`, `machine.freq_max_available_mhz` == `3900`
- `runs[]` entry `variant=="unsorted", n==33554432` has `ns_per_op.median` == `3.7558`

Any mismatch → stop, report, do not edit.

## Tasks

### T1 — `sum_threshold` asm snippet: update addresses to regenerated disasm

Find (verbatim, inside the first ```asm fence):

```
bbd0:  movslq (%rax),%rdx        ; load x  (sign-extend i32 → i64)
bbd3:  cmp    $0x7f,%edx         ; x − 127  (sets flags)
bbd6:  jle    bbdb               ; ← the branch: skip add if x ≤ 127
bbd8:  add    %rdx,%rsi          ; sum += x
bbdb:  add    $0x4,%rax          ; advance pointer
bbdf:  cmp    %rcx,%rax          ; ptr == end?
bbe2:  jne    bbd0               ; loop
```

Replace with:

```
ba50:  movslq (%rax),%rdx        ; load x  (sign-extend i32 → i64)
ba53:  cmp    $0x7f,%edx         ; x − 127  (sets flags)
ba56:  jle    ba5b               ; ← the branch: skip add if x ≤ 127
ba58:  add    %rdx,%rsi          ; sum += x
ba5b:  add    $0x4,%rax          ; advance pointer
ba5f:  cmp    %rcx,%rax          ; ptr == end?
ba62:  jne    ba50               ; loop
```

### T2 — `sum_threshold_branchless` asm snippet: update addresses

Find (verbatim, inside the second ```asm fence):

```
bc00:  movslq (%rax),%rdx        ; load x  (sign-extend i32 → i64)
bc03:  mov    %rdx,%rsi          ; save x in rsi for the compare
bc06:  add    %rcx,%rdx          ; rdx = sum + x  (speculatively compute the new sum)
bc09:  cmp    $0x7f,%esi         ; x − 127
bc0c:  cmovg  %rdx,%rcx          ; commit: sum = (sum + x) iff x > 127  ← no jump
bc10:  add    $0x4,%rax          ; advance pointer
bc14:  cmp    %rax,%rdi          ; ptr == end?
bc17:  jne    bc00               ; loop
```

Replace with:

```
ba90:  movslq (%rax),%rdx        ; load x  (sign-extend i32 → i64)
ba93:  mov    %rdx,%rsi          ; save x in rsi for the compare
ba96:  add    %rcx,%rdx          ; rdx = sum + x  (speculatively compute the new sum)
ba99:  cmp    $0x7f,%esi         ; x − 127
ba9c:  cmovg  %rdx,%rcx          ; commit: sum = (sum + x) iff x > 127  ← no jump
baa0:  add    $0x4,%rax          ; advance pointer
baa4:  cmp    %rax,%rdi          ; ptr == end?
baa7:  jne    ba90               ; loop
```

### T3 — Headline ratio, occurrence 1 (§ "The gap across the cache hierarchy", opening sentence)

Find: `The 6.7× headline is measured at N = 32 M (128 MiB), where both variants are`
Replace: `The 6.8× headline is measured at N = 32 M (128 MiB), where both variants are`

(Derivation: 3.7558 / 0.5521 = 6.803.)

### T4 — Headline ratio, occurrence 2 (DRAM-bound bullet)

Find: `but the ratio settles at **6.7×** — the _floor_ of the effect, not the peak.`
Replace: `but the ratio settles at **6.8×** — the _floor_ of the effect, not the peak.`

### T5 — Small-N prose figures (§ "Random is in the eye of the predictor")

Find: `gap — with a measured mispredict rate of just **1.27%** and IPC of **1.61**.`
Replace: `gap — with a measured mispredict rate of just **1.37%** and IPC of **1.70**.`

(Derivation: branch_misses_per_op 0.0137; instructions_per_cycle 1.696.)

### T6 — Table row N = 1,024

Find: `| 1,024     | 1.27%              | 1.61         | 1.04×                 |`
Replace: `| 1,024     | 1.37%              | 1.70         | 1.04×                 |`

### T7 — Table row N = 10,240

Find: `| 10,240    | 30.3%              | 0.63         | 1.91×                 |`
Replace: `| 10,240    | 30.4%              | 0.63         | 1.91×                 |`

### T8 — Table row N = 102,400

Find: `| 102,400   | 49.8%              | 0.45         | 5.50×                 |`
Replace: `| 102,400   | 49.8%              | 0.45         | 5.51×                 |`

(Derivation: 3.9030 / 0.7089 = 5.506.)

### T9 — Table row N = 1,048,576

Find: `| 1,048,576 | 50.0%              | 0.45         | 7.17×                 |`
Replace: `| 1,048,576 | 50.0%              | 0.45         | 7.19×                 |`

(Derivation: 3.7635 / 0.5232 = 7.193.)

### T10 — Sort cost (§ "The sort caveat")

Find: `` `std::sort` on 32 M integers takes **~1.0 s** on the reference machine — ``
Replace: `` `std::sort` on 32 M integers takes **~1.1 s** on the reference machine — ``

(Derivation: sort_cost_32m.wall_seconds = 1.096.)

### T11 — Footer isolation correction (pre-existing defect, not a recapture delta)

Find: `cores 0–7 isolated, pinned to 4–7`
Replace: `cores 1–7 isolated, pinned to 4–7`

(JSON: `isolated_cpus_effective: "1-7"`; cpu0 cannot be removed from the scheduler via isolcpus.)

## Acceptance criteria (grep against the MDX; all must hold)

1. `grep -c '6\.8×' content/posts/01-branch-prediction.mdx` → 2; `grep -c '6\.7×'` → 0
2. `grep -c 'bbd0\|bc00\|bbd3\|bc0c'` → 0; `grep -c 'ba50'` → 2 (label + jump target); `grep -c 'ba90'` → 2
3. `grep -c '1\.27%\|IPC of \*\*1\.61\*\*'` → 0; `grep -c '1\.37%'` → 2; `grep -c '1\.70'` → 2
4. `grep -c '30\.4%'` → 1; `grep -c '30\.3%'` → 0
5. `grep -c '5\.51×'` → 1; `grep -c '7\.19×'` → 1; `grep -c '5\.50×\|7\.17×'` → 0
6. `grep -c '~1\.1 s'` → 1; `grep -c '~1\.0 s'` → 0
7. `grep -c 'cores 1–7 isolated'` → 1; `grep -c 'cores 0–7'` → 0
8. Asm snippets in the MDX match the committed `01-branch-prediction.disasm.txt` inner-loop instructions line-for-line (addresses and mnemonics).

## Out of scope

- All other demo MDX files (02–09), the methodology page, and the correction note (separate, after all eight re-derivations close).
- The summary/intro "7×" and "roughly seven times faster" phrasing — retained deliberately: peak is 7.19×, headline 6.80×; rough framing survives. Do not edit.
- "IPC drops to **0.45**" and "~22%"/"~5.5×" branchless figures — re-derived and confirmed holding (0.441–0.451; 22.5%; 5.55×). Do not edit.
- Chart components (`<Benchmark>` blocks) — data-driven, no literals to patch.
- JSON and disasm artifacts — already committed.

## Open items

1. **"Branchless tracks sorted within a few percent at small N"** — at N=10,240 the gap is 7.3% (2.6277/2.4489), which strains "a few percent". Low severity, judgment call for Gareth; not edited in this brief.
2. **Footer "20 outer repetitions"** — not verifiable from this JSON (no reps field surfaced). Assumed unchanged by the recapture; confirm against capture orchestration if the methodology correction note touches rep counts.
3. The footer isolation defect (T11) predates the recapture and shipped wrong — candidate mention for the methodology correction note alongside the turbo discovery, since both are capture-condition truthfulness issues.
