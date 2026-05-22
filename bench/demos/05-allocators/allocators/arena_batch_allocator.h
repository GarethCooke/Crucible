#pragma once
// Variant 3: arena-batch-handoff
// Producer bump-allocates from a rotating set of arenas. Consumer increments
// consumer_pos per arena as it drains orders. Producer recycles an arena only
// when fully_drained() returns true.
//
// ARENA_COUNT = 4, ARENA_CAPACITY = 4096 → 16K in-flight capacity, far more than
// the 1024 queue depth. Headroom ensures the producer never waits under normal load.
//
// Memory ordering: producer_pos is written only by the producer; consumer_pos only
// by the consumer. acquire/release pairs enforce the happens-before needed for slot
// reuse. No seq_cst in the hot path.

#include "../order.h"

#include <atomic>
#include <cstddef>
#include <memory>

#include <x86intrin.h>  // _mm_pause

struct Arena {
    // Each counter on its own cache line: producer writes producer_pos,
    // consumer writes consumer_pos — separate lines prevent false sharing.
    alignas(64) std::atomic<size_t> producer_pos{0};
    alignas(64) std::atomic<size_t> consumer_pos{0};
    alignas(64) std::unique_ptr<Order[]> slots;
    size_t capacity = 0;

    // Returns true when consumer has acknowledged all orders produced so far.
    // Uses acquire on consumer_pos so the reuse reset below happens-after.
    bool fully_drained() const noexcept {
        return consumer_pos.load(std::memory_order_acquire)
            >= producer_pos.load(std::memory_order_relaxed);
    }
};

class ArenaBatchAllocator {
    static constexpr size_t ARENA_COUNT    = 4;
    static constexpr size_t ARENA_CAPACITY = 4096;

    Arena   arenas_[ARENA_COUNT];
    size_t  current_            = 0;
    size_t  orders_in_current_  = 0;

    // Debug instrumentation: count how many times the producer had to wait.
    // Should be zero (or near-zero) under correct sizing.
public:
    uint64_t wait_count = 0;

    const size_t arena_count    = ARENA_COUNT;
    const size_t arena_capacity = ARENA_CAPACITY;

    ArenaBatchAllocator() {
        for (auto& a : arenas_) {
            a.slots    = std::make_unique<Order[]>(ARENA_CAPACITY);
            a.capacity = ARENA_CAPACITY;
        }
    }

    // Called by producer. Fast path (>99.97% of calls): one bounds check + increment.
    Order* allocate() {
        Arena& a = arenas_[current_];
        if (orders_in_current_ >= a.capacity) [[unlikely]] {
            // Publish that this arena is fully filled; no more writes.
            // release: consumer sees all prior slot writes before producer_pos.
            a.producer_pos.store(orders_in_current_, std::memory_order_release);

            // Rotate to next arena.
            current_ = (current_ + 1) % ARENA_COUNT;
            orders_in_current_ = 0;

            Arena& next = arenas_[current_];
            // Wait for consumer to finish draining this arena (should be instant).
            while (!next.fully_drained()) {
                ++wait_count;
                _mm_pause();
            }
            // Reset for reuse. relaxed: sole writer; visibility comes from the
            // next producer_pos release store when this arena fills again.
            next.producer_pos.store(0, std::memory_order_relaxed);
            next.consumer_pos.store(0, std::memory_order_relaxed);
        }

        Order* o = &arenas_[current_].slots[orders_in_current_++];
        o->arena_idx = static_cast<uint8_t>(current_);
        return o;
    }

    // Called by consumer. Increments drain progress for the order's arena.
    // release: producer sees this store before testing fully_drained().
    void deallocate(Order* o) noexcept {
        arenas_[o->arena_idx].consumer_pos.fetch_add(1, std::memory_order_release);
    }
};
