import { readFile } from 'fs/promises'
import path from 'path'
import { ThroughputBarsChart, type Run } from './ThroughputBarsChart'
import { NoData } from './NoData'

interface Props {
  /** Load data from site/src/data/perf/<slug>.json when provided. */
  slug?: string
  /** Pass runs directly (used by Benchmark.tsx). */
  runs?: Run[]
  /** Filter runs to those with this placement value. */
  placement?: string
  /** Filter runs to these variant names. */
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  targetN?: number
  title?: string
  kFilter?: number | number[]
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
}: Props) {
  let runs: Run[] = runsIn ?? []

  if (slug) {
    const filePath = path.join(process.cwd(), 'src/data/perf', `${slug}.json`)
    try {
      const raw = await readFile(filePath, 'utf-8')
      const data = JSON.parse(raw) as { title?: string; runs: Run[] }
      runs = data.runs
      if (!title) title = data.title
    } catch {
      return (
        <NoData>
          No data found for <span>{slug}</span>.
          Run <code>tools/perf_capture.sh</code> on the reference machine.
        </NoData>
      )
    }
  }

  if (placement) {
    runs = runs.filter(
      (r) => (r as { placement?: string }).placement === placement,
    )
  }

  if (variants) {
    runs = runs.filter((r) => variants.includes(r.variant))
  }

  return (
    <ThroughputBarsChart
      runs={runs}
      stat={stat as 'median' | 'min' | 'p99'}
      targetN={targetN}
      title={title}
      kFilter={kFilter}
    />
  )
}
