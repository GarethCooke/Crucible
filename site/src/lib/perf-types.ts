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
