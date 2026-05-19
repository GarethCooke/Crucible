import type { ReactNode } from 'react'

export function NoData({ children }: { children?: ReactNode }) {
  return (
    <div
      className="my-8 rounded-xl border p-6 text-xs font-mono"
      style={{
        background: 'var(--bg-card)',
        borderColor: 'var(--border-color)',
        color: 'var(--cyan)',
      }}
    >
      {children ?? 'No benchmark data available.'}
    </div>
  )
}
