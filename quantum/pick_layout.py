"""
pick_layout.py — choose a low-error connected qubit chain for the pinned capture.

Part of the capture protocol for the "Measuring the Gap" special edition: the
physical-qubit layout is selected from the backend's calibration data at capture
time, and the capture runs in the same session so the chain still reflects that
calibration. Record the printed calibration timestamp in the capture notes.

Greedy heuristic, not provably optimal: from each possible start qubit, repeatedly
step to the lowest-error unused neighbour; keep the cheapest full-width chain by
summed two-qubit gate error + readout error. Good enough for a one-post capture.

Costs no QPU time — this reads published device properties only.

Usage:
    python pick_layout.py                          # ibm_marrakesh, width 6
    python pick_layout.py --backend ibm_kingston --width 6
"""

import argparse


def main():
    ap = argparse.ArgumentParser(description="Pick a low-error connected qubit chain.")
    ap.add_argument("--backend", default="ibm_marrakesh")
    ap.add_argument("--width", type=int, default=6,
                    help="chain length; BV needs n+1 (6 at n=5)")
    args = ap.parse_args()

    from qiskit_ibm_runtime import QiskitRuntimeService

    service = QiskitRuntimeService()
    backend = service.backend(args.backend)
    target = backend.target

    # Calibration timestamp — pin the layout choice to the calibration it came
    # from. API surface varies; be defensive.
    try:
        ts = backend.properties().last_update_date
        print(f"backend: {backend.name}   calibration last updated: {ts}")
    except Exception:
        print(f"backend: {backend.name}   (calibration timestamp unavailable via "
              f"properties(); note wall-clock time of this run instead)")

    # 2-qubit gate error per directed edge, from whichever entangling gate the
    # device exposes (Heron: cz).
    edge_err = {}
    for gate in ("ecr", "cz", "cx"):
        if gate in target.operation_names:
            for qubits, props in target[gate].items():
                if props is not None and props.error is not None:
                    edge_err[tuple(qubits)] = props.error
            print(f"entangling gate: {gate}   edges with error data: {len(edge_err)}")
            break
    if not edge_err:
        raise SystemExit(f"no entangling-gate error data found; "
                         f"operation_names = {target.operation_names}")

    # Readout error per qubit.
    ro_err = {}
    if "measure" in target.operation_names:
        for (q,), props in target["measure"].items():
            if props is not None and props.error is not None:
                ro_err[q] = props.error

    # Undirected adjacency with a symmetric edge cost.
    adj = {}
    for (a, b), e in edge_err.items():
        cost = e + edge_err.get((b, a), e)
        adj.setdefault(a, {})[b] = min(adj.get(a, {}).get(b, 9), cost)
        adj.setdefault(b, {})[a] = min(adj.get(b, {}).get(a, 9), cost)

    def grow_chain(start):
        chain, used = [start], {start}
        while len(chain) < args.width:
            options = [(adj[chain[-1]][q], q)
                       for q in adj.get(chain[-1], {}) if q not in used]
            if not options:
                return None  # dead end (heavy-hex corner) — try another start
            _, nxt = min(options)
            chain.append(nxt)
            used.add(nxt)
        return chain

    def chain_cost(ch):
        twoq = sum(adj[ch[i]][ch[i + 1]] for i in range(len(ch) - 1))
        ro = sum(ro_err.get(q, 0) for q in ch)
        return twoq + ro

    best = None
    for start in adj:
        ch = grow_chain(start)
        if ch is not None and (best is None or chain_cost(ch) < chain_cost(best)):
            best = ch
    if best is None:
        raise SystemExit("no full-width chain found; try a smaller --width "
                         "or inspect the coupling map")

    print(f"\npinned layout: {best}")
    print(f"total 2q+readout error cost: {chain_cost(best):.4f}")
    print("per-edge 2q error along the chain:")
    for i in range(len(best) - 1):
        print(f"  {best[i]:>3} -- {best[i+1]:<3}  {adj[best[i]][best[i+1]]:.4f}")
    print("per-qubit readout error:")
    for q in best:
        print(f"  {q:>3}  {ro_err.get(q, float('nan')):.4f}")

    print(f"\n--qubits {','.join(map(str, best))}")


if __name__ == "__main__":
    main()
