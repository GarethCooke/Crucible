"""Unit tests for parse_perf.py — parse_perf_json, parse_bench_json, derive_counters."""

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.dirname(__file__))
from parse_perf import N_FILLS, N_ITERS, derive_counters, parse_bench_json, parse_perf_json


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _write_bench_json(benchmarks: list) -> Path:
    data = {"context": {}, "benchmarks": benchmarks}
    f = tempfile.NamedTemporaryFile(mode="w", suffix=".bench.json", delete=False)
    json.dump(data, f)
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
    """Verify parse_bench_json produces correct ns_per_op values.

    Key invariant: ns_per_op * nthreads * N_ITERS * N_FILLS == real_time_ns
    (within floating-point rounding). This identity would fail with the previous
    implementation that derived ns_per_op via items_per_second.
    """

    def tearDown(self):
        if hasattr(self, "_tmp") and self._tmp.exists():
            self._tmp.unlink()

    def _parse(self, benchmarks, filter_name, nthreads):
        self._tmp = _write_bench_json(benchmarks)
        return parse_bench_json(self._tmp, filter_name, nthreads)

    # ── roundtrip identity ────────────────────────────────────────────────────

    def test_roundtrip_identity_1t(self):
        """Single thread: ns_per_op * N_ITERS * N_FILLS must recover real_time_ns."""
        real_time_ns = 2920469.8
        nthreads = 1
        result = self._parse(
            [{"name": "IntraCCX/1t/unpadded/0", "real_time": real_time_ns}],
            "IntraCCX/1t/unpadded",
            nthreads,
        )
        recovered = result["ns_per_op"]["median"] * nthreads * N_ITERS * N_FILLS
        rel_err = abs(recovered - result["real_time_ns"]["median"]) / result["real_time_ns"]["median"]
        self.assertLess(rel_err, 0.001, f"roundtrip relative error {rel_err:.6f} >= 0.001")

    def test_roundtrip_identity_4t(self):
        """Four threads: same identity, with multiple reps for realistic median."""
        nthreads = 4
        reps = [1_650_000.0, 1_670_000.0, 1_645_000.0, 1_660_000.0, 1_655_000.0]
        bms = [{"name": f"IntraCCX/4t/padded/{i}", "real_time": r} for i, r in enumerate(reps)]
        result = self._parse(bms, "IntraCCX/4t/padded", nthreads)
        recovered = result["ns_per_op"]["median"] * nthreads * N_ITERS * N_FILLS
        rel_err = abs(recovered - result["real_time_ns"]["median"]) / result["real_time_ns"]["median"]
        self.assertLess(rel_err, 0.001)

    def test_roundtrip_identity_8t_cross_ccx(self):
        """Eight threads cross-CCX."""
        nthreads = 8
        real_time_ns = 1_572_549.0
        result = self._parse(
            [{"name": "CrossCCX/8t/padded/0", "real_time": real_time_ns}],
            "CrossCCX/8t/padded",
            nthreads,
        )
        recovered = result["ns_per_op"]["median"] * nthreads * N_ITERS * N_FILLS
        rel_err = abs(recovered - result["real_time_ns"]["median"]) / result["real_time_ns"]["median"]
        self.assertLess(rel_err, 0.001)

    # ── ops_per_sec sanity bounds ─────────────────────────────────────────────

    def test_ops_per_sec_1t_in_hundreds_of_millions(self):
        """After fix, 1t unpadded should be ~350 M/s, not ~68 G/s."""
        real_time_ns = 2920469.8   # ~2.9 ms for 1t intra-CCX unpadded
        result = self._parse(
            [{"name": "IntraCCX/1t/unpadded/0", "real_time": real_time_ns}],
            "IntraCCX/1t/unpadded",
            nthreads=1,
        )
        ops = result["ops_per_sec"]
        self.assertGreater(ops, 100_000_000,    "ops_per_sec < 100 M/s — too low")
        self.assertLess(ops,   2_000_000_000,   "ops_per_sec > 2 G/s — likely still using items_per_second")

    def test_ops_per_sec_8t_padded_a_few_gops(self):
        """8t padded cross-CCX should land at a few G ops/sec total."""
        real_time_ns = 1_572_549.0   # ~1.6 ms for 8t cross-CCX padded
        result = self._parse(
            [{"name": "CrossCCX/8t/padded/0", "real_time": real_time_ns}],
            "CrossCCX/8t/padded",
            nthreads=8,
        )
        ops = result["ops_per_sec"]
        self.assertGreater(ops, 1_000_000_000,  "ops_per_sec < 1 G/s — too low for 8t padded")
        self.assertLess(ops,   20_000_000_000,  "ops_per_sec > 20 G/s — still wrong")

    # ── aggregate rows and filtering ──────────────────────────────────────────

    def test_aggregate_rows_excluded(self):
        """_mean/_median/_stddev/_cv rows must not affect real_time_ns."""
        bms = [
            {"name": "IntraCCX/1t/unpadded/0",     "real_time": 2_920_469.8},
            {"name": "IntraCCX/1t/unpadded_mean",   "real_time": 0.0},
            {"name": "IntraCCX/1t/unpadded_median", "real_time": 0.0},
            {"name": "IntraCCX/1t/unpadded_stddev", "real_time": 0.0},
            {"name": "IntraCCX/1t/unpadded_cv",     "real_time": 0.0},
        ]
        result = self._parse(bms, "IntraCCX/1t/unpadded", nthreads=1)
        self.assertAlmostEqual(result["real_time_ns"]["median"], 2_920_469.8, places=0)

    def test_unrelated_benchmarks_excluded(self):
        """Rows for a different benchmark must not pollute the result."""
        bms = [
            {"name": "CrossCCX/8t/unpadded/0",  "real_time": 99_000_000.0},
            {"name": "IntraCCX/1t/unpadded/0",  "real_time": 2_920_469.8},
        ]
        result = self._parse(bms, "IntraCCX/1t/unpadded", nthreads=1)
        self.assertAlmostEqual(result["real_time_ns"]["median"], 2_920_469.8, places=0)

    def test_no_matching_rows_raises(self):
        bms = [{"name": "CrossCCX/8t/unpadded/0", "real_time": 1_000.0}]
        with self.assertRaises(ValueError):
            self._parse(bms, "IntraCCX/1t/unpadded", nthreads=1)

    # ── output structure ──────────────────────────────────────────────────────

    def test_output_keys_present(self):
        result = self._parse(
            [{"name": "IntraCCX/1t/unpadded/0", "real_time": 2_920_469.8}],
            "IntraCCX/1t/unpadded", nthreads=1,
        )
        for key in ("real_time_ns", "ns_per_op", "ops_per_sec"):
            self.assertIn(key, result)
        for sub in ("median", "min", "iqr"):
            self.assertIn(sub, result["real_time_ns"])
            self.assertIn(sub, result["ns_per_op"])


if __name__ == "__main__":
    unittest.main()
