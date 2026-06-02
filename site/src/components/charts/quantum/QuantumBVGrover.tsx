import { loadQuantumData } from '@/lib/quantum-data'
import { QuantumProbChartClient, type ProbSeries } from './QuantumProbChartClient'

const GROVER_COLOR = 'oklch(52% 0.17 30)'
const BV_COLOR     = 'oklch(72% 0.18 222)'

export async function QuantumBVGrover() {
  const data = await loadQuantumData()
  const { grover_device, bv_device, grover_ideal, bv_ideal, random_floor } = data.ns_sweep
  const pending = data.data_status === 'aer-only'

  const xLabels = grover_ideal.map((p) => `N=${p.N}`)

  const series: ProbSeries[] = [
    {
      label: pending ? 'Grover device (pending)' : 'Grover device',
      color: GROVER_COLOR,
      points: (pending ? grover_ideal : grover_device).map((p) => ({
        xLabel: `N=${p.N}`,
        xIndex: p.n,
        y: pending ? null : p.mean,
        yMin: pending ? null : (p.min ?? null),
        yMax: pending ? null : (p.max ?? null),
      })),
    },
    {
      label: pending ? 'BV device (pending)' : 'BV device',
      color: BV_COLOR,
      points: (pending ? bv_ideal : bv_device).map((p) => ({
        xLabel: `N=${p.N}`,
        xIndex: p.n,
        y: pending ? null : p.mean,
        yMin: pending ? null : (p.min ?? null),
        yMax: pending ? null : (p.max ?? null),
      })),
    },
    {
      label: 'Grover ideal',
      color: GROVER_COLOR,
      dash: '6,3',
      points: grover_ideal.map((p) => ({ xLabel: `N=${p.N}`, xIndex: p.n, y: p.mean })),
    },
    {
      label: 'BV ideal',
      color: BV_COLOR,
      dash: '6,3',
      points: bv_ideal.map((p) => ({ xLabel: `N=${p.N}`, xIndex: p.n, y: p.mean })),
    },
  ]

  const hLines = [
    { y: random_floor[random_floor.length - 1].mean, label: `random floor (N=${random_floor[random_floor.length - 1].N})` },
  ]

  return (
    <QuantumProbChartClient
      title="BV vs Grover device success — shallow circuit survives, deep circuit collapses"
      xLabels={xLabels}
      series={series}
      hLines={hLines}
      pending={pending}
      xAxisLabel="N (search-space size)"
      yAxisLabel="P(success)"
    />
  )
}
