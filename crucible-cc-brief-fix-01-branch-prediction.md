# Crucible · CC Brief: Fix `01-branch-prediction`

**Status of the post:** Invalidated. The compiler has eliminated the branch entirely and the prose makes claims that are not supported by the captured data.

**Priority order:** (1) fix the benchmark, (2) verify via disassembly, (3) re-capture, (4) fix methodology drift exposed by the JSON, (5) rewrite prose against actual numbers, (6) fix dates. **Do not rewrite prose until re-capture is complete.**

---

## 1. Root cause

`bench/CMakeLists.txt` sets `-O3 -march=native` globally. The hot loop is:

```cpp
int64_t sum = 0;
for (auto x : data) {
    if (x >= 128) sum += x;
}
```

GCC 13 on a Zen 2 target with AVX2 vectorises this into `vpcmpgtd` + `vpand` + `vpaddd` (eight `int32_t`s per iteration, masked add, no branch). The captured JSON confirms:

- `branch_misses_per_op` is 0.000 on unsorted at N ≥ 1M (would be ~0.5 with a real branch).
- IPC is identical sorted-vs-unsorted across all N (1.759 vs 1.764 at N=33M).
- Wall time is within 1% sorted-vs-unsorted at all six N values.
- Per-element rate at N=33M is ~0.28 ns — bandwidth-limited streaming, not branch-limited.

The page text (1.2 ns sorted / 7.3 ns unsorted, 6.1× gap, 49.8% miss rate, IPC 3.2 / 0.9) does not exist in the JSON. It was written to the expected story.

---

## 2. Fix the benchmark — force a real branch

Apply the following at the function level so `-O3 -march=native` stays default for the rest of the TU. Targeted attributes on the hot function are cleaner than global flag changes and easier to defend in the post.

```cpp
// bench/demos/01-branch-prediction/branch_prediction.cpp

// Disable the two transformations that defeat this experiment:
//   - tree-vectorize  -> SIMD masked add (no branch)
//   - if-conversion   -> scalar cmov     (no branch)
// Keeping -O3 elsewhere; only this function is constrained.
__attribute__((noinline, optimize("no-tree-vectorize",
                                  "no-if-conversion",
                                  "no-if-conversion2")))
static int64_t sum_threshold(const std::vector<int32_t>& data) {
    int64_t sum = 0;
    for (auto x : data) {
        if (x >= 128) sum += x;
    }
    return sum;
}
```

Notes:

- `noinline` is essential — without it the caller's optimisation context can re-vectorise after inlining.
- `optimize` as a function attribute requires GCC ≥ 4.4; it is supported on the toolchain in use (GCC 13.3).
- Do **not** add `volatile` to the loop variable; the goal is to study a real (predictable vs unpredictable) branch, not to defeat all optimisation.

If the function attribute proves unreliable across CI/host updates later, the fallback is to put `sum_threshold` in its own `.cpp` with a CMake `target_compile_options` override applying `-fno-tree-vectorize -fno-if-conversion -fno-if-conversion2`. Attribute approach first; only escalate if needed.

---

## 3. Verify via disassembly before re-capturing

Add a build-time check (or a one-liner in the capture script) that fails loudly if the compiler defeats the experiment again on a future toolchain.

```bash
# Must see jl / jge / jb / jae in the inner loop, NOT cmovge / vpcmpgtd / vpand.
objdump -d build/demos/01-branch-prediction/bench_01_branch_prediction \
  | awk '/<_ZL13sum_threshold/,/^$/' \
  | grep -E '\b(jl|jge|jb|jae|cmov|vpcmpgtd|vpand|vpaddd)\b'
```

**Expected:** at least one `jl`/`jge`. **Failure mode:** any `cmov*` or `vp*` SIMD ops in the loop body — abort and reconsider.

Capture the disassembly snippet to disk during the run; the post can include it as a code block to make the methodology transparent.

---

## 4. Methodology fixes exposed by `01-branch-prediction.json`

These are independent of the branch-elimination bug. Fix them in `tools/perf_capture.sh` and `common/machine_info.{h,cpp}` while the bench is being rebuilt.

### 4.1 Governor reads `ondemand`, page claims `performance`

Capture script must set governor to `performance` and **verify** before running. Suggest:

```bash
for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee "$c" >/dev/null
done
actual=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
[[ "$actual" == "performance" ]] || { echo "governor not performance: $actual"; exit 1; }
```

### 4.2 `isolated_cpus` is empty, page claims cores 4–7 isolated

Either actually isolate via `isolcpus=4-7` kernel cmdline + `cset shield`, **or** drop the claim from page footers and replace with `cpuset = 4-7 (taskset, not kernel-isolated)` to be honest. The latter is simpler and still rigorous if combined with SMT-off and turbo-off.

`machine_info_json()` should emit two distinct fields:

- `isolated_cpus` — read from `/sys/devices/system/cpu/isolated`. Reports kernel-level isolation (will be empty unless `isolcpus=` is on the cmdline). Currently empty in the JSON, which is correct given no kernel isolation is configured.
- `cpu_affinity` — read via `sched_getaffinity(0, ...)` from inside the benchmark process at startup. Reports the actual cpuset the bench is running on, regardless of how it got there (`taskset`, `cset`, inherited from parent, or unrestricted). Format as a compact range string e.g. `"4-7"` or `"0-7"`.

Do **not** derive `cpu_affinity` from a CLI flag, environment variable, or by parsing the parent shell — the goal is to record what the kernel actually scheduled the process on, not what the user claimed they wanted.

Footer prose then reads truthfully as e.g. `cpuset 4–7 (taskset, not kernel-isolated)` and the JSON backs it up directly.

### 4.3 CPU brand string double-concatenated

Current output:

```
"AMD Ryzen 7 3800X 8-Core ProcessorAMD Ryzen 7 3800X 8-Core Processor              Unknown CPU @ 3.9GHz"
```

The reader is concatenating `model name` from `/proc/cpuinfo` with itself, then falling back to a "Unknown CPU @ X GHz" string. Inspect `common/machine_info.cpp`; expected fix is read once, trim trailing whitespace, drop the fallback if the primary read succeeded.

### 4.4 `ram_speed_mhz: 0`

If `dmidecode` isn't available without sudo in the capture environment, omit the field (`null`) rather than report 0. The site renderer should treat null as "not captured" and not display "0 MHz".

---

## 5. Re-capture

After fixes 2–4, run the existing capture flow. Acceptance criteria:

- `branch_misses_per_op` for unsorted at N ≥ 100K is in the range 0.4–0.5.
- `branch_misses_per_op` for sorted at N ≥ 100K is < 0.01.
- IPC for unsorted is meaningfully lower than sorted (expect a ~2–3× IPC gap at N where data fits in L2/L3).
- Wall-time gap sorted-vs-unsorted is **at least 3×** at the cache-resident sizes (likely N=100K and N=1M). At N=33M memory bandwidth may compress the gap — that's a feature, not a bug; report what's measured.
- `governor: "performance"`, `cpu` field clean, no double-concatenation.

---

## 6. Prose rewrite (after re-capture only)

Once the new JSON is in, rewrite `site/posts/01-branch-prediction.{md,mdx}`:

- **Drop all hard-coded numbers** in the body. Replace with `{` template references `}` that pull from the JSON, or at minimum check every number against the new JSON before committing.
- **Frame the post around the diagnostic**, not the result. Suggested structure:
  1. The naive expectation (the StackOverflow story).
  2. First run at `-O3 -march=native` — show the JSON, sorted ≈ unsorted. Why?
  3. Disassembly: `vpcmpgtd` + `vpand`. The compiler defeated the experiment.
  4. The fix: function attributes to suppress vectorisation and if-conversion. Show the new disassembly with `jl`/`jge`.
  5. Re-run: now we see the gap. Across N — gap widens then compresses as memory bandwidth becomes the bottleneck at large N.
  6. Takeaway: every "classic" microbench has caveats; the compiler is your adversary in measurement; always check the disassembly.
     This is a richer story than "sorting is faster" and lands better with the target audience (hedge fund / cap-markets perf engineers who care about what the compiler emits).
- **Footer**: replace with the actual config — `gcc 13.3 -O3 -march=native, function-level no-tree-vectorize/no-if-conversion, governor=performance, turbo off, SMT off, cpuset 4–7`.

---

## 7. Dates

Both posts are dated in the future as of 2026-05-10:

- `01-branch-prediction`: `2026-05-15` → set to capture date `2026-05-10` (or whatever the re-capture date is).
- `02-false-sharing`: `2026-05-22` → set to actual publish date.

---

## 8. Audit `02-false-sharing` separately

Out of scope for this brief but flag for a follow-up brief:

- Footer still reads `*All numbers: placeholder — replace by running the capture scripts on the reference machine.*` Confirm whether the JSON for that post was regenerated after the prose was written, and whether the prose numbers (341×, 21×, 7.84 ns/op, 0.38 ns/op) match.
- Same governor/isolation/cpu-string fixes apply — do not duplicate work; once `machine_info` and `perf_capture.sh` are fixed in this brief, post 02 just needs re-capture.

---

## 9. Acceptance checklist

- [ ] `objdump` of `sum_threshold` shows `jl`/`jge` in the inner loop, no `cmov*`, no `vp*` ops.
- [ ] New JSON: unsorted branch_misses_per_op ∈ [0.4, 0.5] at N ≥ 100K.
- [ ] New JSON: sorted/unsorted wall-time ratio ≥ 3× at N=100K or N=1M.
- [ ] `machine.governor == "performance"` in JSON.
- [ ] `machine.cpu` is a single clean brand string.
- [ ] Page prose contains no numbers absent from the JSON.
- [ ] Post date is not in the future relative to capture date.
- [ ] Disassembly snippet included in the post (or linked from it).
