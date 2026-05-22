#pragma once
// Variant 1: cross-thread-malloc
// Baseline: producer calls new Order, consumer calls delete.
// No domain-specific pooling. The interest is in what the tail looks like
// under background heap pressure.

#include "../order.h"

class MallocAllocator {
public:
    Order* allocate() {
        return new Order{};
    }

    void deallocate(Order* o) {
        delete o;
    }
};
