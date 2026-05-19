import { readFile } from 'fs/promises'
import path from 'path'
import { ThroughputBarsChart } from './charts/ThroughputBarsChart'
import { LatencyHistogramChart } from './charts/LatencyHistogram'
import { LatencyVsLoadChart } from './charts/LatencyVsLoad'
import { NoData } from './charts/NoData'
import type { LatencyHistogramData } from '@/lib/perf-types'

interface BenchmarkProps {
  slug: string
  chart?: 'throughput-bars' | 'latency-histogram' | 'latency-vs-load'
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  n?: number
  mode?: 'paced' | 'saturated' | 'sweep'
  offered_rate_hz?: number
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
  latency_ns?: LatencyHistogramData
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
    const withMode = filtered.filter((r) => r.mode === mode)
    if (withMode.length > 0) return applyRemainingFilters(withMode, offered_rate_hz, variants)
    if (mode === 'sweep') return []  // sweep data must be explicitly tagged; no fallback
    filtered = filtered.filter((r) => !r.mode)
  }

  return applyRemainingFilters(filtered, offered_rate_hz, variants)
}

function applyRemainingFilters(
  runs: RunRecord[],
  offered_rate_hz: number | undefined,
  variants: string[] | undefined,
): RunRecord[] {
  let filtered = runs
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

  const sweepRuns =
    chart === 'latency-vs-load'
      ? filterRuns(data.runs, 'sweep', undefined, variants)
      : []

  const runs = filterRuns(data.runs, mode, offered_rate_hz, variants)

  const hasLatencyData = runs.some((r) => r.latency_ns?.counts?.length)
  const hasSweepData = sweepRuns.some(
    (r) => r.offered_rate_hz != null && r.offered_rate_hz > 0 && r.latency_ns?.stats != null,
  )

  const noData =
    chart === 'latency-histogram'
      ? !hasLatencyData
      : chart === 'latency-vs-load'
      ? !hasSweepData
      : runs.length === 0

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
        runs={runs}
        variants={variants}
        view={view}
        markers={markers}
        title={data.title}
      />
    )
  }

  if (chart === 'latency-vs-load') {
    return (
      <LatencyVsLoadChart
        runs={sweepRuns}
        variants={variants}
        title={data.title}
      />
    )
  }

  return null
}
