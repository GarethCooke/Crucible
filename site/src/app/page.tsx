import type { Metadata } from 'next'
import { getAllPosts } from '@/lib/posts'
import { StatusPill } from '@/components/StatusPill'

export const metadata: Metadata = {
  title: 'Crucible',
  description: 'High-performance C++ benchmarking. Naive vs tuned, real hardware measurements.',
}

export default async function HomePage() {
  const posts = await getAllPosts()

  return (
    <div>
      <section className="mb-16 fu">
        <p
          className="text-sm font-mono uppercase tracking-widest mb-4"
          style={{ color: 'var(--cyan)' }}
        >
          crucible.garethcooke.com
        </p>
        <h1
          className="font-sans text-4xl font-semibold tracking-tight mb-4"
          style={{ color: 'var(--text-primary)' }}
        >
          C++ performance engineering,<br />measured.
        </h1>
        <p className="text-lg max-w-2xl" style={{ color: 'var(--text-secondary)' }}>
          Each post is a focused optimisation problem — naive vs tuned implementations,
          real hardware measurements on a documented reference machine, and visualisations
          of system behaviour rather than algorithm steps.
        </p>
      </section>

      <section>
        <h2
          className="font-sans text-xs font-semibold uppercase tracking-widest mb-6"
          style={{ color: 'var(--text-muted)' }}
        >
          Posts
        </h2>

        <ul className="space-y-px">
          {posts.map((post, i) => (
            <li key={post.slug}>
              <a
                href={`/posts/${post.slug}`}
                className="group flex items-baseline gap-6 rounded-lg px-4 py-4 -mx-4 transition-colors hover:bg-white/[0.03]"
              >
                <span
                  className="font-mono text-xs shrink-0 w-6"
                  style={{ color: 'var(--text-muted)' }}
                >
                  {String(i + 1).padStart(2, '0')}
                </span>
                <div className="flex-1 min-w-0">
                  <h3
                    className="font-sans font-medium text-base mb-1 group-hover:text-white transition-colors"
                    style={{ color: 'var(--text-primary)' }}
                  >
                    {post.title}
                  </h3>
                  <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                    {post.summary}
                  </p>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  {post.status === 'in-progress' && (
                    <StatusPill status={post.status} />
                  )}
                  <span
                    className="font-mono text-xs"
                    style={{ color: 'var(--text-muted)' }}
                  >
                    {post.date}
                  </span>
                </div>
              </a>
            </li>
          ))}
        </ul>

        {posts.length === 0 && (
          <p className="text-sm" style={{ color: 'var(--text-muted)' }}>
            First post coming soon.
          </p>
        )}
      </section>

      {/* Special editions — outside the C++ cadence, not included in the numbered total */}
      <section className="mt-16">
        <div className="flex items-center gap-3 mb-6">
          <h2
            className="font-sans text-xs font-semibold uppercase tracking-widest"
            style={{ color: 'var(--text-muted)' }}
          >
            Special editions
          </h2>
          <span
            className="font-mono text-xs px-2 py-0.5 rounded border"
            style={{ color: 'var(--cyan)', borderColor: 'var(--cyan)', opacity: 0.6 }}
          >
            outside standard methodology
          </span>
        </div>

        <ul className="space-y-px">
          <li>
            <a
              href="/special/measuring-the-gap"
              className="group flex items-baseline gap-6 rounded-lg px-4 py-4 -mx-4 transition-colors hover:bg-white/[0.03]"
            >
              {/* Pill in place of a number */}
              <span
                className="font-mono text-xs shrink-0 w-6"
                style={{ color: 'var(--cyan)' }}
              >
                ★
              </span>
              <div className="flex-1 min-w-0">
                <h3
                  className="font-sans font-medium text-base mb-1 group-hover:text-white transition-colors"
                  style={{ color: 'var(--text-primary)' }}
                >
                  Measuring the gap
                </h3>
                <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                  Take a problem with a famous theoretical quantum speedup, run it both ways, and measure
                  the gap between the promise and the silicon. Grover's algorithm on IBM quantum hardware
                  vs classical linear search. Classical wins decisively; this post shows precisely why.
                </p>
              </div>
              <div className="flex items-center gap-2 shrink-0">
                <StatusPill status="in-progress" />
                <span
                  className="font-mono text-xs hidden sm:block"
                  style={{ color: 'var(--text-muted)' }}
                >
                  quantum
                </span>
                <span
                  className="font-mono text-xs"
                  style={{ color: 'var(--text-muted)' }}
                >
                  2026-06-02
                </span>
              </div>
            </a>
          </li>
        </ul>
      </section>
    </div>
  )
}
