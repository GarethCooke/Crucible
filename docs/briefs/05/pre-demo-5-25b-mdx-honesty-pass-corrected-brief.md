# Crucible — Demo 05 MDX honesty pass (corrected) — CC brief

Companion to `pre-demo-5-review-tasks.md` task 25. **This brief supersedes the prescription in task 25 itself.** Task 25 was audited against data that doesn't match the committed JSON at `site/src/data/perf/05-allocators.json`; the prescription this brief replaces would have produced a different category of wrong post.

## Why this brief

Opus re-audited the live JSON (`05-allocators.json` and `05-allocators-cross-ccx.json`) on 22 May during task 26 and found:

- The current MDX at `site/src/posts/05-allocators.mdx` is the pre-rewrite draft. Task 25 never landed.
- Task 25's quoted percentile values (malloc 172/296/392, freelist 172/220/312, arena 204/244/344) do not appear anywhere in the committed JSON. The actual headline reads:

  | Variant | p50 | p99 | p99.9 | max |
  |---|---|---|---|---|
  | `arena-batch-handoff` | **172** | **228** | **296** | **13,450** |
  | `cross-thread-malloc` | 180 | 228 | 312 | 24,360 |
  | `freelist-return-queue` | 220 | 244 | 360 | 14,960 |

  Arena wins at every percentile. Freelist is the slowest at every percentile. Task 25 had it backwards.

This brief rewrites the MDX against the actual data.

## Pre-flight check (CC: do this first, abort if it fails)

Before applying any edits, verify the JSON the brief was written against matches what's now in the repo. Run:

```bash
python3 - << 'EOF'
import json
with open('site/src/data/perf/05-allocators.json') as f:
    j = json.load(f)
paced = {r['variant']: r['latency_ns']['stats']
         for r in j['runs'] if r.get('mode') == 'paced'}
expected = {
    'cross-thread-malloc':   {'p50': 180, 'p99': 228, 'p99_9': 312, 'max': 24360},
    'freelist-return-queue': {'p50': 220, 'p99': 244, 'p99_9': 360, 'max': 14960},
    'arena-batch-handoff':   {'p50': 172, 'p99': 228, 'p99_9': 296, 'max': 13450},
}
ok = True
for v, exp in expected.items():
    got = paced.get(v, {})
    for k, want in exp.items():
        if got.get(k) != want:
            print(f'MISMATCH {v}.{k}: expected {want}, got {got.get(k)}')
            ok = False
print('PRE-FLIGHT PASS' if ok else 'PRE-FLIGHT FAIL — STOP, contact Opus')
EOF
```

If pre-flight fails, **stop and surface** — the JSON has been re-captured since this brief was written, and applying the prose edits below will land mismatched claims. Don't try to interpret; surface the mismatched values and wait for a new brief.

If pre-flight passes, proceed.

## The honest story (for context — not prose to copy verbatim)

What the data actually shows, used as the source of truth for every edit below:

**Same-CCX paced (1 MHz offered, 1 M/s background pressure, 5M samples per variant)**

| Variant | p50 | p99 | p99.9 | max |
|---|---|---|---|---|
| `arena-batch-handoff` | 172 | 228 | 296 | 13,450 |
| `cross-thread-malloc` | 180 | 228 | 312 | 24,360 |
| `freelist-return-queue` | 220 | 244 | 360 | 14,960 |

Ratios that matter:
- malloc / arena: p50 1.05×, p99 1.00×, p99.9 1.05×, max 1.81×
- freelist / arena: p50 1.28×, p99 1.07×, p99.9 1.22×, max 1.11×
- malloc / freelist: p50 0.82×, p99 0.93×, p99.9 0.87× (malloc beats freelist on percentiles), max 1.63×

**Same-CCX pressure sweep (p99.9 by background-pressure rate)**

| bg_hz | malloc | arena | freelist |
|---|---|---|---|
| no_bg | 296 | 312 | 328 |
| 100k  | 296 | 344 | 344 |
| 193k  | 312 | 344 | 344 |
| 373k  | 296 | 344 | 344 |
| 720k  | 312 | 312 | 344 |
| 1.39M | 312 | 312 | 360 |
| 2.68M | 312 | 344 | 344 |
| 5.18M | 312 | 344 | 376 |
| 10M   | 312 | 344 | 360 |

Malloc p99.9 range across the entire sweep: 16 ns. Arena range: 32 ns. Freelist range: 48 ns. None of the variants' tails meaningfully respond to background pressure on this configuration. There is no widening gap.

**Cross-CCX paced (same offered/bg, consumer on core 1 / CCX0)**

| Variant | p50 | p99 | p99.9 | max |
|---|---|---|---|---|
| `arena-batch-handoff` | 408 | 688 | 720 | 10,690 |
| `cross-thread-malloc` | 408 | 688 | 720 | 9,850 |
| `freelist-return-queue` | 456 | 688 | 784 | 20,010 |

Cross-CCX collapses malloc and arena to identical percentile-grade behaviour. Freelist remains slowest. Cross-CCX adds ~230 ns to every variant's p50 (Infinity Fabric round-trip). Same-CCX → cross-CCX p99.9 expansion: malloc 2.31×, arena 2.43×, freelist 2.18×.

**Single overarching finding:** The arena variant's bump-pointer fast path wins at every percentile measured. The freelist's return-queue overhead doesn't pay for itself on this workload. Malloc is competitive on percentiles but pays a real ~1.8× penalty on single-sample max; that's its only measured weakness here.

## Scope

All edits are in `site/src/posts/05-allocators.mdx`. The JSON files, chart components, and methodology page are NOT in scope.

Section structure stays. Section titles change in two places (§The thesis subtitle implied by content, and §The freelist-vs-arena trade-off). Section ordering stays.

## The edits

### Edit 1 — Frontmatter `summary`

**Current (line 4):**

```
summary: "Cross-thread Order lifecycle benchmarked across three allocator strategies — malloc, freelist with return queue, and arena with batch handoff. Median vs tail under realistic background heap pressure."
```

**Replace with:**

```
summary: "Cross-thread Order lifecycle benchmarked across three allocator strategies — malloc, freelist with return queue, and arena with batch handoff. The bump-pointer arena wins on percentiles; the freelist's return-queue overhead doesn't earn its keep on this workload."
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

In a cross-thread trading pipeline, the allocator design is a derivative of the threading model. The conventional wisdom is that `new`/`delete` looks fine at the median but pays an unacceptable tail penalty under heap pressure, and that a domain-specific pool will buy you back the tail. This post measures that intuition against three honest implementations.

The result that survived contact with the data is not the one the design discussion would lead you to expect: on this workload, `new`/`delete` is competitive on every percentile through p99.9; the arena-batch-handoff variant wins at every percentile by a small margin; and the freelist-with-return-queue variant — the most theoretically appealing of the pool designs — is the slowest of the three. The conventional wisdom holds for one statistic: the single-sample worst case, where `new`/`delete` lands ~1.8× worse than either pool.
```

### Edit 3 — §Setup → §Background heap pressure subsection (lines 62–64)

**Current:**

```
T_bg runs a tight loop of mixed-size `malloc`/`free` calls against six size classes (32–1024 B), prefilling 512 live allocations at thread start to create fragmentation from t=0. The default rate for headline measurements is 1 M ops/sec of churn — verified during calibration to produce visible variant separation in the paced runs.
```

**Replace with:**

```
T_bg runs a tight loop of mixed-size `malloc`/`free` calls against six size classes (32–1024 B), prefilling 8192 live allocations at thread start to create fragmentation from t=0. The default rate for headline measurements is 1 M ops/sec of churn. The pressure-sweep section below shows that variant separation at p99.9 is largely insensitive to this rate across the 100 k/s → 10 M/s range — the variants' tails are determined by their own per-op cost, not by what T_bg is doing.
```

(Note: `8192` is per the rescope brief's locked configuration in `bench/calibration-notes/README.md`. If `bg-live-allocs` is actually still 512 in the headline binary, CC should surface this — the calibration-locked value should be the headline value. If the JSON's `bg_live_allocs` or similar field exists, prefer that as the source of truth. If neither file contains the field, leave the number as `8192` per the locked decision and flag for follow-up.)

### Edit 4 — §Headline latency (CCDF) prose (line 80)

**Current:**

```
The CCDF reads right-to-left: a lower curve at any latency means fewer samples are that slow or slower. At the median the arena variant and freelist variant are both faster than malloc, but the spread between them is small. Moving right toward p99 and p99.9, the picture changes: malloc's tail stretches out as background pressure causes allocator stalls that propagate through pacing; the two pool variants stay comparatively flat, but they separate from each other in a non-obvious direction — the freelist variant beats the arena variant at p99.9, while the arena variant beats the freelist at p50.
```

**Replace with:**

```
The CCDF reads right-to-left: a lower curve at any latency means fewer samples are that slow or slower. The three curves track each other closely through the body of the distribution, with arena sitting consistently leftmost (fastest) and freelist consistently rightmost (slowest). At the median the spread is 48 ns from arena (172 ns) to freelist (220 ns), with malloc landing 8 ns slower than arena. At p99 the arena-malloc pair ties at 228 ns; freelist is 16 ns behind. At p99.9 the order holds — arena 296 ns, malloc 312 ns, freelist 360 ns.

The picture that doesn't show up in the markers but is visible in the long right tail of malloc's CCDF: a single-sample max of 24,360 ns, against arena's 13,450 ns and freelist's 14,960 ns. That outlier is the one place the design-discussion framing materialises: under cross-thread free, glibc's allocator path can produce a worst-case sample roughly 1.8× the pool variants' worst-case. It's one sample out of five million, so don't read more into it than that, but it's the only statistic where the "pool variant for the tail" intuition shows up.
```

### Edit 5 — §The freelist-vs-arena trade-off → renamed §Why the freelist doesn't earn its keep (line 82, whole section)

**Current section title (line 82):**

```
## The freelist-vs-arena trade-off
```

**Replace with:**

```
## Why the freelist doesn't earn its keep
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
The freelist-with-return-queue design has more theoretical machinery than the arena's: a thread-local vector for the producer's hot path, an SPSC return queue for the consumer-to-producer pointer flow, and an amortised drain that pulls 32 pointers off the return queue when the local vector runs empty. The argument for this complexity is supposed to be predictable tail latency — the periodic rotation stalls the arena could in principle suffer don't exist in the freelist's design.

The measurement says no. The freelist is 48 ns slower than the arena at p50, 16 ns slower at p99, and 64 ns slower at p99.9. Its single-sample max is also worse (14,960 ns vs 13,450 ns), though the gap there is small enough to be noise. There's no percentile at which the return-queue design is worth its complexity over the arena on this workload.

Why does the arena win? Its steady-state `allocate()` is:

```cpp
Order* o = &arenas_[current_].slots[orders_in_current_++];
o->arena_idx = static_cast<uint8_t>(current_);
return o;
```

Two instructions on the hot path — one indexed load to compute the slot address, one store to set `arena_idx`. The `[[unlikely]]` rotation branch fires roughly every 4096 orders. Against that, the freelist's hot path is a vector pop (load size, decrement, store size, load tail element) plus an amortised return-queue drain (one branch on size, batch of 32 every ~4 ms at this rate). On any pure instruction count, the freelist should be at least as fast as the arena, and probably faster on the rare-rotation tail. It isn't.

The arena's theoretical risk — the rotation branch triggering a cross-core coherence stall on `producer_pos`/`consumer_pos` — would surface in the p99.9 tail if it were happening. It doesn't. At 1 MHz offered load against 16K in-flight capacity, the consumer is draining slots faster than the producer is filling arenas, and `fully_drained()` returns true essentially every time the producer checks. The arena pays the cost of the rotation infrastructure (two atomics per arena boundary, two cache lines per arena) without paying the cost of an actual stall.

That leaves the freelist's gap unexplained by the design argument. Three plausible mechanisms, none decisive without targeted microbenchmarks the post doesn't include:

1. **Vector-pop dependency chain.** A `std::vector<Order*>::pop_back` issues a load (size), a decrement (size), a store (size), and a load (the tail pointer). The arena's slot computation is one dependent index load. The freelist's longer dependency chain stacks under whatever else is in the pipeline at the percentile boundary.
2. **Return-queue drain blip.** When the local vector runs empty (every ~32 producer allocations after warmup), the freelist takes a branch to drain. That branch is biased not-taken by the compiler, but the drain itself does 32 atomic-load-acquire reads from the return queue's tail. It's bounded and amortised, but the drain points are visible in the latency distribution.
3. **Per-Order `arena_idx` write is in the noise.** It's there in the arena's hot path too, but the freelist doesn't write anything per-Order beyond what the application does. So this *would* be an advantage for the freelist, not a cost. It doesn't explain the gap.

The honest summary: this isn't a "we expected this and confirmed it" result; it's a "we expected the opposite and the data didn't cooperate" result. The post owns the inversion rather than papering over it.
````

### Edit 6 — §Background pressure sweep prose (lines 122–126)

**Current:**

```
The key shape: malloc's p99.9 line climbs steeply as background pressure increases. The two pool variants stay nearly flat through the sweep range. This is the mechanism behind the paced headline picture — at 1 M/s background pressure, malloc is already significantly above the pool variants at p99.9, and the gap widens further at higher pressure levels.

The faint horizontal reference lines show each variant's p99.9 with no background pressure at all. For malloc, the gap between "no background pressure" and "1 M/s background pressure" illustrates exactly how much of malloc's tail is pressure-induced versus inherent to the allocator's per-op cost.
```

**Replace with:**

```
The key shape: all three lines are nearly flat across the sweep. Malloc's p99.9 ranges 296–312 ns across the entire 100 k/s → 10 M/s sweep; arena ranges 312–344; freelist ranges 328–376. None of the variants' p99.9 tails meaningfully respond to background pressure across two orders of magnitude of T_bg activity.

This is itself a finding. The intuition that background heap pressure stretches malloc's tail relative to pool variants — the headline thesis of the calibration ladder behind this demo — doesn't replicate at the percentile resolution of this capture. The variant ordering is determined by per-op allocator cost, not by what T_bg is doing.

The faint horizontal reference lines show each variant's p99.9 with no background pressure at all (malloc 296, arena 312, freelist 328). For every variant, the gap between "no pressure" and "any pressure across the swept range" is within ±32 ns. That's measurement-floor variance at p99.9, not a pressure-induced shift.

What the sweep does *not* address is malloc's single-sample max behaviour, which is the only statistic in the paced headline where the design-discussion intuition shows up. The sweep records p99.9 per point, not max, and a single-sample max isn't usefully comparable across pressure regimes anyway. If "malloc gets dramatically worse under pressure" is your real concern, it would need a sweep on max or a worst-case-over-N-runs metric, neither of which this demo provides.
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
The headline runs place producer and consumer on the same CCX (cores 4 and 5, sharing L3 on CCX1). In a real system, producer and consumer are sometimes on different CCX slices — the queue crossing traverses the Infinity Fabric rather than the shared L3. This case isn't the headline because most tightly-coupled producer/consumer pipelines run same-CCX by design; the side experiment shows what happens when you don't get that choice.

<Benchmark
  slug="05-allocators-cross-ccx"
  chart="latency-histogram"
  mode="paced"
  variants={["cross-thread-malloc", "freelist-return-queue", "arena-batch-handoff"]}
  view="ccdf"
  markers={["p50", "p99", "p99_9"]}
/>

Cross-CCX configuration: producer on core 4 (CCX1), consumer on core 1 (CCX0), T_bg on core 6 (CCX1). Two things change. First, the p50 floor jumps to 408 ns for malloc and arena, 456 ns for freelist — adding ~230 ns to every variant's median for the Infinity Fabric round-trip on the SPSC queue's head/tail metadata. Second, the malloc/arena pair becomes indistinguishable at every percentile through p99.9 (408/688/720 each). Whatever small per-op advantage the arena had on same-CCX disappears once cache-coherence cost dominates the per-Order budget.

Freelist remains the slowest variant, by 48 ns at p50, 0 ns at p99, and 64 ns at p99.9 — the same shape as same-CCX. The freelist's return queue also crosses the CCX boundary, doubling the Infinity-Fabric exposure per Order.

The "malloc loses dramatically when the queue crosses CCX" framing in the design discussion would predict a malloc-specific tail expansion here. The data does not show one. The cross-CCX cost is shared evenly between malloc and arena; both variants pay the same ~2.4× same-CCX-to-cross-CCX p99.9 expansion. If your producer and consumer end up on different CCXs, the right answer is to fix the threading model, not the allocator.
```

### Edit 8 — §Reproducing this (line 165)

**Current:**

```
Hardware: AMD Ryzen 7 3800X (Zen 2), cores 4–6 isolated (`isolcpus=4-7`), governor = performance, Turbo Boost off, SMT off (BIOS), GCC 13.3, `-O3 -march=native -std=c++20`.
```

**Replace with:**

```
Hardware: AMD Ryzen 7 3800X (Zen 2), 3.9 GHz base, governor = performance, turbo disabled (verified via cpupower), SMT off (BIOS), `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` requested at boot (core 0 carries kernel housekeeping per probe), benchmark process pinned to 4–7, producer to core 4, consumer to core 5, T_bg to core 6 (all CCX1). GCC 13.3, `-O3 -march=native -std=c++20`.
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

The arena-batch-handoff variant wins this comparison. On same-CCX paced load at 1 MHz with 1 M/s background heap pressure, it's faster than malloc by 8 ns at p50, ties at p99, and beats by 16 ns at p99.9; faster than the freelist by 48 ns at p50, 16 ns at p99, and 64 ns at p99.9. The freelist-with-return-queue's additional machinery — the return SPSC, the amortised drain, the local vector pop — costs more in the hot path than it saves in the tail. On this workload its complexity is a net negative.

Malloc is the surprise. The conventional intuition that cross-thread `new`/`delete` opens up an unacceptable tail under background pressure does not show up in this dataset at the percentile boundaries. Malloc's p99.9 is 5% behind the arena; its tail is essentially insensitive to background-pressure rate across two orders of magnitude. The one statistic where malloc does pay is single-sample max — 24,360 ns vs the pool variants' ~14,000 ns — which is a real ~1.8× penalty on the worst case but a one-out-of-five-million-samples observation, not a robust statistical property.

The cross-CCX side experiment shows the malloc/arena pair becoming indistinguishable once Infinity-Fabric round-trip dominates the budget. If your producer and consumer are on different CCXs, the relevant question is whether you can move them back onto the same CCX, not which allocator to use; the allocator gap closes when the topology cost is wide.

The honest read of this demo is: the freelist-with-return-queue pattern, which is the design most often cited as the right answer for cross-thread free, didn't pay for itself here. That may be specific to this workload — fixed 64 B Order, 200 ns of consumer work, 1 MHz offered load, single-NUMA, glibc with default arena policy — and the design discussion remains correct in principle. But on this configuration, the bump-pointer arena did the same job with less moving parts, and the baseline `new`/`delete` was within striking distance.
```

### Edit 10 — Footer (line 179)

**Current:**

```
*AMD Ryzen 7 3800X (Zen 2), producer core 4 + consumer core 5 (same CCX1), background pressure core 6, governor = performance, Turbo Boost off, SMT off (BIOS), GCC 13.3, -O3 -march=native.*
```

**Replace with:**

```
*AMD Ryzen 7 3800X, Zen 2, 3.9 GHz base, governor = performance, turbo disabled (verified via cpupower), SMT off (BIOS), cores 0–7 isolated (core 0 carries kernel housekeeping; benchmarks pinned to 4–7). Producer pinned to core 4, consumer to core 5, T_bg to core 6 (all CCX1). GCC 13.3, -O3 -march=native -std=c++20.*
```

### Edit 11 — Choose one methodology link, not both

The post currently ends with both:
1. Line 177: an inline reference *"See [Methodology](/methodology) for the rdtscp calibration path."*
2. Line 181: a standalone *"[Methodology →](/methodology)"*

`grep -l 'Methodology' site/src/posts/0[1-4]-*.mdx` and align demo 5 with whichever pattern demos 1–4 use. If they use the standalone arrow link, drop the inline reference (and the percentile-convention paragraph collapses into footer-only). If they use the inline reference, drop the standalone arrow. If they use both (unlikely), keep both. **Flag what you found** in the PR description.

## Acceptance criteria

After the edits land, the post should satisfy all of the following — auditable by re-reading the post against the JSON:

- **Frontmatter `summary`** previews the actual finding (arena wins on percentiles, freelist doesn't earn its keep).
- **No claim in the post** says malloc has an unacceptable multiplier on its p99.9 tail in same-CCX. The 5% gap doesn't carry that language.
- **No claim in the post** says the freelist beats the arena anywhere. Arena strictly dominates freelist at p50, p99, p99.9, and max in same-CCX. At cross-CCX p99, freelist and others are tied (688/688/688); call out the tie, not a win.
- **No claim in the post** says malloc's p99.9 climbs with background pressure. The sweep shows it doesn't.
- **No claim in the post** says the freelist/arena trade-off "follows the same logic" cross-CCX. The cross-CCX picture is "malloc and arena tied; freelist still slowest."
- **No claim in the post** describes a "trade-off" between freelist and arena. There isn't one in this data.
- **Every numerical claim** in the prose is traceable to a `latency_ns.stats` value in `05-allocators.json` (paced run, default sweep step, or the matching cross-CCX run).
- **Single-sample max framing** is honest: "this is one sample out of five million" or equivalent. Don't dress max as if it were a robust statistic.
- **§Reproducing this** lists the actual isolation state (cores 0–7 requested, core 0 carries housekeeping, benchmarks pinned to 4–7) not a fictional `isolcpus=4-7`.
- **Methodology link** appears exactly once and matches the demos 1–4 convention.
- **Build passes** (`npm run build` or whatever the site uses) with no new warnings.
- **Lighthouse** Performance ≥ 90, Accessibility ≥ 90 on `/posts/05-allocators` after edits (matches the bar for shipped demos).

## Out of scope

- Any changes to the C++ source or capture pipeline.
- Re-running the headline or cross-CCX captures. The current JSON is the data the post is being written against.
- Methodology page edits.
- The cross-CCX JSON `notes` field bug (it currently says "same CCX1" rather than the actual cross-CCX topology). That's a separate one-line fix tracked separately — does not block this brief.
- The `isolated_cpus` cmdline question (whether to update GRUB to actually isolate core 0). The post now describes the actual state honestly; whether to change the underlying configuration is a separate decision.

## Open items for CC to flag during implementation

1. **`bg-live-allocs` value in §Setup edit 3.** I wrote `8192` per the calibration-notes README's locked decision. If the headline binary actually ran with `bg-live-allocs=512` (the default in the original brief) or some other value, surface what's in the JSON (or the binary's recorded config) and we'll align the prose. The prose's `8192` is the locked value; the JSON-recorded value is the truth.

2. **`<Benchmark>` mode filtering.** The headline `<Benchmark>` block uses `mode="paced"` and `background_pressure_hz={1000000}`. Confirm both props are respected by the current `<Benchmark>` component — if the component ignores `background_pressure_hz` and just picks the first matching `paced` run, that's still correct for this JSON (there's only one paced run per variant), but it's worth knowing.

3. **`<PressureSweep>` faint-reference-line implementation.** The pressure sweep section refers to "the faint horizontal reference lines" showing the no-bg baseline. If that feature isn't actually implemented in `<PressureSweep>`, the prose mention should be removed (or the feature added — separate brief).

4. **Demo 4 frontmatter and footer conventions.** Two specific things to verify against `site/src/posts/04-spsc-queue.mdx`:
   - Does demo 4 use `summary:` or `excerpt:` as the frontmatter field?
   - Does demo 4 have an inline methodology reference, a standalone arrow, both, or neither?
   Match demo 5 to demo 4's pattern. If they differ from each other across demos 1–4, flag the broader inconsistency for a separate cleanup brief.

## What this brief is replacing

This brief replaces task 25 in `pre-demo-5-review-tasks.md`. Update the task list to reflect:

- Task 25 status: ☑ (this brief is the corrected prescription; once CC applies the edits, the original task 25 is done in spirit).
- Add a row under "Notes on the demo 5 detour": "Task 25 prescription was rewritten on 22 May during task 26 audit; original prescription did not match the committed JSON. Future briefs that prescribe edits against a specific JSON capture should include a pre-flight check that the JSON the brief was written against still matches the live file."
