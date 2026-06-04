# Crucible — boost detection rework for acpi-cpufreq (Machine 1 rig)

CC brief, branch `fix/turbo-off-recapture`. Supersedes the boost-detection logic in the prior boost-off remediation (`machine_info.h`, `lib.sh`, `verify_boost_off.sh`). That logic assumed signals that **do not exist on the actual Machine 1 rig** (`gcooke@iguanabunt`): it keyed off amd_pstate `base_frequency` and the global `/sys/.../cpufreq/boost`, and used `lscpu` MAXMHZ as ground truth. On this box none of those hold. This brief retargets detection at the signals that are present and honest here.

## Context — verified on the rig (acpi-cpufreq, Ryzen 7 3800X)

Boost is genuinely OFF (BIOS CPB disabled; under-load clock pinned at 3900 MHz on isolated cores). The reliable signals, confirmed by direct inspection:

- **`/sys/devices/system/cpu/cpu*/cpufreq/cpb` = `0`** — per-CPU Core Performance Boost flag. Present on every CPU incl. isolated core cpu4. `0`=off, `1`=on. **Authoritative.**
- **`/sys/devices/system/cpu/cpufreq/policy*/scaling_available_frequencies` tops at `3900000`** (full list `3900000 2800000 2200000`) — highest real P-state = base. With CPB on this list includes the boost frequency; with CPB off it caps at base. **Reliable secondary.**
- **`/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq` = `4560055`** and **`lscpu` MAXMHZ = `4560`** — the silicon boost ceiling. **Stays 4560 regardless of CPB state on this board** — cosmetic, must not gate.
- **`/sys/devices/system/cpu/cpufreq/boost` — ABSENT** (acpi-cpufreq exposes boost per-policy/per-CPU, not globally).
- **amd_pstate `base_frequency` — ABSENT** (acpi-cpufreq does not expose it); so the existing `freq_compare` path never fires here and falls through.

Consequence of the current code as-is on this rig: the gate's MAXMHZ-vs-base cross-check can't run (no base), `machine_info.h` would resolve `turbo` via the global boost node (absent) → `null` or wrong, and `verify_boost_off.sh`'s `freq_max_mhz < 4000` check would **fail every honest boost-off capture** (freq_max reads 4560). All three must change.

## Tasks

### Task 1 — `machine_info.h`: new detection priority

Replace the boost-resolution logic with this priority order. Record which signal won in `turbo_source`.

1. **Per-CPU `cpb`** — read `/sys/devices/system/cpu/cpuN/cpufreq/cpb` (try cpu0; if the process is pinned, prefer an isolated core but cpu0 is fine for a machine-wide flag). If present: `0` → `turbo:false`, `1` → `turbo:true`. `turbo_source="cpb"`. **Highest priority.**
2. **`scaling_available_frequencies` top vs base** — parse `/sys/.../cpufreq/policy0/scaling_available_frequencies`; take the max entry (KHz→MHz). If a base reference is available (see below) and the top is within ~5% of base → `turbo:false`; if the top materially exceeds base → `turbo:true`. `turbo_source="scaling_avail_freq"`.
3. **Global `cpufreq/boost`** — existing `boost_from_cpufreq_boost()`; `turbo_source="cpufreq/boost"`. (Absent on this rig; kept for other machines.)
4. **Fallback** → `turbo:null`, `turbo_source="unavailable"`.

Add fields:

- `freq_max_advertised_mhz` — the `cpuinfo_max_freq`/lscpu MAXMHZ value (4560 here). **Advisory only**, recorded never gated. Rename/repurpose the existing `freq_max_mhz` to this, with a comment: _"advertised silicon ceiling; on acpi-cpufreq this stays at the boost ceiling even when CPB is off — do not use to infer boost state."_
- `freq_max_available_mhz` — the top of `scaling_available_frequencies` (3900 here). This is the value that **does** track boost state.
- keep `freq_base_mhz` (amd_pstate base; null on acpi-cpufreq — fine).

Base reference for step 2: use `freq_base_mhz` if present (amd_pstate); else the lowest-plausible base can't be derived cleanly on acpi-cpufreq, so if step 1 (`cpb`) succeeded, step 2 is not needed. Step 2 only matters on a hypothetical box with neither `cpb` nor amd_pstate base — acceptable to leave it best-effort there.

### Task 2 — `lib.sh` `assert_boost_off`: gate on cpb / scaling-freq, not MAXMHZ

Rework the gate priority to mirror Task 1:

1. If any `/sys/devices/system/cpu/cpu*/cpufreq/cpb` reads `1` → FATAL (boost on). If all readable `cpb` read `0` → pass.
2. Else if global `cpufreq/boost` == `1` → FATAL.
3. Else if `scaling_available_frequencies` top materially exceeds base (where base is derivable) → FATAL.
4. **Remove the MAXMHZ-vs-base cross-check as a hard gate** — on acpi-cpufreq MAXMHZ is the cosmetic 4560 and base is absent, so it produces false aborts. MAXMHZ may be printed for information only.
   Keep the `CRUCIBLE_ALLOW_BOOST=1` override. The gate must still degrade safely on the Pi (no `cpb`, no global boost, no amd_pstate base → no signal → pass, not fail-closed).

### Task 3 — `verify_boost_off.sh`: drop the freq_max<4000 gate

- **Remove** the `freq_max_mhz < 4000` failure condition entirely — it false-fails honest captures on this rig.
- **Remove** the `lscpu_extended MAXMHZ >= 4500` failure condition — same reason (MAXMHZ is legitimately 4560 with boost off here).
- **Add** the real checks: `machine.turbo == false` (already present, keep), AND `machine.turbo_source` is a trustworthy signal — pass when `turbo_source` ∈ {`cpb`, `scaling_avail_freq`, `cpufreq/boost`}; FAIL when `unavailable` or missing.
- **Add**: `freq_max_available_mhz` present and at/near base (e.g. < 4000) — this is the honest ceiling and _should_ be ~3900. (Note: this is the available-freq top, NOT the advertised silicon ceiling.)
- Keep: well-formed JSON; missing Machine 1 file = FAIL; per-demo PASS line printing `turbo`, `turbo_source`, `freq_max_available_mhz`, and (advisory) `freq_max_advertised_mhz`.

## Acceptance

- On the rig (boost off): a fresh capture's machine block reads `turbo:false`, `turbo_source:"cpb"`, `freq_max_available_mhz:3900`, `freq_max_advertised_mhz:4560`. Confirm by inspecting a real captured block.
- `assert_boost_off` **passes** on the rig as currently configured (cpb=0), and **aborts** if any `cpb` reads 1 (test by temporarily checking against a forced value or a unit stub — do not require re-enabling BIOS boost).
- `verify_boost_off.sh` **passes** the rig's honest boost-off capture (freq_max_advertised 4560 no longer fails it), and still FAILS: turbo!=false, turbo_source unavailable/missing, missing file, or freq_max_available >= 4000.
- Pi/ARM: header → `turbo:null`, `turbo_source:"unavailable"`, no crash; gate → passes (no fail-closed).

## Out of scope

- The corpus recapture itself (USER, gated on this landing), MDX prose patching, the methodology correction note, the quantum edition.
- Re-enabling BIOS boost to test the `cpb==1` path — use a stub/forced value; do not touch the rig BIOS.

## Open items for CC to flag

- If `cpb` is readable but its semantics differ from `0=off/1=on` on any tested kernel, flag rather than assume.
- Confirm the renderer tolerates the renamed/added fields (`freq_max_advertised_mhz`, `freq_max_available_mhz`) and `turbo_source` values before merge — the site footer consumes the machine block.
- If parsing `scaling_available_frequencies` for the top entry, note units are KHz; guard against empty/space-only content.
