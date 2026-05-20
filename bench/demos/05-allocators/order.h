#pragma once
#include <cstdint>

enum class Side : uint8_t { Buy = 0, Sell = 1 };

// Fixed 64 B, exactly one cache line. Cross-thread: constructed on T_p, freed on T_c.
// arena_idx is set by ArenaBatchAllocator::allocate(); variants 1 and 2 leave it zero.
struct alignas(64) Order {
    uint64_t ts_create_tsc;  // 8B  TSC at producer construction (after allocate returns)
    uint64_t seq;            // 8B  monotonic sequence
    int64_t  price;          // 8B  fixed-point, scaled
    int32_t  qty;            // 4B
    uint32_t client_id;      // 4B
    uint32_t symbol_id;      // 4B
    uint32_t risk_seq;       // 4B  stamped by risk check
    Side     side;           // 1B
    uint8_t  arena_idx;      // 1B  used by variant 3; zero for variants 1 and 2
    uint8_t  _pad[18];       // 18B round to 64B
};

static_assert(sizeof(Order)  == 64, "Order must be exactly one cache line");
static_assert(alignof(Order) == 64, "Order must be cache-line aligned");
