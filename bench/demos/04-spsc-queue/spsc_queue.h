#pragma once
// Hand-rolled single-producer single-consumer ring buffer.
// Capacity N must be a power of 2. head_ and tail_ each occupy one 64-byte
// cache line to eliminate false sharing between the producer and consumer cores.
//
// Memory ordering rationale:
//   - Producer is the sole writer of tail_; consumer is the sole writer of head_.
//   - Producer reads head_ with acquire to observe consumer progress before
//     testing for fullness — ensures the producer sees the latest consumed index.
//   - Producer writes tail_ with release so the consumer sees the data write
//     before it sees the incremented tail.
//   - Consumer reads tail_ with acquire to observe producer progress before
//     testing for emptiness — ensures the consumer sees the written data.
//   - Consumer writes head_ with release so the producer sees the updated head
//     and can reclaim the slot.
//   - Each atomic load of the writer's own counter uses relaxed order because no
//     other thread writes that counter.

#include <atomic>
#include <cstddef>

template <typename T, size_t N>
class SPSCQueue {
    static_assert(N > 0 && (N & (N - 1)) == 0, "N must be a power of 2");
    static constexpr size_t MASK = N - 1;

    struct alignas(64) PaddedAtomic {
        std::atomic<size_t> value{0};
        char pad[64 - sizeof(std::atomic<size_t>)];
    };

    PaddedAtomic head_{};  // sole writer: consumer
    PaddedAtomic tail_{};  // sole writer: producer
    alignas(64) T buffer_[N];

    static_assert(sizeof(PaddedAtomic) == 64,
                  "PaddedAtomic must occupy exactly one cache line");
    static_assert(alignof(PaddedAtomic) == 64,
                  "PaddedAtomic must be 64-byte aligned");
    // head_ and tail_ are consecutive 64-byte-aligned PaddedAtomic members,
    // so they're guaranteed on separate cache lines by construction.
public:
    SPSCQueue() = default;
    SPSCQueue(const SPSCQueue&) = delete;
    SPSCQueue& operator=(const SPSCQueue&) = delete;

    // Returns true and enqueues item if the queue has room; false if full.
    bool try_push(const T& item) noexcept {
        const size_t tail = tail_.value.load(std::memory_order_relaxed);
        // Acquire: see consumer's head_ store before deciding fullness.
        const size_t head = head_.value.load(std::memory_order_acquire);
        if (tail - head >= N) return false;
        buffer_[tail & MASK] = item;
        // Release: publish buffer_ write to consumer.
        tail_.value.store(tail + 1, std::memory_order_release);
        return true;
    }

    // Returns true and sets item if the queue has an entry; false if empty.
    bool try_pop(T& item) noexcept {
        const size_t head = head_.value.load(std::memory_order_relaxed);
        // Acquire: see producer's tail_ store (and the buffer_ write it synchronises).
        const size_t tail = tail_.value.load(std::memory_order_acquire);
        if (head == tail) return false;
        item = buffer_[head & MASK];
        // Release: publish updated head_ to producer so it can reuse the slot.
        head_.value.store(head + 1, std::memory_order_release);
        return true;
    }
};
