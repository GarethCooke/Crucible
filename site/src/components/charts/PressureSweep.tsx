import { loadPerfData } from '@/lib/perf-data'
import { PressureSweepChart } from './PressureSweepChart'
import { NoData } from './NoData'
import type { PressureSweepRun } from '@/lib/perf-types'
import type { PressureMetric } from './PressureSweepChart'

interface PressureSweepProps {
  slug: string
  variants?: string[]
  metric?: PressureMetric
  xAxis?: 'background_pressure_hz'
  yAxisLabel?: string
}

interface RawRun {
  variant: string
  mode?: string
  background_pressure_hz?: number | null
  offered_rate_hz?: number
  latency_ns?: { stats?: { p50?: number; p90?: number; p99?: number; p99_9?: number } }
}

interface PerfData {
  runs: RawRun[]
}

export async function PressureSweep({
  slug,
  variants,
  metric = 'p99_9',
  yAxisLabel,
}: PressureSweepProps) {
  const noData = (msg: string) => (
    <NoData>
      {msg} Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
    </NoData>
  )

  let data: PerfData
  try {
    data = await loadPerfData<PerfData>(slug)
  } catch {
    return noData(`No benchmark data found for ${slug}.`)
  }

  // Filter pressure_sweep runs, then optionally filter by variants.
  let runs: PressureSweepRun[] = data.runs
    .filter((r): r is RawRun & { mode: 'pressure_sweep' } => r.mode === 'pressure_sweep')
    .map((r) => ({
      variant: r.variant,
      mode: 'pressure_sweep',
      offered_rate_hz: r.offered_rate_hz ?? 0,
      background_pressure_hz: r.background_pressure_hz ?? null,
      latency_ns: r.latency_ns?.stats
        ? { stats: { count: 0, min: 0, max: 0, p50: 0, p90: 0, p99: 0, p99_9: 0, ...r.latency_ns.stats } }
        : undefined,
    }))

  if (variants) {
    runs = runs.filter((r) => variants.includes(r.variant))
  }

  const hasData = runs.some((r) => {
    const v = r.latency_ns?.stats?.[metric as keyof typeof r.latency_ns.stats]
    return typeof v === 'number' && v > 0
  })

  if (!hasData) {
    return noData(`No pressure sweep data found for ${slug}.`)
  }

  const title = `${slug} — background pressure vs ${metric} latency`

  return (
    <PressureSweepChart
      runs={runs}
      variants={variants}
      metric={metric}
      yAxisLabel={yAxisLabel}
      title={title}
    />
  )
}
