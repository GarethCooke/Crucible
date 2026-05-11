#!/usr/bin/env python3
"""Post-run sanity checks for the false-sharing benchmark data.

Usage:
    python3 tools/sanity_check.py site/src/data/perf/false-sharing-pnl.json

Exit 0 if all assertions pass; exit 1 on any failure.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def find_run(runs: list[dict], placement: str, threads: int, variant: str) -> dict | None:
    for r in runs:
        if (
            r.get("placement") == placement
            and r.get("threads") == threads
            and r.get("variant") == variant
        ):
            return r
    return None


def median_ns(run: dict) -> float:
    return run["ns_per_op"]["median"]


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <false-sharing-pnl.json>", file=sys.stderr)
        sys.exit(1)

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    with open(path) as f:
        data = json.load(f)
    runs = data.get("runs", [])

    failures: list[str] = []

    # ── Assertion 1 ──────────────────────────────────────────────────────────
    # At intra-CCX 4t, unpadded must be at least 5× slower than padded.
    # (Expected ~10–20×; 5× is the floor for "the demo is working".)
    intra4u = find_run(runs, "intra-ccx", 4, "unpadded")
    intra4p = find_run(runs, "intra-ccx", 4, "padded")
    if intra4u is None or intra4p is None:
        failures.append("MISSING intra-ccx/4t/unpadded or intra-ccx/4t/padded run")
    else:
        ratio = median_ns(intra4u) / median_ns(intra4p)
        label = f"intra-ccx/4t unpadded/padded ratio = {ratio:.1f}×"
        if ratio >= 5.0:
            print(f"  PASS  {label} (≥5× required)")
        else:
            msg = f"FAIL  {label} — expected ≥5×; demo may not be working"
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    # ── Assertion 2 ──────────────────────────────────────────────────────────
    # At intra-CCX 1t, unpadded ≈ padded within 20%.
    # With one thread there is no contention, so padding should not matter.
    intra1u = find_run(runs, "intra-ccx", 1, "unpadded")
    intra1p = find_run(runs, "intra-ccx", 1, "padded")
    if intra1u is None or intra1p is None:
        failures.append("MISSING intra-ccx/1t/unpadded or intra-ccx/1t/padded run")
    else:
        u_ns = median_ns(intra1u)
        p_ns = median_ns(intra1p)
        diff_pct = abs(u_ns - p_ns) / max(u_ns, p_ns) * 100
        label = f"intra-ccx/1t unpadded={u_ns:.3f} padded={p_ns:.3f} ns/op ({diff_pct:.1f}% diff)"
        if diff_pct <= 20.0:
            print(f"  PASS  {label} (≤20% required)")
        else:
            msg = f"FAIL  {label} — expected ≤20% at 1 thread (no false sharing expected)"
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    # ── Assertion 3 ──────────────────────────────────────────────────────────
    # Cross-CCX 4t unpadded must be slower than intra-CCX 4t unpadded.
    # The Infinity Fabric coherency penalty is the driver.
    cross4u = find_run(runs, "cross-ccx", 4, "unpadded")
    if cross4u is None or intra4u is None:
        failures.append("MISSING cross-ccx/4t/unpadded or intra-ccx/4t/unpadded run")
    else:
        cross_ns = median_ns(cross4u)
        intra_ns = median_ns(intra4u)
        label = (
            f"cross-ccx/4t/unpadded={cross_ns:.2f} ns/op  "
            f"intra-ccx/4t/unpadded={intra_ns:.2f} ns/op"
        )
        if cross_ns > intra_ns:
            print(f"  PASS  {label} (cross > intra required)")
        else:
            msg = f"FAIL  {label} — expected cross-CCX to be slower (Infinity Fabric penalty)"
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    if failures:
        print(f"\nSanity check FAILED ({len(failures)} assertion(s)).", file=sys.stderr)
        sys.exit(1)
    else:
        print("\nSanity check PASSED — all assertions satisfied.")


if __name__ == "__main__":
    main()
