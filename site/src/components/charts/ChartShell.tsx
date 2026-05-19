'use client'

import { forwardRef } from 'react'
import { getColors } from './theme'

interface ChartShellProps {
  title?: string
  ariaLabel?: string
}

export const ChartShell = forwardRef<SVGSVGElement, ChartShellProps>(
  function ChartShell({ title, ariaLabel }, ref) {
    const colors = getColors()
    return (
      <figure
        className="my-8"
        role="img"
        aria-label={ariaLabel ?? title ?? 'Benchmark chart'}
      >
        {title && (
          <figcaption className="text-xs mb-3 font-mono" style={{ color: colors.textMuted }}>
            {title}
          </figcaption>
        )}
        <div
          className="rounded-xl border overflow-hidden"
          style={{ background: colors.bg, borderColor: colors.border }}
        >
          <svg ref={ref} className="w-full" style={{ display: 'block' }} />
        </div>
      </figure>
    )
  },
)
