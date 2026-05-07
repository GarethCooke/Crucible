import { readFile } from 'fs/promises'
import path from 'path'
import { ThroughputBars } from './charts/ThroughputBars'

interface BenchmarkProps {
  slug: string
  chart?: 'throughput-bars'
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  n?: number
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
  }[]
}

export async function Benchmark({
  slug,
  chart = 'throughput-bars',
  variants,
  stat = 'median',
  n,
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

  if (chart === 'throughput-bars') {
    return <ThroughputBars runs={runs} stat={stat} targetN={n} title={data.title} />
  }

  return null
}
