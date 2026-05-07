import json, sys, os

bench_file, slug, captured_at, machine_json, out_path = sys.argv[1:]

with open(bench_file) as f:
    raw = json.load(f)

machine = json.loads(machine_json)

def stats(values):
    s = sorted(values)
    n = len(s)
    if n == 0:
        return {"median": 0, "min": 0, "p99": 0, "iqr": 0}
    def pct(p):
        idx = p / 100 * (n - 1)
        lo  = int(idx)
        frac = idx - lo
        if lo + 1 >= n: return s[-1]
        return s[lo] * (1 - frac) + s[lo + 1] * frac
    return {
        "median": round(pct(50), 4),
        "min":    round(s[0],    4),
        "p99":    round(pct(99), 4),
        "iqr":    round(pct(75) - pct(25), 4),
    }

groups = {}
for b in raw.get("benchmarks", []):
    if b.get("run_type") != "iteration":
        continue
    name = b["name"]
    parts = name.split("/")
    variant_raw = parts[0].removeprefix("BM_").lower()
    n = int(parts[1]) if len(parts) > 1 else 0
    key = (variant_raw, n)
    groups.setdefault(key, []).append(b)

runs = []
for (variant, n), reps in sorted(groups.items(), key=lambda x: (x[0][0], x[0][1])):
    times = [r["real_time"] for r in reps]
    ops_s = [r.get("items_per_second", 0) for r in reps]
    bm    = [r.get("branch_misses_per_op", 0) for r in reps]
    ipc   = [r.get("ipc", 0) for r in reps]

    runs.append({
        "variant":                variant,
        "n":                      n,
        "iterations":             reps[0].get("iterations", 0),
        "ns_per_op":              stats(times),
        "ops_per_sec":            round(sorted(ops_s)[len(ops_s) // 2]),
        "branch_misses_per_op":   round(sorted(bm)[len(bm) // 2], 4),
        "instructions_per_cycle": round(sorted(ipc)[len(ipc) // 2], 3),
    })

output = {
    "demo":        slug,
    "title":       "Sorted vs unsorted branch prediction",
    "machine":     machine,
    "captured_at": captured_at,
    "runs":        runs,
    "notes":       "Branch predictor learns sorted patterns; unsorted forces ~50% mispredicts.",
}

os.makedirs(os.path.dirname(out_path), exist_ok=True)
with open(out_path, "w") as f:
    json.dump(output, f, indent=2)

print(f"Written: {out_path}")
