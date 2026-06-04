# Crucible — boost-off recapture plan (Machine 1 corpus)

Remediation plan brief. Owners are marked per task (CC = code, USER = rig, OPUS = downstream). Triggered by the audit finding: demos 06/07/08 (and by inference the whole Machine 1 corpus) were captured with Core Performance Boost **enabled** while their machine blocks asserted `turbo: false` and the methodology claimed "turbo off (BIOS)." Evidence: every captured `lscpu_extended` shows `MAXMHZ 4560`, which with boost actually off would read base (~3900); the live rig confirms 4560. This brief makes the rig state honest, hard-gates it so it can't recur silently, and recaptures the corpus at the controlled base clock. Companion: `BRIEF.md` (capture conventions), the three audited JSONs.

## Context

- The `turbo` field in the machine block is **derived wrong** — it asserted the expected value and was never validated against the `lscpu` captured beside it. The raw `lscpu_extended` was honest; the derived field was not. That is the bug to fix, and the lesson to encode.
- This brief covers: the `machine_info.h` fix, a capture-time boost-state gate, the BIOS change, the recapture, and committing the new JSON. It does **not** cover patching the MDX prose (downstream OPUS phase — needs the new JSON first), the dated methodology correction note (separate brief), or the quantum special edition (separate track; its classical baseline is already captured boost-off).
- Sequencing: the `machine_info.h` fix and the gate (Tasks 1–2) land **first** and are a hard precondition for any recapture. Recapture (Task 4) can be one rig session — boost-off is a single BIOS state, no benefit to toggling per demo. The downstream MDX re-derivation is per-demo and closed one at a time (see Notes).

## Tasks

### Task 1 — Fix `machine_info.h` turbo detection (CC)
Derive `turbo` from the actual boost state, not an assertion. Read the real signal — `/sys/devices/system/cpu/cpufreq/boost` (acpi-cpufreq: 1=on/0=off) or the amd_pstate equivalent — and, as a cross-check, compare the `lscpu` MAXMHZ against base clock: if MAXMHZ materially exceeds base, boost is on regardless of what any field claims. Record both the boost state and an effective/max frequency in the machine block so this is self-evident in the data going forward. The field must agree with the `lscpu_extended` in the same block by construction.

### Task 2 — Capture-time boost gate (CC)
Add a preflight to the capture pipeline (`run_one.sh` / `run_all.sh`, alongside the `cset shield --reset` precondition) that reads the boost state and **aborts the capture if boost is enabled**, with a clear message. This is the same convention class as the `cset` precondition and the stale-JSON sentinel: a hard gate so a boosted capture can never again be taken silently while the methodology claims otherwise. Allow an explicit override flag only if the project ever deliberately captures boost-on (it does not today).

### Task 3 — Disable boost in BIOS (USER)
On the ASUS B550-F: Ai Tweaker → Core Performance Boost → Disabled (master switch; PBO-off alone is insufficient). Verify: `lscpu | grep "max MHz"` reads ~3900, not 4560. This is the precondition the Task 2 gate enforces.

### Task 4 — Recapture the corpus boost-off (USER)
With Tasks 1–2 merged and boost confirmed off, recapture all Machine 1 demos under the standard protocol (`cset shield --reset`, `multi-user.target`, performance governor, isolated cores) via `run_all.sh`. Commit the new JSON. Do this in as few sessions as practical — the BIOS state is identical for all demos.

### Task 5 — Verify the new captures (CC/USER)
For every recaptured demo's new JSON: the machine block now shows boost off **and** `lscpu` MAXMHZ ~3900 — the two agree (the contradiction is gone); `captured_at` is new; the JSON validates against its schema. The Task 2 gate having passed is itself evidence boost was off at capture.

## Acceptance

- `machine_info.h`: on the boost-off rig, the emitted machine block reports boost off and a max/effective frequency consistent with the `lscpu_extended` in the same block. On a deliberately boost-on machine (or in a unit check), it reports boost on — i.e. it tracks reality, not a constant. (Confirm by inspecting a freshly captured block, not by reading the source intent.)
- Capture gate: running a capture with boost enabled aborts before any timed run, with a message naming the boost state. (Confirm by attempting a capture boost-on and seeing it refuse.)
- Recaptured JSONs: every Machine 1 demo has a new `captured_at`, machine block boost-off, and `MAXMHZ ~3900` — `grep` across the new JSONs returns no `4560` MAXMHZ and no `turbo: false` paired with a boosted ceiling.
- All recaptured JSONs validate against their schemas.

## Out of scope

- Patching MDX prose to the new numbers — downstream OPUS phase, gated on this brief landing (the new JSON is its input).
- The dated methodology correction note — separate artifact.
- The quantum special edition and its classical baseline — separate track, already on the corrected (boost-off) standard.
- The known AArch64 `cores_physical` detection bug in `machine_info.h` — unrelated; do not fold in.

## Open items for CC to flag

- If `cpufreq/boost` isn't present or readable under the rig's cpufreq driver (acpi-cpufreq vs amd_pstate differ), **fall back to the MAXMHZ-vs-base comparison against `lscpu`** — that is the ground truth that caught this in the first place — and flag which signal you used.
- If any demo's bench no longer builds or has changed since its original capture, **stop and flag** rather than capturing a silently-different binary against the old prose.
- BIOS access and the recapture runs are USER tasks; CC's deliverables are Tasks 1–2 and the Task 5 verification logic. If CC cannot validate the fix without the live rig, build it against the captured sample blocks and flag what needs rig confirmation.

## Notes

- Recapture is batched (one boost-off rig state); the **downstream MDX re-derivation is per-demo and closed one demo at a time** — recapture-all then patch-all risks a half-patched corpus where some posts cite new numbers and some cite old. Each demo: new JSON committed → OPUS re-reads JSON vs MDX → per-demo patch brief for CC → closed → next demo. Most ratios should survive (same-session, both arms were boosted), but "should" is verified per demo, not assumed; a ratio that shifts enough to change a sentence's framing changes the prose, not just the digits.
- The methodology correction note should land in the same wave: own the discovery, state "re-verified at controlled base clock; ratios unchanged" where true.
