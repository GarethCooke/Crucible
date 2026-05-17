"""One-shot recovery tool: rewrite concatenated-object sweep JSON files as proper arrays.

Usage:
    python3 bench/scripts/repair_sweep_json.py <file> [<file> ...]

Each file is rewritten in-place from a sequence of top-level JSON objects
(the broken format emitted before the array-wrapping fix) to a single JSON
array containing those objects.  Files already in array format are left
unchanged.

After repair, re-run:
    python3 bench/scripts/assemble_results_04.py <variant_dir> <captured_at> "$machine_json" <out_path>
"""

import json
import sys
from pathlib import Path


def repair(path: Path) -> None:
    text = path.read_text()
    decoder = json.JSONDecoder()
    objs = []
    idx = 0
    while idx < len(text):
        while idx < len(text) and text[idx].isspace():
            idx += 1
        if idx >= len(text):
            break
        obj, end = decoder.raw_decode(text, idx)
        objs.append(obj)
        idx = end

    if len(objs) == 1 and isinstance(objs[0], list):
        print(f"Skipped {path}: already a JSON array")
        return

    path.write_text(json.dumps(objs, indent=2))
    print(f"Repaired {path}: {len(objs)} objects")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(1)
    for p in sys.argv[1:]:
        repair(Path(p))
