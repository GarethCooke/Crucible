import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Methodology",
  description: "How Crucible benchmarks are run, measured, and reported.",
};

function Commitment({
  n,
  title,
  children,
}: {
  n: number;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div
      className="flex gap-5 py-5 border-b"
      style={{ borderColor: "var(--border-color)" }}
    >
      <span
        className="font-mono text-2xl font-bold shrink-0 w-8 pt-0.5 leading-none"
        style={{ color: "var(--cyan)" }}
      >
        {n}
      </span>
      <div>
        <h3
          className="font-sans font-semibold mb-1"
          style={{ color: "var(--text-primary)" }}
        >
          {title}
        </h3>
        <div
          className="text-sm leading-relaxed"
          style={{ color: "var(--text-secondary)" }}
        >
          {children}
        </div>
      </div>
    </div>
  );
}

function Ref({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <li>
      <a
        href={href}
        target="_blank"
        rel="noopener noreferrer"
        className="text-sm transition-opacity hover:opacity-70"
        style={{ color: "var(--cyan)" }}
      >
        {children} ↗
      </a>
    </li>
  );
}

export default function MethodologyPage() {
  return (
    <div className="max-w-2xl prose prose-invert fu">
      <p
        className="font-mono text-xs uppercase tracking-widest mb-3"
        style={{ color: "var(--cyan)" }}
      >
        Methodology
      </p>
      <h1
        className="font-sans text-3xl font-semibold tracking-tight mb-4"
        style={{ color: "var(--text-primary)" }}
      >
        How the numbers are produced
      </h1>
      <p
        className="text-base leading-relaxed mb-12"
        style={{ color: "var(--text-secondary)" }}
      >
        Published benchmark results are only credible with a documented,
        reproducible methodology. All measurements on this site satisfy the four
        non-negotiable commitments below.
      </p>

      {/* ── Reference machine ─────────────────────────────────────────────── */}
      <h2
        id="reference-machine"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-4"
        style={{ color: "var(--text-muted)" }}
      >
        Reference machine
      </h2>
      <div
        className="rounded-xl border p-5 mb-12 font-mono text-sm space-y-1"
        style={{
          borderColor: "var(--border-color)",
          background: "var(--bg-card)",
          color: "var(--text-secondary)",
        }}
      >
        <div>
          <span style={{ color: "var(--text-muted)" }}>CPU</span>{" "}
          <span className="ml-4">
            AMD Ryzen 7 3800X (Zen 2) — 8C/16T silicon, SMT disabled, 8 logical
            CPUs exposed during benchmarks
          </span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>RAM</span>{" "}
          <span className="ml-4">32 GB DDR4-3200</span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>Board</span>{" "}
          <span className="ml-4">ASUS ROG STRIX B550-F GAMING</span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>OS</span>{" "}
          <span className="ml-4">Ubuntu Server LTS (dual-boot)</span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>Mode</span>{" "}
          <span className="ml-4">
            Headless boot — no display server, no graphical desktop. Eliminates
            compositor and display-server noise from measurements.
          </span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>Boot</span>{" "}
          <span className="ml-4">
            isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7; benchmarks pin to cores
            4–7 via taskset
          </span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>BIOS</span>{" "}
          <span className="ml-4">
            Core Performance Boost disabled, SMT disabled
          </span>
        </div>
        <div
          className="pt-2 border-t"
          style={{ borderColor: "var(--border-color)" }}
        >
          <span style={{ color: "var(--text-muted)" }}>ISA</span>{" "}
          <span className="ml-4">
            SSE4.2 · AVX · AVX2 · FMA ·{" "}
            <strong style={{ color: "var(--text-primary)" }}>no AVX-512</strong>
          </span>
        </div>
      </div>
      <p className="text-sm mb-6" style={{ color: "var(--text-muted)" }}>
        Zen 2 implements 256-bit AVX2 as two 128-bit µops — called out
        explicitly in any SIMD post. Full{" "}
        <code>lscpu --extended</code> output,
        kernel version, and compiler version are committed to the repo alongside
        each benchmark result.
      </p>
      {/* ── Four commitments ──────────────────────────────────────────────── */}
      <h2
        id="commitments"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-2"
        style={{ color: "var(--text-muted)" }}
      >
        Four non-negotiable commitments
      </h2>
      <div className="mb-12">
        <Commitment n={1} title="CPU governor pinned to performance">
          Every benchmark run begins with{" "}
          <code>cpupower frequency-set -g performance</code>. Frequency scaling
          during a measurement run is a leading cause of variance that makes
          numbers look better or worse than they really are.
        </Commitment>
        <Commitment n={2} title="Turbo Boost disabled">
          Core Performance Boost is disabled in BIOS. State is verified by{" "}
          <code>run_one.sh</code> via <code>cpupower frequency-info</code>{" "}
          before any benchmark binary runs; the result is exported as{" "}
          <code>CRUCIBLE_TURBO=off</code> and recorded in the JSON{" "}
          <code>machine.turbo</code> field. If turbo state cannot be determined
          the script exits non-zero rather than silently recording a wrong
          value. Boost obscures the true steady-state throughput the predictor
          and cache hierarchy deliver at nominal frequency.
        </Commitment>
        <Commitment n={3} title="Core isolation">
          Cores 0–7 are isolated at the kernel level via{" "}
          <code>isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7</code> boot parameters
          — scoped to a dedicated GRUB entry (&ldquo;Ubuntu (benchmark &mdash;
          cores 0-7 isolated)&rdquo;) distinct from the standard development
          entry. Within that isolated set, benchmarks are additionally pinned to
          cores 4–7 via <code>taskset</code> (invoked by the per-demo wrapper
          scripts), with cores 0–3 absorbing any residual kernel housekeeping
          the isolation directives cannot redirect. SMT is disabled at the BIOS
          level — verified via <code>/sys/devices/system/cpu/smt/active</code>{" "}
          returning <code>0</code> and <code>lscpu</code> reporting 8 CPUs — to
          remove SMT-sibling resource sharing (L1, L2, execution ports,
          frontend) from all measurements. Isolated CPU IDs are recorded in each
          demo&rsquo;s JSON <code>machine.isolated_cpus</code> field.
          <br />
          <br />
          <strong style={{ color: "var(--text-secondary)" }}>
            Cross-CCX results.
          </strong>{" "}
          Cpu 0 still carries the system timer and other unmovable kernel work
          that <code>isolcpus=</code> cannot fully evict, so cross-CCX
          measurements (cores 0–3 and 4–7 both in the isolated set) carry
          slightly higher ambient noise than intra-CCX measurements and are
          labelled accordingly in every post.
        </Commitment>
        <Commitment n={4} title="Statistical reporting">
          Each benchmark uses one of three rep-count conventions, depending on
          what kind of statistic it reports. Every post&rsquo;s footer states which
          convention it used.
          <ul className="mt-2 mb-3 space-y-1 list-disc list-inside">
            <li>
              <strong>Throughput / steady-state median</strong> (demos 1, 2, 3):
              ≥20 outer repetitions (Google Benchmark{" "}
              <code>--benchmark_repetitions</code>); aggregates computed across
              those repetitions.
            </li>
            <li>
              <strong>Tail-latency distribution</strong> (demos 4, 5): 5 outer
              runs × 1 M timed samples per run through a custom latency pipeline;
              percentiles computed from histograms merged across runs.
            </li>
            <li>
              <strong>Scan-throughput across a working-set sweep</strong> (demo 6):
              5 outer repetitions per cell; median <code>ns_per_op</code> reported.
              Sweep coverage (135 cells) substitutes for higher per-cell rep count.
            </li>
          </ul>
          Every chart states which statistic it shows:
          <ul className="mt-2 space-y-1 list-disc list-inside">
            <li>
              <strong>Median</strong> — typical-case latency
            </li>
            <li>
              <strong>Min</strong> — best the hardware can do (cache warm,
              predictor trained)
            </li>
            <li>
              <strong>p99 / p99.9</strong> — tail-latency claims
            </li>
            <li>
              <strong>IQR</strong> — spread around the median
            </li>
          </ul>
        </Commitment>
      </div>

      {/* ── Best practice items ───────────────────────────────────────────── */}
      <h2
        id="best-practices"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-4"
        style={{ color: "var(--text-muted)" }}
      >
        Additional best-practice items
      </h2>
      <ul className="space-y-2 mb-12">
        {[
          "Inputs are runtime-loaded (not compile-time-known) to defeat constant folding.",
          "Outputs are sunk via benchmark::DoNotOptimize to prevent dead-code elimination.",
          "Inputs are shuffled between iterations where branch-predictor memorisation would distort results.",
          "Allocations are kept out of hot paths; data structures are built in benchmark setup.",
          "Machine spec, kernel version, compiler version, and lscpu output are committed to the repo.",
        ].map((item) => (
          <li
            key={item}
            className="flex gap-3 text-sm"
            style={{ color: "var(--text-secondary)" }}
          >
            <span style={{ color: "var(--cyan)" }} className="shrink-0">
              –
            </span>
            {item}
          </li>
        ))}
      </ul>

      {/* ── Building and reproducing ──────────────────────────────────────── */}
      <h2
        id="building-and-reproducing"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-4"
        style={{ color: "var(--text-muted)" }}
      >
        Building and reproducing
      </h2>
      <p className="text-sm mb-4" style={{ color: "var(--text-secondary)" }}>
        Each demo lives under <code>bench/demos/&lt;NN-slug&gt;/</code> with its
        own <code>README.md</code> documenting the harness, inputs, and any
        demo-specific build flags. Headline captures use the per-demo orchestration
        script under <code>bench/scripts/</code>.
      </p>
      <pre
        className="rounded-lg p-4 text-sm overflow-x-auto mb-3 font-mono"
        style={{ background: "var(--bg-card)", color: "var(--text-secondary)" }}
      >{`git clone https://github.com/GarethCooke/Crucible
cd Crucible/bench
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build --target bench_<NN>_<slug>
./bench/scripts/run_one.sh <NN-slug>`}</pre>
      <p className="text-sm mb-12" style={{ color: "var(--text-secondary)" }}>
        Source on GitHub:{" "}
        <a
          href="https://github.com/GarethCooke/Crucible"
          target="_blank"
          rel="noopener noreferrer"
          style={{ color: "var(--cyan)" }}
        >
          GarethCooke/Crucible ↗
        </a>
        . Each demo&rsquo;s directory has its own README with demo-specific notes;
        this page covers the conventions that apply across all of them.
      </p>

      {/* ── References ────────────────────────────────────────────────────── */}
      <h2
        id="references"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-4"
        style={{ color: "var(--text-muted)" }}
      >
        References
      </h2>
      <ul className="space-y-2">
        <Ref href="https://www.youtube.com/watch?v=nXaxk27zwlk">
          Chandler Carruth — Tuning C++: Benchmarks, and CPUs, and Compilers! Oh
          My! (CppCon 2015)
        </Ref>
        <Ref href="https://www.agner.org/optimize/">
          Agner Fog — Optimisation manuals
        </Ref>
        <Ref href="https://brendangregg.com">
          Brendan Gregg — Systems performance writing
        </Ref>
      </ul>
    </div>
  );
}
