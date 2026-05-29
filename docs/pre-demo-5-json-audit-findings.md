# pre-demo-5 JSON machine-block audit findings

Audit of the four perf JSON files against the requirements set out in `docs/briefs/pre-demo-5-cleanup-audits-brief.md` §1.

Harness patch reference: commit `8e35e3c` (`fix(harness): correct turbo misreporting and drop spurious compiler_flags`), committed **2026-05-16T20:42:00Z**. A captured_at must post-date this timestamp to confirm the JSON was produced by the patched harness.

---

## Results table

| Demo                 | turbo      | compiler_flags (machine)         | isolated_cpus                    | governor           | captured_at                                | Verdict              | Recapture? |
| -------------------- | ---------- | -------------------------------- | -------------------------------- | ------------------ | ------------------------------------------ | -------------------- | ---------- |
| 01-branch-prediction | `false` ✅ | absent ✅                        | `"1-7"` — flag (see §01)         | `"performance"` ✅ | `2026-05-18T05:41:18Z` post-dates patch ✅ | **PASS** (with flag) | No         |
| 02-false-sharing-pnl | `false` ✅ | `"-O3 -march=native"` present ❌ | `"1-7"` + notes document cpu0 ✅ | `"performance"` ✅ | `2026-05-16T16:58:01Z` pre-dates patch ❌  | **FAIL**             | **Yes**    |
| 03-simd-blackscholes | `false` ✅ | absent ✅                        | `"0-7"` ✅                       | `"performance"` ✅ | `2026-05-17T08:31:53Z` post-dates patch ✅ | **PASS**             | No         |
| 04-spsc-queue        | `false` ✅ | absent ✅                        | `"1-7"` — flag (see §04)         | `"performance"` ✅ | `2026-05-18T06:03:14Z` post-dates patch ✅ | **PASS** (with flag) | No         |

---

## Per-demo detail

### Demo 01 — branch-prediction

All required fields pass. One flag:

**isolated_cpus flag.** `"isolated_cpus": "1-7"` is documented in the machine block via `isolated_cpus_requested: "0-7"`, `isolated_cpus_effective: "1-7"`, and `isolated_cpus_source: "cmdline+probe"`, which collectively document why the effective value differs from the requested one. However the `notes` field ("Branch predictor learns sorted patterns; unsorted forces ~50% mispredicts.") does not explicitly state that cpu0 cannot be kernel-isolated. The brief requires `notes` to carry this statement for `"1-7"` values. The machine-block sub-fields are more informative than a notes string, so this is not treated as a recapture requirement — but `notes` should be updated to add: _"cpu0 cannot be kernel-isolated on this machine; effective isolcpus is 1-7."_

**Additional drift.** Demo 01 has extra machine-block fields not present in other demos: `isolated_cpus_requested`, `isolated_cpus_effective`, `isolated_cpus_source`, `cpu_affinity`, `lscpu_extended`. These are additive and consistent with the patched harness schema. No action needed.

---

### Demo 02 — false-sharing-pnl

**Two failures requiring recapture.**

1. **compiler_flags at machine level.** `"compiler_flags": "-O3 -march=native"` is present in the machine block. The patched harness drops this field at the machine level (per-variant flags belong in `runs[].compile_flags`). This field is absent from demos 01, 03, and 04.

2. **captured_at pre-dates harness patch.** `"captured_at": "2026-05-16T16:58:01+00:00"` (16:58 UTC) is ~3h 44m before the patch commit (`8e35e3c`, 20:42 UTC). The JSON was produced by the pre-patch harness.

**Additional drift.** Demo 02's machine block has `isolated_cores` (an array of ints) and `smt_active` fields not present in other demos. These are legacy fields from the pre-patch harness. Recapture with the patched harness should resolve them.

**isolated_cpus.** `"1-7"` — the `notes` field explicitly states "cpu0 cannot be kernel-isolated", satisfying the brief requirement. No action needed here if recaptured on the same machine.

#### Corrective action

Boot into the second GRUB entry: **"Ubuntu (benchmark — cores 0-7 isolated)"** (kernel cmdline: `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7`).

```bash
# After boot into benchmark GRUB entry:
sudo cpupower frequency-set -g performance

# Verify turbo off:
cpupower frequency-info | grep "Active: no"

# Set turbo env var for this session:
export CRUCIBLE_TURBO=off

# Capture:
./bench/scripts/run_one.sh 02-false-sharing
```

Expected outcome: the regenerated JSON will have no `compiler_flags` at the machine level, a `captured_at` post-dating the patch, and `CRUCIBLE_TURBO`-sourced turbo state.

---

### Demo 03 — simd-blackscholes

All required fields pass. No flags.

Per-variant `compile_flags` fields are present in `runs[]` entries — this is the correct post-patch location. No machine-level `compiler_flags` field present.

`isolated_cpus: "0-7"` is the expected value post-GRUB-entry rollout and matches the full kernel isolation range.

---

### Demo 04 — spsc-queue

All required fields pass. One flag identical to demo 01:

**isolated_cpus flag.** `"isolated_cpus": "1-7"` is documented via `isolated_cpus_requested: "0-7"`, `isolated_cpus_effective: "1-7"`, and `isolated_cpus_source: "cmdline+probe"` in the machine block. The `notes` field ("Producer pinned to core 4, consumer to core 5...") does not explicitly state that cpu0 cannot be kernel-isolated. Same situation as demo 01 — the machine-block sub-fields carry the information; `notes` should be updated to add the cpu0 statement but recapture is not required.

**Additional drift.** Demo 04 has extra machine-block fields (`isolated_cpus_requested`, `isolated_cpus_effective`, `isolated_cpus_source`, `cpu_affinity`, `lscpu_extended`, `tsc_ns_per_cycle`) not present in all demos. These are additive and consistent with the patched harness schema. No action needed.

---

## Summary

| Action                                                                                                                                             | Owner                                                                |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Recapture 02-false-sharing on the reference machine (see corrective action above)                                                                  | User (reference machine)                                             |
| Optionally update `notes` in 01-branch-prediction.json and 04-spsc-queue.json to state "cpu0 cannot be kernel-isolated; effective isolcpus is 1-7" | User (low priority — machine-block sub-fields already document this) |

---

## Demo 02 — recapture verification

Checked 2026-05-18 against preconditions from `pre-demo-5-audit-closeout-brief.md`. Demo 02 **fails**; the user must recapture before closeout can proceed.

**Failed preconditions:**

1. **`captured_at` pre-dates patch.** Value: `"2026-05-16T16:58:01+00:00"` (~16:58 UTC). Required: post-dates `2026-05-16T20:42:00Z`. Delta: ~3 h 44 m before the patch commit.

2. **`compiler_flags` present at machine level.** Value: `"compiler_flags": "-O3 -march=native"`. The patched harness drops this field from the machine block.

3. **Legacy fields present.** Both `isolated_cores` (array: `[1,2,3,4,5,6,7]`) and `smt_active` (`0`) are present. These must be absent from a post-patch capture.

4. **Patched-harness fields absent.** None of `isolated_cpus_requested`, `isolated_cpus_effective`, `isolated_cpus_source`, `cpu_affinity`, `lscpu_extended` are present in the machine block.

**Action:** Recapture on the reference machine using the patched harness (see §Demo 02 — Corrective action above). Re-hand this brief after recapture.
