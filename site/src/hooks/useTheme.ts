'use client'

import { useEffect, useState } from 'react'

export type Theme = 'dark' | 'light'

export function useTheme(): Theme {
  const [theme, setTheme] = useState<Theme>('dark')

  useEffect(() => {
    const root = document.documentElement
    const read = (): Theme => (root.classList.contains('light') ? 'light' : 'dark')

    setTheme(read())

    const observer = new MutationObserver(() => setTheme(read()))
    observer.observe(root, { attributes: true, attributeFilter: ['class'] })
    return () => observer.disconnect()
  }, [])

  return theme
}
