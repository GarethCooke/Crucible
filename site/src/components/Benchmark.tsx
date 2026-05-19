import { readFile } from 'fs/promises'
import path from 'path'
import { ThroughputBarsChart } from './charts/ThroughputBarsChart'
import { LatencyHistogramChart, type LatencyRun } from './charts/LatencyHistogram'
import { LatencyVsLoadChart, type SweepRun } from './charts/LatencyVsLoad'
import { NoData } from './charts/NoData'

interface BenchmarkProps {
  slug: string
  chart?: 'throughput-bars' | 'latency-histogram' | 'latency-vs-load'
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  n?: number
  // mode/rate filtering — paced runs are the default when not specified
  mode?: 'paced' | 'saturated' | 'sweep'
  offered_rate_hz?: number
  // latency-histogram props
  view?: 'ccdf' | 'pdf'
  markers?: Array<'p50' | 'p99' | 'p99_9'>
}

interface RunRecord {
  variant: string
  mode?: string
  offered_rate_hz?: number
  n: number
  ns_per_op: { median: number; min: number; p99: number; iqr: number }
  ops_per_sec: number
  branch_misses_per_op?: number
  instructions_per_cycle?: number
  latency_ns?: unknown
}

interface PerfData {
  title: string
  runs: RunRecord[]
}

// Filter runs to those matching the requested mode and offered_rate_hz.
// Falls back gracefully for old data files that have no mode field.
function filterRuns(
  runs: RunRecord[],
  mode: string | undefined,
  offered_rate_hz: number | undefined,
  variants: string[] | undefined,
): RunRecord[] {
  let filtered = runs

  if (mode !== undefined) {
    // Keep runs whose mode matches, OR runs with no mode field (old data)
    // preferring an exact match when present.
    const withMode = filtered.filter((r) => r.mode === mode)
    filtered = withMode.length > 0 ? withMode : filtered.filter((r) => !r.mode)
  }

  if (offered_rate_hz !== undefined) {
    filtered = filtered.filter((r) => r.offered_rate_hz === offered_rate_hz)
  }

  if (variants !== undefined) {
    filtered = filtered.filter((r) => variants.includes(r.variant))
  }

  return filtered
}

export async function Benchmark({
  slug,
  chart = 'throughput-bars',
  variants,
  stat = 'median',
  n,
  mode,
  offered_rate_hz,
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
      <NoData>
        No benchmark data found for <span>{slug}</span>. Run{' '}
        <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
      </NoData>
    )
  }

  // For latency-vs-load, use sweep runs unfiltered by offered_rate_hz
  const sweepRuns =
    chart === 'latency-vs-load'
      ? filterRuns(data.runs, 'sweep', undefined, variants)
      : []

  const runs = filterRuns(data.runs, mode, offered_rate_hz, variants)

  const noData = chart === 'latency-vs-load' ? sweepRuns.length === 0 : runs.length === 0

  if (noData) {
    return (
      <NoData>
        No benchmark data found for <span>{slug}</span>. Run{' '}
        <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
      </NoData>
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

  if (chart === 'latency-vs-load') {
    return (
      <LatencyVsLoadChart
        runs={sweepRuns as SweepRun[]}
        variants={variants}
      />
    )
  }

  return null
}
