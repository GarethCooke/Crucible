import type { Metadata } from 'next'
import { Inter, Space_Grotesk, JetBrains_Mono } from 'next/font/google'
import './globals.css'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
})

const spaceGrotesk = Space_Grotesk({
  subsets: ['latin'],
  variable: '--font-space-grotesk',
  display: 'swap',
})

const jetbrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-jetbrains-mono',
  display: 'swap',
})

export const metadata: Metadata = {
  title: {
    default: 'Crucible',
    template: '%s · Crucible',
  },
  description:
    'High-performance C++ benchmarking. Naive vs tuned, real hardware measurements, visualised system behaviour.',
  metadataBase: new URL('https://crucible.garethcooke.com'),
  openGraph: {
    siteName: 'Crucible',
    locale: 'en_GB',
    type: 'website',
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${spaceGrotesk.variable} ${jetbrainsMono.variable}`}
    >
      <body>
        <header className="border-b" style={{ borderColor: 'var(--border-color)' }}>
          <div className="max-w-4xl mx-auto px-6 py-4 flex items-center justify-between">
            <a
              href="/"
              className="font-sans font-semibold text-lg tracking-tight"
              style={{ color: 'var(--text-primary)' }}
            >
              Crucible
            </a>
            <nav className="flex items-center gap-6 text-sm" style={{ color: 'var(--text-secondary)' }}>
              <a href="/methodology" className="hover:text-white transition-colors">Methodology</a>
              <a
                href="https://garethcooke.com"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-white transition-colors"
              >
                garethcooke.com ↗
              </a>
            </nav>
          </div>
        </header>

        <main className="max-w-4xl mx-auto px-6 py-12">
          {children}
        </main>

        <footer
          className="border-t mt-24"
          style={{ borderColor: 'var(--border-color)', color: 'var(--text-muted)' }}
        >
          <div className="max-w-4xl mx-auto px-6 py-8 flex items-center justify-between text-sm">
            <span>Crucible · MIT</span>
            <a
              href="https://garethcooke.com"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-white transition-colors"
            >
              garethcooke.com
            </a>
          </div>
        </footer>
      </body>
    </html>
  )
}
