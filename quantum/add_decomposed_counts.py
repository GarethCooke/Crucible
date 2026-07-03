"""
add_decomposed_counts.py — additive decomposed two-qubit gate counts (finding M-4).

Loads the committed measuring-the-gap.json, rebuilds each circuit_depth circuit
with capture.py's own builders (build_grover / build_bv, states from
marked_states — identical to collect_depth_metrics), and pre-flight verifies the
reconstruction against the committed data before touching anything.

Pre-flight gate (user-confirmed 2026-07-03): the committed depth /
two_qubit_gates values were produced by capture.py's circuit_metrics() (Aer
transpile, seed_transpiler=42), NOT by abstract QuantumCircuit.depth() — so the
reconstruction check reruns circuit_metrics() and requires an exact match on
every row. The abstract two-qubit op count is additionally asserted equal to
the committed two_qubit_gates (0). Any mismatch → abort, no write.

Then, per row: transpile to basis ['cx','rz','sx','x'] at optimization_level=1
with seed_transpiler=42 and count cx ops → two_qubit_gates_decomposed.
One sibling key circuit_depth.decomposition records basis / level / seed /
qiskit version.

The write-back is asserted additive-only: a deep diff against the original
must show zero modified or removed keys — only the new fields.

Usage:
    quantum/.venv/Scripts/python.exe quantum/add_decomposed_counts.py
"""

import copy
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import qiskit
from qiskit import transpile

from capture import build_bv, build_grover, circuit_metrics, marked_states

JSON_PATH = os.path.normpath(
    os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "..", "site", "src", "data", "quantum", "measuring-the-gap.json",
    )
)

DECOMP_BASIS = ["cx", "rz", "sx", "x"]
DECOMP_OPT_LEVEL = 1
DECOMP_SEED = 42


def abstract_two_qubit_ops(qc):
    """Count 2-qubit operations in the un-transpiled circuit."""
    return sum(1 for inst in qc.data if inst.operation.num_qubits == 2)


def build_row_circuit(algo, n):
    """Rebuild the circuit exactly as collect_depth_metrics does."""
    state = marked_states(n, 1)[0]
    if algo == "grover":
        qc, iters = build_grover(n, state)
        return qc, iters
    qc = build_bv(n, state)
    return qc, None


def preflight(committed):
    """Verify reconstruction reproduces the committed circuit_depth rows."""
    failures = []
    circuits = {}
    for algo in ("grover", "bv"):
        for row in committed["circuit_depth"][algo]:
            n = row["n"]
            qc, iters = build_row_circuit(algo, n)
            circuits[(algo, n)] = qc

            m = circuit_metrics(qc)  # the generator's own metric path (Aer, seed 42)
            if m["depth"] != row["depth"]:
                failures.append(
                    f"{algo} n={n}: circuit_metrics depth {m['depth']} != committed {row['depth']}"
                )
            if m["two_qubit_gates"] != row["two_qubit_gates"]:
                failures.append(
                    f"{algo} n={n}: circuit_metrics two_qubit_gates {m['two_qubit_gates']} "
                    f"!= committed {row['two_qubit_gates']}"
                )
            abs2q = abstract_two_qubit_ops(qc)
            if abs2q != row["two_qubit_gates"]:
                failures.append(
                    f"{algo} n={n}: abstract 2q op count {abs2q} != committed {row['two_qubit_gates']}"
                )
            if algo == "grover" and iters != row["optimal_iters"]:
                failures.append(
                    f"grover n={n}: rebuilt optimal_iters {iters} != committed {row['optimal_iters']}"
                )
            print(
                f"  preflight {algo} n={n}: metric depth={m['depth']} 2q={m['two_qubit_gates']} "
                f"abstract-2q={abs2q}  OK" if not failures else
                f"  preflight {algo} n={n}: MISMATCH"
            )
    return failures, circuits


def decomposed_cx_count(qc):
    tqc = transpile(
        qc,
        basis_gates=DECOMP_BASIS,
        optimization_level=DECOMP_OPT_LEVEL,
        seed_transpiler=DECOMP_SEED,
    )
    return int(tqc.count_ops().get("cx", 0))


def deep_diff(old, new, path="$"):
    """Return (modified_or_removed, added) key paths between old and new."""
    bad, added = [], []
    if isinstance(old, dict) and isinstance(new, dict):
        for k in old:
            if k not in new:
                bad.append(f"{path}.{k} removed")
            else:
                b, a = deep_diff(old[k], new[k], f"{path}.{k}")
                bad += b
                added += a
        for k in new:
            if k not in old:
                added.append(f"{path}.{k}")
    elif isinstance(old, list) and isinstance(new, list):
        if len(old) != len(new):
            bad.append(f"{path} length {len(old)} -> {len(new)}")
        else:
            for i, (o, nw) in enumerate(zip(old, new)):
                b, a = deep_diff(o, nw, f"{path}[{i}]")
                bad += b
                added += a
    else:
        if old != new:
            bad.append(f"{path} modified: {old!r} -> {new!r}")
    return bad, added


def main():
    with open(JSON_PATH) as f:
        committed = json.load(f)
    original = copy.deepcopy(committed)

    print("Pre-flight: rebuilding circuits and verifying against committed data")
    failures, circuits = preflight(committed)
    if failures:
        print("\nABORT — reconstruction does not match what produced the committed data:")
        for msg in failures:
            print(f"  {msg}")
        sys.exit(1)
    print("Pre-flight passed on all six rows.\n")

    print(f"Decomposing to basis {DECOMP_BASIS} (opt level {DECOMP_OPT_LEVEL}, seed {DECOMP_SEED})")
    for algo in ("grover", "bv"):
        for row in committed["circuit_depth"][algo]:
            cx = decomposed_cx_count(circuits[(algo, row["n"])])
            row["two_qubit_gates_decomposed"] = cx
            print(f"  {algo} n={row['n']} (N={row['N']}): {cx} cx")

    committed["circuit_depth"]["decomposition"] = {
        "basis": DECOMP_BASIS,
        "optimization_level": DECOMP_OPT_LEVEL,
        "seed_transpiler": DECOMP_SEED,
        "qiskit_version": qiskit.__version__,
    }

    bad, added = deep_diff(original, committed)
    expected_added = {
        f"$.circuit_depth.{algo}[{i}].two_qubit_gates_decomposed"
        for algo in ("grover", "bv")
        for i in range(3)
    } | {"$.circuit_depth.decomposition"}
    assert not bad, f"non-additive change detected: {bad}"
    assert set(added) == expected_added, (
        f"unexpected additions: {set(added) ^ expected_added}"
    )
    print(f"\nAdditive-only diff verified: {len(added)} added keys, 0 modified, 0 removed.")

    with open(JSON_PATH, "w", newline="\n") as f:
        json.dump(committed, f, indent=2)
    print(f"Written: {JSON_PATH}")

    g5 = next(r for r in committed["circuit_depth"]["grover"] if r["n"] == 5)
    print(f"\ngrover n=5 two_qubit_gates_decomposed = {g5['two_qubit_gates_decomposed']}")


if __name__ == "__main__":
    main()
