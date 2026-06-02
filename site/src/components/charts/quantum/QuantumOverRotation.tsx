import { loadQuantumData } from '@/lib/quantum-data'
import { QuantumIterSweepClient } from './QuantumProbChartClient'

export async function QuantumOverRotation() {
  const data = await loadQuantumData()
  const { curve, n } = data.teaching_sweep
  const optimalIters = Math.max(1, Math.round((Math.PI / 4) * Math.sqrt(Math.pow(2, n))))

  return (
    <QuantumIterSweepClient
      title="Over-rotation: P(marked) vs iteration count — N=16, ideal simulator"
      curve={curve}
      optimalIters={optimalIters}
    />
  )
}
