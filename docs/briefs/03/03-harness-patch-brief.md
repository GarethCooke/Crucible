# Crucible — harness patch brief (turbo misreporting, related cleanup)

## Context

Demo 3 skeptical review surfaced two methodology violations rooted in the harness, not the demo code:

1. **JSON reports `turbo: true` while BIOS Core Performance Boost is actually off.** `machine_info.h` reads `/sys/devices/system/cpu/cpufreq/boost`, which doesn't exist on this AMD / `acpi-cpufreq` driver combination. The `|| echo 1` fallback fires and the field defaults to `true`. Verified independently via `cpupower frequency-info` reporting `Active: no`.
2. **Machine-level `compiler_flags` field is filled from `$CXXFLAGS`** (empty in normal use) and falls back to a hardcoded `"-O3 -march=native"` which contradicts per-variant `runs[].compile_flags` for multi-variant demos.

Demos 1, 3, 4 captured with these defects; demo 2's JSON happens to be correct (likely captured under a path where the boost file existed). The patches below subsume both cases. Reruns of demos 1, 3, 4 with the patched harness will follow under their own review passes — not in scope here.

The methodology page also needs a small update: it currently asserts `isolcpus=4-7` but the machine now boots with `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7`. Both are valid isolation patterns; the doc needs to match physical reality.

## Goals

- `machine_info.h` stops asserting unobserved facts. Where state can't be determined from inside the C++ process, the JSON gets `null`.
- `run_one.sh` enforces turbo verification before any benchmark binary runs; fails loud if state is indeterminate.
- Methodology page matches the running kernel's actual cmdline.

## Scope

### 1. `bench/common/machine_info.h` — turbo detection via env var

Replace the existing turbo block. The C++ harness has no reliable way to detect AMD CPB state across `acpi-cpufreq` versions, so verification moves to the orchestrating shell script (which is already the right place for methodology enforcement) and the result is passed in via `CRUCIBLE_TURBO`.

```cpp
// REMOVE:
const auto turbo_r = shell("cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo 1");
// ...
const bool turbo_on = (turbo_r != "0");
// ...
"\"turbo\":" + (turbo_on ? "true" : "false") + ","

// REPLACE WITH:
const auto turbo_env = shell("echo \"$CRUCIBLE_TURBO\"");
std::string turbo_field;
if      (turbo_env == "off") turbo_field = "false";
else if (turbo_env == "on")  turbo_field = "true";
else                          turbo_field = "null";   // caller did not verify
// ...
"\"turbo\":" + turbo_field + ","
```

### 2. `bench/common/machine_info.h` — drop machine-level compiler_flags

Delete the field and its source variable entirely. Per-variant flags already live in `runs[].compile_flags`; the machine-level field has never carried accurate information.

```cpp
// DELETE the variable:
const auto flags    = shell("echo \"$CXXFLAGS\"");

// DELETE the JSON line:
"\"compiler_flags\":\"" + (flags.empty() ? "-O3 -march=native" : flags) + "\","
```

### 3. `bench/scripts/run_one.sh` — turbo verification before capture

Add this block early in the script, before any benchmark binary is invoked. If `CRUCIBLE_TURBO` is already set in the environment when the script starts, respect it and skip the cpupower check — this allows manual override on machines without `cpupower` available.

```bash
# Verify turbo state and export for machine_info.h to consume.
# Caller can pre-set CRUCIBLE_TURBO=on|off to override (e.g. on systems
# without cpupower); otherwise we derive it from cpupower output.
if [ -z "${CRUCIBLE_TURBO:-}" ]; then
    boost=$(cpupower frequency-info 2>/dev/null \
        | awk '/boost state support/{flag=1; next} flag && /Active/{print tolower($2); exit}')
    case "$boost" in
        no)  export CRUCIBLE_TURBO=off ;;
        yes) export CRUCIBLE_TURBO=on  ;;
        *)
            echo "FATAL: cannot determine turbo state from cpupower" >&2
            echo "Run 'cpupower frequency-info' and verify manually," >&2
            echo "then export CRUCIBLE_TURBO=on|off before invoking this script." >&2
            exit 1
            ;;
    esac
fi
echo "CRUCIBLE_TURBO=$CRUCIBLE_TURBO (verified)" >&2
```

The `echo` to stderr is intentional — leaves an audit trail in run logs without polluting JSON output on stdout.

### 4. Methodology page — isolation update

Wherever the methodology page (and the README, if it duplicates the claim) says `isolcpus=4-7`, replace with copy along these lines:

> Cores 0–7 are isolated from the kernel scheduler's load-balancing domains via `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` boot parameters. Benchmarks pin to cores 4–7 within the isolated set via `taskset`; cores 0–3 absorb residual kernel housekeeping that the isolation directives don't redirect elsewhere.

Don't leave the original `isolcpus=4-7` claim in the doc — that configuration is no longer what the machine boots with.

### 5. (Flag only — do not implement) `ns_per_op` field semantics

The schema in `BRIEF.md` defines `ns_per_op` as nanoseconds per option. Demo 3's JSON shows values like 50,071,687 at N=1M — clearly per-iteration over the whole batch, not per-element. This is a pre-existing inconsistency that may affect chart components and other demos. **Do not change this in this brief.** Flag it in your handover notes for a follow-up brief that audits all chart components consuming the field.

## Acceptance criteria

- `bench/common/machine_info.h` compiles cleanly, builds for all demos without warning.
- A benchmark binary invoked with no `CRUCIBLE_TURBO` exported and no cpupower available produces JSON with `"turbo": null`.
- A benchmark binary invoked with `CRUCIBLE_TURBO=off` exported manually produces JSON with `"turbo": false` and no `compiler_flags` field anywhere in the machine block.
- `./scripts/run_one.sh 03-simd-blackscholes` on the reference machine (where `cpupower` reports `Active: no`) succeeds, prints `CRUCIBLE_TURBO=off (verified)` to stderr, and produces JSON with `"turbo": false`.
- `./scripts/run_one.sh` on a machine with neither cpupower nor a pre-set env var exits non-zero with the FATAL message and does NOT produce a JSON file.
- Methodology page and README no longer mention `isolcpus=4-7`.

## Out of scope

- Reruns of demos 1, 3, 4 with the patched harness — those are tracked separately and will run after this brief lands.
- Demo 2's JSON does not need re-capture (already correct on affected fields).
- Schema cleanup for `ns_per_op` semantics (deferred to its own brief).
- Older demo JSONs retaining the now-deprecated `compiler_flags` field is acceptable — they'll be regenerated when those demos are re-captured.

## Open questions for CC to flag during implementation

- Audit `site/src/components/charts/` and any MDX post: does any chart component or post body read `machine.compiler_flags`? If yes, stop and report back — that consumer needs handling before this lands.
- Identify every place in human-readable copy (methodology page, README, any post) that mentions `isolcpus=4-7` and list them in your PR description so the doc fix is comprehensive.
- Confirm `run_one.sh` doesn't already export `CRUCIBLE_TURBO` somewhere — if it does, reconcile.
