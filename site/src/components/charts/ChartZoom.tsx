'use client'

import { useRef, useState, useCallback, useEffect } from 'react'
import { createPortal } from 'react-dom'

export function ChartZoom({ children }: { children: React.ReactNode }) {
  const containerRef = useRef<HTMLDivElement>(null)
  const modalSvgRef = useRef<HTMLDivElement>(null)
  const [isOpen, setIsOpen] = useState(false)

  const open = useCallback(() => setIsOpen(true), [])
  const close = useCallback(() => setIsOpen(false), [])

  useEffect(() => {
    if (!isOpen || !modalSvgRef.current) return
    const svg = containerRef.current?.querySelector('svg')
    if (!svg) return
    const clone = svg.cloneNode(true) as SVGSVGElement
    clone.setAttribute('width', '100%')
    clone.removeAttribute('height')
    clone.style.display = 'block'
    modalSvgRef.current.innerHTML = ''
    modalSvgRef.current.appendChild(clone)
  }, [isOpen])

  useEffect(() => {
    if (!isOpen) return
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') close() }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [isOpen, close])

  return (
    <>
      <div
        ref={containerRef}
        className="group relative cursor-zoom-in"
        onClick={open}
        title="Click to enlarge"
      >
        {children}
        <div
          className="absolute top-3 right-3 opacity-0 group-hover:opacity-70 transition-opacity pointer-events-none rounded p-1"
          style={{ background: 'var(--border-color)' }}
          aria-hidden
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" style={{ color: 'var(--text-secondary)' }}>
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
            <line x1="11" y1="8" x2="11" y2="14" />
            <line x1="8" y1="11" x2="14" y2="11" />
          </svg>
        </div>
      </div>
      {isOpen && typeof document !== 'undefined' &&
        createPortal(
          <div
            className="fixed inset-0 z-50 flex items-center justify-center p-6"
            style={{ background: 'rgba(0,0,0,0.87)' }}
            onClick={close}
          >
            <div
              className="w-full max-w-5xl rounded-2xl overflow-auto"
              style={{
                background: 'var(--bg-card)',
                border: '1px solid var(--border-color)',
                maxHeight: '90vh',
                padding: '28px 28px 20px',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div ref={modalSvgRef} />
              <p
                className="text-center text-xs mt-3 font-mono"
                style={{ color: 'var(--text-muted)' }}
              >
                press Esc or click outside to close
              </p>
            </div>
          </div>,
          document.body,
        )
      }
    </>
  )
}
