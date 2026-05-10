"""Unit tests for stats_utils.py."""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from stats_utils import bench_stats, percentile


class TestPercentile(unittest.TestCase):
    # ── boundary conditions ──────────────────────────────────────────────────

    def test_empty_returns_zero(self):
        self.assertEqual(percentile([], 50), 0.0)

    def test_singleton_any_p(self):
        for p in (0, 25, 50, 75, 100):
            with self.subTest(p=p):
                self.assertEqual(percentile([7.0], p), 7.0)

    # ── 0th and 100th percentile equal min and max ───────────────────────────

    def test_p0_equals_min(self):
        s = [1.0, 2.0, 3.0, 4.0, 5.0]
        self.assertEqual(percentile(s, 0), 1.0)

    def test_p100_equals_max(self):
        s = [1.0, 2.0, 3.0, 4.0, 5.0]
        self.assertEqual(percentile(s, 100), 5.0)

    # ── median (50th percentile) ─────────────────────────────────────────────

    def test_median_odd_length(self):
        # middle element of sorted odd-length list
        s = [1.0, 2.0, 3.0, 4.0, 5.0]
        self.assertAlmostEqual(percentile(s, 50), 3.0)

    def test_median_even_length_interpolates(self):
        # midpoint between the two central elements
        s = [1.0, 2.0, 3.0, 4.0]
        self.assertAlmostEqual(percentile(s, 50), 2.5)

    # ── linear interpolation ─────────────────────────────────────────────────

    def test_interpolation_two_elements(self):
        s = [0.0, 10.0]
        self.assertAlmostEqual(percentile(s, 25), 2.5)
        self.assertAlmostEqual(percentile(s, 75), 7.5)

    def test_interpolation_uniform_spacing(self):
        s = [0.0, 1.0, 2.0, 3.0, 4.0]  # idx = p/100 * 4
        self.assertAlmostEqual(percentile(s, 25), 1.0)
        self.assertAlmostEqual(percentile(s, 75), 3.0)

    # ── monotonicity ─────────────────────────────────────────────────────────

    def test_monotone_in_p(self):
        s = [1.0, 3.0, 5.0, 7.0, 9.0]
        prev = percentile(s, 0)
        for p in (10, 25, 50, 75, 90, 100):
            val = percentile(s, p)
            self.assertGreaterEqual(val, prev)
            prev = val

    # ── IQR sign ─────────────────────────────────────────────────────────────

    def test_iqr_non_negative(self):
        for s in [[1.0], [1.0, 2.0], [1.0, 2.0, 3.0, 4.0, 5.0]]:
            with self.subTest(s=s):
                iqr = percentile(s, 75) - percentile(s, 25)
                self.assertGreaterEqual(iqr, 0.0)


class TestBenchStats(unittest.TestCase):
    def test_empty_returns_zeros(self):
        self.assertEqual(bench_stats([]), {"median": 0, "min": 0, "p99": 0, "iqr": 0})

    def test_keys_present(self):
        result = bench_stats([1.0, 2.0, 3.0])
        for key in ("median", "min", "p99", "iqr"):
            self.assertIn(key, result)

    def test_min_le_median(self):
        result = bench_stats([3.0, 1.0, 4.0, 1.0, 5.0])
        self.assertLessEqual(result["min"], result["median"])

    def test_median_in_range(self):
        values = [1.0, 2.0, 3.0, 4.0, 5.0]
        result = bench_stats(values)
        self.assertGreaterEqual(result["median"], result["min"])
        self.assertLessEqual(result["median"], max(values))

    def test_p99_ge_median(self):
        result = bench_stats(list(range(1, 101)))
        self.assertGreaterEqual(result["p99"], result["median"])

    def test_singleton(self):
        result = bench_stats([42.0])
        self.assertEqual(result["median"], 42.0)
        self.assertEqual(result["min"],    42.0)
        self.assertEqual(result["iqr"],    0.0)

    def test_identical_values_iqr_zero(self):
        result = bench_stats([5.0] * 10)
        self.assertEqual(result["iqr"], 0.0)

    def test_rounded_to_4dp(self):
        result = bench_stats([1.0 / 3.0])
        for key in ("median", "min", "p99", "iqr"):
            s = str(result[key])
            decimal_places = len(s.split(".")[-1]) if "." in s else 0
            self.assertLessEqual(decimal_places, 4, f"{key} has >4 decimal places")


if __name__ == "__main__":
    unittest.main()
