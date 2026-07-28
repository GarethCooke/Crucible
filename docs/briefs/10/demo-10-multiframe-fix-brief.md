# Crucible — demo 10 multi-frame placement fix brief

Opus → CC, on `feat/demo-10-core-to-core`. This fixes a calibration failure §4 caught: the matrix harness samples cache-line placements the wrong way, producing per-cell error bars that are tight but wrong. Companion: `demo-10-02-implementation-brief.md` (this supersedes its Task 4 sampling design and the corresponding `latency_matrix` fields; the schema is otherwise unchanged), and the two logs `capture-20260726T181645.log` (pilot round 2) and `capture-20260727T180709.log` (failed §4).

## Context — what §4 caught and why

The §4 calibration run does not reproduce the pilot's intra numbers, and the error bars prove it isn't noise:

- Pilot round-2, pair (1,2), K=1000, 20 placements, seed `0x9e3779b97f4a7c15`: **median 72.13 ns, IQR 0.01** (`...181645.log` line 70; all 20 per-offset medians fell in 72.12–72.15).
- §4, same pair, same mechanism, same seed: **median 79.93 ns, IQR 0.14**.

Two tight, non-overlapping error bars 8 ns / 11% apart. That means the error bars understate the true uncertainty — they are measuring the wrong axis.

**Root cause: single-arena placement sampling.** The pilot printed a *fresh* arena address for every single-pair invocation (fresh `mmap` → fresh physical huge-page frame each time). The §4 matrix printed **one** arena (`0x73e8ba000000`) shared across all 28 cells and 8 baselines. And the pilot's own A6 sweep (`...181645.log` lines 144–209) proved intra (1,2) is **flat within a frame** — 72.13 across every offset. So `placements_per_cell=20`, which samples 20 offsets *inside one arena*, averages over the axis where intra doesn't vary (offset within a frame) and is blind to the axis where it does (which physical 2 MiB frame the arena occupies — high-order address bits feed the Zen 2 L3 slice hash). The pilot's (1,2) landed on a ~72 ns frame; §4's whole matrix landed on a ~80 ns frame. `--repeat` reported the frame's level with a false-confident 0.14 ns IQR.

Consequences that make this a hard blocker, not a cosmetic one:

1. **Cross reproduces, intra doesn't.** Cross-CCX RTT is bimodal *on offset within a frame* (A6 lines 220–285 alternate ~160/~166), so `--repeat` legitimately averages it — pilot 166.0 vs §4 163.2, both inside the band, fine. Intra's variation is *between frames*, which `--repeat` never samples. That's the whole discrepancy.
2. **The two §6 captures would disagree.** Independent captures build independent arenas on different frames, so their intra cells could differ by ~8 ns — and the corroboration rule would flag two correct captures as inconsistent.
3. **The CCX0-vs-CCX1 asymmetry (80 vs 72) may be a frame artifact, not hardware.** Nothing currently samples frames, so we can't tell. The fix decides it.

## The fix — sample across frames, identically for every cell

Replace the single shared arena with a **pool of `N` independent arenas, allocated once at capture start, held live simultaneously, and reused across every cell**, where `N = placements_per_cell` (20).

Why this shape specifically:

- **Held simultaneously → guaranteed distinct frames.** Two live private anonymous `mmap`s never share physical backing, so 20 simultaneously-mapped, faulted-in arenas occupy 20 distinct physical frame-sets — frame diversity without needing `/proc/self/pagemap` (root-only, out of scope).
- **Same pool for every cell → the matrix stays internally comparable.** If cell A sampled frames {f1..f20} and cell B sampled {g1..g20}, cell-to-cell differences would be confounded by frame-set differences. Reusing one pool means every cell sees the same 20 frames, so cell-to-cell differences are pure core-pair effects.
- **Captures both axes.** Placement `i` of every cell uses pool-arena `i` at a per-cell pseudo-random 64 B-aligned offset (seeded, reproducible). Across the 20, that samples 20 frames (intra's axis) each at a random offset (cross's axis). Median-of-medians is robust; the IQR now honestly spans the frame variation.

### Task 1 — Arena pool

- At capture start, allocate `N = placements_per_cell` independent arenas (each the current 2 MiB, `MADV_HUGEPAGE`, faulted in). Hold all `N` live for the whole matrix capture; free them at the end.
- Per arena, record whether THP was obtained (`/proc/self/smaps`, as now). **Non-THP arenas are tolerated for the matrix** — a random offset in a 4 KiB-page arena still lands on a physical page whose address feeds the slice hash, so it's still a valid frame sample (arguably better frame diversity). THP only matters for the slice-sweep exhibit (Task 4). Report the THP-obtained count across the pool; do not abort if some arenas miss it.
- If fewer than `N` huge pages are available and you fall back to small pages for some, that's fine and reportable — not a failure.

### Task 2 — Per-cell measurement over the pool

- For each of the 28 pairs and 8 baselines, measure once per pool arena (`N` measurements): placement `i` uses arena `i` at a per-cell seeded random 64 B-aligned offset.
- Reduce exactly as now: per-placement median over its windows, then house stats over the `N` per-placement medians. The two-level reduction is unchanged; only the *source* of the `N` placements changes (pool arenas, not offsets in one arena).
- Keep `n_reps = N = 20`.

### Task 3 — Schema fields (document the change so §8 can verify)

In `latency_matrix`, replace the old single-arena descriptors with:

```json
"placement_arenas": 20,
"placement_sampling": "independent_arena_pool",
"arenas_hugepage_obtained": <count 0..20>,
"offset_mode": "random_64B_aligned_per_arena",
"offset_seed": "0x9e3779b97f4a7c15",
```

Drop the old top-level `arena_hugepage: true` boolean (it described one arena; `arenas_hugepage_obtained` replaces it). Update the `notes` methodology string: state that each cell is measured across `placement_arenas` independent arena allocations held simultaneously (distinct physical frames), so the reported distribution spans **both** within-frame cache-line-offset variation and between-frame L3-slice-placement variation — and that this was changed after a single-arena design was found to sample only the former, understating intra-CCX uncertainty. Strings remain source literals.

### Task 4 — Exhibits

- **Protocol exhibit** (`.protocol.json`): use the same pool sampling as the matrix, so its intra/cross numbers are directly comparable to matrix cells. Same field updates.
- **Slice-sweep exhibit** (`.slice-sweep.json`): **unchanged — keep the single 2 MiB THP arena.** Its entire purpose is to show within-frame offset dependence, which requires one contiguous frame. Add one line to its own `notes` making explicit that it is single-frame by design (so a reader doesn't apply the matrix's multi-frame reasoning to it).

## Acceptance

- **Pool exists and is reused:** the matrix capture allocates `placements_per_cell` arenas once and reuses them across all cells; `grep` shows no single arena shared across cells and no per-cell single-arena offset loop. The `N` arenas are held live simultaneously (not allocated-and-freed per placement).
- **Distinct frames guaranteed by construction:** arenas are independent `mmap`s held concurrently (code comment states the distinctness guarantee).
- **Schema:** a `--capture` dry run emits `placement_arenas`, `placement_sampling: "independent_arena_pool"`, `arenas_hugepage_obtained`, and the updated `offset_mode`; the old `arena_hugepage` boolean is gone. `notes` explains the frame-vs-offset distinction and why the design changed.
- **Reduction unchanged:** still two-level (per-placement median → house stats over N); 28 pairs, 8 baselines, 8 cores, `same_ccx` agreement, `iqr == iqr_hi − iqr_lo`, no `p99`, all still hold.
- **Exhibits:** protocol exhibit uses pool sampling; slice-sweep exhibit still uses one THP arena and says so in its notes.
- **Locked params & guards** from the prior fix brief still hold (`--capture` rejects tuning overrides; `run_one.sh` preconditions intact).
- **Build clean**, `grep -c memory_order_seq_cst → 0`, scope confined to `bench/demos/10-core-to-core/`.
- **Non-THP tolerance:** on a box where some pool arenas miss THP, `--capture` still completes and reports `arenas_hugepage_obtained` < 20 rather than aborting.

## Out of scope

- The schema outside the `latency_matrix` sampling fields, the machine block, `captured_at` — untouched.
- The `<LatencyMatrix>` chart (§5) — the contract is still `median` + `iqr`; this changes what those *mean* (now frame-robust), not their names, so the chart is unaffected.
- Reading physical addresses via `/proc/self/pagemap` — root-only, unnecessary; simultaneous live mappings give the distinctness guarantee.
- Bumping `N` above 20 — hold at 20 for now; only revisit if re-calibration shows the two captures still disagree beyond the IQR (Open items).

## Open items for CC to flag

1. **THP pool availability** — report how many of the 20 arenas got huge pages on the rig. If it's routinely well under 20, say so; it doesn't break the matrix but it's worth knowing, and it means the slice-sweep exhibit and the matrix now differ in page backing.
2. **Frame distinctness assumption** — confirm the arenas are faulted in (touched) before measurement so the physical frames are actually committed; a reserved-but-unfaulted mapping shares the zero page and would defeat the guarantee.
3. **Runtime** — 20 arenas × 28 cells is the same measurement count as before; if holding 40 MB of huge pages interacts badly with anything, flag it rather than trimming `N` silently.
4. **If intra still collapses to a single tight value across the pool** — i.e. the 20 frames all give ~the same intra — then the frame hypothesis is wrong and the §4-vs-pilot gap has another cause; stop and report the per-placement medians so we can see the distribution.

## User actions (not CC) — clean up the committed bad capture

The failed §4 capture was committed. It must not survive to be archived as a legitimate prior when the fixed capture runs (`run_one.sh` archives the existing `10-core-to-core.json` to `archive/<slug>_<its-date>.json` before overwriting — that would enshrine the bad calibration run in history).

Before re-capturing:

1. Remove the three committed data files so there's nothing to wrongly archive:
   ```bash
   git rm site/src/data/perf/10-core-to-core.json \
          site/src/data/perf/10-core-to-core.slice-sweep.json \
          site/src/data/perf/10-core-to-core.protocol.json
   git commit -m "demo 10: drop failed §4 calibration capture (single-frame sampling artifact)"
   ```
   (Or `git revert` the commit that added them — same effect. The commit message should name *why*, so a future cross-read doesn't mistake this for a real capture that went missing.)
2. Confirm nothing already landed in `site/src/data/perf/archive/10-core-to-core_*` from the §4 run (there was no prior, so the archive step should have been a no-op — verify). If a bad archive file exists, `git rm` it too.

## Re-calibration (§4, second attempt) — the criterion has changed

After the fix, the reference is **no longer** "match the pilot's 72.13." That number was itself a single-frame sample. The new criteria:

- **The two captures agree.** Run `--capture` twice (independent pools). Each cell's median-of-medians should now agree between the two within the (now honest, wider) IQR — because each averages ~20 frames, integrating out the frame variation that made 72-vs-80 possible.
- **The intra IQR is now honest** — expect it to widen from ~0.1 ns to something reflecting the ~8 ns frame spread on CCX0 intra, rather than the false-tight value.
- **The CCX0-vs-CCX1 asymmetry resolves one way or the other.** If CCX0 intra stays above CCX1 across the frame pool, it's a real hardware property (candidate finding: the CCX hosting the housekeeping core 0 runs hotter — worth a paragraph and useful to the audience). If it collapses, 80-vs-72 was placement and the honest intra is a single band. Either outcome is publishable; the point is we'll *know*.

Only once the two re-captures agree does §6 proceed — and at that point the two agreeing captures may simply *be* the §6 pair.
