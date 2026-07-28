# Crucible — demo 10 §2 fix brief (post-review)

Opus → CC, on the existing uncommitted work on `feat/demo-10-core-to-core`. Three fixes surfaced by the §2 review; none is a rewrite. Companion: `demo-10-02-implementation-brief.md` (the fixes below correct two spec errors in it — noted inline so the brief and the code end up agreeing).

## Context

The §2 harness is implemented and audited; acceptance passed but for a necessary `bench/CMakeLists.txt` registration (accepted — target must be registered, correctly x86-64-gated). Three items remain, in priority order: a stats-shape mismatch against the shipped house convention, a silent-data-loss bug in the capture path, and a footgun that lets a stray flag defeat the locked capture parameters. Fix all three in one pass, then §4 (calibration against the pilot numbers) is unblocked.

Two of these correct errors in the §2 brief itself — where this brief and `demo-10-02-implementation-brief.md` disagree, **this brief wins**, and the divergence is called out so it's not read as CC drift.

## Tasks

### Task 1 — Stats shape: add `iqr`, keep `p99` out, document why

The review compared demo 10's emitted `rtt_ns`/`baseline_ns` stats against the shipped JSONs. **The house shape is eight fields**, not the six the §2 brief specified:

```
median, min, max, p99, iqr, iqr_lo, iqr_hi, n_reps
```

confirmed across every `ns_per_op` in `site/src/data/perf/07-no-crossover.json` and siblings. `iqr_lo`/`iqr_hi` are **absolute quartile positions** (e.g. median 18.669 with iqr_lo 18.653, iqr_hi 18.686), and `iqr` = iqr_hi − iqr_lo. The §2 brief's Task 5 example (`"iqr_lo": 0.0` against median 0.60) treated them as deltas — that example was wrong; the shipped absolute-quartile convention you followed is correct. Do not revert to the brief's example.

**Change:** add `iqr` to every emitted stats object (`rtt_ns` for all 28 pairs, and `baseline_ns` for all 8 cores), computed as `iqr_hi − iqr_lo`. This makes demo 10 a clean subset of the house shape.

**Do not add `p99`** — this is a deliberate departure, and it needs a one-line justification in the JSON so §8's cross-read doesn't read the absence as an oversight. For demos 1–7 the distribution is raw per-rep latencies, so p99 is a meaningful tail. Demo 10's cell distribution is the **20 slice-placement medians** (Task 4 of §2), so a "p99" over 20 medians is the near-max of an already-averaged quantity, not a latency tail — reporting it would invite a false tail reading. Add to the `latency_matrix.notes` (or the top-level `notes`, wherever the methodology string lives) a sentence to that effect, e.g.: *"Cell stats are computed over the 20 per-placement medians, not raw windows; p99 is intentionally omitted as it would not represent a latency tail for an averaged quantity."*

Final emitted stats shape for demo 10: `median, min, max, p99-OMITTED, iqr, iqr_lo, iqr_hi, n_reps` → i.e. the seven `median, min, max, iqr, iqr_lo, iqr_hi, n_reps`.

### Task 2 — Auto-archive before overwrite (data-loss fix)

The current `run_one.sh` prints an advisory to move the previous capture, **then overwrites `OUT_JSON`**. Under `headless-capture.sh` the console is gone, so the advisory can't be acted on in time and **the second §6 capture silently destroys the first** — which makes the two-capture fine-structure rule (the whole point of §6) impossible to satisfy. An advisory that can't be acted on is not a safeguard.

**Change:** in the `10-core-to-core` branch of `run_one.sh`, before writing `OUT_JSON`, if a file already exists at that path, move it to the archive first:

- Destination: `site/src/data/perf/archive/<slug>_<DATE>.json`, matching the demos 05–08 convention you confirmed.
- **`<DATE>` is read from the existing file's own `captured_at`** (its capture date, `YYYY-MM-DD`), **not** today's date — the archive name must reflect when that capture was taken. Extract it from the JSON (e.g. `jq -r '.captured_at' "$OUT_JSON"` → take the date portion), with a fallback to the file mtime if `captured_at` is somehow unreadable.
- `mkdir -p` the archive dir. If a file already exists at the archive destination (same capture date, re-run), don't clobber it — append a short disambiguator (`_2`, or the time portion) and note it.
- Apply the same archive-before-write to the two sibling exhibit files (`.slice-sweep.json`, `.protocol.json`) if they're written to fixed paths.
- Print what was archived (this is advisory-after-the-fact, which is fine — the move already happened safely).

This is the mechanism the §2 brief's Capture-protocol section assumed ("second file per the demos 05–08 convention") but didn't actually mandate in `run_one.sh`. This brief mandates it.

### Task 3 — Guard the locked capture parameters in `--capture`

`--capture --k 7` currently emits `k_roundtrips: 7` — self-consistent (the JSON reports what ran), but it means a stray flag silently produces non-comparable data that still validates. Given this demo's own history (a governor default produced a phantom 1.40× that looked entirely valid), a second silent-wrong-number path shouldn't be left open.

**Change:** in `--capture` mode, the locked parameters are fixed — `protocol=exchange`, `k=1000`, `windows=20`, `warmup=5`, `placements=20`. If any of `--k`, `--protocol`, `--windows`, `--warmup`, `--repeat` is passed **together with** `--capture`, exit non-zero with a clear message naming the offending flag and stating that `--capture` uses locked parameters (point to the diagnostic modes for tuning). The diagnostic modes (`--pair`, `--offset-sweep`, `--baseline`, etc.) keep honouring these flags — the lock applies only to `--capture`.

## Acceptance

- **Stats shape:** a `--capture` dry run (off-rig fine) emits `iqr` on all 28 `rtt_ns` and all 8 `baseline_ns` objects; `iqr` equals `iqr_hi − iqr_lo` to within float tolerance. No `p99` field present. `grep -c '"p99"'` on the emitted JSON → 0. The p99-omission rationale is present in a `notes` field (`grep -c 'p99' <notes-bearing field>` → ≥1).
- **Archive:** with a pre-existing `10-core-to-core.json` present, a second `run_one.sh 10-core-to-core` moves the old file to `site/src/data/perf/archive/10-core-to-core_<its-captured_at-date>.json` and writes the new one at the live path. Verify the archived file's content is the *old* capture (its `captured_at` matches the date in its new filename), and the live file is the new one. No data lost.
- **Locked params:** `<binary> --capture --k 7` exits non-zero with a message naming `--k`; `<binary> --capture` alone runs with `k_roundtrips: 1000`. `<binary> --pair 1,2 --k 7` still honours `k=7` (diagnostic mode unaffected).
- **Scope:** changes confined to `bench/demos/10-core-to-core/` and `bench/scripts/run_one.sh`. Build stays clean (`cmake --build`, no warnings). `grep -c memory_order_seq_cst bench/demos/10-core-to-core/*.cpp` still → 0.
- **No regression:** the 28-pair / 8-core / 8-baseline counts, `same_ccx` agreement, orchestrator-off-pair rule, and source-literal strings all still hold from the prior audit.

## Out of scope

- The `<LatencyMatrix>` chart (§5, separate Opus scope — being written in parallel; its contract is `median` + `iqr`, no `p99` dependency, so Task 1 is compatible).
- Re-running captures (§6, user).
- The 05–08 archive **naming** itself — you confirmed it; this brief only wires demo 10 to follow it.
- The owed `bench/scripts/` hardening brief (governor false-pass in `prepare_bench.sh`, full `headless-capture.sh`→`lib.sh` convergence, `perf_event_paranoid` assert). Independent.
- The partial-audit gap: 6/25 review agents timed out. Not re-running them — §4 (calibration) and §8 (hostile cross-read) are the real nets and both are ahead.

## Open items for CC to flag

1. **Archive date extraction** — if the existing file's `captured_at` is missing or malformed on some path, report the fallback used (mtime) rather than silently dating the archive wrong.
2. **Sibling exhibit archiving** — if `.slice-sweep.json` / `.protocol.json` are written to timestamped rather than fixed paths, the archive-before-write may be unnecessary for them; state which and why.
3. **`iqr` on a degenerate distribution** — if any cell's 20 placement medians are identical (possible for a very stable intra pair), `iqr` = 0 is correct, not an error; confirm the emitter doesn't treat it as a divide-by-zero or drop the field.
4. If the locked-param guard turns out to collide with how `run_one.sh` invokes `--capture` (e.g. it passes `--windows` explicitly for a reason), stop and flag rather than making `run_one.sh` pass the tuning flags — the point is that the captured params come from the locked defaults, not the script.

## After this lands

§4 — you re-run the pilot checks through the built harness: block structure reproduces, cell medians match the pilot (intra ~72 ns, cross ~160 ns) within the across-placement error band, and the two-level reduction (per-placement median → house stats over the 20) matches the pilot's `--repeat` numbers. Only once §4 confirms the harness reproduces the calibration reference do the two §6 headline captures run.
