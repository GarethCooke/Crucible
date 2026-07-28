import { loadPerfData } from '@/lib/perf-data'
import { LatencyMatrixChart } from './LatencyMatrixChart'
import { NoData } from './NoData'
import type { LatencyMatrixFile } from '@/lib/perf-types'

interface Props {
  slug: string
  /** Override the title from the JSON data file. */
  title?: string
}

/**
 * Server wrapper for the core-to-core RTT heatmap.
 *
 * Deliberately not routed through <Benchmark>: the matrix has no variant,
 * thread or N axis for that component's filter model to act on — it is a fixed
 * cores × cores grid in its own `latency_matrix` block. This follows the same
 * direct-export pattern as <TimeVsN> and <PressureSweep>.
 */
export async function LatencyMatrix({ slug, title }: Props) {
  const noData = (msg: string) => (
    <NoData>
      {msg} Run <code>./bench/scripts/run_one.sh {slug}</code> on the reference machine.
    </NoData>
  )

  let data: LatencyMatrixFile
  try {
    data = await loadPerfData<LatencyMatrixFile>(slug)
  } catch {
    return noData(`No benchmark data found for ${slug}.`)
  }

  // Degrade rather than throw when pointed at a demo whose JSON has no matrix.
  const matrix = data.latency_matrix
  if (!matrix?.cores?.length || !matrix.pairs?.length) {
    return noData(`No latency_matrix block in ${slug}.`)
  }

  return <LatencyMatrixChart matrix={matrix} title={title ?? data.title} />
}
