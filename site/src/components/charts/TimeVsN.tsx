import { loadPerfData } from '@/lib/perf-data'
import { TimeVsNChart, type TimeVsNRun } from './TimeVsNChart'
import { NoData } from './NoData'

interface Props {
  slug: string
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  title?: string
}

export async function TimeVsN({ slug, variants, stat = 'median', title }: Props) {
  try {
    const data = await loadPerfData<{ title?: string; runs: TimeVsNRun[] }>(slug)
    const resolvedTitle = title ?? data.title
    const runs = variants
      ? data.runs.filter((r) => variants.includes(r.variant))
      : data.runs

    if (runs.length === 0) throw new Error('no matching runs')

    return <TimeVsNChart runs={runs} stat={stat} title={resolvedTitle} />
  } catch {
    return (
      <NoData>
        No data found for <span>{slug}</span>.
        Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
      </NoData>
    )
  }
}
