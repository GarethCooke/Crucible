# Crucible — bench preflight checks brief

**Pre-demo-5 brief 2 of 9. Forward-protection only — no historical data is invalidated.**

---

## 1. Context

`bench/scripts/run_one.sh` enforces some pre-capture preconditions but not others. The current state, by demo:

| Precondition           | demo 01                 | demo 02                         | demo 03        | demo 04        |
| ---------------------- | ----------------------- | ------------------------------- | -------------- | -------------- |
| `CRUCIBLE_TURBO=off`   | ✓ (run_one.sh)          | ✓ (run_one.sh)                  | ✓ (run_one.sh) | ✓ (run_one.sh) |
| Governor = performance | ✓ (run_one.sh → lib.sh) | ✓                               | ✓              | ✓              |
| SMT disabled           | ✗                       | ✓ (in-binary `check_smt_off()`) | ✗              | ✗              |
| Isolated cores         | ✗                       | ✓ (`tools/perf_capture.sh`)     | ✗              | ✗              |

Demo 02 enforces SMT-off and isolation through paths the other three demos don't share: an in-binary check at `false_sharing_pnl.cpp:79–93` and a check in `tools/perf_capture.sh:42–53`. Demos 01, 03, 04 inherit neither — they rely on `cset shield` at runtime, which migrates existing tasks but cannot prevent timer ticks or interrupts on non-isolated cores, and which says nothing about SMT.

Impact if a future capture runs with SMT on or without `isolcpus=`:

- **Demo 01** — branch-miss and IPC counter readings are the post's headline. SMT sibling-thread contention on decode and execution units would corrupt both. Silent contamination, no script-level guard.
- **Demo 03** — GFLOPS numbers are the post's headline. SMT resource contention can deflate them. Same silence.
- **Demo 04** — TSC-paced latency measurements are the post's headline. Non-isolated cores receiving timer ticks would inject latency outliers attributable to the kernel rather than the queue.

This is forward-protection. **All four demos already captured under verified-good machine state** — see §2.

---

## 2. Why no re-capture is required

The four current JSONs were captured in a single session on a single boot. Demo 02's in-binary `check_smt_off()` is an unconditional abort: if SMT had been on at capture time, `false_sharing_pnl` would have refused to run and demo 02's JSON would not exist in its current form. It does exist and shows the expected ~341× / ~21× ratios — therefore SMT was off when demo 02 ran. The same boot served demos 01, 03, 04, so SMT was off for those captures too.

The same argument applies to isolation: `tools/perf_capture.sh` aborts if `/sys/devices/system/cpu/isolated` doesn't match the expected value, and demo 02's JSON exists. The machine was booted under the benchmark GRUB entry with `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` for the demo 02 capture; the other three captures, on the same boot, inherited the same kernel cmdline.

The scripts get the new checks. No JSON is invalidated. No demo is re-captured for this brief.

---

## 3. Goals

- Future `run_one.sh` invocations refuse to proceed if SMT is on or if isolated-cores state doesn't match the methodology.
- The checks live in one place (`lib.sh`), are called from one place (`run_one.sh`), and produce a clear remediation message on failure.
- Demo 02's in-binary `check_smt_off()` stays (belt-and-braces redundancy is desired here, not a duplication concern).

---

## 4. Patch `bench/scripts/lib.sh`

Add two helper functions alongside the existing `set_governor_performance()`. Match its style.

### 4.1 `assert_smt_off`

```bash
# Aborts unless SMT is disabled. Reads /sys/devices/system/cpu/smt/active.
#   "0" = SMT off                        → proceed
#   "1" = SMT on                         → abort with remediation
#   file missing (no CONFIG_SCHED_SMT)   → warn and proceed (kernel lacks SMT)
assert_smt_off() {
    local smt_path=/sys/devices/system/cpu/smt/active
    if [[ ! -r "$smt_path" ]]; then
        echo "WARNING: $smt_path not readable — SMT check skipped (kernel may lack CONFIG_SCHED_SMT)" >&2
        return 0
    fi
    local active
    active=$(<"$smt_path")
    if [[ "$active" != "0" ]]; then
        echo "ERROR: SMT is enabled (smt/active=$active). Disable in BIOS or run:" >&2
        echo "  echo off | sudo tee $smt_path" >&2
        exit 1
    fi
}
```

The "kernel lacks SMT" path mirrors the demo 02 in-binary check's tolerance for unsupported kernels (review finding N2 also flagged that the silent-skip there should print a warning; this implementation does).

### 4.2 `assert_isolated_cores`

```bash
# Aborts unless /sys/devices/system/cpu/isolated matches the expected mask.
# Expected value is configurable to track methodology changes in one place.
EXPECTED_ISOLATED="${EXPECTED_ISOLATED:-0-7}"

assert_isolated_cores() {
    local iso_path=/sys/devices/system/cpu/isolated
    local actual
    actual=$(<"$iso_path" 2>/dev/null || echo "")
    if [[ "$actual" != "$EXPECTED_ISOLATED" ]]; then
        echo "ERROR: isolated cores mismatch — got '$actual', expected '$EXPECTED_ISOLATED'." >&2
        echo "Boot under the benchmark GRUB entry with isolcpus=$EXPECTED_ISOLATED nohz_full=$EXPECTED_ISOLATED rcu_nocbs=$EXPECTED_ISOLATED." >&2
        exit 1
    fi
}
```

The `EXPECTED_ISOLATED` env-var default tracks the current methodology page (`isolcpus=0-7`). If the methodology changes (e.g. back to `4-7`), update the default here — single source of truth.

---

## 5. Patch `bench/scripts/run_one.sh`

Call both new asserts immediately after the existing `CRUCIBLE_TURBO` check and before any demo-specific branching. Order: turbo → SMT → isolation → governor → demo-specific.

```bash
# After the existing CRUCIBLE_TURBO check (around line 45–58):
assert_smt_off
assert_isolated_cores
set_governor_performance
```

No demo-specific branching for these — same check applies to all four (and to demo 5+).

---

## 6. Behaviour summary

Each precondition produces the same failure-mode shape: print an `ERROR: …` line naming the violation, print a remediation line showing the exact command or boot step to fix it, then `exit 1`. Matches the established `CRUCIBLE_TURBO` failure style.

A `run_one.sh 01-branch-prediction` invocation on a machine booted under the non-benchmark GRUB entry will now fail at the second check (isolation) rather than silently producing contaminated data.

---

## 7. Out of scope

- **`tools/perf_capture.sh` harmonisation.** Currently has its own isolation check at lines 42–53. Could be replaced by sourcing `lib.sh` and calling `assert_isolated_cores`, plus adding `assert_smt_off`. Not in this brief because the `tools/` scripts are a separate orchestration path; harmonising them would touch demo 02's working capture flow without functional change. Worth a separate small brief or a fold into the DRY-cleanup pass (brief 3).
- **Demo 02's in-binary `check_smt_off()`.** Stays as-is. Redundant with the new script-level check, intentionally so — defence in depth at the binary level is valuable because it catches the case where someone runs the binary directly without going through `run_one.sh`. (Review finding N2 — the silent-skip behaviour on missing sysfs — is folded into brief 9, the minor cleanup pass.)
- **Pre-existing-state preservation for governor.** `set_governor_performance()` currently writes the governor unconditionally rather than checking first (bench review M11 footnote). The current behaviour is correct for its purpose; if "don't overwrite a pre-existing `performance` governor" becomes desired, that's a separate small change.
- **Re-capture of any demo.** Not required (see §2).

---

## 8. Acceptance checklist

- [ ] `bench/scripts/lib.sh` exports `assert_smt_off` and `assert_isolated_cores`.
- [ ] `EXPECTED_ISOLATED` default in `lib.sh` matches the value asserted on the methodology page (`0-7` as of this brief).
- [ ] `bench/scripts/run_one.sh` calls `assert_smt_off`, `assert_isolated_cores`, `set_governor_performance` in that order, before any demo-specific code.
- [ ] Manual smoke test: on the reference machine in benchmark-boot state, `./run_one.sh 01-branch-prediction` proceeds past the new checks without error.
- [ ] Manual smoke test: temporarily set `EXPECTED_ISOLATED=1-7` (mismatch) and confirm `run_one.sh` aborts with the expected remediation message; revert.
- [ ] No JSON file under `site/src/data/perf/` is modified by this brief.
- [ ] No demo binary is re-built or re-captured by this brief.
