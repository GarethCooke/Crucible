import { readFile } from 'fs/promises'
import path from 'path'
import { ThroughputBarsChart } from './charts/ThroughputBarsChart'
import { LatencyHistogramChart, type LatencyRun } from './charts/LatencyHistogram'

interface BenchmarkProps {
  slug: string
  chart?: 'throughput-bars' | 'latency-histogram'
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  n?: number
  // latency-histogram props
  view?: 'ccdf' | 'pdf'
  markers?: Array<'p50' | 'p99' | 'p99_9'>
}

interface PerfData {
  title: string
  runs: {
    variant: string
    n: number
    ns_per_op: { median: number; min: number; p99: number; iqr: number }
    ops_per_sec: number
    branch_misses_per_op: number
    instructions_per_cycle: number
    latency_ns?: unknown
  }[]
}

export async function Benchmark({
  slug,
  chart = 'throughput-bars',
  variants,
  stat = 'median',
  n,
  view = 'ccdf',
  markers = ['p50', 'p99', 'p99_9'],
}: BenchmarkProps) {
  const filePath = path.join(process.cwd(), 'src/data/perf', `${slug}.json`)
  let data: PerfData

  try {
    const raw = await readFile(filePath, 'utf-8')
    data = JSON.parse(raw) as PerfData
  } catch {
    return (
      <div
        className="my-8 rounded-xl border p-4 text-sm font-mono"
        style={{ borderColor: 'var(--border-color)', color: 'var(--text-muted)' }}
      >
        No benchmark data found for{' '}
        <span style={{ color: 'var(--cyan)' }}>{slug}</span>. Run{' '}
        <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
      </div>
    )
  }

  const runs = variants
    ? data.runs.filter((r) => variants.includes(r.variant))
    : data.runs

  if (runs.length === 0) {
    return (
      <div
        className="my-8 rounded-xl border p-4 text-sm font-mono"
        style={{ borderColor: 'var(--border-color)', color: 'var(--text-muted)' }}
      >
        No benchmark data found for{' '}
        <span style={{ color: 'var(--cyan)' }}>{slug}</span>. Run{' '}
        <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
      </div>
    )
  }

  if (chart === 'throughput-bars') {
    return <ThroughputBarsChart runs={runs} stat={stat} targetN={n} title={data.title} />
  }

  if (chart === 'latency-histogram') {
    return (
      <LatencyHistogramChart
        runs={runs as LatencyRun[]}
        variants={variants}
        view={view}
        markers={markers}
      />
    )
  }

  return null
}
