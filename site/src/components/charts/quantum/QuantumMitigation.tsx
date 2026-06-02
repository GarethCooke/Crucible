import { loadQuantumData } from '@/lib/quantum-data'
import { QuantumProbChartClient, type ProbSeries } from './QuantumProbChartClient'

const OFF_COLOR = 'oklch(72% 0.18 222)'
const ON_COLOR  = 'oklch(60% 0.17 320)'

export async function QuantumMitigation() {
  const data = await loadQuantumData()
  const { off, on } = data.mitigation
  const { grover_ideal, random_floor } = data.ns_sweep
  const pending = data.data_status === 'aer-only'

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
  )
}
