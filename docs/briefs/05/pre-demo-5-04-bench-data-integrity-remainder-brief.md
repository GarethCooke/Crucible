# Crucible — bench data-integrity remainder brief

**Pre-demo-5 brief 4 of 9. Three unrelated bench-side issues; none invalidates shipped data, all are forward-protection or cosmetic correction.**

---

## 1. Context

Brief 1 handled the visible `ns_per_op` units bug. This brief catches the three other bench-side findings from the pre-demo-5 review that affect data integrity:

- **C2 — demo 04 sweep drift not monitored.** The sweep chart is the headline of demo 04; its `calibration_drift_pct` field is hardcoded to `0.0`, so the assembler's drift flag never fires for sweep data.
- **M5 — `l1d.replacement` perf event not captured.** `parse_perf.py` tries to read it and silently emits `null`; all shipped demo 02 data has `"l1d_misses_per_op": null`.
- **M6 — `assemble_results_04.py` notes field is stale.** Hardcoded as "8 log-spaced steps 100 kHz→25 MHz" but actual capture uses 12 steps to 50 MHz.

None of these is a visible numerical bug in a chart. C2 and M5 are missing-data issues (a check that never fires; a field that's always null); M6 is wrong metadata in the JSON. All three are small script-side fixes.

---

## 2. C2 — sweep mode drift monitoring

**File:** `bench/demos/04-spsc-queue/benchmark.cpp`, around line 758.

Current state:

```cpp
const double drift = 0.0;  // per-step drift omitted
```

This sits inside the sweep loop, so every JSON object emitted by sweep gets `"calibration_drift_pct":0.0000`. The downstream check in `assemble_results_04.py` (`if drift > 0.1: FLAG`) is therefore permanently silenced for sweep data.

In paced and saturated modes a second `calibrate_tsc()` call is made after the run and the result is compared against the startup calibration. Sweep mode does a single calibration at startup and never re-checks.

### 2.1 Fix

Add a second `calibrate_tsc()` call after each sweep step (not after the entire sweep — per-step localisation matters for diagnosing which rate point drifted, if any). The cost is one TSC calibration per step (~10 ms each, 12 steps = 120 ms added to a several-second sweep — negligible).

Implementation sketch (CC to adapt to the actual local variable names and the calibration helper's signature):

```cpp
// At sweep startup, alongside the existing calibration:
const auto tsc_hz_start = calibrate_tsc();

// In the sweep loop, after each step's measurement is complete:
const auto tsc_hz_step = calibrate_tsc();
const double drift = std::abs(static_cast<double>(tsc_hz_step) -
                              static_cast<double>(tsc_hz_start)) /
                     static_cast<double>(tsc_hz_start) * 100.0;
// Use this `drift` value in the JSON record for this step.
```

If the calibration helper isn't already idempotent and side-effect-free, factor it so it can be called repeatedly without disturbing measurement state.

### 2.2 Recapture decision

Demo 04 was captured with sweep drift unmonitored. The other modes (paced, saturated) on the same machine session did pass their drift checks, so the TSC was demonstrably stable for those windows. Modern Zen 2 with `constant_tsc + nonstop_tsc` (both verified by the harness) effectively eliminates drift in normal operation; the probability that sweep drifted while paced and saturated did not is very low.

**Recommendation:** patch and re-capture demo 04 in the same session as the other recaptures from brief 1's cross-demo audit. If brief 1's audit concludes demo 04 is unaffected by the `ns_per_op` issue, demo 04 doesn't strictly need recapture for C2 alone — the historical sweep data stays unvalidated but is almost certainly correct.

This decision is yours; the brief's acceptance criteria below cover both paths.

---

## 3. M5 — `l1d.replacement` perf event

**File:** `tools/perf_capture.sh`, around lines 90–99 (the `perf stat -e ...` invocation).

Current event list: `cache-misses,cache-references,instructions,cycles`. `parse_perf.py` (lines 126–130) attempts to read `l1d.replacement` with fallback to `L1-dcache-load-misses`; when neither is present, `l1d_misses_per_op` becomes `null`. All shipped demo 02 JSON has this field null.

### 3.1 Verify the event name on the reference machine

Before patching, confirm what the local AMD PMU exposes. CC should run on the reference machine:

```bash
perf list | grep -i l1d
```

Expected on Zen 2: `l1d.replacement` is the AMD-specific event name. If absent, the kernel-generic `L1-dcache-load-misses` should be available. Pick the more specific of the two that's actually exposed; fall back to the generic if the specific isn't.

### 3.2 Patch `perf_capture.sh`

Append the event(s) to the `-e` list. If both are exposed, capturing both is fine — `parse_perf.py` already has fallback logic.

```bash
# BEFORE
-e cache-misses,cache-references,instructions,cycles

# AFTER (substitute the actually-available event name discovered in §3.1)
-e cache-misses,cache-references,instructions,cycles,l1d.replacement
```

### 3.3 Field population

The `l1d_misses_per_op` field will populate on the *next* demo 02 capture. Historical data stays null.

Whether to recapture demo 02 to populate the field is a deferred decision (see §6). The post's current claims don't cite per-op L1D miss rates directly (the `cache_miss_ratio` proxy is what's used). Recapturing for this field alone is optional and probably not warranted unless demo 02 is being recaptured anyway for other reasons.

---

## 4. M6 — `assemble_results_04.py` stale notes

**File:** `bench/scripts/assemble_results_04.py`, lines 109–110.

Current state:

```python
"notes": "Sweep: 8 log-spaced steps 100 kHz→25 MHz."
```

`run_one.sh` actually invokes the demo 04 binary with `--steps 12 --rate-to 50000000`. The notes field is wrong by 4 steps and a factor of 2 on the upper rate, and ships in the JSON.

### 4.1 Fix — derive from data

Replace the hardcoded string with values computed from the runs:

```python
sweep_runs = [r for r in runs if r.get("mode") == "sweep"]
if sweep_runs:
    rates = [r["offered_rate_hz"] for r in sweep_runs if r.get("offered_rate_hz") is not None]
    if rates:
        step_count = len(sweep_runs) // len({r["variant"] for r in sweep_runs})  # steps per variant
        notes = (
            f"Sweep: {step_count} log-spaced steps "
            f"{min(rates)/1000:.0f} kHz→{max(rates)/1e6:.0f} MHz."
        )
    else:
        notes = ""
else:
    notes = ""
```

CC should adapt the formatting to match whatever convention `assemble_results_04.py` already uses for numeric strings; the above is illustrative.

### 4.2 Fix the shipped JSON

Re-assembly needs the raw Google Benchmark JSON, which (per brief 1) is no longer on disk. Two paths:

- **(a) Manual edit.** Open `site/src/data/perf/04-spsc-queue.json`, find the `notes` field, edit the string to `"Sweep: 12 log-spaced steps 100 kHz→50 MHz."` (or whatever the actual capture parameters were — confirm against the shipped run data first). One-line text change, no rebuild.
- **(b) Recapture.** Roll into the recapture pass for whatever else might trigger it.

Path (a) is the pragmatic answer if demo 04 isn't being recaptured for other reasons. The script fix in §4.1 ensures the notes field will be correct on the *next* capture, whenever that happens.

### 4.3 Visibility check

Confirm whether the JSON's `notes` field is consumed anywhere in the site (rendered in the post page, used in a tooltip, etc.). Quick grep:

```bash
grep -rn "\.notes" site/src/ | grep -v node_modules
```

If displayed: the wrong text is visible to readers and the manual edit in §4.2(a) is urgent. If not displayed: cosmetic data correctness only.

---

## 5. Out of scope

- **Other pre-demo-5 bench findings.** Preflight checks → brief 2 (done). DRY cleanup → brief 3. Visible `ns_per_op` bug → brief 1 (done).
- **Demo 02 in-binary `check_smt_off` silent-skip warning (review finding N2).** Folds into the minor cleanup brief (9).
- **Adding programmatic invariants to `sanity_check.py`** (e.g. "all sweep rows must have non-zero drift, or the assertion fails"). Future quality-of-life, not blocking.
- **Mandatory recapture of demo 02 or demo 04 for this brief alone.** All three fixes are forward-protection; historical data stays in place. Recapture decisions are per-demo and combined with brief 1's cross-demo audit outcome.

---

## 6. Acceptance checklist

### C2 — sweep drift

- [ ] `bench/demos/04-spsc-queue/benchmark.cpp` calls `calibrate_tsc()` after each sweep step and uses the result to compute per-step `drift`.
- [ ] Per-step `calibration_drift_pct` in any new demo 04 JSON shows non-zero values (typically <0.01% on a stable Zen 2; presence of the field with a real number is what matters).
- [ ] `assemble_results_04.py`'s `if drift > 0.1: FLAG` path is now reachable for sweep data (verified by manual injection or just inspection of the new field values).
- [ ] (Optional) demo 04 re-captured to refresh sweep data with the drift check active.

### M5 — l1d.replacement

- [ ] `perf list | grep -i l1d` output on the reference machine confirms the available event name(s).
- [ ] `tools/perf_capture.sh` includes the most-specific available l1d event in the `-e` list.
- [ ] `parse_perf.py` fallback chain unchanged (still tries `l1d.replacement` then `L1-dcache-load-misses`).
- [ ] (Optional) demo 02 re-captured; new JSON has non-null `l1d_misses_per_op`.

### M6 — assembler notes

- [ ] `assemble_results_04.py` derives the `notes` string from sweep run data (step count + min/max rate) rather than hardcoding.
- [ ] Shipped `04-spsc-queue.json` `notes` field corrected — either manually edited to match actual parameters (12 steps, 100 kHz→50 MHz) or refreshed via recapture.
- [ ] `grep -rn "\.notes" site/src/` checked; if the field is rendered anywhere, the manual correction is in place before the next deploy.

### Cross-cutting

- [ ] No JSON file is invalidated by this brief; any recapture decisions are explicit and documented.
- [ ] No demo binary is re-built unless a recapture is undertaken.
