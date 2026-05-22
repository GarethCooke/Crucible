#pragma once
// Variant 2: freelist-return-queue
// Producer keeps a thread-local freelist. Consumer returns used Orders via a
// second SPSC queue (C → P). Producer drains the return queue in batches when
// its local freelist runs empty.
//
// INITIAL_SLOTS = 4096 covers in-flight max under 1 MHz offered load:
//   forward queue depth (1024) + drain batching slack + safety margin.
//
// DRAIN_BATCH = 32: default; sweep 8/32/128 if producer-side drain spikes appear.
// Return queue depth = 1024 (matches forward queue depth).

#include "../order.h"
#include "spsc_queue.h"

#include <memory>
#include <vector>

#include <x86intrin.h>  // _mm_pause

class FreelistReturnAllocator {
    static constexpr size_t INITIAL_SLOTS = 4096;
    static constexpr size_t DRAIN_BATCH   = 32;
    static constexpr size_t RETURN_DEPTH  = 1024;

    // C → P return path. Allocator owns this queue.
    SPSCQueue<Order*, RETURN_DEPTH> return_;

    std::vector<Order*>     local_free_;
    std::unique_ptr<Order[]> slab_;     // pre-allocated slot pool

public:
    const size_t initial_slots = INITIAL_SLOTS;
    const size_t drain_batch   = DRAIN_BATCH;
    const size_t return_depth  = RETURN_DEPTH;

    FreelistReturnAllocator() {
        slab_ = std::make_unique<Order[]>(INITIAL_SLOTS);
        local_free_.reserve(INITIAL_SLOTS);
        for (size_t i = 0; i < INITIAL_SLOTS; ++i)
            local_free_.push_back(&slab_[i]);
    }

    // Called by producer. Drains return queue if local freelist is empty.
    Order* allocate() {
        drain_return_queue();
        if (local_free_.empty()) [[unlikely]] {
            // Slab exhausted — should not happen under correct sizing.
            // Spin until the consumer returns something.
            while (local_free_.empty()) {
                drain_return_queue();
                _mm_pause();
            }
        }
        Order* o = local_free_.back();
        local_free_.pop_back();
        return o;
    }

    // Called by consumer. Pushes the used Order onto the return queue.
    void deallocate(Order* o) {
        // Spin if return queue is full (should not happen under correct sizing).
        while (!return_.try_push(o)) { _mm_pause(); }
    }

private:
    void drain_return_queue() {
        for (size_t i = 0; i < DRAIN_BATCH; ++i) {
            Order* o = nullptr;
            if (!return_.try_pop(o)) break;
            local_free_.push_back(o);
        }
    }
};
