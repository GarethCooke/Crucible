import { readFile } from 'fs/promises'
import path from 'path'

export interface QuantumNSweepPoint {
  n: number
  N: number
  mean: number | null
  min?: number | null
  max?: number | null
  per_repeat?: number[]
  status?: string
}

export interface QuantumMitigationPoint {
  n: number
  N: number
  mean: number | null
  min?: number | null
  max?: number | null
  per_repeat?: number[]
  status?: string
}

export interface QuantumTeachingPoint {
  iters: number
  p_marked: number
}

export interface QuantumCircuitDepthPoint {
  n: number
  N: number
  depth: number
  two_qubit_gates: number
  optimal_iters?: number
}

export interface QuantumMeasuringTheGap {
  schema: string
  data_status: 'aer-only' | 'hardware-captured'
  note: string
  capture_meta: {
    backend: { name: string; num_qubits: number } | null
    physical_qubits: number[] | null
    calibration_timestamp: string | null
    shots: number
    ns: number[]
    captured_at: string
  }
  ns_sweep: {
    grover_ideal: QuantumNSweepPoint[]
    grover_device: QuantumNSweepPoint[]
    bv_ideal: QuantumNSweepPoint[]
    bv_device: QuantumNSweepPoint[]
    classical_floor: { n: number; N: number; mean: number }[]
    random_floor: { n: number; N: number; mean: number }[]
  }
  mitigation: {
    note: string
    off: QuantumMitigationPoint[]
    on: QuantumMitigationPoint[]
  }
  teaching_sweep: {
    n: number
    N: number
    marked: string
    note: string
    curve: QuantumTeachingPoint[]
  }
  circuit_depth: {
    grover: QuantumCircuitDepthPoint[]
    bv: QuantumCircuitDepthPoint[]
  }
  raw_archive_paths: string[]
}

export async function loadQuantumData(): Promise<QuantumMeasuringTheGap> {
  const filePath = path.join(
    process.cwd(),
    'src/data/quantum/measuring-the-gap.json',
  )
  const raw = await readFile(filePath, 'utf-8')
  return JSON.parse(raw) as QuantumMeasuringTheGap
}
