# Understanding `grover_pilot.py` — what each step does and why

A walkthrough for someone who reads Python fluently but is new to quantum. Read it next to the script. The goal is that by the end, every line in `build_grover`, `_oracle`, and `_diffuser` means something — not "magic happens here."

This is also a dry run for the post's explainer section: it's written in the register Crucible needs — mechanism-first, and explicitly refusing the usual myths.

---

## The one mental model you need (and the myth to drop)

**The myth:** "A quantum computer tries all the answers at once and tells you the right one." This is wrong, and a quant reader will smell it. If it were true, search would be instant, not √N.

**The model that's actually right:** the machine holds a list of **amplitudes** — one number per possible answer. For n qubits there are N = 2ⁿ possible answers, so N amplitudes. An amplitude is like a probability, except it can be negative (and in general complex). When you finally measure, you get answer *i* with probability proportional to amplitude*ᵢ* squared. You get **one** answer out, not all of them.

So you never "read all the answers." The entire game is: **arrange the amplitudes so that the marked answer has a large magnitude and everything else is near zero, before you measure.** Grover is a recipe for doing exactly that, and it needs √N steps because each step can only nudge the amplitudes a little.

Hold that picture — amplitudes you're sculpting, one measurement at the end — and the rest is mechanical.

---

## The problem being solved

Unstructured search: someone gives you a test (the "oracle") that says yes/no for a candidate, and you want the one candidate that passes. No structure, no sorting — all you can do is try candidates.

- **Classical:** in the worst case you try all N. That's the linear scan, O(N). It's what the C++ baseline will time.
- **Grover:** finds it in about (π/4)·√N steps. For N = 16 that's ~3 steps instead of up to 16. Quadratic, not exponential — a real but modest speedup, and (the post's whole point) one that today's noisy hardware throws away.

---

## The steps, mapped to the code

### Step 1 — Equal superposition (`qc.h(qubits)`)

The circuit starts every qubit in state |0⟩, so the whole register is the single answer "000…0". Applying a **Hadamard** (`H`) gate to each qubit spreads it into an equal mix of *all* N answers — every amplitude becomes 1/√N. Not "all answers at once" in the magic sense; just: the list of amplitudes now starts out flat.

In the code: `qc.h(qubits)` at the top of `build_grover`. One line, all qubits.

Why flat? Because we have no idea where the answer is yet, so we start with no bias. Grover's job is to bend this flat list toward the marked answer.

### Step 2 — The oracle: mark the answer with a sign (`_oracle`)

The oracle flips the **sign** of the marked answer's amplitude: +1/√N becomes −1/√N. Every other amplitude is untouched.

Here's the subtle part, and the part most tutorials skip: **right after the oracle, measuring would tell you nothing.** Probabilities are amplitude *squared*, and (−1/√N)² = (1/√N)² — so the marked answer is exactly as likely as everything else. The mark is real but *invisible to measurement*. It's a sign change hiding in the amplitudes.

How the code does it (`_oracle`):
- The easy thing to phase-flip is the "all-ones" answer (11…1), using a multi-controlled Z (`_mcz`). So first we X-flip the qubits that *should* be 0 in our marked pattern, which relabels the marked answer as all-ones (`qc.x(zeros)`).
- `_mcz` flips the sign of all-ones.
- We undo the X-flips (`qc.x(zeros)`), putting the labels back.

Net effect: exactly the marked answer's amplitude gets its sign flipped, nothing else.

`_mcz` itself is the standard trick that a multi-controlled-Z equals H · (multi-controlled-X) · H on the target qubit — that's why you see `qc.h(target); qc.mcx(controls, target); qc.h(target)`.

### Step 3 — The diffuser: make the invisible mark visible (`_diffuser`)

This is where the amplification happens, and it's the cleverest step. The diffuser does **"inversion about the mean"**: it reflects every amplitude around the *average* of all amplitudes.

Walk it through with the numbers. After the oracle, one amplitude is −1/√N (marked) and N−1 are +1/√N. The average is therefore slightly *positive* (the one negative barely dents it). Now reflect each amplitude across that average:
- The marked amplitude was *below* the mean (it's negative), so reflecting it lands it *well above* the mean — its magnitude jumps up.
- The unmarked amplitudes were just above the mean, so reflecting them nudges them slightly *down*.

The hidden sign flip has been converted into a visible size difference. The marked answer is now genuinely more probable. That's "amplitude amplification."

In the code (`_diffuser`): `H` then `X` on all qubits, an `_mcz`, then `X` then `H` again. That sandwich is the algebra for "reflect about the equal-superposition state," which is the same thing as inversion about the mean. You don't have to derive it; you have to know that's what it *is*.

### Repeat — why a fixed number of times, and why more is worse

One oracle + one diffuser = one **Grover iteration**. Geometrically, each iteration rotates the amplitude "state" by a fixed angle toward the marked answer. Do it the right number of times — about (π/4)·√N — and you land as close to the marked answer as you can get. **Keep going and you rotate past it**, and the probability *drops*. Over-rotation is a real failure mode, not a safety margin.

This is exactly what the `--sweep` output shows. For n=4 (N=16), optimal is 3 iterations:

```
iters  P(marked)
    0      0.063   <- flat start, = 1/16, pure chance
    1      0.477
    2      0.905
    3      0.963   <- optimal, as good as it gets
    4      0.590   <- rotated past the target
    5      0.131
    6      0.021   <- worse than random
```

`optimal_iterations(n)` computes the (π/4)·√N count; `build_grover(..., iterations=k)` lets the sweep force any k so you can see the whole curve. That oscillation is the teaching chart: Grover is a controlled rotation you can overshoot, not a magic lookup.

### Step 4 — Measure (`qc.measure`)

Reading the qubits collapses the whole amplitude list down to **one** answer, chosen with probability = amplitude². After the optimal iterations the marked answer's amplitude dominates, so you almost always read it back. "Almost" — at N = 8 it's ~0.945, not 1.0, which is why the post reports a *probability*, not a yes/no.

One bit-order footgun, called out in `verify_on_aer`: Qiskit prints measurement strings in reverse (rightmost qubit first), so marked `100` comes back as `001`. The code compares against `marked[::-1]` to account for it. Watch this whenever you read counts.

---

## Why simulate first, and what changes on real hardware

`verify_on_aer` runs the circuit on the **Aer simulator** — exact arithmetic on the amplitude list, no noise. It's free, local, and tells you the circuit is *logically* correct (the marked answer dominates). If a circuit is wrong, you find out here for free instead of paying QPU minutes to watch noise.

`meter_on_hardware` runs the *same* circuit on a real device. On hardware, two things break the clean rotation:
- **Gate error:** every gate is slightly wrong, and Grover stacks many gates. Errors compound with circuit depth.
- **Decoherence:** the qubits' state decays over time (the T1/T2 numbers you'll see on the backend). A deep circuit takes long enough that the amplitudes blur before you measure.

So the real device's amplitudes don't end up sculpted into a clean spike on the marked answer — they smear back toward flat. That's the collapse the post measures: the gap between the simulator (clean rotation, near-1.0) and the hardware (noise eating the rotation, sliding toward 1/N). The √N advantage is real in the math and gone in the silicon — which is the thesis.

That's also why the same circuit gives different numbers on different days: backends recalibrate, so the noise changes. The classical baseline and the simulator reproduce exactly; the hardware numbers are pinned by archiving the job results, not by re-running.

---

## Links — in rough reading order

1. **IBM Quantum Learning — Grover's algorithm (computer-science track).** The gentlest correct treatment, structured exactly as the steps above (superposition → mark → diffuse → repeat). https://quantum.cloud.ibm.com/learning/en/modules/computer-science/grovers
2. **IBM Quantum Learning — "Fundamentals of quantum algorithms" (John Watrous), Grover lesson.** The rigorous version with the actual math of the rotation and the iteration count, if you want the derivation rather than the picture. Linked from the module above; it's the course to graduate to.
3. **Nielsen & Chuang, *Quantum Computation and Quantum Information*, §6.1 (the "quantum search algorithm").** The canonical textbook treatment of Grover and the inversion-about-the-mean geometry. Worth it if you want the definitive source; it's the reference the tutorials cite.
4. **Mandviwalla, Ohshiro & Ji, "Implementing Grover's Algorithm on the IBM Quantum Computers."** A short empirical paper doing on real hardware almost exactly what this pilot does — useful as a sanity check on your numbers (their 4-qubit/3-iteration ideal accuracy is ~96%, matching the simulator here) and as prior art for the post's collapse story. https://par.nsf.gov/servlets/purl/10089417

Skip the breathless blog explainers. Anything that says "tries all answers simultaneously" is teaching you the myth from the top of this doc, and it'll cost you when you try to reason about why the device collapses.

---

## What you do *not* need to understand to run the pilot

- The complex-number details of amplitudes. "Numbers, can be negative, squared gives probability" is enough to reason about every step here.
- The matrix algebra behind why the H–X–MCZ–X–H sandwich is a reflection. Know *what* it does (inversion about the mean); the derivation is in links 2 and 3 when you want it.
- Transpilation internals. `transpile(qc, backend)` rewrites your circuit into the device's native gates and connectivity; you can treat it as a compiler pass for now.
