# Crucible — Demo 2 (false sharing) prose rewrite + JSON cleanup

Read `BRIEF.md` and `crucible-handover.md` for project context. Demo 2 recapture is complete — real data lives in `site/src/data/perf/02-false-sharing-pnl.json`. This brief takes the demo from "shippable data, stale prose" to "shippable, end-to-end."

The previous remediation brief (`02-false-sharing-remediation-brief.md`) is complete and signed off. The parser bug, 1t baseline anomaly, isolation method, and CI guards are all resolved. This brief is the next, final piece.

## What's now true (and why the old prose is wrong)

The original `02-false-sharing.mdx` was written against parser-corrupted data. The real numbers tell a different — better, simpler — story. The current post overclaims in some places and underclaims in others. Specifically:

- **Old claim:** "341× throughput gap" — this came from arithmetic on broken data.
- **Real number:** 14.3× wall-time gap at 8 threads cross-CCX (3.30 ns/op unpadded vs 0.23 ns/op padded).

- **Old claim:** "Wall-clock impact within one CCX is muted (~1.2×) — the shared L3 absorbs the cost."
- **Real number:** 5.1× wall-time penalty at 4t intra-CCX (3.61 ns/op unpadded vs 0.71 ns/op padded). The shared L3 does _not_ absorb the cost. The central thesis of the original post is contradicted by the real data.

- **Old claim:** "Cross-CCX 1.28× additional penalty" — this number happens to survive, because it's a ratio and ratios cancel out the parser bug. But the framing around it (as the _only_ place wall-clock pain shows up) does not.

The new headline is **"14× throughput gap from two missing bytes"** — accurate, dramatic, defensible by a hostile reviewer with a calculator. The new narrative arc is simpler than the old one: false sharing hurts wall-clock _everywhere_ it appears (~5× intra-CCX); crossing the Infinity Fabric adds another ~1.27× on top; at 8 threads spanning both CCXs the combined penalty is 14×.

## Tasks

### 1. JSON cleanup (`site/src/data/perf/02-false-sharing-pnl.json`)

- Set `captured_at` to the real ISO 8601 timestamp of the capture run. The user can supply this — ask if not obvious from filesystem mtime of the bench/perf intermediates.
- Set `machine.isolated_cpus` from `"4-7"` to `"1-7"`. The kernel refuses to isolate cpu0 (boot CPU) regardless of `isolcpus=` request — effective isolation on the reference machine is 1–7. Update `machine.isolated_cores` array accordingly: `[1, 2, 3, 4, 5, 6, 7]`.
- Update the top-level `notes` field — remove the "Placeholder data — replace by running tools/perf_capture.sh" wording. Replace with a single sentence: "Captured on AMD Ryzen 7 3800X, Zen 2, governor=performance, turbo off, SMT off, isolated cpus 1-7 (cpu0 cannot be kernel-isolated). Fill stream: 1024 doubles (8 KB), mt19937 seed 42, uniform [-1, 1]. Compiler: GCC 13, -O3 -march=native."

### 2. Prose rewrite (`site/src/posts/02-false-sharing.mdx`)

Full rewrite. The existing structure (setup → intra-CCX counter signal → intra-CCX wall-clock → cross-CCX → conclusion) had a central thesis that the real data contradicts, so a partial rewrite isn't tractable.

**New title (locked):** `"False sharing: a 14× throughput gap from two missing bytes"` — exact wording. The hook in the body opens with that ratio.

**Summary frontmatter:** A one-line variant of the title that omits the headline number but conveys "same algorithm, struct layout matters, dramatic gap." Keep it short.

**Sections to write, in order:**

#### Hook — opening 3-5 lines

Same algorithm. Same fill stream. Same machine. Two versions of a single struct — the only difference is 56 bytes of padding. At 8 threads, the unpadded version completes the workload at 0.23 ns/op; the padded version takes 3.30 ns/op. A 14× gap from a layout choice the compiler never warned about.

#### The setup

Carry over from the existing post with minor edits. The `<CodeCompare>` block is fine as written — both struct definitions, `volatile double pnl` in the body, comment on cache-line geometry. Keep the labels `["Unpadded", "Padded"]`.

Add one sentence after the CodeCompare: "Each thread owns a slot; threads never write to each other's slots logically. The only sharing is incidental — adjacent slots happen to land on the same cache line."

#### The mechanism (replaces "The counter signal — intra-CCX")

Short paragraph: every write to an unpadded slot invalidates the entire cache line, which holds seven neighbouring slots belonging to other threads. Each thread must re-fetch the line before it can write. Accesses that previously resolved in L1d (~4 cycles) now require L3 round-trips (~35 cycles on Zen 2). With four threads simultaneously invalidating each other, the CPU spends most of its time waiting.

The IPC counter and cache-miss-ratio counter make this visible. Show them via CounterOverlay:

```mdx
<CounterOverlay
  slug="02-false-sharing-pnl"
  placement="intra-ccx"
  metric="instructions_per_cycle"
/>
<CounterOverlay
  slug="02-false-sharing-pnl"
  placement="intra-ccx"
  metric="cache_miss_ratio"
/>
```

Commentary on the numbers: at 1 thread the two layouts are indistinguishable (no contention, ~26% miss ratio, IPC ~0.56). At 4 threads the unpadded layout collapses to IPC 0.11 and a 96% miss ratio; the padded layout holds at IPC 0.55 and ~19% miss ratio.

#### The wall-clock cost (replaces "Wall-clock impact — intra-CCX")

This is the section the old post got wrong. The new framing:

> The counter collapse translates directly into wall-clock time. At 4 threads on a single CCX, unpadded is 3.61 ns/op against padded's 0.71 ns/op — **a 5× wall-clock penalty inside one core complex**, lockstep with the 5× IPC collapse. The shared L3 doesn't rescue you — every false-sharing round-trip still costs you instructions you could have been executing.

Show this with `<ThroughputBars slug="02-false-sharing-pnl" placement="intra-ccx" />`.

#### Crossing the Fabric (replaces "Where wall-clock magnification reasserts itself")

The cross-CCX section. Topology context first: Zen 2 is a chiplet architecture. Two 4-core CCXs sit on a compute die (CCD), connected via Infinity Fabric to a separate I/O die (IOD) that holds the memory controller. **Important precision fix from the old post — the memory controller is on the IOD, not the CCD. Get this right.**

Coherency traffic between two cores on the same CCX travels through their shared 16 MB L3. Coherency traffic between CCX0 and CCX1 has to cross the Infinity Fabric — higher latency, no shared cache to absorb the round-trips.

Show: `<ThroughputBars slug="02-false-sharing-pnl" placement="cross-ccx" />` and `<CounterOverlay slug="02-false-sharing-pnl" placement="cross-ccx" metric="instructions_per_cycle" />`.

Commentary: at 4t the cross-CCX unpadded is 4.57 ns/op vs intra-CCX 4t unpadded at 3.61 ns/op — **a 1.27× additional penalty from crossing the fabric, on top of the 5× false-sharing penalty already paid**. The cross-CCX 4t result has IQR/median under 0.02% across 11 repetitions, so the 1.27× number is reproducible to the third decimal.

Drop the "200 ns of local work per iteration" back-of-envelope from the old post entirely. It had no defensible derivation. The empirical 1.27× speaks for itself; readers don't need a hand-wavy model alongside.

#### The headline — 14× at 8 threads cross-CCX

Short, punchy section:

> At 8 threads spanning both CCXs, the gap widens. The unpadded variant settles at 3.30 ns/op; the padded variant reaches 0.23 ns/op — a **14× throughput gap** from a single struct layout decision.

Table (matching the existing format but with real numbers and IQR rather than fake CV):

| Configuration         | Median ns/op | Throughput (ops/sec) | IQR/median |
| --------------------- | ------------ | -------------------- | ---------- |
| Intra-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.03%      |
| Intra-CCX 4t unpadded | 3.61         | 277 M/s              | 0.09%      |
| Cross-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.31%      |
| Cross-CCX 4t unpadded | 4.57         | 219 M/s              | 0.02%      |
| Cross-CCX 8t padded   | 0.23         | 4.33 G/s             | 19%        |
| Cross-CCX 8t unpadded | 3.30         | 303 M/s              | 0.35%      |

The 8t padded row's higher variance needs an honest caveat in the surrounding text: "The 8-thread configuration is the only one that includes cpu0, which the kernel refuses to isolate (it's the boot CPU and handles unmigrable housekeeping). Run-to-run variance is correspondingly higher there. The unpadded number remains robust — false-sharing cost dwarfs cpu0 background noise — but the padded baseline has IQR/median around 19% rather than the sub-1% seen everywhere else. The 14× headline is real; treat the third significant figure with skepticism."

#### Why this matters in practice

Carry over the bulleted list from the existing post — per-strategy accumulators in trading engines, per-worker statistics counters, market-data fan-out structs. These are good and the framing matches the audience. No edits needed.

The fix paragraph is also fine as-is: `alignas(64)` is sufficient on x86-64; the memory cost (8 threads × 64 bytes = 512 bytes vs 64 bytes) is trivial for hot-path accumulators.

#### What this benchmark doesn't show

Replace the existing closing section. Three honest caveats:

- **Read-write sharing is different.** This benchmark measures write-write false sharing. Writer-reader and reader-writer patterns (e.g., one thread updating a sequence number while another reads the payload on the same line) have different magnitudes — usually less severe, since reads don't invalidate.
- **The result is hardware-specific.** Zen 2's 16 MB shared L3 within a CCX and the Infinity Fabric latency to the other CCX are the specific topology measured. Intel monolithic-die designs absorb intra-socket false sharing in the shared LLC; multi-socket NUMA systems behave more like cross-CCX. The mechanism is universal; the magnitudes depend on the chip.
- **cpu0 cannot be kernel-isolated.** On the reference machine the 8t result includes cpu0 in the worker pool. The 14× number is robust because the false-sharing signal dominates; smaller effects measured at 8t would need different methodology.

#### Reproducing this

Carry over the existing section with one edit: replace any reference to `cset shield` (already done in the remediation brief, but double-check) and replace the "All numbers: placeholder" footer with a real footer pointing to `/methodology`.

### 3. Methodology page update (`site/src/app/methodology/page.tsx`)

The methodology page already documents `isolcpus=4-7` from the original BRIEF. Update to reflect the resolved approach:

- Change isolation description from "cores 4–7 isolated" to "cores 1–7 isolated via dual-GRUB-entry kernel boot parameter (`isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7`); the kernel refuses to isolate cpu0 (boot CPU), so effective isolation is 1–7."
- Add one sentence on the boot-CPU constraint: "Some benchmarks (e.g. 8-thread configurations on the reference machine) necessarily include cpu0; results for those configurations are flagged inline where they appear."
- Verify no remaining references to `cset` anywhere on the methodology page.

## Acceptance criteria

- `captured_at` field is a real ISO 8601 timestamp.
- `machine.isolated_cpus` reads `"1-7"`.
- Top-level JSON `notes` no longer contains "Placeholder data."
- Post title is exactly `"False sharing: a 14× throughput gap from two missing bytes"`.
- Body contains no mention of "341×" anywhere.
- No "200 ns of local work" hand-wavy model survives the rewrite.
- "CV under 0.25%" wording (technically wrong — it's IQR/median) is replaced with correct dispersion terminology.
- Zen 2 chiplet description correctly attributes the memory controller to the IOD, not the CCD.
- Methodology page describes `isolcpus=0-7` and the cpu0 limitation.
- `npm run build` succeeds; the post renders; charts pick up the real JSON.

## Out of scope

- Any further C++ or parser changes. The data is sound; this brief is prose + JSON metadata only.
- Other demos.
- Adding new chart components. The post uses `<CodeCompare>`, `<CounterOverlay>`, `<ThroughputBars>` — all already built.
