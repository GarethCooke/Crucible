# Crucible — demo 10 §2 implementation brief (harness + schema + capture protocol)

Opus → CC. Feature branch `feat/demo-10-core-to-core` (new, off `main`; the pilot lives on `pilot/demo-10-core-to-core`, already committed). Companion: `demo-10-plan.md`, `demo-10-01-pilot-bench-brief-rev2.md`, `demo-10-01-pilot-round2-brief.md`, and the two committed pilot logs.

This is §2 of the plan: it specifies the **production harness** (§3 builds it), the **JSON schema** (the matrix block), and the **§6 capture protocol**. It does **not** cover the `<LatencyMatrix>` chart — that's §5, a separate Opus scope — but the schema here is its data contract, designed with the heatmap loader in view.

## Context — what the pilot settled

Both pilot rounds ran headless on Machine 1 under `performance`, boost off, isolated `1-7`. The decisions below are locked from that data; the numbers are the calibration reference §4 checks against.

- **Protocol: `exchange`** (single `alignas(64)` line, atomic exchange ping-pong). Headline 2.20× (intra 72.1 ns, cross 160.2 ns at K=1000). `twoflag` (3.16×) is retained as a comparison figure for the post, not the headline — it moves two lines and pays the fabric crossing twice.
- **K = 1000.** The across-allocation IQR locked it: at K=1000 the slice-averaged medians are stable (intra IQR 0.01 ns, cross 5.67 ns) against the ~88 ns seam. K=100 is overhead-contaminated; K=10000 buys nothing and quadruples runtime.
- **Core 0 included → 8×8 matrix, 28 unique pairs.** A4 showed core 0's row clean (no housekeeping stripe, IQRs ≤2 ns). The post states the housekeeping caveat as "we measured it, it behaves normally," not a hedge.
- **CCX membership from sysfs:** `{0,1,2,3}` = CCX0 (L3 `0-3`), `{4,5,6,7}` = CCX1 (L3 `4-7`), confirmed by `topology.sh` and by the measured blocks. The matrix labels come from `index3/shared_cpu_list`, not from the core index.
- **RTT reported, not halved.** Baseline X ≈ 0.6 ns/core (A7) — three orders below the intra RTT — so RTT is essentially all transfer. Name the RTT/2 convention in the post; never silently halve.
- **Slice modulation is real (A6).** Cross-pair RTT is bimodal on cache-line address (~160 vs ~166 ns, a ~4% swing); intra is flat. **This changes the capture design** (Task 4): each cell is measured across 20 random line placements and reported as a slice-averaged median with an across-placement error bar, so the value is robust and the two independent captures agree. The bimodality itself becomes a separate supporting exhibit, not a confound baked into the matrix.
- **Orchestrator placement is irrelevant (A8):** it sleeps in `pthread_join` during the timed region. This matters here because core 0 is now a measured worker — see Task 3.
- **WSL2 framing is dead.** Native bare metal; absolute nanoseconds stand with no hypervisor caveat. Remaining caveats: FCLK dependence and Matisse-specificity.

**Sacred contract (do not touch):** the top-level `machine` block and `captured_at` come from `bench/common/machine_info.h`, Z-suffix format, exactly as demos 1/3/4. The matrix data goes in a **demo-local extension block**, precedent demo 4's sweep / demo 5's pressure data / demo 7's `workload` field. Machine block and `captured_at` are never hand-edited and never restructured.

## Tasks

### Task 1 — Promote the pilot to a production demo

Create `bench/demos/10-core-to-core/`, mirroring the demo 4 custom-pipeline layout (demo 10 has no Google Benchmark / `perf stat` path — it's a custom harness like demo 4):

- `benchmark.cpp` — the ping-pong harness, promoted from `bench/pilot/10-core-to-core/pingpong.cpp`. Keep the round-2 internals: `alignas(64)` line + `static_assert`s, affinity readback-assert, invariant-TSC calibration, acquire/release ordering, the arena with selectable offset, the `parse_count`/`parse_core` hardening, the overflow guard. Drop the pilot's ad-hoc stdout table in favour of the JSON emitter (Task 2).
- `CMakeLists.txt` — C++20, `-O3 -march=native`, pthreads, link `bench_common` for `machine_info.h`. Match the demo 4 target pattern.
- `README.md` — one screen: what the demo measures, the `--capture` invocation, a pointer to the post and to the committed pilot for provenance.

The pilot's diagnostic modes (`--offset-sweep`, `--baseline`, `--orchestrator-core`, `--full-matrix` text output) are retained as CLI options — they produce the supporting exhibits (Task 6) and let §4 re-verify against the pilot — but the default `--capture` path is the production one.

### Task 2 — `--capture` mode: emit the complete JSON

A single `--capture` invocation runs the full 8×8 matrix and writes the **entire** demo JSON to stdout (run_one.sh redirects to the data file). Structure:

```json
{
  "demo": "10-core-to-core",
  "title": "Core-to-core latency: cache-line ping-pong RTT across the Zen 2 CCX boundary",
  "machine": <verbatim machine_info_json()>,
  "captured_at": "<UTC now, %Y-%m-%dT%H:%M:%SZ>",
  "latency_matrix": { ... see Task 5 ... },
  "notes": "<canonical methodology string, hardcoded in source — Task 3>"
}
```

- The `machine` block is `machine_info_json()` verbatim — no machine-level `compiler_flags`, all the patched sub-fields (`isolated_cpus_requested`/`_effective`/`_source`, `cpu_affinity`, `lscpu_extended`). Do not reconstruct it by hand.
- `captured_at` stamped in the C harness in Z format, same call demos 1/3/4 use. Not `+00:00`.
- The `title` here is the **JSON** title (descriptive, stable). The **published post title** is a separate editorial decision still open ("Anatomy of the CCX" / "The Seam in the Silicon") — do not block on it; it lives in the MDX front-matter at §7, not here.

### Task 3 — Orchestrator placement (core 0 is now a worker)

The pilot pinned the orchestrator to core 0, off the isolated set. Core 0 is now a **measured worker** for its own row, so that no longer holds. A8 proved placement doesn't perturb the pair (orchestrator sleeps in `pthread_join`), so:

- For each measured pair `(a, b)`, pin the orchestrator to the **lowest-indexed core in `1-7` that is not in `{a, b}`**. That guarantees both workers own their cores during timing, for every pair including core-0 pairs.
- Assert the orchestrator's own `sched_getcpu()` after pinning, same as the workers.
- Record the rule in the JSON (`orchestrator_placement: "lowest-free-isolated"`) so the capture is self-documenting.

### Task 4 — Slice-averaged cells (the A6 consequence)

Each of the 28 cells is measured with **`--repeat 20` across random 64 B-aligned arena offsets**, seeded and reproducible (reuse the round-2 seed machinery). The cell value is the **median of the 20 per-placement medians**; the error bar is the IQR across those 20. This bakes the ~4% slice modulation into a quantified error bar rather than leaving it an uncontrolled per-capture confound, and it's what makes the two §6 captures agree.

- K=1000, windows=20, warmup=5 per placement (locked).
- Diagonal (self-pairs) not measured.
- Also capture the per-core **baseline X** (`--baseline`, one value per core) into the JSON — it underwrites the "RTT is essentially all transfer" claim.
- Runtime sanity: 28 pairs × 20 offsets × 20 windows × K=1000 ≈ a couple of seconds per capture. Cheap; no need to trim.

### Task 5 — The `latency_matrix` extension block

```json
"latency_matrix": {
  "protocol": "exchange",
  "memory_order": "acq_rel",
  "k_roundtrips": 1000,
  "windows_per_placement": 20,
  "warmup_windows": 5,
  "placements_per_cell": 20,
  "offset_mode": "random_64B_aligned",
  "offset_seed": "0x9e3779b97f4a7c15",
  "arena_hugepage": true,
  "tsc_ns_per_cycle": 0.256410,
  "rtt_convention": "round_trip",
  "orchestrator_placement": "lowest-free-isolated",
  "cores": [
    {"cpu": 0, "ccx": 0, "l3_domain": "0-3", "housekeeping": true},
    {"cpu": 1, "ccx": 0, "l3_domain": "0-3", "housekeeping": false},
    ...
    {"cpu": 7, "ccx": 1, "l3_domain": "4-7", "housekeeping": false}
  ],
  "baseline_ns": [
    {"cpu": 0, "median": 0.60, "iqr_lo": 0.0, "iqr_hi": 0.01, "min": 0.58, "max": 0.63, "n_reps": 20},
    ...
  ],
  "pairs": [
    {"a": 0, "b": 1, "same_ccx": true,
     "rtt_ns": {"median": .., "iqr_lo": .., "iqr_hi": .., "min": .., "max": .., "n_reps": 20}},
    {"a": 0, "b": 4, "same_ccx": false,
     "rtt_ns": {"median": .., "iqr_lo": .., "iqr_hi": .., "min": .., "max": .., "n_reps": 20}},
    ... 28 unordered pairs, ascending (a,b) ...
  ]
}
```

Design notes:

- `rtt_ns.stats` uses the **exact house `stats` shape** demos 1–7 use (`median`, `iqr_lo`, `iqr_hi`, `min`, `max`, `n_reps`). Here the distribution is the 20 across-placement medians, not raw windows — state that in `notes`.
- `pairs` holds the 28 **unordered** pairs (ping-pong RTT is symmetric by construction). The chart mirrors them into the full square; the diagonal is rendered null/baseline by the chart, not stored.
- `same_ccx` is derivable from `cores` but stored for loader convenience.
- All harness-emitted strings (protocol, offset_mode, orchestrator_placement, notes) are **string literals in the source**, per demo 9's `cores_physical`/`notes` regression lesson. No post-hoc edits.

### Task 6 — Supporting-exhibit data (small, same capture session)

Two supporting exhibits the post needs, emitted as sibling files so they don't complicate the matrix schema:

- `10-core-to-core.slice-sweep.json` — one intra and one cross pair swept across a full 2 MiB huge page (`--offset-sweep --offset-sweep-range 2097152`), showing the bimodal slice modulation. This is the exhibit that explains the per-cell error bar.
- `10-core-to-core.protocol.json` — the exchange-vs-twoflag comparison on one intra + one cross pair (the A2 four-medians, at K=1000, `--repeat 20`).

Both carry a `machine` block and `captured_at` too (same emitter), so each stands alone.

### Task 7 — `run_one.sh` wiring

Add a `10-core-to-core` branch. Unlike demos 1–8 it does **not** loop over Google Benchmark variants or call `parse_perf.py` — it invokes the binary's `--capture` once and the two exhibit modes, redirecting to the three data files. It **must** still go through the standard preconditions (`assert_isolated_cores`, `assert_smt_off`, `assert_boost_off`, `set_governor_performance`, and now `assert_headless`) via `lib.sh`, exactly as the other demos — the pilot proved a standalone path that skips these produces plausible-but-wrong numbers.

## Capture protocol (§6 — user, after §3/§4 land)

The §6 headline capture, once the harness is built and §4 has confirmed it reproduces the pilot:

```bash
sudo ./bench/scripts/headless-capture.sh ./bench/scripts/run_one.sh 10-core-to-core
```

`headless-capture.sh` now asserts isolation, SMT, boost (via the board-aware `cpb` path), governor, and headless state before dropping the desktop — all the sentinels this demo needs. Then **a second independent capture** for the fine-structure rule:

```bash
sudo ./bench/scripts/headless-capture.sh ./bench/scripts/run_one.sh 10-core-to-core
# → second file per the demos 05–08 convention
```

- **Two captures, block-structure agreement.** The two must agree on CCX block structure and the seam ratio within the across-placement error band. Per-cell differences inside that band are expected (slice placement) and are **not** a retraction trigger — the error bar already owns them. This is the correct application of the multi-capture rule for this demo: it corroborates structure, not sub-error-bar per-cell identity.
- **Second-capture file + citation convention:** match demos 05–08 exactly. CC confirms the naming and post-citation pattern from the repo when wiring `run_one.sh` and flags if it can't find a single consistent pattern (Open items) — do not invent a new one.

## Acceptance

- **Scope:** `git status --porcelain` shows changes only under `bench/demos/10-core-to-core/` and `bench/scripts/run_one.sh`. No `site/` file, no chart, no MDX touched.
- **Builds:** the demo builds via the standard `cmake --build` on the reference machine; `--help` lists `--capture`, `--offset-sweep`, `--baseline`, `--orchestrator-core`, `--repeat`.
- **Machine block untouched:** the emitted JSON's `machine` block is byte-structurally identical to demo 4's (no machine-level `compiler_flags`, patched sub-fields present); `captured_at` matches `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$`.
- **Schema:** a `--capture` run (off-rig sanity is fine — numbers meaningless, structure valid) emits `latency_matrix` with exactly 28 `pairs`, 8 `cores`, 8 `baseline_ns`, and every `rtt_ns` carrying the six-field house `stats` shape. `same_ccx` agrees with the `cores` CCX labels for all 28 pairs.
- **Ordering:** `grep -c memory_order_seq_cst bench/demos/10-core-to-core/*.cpp` → 0.
- **Strings at source:** `notes`, `protocol`, `orchestrator_placement`, `offset_mode` are string literals in the `.cpp` (grep them); none is assembled in a script or hand-edited into JSON.
- **run_one.sh preconditions:** the `10-core-to-core` branch calls `assert_isolated_cores`, `assert_smt_off`, `assert_boost_off`, `set_governor_performance`, `assert_headless` (grep each in the branch).
- **Orchestrator rule:** for a spot-checked core-0 pair, the orchestrator pins off the pair and asserts its own core (grep the assert).

## Out of scope

- **The `<LatencyMatrix>` chart** — §5, separate Opus scope. This brief only fixes its data contract.
- **The MDX post, cross-links, reconciliation section** — §7. (A5's inventory found demos 02/05 cross-CCX claims re-derive cleanly; the one transparency note — demo 05's "1.3× upper bound" resting on an out-of-repo May capture — is a §7/§8 item, not this brief.)
- **The hostile cross-read** — §8.
- **The owed `bench/scripts/` hardening brief** (governor false-pass in `prepare_bench.sh`, converging `headless-capture.sh` fully onto `lib.sh`, `perf_event_paranoid` assert, dead schema fields). Independent; lands any time.
- **The published post title and slug-beyond-default** — editorial, §7. Slug stays `10-core-to-core`.

## Open items for CC to flag

1. **`machine_info_json()` shape** — if it returns the object body without braces (some call sites wrap it), match whatever demo 4's `--machine-info` does so the block is byte-identical; flag if the two diverge.
2. **Second-capture convention** — report the exact file-naming and post-citation pattern demos 05–08 use; if there's no single consistent pattern across them, stop and surface it rather than picking one.
3. **THP on the rig** — the round-2 capture obtained a huge page; if a §6 run reports `THP NOT obtained`, the slice-sweep exhibit (Task 6) is limited to one 4 KiB page and the per-cell placement sampling is within-page only. Flag it; the matrix is still valid (intra is flat, cross modulation is captured either way) but the exhibit is weaker.
4. **`stats` shape drift** — if any demo 1–7 JSON uses a different field set than `{median, iqr_lo, iqr_hi, min, max, n_reps}`, flag before emitting so demo 10 matches the majority, not an outlier.
5. **Baseline sanity** — if any per-core baseline X exceeds its intra-CCX RTT, stop and report (a broken baseline loop), per the round-2 open item.
6. **run_one.sh structure** — if the demo-branch dispatch doesn't accommodate a non-Google-Benchmark custom capture cleanly, flag the actual integration point rather than forcing demo 10 through the variant loop.

## What happens after this lands

§3 is this brief implemented; §4 is you re-running the pilot checks through the built harness (block structure reproduces, medians match the pilot within the error band) before any headline capture. §5 (the `<LatencyMatrix>` chart scope) I write in parallel — it doesn't need real data, the schema above is enough. §6 is the two captures. Nothing downstream is unblocked until §4 confirms the production harness matches the calibration reference.
