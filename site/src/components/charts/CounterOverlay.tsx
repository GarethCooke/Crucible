import { loadPerfData } from '@/lib/perf-data'
import { CounterOverlayChart, type CounterRun } from './CounterOverlayChart'
import { BranchMissOverlayChart, type BranchMissRun } from './CounterOverlayChart'
import { NoData } from './NoData'

type Metric =
  | 'cache_misses_per_op'
  | 'cache_miss_ratio'
  | 'instructions_per_cycle'
  | 'branch_misses_per_op'

interface Props {
  slug: string
  metric: Metric
  placement?: string   // false-sharing: filter by placement
  variants?: string[]  // branch-pred: filter by variant name
  title?: string
}

const noData = (slug: string) => (
  <NoData>
    No data found for <span>{slug}</span>.
    Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
  </NoData>
)

export async function CounterOverlay({ slug, metric, placement, variants, title }: Props) {
  if (metric === 'branch_misses_per_op') {
    // Branch-prediction schema: top-level branch_misses_per_op per run.
    // Show per-variant bars at the largest captured N.
    let branchRuns: BranchMissRun[] = []
    let maxN = 0
    let resolvedTitle = title
    try {
      const data = await loadPerfData<{
        title?: string
        runs: { variant: string; n: number; branch_misses_per_op: number }[]
      }>(slug)
      if (!resolvedTitle) resolvedTitle = data.title
      const allRuns = variants
        ? data.runs.filter((r) => variants.includes(r.variant))
        : data.runs
      // Pick the largest N so each variant contributes one representative bar.
      maxN = Math.max(...allRuns.map((r) => r.n))
      branchRuns = allRuns
        .filter((r) => r.n === maxN)
        .map((r) => ({ variant: r.variant, branch_misses_per_op: r.branch_misses_per_op }))
    } catch {
      return noData(slug)
    }
    if (branchRuns.length === 0) return noData(slug)
    return <BranchMissOverlayChart runs={branchRuns} title={resolvedTitle} maxN={maxN} />
  }

  // False-sharing schema: metrics nested in run.counters.
  let runs: CounterRun[] = []
  let resolvedTitle = title
  try {
    const data = await loadPerfData<{ title?: string; runs: (CounterRun & { placement?: string })[] }>(slug)
    const all = data.runs.filter((r) => r.counters != null)
    runs = placement ? all.filter((r) => r.placement === placement) : all
    if (!resolvedTitle) resolvedTitle = data.title
  } catch {
    return noData(slug)
  }

  return <CounterOverlayChart runs={runs} metric={metric as Exclude<Metric, 'branch_misses_per_op'>} title={resolvedTitle} />
}
