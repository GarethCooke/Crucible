import { loadQuantumData } from '@/lib/quantum-data'
import { QuantumProbChartClient, type ProbSeries } from './QuantumProbChartClient'

const GROVER_IDEAL_COLOR   = 'oklch(72% 0.18 222)'
const GROVER_DEVICE_COLOR  = 'oklch(52% 0.17 30)'
const CLASSICAL_COLOR      = 'oklch(78% 0.15 95)'

export async function QuantumCollapseCurve() {
  const data = await loadQuantumData()
  const { grover_ideal, grover_device, classical_floor, random_floor } = data.ns_sweep
  const pending = data.data_status === 'aer-only'

  const xLabels = grover_ideal.map((p) => `N=${p.N}`)

  const series: ProbSeries[] = [
    {
      label: 'Ideal simulator',
      color: GROVER_IDEAL_COLOR,
      points: grover_ideal.map((p) => ({ xLabel: `N=${p.N}`, xIndex: p.n, y: p.mean })),
    },
    {
      label: 'Classical (always correct)',
      color: CLASSICAL_COLOR,
      dash: '6,3',
      points: classical_floor.map((p) => ({ xLabel: `N=${p.N}`, xIndex: p.n, y: p.mean })),
    },
    {
      label: pending ? 'Grover device (pending)' : 'Grover device',
      color: GROVER_DEVICE_COLOR,
      points: grover_device.map((p) => ({
        xLabel: `N=${p.N}`,
        xIndex: p.n,
        y: p.mean,
        yMin: p.min ?? null,
        yMax: p.max ?? null,
      })),
    },
  ]

  // Random floor for each N as horizontal reference lines (one per N would be cluttered;
  // show a single representative line for the minimum N floor)
  const hLines = [
    { y: random_floor[random_floor.length - 1].mean, label: `random 1/N=${random_floor[random_floor.length - 1].N}` },
  ]

  return (
    <QuantumProbChartClient
      title="Grover collapse curve — ideal simulator vs device"
      xLabels={xLabels}
      series={series}
      hLines={hLines}
      pending={pending}
      xAxisLabel="N (search-space size)"
      yAxisLabel="P(success)"
    />
  )
}
