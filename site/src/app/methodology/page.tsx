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

      {/* ── Reference machines ────────────────────────────────────────────── */}
      <h2
        id="reference-machine"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-4"
        style={{ color: "var(--text-muted)" }}
      >
        Reference machines
      </h2>

      {/* Machine 1: Zen 2 */}
      <p
        className="font-mono text-xs uppercase tracking-widest mb-2"
        style={{ color: "var(--text-muted)" }}
      >
        Machine 1 — x86-64 (demos 1–8)
      </p>
      <div
        className="rounded-xl border p-5 mb-4 font-mono text-sm space-y-1"
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
            isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7; benchmarks pin to cores
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
      <p className="text-sm mb-8" style={{ color: "var(--text-muted)" }}>
        Zen 2 implements 256-bit AVX2 as two 128-bit µops — called out
        explicitly in any SIMD post. Full{" "}
        <code>lscpu --extended</code> output,
        kernel version, and compiler version are committed to the repo alongside
        each benchmark result.
      </p>

      {/* Machine 2: Pi 5 / Cortex-A76 */}
      <p
        className="font-mono text-xs uppercase tracking-widest mb-2"
        style={{ color: "var(--text-muted)" }}
      >
        Machine 2 — AArch64 (demo 9+)
      </p>
      <div
        className="rounded-xl border p-5 mb-4 font-mono text-sm space-y-1"
        style={{
          borderColor: "var(--border-color)",
          background: "var(--bg-card)",
          color: "var(--text-secondary)",
        }}
      >
        <div>
          <span style={{ color: "var(--text-muted)" }}>CPU</span>{" "}
          <span className="ml-4">
            Cortex-A76 (BCM2712) — 4 cores, AArch64, NEON baseline ISA, no SVE
          </span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>Board</span>{" "}
          <span className="ml-4">Raspberry Pi 5 Model B Rev 1.1</span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>RAM</span>{" "}
          <span className="ml-4">4 GB LPDDR4X</span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>OS</span>{" "}
          <span className="ml-4">Raspberry Pi OS (64-bit)</span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>Boot</span>{" "}
          <span className="ml-4">
            isolcpus=2,3 in kernel cmdline; benchmarks pinned to core 3 via
            taskset -c 3; IRQ affinity redirected off cores 2–3
          </span>
        </div>
        <div>
          <span style={{ color: "var(--text-muted)" }}>Clock</span>{" "}
          <span className="ml-4">
            governor = performance; clock pinned at 2400 MHz (MAXMHZ);
            get_throttled = 0x0 verified (no CPU throttling) — replaces the
            Zen 2 BIOS turbo-disable with a clock-pin approach
          </span>
        </div>
        <div
          className="pt-2 border-t"
          style={{ borderColor: "var(--border-color)" }}
        >
          <span style={{ color: "var(--text-muted)" }}>ISA</span>{" "}
          <span className="ml-4">
            AArch64 · NEON (128-bit) ·{" "}
            <strong style={{ color: "var(--text-primary)" }}>no SVE</strong>
          </span>
        </div>
      </div>
      <p className="text-sm mb-12" style={{ color: "var(--text-muted)" }}>
        Cross-machine absolute ns/op comparisons are never made between Machine 1
        and Machine 2 — different clocks, compilers, and memory subsystems make
        them meaningless. The only portable quantity across machines is the
        within-machine speedup ratio. Full <code>lscpu --extended</code> output,
        kernel version, and compiler version are committed alongside each
        benchmark result.
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
          <p>
            Core Performance Boost is disabled in BIOS, pinning the cores to
            their 3900 MHz base clock. Boost state is{" "}
            <em>measured from the kernel</em>, never asserted: each capture
            reads the per-CPU <code>cpb</code> flag (
            <code>/sys/devices/system/cpu/cpu*/cpufreq/cpb</code>) —
            authoritative on this AMD <code>acpi-cpufreq</code> board — and
            cross-checks it against the top entry of{" "}
            <code>scaling_available_frequencies</code>. The result and the
            signal it came from are recorded in every JSON as{" "}
            <code>machine.turbo</code> and <code>machine.turbo_source</code>.
            A hard capture-time gate aborts the run before any benchmark
            executes if boost is detected as enabled, so a boosted capture
            cannot be taken silently.
          </p>
          <p className="mt-2">
            <code>cpuinfo_max_freq</code> / <code>lscpu</code> MAXMHZ is{" "}
            <strong>not</strong> used to infer boost state: on this board it
            reports the silicon&rsquo;s 4560 MHz ceiling whether or not boost
            is enabled, so it is recorded as{" "}
            <code>machine.freq_max_advertised_mhz</code> (advisory) while{" "}
            <code>machine.freq_max_available_mhz</code> — the highest real
            P-state, 3900 MHz with boost off — is the value that tracks
            state. Where no boost signal is exposed (e.g. the AArch64 rig),{" "}
            <code>machine.turbo</code> is recorded as <code>null</code> rather
            than guessed. Boost obscures the true steady-state throughput the
            predictor and cache hierarchy deliver at nominal frequency.
          </p>
          <p className="mt-2">
            <em>
              An earlier version of this pipeline derived turbo state from an
              environment variable rather than measuring it; see{" "}
              <a href="#corrections" style={{ color: "var(--cyan)" }}>
                Corrections
              </a>
              .
            </em>
          </p>
        </Commitment>
        <Commitment n={3} title="Core isolation">
          Cores 1–7 are isolated at the kernel level via{" "}
          <code>isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7</code> boot parameters
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
          demo&rsquo;s JSON <code>machine.isolated_cpus</code> field. On
          Machine 2 isolation uses <code>isolcpus=2,3</code> in the Pi kernel
          cmdline with benchmarks pinned to core 3 via{" "}
          <code>taskset -c 3</code>; the A76 exposes no SMT to disable. See
          Machine 2 above.
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
              <strong>Throughput / steady-state median</strong> (demos 1, 2, 3, 9):
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
              <strong>Working-set sweep</strong> (demos 6, 7, 8):
              5 outer repetitions per cell; median <code>ns_per_op</code> reported.
              Sweep coverage substitutes for higher per-cell rep count.
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
      <p className="text-sm mb-4" style={{ color: "var(--text-secondary)" }}>
        <code>run_one.sh</code> requires <code>sudo</code> and the{" "}
        <code>cpuset</code> package (<code>sudo apt install cpuset</code> on
        Ubuntu); it runs the benchmark binary inside a <code>cset shield</code>{" "}
        on cores 4–7 and tears the shield down automatically. On Machine 2 (the
        Pi 5) <code>cset</code> is not used — Raspberry Pi OS is cgroup v2,
        which <code>cset</code> does not target; AArch64 demos isolate with{" "}
        <code>isolcpus=2,3</code> at boot and pin with{" "}
        <code>taskset -c 3</code>, as documented in each demo&rsquo;s README.
      </p>
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

      {/* ── Special editions — methodology departure ──────────────────────── */}
      <h2
        id="special-editions"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-4"
        style={{ color: "var(--text-muted)" }}
      >
        Special editions
      </h2>
      <p className="text-sm mb-4" style={{ color: "var(--text-secondary)" }}>
        Occasional posts sit outside the standard methodology. They are not counted
        as numbered demos and do not affect the four commitments above. Each departure
        is documented here and in the post itself.
      </p>
      <div
        className="rounded-xl border p-5 mb-12"
        style={{ borderColor: "var(--border-color)", background: "var(--bg-card)" }}
      >
        <div className="flex items-center gap-3 mb-3">
          <a
            href="/special/measuring-the-gap"
            className="font-sans font-semibold text-sm transition-opacity hover:opacity-70"
            style={{ color: "var(--text-primary)" }}
          >
            Measuring the Gap — Grover&rsquo;s algorithm on real quantum hardware
          </a>
          <span
            className="font-mono text-xs px-2 py-0.5 rounded border shrink-0"
            style={{ color: "var(--cyan)", borderColor: "var(--cyan)", opacity: 0.7 }}
          >
            special edition
          </span>
        </div>
        <ul className="space-y-1.5">
          {[
            "Not a C++ benchmark — primary implementation is Python/Qiskit on IBM Quantum cloud hardware.",
            "Reference machine is an IBM QPU, not the Zen 2 or Cortex-A76 rigs.",
            "Metric is P(success), a dimensionless probability, not ns/op.",
            "Numbers are not reproducible by re-running — calibration changes. Committed JSON archives the job results.",
            "NOT counted in the numbered demo total. The demo count is unchanged.",
          ].map((item) => (
            <li key={item} className="flex gap-3 text-sm" style={{ color: "var(--text-secondary)" }}>
              <span style={{ color: "var(--cyan)" }} className="shrink-0">–</span>
              {item}
            </li>
          ))}
        </ul>
      </div>

      {/* ── Corrections ───────────────────────────────────────────────────── */}
      <h2
        id="corrections"
        className="font-sans font-semibold text-sm uppercase tracking-widest mb-4"
        style={{ color: "var(--text-muted)" }}
      >
        Corrections
      </h2>
      <div
        className="rounded-xl border p-5 mb-12 text-sm space-y-3"
        style={{
          borderColor: "var(--border-color)",
          background: "var(--bg-card)",
          color: "var(--text-secondary)",
        }}
      >
        <p>
          <strong style={{ color: "var(--text-primary)" }}>
            2026-06-06 &mdash; Boost-state verification in the original Machine 1 corpus.
          </strong>
        </p>
        <p>
          The benchmarks for demos 01&ndash;08, as originally published,
          carried a <code>machine.turbo</code> field that was not a real
          measurement: it was echoed from an operator-set environment variable
          (<code>CRUCIBLE_TURBO</code>) rather than read from hardware, so the
          corpus&rsquo;s boost state was in effect unverified. The{" "}
          <code>lscpu</code> output committed alongside each result showed the
          4560 MHz boost <em>ceiling</em> &mdash; but on this AMD{" "}
          <code>acpi-cpufreq</code> board that ceiling is reported whether or
          not boost is active, so it neither confirmed nor refuted the
          &ldquo;turbo off&rdquo; claim.
        </p>
        <p>
          We rebuilt boost detection to read real kernel sysfs signals (the
          per-CPU <code>cpb</code> flag, cross-checked against the
          available-frequency list), added a hard capture-time gate that aborts
          if boost is enabled, and recaptured the entire Machine 1 corpus at a
          confirmed 3900 MHz base clock.
        </p>
        <p>
          <strong style={{ color: "var(--text-primary)" }}>
            Effect on results.
          </strong>{" "}
          The recaptured figures round-trip to within 1% of the originals
          &mdash; the compute-bound demos (01, 03, 08) reproduce exactly
          &mdash; which confirms the original captures were already running at
          base clock and the published numbers were accurate. The same-session
          speedup ratios each post is built on were unchanged throughout. Two
          posts, demos 04 and 06, required prose corrections unrelated to
          clock &mdash; demo 04&rsquo;s over-saturation section described
          single-draw queue behaviour; re-derivation replaced it with a
          bistability finding showing each process run settles into one of two
          stable queue-depth equilibria; demo 06&rsquo;s DRAM-band
          non-monotonic dip was attributed to a microarchitectural
          TLB/huge-page interaction; the recapture produced a near-flat band,
          reclassifying the dip as a capture-specific page-placement artifact
          &mdash; while their underlying ratios were intact. Demo 02&rsquo;s
          L1 cache counter (<code>l1d.replacement</code>) returned null in all
          twelve original runs and was never cited in the post; the recapture
          substitutes <code>L1-dcache-load-misses</code>, with no numeric
          impact.
        </p>
        <p>
          The raw <code>lscpu</code> capture committed alongside every result
          is what made this auditable: the underlying data was honest even
          where the derived field was not. The detection logic that replaced it
          is described under{" "}
          <a href="#commitments" style={{ color: "var(--cyan)" }}>
            Turbo Boost disabled
          </a>{" "}
          above.
        </p>
      </div>

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
