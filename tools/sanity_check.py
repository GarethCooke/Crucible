#!/usr/bin/env python3
"""Post-run sanity checks for the false-sharing benchmark data.

Usage:
    python3 tools/sanity_check.py site/src/data/perf/02-false-sharing-pnl.json

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
    return run["real_time_ns"]["median"]


def ipc(run: dict) -> float:
    return run["counters"]["instructions_per_cycle"]


def miss_ratio(run: dict) -> float:
    """Generic cache miss ratio (proxy for L1D miss ratio until l1d.replacement captured)."""
    return run["counters"]["cache_miss_ratio"]


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <02-false-sharing-pnl.json>", file=sys.stderr)
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
    # 4t intra-CCX unpadded: cache miss ratio ≥ 0.3.
    # False sharing's direct counter signature — universal across topologies.
    # (l1d_miss_ratio preferred; using cache_miss_ratio until l1d.replacement captured.)
    intra4u = find_run(runs, "intra-ccx", 4, "unpadded")
    if intra4u is None:
        failures.append("MISSING intra-ccx/4t/unpadded run")
    else:
        ratio = miss_ratio(intra4u)
        label = f"intra-ccx/4t/unpadded cache_miss_ratio = {ratio:.3f}"
        if ratio >= 0.3:
            print(f"  PASS  {label} (≥0.30 required)")
        else:
            msg = f"FAIL  {label} — expected ≥0.30; false-sharing counter signal not firing"
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    # ── Assertion 2 ──────────────────────────────────────────────────────────
    # 4t intra-CCX: IPC ratio (padded / unpadded) ≥ 3.0.
    # Padded threads execute independently; unpadded threads stall on coherency.
    intra4p = find_run(runs, "intra-ccx", 4, "padded")
    if intra4u is None or intra4p is None:
        failures.append("MISSING intra-ccx/4t/unpadded or intra-ccx/4t/padded run")
    else:
        padded_ipc   = ipc(intra4p)
        unpadded_ipc = ipc(intra4u)
        ratio = padded_ipc / unpadded_ipc if unpadded_ipc > 0 else 0
        label = (
            f"intra-ccx/4t IPC ratio (padded/unpadded) = "
            f"{padded_ipc:.3f} / {unpadded_ipc:.3f} = {ratio:.1f}×"
        )
        if ratio >= 3.0:
            print(f"  PASS  {label} (≥3.0× required)")
        else:
            msg = f"FAIL  {label} — expected ≥3.0×; IPC collapse not observed"
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    # ── Assertion 3 ──────────────────────────────────────────────────────────
    # 1t intra-CCX: unpadded ≈ padded within 20%.
    # With one thread there is no contention — padding should not matter.
    intra1u = find_run(runs, "intra-ccx", 1, "unpadded")
    intra1p = find_run(runs, "intra-ccx", 1, "padded")
    if intra1u is None or intra1p is None:
        failures.append("MISSING intra-ccx/1t/unpadded or intra-ccx/1t/padded run")
    else:
        u_ns = median_ns(intra1u)
        p_ns = median_ns(intra1p)
        diff_pct = abs(u_ns - p_ns) / max(u_ns, p_ns) * 100
        label = f"intra-ccx/1t unpadded={u_ns:.1f} padded={p_ns:.1f} ns wall-clock ({diff_pct:.1f}% diff)"
        if diff_pct <= 20.0:
            print(f"  PASS  {label} (≤20% required)")
        else:
            msg = f"FAIL  {label} — expected ≤20% at 1 thread (no false sharing expected)"
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    # ── Assertion 4 ──────────────────────────────────────────────────────────
    # NOTE: cross-ccx/2t/unpadded vs intra-ccx/2t/unpadded is intentionally
    # NOT asserted. cross-2t pins one thread to cpu 0, which still receives
    # the system timer interrupt even with isolcpus=0-7 boot params, and
    # therefore picks up cross-run variance from ambient kernel activity.
    # Within-run CV is <0.3% but the median drifts a few percent across
    # separate invocations. The 4t variant has enough contention that IF
    # latency dominates cpu 0 noise — assertion stays there. See /methodology.
    # ── Assertion 5 ──────────────────────────────────────────────────────────
    # 4t cross-CCX unpadded vs 4t intra-CCX unpadded: wall-clock ratio ≥ 1.15.
    # 3800X measured: ~1.28× (load-invariant; intra 2t→4t: ×1.91, cross: ×1.89).
    cross4u = find_run(runs, "cross-ccx", 4, "unpadded")
    if cross4u is None or intra4u is None:
        failures.append("MISSING cross-ccx/4t/unpadded or intra-ccx/4t/unpadded run")
    else:
        cross_ns = median_ns(cross4u)
        intra_ns = median_ns(intra4u)
        ratio = cross_ns / intra_ns if intra_ns > 0 else 0
        label = (
            f"cross-ccx/4t/unpadded={cross_ns:.1f} ns  "
            f"intra-ccx/4t/unpadded={intra_ns:.1f} ns  "
            f"ratio={ratio:.2f}×"
        )
        if ratio >= 1.15:
            print(f"  PASS  {label} (≥1.15× required)")
        else:
            msg = (
                f"FAIL  {label} — expected cross-CCX/intra-CCX wall-clock ratio ≥1.15×; "
                f"Infinity Fabric penalty not manifesting at 4t"
            )
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    # ── Assertion 6 ──────────────────────────────────────────────────────────
    # 2t cross-CCX padded vs 2t intra-CCX padded: wall-clock ratio in [0.40, 1.15].
    # 3800X measured: padded cross-CCX is ~0.58× of padded intra-CCX
    # (i.e. ~40% faster). Each CCX has its own L3 slice and coherence
    # controller, so cross-CCX threads avoid L3-controller contention
    # even when no false sharing exists. Floor at 0.40× leaves margin
    # for similar Zen 3+ CCX-equipped parts; ceiling at 1.15× still
    # catches a regression where cross-CCX is somehow penalised.
    cross2p = find_run(runs, "cross-ccx", 2, "padded")
    intra2p = find_run(runs, "intra-ccx", 2, "padded")
    if cross2p is None or intra2p is None:
        failures.append("MISSING cross-ccx/2t/padded or intra-ccx/2t/padded run")
    else:
        cross_ns = median_ns(cross2p)
        intra_ns = median_ns(intra2p)
        ratio = cross_ns / intra_ns if intra_ns > 0 else 0
        label = (
            f"cross-ccx/2t/padded={cross_ns:.1f} ns  "
            f"intra-ccx/2t/padded={intra_ns:.1f} ns  "
            f"ratio={ratio:.2f}×"
        )
        if 0.40 <= ratio <= 1.15:
            print(f"  PASS  {label} ([0.40, 1.15] required)")
        else:
            msg = (
                f"FAIL  {label} — expected padded cross/intra ratio in [0.40, 1.15]; "
                f"no false sharing -> no cross-CCX penalty expected"
            )
            print(f"  {msg}", file=sys.stderr)
            failures.append(msg)

    if failures:
        print(f"\nSanity check FAILED ({len(failures)} assertion(s)).", file=sys.stderr)
        sys.exit(1)
    else:
        print("\nSanity check PASSED — all assertions satisfied.")


if __name__ == "__main__":
    main()
