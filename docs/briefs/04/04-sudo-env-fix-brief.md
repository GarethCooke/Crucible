# Crucible — `run_one.sh` env-var propagation fix

## Context

The previous harness patch (machine_info.h env-var-driven turbo detection + run_one.sh cpupower verification block) landed correctly. Verified on the reference machine:

- `grep -n CRUCIBLE_TURBO bench/scripts/run_one.sh` shows the verification block in place.
- Running `./scripts/run_one.sh 03-simd-blackscholes` prints `CRUCIBLE_TURBO=off (verified)` to stderr.
- No FATAL path hit.

But the resulting JSON still reports `"turbo": null` instead of `"turbo": false`. Diagnosis: `sudo` strips environment variables by default, so every `sudo cset shield --exec -- BINARY` invocation in the script drops `CRUCIBLE_TURBO` before the benchmark binary inherits it. The script's own shell has the variable set; the C++ process never sees it; `machine_info.h`'s `echo "$CRUCIBLE_TURBO"` returns empty; the null-state branch fires.

## Goal

Preserve `CRUCIBLE_TURBO` (and any future env vars the harness might rely on) across the sudo boundary, so `machine_info.h` sees the value `run_one.sh` exports.

## Scope

Add `-E` to every `sudo` invocation in `bench/scripts/run_one.sh` that executes a benchmark binary. The `sudo cset shield --cpu=...` and `sudo cset shield --reset` invocations don't strictly need it (they don't run the binary), but adding `-E` uniformly is harmless and avoids the next person making the same mistake on a different invocation.

### Lines requiring the change

```
83:    sudo cset shield --exec -- "${VERIFY_BIN}" | grep -v '^cset:'
90:    MACHINE_JSON=$(sudo cset shield --exec -- "${BS_BINARY}" --machine-info \
97:    sudo cset shield --exec -- "${BS_BINARY}" \
130:    sudo cset shield --exec -- "${SPSC_BINARY}" --stress-test | grep -v '^cset:'
137:    MACHINE_JSON=$(sudo cset shield --exec -- "${SPSC_BINARY}" --machine-info \
144:        sudo cset shield --exec -- "${SPSC_BINARY}" "${VARIANT}" \
245:    MACHINE_JSON=$(sudo cset shield --exec -- "${BINARY}" --machine-info \
253:    sudo cset shield --exec -- "${BINARY}" \
```

Each becomes `sudo -E cset shield --exec -- ...`. Pattern is uniform — a single `sed -i 's/sudo cset shield --exec/sudo -E cset shield --exec/g' bench/scripts/run_one.sh` covers all eight in one go. Verify by diff before committing.

### Optional secondary edits

For consistency, the other `sudo` invocations in the script (lines 33, 81, 84, 88, 94, 103, 128, 131, 135, 148, 241, 250, 260) can also receive `-E` — they don't need it functionally, but uniform `sudo -E` everywhere prevents future bugs of the same shape. Defer to your judgment; the eight binary-invocation lines are the only ones that strictly matter.

## Acceptance criteria

- All eight `sudo cset shield --exec --` lines in `bench/scripts/run_one.sh` use `sudo -E`.
- On the reference machine, `./scripts/run_one.sh 03-simd-blackscholes` produces JSON with `"turbo": false` (not `null`).
- The stderr line `CRUCIBLE_TURBO=off (verified)` continues to print exactly once at the start of the run.
- No regression in the FATAL path when `CRUCIBLE_TURBO` cannot be determined — i.e., commenting out the boost detection block on a test branch should still produce the FATAL message and a non-zero exit, with no JSON written.

## Out of scope

- The actual demo 3 rerun — happens after this lands.
- Any change to `machine_info.h` (already correct; the bug is environment propagation, not parsing logic).
- Demo 4's eventual rerun (will benefit automatically from this fix when it happens).
- Other env vars that might want to cross the sudo boundary in the future (not currently any).

## Open questions for CC to flag during implementation

- Confirm that `sudo -E cset shield --exec` actually propagates env vars on the reference machine's Ubuntu LTS / sudo version. The expected behaviour is documented but a one-line test would close the loop:

  ```bash
  CRUCIBLE_TEST=hello sudo -E cset shield --exec -- env | grep CRUCIBLE_TEST
  ```

  If that prints `CRUCIBLE_TEST=hello`, the mechanism works. If it's empty, the sudo configuration on this machine is stricter than default (env_reset without env_keep), and we need the explicit-pass alternative: `sudo CRUCIBLE_TURBO="$CRUCIBLE_TURBO" cset shield --exec -- ...`. Flag this in the PR and we'll pick the right form.

- If `/etc/sudoers` on the reference machine has `Defaults env_reset` without a corresponding `env_keep += "CRUCIBLE_TURBO"` (or `+= "CRUCIBLE_*"`), `-E` may not be sufficient. The test above will reveal it; the fallback is the explicit-pass form.
