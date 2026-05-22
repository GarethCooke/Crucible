#pragma once
// Simulated risk-check work. Three small tables sized to fit comfortably in L1d.
// Target wall-clock: 150–300 ns. Calibrate during implementation:
//   - If too light (<100 ns), expand by adding a fourth lookup (e.g. open-orders-per-symbol).
//   - If too heavy (>500 ns), drop the velocity check.
// The calibrated value is recorded in consumer_work_target_ns in the JSON output.

#include "order.h"
#include <cstdint>

// ─── Risk tables ─────────────────────────────────────────────────────────────

struct PositionEntry { int64_t qty; double notional; uint32_t opens; uint32_t _pad; }; // 24B
struct LimitEntry    { int64_t max_long; int64_t max_short; uint32_t max_per_sec; uint32_t _pad; }; // 24B
struct VelocityEntry { uint64_t last_ts_ns; uint32_t count; uint32_t _pad; }; // 16B

constexpr uint64_t VELOCITY_WINDOW_NS = 1'000'000;  // 1 ms window

// All mutable risk state in one struct so it has no static lifetime and
// the consumer thread can hold it by reference without global initialisation.
struct RiskState {
    PositionEntry positions[1024];  // ~24 KB — L1 hot
    LimitEntry    limits[256];      // ~6 KB  — L1
    VelocityEntry velocity[256];    // ~4 KB  — L1
    uint64_t      rejects  = 0;
    uint32_t      risk_seq = 0;

    void init() {
        for (auto& p : positions) { p.qty = 0; p.notional = 0.0; p.opens = 0; p._pad = 0; }
        for (auto& l : limits) {
            l.max_long    =  100'000;
            l.max_short   = -100'000;
            l.max_per_sec = 10'000;
            l._pad = 0;
        }
        for (auto& v : velocity) { v.last_ts_ns = 0; v.count = 0; v._pad = 0; }
        rejects  = 0;
        risk_seq = 0;
    }

    void check(Order* o, uint64_t now_ns) {
        PositionEntry& pos = positions[o->symbol_id & 1023];
        LimitEntry&    lim = limits[o->client_id & 255];
        VelocityEntry& vel = velocity[o->client_id & 255];

        const int64_t delta = (o->side == Side::Buy) ? o->qty : -o->qty;
        pos.qty      += delta;
        pos.notional += static_cast<double>(o->qty) * static_cast<double>(o->price);
        ++pos.opens;

        if (pos.qty > lim.max_long || pos.qty < lim.max_short) {
            ++rejects;
        }

        if (now_ns - vel.last_ts_ns > VELOCITY_WINDOW_NS) {
            vel.last_ts_ns = now_ns;
            vel.count = 1;
        } else if (++vel.count > lim.max_per_sec) {
            ++rejects;
        }

        o->risk_seq = ++risk_seq;
    }
};
