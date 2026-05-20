export interface LatencyStats {
  count: number
  min: number
  max: number
  p50: number
  p90: number
  p99: number
  p99_9: number
}

export interface LatencyHistogramData {
  scheme: string
  bucket_count: number
  min_bucket_ns: number
  counts: number[]
  stats: LatencyStats
}

export type LatencyStatsOnly = Pick<LatencyHistogramData, 'stats'>

// Demo 05 pressure-sweep record (mode: "pressure_sweep").
// background_pressure_hz is null for the no-T_bg baseline run.
export interface PressureSweepRun {
  variant: string
  mode: 'pressure_sweep'
  offered_rate_hz: number
  background_pressure_hz: number | null
  latency_ns?: LatencyStatsOnly
}
