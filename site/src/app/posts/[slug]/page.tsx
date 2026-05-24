import { notFound } from 'next/navigation'
import { readFile } from 'fs/promises'
import path from 'path'
import matter from 'gray-matter'
import { MDXRemote } from 'next-mdx-remote/rsc'
import rehypePrettyCode from 'rehype-pretty-code'
import remarkGfm from 'remark-gfm'
import remarkMath from 'remark-math'
import rehypeKatex from 'rehype-katex'
import type { Metadata } from 'next'
import { CodeCompare } from '@/components/CodeCompare'
import { Benchmark } from '@/components/Benchmark'
import { InProgressNotice } from '@/components/InProgressNotice'
import { PressureSweep } from '@/components/charts/PressureSweep'
import { TimeVsN } from '@/components/charts/TimeVsN'
import { ThroughputBars } from '@/components/charts/ThroughputBars'
import { getAllPosts } from '@/lib/posts'
import { SYNTAX_THEME } from '@/lib/syntax'

const components = { CodeCompare, Benchmark, InProgressNotice, PressureSweep, TimeVsN, ThroughputBars }

const POSTS_DIR = path.join(process.cwd(), 'src/posts')

export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map((p) => ({ slug: p.slug }))
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  try {
    const raw = await readFile(path.join(POSTS_DIR, `${params.slug}.mdx`), 'utf-8')
    const { data } = matter(raw)
    return {
      title: data.title ?? params.slug,
      description: data.summary ?? undefined,
    }
  } catch {
    return { title: params.slug }
  }
}

export default async function PostPage({ params }: { params: { slug: string } }) {
  let source: string
  try {
    source = await readFile(path.join(POSTS_DIR, `${params.slug}.mdx`), 'utf-8')
  } catch {
    notFound()
  }

  const { content, data } = matter(source)

  const allPosts = await getAllPosts()
  const idx = allPosts.findIndex((p) => p.slug === params.slug)
  const prev = idx > 0 ? allPosts[idx - 1] : null
  const next = idx < allPosts.length - 1 ? allPosts[idx + 1] : null

  return (
    <article>
      <div className="flex items-center justify-between mb-12">
        <a
          href="/"
          className="text-sm transition-opacity hover:opacity-70"
          style={{ color: 'var(--text-muted)' }}
        >
          ← All posts
        </a>

        <div className="flex flex-wrap items-center gap-2">
          {prev && (
            <a
              href={`/posts/${prev.slug}`}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded text-sm border transition-colors hover:bg-white/[0.05] min-w-0 flex-1 sm:flex-initial sm:max-w-[220px]"
              style={{ borderColor: 'var(--border-color)', color: 'var(--text-secondary)' }}
              title={prev.title}
            >
              <span className="shrink-0">←</span>
              <span className="truncate">{prev.title}</span>
            </a>
          )}
          {next && (
            <a
              href={`/posts/${next.slug}`}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded text-sm border transition-colors hover:bg-white/[0.05] min-w-0 flex-1 sm:flex-initial sm:max-w-[220px]"
              style={{ borderColor: 'var(--border-color)', color: 'var(--text-secondary)' }}
              title={next.title}
            >
              <span className="truncate">{next.title}</span>
              <span className="shrink-0">→</span>
            </a>
          )}
        </div>
      </div>

      <header className="mb-12">
        <p className="font-mono text-xs uppercase tracking-widest mb-3" style={{ color: 'var(--cyan)' }}>
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
              remarkPlugins: [remarkGfm, remarkMath],
              rehypePlugins: [
                rehypeKatex,
                [
                  rehypePrettyCode,
                  {
                    themes: {
                      dark:  SYNTAX_THEME,
                      light: 'github-light',
                    },
                    keepBackground: false,
                  },
                ],
              ],
            },
          }}
        />
      </div>

      <footer className="mt-16">
        {(prev || next) && (
          <nav className="border-t pt-8 mb-8 grid grid-cols-2 gap-4" style={{ borderColor: 'var(--border-color)' }}>
            <div>
              {prev && (
                <a
                  href={`/posts/${prev.slug}`}
                  className="group block transition-opacity hover:opacity-70"
                >
                  <p
                    className="font-mono text-xs uppercase tracking-widest mb-1 flex items-center gap-1.5"
                    style={{ color: 'var(--text-muted)' }}
                  >
                    ← Previous
                  </p>
                  <p className="font-sans font-medium text-base" style={{ color: 'var(--text-primary)' }}>
                    {prev.title}
                  </p>
                </a>
              )}
            </div>
            <div className="text-right">
              {next && (
                <a
                  href={`/posts/${next.slug}`}
                  className="group block transition-opacity hover:opacity-70"
                >
                  <p
                    className="font-mono text-xs uppercase tracking-widest mb-1 flex items-center justify-end gap-1.5"
                    style={{ color: 'var(--text-muted)' }}
                  >
                    Next →
                  </p>
                  <p className="font-sans font-medium text-base" style={{ color: 'var(--text-primary)' }}>
                    {next.title}
                  </p>
                </a>
              )}
            </div>
          </nav>
        )}

        <div className="border-t pt-8" style={{ borderColor: 'var(--border-color)' }}>
          <a
            href="/methodology"
            className="text-sm transition-opacity hover:opacity-70"
            style={{ color: 'var(--text-muted)' }}
          >
            ← Methodology: how these numbers are produced
          </a>
        </div>
      </footer>
    </article>
  )
}
