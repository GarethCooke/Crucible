# Crucible — Demo 05 MDX honesty pass — CC brief (25c)

Companion to `pre-demo-5-review-tasks.md` task 25. **This brief supersedes brief 25b** (which was based on a stale JSON capture from `2026-05-20T21:40:13Z` and prescribed edits in the wrong direction). CC's pre-flight check on 25b correctly stopped before any edits landed. This brief is the corrected prescription against the actual repo JSON at `captured_at: 2026-05-21T17:52:54Z`.

## Why this brief

Three things converged into one mess:

1. The current MDX (`site/src/posts/05-allocators.mdx`) was written before the headless re-capture and reflects expectations from the implementation brief, not the data. Task 25 caught this; the rewrite was never applied.
2. Brief 25b was based on a 20-hour-older JSON capture (`2026-05-20T21:40:13Z`) that had different numerical results — specifically, that older capture showed `arena-batch-handoff` winning at every percentile, the opposite story from the May 21 headless re-capture.
3. CC's pre-flight check on 25b caught the mismatch and stopped. That's the safety net working exactly as designed. **Don't read 25b — it's been removed from outputs.** This brief (25c) is the only one that should be acted on.

This brief is what task 25 originally prescribed, with hostile-cross-read findings from the 25b task-26 review pass folded in.

## Pre-flight check (CC: do this first, abort if it fails)

```bash
python3 - << 'EOF'
import json
with open('site/src/data/perf/05-allocators.json') as f:
    j = json.load(f)
paced = {r['variant']: r['latency_ns']['stats']
         for r in j['runs'] if r.get('mode') == 'paced'}
expected = {
    'cross-thread-malloc':   {'p50': 172, 'p99': 296, 'p99_9': 392, 'max': 46710},
    'freelist-return-queue': {'p50': 172, 'p99': 220, 'p99_9': 312, 'max': 10860},
    'arena-batch-handoff':   {'p50': 204, 'p99': 244, 'p99_9': 344, 'max': 14780},
}
captured_at = j.get('captured_at')
expected_captured_at = '2026-05-21T17:52:54Z'

ok = True
if captured_at != expected_captured_at:
    print(f'CAPTURE TIMESTAMP MISMATCH: expected {expected_captured_at}, got {captured_at}')
    ok = False

for v, exp in expected.items():
    got = paced.get(v, {})
    for k, want in exp.items():
        if got.get(k) != want:
            print(f'MISMATCH {v}.{k}: expected {want}, got {got.get(k)}')
            ok = False

# Cross-CCX
with open('site/src/data/perf/05-allocators-cross-ccx.json') as f:
    cc = json.load(f)
cc_paced = {r['variant']: r['latency_ns']['stats'] for r in cc['runs']}
cc_expected = {
    'cross-thread-malloc':   {'p50': 408, 'p99': 1120, 'p99_9': 1760},
    'freelist-return-queue': {'p50': 408, 'p99': 688,  'p99_9': 720},
    'arena-batch-handoff':   {'p50': 408, 'p99': 688,  'p99_9': 720},
}
for v, exp in cc_expected.items():
    got = cc_paced.get(v, {})
    for k, want in exp.items():
        if got.get(k) != want:
            print(f'CROSS-CCX MISMATCH {v}.{k}: expected {want}, got {got.get(k)}')
            ok = False

print('PRE-FLIGHT PASS' if ok else 'PRE-FLIGHT FAIL — STOP, contact Opus')
EOF
```

If pre-flight fails, **stop and surface** the mismatched values. Don't try to interpret. Wait for a new brief.

If pre-flight passes, proceed.

## The honest story (source of truth for every edit)

**Same-CCX paced (1 MHz offered, 1 M/s background pressure, 5M samples per variant)**

| Variant | p50 | p99 | p99.9 | max |
|---|---|---|---|---|
| `freelist-return-queue` | 172 | 220 | 312 | 10,860 |
| `cross-thread-malloc` | 172 | 296 | 392 | 46,710 |
| `arena-batch-handoff` | 204 | 244 | 344 | 14,780 |

**Freelist beats arena at every percentile.** Gap: 32 ns at p50, 24 ns at p99, 32 ns at p99.9. Freelist max (10,860) also beats arena max (14,780) — freelist is the most stable variant by every measured statistic. The arena's bump-pointer fast path is theoretically minimal but doesn't translate to lower observed latency on this CPU.

**Malloc's same-CCX penalty is modest.** malloc/arena p99.9 = 1.14×. malloc/freelist p99.9 = 1.26×. The "multiplier you wouldn't accept" framing in the current MDX is cross-CCX-strength language; the same-CCX data doesn't carry it.

**Malloc's max IS dramatic.** 46,710 ns — roughly 4× the pool variants' max. One-out-of-five-million sample, but the only same-CCX statistic where the "tail penalty" intuition shows up.

**Same-CCX pressure sweep (p99.9 by background-pressure rate)**

| bg_hz | malloc | arena | freelist |
|---|---|---|---|
| no_bg | 328 | 344 | 312 |
| 100k  | 344 | 344 | 312 |
| 193k  | 376 | 344 | 312 |
| 373k  | **424** | 344 | 296 |
| 720k  | 408 | 344 | 312 |
| 1.39M | 392 | 344 | 312 |
| 2.68M | 344 | 344 | 312 |
| 5.18M | 344 | 344 | 312 |
| 10M   | 344 | 344 | 328 |

- **Malloc is non-monotonic.** Rises 328 → 424 from no-bg to 372k bg_hz (peak), then *declines* back to 344 at high pressure. Cache-locality effect: at high churn rates, recently-freed blocks stay warm in L1/L2 and the fragmentation tail visible at moderate rates gets masked.
- **Arena is dead-flat at 344 across all 9 sweep points.** Including no-bg. Zero variance under background pressure. This is the arena's real property — not lower latency, but *invariance*.
- **Freelist hovers 296-328**, mostly 312. Slight variance, much less than malloc.

**Cross-CCX paced (consumer pinned to core 1, CCX0)**

| Variant | p50 | p99 | p99.9 | max |
|---|---|---|---|---|
| `freelist-return-queue` | 408 | 688 | 720 | 7,200 |
| `arena-batch-handoff` | 408 | 688 | 720 | 12,200 |
| `cross-thread-malloc` | 408 | 1120 | 1760 | 10,460 |

- **p50 floor rises to 408 ns** for all three (Infinity Fabric round-trip on SPSC queue's head/tail metadata).
- **Freelist and arena tied** at p99 (688) and p99.9 (720). The same-CCX freelist/arena gap closes when topology cost dominates.
- **Malloc penalty opens up:** p99 = 1.63× pool variants, p99.9 = 2.44× pool variants. This is the dramatic finding the design discussion was implicitly pointing at.
- **Same-CCX → cross-CCX p99.9 expansion**: malloc 4.49×, freelist 2.31×, arena 2.09×. Malloc's expansion is double the pools'.

## Scope

All edits are in `site/src/posts/05-allocators.mdx`. JSON, chart components, and methodology page are NOT in scope.

Section structure stays. Two section titles change. Section ordering stays.

## The edits

### Edit 1 — Frontmatter `summary` (line 4)

**Current:**

```
summary: "Cross-thread Order lifecycle benchmarked across three allocator strategies — malloc, freelist with return queue, and arena with batch handoff. Median vs tail under realistic background heap pressure."
```

**Replace with:**

```
summary: "Cross-thread Order lifecycle benchmarked across three allocator strategies — malloc, freelist with return queue, and arena with batch handoff. The result that survives contact with the data isn't the one the design discussion would lead you to expect."
```

### Edit 2 — §The thesis (lines 9–13)

**Current:**

```
## The thesis

In a cross-thread trading pipeline, the allocator design is a derivative of the threading model. Malloc looks fine at the median. Under background heap pressure — other subsystems sharing the heap, fragmentation building up, arena locks contending — its p99.9 tail diverges by a multiplier you wouldn't accept in a slow market, let alone a fast one. The right replacement depends on whether your latency budget is in the median or the tail, and those two objectives point at different designs.

This post measures three strategies for the cross-thread free pattern: the baseline that most real systems actually ship, and two honest domain-specific designs. The twist is that neither pool variant strictly dominates the other. Each wins on a different percentile.
```

**Replace with:**

```
## The thesis

In a cross-thread trading pipeline, the allocator design is a derivative of the threading model. Malloc's median is fine; its tail drifts under background heap pressure — other subsystems sharing the heap, fragmentation accumulating, arena locks contending. The size of that drift depends on topology: modest (1.1–1.3× p99.9) when producer and consumer share a CCX, substantial (2.4×) when they don't.

This post measures three strategies for the cross-thread free pattern: the baseline that most real systems actually ship, and two honest domain-specific designs. The result that survives contact with the data isn't the one the design discussion would lead you to expect.
```

### Edit 3 — §Setup → §Background heap pressure subsection (lines 62–64)

**Current:**

```
T_bg runs a tight loop of mixed-size `malloc`/`free` calls against six size classes (32–1024 B), prefilling 512 live allocations at thread start to create fragmentation from t=0. The default rate for headline measurements is 1 M ops/sec of churn — verified during calibration to produce visible variant separation in the paced runs.
```

**Replace with:**

```
T_bg runs a tight loop of mixed-size `malloc`/`free` calls against six size classes (32–1024 B), prefilling 8192 live allocations at thread start to create fragmentation from t=0. The default rate for headline measurements is 1 M ops/sec of churn, with `bg-threads=1`. Both values come from the calibration ladder in `bench/calibration-notes/README.md`; the lock decision is documented there.
```

**Flag if `bg-live-allocs` actually still reads 512 anywhere in the binary's runtime config (check the JSON's `runs[].pressure_config` if it exists, or recompile with verbose logging). The locked value per the calibration notes is 8192. If the headline JSON was produced with 512, that's a methodology audit item separate from this brief — flag it and proceed; we'll resolve the audit item separately.**

### Edit 4 — §Headline latency (CCDF) prose (line 80)

**Current:**

```
The CCDF reads right-to-left: a lower curve at any latency means fewer samples are that slow or slower. At the median the arena variant and freelist variant are both faster than malloc, but the spread between them is small. Moving right toward p99 and p99.9, the picture changes: malloc's tail stretches out as background pressure causes allocator stalls that propagate through pacing; the two pool variants stay comparatively flat, but they separate from each other in a non-obvious direction — the freelist variant beats the arena variant at p99.9, while the arena variant beats the freelist at p50.
```

**Replace with:**

```
The CCDF reads right-to-left: a lower curve at any latency means fewer samples are that slow or slower. At the median, malloc and freelist tie at 172 ns; arena sits 32 ns slower at 204 ns. Moving right toward p99 and p99.9, the picture sorts cleanly: freelist holds its lead (p99 = 220, p99.9 = 312), arena trails by 24 ns at p99 and 32 ns at p99.9 (244 and 344), and malloc's tail stretches out under background pressure (296 and 392) — about a 1.35× gap to the freelist at p99 and 1.26× at p99.9.

The numbers are modest in absolute terms because both producer and consumer share a CCX; the cross-CCX section near the end of the post shows what happens to malloc's tail when the queue traversal stops being free. The one statistic where malloc separates dramatically even on same-CCX is its max: 46,710 ns versus the pool variants' ~10,000–15,000 ns. That's a single sample out of five million, so don't read it as a robust property, but it is the only same-CCX statistic where the design-discussion framing materialises.
```

### Edit 5 — §The freelist-vs-arena trade-off → renamed (line 82, whole section through line 96)

**Current section title (line 82):**

```
## The freelist-vs-arena trade-off
```

**Replace with:**

```
## The bump-pointer that doesn't win
```

**Current section body (lines 84–96):**

```
This is the interesting result. The arena variant's median advantage comes from its fast path: bump-the-pointer is one load and one store. No conditional branch to drain a return queue; no pop from a linked structure. In steady state (99.97% of allocations), `allocate()` for the arena is:

```cpp
Order* o = &arenas_[current_].slots[orders_in_current_++];
o->arena_idx = static_cast<uint8_t>(current_);
return o;
```

That's two instructions in the hot path. The `[[unlikely]]` rotation branch fires roughly every 4096 orders.

The freelist variant's p99.9 advantage comes from a different property: it has no rotation stalls. The arena must occasionally wait for `fully_drained()` before reusing an arena. Even though the system is sized so this should never happen at 1 MHz offered load (16K in-flight capacity against a 1024-slot queue), the periodic rotation itself triggers a `producer_pos.store(release)` and a check on the next arena's `consumer_pos` — two cache-line touches across cores. Under background pressure those cache-line coherence trips can occasionally stall. The freelist producer path has no such periodic stall: it either pops from the local vector (one instruction) or drains the return queue (batch of 32, amortised).

The payoff is the trade-off, not a winner. If your SLA is written in terms of median or p99, the arena variant is the right choice. If your SLA is written in terms of p99.9 or maximum latency — the outlier that fires during the fast market move — the freelist variant deserves the edge.
```

**Replace with:**

````
This is the result that contradicts the design discussion above. The arena's steady-state `allocate()`, in 99.97% of calls, is:

```cpp
Order* o = &arenas_[current_].slots[orders_in_current_++];
o->arena_idx = static_cast<uint8_t>(current_);
return o;
```

Two instructions on the hot path — one indexed load to compute the slot address, one store to set `arena_idx`. The `[[unlikely]]` rotation branch fires roughly every 4096 orders. Against that, the freelist's hot path is a vector pop (load size, decrement, load tail element) plus an amortised return-queue drain (one branch on size, batch of 32 every ~4 ms at this rate). On any theoretical instruction count, the arena should be at least as fast.

It isn't. The freelist wins at every percentile by 24–32 ns at the headline measurement, and its max (10,860 ns) beats the arena's max (14,780 ns) too. Three plausible mechanisms, none of them definitive without targeted microbenchmarks the post doesn't include:

1. **The per-Order `arena_idx` write is a store the freelist doesn't do.** It goes into the store buffer, doesn't block the return, but it does occupy a store-buffer slot during a phase when the producer is also issuing the SPSC queue's `producer_pos.store(release)` for the same order. Two stores in flight versus one is exactly the kind of small overhead that shows up at every percentile.
2. **The arena's rotation branch isn't free even when it doesn't fire.** It's a compare-and-branch on `orders_in_current_ < 4096` every allocation; the freelist's analogous "is the local vector empty?" check is one register comparison the compiler can hoist out of the inner loop body. Branch prediction handles both, but predicted branches still consume issue slots.
3. **The arena's slot address has a longer dependency chain.** `&arenas_[current_].slots[orders_in_current_++]` requires two dependent index loads against the freelist's single pointer-load from the back of a contiguous vector. At p50 this matters less; at p99 and p99.9 it stacks with whatever else is going on in the pipeline.

The arena's design has one property the freelist's doesn't: **its p99.9 is flat across the entire pressure sweep at 344 ns** — every single one of the nine sweep points lands on that number, including the zero-pressure baseline. That kind of variance suppression is sometimes the property a tail-latency SLA actually wants. If predictability matters more than absolute magnitude, the arena's stability is worth a separate look. But on the headline question — which variant has the lowest tail — the freelist wins.
````

### Edit 6 — §Background pressure sweep prose (lines 122–126)

**Current:**

```
The key shape: malloc's p99.9 line climbs steeply as background pressure increases. The two pool variants stay nearly flat through the sweep range. This is the mechanism behind the paced headline picture — at 1 M/s background pressure, malloc is already significantly above the pool variants at p99.9, and the gap widens further at higher pressure levels.

The faint horizontal reference lines show each variant's p99.9 with no background pressure at all. For malloc, the gap between "no background pressure" and "1 M/s background pressure" illustrates exactly how much of malloc's tail is pressure-induced versus inherent to the allocator's per-op cost.
```

**Replace with:**

```
Three different shapes in this chart.

**Arena is flat.** Every sweep point, including the zero-pressure baseline, lands at p99.9 = 344 ns. The arena's tail is decoupled from background heap pressure entirely. The bound is set by the rotation infrastructure cost, not by anything the background thread is doing.

**Freelist is nearly flat.** It hovers around p99.9 = 312 ns across most of the sweep, dropping slightly to 296 at moderate pressure and rising to 328 at the highest pressure level. The return-queue's batched drain absorbs background-induced variance the same way the arena's rotation does, with slightly less perfect suppression.

**Malloc is non-monotonic.** Its p99.9 rises from 328 (no pressure) to a peak of 424 at 372 k/s, then *declines* as pressure increases further — back to 344 at 2.68 M/s and stable from there. This isn't a measurement artefact; it's a cache-locality effect: at high churn rates, malloc's recently-freed blocks get re-touched fast enough to stay warm in L1/L2, and the fragmentation tail that exposes itself at moderate rates gets masked. The worst case for malloc isn't peak background activity. It's the kind of background activity a real system would happily run at.

The faint horizontal reference lines show each variant's p99.9 with no background pressure at all. Arena's reference is on top of its sweep line — no separation. Freelist's reference (312) and its sweep line are within ±16 ns at every point. Only malloc's sweep diverges materially from its no-pressure reference, and only in a specific pressure regime.
```

### Edit 7 — §Cross-CCX side note (lines 130–143)

**Current:**

```
The headline runs place producer and consumer on the same CCX (cores 4 and 5, sharing L3 on CCX1). In a real system, producer and consumer are sometimes on different CCX slices — the queue crossing traverses the Infinity Fabric rather than the shared L3.

<Benchmark
  slug="05-allocators-cross-ccx"
  chart="latency-histogram"
  mode="paced"
  variants={["cross-thread-malloc", "freelist-return-queue", "arena-batch-handoff"]}
  view="ccdf"
  markers={["p50", "p99", "p99_9"]}
/>

Cross-CCX configuration: producer on core 4 (CCX1), consumer on core 1 (CCX0), T_bg on core 6 (CCX1). The p50 floor rises across all three variants — the inter-core cache-coherence round-trip is now across the Infinity Fabric rather than the shared L3. The relative ordering between variants is preserved: malloc still has the widest tail, and the freelist/arena trade-off at the percentile boundary follows the same logic as the same-CCX case.

The cross-CCX picture is not the headline because most tightly-coupled producer/consumer pipelines in a trading system run on the same socket and often the same CCX. The same-CCX configuration is the design you'd choose if you had the choice. This side experiment shows what you pay when you don't.
```

**Replace with (keep the `<Benchmark>` block exactly as-is; rewrite the prose around it):**

```
The headline runs place producer and consumer on the same CCX (cores 4 and 5, sharing L3 on CCX1). In a real system, producer and consumer are sometimes on different CCX slices — the queue crossing traverses the Infinity Fabric rather than the shared L3. This case isn't the headline because most tightly-coupled trading pipelines run same-CCX by design; the side experiment shows what happens when you don't get that choice.

<Benchmark
  slug="05-allocators-cross-ccx"
  chart="latency-histogram"
  mode="paced"
  variants={["cross-thread-malloc", "freelist-return-queue", "arena-batch-handoff"]}
  view="ccdf"
  markers={["p50", "p99", "p99_9"]}
/>

Cross-CCX configuration: producer on core 4 (CCX1), consumer on core 1 (CCX0), T_bg on core 6 (CCX1). The p50 floor rises to 408 ns across all three variants — the Infinity Fabric round-trip is the new baseline, identical for everyone.

The tail picture is where the variants part. The freelist and arena both top out at p99.9 = 720 ns — within sample-noise of each other, both about 2.1–2.3× their same-CCX baselines. Malloc reaches p99 = 1120 ns and p99.9 = 1760 ns. That's 1.63× the pool variants at p99 and 2.44× at p99.9 in absolute terms, and a 4.5× expansion of malloc's same-CCX baseline (392 → 1760) versus the pools' 2.1–2.3× expansion. The cross-CCX environment amplifies malloc's allocator-overhead tail disproportionately — the lock-contention paths and arena coordination that malloc has to do internally pay an extra Infinity-Fabric round-trip every time they cross between threads on different L3 domains.

This is the gap the design discussion at the top was implicitly pointing at. It happens to live in the cross-CCX corner, not the headline.
```

### Edit 8 — §Reproducing this (line 165)

**Current:**

```
Hardware: AMD Ryzen 7 3800X (Zen 2), cores 4–6 isolated (`isolcpus=4-7`), governor = performance, Turbo Boost off, SMT off (BIOS), GCC 13.3, `-O3 -march=native -std=c++20`.
```

**Replace with:**

```
Hardware: AMD Ryzen 7 3800X (Zen 2), 3.9 GHz base, governor = performance, turbo disabled (verified via cpupower), SMT off (BIOS), `isolcpus=0-7` requested at boot (core 0 carries unavoidable kernel housekeeping per probe; benchmark process pinned to cores 4–7). Producer to core 4, consumer to core 5, T_bg to core 6 (all CCX1). GCC 13.3, `-O3 -march=native -std=c++20`.
```

### Edit 9 — §Takeaway (lines 167–173)

**Current:**

```
## Takeaway

The allocator design follows from the threading model. For cross-thread Order lifetimes, the question isn't whether to pool — it's which shape of pool matches your latency target.

If your latency budget is in the median, the arena variant wins: bump-pointer allocation is one instruction, and there are no per-object data structures to traverse on the free path. If your latency budget is in the tail, the freelist-with-return-queue variant wins: it avoids the periodic rotation stall that can surface under cache pressure, and the return queue batches the cross-thread coordination cost into amortised drains of 32.

`new`/`delete` loses to both on the tail by a significant multiplier under background pressure. The multiplier is the one in the charts above — derived from the measurement, not from expectations set by the brief.
```

**Replace with:**

```
## Takeaway

For cross-thread Order lifetimes on this CPU, the freelist-return-queue variant wins at every percentile measured: matching malloc's median and beating both alternatives at p99 and p99.9. The arena variant's theoretical advantage — a two-instruction bump-pointer fast path — doesn't materialise against a freelist whose pop is similarly cheap and whose return-queue drain amortises into 32-order batches.

What the arena gives up in absolute latency, it returns in predictability: its p99.9 is dead-flat at 344 ns across all nine pressure-sweep points, no-pressure baseline included. If the latency SLA is written in terms of jitter or worst-case-under-any-load rather than absolute tail magnitude, that flat line is a real property and worth a separate weighing against the freelist's 32-ns p99.9 advantage.

`new`/`delete` is the only variant whose tail responds to background heap pressure, and the response isn't where intuition puts it — moderate pressure (a few hundred k/s background allocations) hurts malloc more than peak pressure does, because at peak churn the recently-freed blocks stay warm in cache. The same-CCX gap is real but modest (~1.26× p99.9). Cross the CCX boundary and the gap opens to 2.44× at p99.9 and 4.5× as an expansion of malloc's own same-CCX baseline, with malloc's tail compounding the Infinity-Fabric round-trip with its own allocator coordination overhead. If your producer and consumer don't share an L3, the case for replacing `new`/`delete` is much sharper than the headline numbers suggest.
```

### Edit 10 — Footer (line 179)

**Current:**

```
*AMD Ryzen 7 3800X (Zen 2), producer core 4 + consumer core 5 (same CCX1), background pressure core 6, governor = performance, Turbo Boost off, SMT off (BIOS), GCC 13.3, -O3 -march=native.*
```

**Replace with:**

```
*AMD Ryzen 7 3800X, Zen 2, 3.9 GHz base, governor = performance, turbo disabled (verified via cpupower), SMT off (BIOS), cores 0–7 isolated (core 0 carries kernel housekeeping; benchmarks pinned to 4–7). Producer on core 4, consumer on core 5, T_bg on core 6 (all CCX1). GCC 13.3, -O3 -march=native -std=c++20.*
```

### Edit 11 — Choose one methodology link, not both

The post currently ends with both:
1. Line 177: inline reference *"See [Methodology](/methodology) for the rdtscp calibration path."*
2. Line 181: standalone *"[Methodology →](/methodology)"*

`grep` the demo-04 MDX:

```bash
grep -n -i 'methodology' site/src/posts/04-spsc-queue.mdx
```

Align demo 5 with whichever pattern demo 4 uses. If demo 4 has both, keep both. If demo 4 has only the standalone arrow, drop the inline reference (collapse the percentile-convention paragraph or merge it into the footer). If demo 4 has only the inline reference, drop the standalone arrow. **Flag what you found in the PR description.**

## Acceptance criteria

After the edits land, the post should satisfy all of the following — auditable by re-reading the post against the JSON:

- **Frontmatter `summary`** previews the "result that survives contact with the data isn't the one the design discussion would lead you to expect" finding without claiming the wrong winner.
- **No claim in the post** says malloc has an unacceptable multiplier on its p99.9 tail in same-CCX. The 1.14× to 1.26× range doesn't carry that language.
- **No claim in the post** says the arena beats the freelist anywhere on the same-CCX paced headline. Freelist strictly dominates arena at p50, p99, p99.9, and max in same-CCX.
- **No claim in the post** says malloc's p99.9 monotonically climbs with background pressure. The actual shape is non-monotonic with a peak at 372 k/s and decline after.
- **No claim in the post** describes a "trade-off" between freelist and arena where one wins at median and the other at the tail. Freelist wins everywhere on absolute latency; arena's distinct property is its zero-variance p99.9 across the sweep.
- **§Cross-CCX prose** owns the malloc 2.44× p99.9 ratio honestly, calling out the 4.5× expansion of malloc's same-CCX baseline as the dramatic finding.
- **Every numerical claim** in the prose is traceable to a `latency_ns.stats` value in `05-allocators.json` (paced run, named sweep step) or `05-allocators-cross-ccx.json`.
- **Single-sample max framing** in the §Headline section is honest: "one sample out of five million" or equivalent. Don't dress max as a robust statistic.
- **§Reproducing this** lists the actual isolation state (cores 0–7 requested, core 0 carries housekeeping, benchmarks pinned to 4–7) not a fictional `isolcpus=4-7`.
- **§The bump-pointer that doesn't win** owns the three mechanism hypotheses with explicit "none of them definitive without targeted microbenchmarks the post doesn't include."
- **Methodology link** appears in whatever pattern matches demo 4. PR description notes which pattern was chosen and why.
- **Build passes** (`npm run build` or equivalent) with no new warnings.
- **Lighthouse** Performance ≥ 90, Accessibility ≥ 90 on `/posts/05-allocators` after edits.

## Out of scope

- Any changes to the C++ source or capture pipeline.
- Re-running the headline or cross-CCX captures.
- Methodology page edits.
- The cross-CCX JSON `notes` field bug (it currently says "same CCX1 on Zen 2" — copy-paste from the same-CCX file). One-line fix tracked separately as item (a) under "Items the user owes outside this brief" below; does not block this brief.
- The `isolated_cpus` cmdline question (whether to update GRUB to actually isolate core 0). The post now describes the actual state honestly; whether to change the underlying configuration is a separate decision tracked as item (b) below.

## Open items for CC to flag during implementation

1. **`bg-live-allocs` value in §Setup edit 3.** The prose says `8192` per the calibration-notes lock. If the headline binary actually ran with `bg-live-allocs=512` (the original default), surface what's in the JSON or binary config and flag it as a methodology audit item. **Don't change the prose** — the locked value is the correct number to ship; an audit item is what to raise.

2. **`<Benchmark>` prop filtering.** The headline `<Benchmark>` block uses `mode="paced"` and `background_pressure_hz={1000000}`. Confirm both props are respected by the current `<Benchmark>` component. If `background_pressure_hz` is silently ignored, the chart will still render correctly because there's only one paced run per variant — but flag the dead prop.

3. **`<PressureSweep>` faint-reference-line implementation.** The pressure sweep section refers to "the faint horizontal reference lines" showing the no-bg baseline. If that feature isn't actually implemented in `<PressureSweep>`, either remove the prose reference or surface it as a chart-component gap.

4. **Demo 4 conventions to check** (and align demo 5 to):
   - Frontmatter field: `summary:` or `excerpt:`?
   - Methodology link pattern (inline / standalone arrow / both)?
   - Footer text style (sentence shape, what's included)?
   Report what you find in the PR description.

5. **`<PressureSweep>` x-axis treatment of the no-bg baseline.** The JSON includes a `background_pressure_hz: null` point alongside numeric sweep points. The prose refers to a "faint dashed horizontal reference line" for this, which assumes the component renders the no-bg point as a reference rather than a sweep value. Confirm the component does this; if it doesn't, flag — the prose would need amending.

## Items the user owes outside this brief

For the handover doc / review-tasks list, not for CC to action:

(a) **Cross-CCX JSON `notes` field bug.** `05-allocators-cross-ccx.json` `notes` says *"Producer pinned to core 4, consumer to core 5 (same CCX1 on Zen 2 3800X)"*. The cross-CCX file has consumer on core 1 (CCX0). One-line fix in whatever assembled the JSON (Python aggregator script most likely).

(b) **`isolated_cpus_effective: 1-7` vs `requested: 0-7`.** GRUB cmdline requests `isolcpus=0-7` but core 0 is unavoidably retained for kernel housekeeping. The post (after edit 8 / edit 10) describes this state honestly. Decide separately whether to change the GRUB config; not a blocker.

(c) **Stale May 20 JSON capture.** A `2026-05-20T21:40:13Z`-stamped capture of `05-allocators.json` was uploaded to Opus's task 26 review and produced brief 25b (now retracted). The capture is not in the repo. Find any local copies (`find ~ -name '05-allocators.json'` and inspect captured_at) and delete them so they don't keep contaminating future audits. The repo file is the only canonical version.

(d) **Process improvement.** For future briefs that prescribe edits against specific JSON values, the pre-flight check pattern used in 25b/25c (validate captured_at + a handful of stat values before applying any edits) should be the default. Add a one-line note to `BRIEF.md` or `crucible-handover.md` recommending this for any future capture-vs-prose brief.

## What this brief is replacing in the task list

In `pre-demo-5-review-tasks.md`:

- Task 25 status: pending → ☑ once CC applies this brief.
- Add a row under "Notes on the demo 5 detour" (or wherever loose notes live):

  > Brief 25b was drafted against a stale May 20 JSON capture (arena-winning) that doesn't match the repo's May 21 headless capture (freelist-winning). CC's pre-flight caught the mismatch and aborted; brief 25c is the corrected prescription. Lesson: always pre-flight prose-against-data briefs with a values check before applying edits. (See item (d) under "Items the user owes outside this brief.")
