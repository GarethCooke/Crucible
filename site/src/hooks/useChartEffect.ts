'use client'

import { useEffect, useRef, type DependencyList } from 'react'
import { select } from 'd3-selection'
import { useTheme } from './useTheme'

export function useChartEffect(
  render: (el: SVGSVGElement) => void,
  deps: DependencyList,
): React.RefObject<SVGSVGElement> {
  const ref = useRef<SVGSVGElement>(null)
  const theme = useTheme()
  // Hold latest render fn without making it a dep (avoids new-closure churn).
  const renderRef = useRef(render)
  renderRef.current = render

  useEffect(() => {
    if (!ref.current) return
    select(ref.current).selectAll('*').remove()
    renderRef.current(ref.current)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, theme])

  // Cast: ChartShell's forwardRef<SVGSVGElement> predates React 19's RefObject<T|null> typing.
  return ref as React.RefObject<SVGSVGElement>
}
