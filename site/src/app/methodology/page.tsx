import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Methodology',
  description: 'How Crucible benchmarks are run, measured, and reported.',
}

function Commitment({ n, title, children }: { n: number; title: string; children: React.ReactNode }) {
  return (
    <div className="flex gap-5 py-5 border-b" style={{ borderColor: 'var(--border-color)' }}>
      <span
        className="font-mono text-2xl font-bold shrink-0 w-8 pt-0.5 leading-none"
        style={{ color: 'var(--cyan)' }}
      >
        {n}
      </span>
      <div>
        <h3 className="font-sans font-semibold mb-1" style={{ color: 'var(--text-primary)' }}>
          {title}
        </h3>
        <p className="text-sm leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
          {children}
        </p>
      </div>
    </div>
  )
}

function Ref({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <li>
      <a
        href={href}
        target="_blank"
        rel="noopener noreferrer"
        className="text-sm transition-opacity hover:opacity-70"
        style={{ color: 'var(--cyan)' }}
      >
        {children} ↗
      </a>
    </li>
  )
}

export default function MethodologyPage() {
  return (
    <div className="max-w-2xl fu">
      <p className="font-mono text-xs uppercase tracking-widest mb-3" style={{ color: 'var(--cyan)' }}>
        Methodology
      </p>
      <h1 className="font-sans text-3xl font-semibold tracking-tight mb-4" style={{ color: 'var(--text-primary)' }}>
        How the numbers are produced
      </h1>
      <p className="text-base leading-relaxed mb-12" style={{ color: 'var(--text-secondary)' }}>
        Published benchmark results are only credible with a documented, reproducible methodology.
        All measurements on this site satisfy the four non-negotiable commitments below.
      </p>

      {/* ── Reference machine ─────────────────────────────────────────────── */}
      <h2 className="font-sans font-semibold text-sm uppercase tracking-widest mb-4" style={{ color: 'var(--text-muted)' }}>
        Reference machine
      </h2>
      <div
        className="rounded-xl border p-5 mb-12 font-mono text-sm space-y-1"
        style={{ borderColor: 'var(--border-color)', background: 'var(--bg-card)', color: 'var(--text-secondary)' }}
      >
        <div><span style={{ color: 'var(--text-muted)' }}>CPU</span>       <span className="ml-4">AMD Ryzen 7 3800X — 8 cores / 16 threads, Zen 2</span></div>
        <div><span style={{ color: 'var(--text-muted)' }}>RAM</span>       <span className="ml-4">32 GB DDR4-3200</span></div>
        <div><span style={{ color: 'var(--text-muted)' }}>Board</span>     <span className="ml-4">ASUS ROG STRIX B550-F GAMING</span></div>
        <div><span style={{ color: 'var(--text-muted)' }}>OS</span>        <span className="ml-4">Ubuntu Server LTS (dual-boot)</span></div>
        <div><span style={{ color: 'var(--text-muted)' }}>Boot</span>      <span className="ml-4">No core-isolation params — cset shield applied per-benchmark</span></div>
        <div><span style={{ color: 'var(--text-muted)' }}>BIOS</span>      <span className="ml-4">Core Performance Boost disabled, SMT disabled</span></div>
        <div className="pt-2 border-t" style={{ borderColor: 'var(--border-color)' }}>
          <span style={{ color: 'var(--text-muted)' }}>ISA</span>
          <span className="ml-4">SSE4.2 · AVX · AVX2 · FMA · <strong style={{ color: 'var(--text-primary)' }}>no AVX-512</strong></span>
        </div>
      </div>
      <p className="text-sm mb-6" style={{ color: 'var(--text-muted)' }}>
        Zen 2 implements 256-bit AVX2 as two 128-bit µops — called out explicitly in any SIMD post.
        Full <code style={{ color: 'var(--cyan)' }}>lscpu --extended</code> output, kernel version, and
        compiler version are committed to the repo alongside each benchmark result.
      </p>
      <p className="text-sm mb-12" style={{ color: 'var(--text-muted)' }}>
        <strong style={{ color: 'var(--text-secondary)' }}>Boot parameters.</strong>{' '}
        No core-isolation boot parameters are committed (<code>isolcpus=</code>,{' '}
        <code>nohz_full=</code>, <code>rcu_nocbs=</code> are all unset). Demos with hard
        tail-latency claims (sub-microsecond p99.9) may introduce <code>nohz_full=</code> at
        that point, with each addition documented in that demo&rsquo;s methodology notes
        alongside the data it is needed for.
      </p>

      {/* ── Four commitments ──────────────────────────────────────────────── */}
      <h2 className="font-sans font-semibold text-sm uppercase tracking-widest mb-2" style={{ color: 'var(--text-muted)' }}>
        Four non-negotiable commitments
      </h2>
      <div className="mb-12">
        <Commitment n={1} title="CPU governor pinned to performance">
          Every benchmark run begins with <code>cpupower frequency-set -g performance</code>.
          Frequency scaling during a measurement run is a leading cause of variance that makes
          numbers look better or worse than they really are.
        </Commitment>
        <Commitment n={2} title="Turbo Boost disabled">
          Core Performance Boost is disabled in BIOS and verified via{' '}
          <code>/sys/devices/system/cpu/cpufreq/boost</code> (reads&nbsp;0) before each run.
          Boost obscures the true steady-state throughput the predictor and cache hierarchy
          deliver at nominal frequency.
        </Commitment>
        <Commitment n={3} title="Core isolation">
          Core isolation is applied per-benchmark via <code>cset shield</code>, not via
          persistent <code>isolcpus=</code> boot parameters. The reference machine is
          dual-purpose — it dual-boots Windows, and the Ubuntu install is used for things
          other than benchmarking — so permanent kernel-level isolation would penalise normal
          use and is the kind of configuration that&rsquo;s easy to forget about and hard to
          debug six months later. <code>cset shield --cpu=0-7</code> is invoked by the
          per-demo wrapper scripts immediately before the benchmark binary runs and reset
          (<code>cset shield --reset</code>) immediately after, providing isolation during the
          measurement window and nothing more.
          <br /><br />
          The tradeoff: <code>cset shield</code> is a best-effort migration at shield time,
          not a kernel-enforced exclusion. Tasks already pinned to a shielded cpu, kernel
          threads that can&rsquo;t be moved, and tasks that spawn during the run can still
          appear on benchmark cores. Within a single run this is negligible — CV across 11
          repetitions is typically under 0.3%. Across separate runs, cpus that pick up
          ambient kernel activity (notably cpu 0, which holds the system timer and other
          unmovable work) can drift by a few percent. Where this matters for sanity
          assertions we use measurements that are robust to that drift, typically by running
          enough contending threads that the silicon-level signal dominates over background
          noise. IRQ affinity is steered to non-shielded cores via{' '}
          <code>/proc/irq/*/smp_affinity</code> by the wrapper script. SMT is disabled at
          the BIOS level — verified via <code>/sys/devices/system/cpu/smt/active</code>{' '}
          returning <code>0</code> and <code>lscpu</code> reporting 8 CPUs — to remove
          SMT-sibling resource sharing (L1, L2, execution ports, frontend) from all
          measurements. Exact shielded core IDs are recorded in each demo&rsquo;s JSON{' '}
          <code>machine.isolated_cores</code> field.
          <br /><br />
          <strong style={{ color: 'var(--text-secondary)' }}>Cross-CCX results.</strong>{' '}
          Runs that span both CCXs (cores 0–3 and 4–7) are categorised as{' '}
          <em>exploratory</em> rather than publication-grade. Cores 0–3 are not
          permanently isolated — cpu 0 in particular carries the system timer and other
          unmovable kernel work that <code>cset shield</code> cannot evict. Cross-CCX
          measurements therefore carry higher ambient noise than intra-CCX measurements and
          should be read as directional signal only. Publication-grade cross-CCX data would
          require <code>isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7</code> as persistent boot
          parameters, which is deferred until a dedicated benchmark machine is available.
          Every post labels cross-CCX results accordingly.
        </Commitment>
        <Commitment n={4} title="Statistical reporting">
          Each benchmark runs ≥20 repetitions after warmup. Every chart states which statistic
          it shows:
          <ul className="mt-2 space-y-1 list-disc list-inside">
            <li><strong>Median</strong> — typical-case latency</li>
            <li><strong>Min</strong> — best the hardware can do (cache warm, predictor trained)</li>
            <li><strong>p99 / p99.9</strong> — tail-latency claims</li>
            <li><strong>IQR</strong> — spread around the median</li>
          </ul>
        </Commitment>
      </div>

      {/* ── Best practice items ───────────────────────────────────────────── */}
      <h2 className="font-sans font-semibold text-sm uppercase tracking-widest mb-4" style={{ color: 'var(--text-muted)' }}>
        Additional best-practice items
      </h2>
      <ul className="space-y-2 mb-12">
        {[
          'Inputs are runtime-loaded (not compile-time-known) to defeat constant folding.',
          'Outputs are sunk via benchmark::DoNotOptimize to prevent dead-code elimination.',
          'Inputs are shuffled between iterations where branch-predictor memorisation would distort results.',
          'Allocations are kept out of hot paths; data structures are built in benchmark setup.',
          'Machine spec, kernel version, compiler version, and lscpu output are committed to the repo.',
        ].map((item) => (
          <li key={item} className="flex gap-3 text-sm" style={{ color: 'var(--text-secondary)' }}>
            <span style={{ color: 'var(--cyan)' }} className="shrink-0">–</span>
            {item}
          </li>
        ))}
      </ul>

      {/* ── References ────────────────────────────────────────────────────── */}
      <h2 className="font-sans font-semibold text-sm uppercase tracking-widest mb-4" style={{ color: 'var(--text-muted)' }}>
        References
      </h2>
      <ul className="space-y-2">
        <Ref href="https://www.youtube.com/watch?v=nXaxk27zwlk">
          Chandler Carruth — Tuning C++: Benchmarks, and CPUs, and Compilers! Oh My! (CppCon 2015)
        </Ref>
        <Ref href="https://www.agner.org/optimize/">
          Agner Fog — Optimisation manuals
        </Ref>
        <Ref href="https://brendangregg.com">
          Brendan Gregg — Systems performance writing
        </Ref>
      </ul>
    </div>
  )
}
