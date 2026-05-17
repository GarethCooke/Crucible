import { readFile } from 'fs/promises'
import path from 'path'
import { TimeVsNChart, type TimeVsNRun } from './TimeVsNChart'

interface Props {
  slug: string
  variants?: string[]
  stat?: 'median' | 'min' | 'p99'
  title?: string
}

export async function TimeVsN({ slug, variants, stat = 'median', title }: Props) {
  const filePath = path.join(process.cwd(), 'src/data/perf', `${slug}.json`)

  try {
    const raw = await readFile(filePath, 'utf-8')
    const data = JSON.parse(raw) as {
      title?: string
      runs: TimeVsNRun[]
    }
    if (!title) title = data.title
    const runs = variants
      ? data.runs.filter((r) => variants.includes(r.variant))
      : data.runs

    if (runs.length === 0) throw new Error('no matching runs')

    return <TimeVsNChart runs={runs} stat={stat} title={title} />
  } catch {
    return (
      <div
        className="my-8 rounded-xl border p-4 text-sm font-mono"
        style={{ borderColor: 'rgba(255,255,255,0.07)', color: '#435270' }}
      >
        No data found for <span style={{ color: 'oklch(65% 0.18 222)' }}>{slug}</span>.
        Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
      </div>
    )
  }
}
