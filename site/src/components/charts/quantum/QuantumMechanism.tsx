import { loadQuantumData } from '@/lib/quantum-data'
import { QuantumMechanismClient } from './QuantumProbChartClient'

export async function QuantumMechanism() {
  const data = await loadQuantumData()
  const { grover, bv } = data.circuit_depth

  return (
    <QuantumMechanismClient
      title="Transpiled circuit depth vs N — why Grover collapses"
      groverDepths={grover.map((d) => ({ N: d.N, depth: d.depth }))}
      bvDepths={bv.map((d) => ({ N: d.N, depth: d.depth }))}
    />
  )
}
