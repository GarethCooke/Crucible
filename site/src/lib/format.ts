// SI suffix formatter using binary prefixes (M = 2^20, K = 2^10).
// Binary prefixes keep power-of-two array sizes (e.g. 2^25 = 32 M) exact.
export function formatSI(n: number): string {
  const Mi = 1 << 20
  const Ki = 1 << 10
  if (n >= Mi) {
    const v = n / Mi
    return `${Number.isInteger(v) ? v : v.toFixed(1)} M`
  }
  if (n >= Ki) {
    const v = n / Ki
    return `${Number.isInteger(v) ? v : v.toFixed(1)} K`
  }
  return `${n}`
}
