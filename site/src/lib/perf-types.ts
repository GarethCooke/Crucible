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

// ─── Demo 10: core-to-core latency matrix ────────────────────────────────────
// Mirrors the `latency_matrix` block emitted by bench/10-core-to-core.
//
// Deliberately does NOT reuse LatencyStats. The matrix harness reports an
// across-placement spread (median of per-placement medians, plus the IQR
// bounds over those placements) rather than a within-run percentile ladder,
// so there is no p99/p99_9 to report and none is invented here.

export interface LatencyMatrixStats {
  /** Median across placements of each placement's per-window median. */
  median: number
  min: number
  max: number
  /** iqr_hi − iqr_lo across placements. */
  iqr: number
  iqr_lo: number
  iqr_hi: number
  /** Number of placements sampled for this cell. */
  n_reps: number
}

export interface LatencyMatrixCore {
  cpu: number
  /** L3/CCX group id — the authority for row/column grouping. Never infer from cpu index. */
  ccx: number
  /** Human-readable cpu range sharing this L3, e.g. "0-3". */
  l3_domain: string
  housekeeping: boolean
}

export interface LatencyMatrixPair {
  a: number
  b: number
  same_ccx: boolean
  rtt_ns: LatencyMatrixStats
}

export interface LatencyMatrixBaseline extends LatencyMatrixStats {
  cpu: number
}

export interface LatencyMatrixBlock {
  protocol: string
  memory_order: string
  k_roundtrips: number
  windows_per_placement: number
  warmup_windows: number
  placements_per_cell: number
  placement_arenas?: number
  placement_sampling?: string
  arenas_hugepage_obtained?: number
  offset_mode?: string
  offset_seed?: string
  tsc_ns_per_cycle: number
  rtt_convention: string
  orchestrator_placement?: string
  cores: LatencyMatrixCore[]
  baseline_ns: LatencyMatrixBaseline[]
  /** Each unordered pair once — the component mirrors them into the full N×N. */
  pairs: LatencyMatrixPair[]
}

export interface LatencyMatrixFile {
  demo?: string
  title?: string
  captured_at?: string
  notes?: string
  latency_matrix?: LatencyMatrixBlock
}
