import { loadPerfData } from '@/lib/perf-data'
import { ThroughputBarsChart, type Run } from './ThroughputBarsChart'
import { NoData } from './NoData'

interface Props {
  /** Load data from site/src/data/perf/<slug>.json when provided. */
  slug?: string
  /** Pass runs directly (used by Benchmark.tsx). */
  runs?: Run[]
  /** Filter runs to those with this placement value. */
  placement?: string
  /** Filter runs to these variant names (also controls left-to-right ordering). */
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  targetN?: number
  title?: string
  kFilter?: number | number[]
  /** Filter to a specific workload (e.g. "lookup" or "modify_mix"). */
  workloadFilter?: string
  /** Filter to a specific distribution (e.g. "random"). */
  distributionFilter?: string
  /** Render bars grouped by input distribution (demo 8 chart 2). */
  distGrouped?: boolean
  /** Filter to a specific key type (e.g. "u32"). */
  keyTypeFilter?: string
  /** Display-name overrides: maps JSON variant name → X-axis label. */
  variantLabels?: Record<string, string>
}

export async function ThroughputBars({
  slug,
  runs: runsIn,
  placement,
  variants,
  stat = 'median',
  targetN,
  title,
  kFilter,
  workloadFilter,
  distributionFilter,
  distGrouped,
  keyTypeFilter,
  variantLabels,
}: Props) {
  let runs: Run[] = runsIn ?? []

  if (slug) {
    try {
      const data = await loadPerfData<{ title?: string; runs: Run[] }>(slug)
      runs = data.runs
      if (!title) title = data.title
    } catch {
      return (
        <NoData>
          No data found for <span>{slug}</span>.
          Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
        </NoData>
      )
    }
  }

  if (workloadFilter) {
    runs = runs.filter(
      (r) => (r as { workload?: string }).workload === workloadFilter,
    )
  }

  if (distributionFilter) {
    runs = runs.filter(
      (r) => (r as { distribution?: string }).distribution === distributionFilter,
    )
  }

  if (keyTypeFilter) {
    runs = runs.filter(
      (r) => (r as { key_type?: string }).key_type === keyTypeFilter,
    )
  }

  if (placement) {
    runs = runs.filter(
      (r) => (r as { placement?: string }).placement === placement,
    )
  }

  if (variants) {
    runs = runs.filter((r) => variants.includes(r.variant))
    // honour the caller's preferred left-to-right order
    runs = [...runs].sort(
      (a, b) => variants.indexOf(a.variant) - variants.indexOf(b.variant),
    )
  }

  return (
    <ThroughputBarsChart
      runs={runs}
      stat={stat as 'median' | 'min' | 'p99'}
      targetN={targetN}
      title={title}
      kFilter={kFilter}
      variantLabels={variantLabels}
      distGrouped={distGrouped}
    />
  )
}
