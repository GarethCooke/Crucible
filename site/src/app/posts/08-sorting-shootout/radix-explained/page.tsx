import { readFile } from 'fs/promises'
import path from 'path'
import matter from 'gray-matter'
import { MDXRemote } from 'next-mdx-remote/rsc'
import rehypePrettyCode from 'rehype-pretty-code'
import rehypeSlug from 'rehype-slug'
import rehypeAutolinkHeadings from 'rehype-autolink-headings'
import remarkGfm from 'remark-gfm'
import type { Metadata } from 'next'
import { RadixSort } from '@/components/RadixSort'
import { SYNTAX_THEME } from '@/lib/syntax'

export const metadata: Metadata = {
  title: 'How LSD radix sort actually works',
  description:
    "A companion to the main post. The post measures what a radix sort costs and why it beats std::sort on integer keys; this shows the sort actually moving the data — count, position, scatter, one digit at a time — with the step a benchmark can't show you made visible. No prior background assumed.",
}

const SOURCE = path.join(process.cwd(), 'src/posts/companions/08-radix-explained.mdx')

const components = { RadixSort }

export default async function RadixExplainedPage() {
  const raw = await readFile(SOURCE, 'utf-8')
  const { content, data } = matter(raw)

  return (
    <article>
      {/* Back navigation */}
      <div className="flex items-center gap-4 mb-12">
        <a
          href="/posts/08-sorting-shootout"
          className="text-sm transition-opacity hover:opacity-70"
          style={{ color: 'var(--text-muted)' }}
        >
          ← The comparison lower bound is a wall
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

      {/* Companion marker */}
      <div className="mb-6">
        <span
          className="font-mono text-xs uppercase tracking-widest px-2 py-1 rounded border"
          style={{
            color: 'var(--cyan)',
            borderColor: 'var(--cyan)',
            opacity: 0.7,
          }}
        >
          Companion explainer
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
          components={components}
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
          href="/posts/08-sorting-shootout"
          className="text-sm transition-opacity hover:opacity-70"
          style={{ color: 'var(--text-muted)' }}
        >
          ← Back to The comparison lower bound is a wall
        </a>
      </footer>
    </article>
  )
}
