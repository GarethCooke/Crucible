# Crucible — pre-demo-5 audit closeout brief

Companion to `BRIEF.md`, `crucible-handover.md`, and `pre-demo-5-cleanup-audits-brief.md`. Closes out the remaining items from task 1 of the pre-demo-5 review (JSON machine-block audit).

This brief picks up after the user has recaptured demos 02 and 03 on the reference machine. Demo 03's regenerated JSON has already been verified clean. Demo 02 is the open question — see Preconditions.

## Preconditions

**Verify demo 02 first.** Before doing anything else, inspect `site/src/data/perf/02-false-sharing-pnl.json` and confirm all of the following hold:

- `captured_at` is an ISO 8601 timestamp postdating `2026-05-16T20:42:00Z` (the harness patch commit `8e35e3c`).
- No `compiler_flags` field at the machine level (per-variant `runs[].compile_flags` is fine and expected).
- Legacy fields `isolated_cores` (array) and `smt_active` are **absent** from the machine block.
- The patched-harness fields are **present** in the machine block: `isolated_cpus_requested`, `isolated_cpus_effective`, `isolated_cpus_source`, `cpu_affinity`, `lscpu_extended`.
- `turbo` is `false`.
- `governor` is `"performance"`.
- `isolated_cpus` is `"1-7"` (with the sub-fields above documenting the requested-vs-effective gap).

If **any** of these fail, **stop**. Do not proceed with the rest of the brief. Instead, write a short note to `pre-demo-5-json-audit-findings.md` under a new `## Demo 02 — recapture verification` section stating which preconditions failed and quoting the offending field values. The user will re-run the capture before this brief is re-handed.

Common failure modes worth surfacing in the failure note:

- Bench binary not rebuilt against the patched `bench/common/machine_info.h` (run `cmake --build build --clean-first`).
- Capture script ran but wrote to a different path (check `run_one.sh` output for the destination filename).
- Not booted into the benchmark GRUB entry (verify `cat /sys/devices/system/cpu/isolated` returns `0-7`).
- `CRUCIBLE_TURBO` not exported before invocation.

If all preconditions hold, proceed to Tasks.

## Tasks

### 1. Update `notes` field in `01-branch-prediction.json`

The original audit flagged that the top-level `notes` field doesn't explicitly state the cpu0 limitation, even though the machine-block sub-fields (`_requested`/`_effective`/`_source`) document it. Add a sentence.

In `site/src/data/perf/01-branch-prediction.json`, append to the **top-level** `notes` field (the one on the root object, not the per-run `notes` strings inside `runs[]`):

> `cpu0 cannot be kernel-isolated on this machine; effective isolcpus is 1-7.`

Preserve all existing content in the `notes` field — only append.

### 2. Update `notes` field in `04-spsc-queue.json`

Same edit as Task 1, on `site/src/data/perf/04-spsc-queue.json`. Append the same sentence to the top-level `notes` field.

Do not modify the per-run `notes` strings — only the top-level field.

### 3. Update `pre-demo-5-json-audit-findings.md`

Rewrite the findings file to reflect the post-closeout state. Structure:

- Preserve the header paragraph (audit context, harness patch reference).
- Update the results table so all four demos read **PASS**. Drop the "(with flag)" qualifier from demos 01 and 04 since their `notes` now carries the cpu0 statement.
- Condense the per-demo detail sections. A one-line "all required fields pass" per demo is fine.
- Remove the "Corrective action" subsection for demo 02 entirely.
- Update the Summary table to reflect that all required actions are complete.

Append a new section at the bottom:

```
## Closeout history

- 2026-05-18: Initial audit. Demo 02 failed (machine-level compiler_flags present, captured_at pre-patch). Demos 01 and 04 flagged for low-priority notes-field updates.
- <recapture-date>: Demo 02 recaptured by user. Demo 03 also recaptured to normalize schema (was missing isolated_cpus_requested/_effective/_source sub-fields).
- <closeout-date>: notes fields updated in demos 01 and 04. Audit findings updated to all-pass. Task 1 of pre-demo-5-review closed.
```

Fill in the dates from filesystem mtimes or from your local environment's date.

### 4. Update `pre-demo-5-review-tasks.md`

In the task table, change the Status column for task 1 from `☐` to `☑`. Leave the task text and all other rows unchanged.

## Acceptance

- All four demo JSONs (`01-branch-prediction.json`, `02-false-sharing-pnl.json`, `03-simd-blackscholes.json`, `04-spsc-queue.json`) have:
  - No machine-level `compiler_flags` field.
  - `turbo: false`.
  - `governor: "performance"`.
  - `captured_at` postdating `2026-05-16T20:42:00Z`.
  - The patched-harness sub-fields (`isolated_cpus_requested`, `_effective`, `_source`, `cpu_affinity`, `lscpu_extended`).
- Top-level `notes` in `01-branch-prediction.json` and `04-spsc-queue.json` includes the cpu0 statement.
- `pre-demo-5-json-audit-findings.md` shows all four demos passing and carries a Closeout history section.
- `pre-demo-5-review-tasks.md` task 1 marked ☑.

## Out of scope

- Recapturing any JSON (precondition; user task on the reference machine).
- Modifying any `runs[]` data, per-variant `compile_flags`, or per-run `notes` strings.
- Updating any post MDX prose (separate Opus task — hostile cross-read).
- Methodology page changes (separate Opus task).
- Any other task in `pre-demo-5-review-tasks.md`.

## Open items for CC to flag

- If demo 02's recaptured JSON satisfies the audit but has additional drift not covered by the precondition list (a field present that isn't in demos 01, 03, 04, or vice versa), flag it in the findings doc rather than silently editing.
- If the `notes` fields in demos 01 or 04 already contain the cpu0 statement (perhaps from a prior pass), skip that task and note it.
- If `pre-demo-5-json-audit-findings.md` has been edited by a human since the initial audit (the file has unexpected content beyond the original CC output), pause and report rather than overwrite.
