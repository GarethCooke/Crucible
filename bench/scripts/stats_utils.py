"""Shared statistics utilities for benchmark result scripts."""

from typing import Callable


def build_groups(benchmarks: list, parse_name_fn: Callable) -> dict:
    """Group iteration records by (variant, n) via the supplied name parser."""
    groups: dict = {}
    for b in benchmarks:
        if b.get("run_type") != "iteration":
            continue
        parsed = parse_name_fn(b["name"])
        if parsed is None:
            continue
        key = (parsed["variant"], parsed["n"])
        groups.setdefault(key, []).append(b)
    return groups


def percentile(sorted_values: list[float], p: float) -> float:
    """Linear-interpolation percentile. sorted_values must already be sorted."""
    s = sorted_values
    n = len(s)
    if n == 0:
        return 0.0
    idx = p / 100.0 * (n - 1)
    lo = int(idx)
    frac = idx - lo
    if lo + 1 >= n:
        return s[-1]
    return s[lo] * (1.0 - frac) + s[lo + 1] * frac


def bench_stats(values: list[float]) -> dict:
    """Standard timing stats dict used in benchmark JSON output."""
    if not values:
        return {"median": 0, "min": 0, "p99": 0, "iqr": 0}
    s = sorted(values)
    return {
        "median": round(percentile(s, 50), 4),
        "min":    round(s[0],              4),
        "p99":    round(percentile(s, 99), 4),
        "iqr":    round(percentile(s, 75) - percentile(s, 25), 4),
    }
