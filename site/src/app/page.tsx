import type { Metadata } from 'next'
import { getAllPosts } from '@/lib/posts'

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
                <span
                  className="font-mono text-xs shrink-0"
                  style={{ color: 'var(--text-muted)' }}
                >
                  {post.date}
                </span>
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
    </div>
  )
}
