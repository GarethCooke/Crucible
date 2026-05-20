# Crucible — Demo 05: Allocators in a cross-thread Order pipeline

Implementation brief for Claude Code. Lands on the feature branch (`demo-5-allocators` or equivalent, per-branch Amplify preview enabled). Self-contained — no further scoping decisions required beyond the named open items.

## Context

Fifth demo in the Crucible series. Builds on:

- `BRIEF.md` — v1 scaffold, locked schema, methodology, hardware spec.
- `crucible-handover.md` — per-demo process and lessons from demos 1-4.
- `demo-05-teaser-brief.md` (companion) — the stub MDX and WIP teaser that lands on `main` ahead of this work.
- Demo 4 (SPSC queue) — provides the lock-free ring buffer primitive this demo reuses for both the forward queue and the return queue.
- Demo 4 (`histogram.h`, `LatencyHistogram`) — provides the histogram capture and CCDF chart used for the headline latency picture.
- Demo 4's paced/sweep mode pattern — this demo mirrors that two-mode structure.

This demo:

- Reuses the SPSC queue primitive from demo 4. **Precondition:** that primitive must be in `bench/common/`. If it still lives under `bench/demos/04-spsc-queue/`, lifting it to `bench/common/spsc_queue.h` is a precondition to this brief — see Open Items.
- Reuses `histogram.h` and `<LatencyHistogram>` unchanged.
- Adds one new chart component, `<PressureSweep>`, for the background-pressure-vs-tail-latency view. If demo 4's load-sweep already uses a reusable line-chart component, prefer to reuse rather than introduce a new one — see Open Items.
- Adds new per-run schema fields (additive only) for background-pressure config and variant-specific knobs.
- Adds three allocator implementations under `bench/demos/05-allocators/allocators/`.

When the feature branch merges to main, the merge replaces the stub MDX from the teaser brief with the full post, and removes the `status: "in-progress"` and `expectedAt` frontmatter fields.

## Story angle

Headline thesis: *in a cross-thread Order pipeline, the allocator design is a derivative of the threading model, and the right choice depends on whether your latency budget lives in the median or the tail.*

Trading-shop framing in one paragraph: an Order travels through 2-4 pinned threads via SPSC queues — market-data thread, strategy thread, risk thread, network thread. The Order is constructed on one thread and destroyed on another. This is the pattern every real trading system uses, and it is the pattern that breaks naïve thread-local pool allocators.

The post benchmarks three allocator strategies for this cross-thread Order lifecycle under realistic background heap pressure (other subsystems sharing the heap). The variants are not "use a pool / don't use a pool" — they are three honest cross-thread designs that trade off differently between median and tail latency.

The twist that earns the post: the freelist-with-return-queue variant beats the arena variant on p99 (no rotation stalls), the arena beats the freelist on the median (bump-the-pointer is one instruction vs the freelist's load-load-store), and `new`/`delete` loses to both on the tail by a wide multiplier (the actual multiplier is whatever the measurement says — do not hardcode an expected ratio). The payoff is the trade-off, not the winner.

What the post does **not** claim:

- It does not compare against jemalloc / mimalloc / tcmalloc. Drop-in allocator comparison is a separate future post; this post is scoped to "standard library vs domain-specific." State this explicitly in a "What this doesn't show" section.
- It does not address multi-producer or multi-consumer patterns. Strictly 1P/1C.
- It does not vary the Order struct's size meaningfully. A single 64B representation is used; production Orders carry variable-length fields (FIX strings, optional tags) and that's a separate concern.

## Workload

### The Order struct

Fixed 64 B, exactly one cache line:

```cpp
#pragma once
#include <cstdint>

enum class Side : uint8_t { Buy = 0, Sell = 1 };

struct alignas(64) Order {
    uint64_t ts_create_tsc;  // 8B - TSC at producer construction
    uint64_t seq;            // 8B - monotonic sequence
    int64_t  price;          // 8B - fixed-point, scaled
    int32_t  qty;            // 4B
    uint32_t client_id;      // 4B
    uint32_t symbol_id;      // 4B
    uint32_t risk_seq;       // 4B - stamped by risk check
    Side     side;           // 1B
    uint8_t  arena_idx;      // 1B - used by variant 3; ignored otherwise
    uint8_t  _pad[18];       // 18B - round to 64B
};

static_assert(sizeof(Order) == 64, "Order must be exactly one cache line");
static_assert(alignof(Order) == 64, "Order must be cache-line aligned");
```

Realistic-looking for an internal order representation. Note in the post that production orders vary in size; the allocator story is independent of payload contents.

### Producer thread (T_p)

Tight loop with TSC-paced offered load (default 1 MHz):

```cpp
for (uint64_t i = 0; i < items_total; ++i) {
    while (__rdtsc() < next_release_cycles) { _mm_pause(); }
    next_release_cycles += period_cycles;

    Order* o = allocator.allocate();
    o->ts_create_tsc = rdtscp_ordered();
    o->seq           = i;
    o->price         = generate_price(rng);
    o->qty           = generate_qty(rng);
    o->client_id     = i & 255;          // spread across 256 clients
    o->symbol_id     = i & 1023;         // spread across 1024 symbols
    o->risk_seq      = 0;
    o->side          = (rng() & 1) ? Side::Buy : Side::Sell;
    // arena_idx set by allocator.allocate() for variant 3
    
    while (!queue.try_push(o)) { _mm_pause(); }
}
```

Pacing pattern is identical to demo 4 — TSC spin with `__rdtsc()` for the pace check and `rdtscp_ordered()` for the timestamp stamping.

### Consumer thread (T_c)

```cpp
while (!stop_flag.load(std::memory_order_relaxed)) {
    Order* o = queue.try_pop();
    if (!o) { _mm_pause(); continue; }
    
    uint64_t now_ns = tsc_to_ns(rdtscp_ordered());  // for velocity check
    simulated_risk_check(o, now_ns);
    
    uint64_t latency_ns = tsc_to_ns(rdtscp_ordered() - o->ts_create_tsc);
    histogram.record(latency_ns);
    
    allocator.deallocate(o);
}
```

### Simulated risk-check work

Three small tables, all sized to fit comfortably in L1d:

```cpp
struct PositionEntry { int64_t qty; double notional; uint32_t opens; uint32_t _pad; }; // 24B
struct LimitEntry    { int64_t max_long; int64_t max_short; uint32_t max_per_sec; uint32_t _pad; }; // 24B
struct VelocityEntry { uint64_t last_ts_ns; uint32_t count; uint32_t _pad; }; // 16B

static PositionEntry positions[1024];  // ~24 KB - L1 hot
static LimitEntry    limits[256];      // ~6 KB  - L1
static VelocityEntry velocity[256];    // ~4 KB  - L1
static uint64_t      g_rejects = 0;
static uint32_t      g_risk_seq = 0;

constexpr uint64_t VELOCITY_WINDOW_NS = 1'000'000;  // 1 ms window

inline void simulated_risk_check(Order* o, uint64_t now_ns) {
    PositionEntry& pos = positions[o->symbol_id & 1023];
    LimitEntry&    lim = limits[o->client_id & 255];
    VelocityEntry& vel = velocity[o->client_id & 255];

    int64_t delta = (o->side == Side::Buy) ? o->qty : -o->qty;
    pos.qty += delta;
    pos.notional += static_cast<double>(o->qty) * static_cast<double>(o->price);
    ++pos.opens;

    if (pos.qty > lim.max_long || pos.qty < lim.max_short) {
        ++g_rejects;
    }

    if (now_ns - vel.last_ts_ns > VELOCITY_WINDOW_NS) {
        vel.last_ts_ns = now_ns;
        vel.count = 1;
    } else if (++vel.count > lim.max_per_sec) {
        ++g_rejects;
    }

    o->risk_seq = ++g_risk_seq;
}
```

**Target work weight:** 150-300 ns wall-clock. Calibrate during implementation. If too light (<100 ns), expand by adding a fourth lookup (e.g., open-orders-per-symbol). If too heavy (>500 ns), drop the velocity check. The work weight matters because it determines whether allocator differences are visible in the latency distribution. Confirm via measurement before locking in.

The position table is shared state across orders within the consumer thread — multiple orders touching the same symbol both update the same entry. That's realistic, but it means the consumer has intra-thread cache traffic independent of the allocator. Monitor during calibration that the working-set is not the limiting factor.

### Background pressure thread (T_bg)

Simulates other subsystems sharing the heap. Mixed-size malloc/free with controllable rate.

```cpp
void background_pressure_loop(uint64_t target_rate_hz, std::atomic<bool>& stop) {
    constexpr size_t SIZE_CLASSES[] = {32, 64, 128, 256, 512, 1024};
    constexpr size_t NUM_CLASSES = sizeof(SIZE_CLASSES) / sizeof(SIZE_CLASSES[0]);
    
    std::vector<void*> live;
    live.reserve(2048);
    
    // Pre-fill to create fragmentation pressure from t=0
    for (int i = 0; i < 512; ++i) {
        void* p = std::malloc(SIZE_CLASSES[i % NUM_CLASSES]);
        *reinterpret_cast<uint8_t*>(p) = 0xCC;  // touch
        live.push_back(p);
    }

    const uint64_t period_cycles = (target_rate_hz == 0) 
        ? 0 
        : ns_to_cycles(1'000'000'000ULL / target_rate_hz);
    uint64_t next = __rdtsc() + period_cycles;
    
    std::mt19937 rng(42);
    
    while (!stop.load(std::memory_order_relaxed)) {
        if (period_cycles) {
            while (__rdtsc() < next) { _mm_pause(); }
            next += period_cycles;
        }

        if ((rng() & 1) || live.empty()) {
            size_t sz = SIZE_CLASSES[rng() % NUM_CLASSES];
            void* p = std::malloc(sz);
            *reinterpret_cast<uint8_t*>(p) = 0xCC;
            live.push_back(p);
        } else {
            size_t idx = rng() % live.size();
            std::free(live[idx]);
            live[idx] = live.back();
            live.pop_back();
        }
    }

    for (void* p : live) std::free(p);
}
```

When `target_rate_hz == 0`, T_bg is **not spawned at all** (treated as a separate baseline run). Don't run T_bg at "zero rate" — it's noise.

**Calibration:** the default background pressure for the paced headline measurement is **1,000,000 ops/sec** of mixed-size churn. Confirm during implementation that this is sustained on the reference machine (T_bg's pacing loop doesn't fall behind by more than ~5%) and that it produces a visible separation between malloc and pool variants in the headline latency distribution. If at 1M/s the separation is too small (<2× p99.9 ratio), raise to 3M/s. If T_bg can't sustain 3M/s on the reference machine, the demo is in trouble and we need to re-scope — flag immediately, don't paper over it.

## Variants

Three variants, all built with `-O3 -march=native -std=c++20`:

### 1. `cross-thread-malloc`

Baseline. `new Order(...)` / `delete order`. Producer constructs with placement-new on a `std::malloc`-allocated 64 B block (or just `new Order`); consumer `delete`s.

```cpp
class MallocAllocator {
public:
    Order* allocate() {
        return new Order;  // or: static_cast<Order*>(std::aligned_alloc(64, 64));
    }
    void deallocate(Order* o) {
        delete o;  // or: std::free(o);
    }
};
```

Trivial. The interest is in what its tail looks like under background pressure.

### 2. `freelist-return-queue`

Thread-local freelist on the producer, with cross-thread return via a second SPSC queue.

```cpp
class FreelistReturnAllocator {
    SPSCQueue<Order*, 1024> forward_;   // P -> C (this is the demo's main queue; allocator doesn't own it)
    SPSCQueue<Order*, 1024> return_;    // C -> P (allocator owns this)
    
    std::vector<Order*>     local_free_;
    std::unique_ptr<Order[]> slab_;     // pre-allocated slot pool
    
    static constexpr size_t INITIAL_SLOTS = 4096;
    static constexpr size_t DRAIN_BATCH   = 32;

public:
    FreelistReturnAllocator() {
        slab_ = std::make_unique<Order[]>(INITIAL_SLOTS);
        local_free_.reserve(INITIAL_SLOTS);
        for (size_t i = 0; i < INITIAL_SLOTS; ++i) {
            local_free_.push_back(&slab_[i]);
        }
    }
    
    Order* allocate() {              // called by producer
        if (local_free_.empty()) [[unlikely]] {
            drain_return_queue();
        }
        if (local_free_.empty()) [[unlikely]] {
            return nullptr;          // exhausted — should not happen under correct sizing
        }
        Order* o = local_free_.back();
        local_free_.pop_back();
        return o;
    }
    
    void deallocate(Order* o) {      // called by consumer
        while (!return_.try_push(o)) { _mm_pause(); }
    }
    
private:
    void drain_return_queue() {
        for (size_t i = 0; i < DRAIN_BATCH; ++i) {
            Order* o = return_.try_pop();
            if (!o) break;
            local_free_.push_back(o);
        }
    }
};
```

Notes:

- `INITIAL_SLOTS = 4096` covers the in-flight max under 1 MHz offered load (queue depth 1024 + drain batching slack + safety margin). Verify the slab never runs dry during the run; if it does, the demo is misconfigured.
- `DRAIN_BATCH = 32` is a guess. Tune during calibration: too small means frequent drain calls; too large means a single drain stalls the producer for too long, which itself becomes a latency spike. Sweep 8 / 32 / 128 in a side experiment if needed; pick one before the headline runs.
- The return queue is sized identically to the forward queue (1024). Justification: same back-pressure shape, same memory footprint, easy to reason about.

### 3. `arena-batch-handoff`

Producer bump-allocates from a rotating set of arenas. Consumer publishes drain progress per arena; producer reuses an arena only when the consumer has fully drained it.

```cpp
struct Arena {
    alignas(64) std::atomic<size_t> producer_pos{0};  // bump pointer (orders)
    alignas(64) std::atomic<size_t> consumer_pos{0};  // drain progress (orders)
    alignas(64) std::unique_ptr<Order[]> slots;
    size_t capacity;
    
    bool fully_drained() const {
        return consumer_pos.load(std::memory_order_acquire) >= producer_pos.load(std::memory_order_relaxed);
    }
};

class ArenaBatchAllocator {
    static constexpr size_t ARENA_COUNT     = 4;
    static constexpr size_t ARENA_CAPACITY  = 4096;  // orders per arena
    
    Arena arenas_[ARENA_COUNT];
    size_t current_ = 0;
    uint64_t orders_in_current_ = 0;
    
public:
    ArenaBatchAllocator() {
        for (auto& a : arenas_) {
            a.slots = std::make_unique<Order[]>(ARENA_CAPACITY);
            a.capacity = ARENA_CAPACITY;
        }
    }
    
    Order* allocate() {            // called by producer
        Arena& a = arenas_[current_];
        if (orders_in_current_ >= a.capacity) [[unlikely]] {
            // Publish that this arena is fully filled (no more writes).
            a.producer_pos.store(orders_in_current_, std::memory_order_release);
            
            // Rotate to next arena.
            current_ = (current_ + 1) % ARENA_COUNT;
            orders_in_current_ = 0;
            
            Arena& next = arenas_[current_];
            // Wait for consumer to finish draining this arena, if necessary.
            while (!next.fully_drained()) { _mm_pause(); }
            // Reset next arena's positions for reuse.
            next.producer_pos.store(0, std::memory_order_relaxed);
            next.consumer_pos.store(0, std::memory_order_relaxed);
        }
        
        Order* o = &arenas_[current_].slots[orders_in_current_++];
        o->arena_idx = static_cast<uint8_t>(current_);
        return o;
    }
    
    void deallocate(Order* o) {    // called by consumer
        Arena& a = arenas_[o->arena_idx];
        // Increment drain progress for the order's arena. We don't need to know
        // the exact slot index — we just publish "one more drained from this arena."
        a.consumer_pos.fetch_add(1, std::memory_order_release);
    }
};
```

Notes:

- 4 arenas of 4096 orders each = 16 K in-flight capacity, far more than the 1024 queue depth ever uses. Headroom is deliberate: the producer should never wait on `fully_drained()` under normal load. If it does, calibration is wrong.
- The producer never touches `consumer_pos` except via `fully_drained()` during rotation. The consumer never touches `producer_pos`. This is two single-writer fields with the queue-style memory ordering.
- `arena_idx` lives in the Order struct (set at allocation). This is one byte of overhead in the Order layout but it makes deallocate O(1) without arena-search.
- `[[unlikely]]` on the rotation branch matters: in steady state, 99.97% of allocations are just `&slots[orders_in_current_++]`, which is one load and one store.

## Measurement

### Modes

Two modes, mirroring demo 4's structure:

**Mode A — `paced` (the headline)**

Producer paces at fixed offered load (default 1 MHz). T_bg runs at fixed default background pressure (1 M ops/sec; see Calibration). 5 iterations of 1 M items each per variant, histograms merged elementwise, stats computed from merged histogram. Top-level result is one `latency_ns` block per variant with 5 M samples.

**Mode B — `pressure_sweep`**

Producer paces at fixed offered load (1 MHz). T_bg's rate is the swept axis. Log-spaced from 100 k/s to 10 M/s in 8 points, plus one extra run at 0 (T_bg not spawned). Total of 9 sweep points × 3 variants = 27 sweep runs.

For each sweep point: 1 iteration of 1 M items (not 5 — sweep is for shape, headline measurement is paced mode). Each sweep point emits one `runs[]` entry with `mode: "pressure_sweep"`, its `background_pressure_hz`, and the resulting `latency_ns.stats`.

A `--verify-warmup` flag in the binary writes histograms of items 0–10 k and items 100 k+ to stderr for one-time verification (mirroring demo 4's pattern). Lock in once verified.

### Warmup

100,000 items pre-roll before measurement starts. Identical to demo 4. Consumer publishes a `warmup_consumed` counter; producer waits for it before flipping the measurement-active flag.

### Items measured per run

1,000,000 per iteration. 5 iterations per variant for paced mode (5 M total samples). 1 iteration per variant per sweep point for sweep mode (1 M samples per point).

### Headline metric

End-to-end latency = `tsc_to_ns(consumer_dealloc_tsc - producer_construct_tsc)`. This includes:

- The allocator's `allocate()` cost on the producer side (negligible for variants 2/3, variable for malloc under pressure)
- Queue residency (paced at 1 MHz, expected to be near-empty for all variants — same as demo 4)
- Consumer's risk-check work (~150-300 ns, roughly constant across variants)
- The allocator's `deallocate()` cost on the consumer side

The interesting variance across variants is in the allocate/deallocate components. The risk-check work is included so the measurement reflects realistic per-order processing — not just allocator microbenchmark.

## Schema additions

All additive. Existing fields preserved. Per-run schema gains:

```json
{
  "variant": "freelist-return-queue",
  "mode": "paced",                              // or "pressure_sweep"
  "offered_rate_hz": 1000000,
  "background_pressure_hz": 1000000,            // NEW
  "background_size_classes": [32, 64, 128, 256, 512, 1024],  // NEW, documented config
  "consumer_work_target_ns": 200,               // NEW, what we calibrated to
  
  // Variant-specific (present only on relevant variants):
  "freelist_initial_slots": 4096,               // variant 2 only
  "return_queue_depth": 1024,                   // variant 2 only
  "freelist_drain_batch": 32,                   // variant 2 only
  "arena_count": 4,                             // variant 3 only
  "arena_capacity_orders": 4096,                // variant 3 only
  
  // Existing fields (unchanged):
  "n": 1024,
  "items_measured": 1000000,
  "items_warmup": 100000,
  "iterations": 5,
  "ns_per_op": { "median": ..., "min": ..., "p99": ..., "iqr": ... },
  "ops_per_sec": ...,
  "latency_ns": {
    "scheme": "log2_subbuckets_16",
    "percentile_convention": "log2_bucket_midpoint",
    "bucket_count": 384,
    "min_bucket_ns": 1,
    "counts": [...],
    "stats": { "count": ..., "min": ..., "max": ..., "p50": ..., "p90": ..., "p99": ..., "p99_9": ... }
  },
  "top_bucket_count": 0,
  "calibration_drift_pct": 0.0
}
```

The `<Benchmark>` MDX component already filters by `variants` and `mode` (extended in demo 4). Confirm it can also filter by `background_pressure_hz` for the sweep chart — if not, extend its filter contract before drawing sweep charts.

The `machine` block gains no new fields. `tsc_ns_per_cycle` (from demo 4) is reused.

## Hardware gotchas baked into implementation

- **Producer pinned to core 4.** **Consumer pinned to core 5.** Both on CCX1 of the 3800X — same L3 slice. Matches demo 4's same-CCX configuration so the queue-crossing cost is comparable.
- **Background pressure thread T_bg pinned to core 6.** Same CCX1 as producer/consumer. Justification: T_bg shares L3 with P/C, which is the realistic "other subsystems on the same NUMA domain" model. If T_bg were on a different CCX, it would stress the heap without cache impact and the demo would understate the realistic interference.
- **Cross-CCX side note (one-page section in the post, not part of the headline data).** A small additional run with producer on core 4 (CCX1) and consumer on core 1 (CCX0), T_bg on core 6. This single side experiment shows how the allocator picture changes when the queue crosses CCX. Not part of the headline; mentioned for completeness. Generate one JSON file per variant for this side experiment, e.g. `05-allocators-cross-ccx.json`, and load it in a separate `<LatencyHistogram>` block in the post's "Cross-CCX side note" section.
- All threads verify their affinity at thread start via `sched_getcpu()` against an expected core. Abort on mismatch.
- TSC calibration: verify `constant_tsc`, `nonstop_tsc`, and `__builtin_cpu_supports("invariant_tsc")`. Abort cleanly with a diagnostic on missing. Same pattern as demo 4.
- Memory ordering: each `std::atomic` load/store has an explicit `memory_order` argument and a one-line comment. `acquire`/`release` only — no `seq_cst` in the hot path. Apply to `producer_pos` / `consumer_pos` in the arena variant, and to the return queue's existing SPSC primitive (which already has this).
- Cache-line considerations: Order is 64 B aligned. Arena's `producer_pos` and `consumer_pos` are each on their own cache line (`alignas(64)`) to avoid false sharing between writer and reader.

## Build / file layout

```
bench/
├── common/
│   ├── perf_wrapper.h            # existing
│   ├── stats.h                   # existing
│   ├── machine_info.h            # existing
│   ├── histogram.h               # existing
│   └── spsc_queue.h              # PRECONDITION: lifted from demo 04
├── demos/
│   └── 05-allocators/
│       ├── CMakeLists.txt
│       ├── README.md
│       ├── order.h                       # Order struct
│       ├── risk_check.h                  # simulated risk-check work + tables
│       ├── background_pressure.h         # T_bg loop
│       ├── allocators/
│       │   ├── malloc_allocator.h
│       │   ├── freelist_return_allocator.h
│       │   └── arena_batch_allocator.h
│       └── benchmark.cpp                 # dispatches all 3 variants, both modes
```

Single binary `bench_05_allocators` accepts variant + mode + parameters:

```
bench_05_allocators <variant> --mode paced     [--offered-rate-hz N] [--bg-pressure-hz N]
bench_05_allocators <variant> --mode pressure_sweep
                              [--bg-from N --bg-to N --steps K]
                              [--offered-rate-hz N]
bench_05_allocators --machine-info
bench_05_allocators <variant> --verify-warmup
```

Defaults: `offered-rate-hz=1000000`, `bg-pressure-hz=1000000` (paced mode), `bg-from=100000 bg-to=10000000 steps=8` (sweep mode). Variant names: `cross-thread-malloc | freelist-return-queue | arena-batch-handoff`.

`bench/scripts/run_one.sh 05-allocators` orchestrates the full capture: paced runs (5 iter each) + pressure_sweep runs (1 iter each) for all three variants. Plus the cross-CCX side experiment (paced only). Output written to `site/src/data/perf/05-allocators.json` (primary) and `site/src/data/perf/05-allocators-cross-ccx.json` (side note).

CMakeLists is conventional: link `pthread`, include `bench/common/`, C++20, `-O3 -march=native`. No external dependencies new beyond what demo 4 already requires.

## Site additions

When the feature branch merges to main, these changes overwrite the stub from the teaser brief:

- `site/src/posts/05-allocators.mdx` — full post (replaces stub from teaser).
- Frontmatter: remove `status: "in-progress"` and `expectedAt`. Set `date` to the capture date. Keep `excerpt` (refine wording as needed).
- `site/src/data/perf/05-allocators.json` — main JSON output.
- `site/src/data/perf/05-allocators-cross-ccx.json` — side-experiment JSON.
- `site/src/components/charts/PressureSweep.tsx` — new chart component (if not reusable from existing components). See below.

### `<PressureSweep>` chart contract

```jsx
<PressureSweep
  slug="05-allocators"
  variants={["cross-thread-malloc", "freelist-return-queue", "arena-batch-handoff"]}
  metric="p99_9"                  // "p50" | "p99" | "p99_9" — default "p99_9"
  xAxis="background_pressure_hz"
  yAxisLabel="p99.9 latency (ns)"
/>
```

- x-axis: `background_pressure_hz`, log scale, range from min to max sweep point (plus a discrete "0" tick if the no-bg baseline is included).
- y-axis: chosen percentile from `latency_ns.stats`, log scale, range auto-fit.
- One line per variant. 2 px stroke, no fill. Variant colours from `components/charts/theme.ts`, matching demo 4's palette assignments.
- Marker points at each sweep step, small filled circles.
- Optional: render a faint horizontal line at the malloc variant's p99.9 from the *no-bg* run, to make "this is the floor; tail grows with pressure" visible at a glance.

**If demo 4's load-sweep chart already implements a generalisable line-chart-of-sweep-result, prefer to extend that component rather than introduce a new one.** This is an open item — see Open Items.

### Post structure (MDX)

Adapt the structure from demo 4. Required sections:

1. *Opening framing* — capital-markets motivation, the 1-paragraph trading-shop pipeline.
2. *The thesis* — median vs tail, allocator design as derivative of threading model.
3. *Setup* — Order struct, three variants, the cross-thread free pattern, the SPSC queue (link to demo 4).
4. *Background heap pressure* — what it is, why it's there, why the demo is dishonest without it.
5. *Headline latency picture* — `<LatencyHistogram>` showing all three variants overlaid at the default pressure. CCDF view, p50/p99/p99.9 markers.
6. *Throughput* — `<ThroughputBars>` as a secondary view. Brief commentary.
7. *Pressure sweep* — `<PressureSweep>` showing p99.9 across the sweep. The story of how malloc's tail grows while the pool variants stay flat.
8. *The freelist-vs-arena trade-off* — the post's interesting twist. The arena wins on median, the freelist wins on p99. Show the data; reason about why.
9. *Cross-CCX side note* — one paragraph + one `<LatencyHistogram>` from the cross-CCX JSON. What changes; why we're not making it the headline.
10. *What this doesn't show* — explicit list of scoping decisions (no jemalloc, single producer/consumer, fixed Order size, no variable-length fields, no NUMA crossing).
11. *Reproducing this* — link to bench source, the run command, the hardware spec.
12. *Takeaway* — the design choice depends on whether your latency budget is in the median or the tail.

Length target: comparable to demo 4. Do not pad. Every chart needs a paragraph that says what the reader is supposed to see, written from the data after capture, not from the brief's expectations.

## Acceptance criteria

### C++ / capture

- `bench_05_allocators --machine-info` emits a JSON object structurally identical to the `machine` block produced by demo 04 (turbo, isolated_cpus_*, cpu_affinity, lscpu_extended, tsc_ns_per_cycle, etc).
- `bench_05_allocators` accepts the CLI shape above. Defaults match.
- Each variant runs in paced mode at 1 MHz offered load + 1 M/sec background pressure without slot exhaustion (variant 2) or arena wait stalls (variant 3) under normal load. CC instruments and verifies these invariants in a debug build.
- Pressure sweep emits exactly 9 sweep points (1 zero baseline + 8 log-spaced 100 k to 10 M) per variant.
- `static_assert(sizeof(Order) == 64)` and `alignof(Order) == 64` hold.
- All `std::atomic` ops in the hot path use `acquire`/`release`. No `seq_cst`. Comments on each ordering choice.
- Affinity is verified at thread start; mismatch aborts.
- `--verify-warmup` produces the documented stderr output. One-time check during implementation; result recorded in the demo README.
- `latency_ns.stats.max >= latency_ns.stats.p99_9` for every run. (The demo 4 bug must not recur.)
- Build succeeds: `cmake --build build --clean-first` on the reference machine.

### Schema

- New fields appear only on demo 05 records; demos 01-04 JSON unchanged.
- `mode` and `offered_rate_hz` semantics match demo 4 (the additive fix-up brief's contract).
- `background_pressure_hz` is `null` (not omitted) on runs where T_bg was not spawned (sweep step 0 baseline).

### Site

- `site/src/posts/05-allocators.mdx` exists with no `status` or `expectedAt` frontmatter (they're removed when the real post lands).
- The index card for demo 05 renders without the WIP pill (because the frontmatter no longer says `in-progress`).
- All charts render with no console errors.
- `<PressureSweep>` reads `background_pressure_hz` from sweep records and plots correctly with log-scale axes.
- `<LatencyHistogram>` on the cross-CCX section reads from the separate JSON file without breaking the main JSON.
- Lighthouse Performance ≥ 90, Accessibility ≥ 90 on `/posts/05-allocators` (matching the other shipped demos).
- No internal contradictions: every reference to "X background pressure points" agrees with the JSON; every reference to "N variants" agrees on N.

### Post

- All numerical claims in prose are derived from the JSON, not the brief. Any sentence like "the malloc variant's p99.9 is N× the arena's" matches `latency_ns.stats.p99_9` from the actual JSON to one significant figure.
- The "What this doesn't show" section lists at minimum: no jemalloc/mimalloc/tcmalloc comparison; strictly 1P/1C; fixed Order size; no variable-length payload; same-CCX headline + brief cross-CCX note.
- Capital-markets framing is one paragraph, not a recurring drumbeat.
- Link to demo 4 in the SPSC queue reuse section.

## Out of scope

- jemalloc / mimalloc / tcmalloc comparison (future post).
- Multi-producer or multi-consumer patterns.
- Variable-length or heterogeneous Order representations.
- NUMA-crossing (this machine is single-NUMA-node).
- Any modifications to demos 1-4 prose, code, or JSON.
- Any modifications to the shipped chart components beyond a possible `<PressureSweep>` extension. `<LatencyHistogram>` and `<ThroughputBars>` are used unchanged.
- A "drop-in replacement allocator" comparison (i.e., compiling with `LD_PRELOAD=libjemalloc.so`). Mention as future work in the "What this doesn't show" section.
- Stress / endurance testing of the variants over hours of runtime.
- Any change to the SPSC queue contract beyond lifting it to `common/`. The queue ABI is fixed.

## Open items for CC to flag

1. **SPSC queue location.** If `bench/demos/04-spsc-queue/spsc_queue.h` still lives under demo 04's directory rather than `bench/common/`, the first task is to lift it (with `git mv`, no behavioural change) and update demo 04's `#include`. Verify demo 04 still builds and its JSON regenerates identically. Do **not** proceed with demo 05 until this is done — demo 05 cannot include from another demo's directory.

2. **Reusable sweep chart.** If demo 04's load-sweep chart is a generalisable line-chart component (e.g., `<SweepChart>` taking variants and a metric), reuse / extend it for `<PressureSweep>` rather than introducing a parallel component. Surface the choice in the PR.

3. **`<Benchmark>` MDX wrapper filter contract.** Demo 4 extended it to filter by `mode` and `offered_rate_hz`. Confirm it can also filter by `background_pressure_hz` for the sweep chart, or extend its contract. Surface the extension.

4. **Calibration of consumer work weight.** Target 150-300 ns. If the chosen implementation lands outside that band, adjust the table sizes or drop/add a check until it fits. Document the measured wall-clock in the README and in `consumer_work_target_ns` in the JSON. Do not silently ship with 600 ns of work and call it 300.

5. **Calibration of background pressure default.** Target 1 M/sec churn, must produce visible variant separation in the paced headline. If at 1 M/s the malloc p99.9 vs arena p99.9 ratio is below 2×, raise pressure (up to 3 M/sec). If at 3 M/sec the separation is still below 2× **stop and flag** — the demo's premise is in trouble and we need to re-scope before writing the post.

6. **Freelist drain batch size.** Default 32. If during calibration the producer's allocate latency shows a visible drain-induced spike at this batch size, sweep 8 / 32 / 128 and pick the one that keeps the producer-side allocate latency tightest. Lock in before the headline measurement.

7. **Arena fully-drained wait.** Under normal 1 MHz offered load, the producer should never wait. Instrument the producer to count wait occurrences; if it waits more than once per 100 k orders, calibration is wrong.

8. **PRNG determinism.** All RNGs (the order generator's `rng`, T_bg's `rng`, any others) use fixed seeds for reproducibility. Document the seeds in the README.

9. **Background pressure isolation.** Confirm that on the reference machine, T_bg pinned to core 6 (same CCX) does not push the producer or consumer off their cores under load — `taskset -p` and `htop` checks during a representative run.

10. **JSON top-level structure.** The combined `05-allocators.json` should have a single `runs[]` array containing all paced + sweep runs across all three variants. The cross-CCX side-note JSON is a separate file. Confirm the consumer (`<Benchmark>` and chart components) handles this shape correctly with the new mode value.

11. **The `arena_idx` field.** This is one byte of Order overhead used only by variant 3. Variants 1 and 2 leave it zero. Consider whether to omit it from variants 1/2's path entirely (it's just dead-write overhead) or leave it as a constant zero. My read: leave it. The cost is one MOV, well below noise. Flag if measurement disagrees.

12. **Two side-experiment JSON outputs.** The cross-CCX side note uses its own JSON file (`05-allocators-cross-ccx.json`). Confirm the build script generates both, and the MDX loads both correctly. Don't merge them — keeping the cross-CCX data in a separate file makes the "this is a side note" framing concrete in the data layout.

## Notes for CC

- This is the biggest brief in the series so far. Budget ~4-6 days of CC time. Stage the work: (1) precondition SPSC lift, (2) Order + risk-check + background pressure (without allocators), (3) one allocator at a time with debug instrumentation, (4) paced mode capture, (5) sweep mode capture, (6) cross-CCX side experiment, (7) MDX. Don't try to land the whole thing in one PR — stage it and surface intermediate state.

- The two highest-risk items are (a) background-pressure calibration and (b) freelist-vs-arena measurement separation. Both can kill the demo. If at the end of step (4) the headline picture doesn't show clear separation between variants, **stop and report** rather than press on to step (5). The fix is calibration, not more measurement.

- The post is replacing a published stub on main. The stub's URL (`/posts/05-allocators`) is already live by the time this work starts. Per-branch Amplify preview should be where you review chart rendering during development; merge to main only when the post is complete and the cross-CCX side note is in place.

- The "What this doesn't show" section is not boilerplate — it's the post's most important defence against a skeptical hedge-fund reviewer. Take it seriously.

- All numerical claims must be regenerated from the captured JSON. Do not pre-write prose with placeholder numbers. The prose-writing pass happens after capture.
