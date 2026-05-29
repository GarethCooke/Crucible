import { loadPerfData } from '@/lib/perf-data'
import { TimeVsNChart, type TimeVsNRun, type ThresholdMarker } from './TimeVsNChart'
import { NoData } from './NoData'

interface Props {
  slug: string
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  title?: string
  yAxisLabel?: string
  kFilter?: number | 'all'
  nFilter?: number
  xAxis?: 'n' | 'k' | 'modify_pct'
  xScale?: 'log' | 'linear'
  thresholdMarkers?: ThresholdMarker[]
  annotateMaxGap?: boolean
  workloadFilter?: 'lookup' | 'modify_mix'
  variantLabels?: Record<string, string>
  yAxisLog?: boolean
}

export async function TimeVsN({
  slug,
  variants,
  stat = 'median',
  title,
  yAxisLabel,
  kFilter,
  nFilter,
  xAxis = 'n',
  xScale,
  thresholdMarkers,
  annotateMaxGap = false,
  workloadFilter,
  variantLabels,
  yAxisLog = false,
}: Props) {
  if (xAxis === 'k' && nFilter == null) {
    console.warn(`TimeVsN: xAxis="k" requires nFilter for slug="${slug}". Rendering NoData.`)
    return (
      <NoData>
        Chart requires <code>nFilter</code> when <code>xAxis=&quot;k&quot;</code>.
      </NoData>
    )
  }

  try {
    const data = await loadPerfData<{ title?: string; runs: TimeVsNRun[] }>(slug)
    const resolvedTitle = title ?? data.title
    let runs = variants
      ? data.runs.filter((r) => variants.includes(r.variant))
      : data.runs

    if (workloadFilter) {
      runs = runs.filter((r) => (r as { workload?: string }).workload === workloadFilter)
    }

    if (typeof kFilter === 'number') {
      runs = runs.filter((r) => r.k === kFilter)
    }

    if (nFilter != null) {
      runs = runs.filter((r) => r.n === nFilter)
    }

    if (runs.length === 0) throw new Error('no matching runs')

    return (
      <TimeVsNChart
        runs={runs}
        stat={stat}
        title={resolvedTitle}
        yAxisLabel={yAxisLabel}
        kFilter={kFilter}
        nFilter={nFilter}
        xAxis={xAxis}
        xScale={xScale}
        thresholdMarkers={thresholdMarkers}
        annotateMaxGap={annotateMaxGap}
        variantLabels={variantLabels}
        yAxisLog={yAxisLog}
      />
    )
  } catch {
    return (
      <NoData>
        No data found for <span>{slug}</span>.
        Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
      </NoData>
    )
  }
}
