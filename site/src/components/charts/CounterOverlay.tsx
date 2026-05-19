import { readFile } from 'fs/promises'
import path from 'path'
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

export async function CounterOverlay({ slug, metric, placement, variants, title }: Props) {
  const filePath = path.join(process.cwd(), 'src/data/perf', `${slug}.json`)
  const noData = (
    <NoData>
      No data found for <span>{slug}</span>.
      Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
    </NoData>
  )

  if (metric === 'branch_misses_per_op') {
    // Branch-prediction schema: top-level branch_misses_per_op per run.
    // Show per-variant bars at the largest captured N.
    let branchRuns: BranchMissRun[] = []
    try {
      const raw = await readFile(filePath, 'utf-8')
      const data = JSON.parse(raw) as {
        title?: string
        runs: { variant: string; n: number; branch_misses_per_op: number }[]
      }
      if (!title) title = data.title
      const allRuns = variants
        ? data.runs.filter((r) => variants.includes(r.variant))
        : data.runs
      // Pick the largest N so each variant contributes one representative bar.
      const maxN = Math.max(...allRuns.map((r) => r.n))
      branchRuns = allRuns
        .filter((r) => r.n === maxN)
        .map((r) => ({ variant: r.variant, branch_misses_per_op: r.branch_misses_per_op }))
    } catch {
      return noData
    }
    if (branchRuns.length === 0) return noData
    return <BranchMissOverlayChart runs={branchRuns} title={title} />
  }

  // False-sharing schema: metrics nested in run.counters.
  let runs: CounterRun[] = []
  try {
    const raw = await readFile(filePath, 'utf-8')
    const data = JSON.parse(raw) as { title?: string; runs: (CounterRun & { placement?: string })[] }
    const all = data.runs.filter((r) => r.counters != null)
    runs = placement ? all.filter((r) => r.placement === placement) : all
    if (!title) title = data.title
  } catch {
    return noData
  }

  return <CounterOverlayChart runs={runs} metric={metric as Exclude<Metric, 'branch_misses_per_op'>} title={title} />
}
