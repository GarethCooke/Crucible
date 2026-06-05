"""Assemble the bimodality diagnostic log into per-cell overload-mode stats.

Usage:
    python3 bench/scripts/assemble_overload_modes.py <log_path> <out_path>

Reads the raw ITER lines from the bimodality diagnostic run, classifies each
per-run observation as deep (depth_mean > 100), shallow (depth_mean < 10), or
indet, and emits per-(variant, point) statistics including per-mode median
p50/p99.9/achieved and per-process uniformity fractions.
"""

import json
import re
import statistics
import sys
from collections import defaultdict
from pathlib import Path


ITER_PAT = re.compile(
    r'\[.*?inv=(\d+).*?\] ITER (\S+) mode=\S+ offered=(\d+)Hz k=(\d+)/(\d+):'
    r'\s+p50=(\d+) ns\s+p99\.9=(\d+) ns\s+mean=[\d.]+ ns'
    r'\s+achieved=([\d.]+) M/s\s+depth_mean=([\d.]+)'
)

META_GOVERNOR_PAT = re.compile(r'governor:\s*(\S+)')
META_KERNEL_PAT   = re.compile(r'kernel:\s*(\S+)')
META_SHIELD_PAT   = re.compile(r'shield:\s*active')
META_INVS_PAT     = re.compile(r'invocations/cell:\s*(\d+)')
META_ITERS_PAT    = re.compile(r'iters/invocation:\s*(\d+)')

OFFERED_LABELS = {
    0:        'saturated',
    16152813: '@16MHz',
    28419019: '@28MHz',
    50000000: '@50MHz',
}


def classify(depth_mean: float) -> str:
    if depth_mean > 100:
        return 'deep'
    if depth_mean < 10:
        return 'shallow'
    return 'indet'


def mode_stats(obs: list[dict]) -> dict:
    """Compute median stats for a list of run observations."""
    n = len(obs)
    if n == 0:
        return {'n': 0}
    p50s  = sorted(r['p50']  for r in obs)
    p999s = sorted(r['p999'] for r in obs)
    achs  = sorted(r['ach']  for r in obs)
    result = {
        'n':                  n,
        'p50_median_ns':      round(statistics.median(p50s)),
        'p99_9_median_ns':    round(statistics.median(p999s)),
        'achieved_median_mhz': round(statistics.median(achs), 1),
    }
    return result


def parse_meta(text: str) -> dict:
    meta = {
        'governor':              'unknown',
        'kernel':                'unknown',
        'shielded':              False,
        'invocations_per_cell':  10,
        'runs_per_invocation':   5,
    }
    m = META_GOVERNOR_PAT.search(text)
    if m:
        meta['governor'] = m.group(1)
    m = META_KERNEL_PAT.search(text)
    if m:
        meta['kernel'] = m.group(1)
    if META_SHIELD_PAT.search(text):
        meta['shielded'] = True
    m = META_INVS_PAT.search(text)
    if m:
        meta['invocations_per_cell'] = int(m.group(1))
    m = META_ITERS_PAT.search(text)
    if m:
        meta['runs_per_invocation'] = int(m.group(1))
    return meta


def main() -> None:
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    log_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])

    text = log_path.read_text()

    meta = parse_meta(text)
    meta['source_log'] = log_path.name

    # Collect all ITER observations
    # keyed by (variant, offered_hz) → list of obs dicts
    cells: dict[tuple, list] = defaultdict(list)
    for m in ITER_PAT.finditer(text):
        inv, variant, offered, k, runs, p50, p999, ach, depth = m.groups()
        obs = {
            'inv':     int(inv),
            'variant': variant,
            'offered': int(offered),
            'k':       int(k),
            'p50':     int(p50),
            'p999':    int(p999),
            'ach':     float(ach),
            'depth':   float(depth),
            'mode':    classify(float(depth)),
        }
        cells[(variant, int(offered))].append(obs)

    # Build output cells
    output_cells = []
    for (variant, offered_hz) in sorted(cells.keys()):
        obs_list = cells[(variant, offered_hz)]
        point    = OFFERED_LABELS.get(offered_hz, f'@{offered_hz}Hz')

        # Per-mode observations
        by_mode: dict[str, list] = defaultdict(list)
        for obs in obs_list:
            by_mode[obs['mode']].append(obs)

        # Per-process uniformity: fraction of invocations whose runs are all same mode
        by_inv: dict[int, list[str]] = defaultdict(list)
        for obs in obs_list:
            by_inv[obs['inv']].append(obs['mode'])
        n_invs = len(by_inv)
        n_uniform = sum(1 for modes in by_inv.values() if len(set(modes)) == 1)
        uniformity = round(n_uniform / n_invs, 2) if n_invs > 0 else 0.0

        # Build modes dict (only include modes that appear)
        modes = {}
        for mode_name in ('shallow', 'deep', 'indet'):
            if mode_name in by_mode:
                modes[mode_name] = mode_stats(by_mode[mode_name])

        cell = {
            'variant':                    variant,
            'point':                      point,
            'offered_hz':                 offered_hz,
            'total_runs':                 len(obs_list),
            'process_uniformity_of_10':   n_uniform,
            'process_uniformity_fraction': uniformity,
            'modes':                      modes,
        }
        output_cells.append(cell)

    output = {
        'meta':  meta,
        'cells': output_cells,
    }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"Written: {out_path} ({len(output_cells)} cells)")

    # Print verification table matching the brief
    print("\n=== verification ===")
    print(f"{'variant':25} {'point':12}  {'modes'}")
    for cell in output_cells:
        parts = []
        for mode_name, ms in cell['modes'].items():
            ach_str = f" ach={ms['achieved_median_mhz']}M" if ms['n'] > 0 else ''
            parts.append(f"{mode_name} n={ms['n']} p50={ms['p50_median_ns']}ns{ach_str}")
        print(f"{cell['variant']:25} {cell['point']:12}: {' ; '.join(parts)}")


if __name__ == '__main__':
    main()
