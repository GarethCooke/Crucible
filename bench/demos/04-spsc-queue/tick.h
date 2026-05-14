#pragma once
#include <cstdint>

// 16-byte POD representing a single market-data tick.
// price/qty are placeholder values; seq is used by the consumer to reconstruct
// delivery order and index into per-item timestamp buffers.
struct MarketTick {
    uint32_t price;
    uint32_t qty;
    uint64_t seq;
};
static_assert(sizeof(MarketTick) == 16, "MarketTick must be 16 bytes");
