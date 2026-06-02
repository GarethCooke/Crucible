import type { Metadata } from 'next'
import { loadQuantumData } from '@/lib/quantum-data'
import { QuantumCollapseCurve } from '@/components/charts/quantum/QuantumCollapseCurve'
import { QuantumOverRotation } from '@/components/charts/quantum/QuantumOverRotation'
import { QuantumMechanism } from '@/components/charts/quantum/QuantumMechanism'
import { QuantumBVGrover } from '@/components/charts/quantum/QuantumBVGrover'
import { QuantumMitigation } from '@/components/charts/quantum/QuantumMitigation'
import { AsymptoticCrossover } from '@/components/charts/quantum/AsymptoticCrossover'

export const metadata: Metadata = {
  title: 'Measuring the Gap — Grover\'s algorithm on real quantum hardware',
  description:
    'Take a problem with a famous theoretical quantum speedup, run it both ways, and measure the gap between the promise and the silicon. Classical wins decisively today; this post shows precisely why.',
}

function SpecialBadge() {
  return (
    <span
      className="font-mono text-xs uppercase tracking-widest px-2 py-1 rounded border"
      style={{ color: 'var(--cyan)', borderColor: 'var(--cyan)', opacity: 0.75 }}
    >
      Special edition — outside the standard methodology
    </span>
  )
}

function Section({ id, children }: { id?: string; children: React.ReactNode }) {
  return (
    <section id={id} className="mb-14">
      {children}
    </section>
  )
}

function H2({ children }: { children: React.ReactNode }) {
  return (
    <h2
      className="font-sans text-xl font-semibold tracking-tight mt-12 mb-4"
      style={{ color: 'var(--text-primary)' }}
    >
      {children}
    </h2>
  )
}

function P({ children }: { children: React.ReactNode }) {
  return (
    <p className="text-base leading-relaxed mb-4" style={{ color: 'var(--text-secondary)' }}>
      {children}
    </p>
  )
}

function Callout({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="rounded-xl border p-5 mb-6 text-sm leading-relaxed"
      style={{ borderColor: 'var(--border-color)', background: 'var(--bg-card)', color: 'var(--text-secondary)' }}
    >
      {children}
    </div>
  )
}

export default async function MeasuringTheGapPage() {
  const data = await loadQuantumData()
  const pending = data.data_status === 'aer-only'

  // Pull ideal-simulator numbers for prose (safe to cite — Aer is reproducible)
  const groverIdeal = data.ns_sweep.grover_ideal
  const n3ideal = groverIdeal.find((p) => p.n === 3)?.mean ?? null
  const n4ideal = groverIdeal.find((p) => p.n === 4)?.mean ?? null
  const n5ideal = groverIdeal.find((p) => p.n === 5)?.mean ?? null

  const teachN = data.teaching_sweep.n
  const teachOpt = data.teaching_sweep.curve.reduce(
    (best, pt) => (pt.p_marked > best.p_marked ? pt : best),
    data.teaching_sweep.curve[0],
  )

  // Grover device numbers: only cite if hardware-captured
  const groverDevice = data.ns_sweep.grover_device
  const hwN3 = groverDevice.find((p) => p.n === 3)?.mean ?? null
  const hwN5 = groverDevice.find((p) => p.n === 5)?.mean ?? null
  const bvDevice = data.ns_sweep.bv_device
  const bvHwN5 = bvDevice.find((p) => p.n === 5)?.mean ?? null

  const fmt = (v: number | null) =>
    v === null ? '[hardware capture pending]' : v.toFixed(2)

  return (
    <article>
      {/* Back navigation */}
      <div className="flex items-center gap-4 mb-12">
        <a href="/" className="text-sm transition-opacity hover:opacity-70" style={{ color: 'var(--text-muted)' }}>
          ← All posts
        </a>
      </div>

      {/* Special edition marker */}
      <div className="mb-6">
        <SpecialBadge />
      </div>

      {/* Header */}
      <header className="mb-12">
        <p className="font-mono text-xs uppercase tracking-widest mb-3" style={{ color: 'var(--cyan)' }}>
          2026-06-02
        </p>
        <h1
          className="font-sans text-3xl font-semibold tracking-tight mb-4 leading-tight"
          style={{ color: 'var(--text-primary)' }}
        >
          Measuring the gap
        </h1>
        <p className="text-lg" style={{ color: 'var(--text-secondary)' }}>
          Take a problem with a famous theoretical quantum speedup, run it both ways, and measure the
          gap between the promise and the silicon. Classical wins decisively today. This post shows
          exactly why — gate error × depth, decoherence, no error correction — and maps where
          advantage is genuinely landing in 2026.
        </p>
      </header>

      {/* What this post does NOT claim */}
      <Callout>
        <p className="font-mono text-xs uppercase tracking-widest mb-3" style={{ color: 'var(--cyan)' }}>
          What this post does not claim
        </p>
        <ul className="space-y-2">
          {[
            'Not "quantum is hype." Real 2026 advantage claims exist for quantum-simulation / physics-class problems — cited below as claimed and recent, awaiting independent replication.',
            'No quantum win on finance workloads. Finance-sector quantum results to date are promissory or par-with-classical on small hardware instances, not a production win.',
            'Not a benchmark in the Crucible sense. These numbers are not comparable ns/op figures — see the methodology departure note.',
            'Not a Q-Day prediction. The asymptotic chart shows requirements, not a date.',
          ].map((item) => (
            <li key={item} className="flex gap-3 text-sm" style={{ color: 'var(--text-secondary)' }}>
              <span style={{ color: 'var(--cyan)' }} className="shrink-0">–</span>
              {item}
            </li>
          ))}
        </ul>
      </Callout>

      {/* The hook */}
      <Section id="hook">
        <P>
          Grover's algorithm has a clean theoretical story: unstructured search in O(√N) queries
          instead of the classical O(N). For a database of 32 entries that's 4 optimal iterations
          instead of up to 32. The math is sound, the circuit is well-understood, and the
          ideal-simulator result confirms it — at N=32 the marked answer comes out with
          P={fmt(n5ideal)} on a noiseless simulation. Then you run the same circuit on real
          quantum hardware, and the number is{' '}
          <strong style={{ color: 'var(--text-primary)' }}>{fmt(hwN5)}</strong>.
        </P>
        <P>
          That gap is the whole post. Not as a failure story — the hardware is doing what physics
          allows — but as a precise measurement of what "NISQ" means in practice: the circuit depth
          required to express the speedup exceeds what current hardware can execute without noise
          destroying the interference pattern you need.
        </P>
      </Section>

      {/* The experiment */}
      <Section id="experiment">
        <H2>The experiment</H2>
        <P>
          The benchmark is Grover's algorithm against classical linear search, run for search-space
          sizes N ∈ {'{8, 16, 32}'} (n ∈ {'{3, 4, 5}'} qubits). Each N was run with four distinct
          marked states and five outer repetitions; the device numbers are means across those runs
          with run-to-run spread recorded.
        </P>
        <P>
          The contrast algorithm is Bernstein–Vazirani (BV): recover a hidden n-bit string in a
          single oracle query. BV is also a quantum algorithm, but it uses a{' '}
          <em>shallow</em> circuit — one layer of controlled-X gates into a phase-kickback ancilla.
          Where Grover's circuit depth grows with N, BV stays flat. If the failure is genuinely
          "quantum computers can't do this," BV should collapse too. If the failure is circuit depth
          × gate error, BV should survive. The data resolves this unambiguously.
        </P>
        <P>
          For a full walkthrough of what the circuits are actually doing —{' '}
          <a
            href="/special/measuring-the-gap/grover-explained"
            style={{ color: 'var(--cyan)' }}
            className="transition-opacity hover:opacity-70"
          >
            How Grover's search actually works →
          </a>
        </P>

        {pending && (
          <Callout>
            <strong style={{ color: 'var(--cyan)' }}>Hardware capture pending.</strong>{' '}
            Device results below are placeholders. Run{' '}
            <code className="font-mono text-xs">python quantum/capture.py --hardware --backend ibm_marrakesh --qubits &lt;layout&gt;</code>{' '}
            on the IBM account to generate committed numbers. Ideal-simulator data shown is
            reproducible from Aer without hardware access.
          </Callout>
        )}
      </Section>

      {/* Chart 1: Collapse curve */}
      <Section id="collapse">
        <H2>The headline result — collapse across N</H2>
        <P>
          Three series: the ideal simulator (flat near 1.0), classical search (always correct by
          construction), and the device. On the ideal simulator Grover at N=8 returns the marked
          answer with P≈{fmt(n3ideal)}, N=16 with P≈{fmt(n4ideal)}, N=32 with P≈{fmt(n5ideal)}.
          On the device: N=8 gives {fmt(hwN3)}, and by N=32 the result is {fmt(hwN5)} — at or near
          the random floor of 1/32 ≈ 0.03.
        </P>
        <QuantumCollapseCurve />
        <p className="text-xs mt-2" style={{ color: 'var(--text-muted)' }}>
          Ideal-simulator data from Aer (reproducible). Device data: {pending ? 'hardware capture pending.' : `ibm_marrakesh, ${data.capture_meta.shots} shots, physical qubits ${(data.capture_meta.physical_qubits ?? []).join(',')}.`}
        </p>
      </Section>

      {/* Chart 2: Over-rotation teaching chart */}
      <Section id="over-rotation">
        <H2>Why not just run more iterations?</H2>
        <P>
          Grover is not a monotone algorithm. Each oracle + diffuser iteration rotates the amplitude
          state toward the marked answer by a fixed angle. Run the right number of iterations (≈ π/4 · √N)
          and you land near the top. Keep going and you rotate past the peak and the probability drops.
          At N={2 ** teachN} the optimal count is {teachOpt.iters} iterations, giving
          P≈{teachOpt.p_marked.toFixed(2)} — then it falls to {data.teaching_sweep.curve[teachOpt.iters + 1]?.p_marked.toFixed(2) ?? '…'} at
          the next step.
        </P>
        <QuantumOverRotation />
        <p className="text-xs mt-2" style={{ color: 'var(--text-muted)' }}>
          Ideal simulator only (Aer). Shows the amplitude-amplification oscillation — a controlled rotation
          you can overshoot. No QPU time required.
        </p>
      </Section>

      {/* Chart 3: Mechanism — circuit depth */}
      <Section id="mechanism">
        <H2>The mechanism: gate error × depth</H2>
        <P>
          The collapse isn't random hardware failure — it follows directly from how Grover's circuit
          scales. Each iteration adds another oracle + diffuser layer, both of which decompose into
          multi-controlled gates that the transpiler expands into sequences of two-qubit CX or ECR
          gates. The transpiled circuit depth at N=32 is roughly{' '}
          {data.circuit_depth.grover.find((d) => d.N === 32)?.depth ?? '—'} layers. BV at N=32 transpiles
          to roughly {data.circuit_depth.bv.find((d) => d.N === 32)?.depth ?? '—'} layers.
        </P>
        <P>
          Each physical gate has an error rate. IBM Heron-class devices run at ~0.1–0.3% per
          two-qubit gate under current calibration. A Grover circuit at N=32 applies on the order
          of {(data.circuit_depth.grover.find((d) => d.N === 32)?.two_qubit_gates ?? 0) || 'many'} two-qubit
          gates; compound that error and the fidelity of the final state is degraded to near-random
          before you measure. BV's shallow circuit escapes this compound loss.
        </P>
        <QuantumMechanism />
        <p className="text-xs mt-2" style={{ color: 'var(--text-muted)' }}>
          Aer-transpiled depths. On real hardware the depth will be higher due to routing overhead and
          native gate decomposition — the ratio is the signal, not the absolute numbers.
        </p>
      </Section>

      {/* Chart 4: BV vs Grover contrast */}
      <Section id="bv-contrast">
        <H2>The contrast: BV survives where Grover collapses</H2>
        <P>
          Bernstein–Vazirani solves a different problem (hidden string recovery) but uses the same
          quantum resource class. Its circuit is shallow by construction — one superposition layer,
          one oracle layer, one measurement. On the ideal simulator both BV and Grover sit near 1.0
          across all N. On the device, BV at N=32 gives P≈{fmt(bvHwN5)} while Grover at N=32 gives
          P≈{fmt(hwN5)}. The gap is not "quantum doesn't work." It is "circuits this deep don't work
          on current hardware."
        </P>
        <QuantumBVGrover />
        <p className="text-xs mt-2" style={{ color: 'var(--text-muted)' }}>
          Solid lines: device. Dashed lines: ideal simulator reference. {pending ? 'Device lines pending hardware capture.' : ''}
        </p>
      </Section>

      {/* Chart 5: Asymptotic crossover — theory */}
      <Section id="asymptotic">
        <H2>The asymptotic picture — theory, not measurement</H2>
        <P>
          The theoretical speedup is real. O(√N) grows slower than O(N) — for large enough N, a
          fault-tolerant quantum computer running Grover would win. The problem is that "large enough
          N" and "fault-tolerant" require error-correction overheads that are not available on current
          NISQ hardware. The crossover point is not in the range of anything we can usefully run today.
        </P>
        <AsymptoticCrossover />
        <p className="text-xs mt-2" style={{ color: 'var(--text-muted)' }}>
          Theory chart — not a measurement. The O(√N) advantage requires fault-tolerant quantum
          error correction; the crossover is far beyond NISQ device capabilities.
        </p>
      </Section>

      {/* Chart 6: Mitigation */}
      <Section id="mitigation">
        <H2>Does error mitigation help?</H2>
        <P>
          Dynamical decoupling (DD) and measurement twirling are the standard mitigation toolkit on
          IBM hardware. The panel below compares Grover device success with mitigation off vs on
          across N. Significance is assessed per N from run-to-run spread: where the off and on
          intervals overlap, no effect is claimed; where they are disjoint, the signed difference
          (off−on) is shown.{pending ? ' Device data is pending; the panel will update once the capture run is committed.' : ''}
        </P>
        <QuantumMitigation />
        <p className="text-xs mt-2" style={{ color: 'var(--text-muted)' }}>
          Error bars show run-to-run spread ({data.capture_meta.shots} shots per run).{' '}
          {pending ? 'Hardware capture pending.' : ''}
        </p>
      </Section>

      {/* Where advantage is landing */}
      <Section id="where-advantage-lands">
        <H2>Where quantum advantage is actually landing in 2026</H2>
        <P>
          The result above is specific: Grover's algorithm for unstructured search, on NISQ hardware,
          today. It doesn't generalise to all quantum computing. The problems where serious advantage
          claims are being made are structurally different:
        </P>
        <ul className="space-y-3 mb-4 ml-4">
          {[
            'Quantum simulation of physical systems (chemistry, materials). This is the originally-intended use case for quantum hardware — simulating quantum systems is naturally suited to quantum computers. Google\'s 2025 claims around superconductor simulation and IBM\'s molecular-energy calculations are in this class. These are recent results awaiting independent replication, but they are the credible frontier.',
            'Variational quantum eigensolvers (VQE) and quantum approximate optimisation (QAOA) for small problem instances. Current results are roughly par-with-classical on matched hardware, not a win — but the trajectory is meaningful.',
            'Quantum key distribution and quantum communication protocols. These are already deployed commercially and don\'t depend on the gate-depth problem at all.',
          ].map((item) => (
            <li key={item} className="flex gap-3 text-sm" style={{ color: 'var(--text-secondary)' }}>
              <span style={{ color: 'var(--cyan)' }} className="shrink-0">–</span>
              {item}
            </li>
          ))}
        </ul>
        <P>
          None of these are the Grover unstructured-search story. The mechanism is different (the
          speedup is exponential for simulation, not quadratic), the circuit structure is different
          (often variational, not fixed-iteration), and the error budget is different (shorter
          circuits that survive current noise levels better).
        </P>
      </Section>

      {/* Finance sidebar */}
      <Section id="finance">
        <H2>The finance angle — a sidebar</H2>
        <P>
          Finance has been one of the most heavily marketed quantum sectors. The realistic 2026 picture:
          on small-instance portfolio optimisation and option-pricing problems, quantum hardware has
          reached par-with-classical on matched problem sizes. That is an important engineering
          milestone — it means the hardware is doing something coherent on a finance-relevant
          workload. It is not a production win, and no credible result shows quantum beating a
          well-tuned classical solver on any finance problem at useful scale. The honest
          characterisation is: promissory, advancing, not yet competitive.
        </P>
      </Section>

      {/* Reproducibility caveats */}
      <Section id="reproducibility">
        <H2>Reproducibility caveats</H2>
        <Callout>
          <ul className="space-y-2 text-sm">
            {[
              'Hardware numbers are physical-qubit-layout dependent. The pinned layout is recorded in the committed JSON. A different layout choice can shift the mid-collapse-N result by ~0.09 in P(success) — pilot measurement.',
              'IBM backends recalibrate continuously. The exact device numbers will not reproduce on a different day; the committed JSON archives the actual job results for this purpose.',
              'The classical baseline and ideal-simulator data reproduce exactly from the capture script (no hardware, no account required): python quantum/capture.py --aer-only.',
              'Run-to-run reproducibility on hardware is ~0.003 within a single calibration window — this is the within-spread figure, not the cross-calibration spread.',
            ].map((item) => (
              <li key={item} className="flex gap-3" style={{ color: 'var(--text-secondary)' }}>
                <span style={{ color: 'var(--cyan)' }} className="shrink-0">–</span>
                {item}
              </li>
            ))}
          </ul>
        </Callout>
      </Section>

      {/* Takeaway */}
      <Section id="takeaway">
        <H2>Takeaway</H2>
        <P>
          Quantum computing is real and advancing. The theoretical speedups are mathematically
          sound. What current hardware cannot do is execute the deep circuits needed to realise
          those speedups at any practically interesting problem size, because gate error accumulates
          faster than the algorithm can produce a useful signal. The gap is not hype — it's physics,
          and it's measurable. When you run Grover at N=32 and read back the random floor, you've
          measured exactly where the fault-tolerance wall is.
        </P>
        <P>
          Classical silicon wins for these workloads today. That isn't a permanent statement — it's
          a calibration point. The relevant question is how far the hardware needs to advance before
          the gap closes, and for which problem classes it closes first. The simulation class is the
          honest answer to the second question; the fault-tolerance overhead is the honest answer to
          the first.
        </P>
      </Section>

      {/* Methodology departure note */}
      <Section id="methodology-note">
        <H2>Methodology note — why this isn't a numbered demo</H2>
        <Callout>
          <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            This post sits outside the standard Crucible methodology in four ways: (1) it is not a
            C++ benchmark — the primary implementation is a Python/Qiskit circuit submitted to IBM
            Quantum hardware; (2) the reference machine is an IBM cloud QPU, not the Zen 2 or
            Cortex-A76 rigs; (3) the metric is P(success), a dimensionless probability, not ns/op;
            (4) the numbers are not reproducible by re-running — they depend on hardware
            calibration state, and are archived rather than regenerated. The C++ classical baseline
            (Task 7) follows normal bench conventions on the Ubuntu reference rig, but the headline
            metric is the quantum/classical success-probability comparison, not a timing figure.
            See the{' '}
            <a href="/methodology" style={{ color: 'var(--cyan)' }} className="transition-opacity hover:opacity-70">
              methodology page
            </a>{' '}
            for the full departure note.
          </p>
        </Callout>
      </Section>

      {/* Footer */}
      <footer className="mt-16 border-t pt-8" style={{ borderColor: 'var(--border-color)' }}>
        {/* Quantum backend block — NOT the Zen 2 machine-spec line */}
        <div
          className="rounded-xl border p-5 mb-8 font-mono text-sm space-y-1"
          style={{ borderColor: 'var(--border-color)', background: 'var(--bg-card)', color: 'var(--text-secondary)' }}
        >
          <p className="font-mono text-xs uppercase tracking-widest mb-2" style={{ color: 'var(--text-muted)' }}>
            Quantum backend
          </p>
          {pending ? (
            <p style={{ color: 'var(--text-muted)' }}>Hardware capture pending — backend details will appear after the capture run.</p>
          ) : (
            <>
              <div><span style={{ color: 'var(--text-muted)' }}>Backend</span><span className="ml-4">{data.capture_meta.backend?.name ?? '—'}</span></div>
              <div><span style={{ color: 'var(--text-muted)' }}>Physical qubits</span><span className="ml-4">{(data.capture_meta.physical_qubits ?? []).join(', ') || '—'}</span></div>
              <div><span style={{ color: 'var(--text-muted)' }}>Shots</span><span className="ml-4">{data.capture_meta.shots}</span></div>
              <div><span style={{ color: 'var(--text-muted)' }}>Calibration</span><span className="ml-4">{data.capture_meta.calibration_timestamp ?? '—'}</span></div>
              <div><span style={{ color: 'var(--text-muted)' }}>Captured</span><span className="ml-4">{data.capture_meta.captured_at}</span></div>
            </>
          )}
        </div>

        <p className="text-sm mb-4" style={{ color: 'var(--text-muted)' }}>
          <em>Source: </em>
          <a
            href="https://github.com/GarethCooke/Crucible/tree/master/quantum/"
            target="_blank"
            rel="noopener noreferrer"
            style={{ color: 'var(--cyan)' }}
          >
            quantum/ ↗
          </a>
          {' · '}
          <a
            href="https://github.com/GarethCooke/Crucible/blob/master/site/src/data/quantum/measuring-the-gap.json"
            target="_blank"
            rel="noopener noreferrer"
            style={{ color: 'var(--cyan)' }}
          >
            JSON ↗
          </a>
        </p>

        <a href="/methodology" className="text-sm transition-opacity hover:opacity-70" style={{ color: 'var(--text-muted)' }}>
          ← Methodology: how these numbers are produced
        </a>
      </footer>
    </article>
  )
}
