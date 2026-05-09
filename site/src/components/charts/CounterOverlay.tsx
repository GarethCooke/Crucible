import { readFile } from 'fs/promises'
import path from 'path'
import { CounterOverlayChart, type CounterRun } from './CounterOverlayChart'

type Metric = 'cache_misses_per_op' | 'cache_miss_ratio' | 'instructions_per_cycle'

interface Props {
  slug: string
  metric: Metric
  placement?: string
  title?: string
}

export async function CounterOverlay({ slug, metric, placement, title }: Props) {
  const filePath = path.join(process.cwd(), 'src/data/perf', `${slug}.json`)
  let runs: CounterRun[] = []

  try {
    const raw = await readFile(filePath, 'utf-8')
    const data = JSON.parse(raw) as { title?: string; runs: (CounterRun & { placement?: string })[] }
    const all = data.runs.filter((r) => r.counters != null)
    runs = placement ? all.filter((r) => r.placement === placement) : all
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

  return <CounterOverlayChart runs={runs} metric={metric} title={title} />
}
