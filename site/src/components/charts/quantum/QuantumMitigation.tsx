import { loadQuantumData } from '@/lib/quantum-data'
import { QuantumProbChartClient, type ProbSeries } from './QuantumProbChartClient'
import type { QuantumMitigationPoint } from '@/lib/quantum-data'

const OFF_COLOR = 'oklch(72% 0.18 222)'
const ON_COLOR  = 'oklch(60% 0.17 320)'

type NConclusion =
  | { n: number; N: number; kind: 'pending' }
  | { n: number; N: number; kind: 'overlap' }
  | { n: number; N: number; kind: 'disjoint'; effect: number }

function computeConclusions(
  off: QuantumMitigationPoint[],
  on: QuantumMitigationPoint[],
): NConclusion[] {
  return off.map((offRow) => {
    const onRow = on.find((r) => r.n === offRow.n)
    if (!onRow) return { n: offRow.n, N: offRow.N, kind: 'pending' }
    if (offRow.min == null || offRow.max == null || onRow.min == null || onRow.max == null) {
      return { n: offRow.n, N: offRow.N, kind: 'pending' }
    }
    const overlaps = offRow.min <= onRow.max && onRow.min <= offRow.max
    if (overlaps) return { n: offRow.n, N: offRow.N, kind: 'overlap' }
    const effect = (offRow.mean ?? 0) - (onRow.mean ?? 0)
    return { n: offRow.n, N: offRow.N, kind: 'disjoint', effect }
  })
}

function conclusionText(c: NConclusion): string {
  if (c.kind === 'pending') return 'pending'
  if (c.kind === 'overlap') return 'no significant effect at this N (off/on intervals overlap)'
  const sign = c.effect > 0 ? '+' : ''
  return `off−on = ${sign}${c.effect.toFixed(3)} (intervals disjoint)`
}

export async function QuantumMitigation() {
  const data = await loadQuantumData()
  const { off, on } = data.mitigation
  const { grover_ideal, random_floor } = data.ns_sweep
  const pending = data.data_status === 'aer-only'

  const conclusions = computeConclusions(off, on)
  const allPending = conclusions.every((c) => c.kind === 'pending')

  const xLabels = grover_ideal.map((p) => `N=${p.N}`)

  const series: ProbSeries[] = [
    {
      label: pending ? 'Mitigation off (pending)' : 'Mitigation off',
      color: OFF_COLOR,
      points: off.map((p) => ({
        xLabel: `N=${p.N}`,
        xIndex: p.n,
        y: pending ? null : p.mean,
        yMin: pending ? null : (p.min ?? null),
        yMax: pending ? null : (p.max ?? null),
      })),
    },
    {
      label: pending ? 'Mitigation on (pending)' : 'Mitigation on',
      color: ON_COLOR,
      dash: '6,3',
      points: on.map((p) => ({
        xLabel: `N=${p.N}`,
        xIndex: p.n,
        y: pending ? null : p.mean,
        yMin: pending ? null : (p.min ?? null),
        yMax: pending ? null : (p.max ?? null),
      })),
    },
  ]

  const hLines = [
    { y: random_floor[random_floor.length - 1].mean, label: `random floor (N=${random_floor[random_floor.length - 1].N})` },
  ]

  return (
    <>
      <QuantumProbChartClient
        title={
          pending
            ? 'Mitigation off vs on — hardware capture pending'
            : 'Grover device success: mitigation off vs on (DD + measurement twirling)'
        }
        xLabels={xLabels}
        series={series}
        hLines={hLines}
        pending={pending}
        xAxisLabel="N (search-space size)"
        yAxisLabel="P(success)"
      />
      {allPending ? (
        <div
          className="rounded-xl border px-4 py-3 mt-3 text-sm"
          style={{ borderColor: 'var(--border-color)', background: 'var(--bg-card)', color: 'var(--text-muted)' }}
        >
          Hardware capture pending. Per-N significance will be assessed from run-to-run spread once device data is committed.
        </div>
      ) : (
        <div
          className="rounded-xl border p-4 mt-3 font-mono text-xs space-y-1"
          style={{ borderColor: 'var(--border-color)', background: 'var(--bg-card)', color: 'var(--text-secondary)' }}
        >
          {conclusions.map((c) => (
            <div key={c.N}>
              <span style={{ color: 'var(--text-muted)' }}>N={c.N}</span>
              {'  '}{conclusionText(c)}
            </div>
          ))}
        </div>
      )}
    </>
  )
}
