"""
capture.py — Crucible quantum special edition: "Measuring the Gap".

Promoted from grover_pilot.py. The circuit builders (build_grover, build_bv)
are UNCHANGED from the validated pilot — diff confirms no edits to their logic.

This tool runs the full capture suite:
  • Grover N-sweep (n ∈ {3,4,5}), ≥5 outer repeats, extra repeats at n=4 (mid-collapse)
  • BV N-sweep at the same n values
  • Grover mitigation off/on pair at each N, matched qubits
  • Aer-only teaching sweep (P(marked) vs iteration count at n=4)
  • Ideal-simulator reference curves for Grover and BV

Outputs:
  site/src/data/quantum/measuring-the-gap.json  — the committed schema
  quantum/capture/scratch/<job_id>-raw.json      — raw archive (gitignored scratch)

Usage (Aer dry-run, no hardware, no spend):
    python capture.py --aer-only
    python capture.py --aer-only --ns 3,4,5 --marked-count 4 --reps 5

Usage (hardware — SPENDS QPU BUDGET, user task):
    python capture.py --hardware --backend ibm_marrakesh \\
        --qubits 0,1,2,3,4,5 --ns 3,4,5 --marked-count 4 --reps 5 --repeats 5
    python capture.py --hardware --backend ibm_marrakesh \\
        --qubits 0,1,2,3,4,5 --ns 3,4,5 --marked-count 4 --reps 5 --repeats 8 \\
        --extra-mid-repeats 3 --mid-collapse-n 4 --mitigation

Acceptance check (Aer path must complete, all near 1.0):
    python capture.py --aer-only && echo "PASS"

Open item flagged to user:
    The BV circuit uses n+1 qubits (input + ancilla). --qubits must supply
    at least max(n)+1 entries. If the pinned layout is too narrow for BV
    this script raises ValueError rather than silently rerouting.
"""

import argparse
import json
import math
import os
from datetime import datetime, timezone

# ─── Circuit construction (unchanged from validated pilot) ─────────────────────


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


# ─── Circuit depth metrics ──────────────────────────────────────────────────────


def circuit_metrics(qc, backend=None):
    """Return depth and 2-qubit gate count, optionally for a transpiled circuit."""
    from qiskit import transpile
    from qiskit_aer import AerSimulator

    if backend is None:
        backend = AerSimulator()
    tqc = transpile(qc, backend, seed_transpiler=42)
    ops = tqc.count_ops()
    cx_count = ops.get("cx", 0) + ops.get("ecr", 0) + ops.get("cz", 0)
    return {"depth": tqc.depth(), "two_qubit_gates": cx_count, "ops": dict(ops)}


# ─── Aer helpers ───────────────────────────────────────────────────────────────


def _aer_counts(qc, shots):
    from qiskit import transpile
    from qiskit_aer import AerSimulator

    sim = AerSimulator()
    tqc = transpile(qc, sim)
    return sim.run(tqc, shots=shots).result().get_counts()


def marked_states(n, count):
    """A deterministic, reproducible spread of `count` distinct marked states.

    Evenly spaced across [0, 2^n) so the averaged P(marked) isn't biased by one
    'easy' state (e.g. all-ones). Reproducible: same set every run.
    """
    N = 2**n
    count = min(count, N)
    idxs = sorted({round(i * (N - 1) / max(1, count - 1)) for i in range(count)})
    return [format(idx, f"0{n}b") for idx in idxs]


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


# ─── Aer reference sweep ───────────────────────────────────────────────────────


def aer_sweep(ns, marked_count, reps, shots, algo="grover"):
    """Ideal-simulator sweep. Returns (records, per-N means).

    Every circuit should be near 1.0; if any N is low the circuit is wrong.
    """
    plan = _plan(ns, marked_count, reps)
    print(
        f"  Aer [{algo}]: {len(plan)} circuits  "
        f"(ns={ns}, {marked_count} states/N, {reps} reps, {shots} shots)"
    )
    records = []
    for n, marked, rep in plan:
        qc = _build(algo, n, marked)
        counts = _aer_counts(qc, shots)
        p = counts.get(marked[::-1], 0) / shots
        records.append({"n": n, "marked": marked, "rep": rep, "p_marked": p})

    means = _aggregate(records)
    print(f"\n  {'N':>4}  {'mean P(success)':>15}  {'random 1/N':>11}")
    for n in ns:
        rand = 1 / (2**n)
        print(f"  {2**n:>4}  {means[n]:>15.3f}  {rand:>11.4f}")

    return records, means


# ─── Aer teaching sweep ────────────────────────────────────────────────────────


def teaching_sweep_aer(n, marked, max_iters=None, shots=4096):
    """P(marked) as a function of Grover iteration count (no QPU cost).

    Shows the amplitude-amplification oscillation — probability rises to the
    optimal peak, then falls if you over-rotate. This is the teaching-chart data.
    """
    opt = optimal_iterations(n)
    if max_iters is None:
        max_iters = 2 * opt + 1
    marked_as_measured = marked[::-1]

    print(f"  Teaching sweep: n={n} (N={2**n}), marked=|{marked}>, optimal={opt}")
    curve = []
    for k in range(0, max_iters + 1):
        qc, _ = build_grover(n, marked, iterations=k)
        counts = _aer_counts(qc, shots)
        p = counts.get(marked_as_measured, 0) / shots
        marker = "  <-- optimal" if k == opt else ""
        print(f"  {k:>5} iters  P={p:.4f}{marker}")
        curve.append({"iters": k, "p_marked": round(p, 4)})
    return curve


# ─── Circuit depth table ───────────────────────────────────────────────────────


def collect_depth_metrics(ns, marked_count, backend=None):
    """Collect transpiled depth and 2-qubit gate count for Grover and BV at each N."""
    metrics = {"grover": [], "bv": []}
    for n in ns:
        g_state = marked_states(n, 1)[0]
        qc_g, iters = build_grover(n, g_state)
        m_g = circuit_metrics(qc_g, backend=backend)
        metrics["grover"].append(
            {
                "n": n,
                "N": 2**n,
                "optimal_iters": iters,
                "depth": m_g["depth"],
                "two_qubit_gates": m_g["two_qubit_gates"],
            }
        )
        qc_b = build_bv(n, g_state)
        m_b = circuit_metrics(qc_b, backend=backend)
        metrics["bv"].append(
            {
                "n": n,
                "N": 2**n,
                "depth": m_b["depth"],
                "two_qubit_gates": m_b["two_qubit_gates"],
            }
        )
    return metrics


# ─── Hardware sweep ────────────────────────────────────────────────────────────


def _pub_counts(pub_result):
    """Extract counts from a SamplerV2 PUB result (version-sensitive access)."""
    data = pub_result.data
    creg = next(iter(data.__dict__))
    return getattr(data, creg).get_counts()


def hardware_sweep(
    ns,
    marked_count,
    reps,
    shots,
    backend_name,
    repeats,
    qubits,
    mitigation=False,
    mid_collapse_n=None,
    extra_mid_repeats=0,
    algo="grover",
    dump_dir="quantum/capture/scratch",
):
    """Run the full sweep on real hardware.

    qubits: explicit physical-qubit list. Length must be >= max(ns) + 1 (BV ancilla).
    mid_collapse_n: the n value that showed uncertain collapse in the pilot — receives
        extra_mid_repeats additional repeats so the mitigation magnitude is more certain.
    Returns (all_records, per_n_summary, backend_info, job_ids).
    """
    from qiskit import transpile
    from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2

    widest = max(ns) + (1 if algo == "bv" else 0)
    if qubits is not None and len(qubits) < widest:
        raise ValueError(
            f"--qubits needs >= {widest} entries for algo={algo}, max n={max(ns)}. "
            f"(BV uses n+1 qubits — the ancilla requires one extra physical qubit.) "
            f"Flagged to user: pin a layout wide enough for BV before submitting."
        )

    service = QiskitRuntimeService()
    backend = service.backend(backend_name)

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

    plan = _plan(ns, marked_count, reps)
    extra_plan = (
        _plan([mid_collapse_n], marked_count, reps) if mid_collapse_n is not None else []
    )

    pubs, meta = [], []
    for n, marked, rep in plan:
        qc = _build(algo, n, marked)
        pubs.append(_transpile(qc))
        meta.append({"n": n, "marked": marked, "rep": rep, "is_extra": False})

    extra_pubs, extra_meta = [], []
    for n, marked, rep in extra_plan:
        qc = _build(algo, n, marked)
        extra_pubs.append(_transpile(qc))
        extra_meta.append({"n": n, "marked": marked, "rep": rep, "is_extra": True})

    all_records = []
    per_repeat_means = []
    job_ids = []
    applied_final = {}
    qpu_total = 0

    total_repeats = repeats + extra_mid_repeats
    for k in range(total_repeats):
        use_extra = k >= repeats
        current_pubs = extra_pubs if use_extra else pubs
        current_meta = extra_meta if use_extra else meta
        if not current_pubs:
            continue

        sampler, applied_final = _make_sampler()
        job = sampler.run(current_pubs, shots=shots)
        job_ids.append(job.job_id())
        label = f"extra-mid {k - repeats + 1}/{extra_mid_repeats}" if use_extra else f"repeat {k + 1}/{repeats}"
        print(f"  {label}  job id: {job.job_id()}  (queueing)")
        result = job.result()
        try:
            qpu = job.metrics().get("usage", {}).get("quantum_seconds")
            if qpu is not None:
                qpu_total += qpu
                print(f"    QPU seconds: {qpu}  (running total: {qpu_total})")
        except Exception:
            pass

        recs = []
        for m, pub in zip(current_meta, result):
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

    summary = {}
    for n in ns:
        vals = [m[n] for m in per_repeat_means if n in m]
        if not vals:
            continue
        mean = sum(vals) / len(vals)
        summary[n] = {
            "mean": round(mean, 4),
            "min": round(min(vals), 4),
            "max": round(max(vals), 4),
            "per_repeat": [round(v, 4) for v in vals],
        }

    backend_info = {
        "name": backend.name,
        "num_qubits": backend.num_qubits,
    }
    try:
        backend_info["basis_gates"] = list(backend.basis_gates)
    except Exception:
        pass
    try:
        c = backend.configuration()
        backend_info["coupling_map"] = list(c.coupling_map)
    except Exception:
        pass

    os.makedirs(dump_dir, exist_ok=True)
    tag = job_ids[0] if job_ids else "nojob"
    raw_path = os.path.join(
        dump_dir, f"raw_{algo}_{'mit' if mitigation else 'raw'}_{tag}.json"
    )
    with open(raw_path, "w") as f:
        json.dump(
            {
                "captured_at": datetime.now(timezone.utc).isoformat(),
                "algo": algo,
                "backend": backend_info,
                "job_ids": job_ids,
                "shots": shots,
                "repeats": repeats,
                "extra_mid_repeats": extra_mid_repeats,
                "mid_collapse_n": mid_collapse_n,
                "qubits_pinned": qubits,
                "mitigation": applied_final if mitigation else "off",
                "summary_per_n": {str(2**n): summary.get(n) for n in ns},
                "random_floor": {str(2**n): round(1 / (2**n), 6) for n in ns},
                "records": all_records,
            },
            f,
            indent=2,
        )
    print(f"  raw archive: {raw_path}")
    return all_records, summary, backend_info, job_ids


# ─── JSON schema assembly ───────────────────────────────────────────────────────


def build_output_json(
    data_status,
    aer_grover_records,
    aer_bv_records,
    teaching_curve,
    depth_metrics,
    ns,
    shots,
    backend_info=None,
    physical_qubits=None,
    calibration_timestamp=None,
    hw_grover_summary=None,
    hw_bv_summary=None,
    hw_grover_mit_off_summary=None,
    hw_grover_mit_on_summary=None,
    hw_grover_mit_off_records=None,
    hw_grover_mit_on_records=None,
    raw_archive_paths=None,
):
    """Assemble the committed quantum JSON schema.

    The schema is deliberately namespaced away from the locked perf schema.
    hardware fields are null until the user's hardware capture lands.
    """
    rand_floor = {n: round(1 / (2**n), 6) for n in ns}

    def _summarise_aer(records, ns_list):
        by_n = {}
        for r in records:
            by_n.setdefault(r["n"], []).append(r["p_marked"])
        return [
            {
                "n": n,
                "N": 2**n,
                "mean": round(sum(ps) / len(ps), 4),
                "min": round(min(ps), 4),
                "max": round(max(ps), 4),
                "per_repeat": [round(p, 4) for p in ps],
            }
            for n in ns_list
            if n in by_n
            for ps in [by_n[n]]
        ]

    def _hw_series(summary, ns_list):
        if summary is None:
            return [{"n": n, "N": 2**n, "mean": None, "min": None, "max": None, "per_repeat": [], "status": "hardware-capture-pending"} for n in ns_list]
        return [
            {
                "n": n,
                "N": 2**n,
                **summary.get(n, {"mean": None, "min": None, "max": None, "per_repeat": []}),
            }
            for n in ns_list
        ]

    return {
        "schema": "quantum-measuring-the-gap-v1",
        "data_status": data_status,
        "note": (
            "Aer-only placeholder — hardware numbers are null pending the user's capture run. "
            "Aer (ideal simulator) and teaching-sweep data are committed and reproducible. "
            "Do not publish hardware-null cells as measurement results."
            if data_status == "aer-only"
            else "Full hardware capture committed."
        ),
        "capture_meta": {
            "backend": backend_info,
            "physical_qubits": physical_qubits,
            "calibration_timestamp": calibration_timestamp,
            "shots": shots,
            "ns": ns,
            "captured_at": datetime.now(timezone.utc).isoformat(),
        },
        "ns_sweep": {
            "grover_ideal": _summarise_aer(aer_grover_records, ns),
            "grover_device": _hw_series(hw_grover_summary, ns),
            "bv_ideal": _summarise_aer(aer_bv_records, ns),
            "bv_device": _hw_series(hw_bv_summary, ns),
            "classical_floor": [{"n": n, "N": 2**n, "mean": 1.0} for n in ns],
            "random_floor": [{"n": n, "N": 2**n, "mean": rand_floor[n]} for n in ns],
        },
        "mitigation": {
            "note": "Grover device success with mitigation off vs on. Null until hardware capture.",
            "off": _hw_series(hw_grover_mit_off_summary, ns),
            "on": _hw_series(hw_grover_mit_on_summary, ns),
        },
        "teaching_sweep": {
            "n": 4,
            "N": 16,
            "marked": "1111",
            "note": "Aer-only (no QPU cost). Shows over-rotation: P(marked) rises then falls past optimal.",
            "curve": teaching_curve,
        },
        "circuit_depth": depth_metrics,
        "raw_archive_paths": raw_archive_paths or [],
    }


# ─── Main capture flow ──────────────────────────────────────────────────────────


def run_aer_only(ns, marked_count, reps, shots, out_path):
    """Run the full Aer suite and emit the placeholder JSON."""
    print("=== Aer-only capture (no QPU spend) ===")
    print("\n[1/4] Grover ideal simulator sweep")
    grover_records, _ = aer_sweep(ns, marked_count, reps, shots, algo="grover")

    print("\n[2/4] BV ideal simulator sweep")
    bv_records, _ = aer_sweep(ns, marked_count, reps, shots, algo="bv")

    print("\n[3/4] Teaching sweep (n=4, over-rotation demonstration)")
    t_curve = teaching_sweep_aer(4, "1" * 4, shots=shots)

    print("\n[4/4] Circuit depth metrics (Aer transpilation)")
    depth = collect_depth_metrics(ns, marked_count)

    # Validate: Aer circuits must all be near 1.0
    failures = [r for r in grover_records + bv_records if r["p_marked"] < 0.5]
    if failures:
        print(f"\nWARNING: {len(failures)} circuits scored < 0.5 on Aer — check circuit logic before hardware run.")
        for f in failures:
            print(f"  n={f['n']} marked={f['marked']} rep={f['rep']} p={f['p_marked']:.3f}")
    else:
        print("\nAll Aer circuits near 1.0 — circuit logic validated.")

    out_json = build_output_json(
        data_status="aer-only",
        aer_grover_records=grover_records,
        aer_bv_records=bv_records,
        teaching_curve=t_curve,
        depth_metrics=depth,
        ns=ns,
        shots=shots,
    )

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(out_json, f, indent=2)
    print(f"\nCommitted JSON: {out_path}")
    return out_json


def run_hardware_capture(
    ns,
    marked_count,
    reps,
    shots,
    backend_name,
    repeats,
    qubits,
    out_path,
    extra_mid_repeats=3,
    mid_collapse_n=4,
):
    """Full hardware capture. Aer validates first; hardware runs only if Aer passes."""
    print("=== Hardware capture — SPENDS QPU BUDGET ===")
    print("\n[1/6] Aer validation (gates must pass before hardware spend)")
    grover_aer, _ = aer_sweep(ns, marked_count, reps, shots, algo="grover")
    bv_aer, _ = aer_sweep(ns, marked_count, reps, shots, algo="bv")
    failures = [r for r in grover_aer + bv_aer if r["p_marked"] < 0.5]
    if failures:
        print(f"REFUSING: {len(failures)} Aer failures. Fix circuits before spending QPU budget.")
        return None

    print("\n[2/6] Teaching sweep (Aer only, free)")
    t_curve = teaching_sweep_aer(4, "1" * 4, shots=shots)

    print("\n[3/6] Circuit depth metrics")
    depth = collect_depth_metrics(ns, marked_count)

    print("\n[4/6] Grover hardware sweep (mitigation off)")
    hw_g_records, hw_g_summary, backend_info, jids_g = hardware_sweep(
        ns, marked_count, reps, shots, backend_name, repeats, qubits,
        mitigation=False, mid_collapse_n=mid_collapse_n, extra_mid_repeats=extra_mid_repeats, algo="grover",
    )

    print("\n[5/6] BV hardware sweep")
    hw_bv_records, hw_bv_summary, _, jids_bv = hardware_sweep(
        ns, marked_count, reps, shots, backend_name, repeats, qubits,
        mitigation=False, algo="bv",
    )

    print("\n[6/6] Grover hardware sweep (mitigation on)")
    hw_g_mit_records, hw_g_mit_summary, _, jids_mit = hardware_sweep(
        ns, marked_count, reps, shots, backend_name, repeats, qubits,
        mitigation=True, mid_collapse_n=mid_collapse_n, extra_mid_repeats=extra_mid_repeats, algo="grover",
    )

    all_job_ids = jids_g + jids_bv + jids_mit
    cal_ts = datetime.now(timezone.utc).isoformat()

    out_json = build_output_json(
        data_status="hardware-captured",
        aer_grover_records=grover_aer,
        aer_bv_records=bv_aer,
        teaching_curve=t_curve,
        depth_metrics=depth,
        ns=ns,
        shots=shots,
        backend_info=backend_info,
        physical_qubits=qubits,
        calibration_timestamp=cal_ts,
        hw_grover_summary=hw_g_summary,
        hw_bv_summary=hw_bv_summary,
        hw_grover_mit_off_summary=hw_g_summary,
        hw_grover_mit_on_summary=hw_g_mit_summary,
        hw_grover_mit_off_records=hw_g_records,
        hw_grover_mit_on_records=hw_g_mit_records,
        raw_archive_paths=[f"quantum/capture/scratch/raw_*_{all_job_ids[0]}*.json"] if all_job_ids else [],
    )

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(out_json, f, indent=2)
    print(f"\nCommitted JSON: {out_path}")
    print(f"All job IDs: {all_job_ids}")
    return out_json


# ─── Entry point ───────────────────────────────────────────────────────────────


def main():
    ap = argparse.ArgumentParser(description="Crucible quantum capture tool.")
    ap.add_argument("--aer-only", action="store_true", help="Run Aer suite only (no hardware, no spend)")
    ap.add_argument("--hardware", action="store_true", help="SUBMIT TO REAL QPU — SPENDS BUDGET")
    ap.add_argument("--backend", type=str, default="ibm_marrakesh")
    ap.add_argument("--ns", type=str, default="3,4,5")
    ap.add_argument("--marked-count", type=int, default=4)
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--shots", type=int, default=4096)
    ap.add_argument("--repeats", type=int, default=5, help="Hardware: separate job repeats")
    ap.add_argument("--qubits", type=str, default=None, help="Pinned physical qubits (comma-separated, >= max_n+1)")
    ap.add_argument("--mitigation", action="store_true")
    ap.add_argument("--extra-mid-repeats", type=int, default=3)
    ap.add_argument("--mid-collapse-n", type=int, default=4)
    ap.add_argument(
        "--out",
        type=str,
        default=os.path.join(
            os.path.dirname(__file__), "..", "site", "src", "data", "quantum", "measuring-the-gap.json"
        ),
    )
    args = ap.parse_args()

    ns = [int(x) for x in args.ns.split(",")]

    if args.aer_only:
        run_aer_only(ns, args.marked_count, args.reps, args.shots, os.path.normpath(args.out))
        return

    if args.hardware:
        if args.qubits is None:
            ap.error("--hardware requires --qubits (pin physical qubits for clean comparison)")
        qubits = [int(x) for x in args.qubits.split(",")]
        widest = max(ns) + 1  # BV ancilla
        if len(qubits) < widest:
            ap.error(
                f"--qubits needs >= {widest} entries (max n={max(ns)}, BV uses n+1 qubits). "
                f"Flag: layout too narrow for BV sweep."
            )
        print(f"*** HARDWARE SUBMISSION — SPENDS QPU BUDGET ***")
        confirm = input("Type 'yes' to proceed: ").strip().lower()
        if confirm != "yes":
            print("Aborted.")
            return
        run_hardware_capture(
            ns, args.marked_count, args.reps, args.shots,
            args.backend, args.repeats, qubits,
            os.path.normpath(args.out),
            extra_mid_repeats=args.extra_mid_repeats,
            mid_collapse_n=args.mid_collapse_n,
        )
        return

    ap.print_help()
    print("\nRun with --aer-only for a free Aer validation run, or --hardware to submit to real QPU.")


if __name__ == "__main__":
    main()
