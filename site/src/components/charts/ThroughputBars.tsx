import { readFile } from 'fs/promises'
import path from 'path'
import { ThroughputBarsChart, type Run } from './ThroughputBarsChart'

interface Props {
  /** Load data from site/src/data/perf/<slug>.json when provided. */
  slug?: string
  /** Pass runs directly (used by Benchmark.tsx). */
  runs?: Run[]
  /** Filter runs to those with this placement value. */
  placement?: string
  stat?: 'median' | 'min' | 'p99'
  targetN?: number
  title?: string
}

export async function ThroughputBars({
  slug,
  runs: runsIn,
  placement,
  stat = 'median',
  targetN,
  title,
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
        <div
          className="my-8 rounded-xl border p-4 text-sm font-mono"
          style={{ borderColor: 'rgba(255,255,255,0.07)', color: '#435270' }}
        >
          No data found for <span style={{ color: 'oklch(65% 0.18 222)' }}>{slug}</span>.
          Run <code>tools/perf_capture.sh</code> on the reference machine.
        </div>
      )
    }
  }

  if (placement) {
    runs = runs.filter(
      (r) => (r as { placement?: string }).placement === placement,
    )
  }

  return (
    <ThroughputBarsChart
      runs={runs}
      stat={stat as 'median' | 'min' | 'p99'}
      targetN={targetN}
      title={title}
    />
  )
}
