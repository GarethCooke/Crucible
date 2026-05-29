# Crucible — pre-demo-5 cleanup audits brief

Companion to `BRIEF.md` and `crucible-handover.md`. Three small audits/edits to bring the project into internal consistency before scoping demo 5. None require benchmark reruns directly — but §1 may surface JSONs that need recapture by the user on the reference machine.

## §1 — JSON machine-block consistency audit

The harness was patched per `03-harness-patch-brief.md` to (a) use the `CRUCIBLE_TURBO` env var for turbo state, (b) drop the machine-level `compiler_flags` field, (c) parse `isolcpus` from `/proc/cmdline`. Demos 1, 3, 4 were originally captured with the unpatched harness. Reruns were expected under their own review passes — this audit confirms they landed.

**Action.**

For each of:

- `site/src/data/perf/01-branch-prediction.json`
- `site/src/data/perf/02-false-sharing-pnl.json`
- `site/src/data/perf/03-simd-blackscholes.json`
- `site/src/data/perf/04-spsc-queue.json`

verify the machine block satisfies all of:

- `"turbo": false` (or explicitly `null` only if `CRUCIBLE_TURBO` was intentionally unset for that capture — in which case `notes` must say so).
- No `"compiler_flags"` field at the machine level. Per-variant `runs[].compile_flags` is fine.
- `"isolated_cpus"` consistent with the captured machine state. Current expected value is `"0-7"` post-GRUB-entry rollout; `"1-7"` is acceptable only if cpu0 cannot be kernel-isolated and `notes` documents this (this is the demo 2 case).
- `"governor": "performance"`.
- `"captured_at"` is a real ISO 8601 timestamp postdating the harness patch (verify against the patch commit date; not a placeholder, not future-dated).

**Output.** Findings document at `pre-demo-5-json-audit-findings.md` in the repo root, structured as a per-demo table:

```
| Demo | turbo | compiler_flags | isolated_cpus | governor | captured_at | Verdict | Recapture? |
|------|-------|----------------|---------------|----------|-------------|---------|------------|
```

For each fail, name the corrective action: which GRUB entry to boot, what `CRUCIBLE_TURBO` to export, what capture command to run.

**Do not modify the JSONs in this task.** If recapture is needed, that's a user task on the reference machine.

**Acceptance.**

- Findings doc exists with all four demos.
- Each demo has an explicit pass/fail per field.
- Recapture recommendations name the GRUB entry, `CRUCIBLE_TURBO` setting, and capture-script invocation.

## §2 — Index page audit

The index page was last touched against earlier post state. Confirm it reflects the four shipped posts accurately and fix any drift in place.

**Action.** Inspect `site/src/app/page.tsx` (or wherever the post listing lives):

- All four posts listed: `01-branch-prediction`, `02-false-sharing`, `03-simd-blackscholes`, `04-spsc-queue`.
- Each post's date is real (not a future date relative to capture, per the demo 1 fix-up brief flag).
- Ordering is sensible — chronological by capture date, or strictly by post number. Pick one and apply consistently.
- Each post's index summary reflects the **current** post prose, not stale framing:
  - Demo 2 should **not** say "341×". Current headline is "14× throughput gap from two missing bytes" (per `02b-false-sharing-prose-rewrite-brief.md`).
  - Demo 3 should **not** say "30×" or imply memory-bandwidth-limited. Current framing is ~10× spread, compute-bound at the inner loop (per `05-mdx-rewrite-brief.md`).
  - Demo 4 should reflect the paced-offered-load reframing, not the original "200× Boost vs handrolled" framing (per `crucible-demo-04-fixup-brief.md`).

Fix any drift in place. Match prose tone of the current MDX summaries.

**Acceptance.**

- All four posts listed and links resolve at build time.
- No future-dated posts.
- No stale numerical claims on the index page.

## §3 — README update post-harness-churn

The repo `README.md` covers prerequisites, machine setup, build, capture, and deploy. Several methodology pieces have shifted since v1 and the README hasn't kept pace.

**Action.** Rewrite or update `README.md` to reflect the current capture path. Required sections:

1. **Prerequisites.** Ubuntu Server LTS or equivalent, GCC 13+, CMake ≥3.20, Google Benchmark, `perf`, Node 20+, npm.
2. **One-time machine setup.**
   - Second GRUB entry "Ubuntu (benchmark — cores 0-7 isolated)" with kernel cmdline `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7`.
   - Disable SMT in BIOS.
   - Disable Core Performance Boost in BIOS.
   - For `perf` without root: `sudo sysctl -w kernel.perf_event_paranoid=1`. If `cache-references`/`cache-misses` are still inaccessible, fall back to `sudo setcap cap_perf_event=ep <binary>` per built binary.
3. **Before each capture run.**
   - Boot into the benchmark GRUB entry.
   - `cpupower frequency-set -g performance`.
   - Verify turbo: `cpupower frequency-info | grep "Active: no"`.
   - `export CRUCIBLE_TURBO=off` for the capture session.
4. **Build.** `cd bench && cmake -B build && cmake --build build`.
5. **Capture one demo.** `./scripts/run_one.sh <demo-slug>`.
6. **Site dev / build / deploy.** Confirm commands match `package.json` scripts; `npm run build` produces a static export in `out/`.

Remove any wording referring to `cset shield`, `isolcpus=4-7` as a specific value, or placeholder/TODO sections.

**Acceptance.**

- A fresh reader could follow the README end-to-end on a new machine and produce valid JSON.
- No references to `cset`, the literal string `isolcpus=4-7`, or "TODO".
- `CRUCIBLE_TURBO` documented as a precondition for capture.
- `perf_event_paranoid` and `setcap` paths both documented.

## Out of scope

- Recapturing any JSON (user task on the reference machine).
- Code review (separate briefs).
- Lighthouse / mobile verification (separate brief).
- Methodology page content (Opus task 2).

## Open items for CC to flag

- If a JSON's machine block has additional drift beyond what's named in §1 (a field present in some demos but not others, an unexpected type, etc.), flag it in the findings doc.
- If the index page has no per-post summary (only titles), no action — flag for a future brief.
- If the README is already correct on a given bullet in §3, note that — don't rewrite for the sake of it.
- If any of the four expected GRUB params (`isolcpus`, `nohz_full`, `rcu_nocbs`) need verification beyond the README claim, say so.
