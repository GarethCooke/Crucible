"""Unit tests for parse_perf.py — parse_perf_json, parse_bench_json, derive_counters."""

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.dirname(__file__))
from parse_perf import N_FILLS, N_ITERS, derive_counters, parse_bench_json, parse_perf_json


def _write_bench_json(benchmarks: list[dict]) -> Path:
    """Write a minimal Google Benchmark JSON file and return its Path."""
    f = tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False)
    json.dump({"benchmarks": benchmarks}, f)
    f.close()
    return Path(f.name)


def _write_perf_json(lines: list[str]) -> Path:
    """Write perf-stat-style JSON lines to a temp file and return its Path."""
    f = tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False)
    f.write("\n".join(lines) + "\n")
    f.close()
    return Path(f.name)


class TestParsePerfJson(unittest.TestCase):
    def tearDown(self):
        # Clean up any temp files created during the test
        if hasattr(self, "_tmp") and self._tmp.exists():
            self._tmp.unlink()

    def _parse(self, lines):
        self._tmp = _write_perf_json(lines)
        return parse_perf_json(self._tmp)

    # ── normal cases ─────────────────────────────────────────────────────────

    def test_single_event(self):
        counts = self._parse([
            json.dumps({"event": "cache-misses", "counter-value": "12345"}),
        ])
        self.assertEqual(counts["cache-misses"], 12345)

    def test_multiple_events(self):
        counts = self._parse([
            json.dumps({"event": "cache-misses",     "counter-value": "100"}),
            json.dumps({"event": "cache-references", "counter-value": "2000"}),
            json.dumps({"event": "instructions",     "counter-value": "50000"}),
            json.dumps({"event": "cycles",           "counter-value": "30000"}),
        ])
        self.assertEqual(counts["cache-misses"],     100)
        self.assertEqual(counts["cache-references"], 2000)
        self.assertEqual(counts["instructions"],     50000)
        self.assertEqual(counts["cycles"],           30000)

    def test_value_with_commas(self):
        # perf stat formats large numbers with commas: "1,234,567"
        counts = self._parse([
            json.dumps({"event": "instructions", "counter-value": "1,234,567"}),
        ])
        self.assertEqual(counts["instructions"], 1234567)

    def test_float_string_truncated_to_int(self):
        counts = self._parse([
            json.dumps({"event": "cycles", "counter-value": "9999.9"}),
        ])
        self.assertEqual(counts["cycles"], 9999)

    # ── robustness / skipping ────────────────────────────────────────────────

    def test_empty_file_returns_empty_dict(self):
        counts = self._parse([])
        self.assertEqual(counts, {})

    def test_comment_lines_skipped(self):
        counts = self._parse([
            "# perf stat output",
            json.dumps({"event": "cycles", "counter-value": "42"}),
        ])
        self.assertNotIn("#", counts)
        self.assertEqual(counts["cycles"], 42)

    def test_blank_lines_skipped(self):
        counts = self._parse([
            "",
            "   ",
            json.dumps({"event": "cycles", "counter-value": "7"}),
        ])
        self.assertEqual(counts["cycles"], 7)

    def test_malformed_json_skipped(self):
        counts = self._parse([
            "not json at all",
            json.dumps({"event": "cycles", "counter-value": "5"}),
        ])
        self.assertEqual(counts["cycles"], 5)

    def test_missing_counter_value_skipped(self):
        counts = self._parse([
            json.dumps({"event": "cycles"}),  # no counter-value key
        ])
        self.assertNotIn("cycles", counts)

    def test_non_numeric_counter_value_skipped(self):
        # e.g. perf outputs "<not counted>" when a counter is unavailable
        counts = self._parse([
            json.dumps({"event": "cycles", "counter-value": "<not counted>"}),
        ])
        self.assertNotIn("cycles", counts)

    def test_event_name_stripped(self):
        # perf sometimes pads event names with whitespace
        counts = self._parse([
            json.dumps({"event": "  cycles  ", "counter-value": "100"}),
        ])
        self.assertIn("cycles", counts)


class TestDeriveCounters(unittest.TestCase):
    def test_basic_ratios(self):
        perf = {
            "cache-misses":     100,
            "cache-references": 1000,
            "instructions":     5000,
            "cycles":           2000,
        }
        result = derive_counters(perf, ops=50)
        self.assertAlmostEqual(result["cache_misses_per_op"],    2.0,   places=4)
        self.assertAlmostEqual(result["cache_miss_ratio"],       0.1,   places=4)
        self.assertAlmostEqual(result["instructions_per_cycle"], 2.5,   places=4)

    def test_ops_zero_returns_zero_miss_per_op(self):
        perf = {"cache-misses": 100, "cache-references": 1000,
                "instructions": 0, "cycles": 1}
        result = derive_counters(perf, ops=0)
        self.assertEqual(result["cache_misses_per_op"], 0)

    def test_missing_keys_default_to_zero_or_one(self):
        # cache-references defaults to 1 (avoids /0), others to 0
        result = derive_counters({}, ops=10)
        self.assertEqual(result["cache_misses_per_op"],    0.0)
        self.assertEqual(result["cache_miss_ratio"],       0.0)
        self.assertEqual(result["instructions_per_cycle"], 0.0)

    def test_perfect_ipc(self):
        perf = {"instructions": 1000, "cycles": 1000,
                "cache-misses": 0, "cache-references": 1}
        result = derive_counters(perf, ops=10)
        self.assertAlmostEqual(result["instructions_per_cycle"], 1.0, places=4)

    def test_output_keys_present(self):
        result = derive_counters({}, ops=1)
        for key in ("cache_misses_per_op", "cache_miss_ratio", "instructions_per_cycle"):
            self.assertIn(key, result)


class TestParseBenchJson(unittest.TestCase):
    def setUp(self):
        self._tmp = None

    def tearDown(self):
        if self._tmp and self._tmp.exists():
            self._tmp.unlink()

    def _make_rep(self, name: str, real_time_ns: float) -> dict:
        return {"name": name, "real_time": real_time_ns, "run_type": "iteration"}

    def _parse(self, benchmarks: list, filter_name: str, nthreads: int):
        self._tmp = _write_bench_json(benchmarks)
        return parse_bench_json(self._tmp, filter_name, nthreads)

    # ── round-trip invariant ─────────────────────────────────────────────────
    # For every row: abs(ns_per_op * nthreads * N_ITERS * N_FILLS - real_time_ns)
    #               / real_time_ns < 0.001
    # This is the canonical guard against the "divide by iterations twice" bug.

    def test_roundtrip_1t(self):
        real_time_ns = 2_919_677.7
        nthreads = 1
        reps = [self._make_rep("IntraCCX/1t/unpadded", real_time_ns)] * 11
        result = self._parse(reps, "IntraCCX/1t/unpadded", nthreads)
        ns_op = result["ns_per_op"]["median"]
        self.assertLess(
            abs(ns_op * nthreads * N_ITERS * N_FILLS - real_time_ns) / real_time_ns,
            0.001,
        )

    def test_roundtrip_4t(self):
        real_time_ns = 1_673_840.6
        nthreads = 4
        reps = [self._make_rep("IntraCCX/4t/padded", real_time_ns)] * 11
        result = self._parse(reps, "IntraCCX/4t/padded", nthreads)
        ns_op = result["ns_per_op"]["median"]
        self.assertLess(
            abs(ns_op * nthreads * N_ITERS * N_FILLS - real_time_ns) / real_time_ns,
            0.001,
        )

    def test_roundtrip_8t(self):
        real_time_ns = 1_561_635.0
        nthreads = 8
        reps = [self._make_rep("CrossCCX/8t/padded", real_time_ns)] * 11
        result = self._parse(reps, "CrossCCX/8t/padded", nthreads)
        ns_op = result["ns_per_op"]["median"]
        self.assertLess(
            abs(ns_op * nthreads * N_ITERS * N_FILLS - real_time_ns) / real_time_ns,
            0.001,
        )

    # ── sanity: absolute value in expected range ─────────────────────────────

    def test_1t_ns_per_op_in_range(self):
        # 1t padded should be ~2.85 ns/op, not ~0.015 (the bugged value)
        real_time_ns = 2_919_677.7
        nthreads = 1
        reps = [self._make_rep("IntraCCX/1t/padded", real_time_ns)] * 11
        result = self._parse(reps, "IntraCCX/1t/padded", nthreads)
        ns_op = result["ns_per_op"]["median"]
        self.assertGreater(ns_op, 1.0,  "ns/op should be > 1 ns (physical floor ~1.3 ns)")
        self.assertLess(ns_op, 10.0, "ns/op should be < 10 ns for single-thread padded")

    def test_ops_per_sec_not_in_tens_of_billions(self):
        # Pre-fix the value was ~67 G ops/sec — physically impossible on a single thread
        real_time_ns = 2_919_677.7
        nthreads = 1
        reps = [self._make_rep("IntraCCX/1t/unpadded", real_time_ns)] * 11
        result = self._parse(reps, "IntraCCX/1t/unpadded", nthreads)
        self.assertLess(result["ops_per_sec"], 2_000_000_000,
                        "single-thread ops/sec must be < 2G (not tens of G)")

    # ── aggregate filtering ───────────────────────────────────────────────────

    def test_aggregate_rows_excluded(self):
        real_time_ns = 3_000_000.0
        nthreads = 1
        reps = [
            self._make_rep("IntraCCX/1t/unpadded",        real_time_ns),
            {"name": "IntraCCX/1t/unpadded_mean",    "real_time": 9_999_999.0},
            {"name": "IntraCCX/1t/unpadded_median",  "real_time": 9_999_999.0},
            {"name": "IntraCCX/1t/unpadded_stddev",  "real_time": 9_999_999.0},
        ]
        result = self._parse(reps, "IntraCCX/1t/unpadded", nthreads)
        self.assertAlmostEqual(result["real_time_ns"]["median"], real_time_ns, places=0)

    def test_no_matching_rows_raises(self):
        reps = [self._make_rep("IntraCCX/1t/unpadded", 1_000_000.0)]
        with self.assertRaises(ValueError):
            self._parse(reps, "CrossCCX/8t/padded", 8)

    # ── min / iqr fields populated ────────────────────────────────────────────

    def test_min_le_median(self):
        reps = [
            self._make_rep("IntraCCX/2t/padded", 3_000_000.0),
            self._make_rep("IntraCCX/2t/padded", 2_900_000.0),
            self._make_rep("IntraCCX/2t/padded", 3_100_000.0),
        ]
        result = self._parse(reps, "IntraCCX/2t/padded", 2)
        self.assertLessEqual(result["real_time_ns"]["min"], result["real_time_ns"]["median"])
        self.assertLessEqual(result["ns_per_op"]["min"],    result["ns_per_op"]["median"])


if __name__ == "__main__":
    unittest.main()
