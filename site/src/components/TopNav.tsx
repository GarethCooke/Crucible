'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useEffect, useRef, useState } from 'react'

function SunIcon() {
  return (
    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="5" />
      <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" />
    </svg>
  )
}

function MoonIcon() {
  return (
    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
    </svg>
  )
}

function HamburgerIcon() {
  return <path d="M3 12h18M3 6h18M3 18h18" />
}

function CloseIcon() {
  return <path d="M18 6L6 18M6 6l12 12" />
}

const portfolioBase = [
  { href: 'https://garethcooke.com/', label: 'Home' },
  { href: 'https://garethcooke.com/projects', label: 'Projects' },
  { href: 'https://garethcooke.com/contact', label: 'Contact' },
]

const appLinks = [
  { href: '/', label: 'Posts' },
  { href: '/methodology', label: 'Methodology' },
]

export default function TopNav() {
  const pathname = usePathname()
  const [theme, setTheme] = useState<'dark' | 'light'>('dark')
  const [menuOpen, setMenuOpen] = useState(false)
  const pillRef = useRef<HTMLDivElement>(null)
  const navRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    try {
      const stored = localStorage.getItem('theme') as 'dark' | 'light' | null
      const t = stored ?? 'dark'
      setTheme(t)
      document.documentElement.classList.remove('dark', 'light')
      document.documentElement.classList.add(t)
    } catch {}
  }, [])

  function applyTheme(t: 'dark' | 'light') {
    setTheme(t)
    document.documentElement.classList.remove('dark', 'light')
    document.documentElement.classList.add(t)
    try { localStorage.setItem('theme', t) } catch {}
  }

  useEffect(() => {
    const nav = navRef.current
    const pill = pillRef.current
    if (!nav || !pill) return
    const active = nav.querySelector<HTMLElement>('.topnav-link.active')
    if (!active) { pill.style.opacity = '0'; return }
    const navRect = nav.getBoundingClientRect()
    const activeRect = active.getBoundingClientRect()
    pill.style.left = (activeRect.left - navRect.left) + 'px'
    pill.style.width = activeRect.width + 'px'
    pill.style.opacity = '1'
  }, [pathname])

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setMenuOpen(false)
    }
    document.addEventListener('keydown', handler)
    return () => document.removeEventListener('keydown', handler)
  }, [])

  function isActive(href: string) {
    if (href === '/') return pathname === '/' || pathname.startsWith('/posts')
    return pathname === href || pathname.startsWith(href + '/')
  }

  return (
    <header className="topnav">
      <div className="topnav-inner">
        <div className="topnav-brand">
          <a className="topnav-logo" href={`https://garethcooke.com/?theme=${theme}`} aria-label="Gareth Cooke portfolio">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/iguana.svg" alt="Gareth Cooke" />
          </a>
          <a className="topnav-site-name" href="/" aria-label="Crucible home">Crucible</a>
        </div>

        <div className="topnav-desktop" ref={navRef} id="topnav-desktop">
          <div className="topnav-pill" ref={pillRef} id="topnav-pill" />

          {appLinks.map(({ href, label }) => (
            <Link
              key={href}
              href={href}
              className={`topnav-link${isActive(href) ? ' active' : ''}`}
            >
              {label}
            </Link>
          ))}

          <div className="topnav-divider" />

          {portfolioBase.map(({ href, label }) => (
            <a key={href} href={`${href}${href.includes('?') ? '&' : '?'}theme=${theme}`} className="topnav-link">
              {label}
            </a>
          ))}

          <button
            type="button"
            className="topnav-btn"
            onClick={() => applyTheme(theme === 'dark' ? 'light' : 'dark')}
            aria-label="Toggle theme"
          >
            {theme === 'dark' ? <SunIcon /> : <MoonIcon />}
          </button>
        </div>

        <div className="topnav-mobile">
          <button
            type="button"
            className="topnav-btn"
            onClick={() => applyTheme(theme === 'dark' ? 'light' : 'dark')}
            aria-label="Toggle theme"
          >
            {theme === 'dark' ? <SunIcon /> : <MoonIcon />}
          </button>
          <button
            type="button"
            className="topnav-btn"
            id="hamburger-btn"
            onClick={() => setMenuOpen(o => !o)}
            aria-label="Toggle menu"
            aria-expanded={menuOpen}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              {menuOpen ? <CloseIcon /> : <HamburgerIcon />}
            </svg>
          </button>
        </div>
      </div>

      {menuOpen && (
        <div className="topnav-mobile-menu" id="topnav-mobile-menu">
          {appLinks.map(({ href, label }) => (
            <Link
              key={href}
              href={href}
              className={`topnav-mobile-link${isActive(href) ? ' active' : ''}`}
              onClick={() => setMenuOpen(false)}
            >
              {label}
            </Link>
          ))}
          <div className="topnav-mobile-divider" />
          {portfolioBase.map(({ href, label }) => (
            <a key={href} href={`${href}${href.includes('?') ? '&' : '?'}theme=${theme}`} className="topnav-mobile-link">
              {label}
            </a>
          ))}
        </div>
      )}
    </header>
  )
}
