'use client'

import { useRef, useCallback } from 'react'

interface CodeComparePanelsProps {
  naiveHtml: string
  optimizedHtml: string
  labels: [string, string]
}

export function CodeComparePanels({ naiveHtml, optimizedHtml, labels }: CodeComparePanelsProps) {
  const leftRef  = useRef<HTMLDivElement>(null)
  const rightRef = useRef<HTMLDivElement>(null)
  const syncing  = useRef(false)

  const syncScroll = useCallback((source: 'left' | 'right') => {
    if (syncing.current) return
    syncing.current = true
    const from = source === 'left' ? leftRef.current  : rightRef.current
    const to   = source === 'left' ? rightRef.current : leftRef.current
    if (from && to) to.scrollTop = from.scrollTop
    syncing.current = false
  }, [])

  return (
    <div
      className="my-8 rounded-xl overflow-hidden"
      style={{ border: '1px solid var(--border-color)' }}
    >
      {/* Header row */}
      <div
        className="grid grid-cols-2 text-xs font-mono"
        style={{ borderBottom: '1px solid var(--border-color)' }}
      >
        {labels.map((label, i) => (
          <div
            key={i}
            className="px-4 py-2"
            style={{
              background: 'var(--bg-card)',
              color: 'var(--text-muted)',
              borderRight: i === 0 ? '1px solid var(--border-color)' : undefined,
            }}
          >
            {label}
          </div>
        ))}
      </div>

      {/* Code panels */}
      <div className="grid grid-cols-2">
        <div
          ref={leftRef}
          onScroll={() => syncScroll('left')}
          className="overflow-auto max-h-96 text-sm"
          style={{
            background: 'var(--bg-card)',
            borderRight: '1px solid var(--border-color)',
          }}
          dangerouslySetInnerHTML={{ __html: naiveHtml }}
        />
        <div
          ref={rightRef}
          onScroll={() => syncScroll('right')}
          className="overflow-auto max-h-96 text-sm"
          style={{ background: 'var(--bg-card)' }}
          dangerouslySetInnerHTML={{ __html: optimizedHtml }}
        />
      </div>
    </div>
  )
}
