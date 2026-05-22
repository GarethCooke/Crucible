# Crucible — Demo 05 rescope follow-up: headless calibration capture

Supplements `demo-05-rescope-brief.md`. CC is presumed to be mid-stream on that brief; this follow-up overrides two items (Task 4 and Task 6) and adds a capture-procedure section. Everything else in the rescope brief stands.

## Why this follow-up

The original rescope brief reused the existing rung 2 JSON as "rung 4a" and asked CC to capture a new rung 4b for the bg-threads decision. Both rung 2 and the planned 4b would have been captured from a gnome-terminal session — adequate for the rescope decision because that's a ratio comparison and the gnome-on-CCX0 noise is small relative to the signal we were checking for.

Demos 01-04 were captured headless (multi-user.target, no graphical session). For methodological consistency, the headline capture for demo 05 must be headless too. The bg-threads lock decision sits between the gnome-terminal rescope evidence and the headless headline; running the bg-threads calibration headless makes the decision data measurement-grade and bridges the methodology gap cleanly.

The existing gnome-terminal calibration data (rungs 1, 2, 3a, 3b) remains as the evidence that drove the rescope itself — adequate for "is the magnitude in the 1.2× range or the 2× range" but not for "what's the precise p99.9 separation." The headless rung 4a/4b captures replace gnome-terminal rung 2 as the input to the lock decision.

## Override of Task 4 (rescope brief)

Replace Task 4 in full with the following.

### 4. Calibration re-run, headless

Both rungs are fresh captures on the reference machine in multi-user.target:

- Rung 4a: `bg-threads=1`, `bg-pressure-hz=1M`, `bg-live-allocs=8192`.
- Rung 4b: `bg-threads=2`, `bg-pressure-hz=1M`, `bg-live-allocs=8192`.

Capture both variants (`cross-thread-malloc` and `arena-batch-handoff`) for each rung. Four runs total. The `freelist-return-queue` variant remains out of scope for calibration per the rescope brief.

Output: `bench/calibration-notes/rung4a-{malloc,arena}.txt` and `bench/calibration-notes/rung4b-{malloc,arena}.txt`, one JSON object per file in the same format as the existing rung 1–3 outputs.

**Capture procedure.** The capture itself is operator work (the user on `iguanabunt`); CC's role on Task 4 is now (a) document this procedure in the calibration-notes README, (b) validate the JSON the user produces, (c) apply the decision rule below.

```bash
# From any session, drop to multi-user.target:
sudo systemctl isolate multi-user.target

# Log in at the console (tty1). Then:
export CRUCIBLE_TURBO=off
sudo cpupower frequency-set -g performance
sudo cset shield --reset
cat /sys/devices/system/cpu/smt/active        # expect 0
taskset -cp 1                                  # expect 0-7

cd ~/Development/Projects/Crucible
BIN=./bench/build/demos/05-allocators/bench_05_allocators

# Rung 4a captures (bg-threads=1):
$BIN cross-thread-malloc --mode paced --bg-threads 1 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4a-malloc.txt
$BIN arena-batch-handoff --mode paced --bg-threads 1 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4a-arena.txt

# Rung 4b captures (bg-threads=2):
$BIN cross-thread-malloc --mode paced --bg-threads 2 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4b-malloc.txt
$BIN arena-batch-handoff --mode paced --bg-threads 2 --bg-pressure-hz 1000000 \
  --bg-live-allocs 8192 > bench/calibration-notes/rung4b-arena.txt

# Return to graphical:
sudo systemctl isolate graphical.target
```

Decision rule for the bg-threads lock is unchanged from rescope brief §4:

- Rung 4b malloc/arena p99.9 ratio ≥ 1.5× → lock `bg-threads=2`.
- 1.23× ≤ ratio < 1.5× → also lock `bg-threads=2` (workload-honesty argument).
- ratio < 1.23× → keep `bg-threads=1`; the freelist-vs-arena section carries proportionally more of the post.

**Sanity check on rung 4a.** The headless rung 4a captures the same workload configuration as the gnome-terminal rung 2 (both: `bg-threads=1`, `bg-pressure-hz=1M`, `bg-live-allocs=8192`). The two should produce nearly identical ratios. If 4a's malloc/arena p99.9 ratio falls outside the band 1.18×–1.28× (i.e., differs from the gnome-terminal rung 2's 1.23× by more than 5 percentage points either direction), flag it before applying the lock decision. A meaningful gnome-vs-headless gap on identical workload is itself a methodology finding worth surfacing — not a "fudge the threshold" situation.

The gnome-terminal rung 2 JSON stays committed in `bench/calibration-notes/` as historical evidence for the rescope decision. It is **not** input to the bg-threads decision. Do not reuse it in the lock-decision calculation.

## Override of Task 6 (rescope brief)

Replace the README guidance in Task 6 with the following.

`bench/calibration-notes/README.md` documents two distinct evidence classes:

1. **Rescope evidence** (rungs 1, 2, 3a, 3b — gnome-terminal capture). Drove the decision to drop the 2× target. Valid as ratio evidence under the explicit caveat that the capture environment differs from the headline methodology. Absolute numbers should be treated as approximate (within ~10% of headless equivalents, modulo the 4a sanity check).

2. **Lock decision data** (rungs 4a, 4b — headless multi-user.target capture). Drives the bg-threads lock. Measurement-grade.

The README contains, in order:

- One-paragraph framing: what these notes are, why they exist, why the two evidence classes are separate.
- The rung table from rescope brief §Context, marked "Rescope evidence (gnome-terminal)."
- A second rung table for 4a and 4b, marked "Lock decision data (headless)."
- A one-sentence statement of the lock decision applied (one of: "Locked bg-threads=2 per rule X" or "Locked bg-threads=1 per rule Y"), with the rung 4b ratio quoted.
- A one-sentence forward-looking note: future calibration ladders for this demo are headless by default.
- The capture procedure from §4 above, verbatim, so it's reproducible without referring back to this brief.

Keep it factual and short. This README is project documentation, not promotional copy.

## What stays from the rescope brief

Unchanged:

- All of Tasks 1, 2, 3, 5 (the CLI flag, multi-thread T_bg, JSON schema, in-place edits to `05-allocators-brief.md`).
- All open items, all out-of-scope items.
- All acceptance criteria from the original brief.

## Acceptance criteria additions

Beyond the rescope brief's existing list:

- [ ] Rung 4a and 4b captured headless, in multi-user.target.
- [ ] Capture procedure documented in `bench/calibration-notes/README.md`.
- [ ] Rung 4a's malloc/arena p99.9 ratio within 5 percentage points of gnome-terminal rung 2's 1.23×; if outside that band, the README documents the discrepancy and the issue is surfaced to Opus before the lock decision is applied.
- [ ] gnome-terminal rungs 1, 2, 3a, 3b remain in `bench/calibration-notes/`, unchanged, labelled "rescope evidence" in the README rather than "lock decision data."

## Notes for CC

- If CC has already executed the original Task 4 (reuse rung 2's JSON as rung 4a, capture only a new 4b): discard the rung 4a aliasing in the calibration log. The new 4a is a fresh headless capture, not the gnome-terminal rung 2. If CC has already captured a gnome-terminal 4b, that data is not reusable for the lock decision either; the user re-captures both 4a and 4b headless per §4 above. No code changes from the original brief are invalidated — the binary built for the original Task 4 is the same binary used for the headless captures.

- "Headless" here is `systemctl isolate multi-user.target`, not a separate physical machine, not a remote session. Same machine, no X/Wayland session.

- The capture procedure includes `sudo cset shield --reset` defensively. On the reference machine as of 2026-05-21, the cgroup v1 cpuset at `/cpusets` was constraining PID 1's affinity to a subset that prevented benchmark thread pinning. The reset clears that. Future boots may or may not need the reset; running it is idempotent when not needed.

- This is a small follow-up. Budget roughly half a day to update the brief edits, the README, and the calibration log; the capture itself takes minutes once the user is at the console.
