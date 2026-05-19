'use client'

import { forwardRef } from 'react'

interface ChartShellProps {
  title?: string
  ariaLabel?: string
}

export const ChartShell = forwardRef<SVGSVGElement, ChartShellProps>(
  function ChartShell({ title, ariaLabel }, ref) {
    return (
      <figure
        className="my-8"
        role="img"
        aria-label={ariaLabel ?? title ?? 'Benchmark chart'}
      >
        {title && (
          <figcaption className="text-xs mb-3 font-mono" style={{ color: 'var(--text-muted)' }}>
            {title}
          </figcaption>
        )}
        <div
          className="rounded-xl border overflow-hidden"
          style={{ background: 'var(--bg-card)', borderColor: 'var(--border-color)' }}
        >
          <svg ref={ref} className="w-full" style={{ display: 'block' }} />
        </div>
      </figure>
    )
  },
)
