"""
grover_pilot.py — Crucible quantum special edition, throwaway pilot scaffold.

Purpose: build a small Grover search circuit, verify it on the local Aer
simulator (free), and — only on an explicit, separate call — submit ONE circuit
to real IBM hardware to meter QPU time (pilot Run 0 / Q2).

This is a STARTING SCAFFOLD, not guaranteed-current code. The Qiskit primitive
API (SamplerV2 PUB/result access) is the most version-sensitive part; if it
errors, fix against current docs and record the working pattern in the pilot
notes. The circuit construction below uses long-stable APIs.

Nothing here writes committed artifacts. Optional raw dumps go to
./pilot/scratch/ (gitignored). Aer is the default; hardware needs --hardware.

Usage:
    python grover_pilot.py                      # Aer verify, n=3, auto marked state
    python grover_pilot.py --n 4 --marked 1011  # Aer verify, n=4, marked |1011>
    python grover_pilot.py --hardware           # SUBMITS TO REAL QPU — spends budget
"""

import argparse
import math
import os

# --- Circuit construction (stable Qiskit APIs) --------------------------------


def _mcz(qc, qubits):
    """Multi-controlled Z: phase-flip the all-ones state of `qubits`."""
    *controls, target = list(qubits)
    qc.h(target)
    if controls:
        qc.mcx(controls, target)
    else:
        qc.z(target)
    qc.h(target)


def _oracle(qc, qubits, marked_bits):
    """Phase-flip the single marked basis state.

    marked_bits[i] is the intended value (0/1) of qubit i. We X-wrap the qubits
    that should be 0 so the all-ones MCZ lands on the marked state.
    NOTE: Qiskit measures qubit i -> clbit i, and counts strings are printed
    little-endian (clbit n-1 leftmost). Watch bit order when you compare the
    recovered mode to `marked` — this is the classic Qiskit footgun.
    """
    zeros = [q for q, b in zip(qubits, marked_bits) if b == 0]
    if zeros:
        qc.x(zeros)
    _mcz(qc, qubits)
    if zeros:
        qc.x(zeros)


def _diffuser(qc, qubits):
    qubits = list(qubits)
    qc.h(qubits)
    qc.x(qubits)
    _mcz(qc, qubits)
    qc.x(qubits)
    qc.h(qubits)


def optimal_iterations(n):
    """The iteration count that maximises P(marked) for one marked item in N=2^n."""
    return max(1, round((math.pi / 4) * math.sqrt(2**n)))


def build_grover(n, marked, iterations=None):
    """Return (circuit, iterations) for an n-qubit Grover search.

    `marked` is a bitstring of length n indexed by qubit (marked[i] -> qubit i).
    `iterations` overrides the optimal count — used by the teaching sweep to show
    over-rotation (probability climbs to a peak, then falls if you keep going).
    """
    from qiskit import QuantumCircuit

    assert len(marked) == n, "marked must have length n"
    marked_bits = [int(c) for c in marked]
    qubits = list(range(n))

    qc = QuantumCircuit(n, n)
    qc.h(qubits)  # uniform superposition

    iters = iterations if iterations is not None else optimal_iterations(n)
    for _ in range(iters):
        _oracle(qc, qubits, marked_bits)
        _diffuser(qc, qubits)

    qc.measure(qubits, qubits)
    return qc, iters


def build_bv(n, secret):
    """Bernstein-Vazirani: recover hidden n-bit `secret` in ONE oracle query.

    Shallow by construction (one layer of CX into a phase-kickback ancilla), so
    it should survive on hardware at N where deep Grover has drowned — that's the
    contrast: the failure is circuit DEPTH x error, not 'quantum'. Uses n input
    qubits + 1 ancilla; measures the n input qubits. secret[i] -> qubit i.
    """
    from qiskit import QuantumCircuit

    assert len(secret) == n, "secret must have length n"
    qc = QuantumCircuit(n + 1, n)
    qc.x(n)  # ancilla -> |1>
    qc.h(n)  # ancilla -> |->  (phase kickback target)
    qc.h(range(n))  # inputs -> superposition
    for i, b in enumerate(secret):
        if b == "1":
            qc.cx(i, n)  # oracle: f(x) = secret . x
    qc.h(range(n))
    qc.measure(range(n), range(n))
    return qc


def _build(algo, n, state, iterations=None):
    """Dispatch: build the circuit for `algo` ('grover' or 'bv').

    Both share the success convention: the expected measured string is
    state[::-1] (Qiskit's little-endian readout of state indexed by qubit).
    """
    if algo == "grover":
        qc, _ = build_grover(n, state, iterations=iterations)
        return qc
    if algo == "bv":
        return build_bv(n, state)
    raise ValueError(f"unknown algo: {algo}")


# --- Aer verification (free, local) -------------------------------------------


def verify_on_aer(qc, marked, shots=4096):
    from qiskit import transpile
    from qiskit_aer import AerSimulator

    sim = AerSimulator()
    tqc = transpile(qc, sim)
    counts = sim.run(tqc, shots=shots).result().get_counts()

    top = max(counts, key=counts.get)
    top_p = counts[top] / shots
    # Compare against marked with bit order accounted for (counts are reversed).
    marked_as_measured = marked[::-1]
    ok = top == marked_as_measured

    print(f"  iterations baked into circuit: {qc.count_ops()}")
    print(f"  shots={shots}  top outcome=|{top}>  P(top)={top_p:.3f}")
    print(f"  marked=|{marked}>  (as measured string: |{marked_as_measured}>)")
    print(
        f"  CORRECT: {ok}   {'<-- marked state dominates' if ok else '<-- MISMATCH, check bit order / oracle'}"
    )
    return ok, counts


def sweep_iterations_aer(n, marked, max_iters=None, shots=4096):
    """Aer-only: P(marked) as a function of Grover iteration count.

    This is the teaching-chart data (Q: how does Grover actually work?). It shows
    the amplitude-amplification oscillation — probability rises to a peak at the
    optimal count, then *falls* if you over-rotate. Costs zero QPU time; this is
    the ideal behaviour the noisy hardware will fail to reproduce.
    """
    from qiskit import transpile
    from qiskit_aer import AerSimulator

    sim = AerSimulator()
    opt = optimal_iterations(n)
    if max_iters is None:
        max_iters = 2 * opt + 1  # enough to show the peak and the fall past it
    marked_as_measured = marked[::-1]

    print(f"Iteration sweep, n={n} (N={2**n}), marked=|{marked}>, optimal={opt}")
    print(f"{'iters':>5}  {'P(marked)':>9}")
    curve = []
    for k in range(0, max_iters + 1):
        qc, _ = build_grover(n, marked, iterations=k)
        tqc = transpile(qc, sim)
        counts = sim.run(tqc, shots=shots).result().get_counts()
        p = counts.get(marked_as_measured, 0) / shots
        curve.append((k, p))
        marker = "  <-- optimal" if k == opt else ""
        print(f"{k:>5}  {p:>9.3f}{marker}")
    return curve


# --- Run 1: the success-probability sweep (resolves Q1) -----------------------


def marked_states(n, count):
    """A deterministic, reproducible spread of `count` distinct marked states.

    Evenly spaced across [0, 2^n) so the averaged P(marked) isn't biased by one
    'easy' state (e.g. all-ones). Reproducible: same set every run.
    """
    N = 2**n
    count = min(count, N)
    idxs = sorted({round(i * (N - 1) / max(1, count - 1)) for i in range(count)})
    return [format(idx, f"0{n}b") for idx in idxs]


def _pub_counts(pub_result):
    """Extract counts from a SamplerV2 PUB result (version-sensitive access)."""
    data = pub_result.data
    creg = next(iter(data.__dict__))  # default classical register name
    return getattr(data, creg).get_counts()


def _plan(ns, marked_count, reps):
    """Build the (n, marked, rep) circuit plan shared by Aer and hardware paths."""
    plan = []
    for n in ns:
        for marked in marked_states(n, marked_count):
            for rep in range(reps):
                plan.append((n, marked, rep))
    return plan


def _aggregate(records):
    """records: list of dicts with n, p_marked. Return per-N mean P(marked)."""
    by_n = {}
    for r in records:
        by_n.setdefault(r["n"], []).append(r["p_marked"])
    return {n: sum(ps) / len(ps) for n, ps in by_n.items()}


def run1_aer(ns, marked_count, reps, shots, algo="grover"):
    """Dry run: validate the whole plan on the noiseless simulator (free).

    This is the ideal reference curve AND the pre-submission correctness check —
    every circuit here must put P(success) near 1.0, or the hardware run is wasted.
    """
    from qiskit import transpile
    from qiskit_aer import AerSimulator

    sim = AerSimulator()
    plan = _plan(ns, marked_count, reps)
    print(
        f"Run 1 Aer dry-run [{algo}]: {len(plan)} circuits  (ns={ns}, "
        f"{marked_count} states/N, {reps} reps, {shots} shots)"
    )
    records = []
    for n, marked, rep in plan:
        qc = _build(algo, n, marked)
        counts = sim.run(transpile(qc, sim), shots=shots).result().get_counts()
        p = counts.get(marked[::-1], 0) / shots
        records.append({"n": n, "marked": marked, "rep": rep, "p_marked": p})
    means = _aggregate(records)
    rand = {n: 1 / (2**n) for n in ns}
    print(f"\n{'N':>4}  {'mean P(success)':>15}  {'random 1/N':>11}")
    for n in ns:
        print(f"{2**n:>4}  {means[n]:>15.3f}  {rand[n]:>11.3f}")
    print(
        "\n(Aer is noiseless — these should all sit near 1.0. If any N is low, "
        "the circuit at that N is wrong; fix before --hardware.)"
    )
    return records, means


def run1_hardware(
    ns,
    marked_count,
    reps,
    shots,
    backend_name=None,
    mitigation=False,
    dump=True,
    repeats=1,
    qubits=None,
    algo="grover",
):
    """The real sweep, optionally repeated to separate signal from drift.

    repeats K: submit the whole plan K times as K separate jobs (job-to-job
    variance IS the drift confound we're testing against). Reports per-N mean
    across all repeats plus the run-to-run spread.

    qubits: explicit physical-qubit list. Pinning makes the OFF/ON (or
    grover/bv) comparison clean — same qubits every time. Length must cover the
    widest circuit (BV uses n+1 qubits). If None, a fixed transpiler seed is used
    for determinism, but a recalibration between jobs can still shift the layout.
    """
    import json
    from datetime import datetime, timezone
    from qiskit import transpile
    from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2

    service = QiskitRuntimeService()
    backend = (
        service.backend(backend_name)
        if backend_name
        else service.least_busy(operational=True, simulator=False)
    )
    plan = _plan(ns, marked_count, reps)
    widest = max(ns) + (1 if algo == "bv" else 0)
    if qubits is not None and len(qubits) < widest:
        raise ValueError(f"--qubits needs >= {widest} entries for algo={algo}, ns={ns}")

    print(f"  backend: {backend.name}")
    print(
        f"  plan [{algo}]: {len(plan)} circuits x {repeats} repeat(s)  "
        f"(ns={ns}, {marked_count} states/N, {reps} reps, {shots} shots, "
        f"mitigation={'ON' if mitigation else 'OFF'}, "
        f"qubits={'pinned ' + str(qubits) if qubits else 'transpiler-chosen'})"
    )

    def _transpile(qc):
        w = qc.num_qubits
        layout = qubits[:w] if qubits is not None else None
        return transpile(qc, backend, initial_layout=layout, seed_transpiler=42)

    def _make_sampler():
        s = SamplerV2(mode=backend)
        applied = {}
        if mitigation:
            for path, value in [
                ("dynamical_decoupling.enable", True),
                ("dynamical_decoupling.sequence_type", "XpXm"),
                ("twirling.enable_gates", True),
                ("twirling.enable_measure", True),
            ]:
                try:
                    obj = s.options
                    *parents, leaf = path.split(".")
                    for p in parents:
                        obj = getattr(obj, p)
                    setattr(obj, leaf, value)
                    applied[path] = value
                except Exception as e:
                    applied[path] = f"FAILED: {e}"
        return s, applied

    # Transpile once, reuse across repeats (identical circuits each job).
    pubs, meta = [], []
    for n, marked, rep in plan:
        qc = _build(algo, n, marked)
        pubs.append(_transpile(qc))
        meta.append({"n": n, "marked": marked, "rep": rep})

    rand = {n: 1 / (2**n) for n in ns}
    all_records = []  # flat, every circuit every repeat
    per_repeat_means = []  # list (len K) of {n: mean}
    job_ids, applied_final = [], {}
    qpu_total = 0

    for k in range(repeats):
        sampler, applied_final = _make_sampler()
        if mitigation and k == 0:
            print(f"  mitigation applied: {applied_final}")
        job = sampler.run(pubs, shots=shots)
        job_ids.append(job.job_id())
        print(f"  repeat {k+1}/{repeats}  job id: {job.job_id()}  (queueing)")
        result = job.result()
        try:
            qpu = job.metrics().get("usage", {}).get("quantum_seconds")
            if qpu is not None:
                qpu_total += qpu
                print(f"    QPU seconds: {qpu}  (running total this run: {qpu_total})")
        except Exception:
            pass
        recs = []
        for m, pub in zip(meta, result):
            try:
                counts = _pub_counts(pub)
                p = counts.get(m["marked"][::-1], 0) / shots
            except Exception as e:
                p = None
                print(f"    decode error {m} ({e})")
            rec = {**m, "repeat": k, "p_marked": p}
            recs.append(rec)
            all_records.append(rec)
        per_repeat_means.append(
            _aggregate([r for r in recs if r["p_marked"] is not None])
        )

    # Aggregate across repeats: mean of the per-repeat per-N means, plus spread.
    print(f"\n{'N':>4}  {'mean':>6}  {'min':>6}  {'max':>6}  {'rand':>6}  per-repeat")
    summary = {}
    for n in ns:
        vals = [m[n] for m in per_repeat_means if n in m]
        if not vals:
            continue
        mean = sum(vals) / len(vals)
        summary[n] = {
            "mean": mean,
            "min": min(vals),
            "max": max(vals),
            "per_repeat": vals,
        }
        pr = "[" + ", ".join(f"{v:.3f}" for v in vals) + "]"
        print(
            f"{2**n:>4}  {mean:>6.3f}  {min(vals):>6.3f}  {max(vals):>6.3f}  "
            f"{rand[n]:>6.3f}  {pr}"
        )
    print(
        "\n(If the OFF/ON gap exceeds the min..max spread, it's real; "
        "if it sits inside the spread, it's drift.)"
    )

    if dump:
        os.makedirs("pilot/scratch", exist_ok=True)
        tag = job_ids[0] if job_ids else "nojob"
        path = f"pilot/scratch/run1_{algo}_{'mit' if mitigation else 'raw'}_{tag}.json"
        with open(path, "w") as f:
            json.dump(
                {
                    "captured_at": datetime.now(timezone.utc).isoformat(),
                    "algo": algo,
                    "backend": backend.name,
                    "job_ids": job_ids,
                    "shots": shots,
                    "repeats": repeats,
                    "qubits_pinned": qubits,
                    "mitigation": applied_final if mitigation else "off",
                    "summary_per_n": {str(2**n): summary.get(n) for n in ns},
                    "random_floor": {str(2**n): rand[n] for n in ns},
                    "records": all_records,
                },
                f,
                indent=2,
            )
        print(f"  archive dumped to {path}")
    return all_records, summary


# --- Hardware metering (spends QPU budget — explicit only) --------------------


def meter_on_hardware(qc, backend_name=None, shots=4096, dump=False):
    """Submit ONE circuit to real hardware and report QPU usage.

    Reads QPU time from job.usage() where available; the Platform Workloads page
    is the authoritative figure — always cross-check there.
    """
    from qiskit import transpile
    from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2

    service = QiskitRuntimeService()  # uses saved account
    if backend_name:
        backend = service.backend(backend_name)
    else:
        backend = service.least_busy(operational=True, simulator=False)
    print(f"  backend: {backend.name}")

    tqc = transpile(qc, backend)
    print(f"  transpiled depth: {tqc.depth()}  ops: {tqc.count_ops()}")

    sampler = SamplerV2(mode=backend)
    job = sampler.run([tqc], shots=shots)
    print(f"  job id: {job.job_id()}  (queue wait does NOT count against budget)")

    result = job.result()  # blocks until complete

    # --- QPU time: try the API, but trust the Workloads page ---
    try:
        print(
            f"  job.usage(): {job.usage()}  <-- QPU seconds, cross-check Workloads page"
        )
    except Exception as e:  # API surface here moves between versions
        print(f"  job.usage() unavailable ({e}); read QPU time from the Workloads page")
    try:
        print(f"  job.metrics(): {job.metrics()}")
    except Exception as e:
        print(f"  job.metrics() unavailable ({e})")

    # --- Counts (V2 result access is version-sensitive; defensive) ---
    try:
        data = result[0].data
        creg = next(iter(data.__dict__))  # first classical register name
        counts = getattr(data, creg).get_counts()
        top = max(counts, key=counts.get)
        print(f"  device top outcome=|{top}>  P(top)={counts[top]/shots:.3f}")
    except Exception as e:
        print(
            f"  result-access path errored ({e}); fix against current docs, note the pattern"
        )
        counts = None

    if dump and counts is not None:
        os.makedirs("pilot/scratch", exist_ok=True)
        path = f"pilot/scratch/{job.job_id()}.txt"
        with open(path, "w") as f:
            f.write(repr(counts))
        print(f"  raw counts dumped to {path} (gitignored scratch)")

    return job


# --- Entry point --------------------------------------------------------------


def main():
    ap = argparse.ArgumentParser(description="Grover pilot — Aer by default.")
    ap.add_argument("--n", type=int, default=3, help="qubit count (N = 2^n)")
    ap.add_argument(
        "--marked",
        type=str,
        default=None,
        help="marked bitstring, length n (default: all ones)",
    )
    ap.add_argument("--shots", type=int, default=4096)
    ap.add_argument(
        "--sweep",
        action="store_true",
        help="Aer-only iteration sweep (teaching-chart data, no QPU)",
    )
    ap.add_argument(
        "--max-iters",
        type=int,
        default=None,
        help="max iterations for --sweep (default: 2*optimal+1)",
    )
    ap.add_argument(
        "--run1",
        action="store_true",
        help="Run 1 success-probability sweep (Aer dry-run unless --hardware)",
    )
    ap.add_argument(
        "--algo",
        choices=["grover", "bv"],
        default="grover",
        help="grover (deep, collapses) or bv (shallow, survives) for --run1",
    )
    ap.add_argument(
        "--ns",
        type=str,
        default="3,4,5",
        help="comma-separated qubit counts for --run1 (default 3,4,5)",
    )
    ap.add_argument(
        "--marked-count",
        type=int,
        default=4,
        help="marked states averaged per N in --run1 (default 4)",
    )
    ap.add_argument(
        "--reps",
        type=int,
        default=5,
        help="outer repetitions per (N, marked) in --run1 (default 5)",
    )
    ap.add_argument(
        "--repeats",
        type=int,
        default=1,
        help="repeat the whole sweep K times as separate jobs to "
        "measure run-to-run drift (--run1 --hardware)",
    )
    ap.add_argument(
        "--qubits",
        type=str,
        default=None,
        help="comma-separated physical qubits to pin (length >= max n); "
        "makes OFF/ON comparison clean. Default: transpiler-chosen.",
    )
    ap.add_argument(
        "--mitigation",
        action="store_true",
        help="enable DD + measurement twirling (--run1 --hardware only)",
    )
    ap.add_argument(
        "--hardware", action="store_true", help="SUBMIT TO REAL QPU AND SPEND BUDGET"
    )
    ap.add_argument(
        "--backend",
        type=str,
        default=None,
        help="backend name, e.g. ibm_kingston (default: least busy)",
    )
    ap.add_argument("--dump", action="store_true", help="dump raw counts to scratch")
    args = ap.parse_args()

    marked = args.marked or ("1" * args.n)

    if args.run1:
        ns = [int(x) for x in args.ns.split(",")]
        records, _ = run1_aer(
            ns, args.marked_count, args.reps, args.shots, algo=args.algo
        )
        if args.hardware:
            if any(r["p_marked"] < 0.5 for r in records):
                print(
                    "\nREFUSING to submit: a circuit failed the Aer dry-run "
                    "(P(success) < 0.5). Fix it before spending QPU time."
                )
                return
            print("\n*** HARDWARE SWEEP — this spends QPU budget ***")
            if (
                input("Type 'yes' to submit the whole Run 1 plan to hardware: ")
                .strip()
                .lower()
                != "yes"
            ):
                print("Aborted.")
                return
            qubits = [int(x) for x in args.qubits.split(",")] if args.qubits else None
            run1_hardware(
                ns,
                args.marked_count,
                args.reps,
                args.shots,
                backend_name=args.backend,
                mitigation=args.mitigation,
                dump=True,
                repeats=args.repeats,
                qubits=qubits,
                algo=args.algo,
            )
        return

    if args.sweep:
        sweep_iterations_aer(args.n, marked, max_iters=args.max_iters, shots=args.shots)
        return

    qc, iters = build_grover(args.n, marked)
    print(f"Grover n={args.n} (N={2**args.n}), marked=|{marked}>, {iters} iteration(s)")

    print("Aer verification:")
    ok, _ = verify_on_aer(qc, marked, shots=args.shots)

    if args.hardware:
        if not ok:
            print(
                "\nREFUSING to submit: circuit failed Aer verification. Fix it first."
            )
            return
        print("\n*** HARDWARE SUBMISSION — this spends QPU budget ***")
        confirm = input("Type 'yes' to submit one circuit to real hardware: ")
        if confirm.strip().lower() != "yes":
            print("Aborted.")
            return
        meter_on_hardware(
            qc, backend_name=args.backend, shots=args.shots, dump=args.dump
        )


if __name__ == "__main__":
    main()
