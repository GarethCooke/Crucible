# Crucible — Demo 04 (SPSC) final-pass brief

Companion to `crucible-demo-04-refinement-brief.md`. The pacer rewrite landed and the schema fixes are correct. Two items from the previous brief did not land, plus two earlier MDX corrections were applied to only one of three locations.

Scope: extend the sweep range (the one C++ change that was specified in the previous brief but not implemented), four MDX edits, one rerun on the rig.

## Why this revision

The previous brief explicitly specified "100 kHz → 50 MHz in 12 log-spaced steps." The harness still runs the old 8 points to 25 MHz, but the MDX was rewritten as if the extension had landed — it now claims "twelve log-spaced offered-load points from 100 kHz to 50 MHz" (line 142) while a later section says "eight points" (line 218). The post contradicts itself, and the load-sweep chart will render the 8-point data.

The consequence for the story: at the existing top of 25 MHz, the hand-rolled variant has not saturated (still 132 ns p50 outside the mutex's saturation regime, achieving 14.66 M/s with avg queue depth 3.87). The MDX claims "the hand-rolled implementation saturates around 16–20 MHz" — falsifiable directly from the chart it sits next to. Extending the sweep is what makes that claim true.

Separately, the "queue near-empty in all variants" overclaim was corrected in the headline section but remains in the Setup section (line 35–38) and the Takeaway (line 227–228). And `date: "2026-05-14"` was not updated.

## C++ changes

### `bench/demos/04-spsc-queue/benchmark.cpp` — sweep range

In the sweep code path, change the default rate-from / rate-to / steps to:

```
rate_from = 100000      // 100 kHz
rate_to   = 50000000    // 50 MHz
steps     = 12          // log-spaced
```

Equivalently: the script invocation in `bench/scripts/run_one.sh` should pass `--rate-from 100000 --rate-to 50000000 --steps 12` explicitly. Defaults inside the binary should agree with that invocation.

If the binary already accepts these as CLI arguments (it should, per the original fix-up brief), then this is purely a `run_one.sh` change and the binary itself doesn't need rebuilding. Confirm before touching `benchmark.cpp`.

Expected resulting rate points (log-spaced from 1e5 to 5e7, 12 steps):

```
100000, 187382, 351119, 657933, 1232846, 2310129, 4328761, 8111308,
15199111, 28480359, 53366992 → clamp to 50000000
```

(Exact spacing decided by the existing log-spaced-points routine; do not hand-roll if there's already a helper.)

## MDX changes — `site/src/posts/04-spsc-queue.mdx`

Four edits. The first depends on the rerun data; the rest are pure prose.

### Edit 1 — Load-sweep prose (line 142+ and 217–219)

Will need updating to actual post-rerun numbers. Template, with placeholders to fill in from the new JSON:

> Each line shows p50, p99, and p99.9 across twelve log-spaced offered-load points from 100 kHz to 50 MHz. The mutex variant saturates first, around **{X}** MHz offered load — its consumer can't drain fast enough beyond that and the queue fills toward capacity. Once saturated, latency scales as `queue_depth × consumer_period` rather than per-op cost plus wake-up overhead, producing the steep climb visible on the right of the mutex curves.
>
> The lock-free variants stay flat much further. The hand-rolled implementation saturates around **{Y}** MHz; Boost around **{Z}** MHz. Their consumers spin on the producer's `tail_` store via cache coherence and proceed without kernel involvement, so they keep up until the producer's per-push cost itself becomes the bottleneck.

For X: identify the lowest offered-rate sweep point where mutex `ops_per_sec / offered_rate_hz < 0.95`. That's where the variant stops keeping up.

For Y and Z: same test on handrolled and boost. The current data has boost saturating at 25 MHz already (33 µs p50, q_depth 661); handrolled likely saturates somewhere between 25 and 50 MHz.

Also update line 217–219 — the "Offered loads near saturation exhaustively" bullet — from "eight points" to "twelve points." Or, better, drop the count entirely and describe it qualitatively: "the load-sweep section covers a 500× range from well below to well past saturation; behaviour between sweep points is interpolated, not measured."

### Edit 2 — Setup section, line 35–38

Current:

> **The producer is paced at 1 M items/sec for the headline measurements**, well below the sustainable throughput of any variant. **This keeps the queue near-empty in all three cases**, so reported latency reflects per-op queue cost plus (for the mutex variant) condvar wake-up time.

Replace with:

> **The producer is paced at 1 M items/sec for the headline measurements**, well below the sustainable throughput of any variant. The lock-free variants leave the queue effectively empty at this load; the mutex variant runs about 1.8 items deep on average. Reported latency reflects per-op queue cost plus (for the mutex variant) condvar wake-up time — depth contribution is under 2 µs even in the mutex case.

### Edit 3 — Takeaway, line 227–230

Current:

> The lock-free SPSC ring buffer wins on the shape of the tail. At 1 MHz offered load the queue is near-empty in all variants; the latency difference is the kernel boundary, not queue depth. The mutex fast path is fast — its cold path involves a syscall and a scheduler decision, and those outliers appear precisely when the market is moving fastest.

Replace with:

> The lock-free SPSC ring buffer wins on the shape of the tail. At 1 MHz offered load the lock-free variants leave the queue effectively empty; even the mutex variant only carries ~1.8 items on average, so the tens-of-microseconds latency gap is kernel-boundary cost, not queue depth. The mutex fast path is fast — its cold path involves a syscall and a scheduler decision, and those outliers appear precisely when the market is moving fastest.

### Edit 4 — Frontmatter date

Current: `date: "2026-05-14"`.

Update to match `captured_at` in the new JSON, or to the day of the rerun.

## Acceptance criteria

The acceptance criteria from the previous brief still apply. New / repeated:

- `bench_04_spsc_queue lockfree-handrolled --mode sweep` (or equivalent invocation via `run_one.sh`) produces **exactly 12 sweep runs**, with `offered_rate_hz` values spanning 100,000 to 50,000,000. (CC: this is the test that catches the issue that landed last time. Count the entries; verify the range. Don't just say it's done.)
- All three variants demonstrate clear saturation within the swept range, defined as: at some sweep point, `ops_per_sec / offered_rate_hz < 0.95` AND `latency_ns.stats.p50` is at least 10× higher than at the lowest sweep point.
- The MDX claim "twelve log-spaced offered-load points from 100 kHz to 50 MHz" agrees with `len([r for r in runs if r['mode'] == 'sweep' and r['variant'] == 'lockfree-handrolled'])` equalling 12.
- No occurrence of "queue is near-empty in all variants" or "queue near-empty in all three cases" anywhere in the MDX. The mutex variant is not near-empty.
- The MDX claim about each variant's saturation point matches the empirical saturation point computed from the JSON (within one sweep step).
- `date` in the frontmatter is ≥ `captured_at` date in the JSON.
- No internal contradiction in point counts: every reference to "the sweep" or "the load-sweep section" agrees on how many points it contains.

## Out of scope

- The C++ pacer logic itself — it works, leave it alone.
- The schema — `isolated_cpus_*` and `offered_rate_hz: 0` are correct.
- Re-running paced or saturated modes — only the sweep needs to be regenerated. (If easier to re-run everything, fine, but not required.)

## Notes for CC

- The previous brief specified the 12-step / 50 MHz extension under "Sweep range extension" with its own subheading. It did not land. Whatever the reason — `run_one.sh` had hard-coded args overriding the defaults, the change was made to one path but not another, or the brief was misread — please verify by running the binary with the new args and counting the resulting sweep entries before declaring this done.
- The "near-empty" phrase was changed in one of three locations in the MDX last pass. Grep before claiming completion: `grep -n 'near-empty' site/src/posts/04-spsc-queue.mdx` should return zero hits after this pass.
- Edit 1 needs the actual rerun data in hand to fill in the saturation points. Don't write the prose against pre-rerun numbers — verify against the new JSON.
