import { readFile } from 'fs/promises'
import path from 'path'
import matter from 'gray-matter'
import { MDXRemote } from 'next-mdx-remote/rsc'
import rehypePrettyCode from 'rehype-pretty-code'
import rehypeSlug from 'rehype-slug'
import rehypeAutolinkHeadings from 'rehype-autolink-headings'
import remarkGfm from 'remark-gfm'
import type { Metadata } from 'next'
import { SYNTAX_THEME } from '@/lib/syntax'

export const metadata: Metadata = {
  title: "How Grover's search actually works",
  description:
    "A companion explainer to the Measuring the Gap post. What the algorithm is doing inside the circuit — no prior quantum background assumed.",
}

const SOURCE = path.join(
  process.cwd(),
  'src/posts/special/grover-explained.mdx',
)

export default async function GroverExplainedPage() {
  const raw = await readFile(SOURCE, 'utf-8')
  const { content, data } = matter(raw)

  return (
    <article>
      {/* Back navigation */}
      <div className="flex items-center gap-4 mb-12">
        <a
          href="/special/measuring-the-gap"
          className="text-sm transition-opacity hover:opacity-70"
          style={{ color: 'var(--text-muted)' }}
        >
          ← Measuring the Gap
        </a>
        <span style={{ color: 'var(--border-color)' }}>·</span>
        <a
          href="/"
          className="text-sm transition-opacity hover:opacity-70"
          style={{ color: 'var(--text-muted)' }}
        >
          All posts
        </a>
      </div>

      {/* Special edition marker */}
      <div className="mb-6">
        <span
          className="font-mono text-xs uppercase tracking-widest px-2 py-1 rounded border"
          style={{
            color: 'var(--cyan)',
            borderColor: 'var(--cyan)',
            opacity: 0.7,
          }}
        >
          Special edition — companion explainer
        </span>
      </div>

      <header className="mb-12">
        <p
          className="font-mono text-xs uppercase tracking-widest mb-3"
          style={{ color: 'var(--cyan)' }}
        >
          {data.date ?? ''}
        </p>
        <h1
          className="font-sans text-3xl font-semibold tracking-tight mb-4 leading-tight"
          style={{ color: 'var(--text-primary)' }}
        >
          {data.title}
        </h1>
        {data.summary && (
          <p className="text-lg" style={{ color: 'var(--text-secondary)' }}>
            {data.summary}
          </p>
        )}
      </header>

      <div className="prose">
        <MDXRemote
          source={content}
          options={{
            mdxOptions: {
              remarkPlugins: [remarkGfm],
              rehypePlugins: [
                rehypeSlug,
                [
                  rehypeAutolinkHeadings,
                  {
                    behavior: 'append',
                    properties: { className: 'heading-anchor', ariaHidden: true, tabIndex: -1 },
                    content: { type: 'text', value: '#' },
                  },
                ],
                [
                  rehypePrettyCode,
                  {
                    themes: { dark: SYNTAX_THEME, light: 'github-light' },
                    keepBackground: false,
                  },
                ],
              ],
            },
          }}
        />
      </div>

      <footer className="mt-16 border-t pt-8" style={{ borderColor: 'var(--border-color)' }}>
        <a
          href="/special/measuring-the-gap"
          className="text-sm transition-opacity hover:opacity-70"
          style={{ color: 'var(--text-muted)' }}
        >
          ← Back to Measuring the Gap
        </a>
      </footer>
    </article>
  )
}
