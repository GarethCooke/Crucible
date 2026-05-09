import { notFound } from 'next/navigation'
import { readFile, readdir } from 'fs/promises'
import path from 'path'
import matter from 'gray-matter'
import { MDXRemote } from 'next-mdx-remote/rsc'
import rehypePrettyCode from 'rehype-pretty-code'
import type { Metadata } from 'next'
import { CodeCompare } from '@/components/CodeCompare'
import { Benchmark } from '@/components/Benchmark'
import { ThroughputBars } from '@/components/charts/ThroughputBars'
import { CounterOverlay } from '@/components/charts/CounterOverlay'

const components = { CodeCompare, Benchmark, ThroughputBars, CounterOverlay }

const POSTS_DIR = path.join(process.cwd(), 'src/posts')

export async function generateStaticParams() {
  const files = await readdir(POSTS_DIR)
  return files
    .filter((f) => f.endsWith('.mdx'))
    .map((f) => ({ slug: f.replace(/\.mdx$/, '') }))
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

  return (
    <article>
      <header className="mb-12 fu">
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

      <div className="prose fu1">
        <MDXRemote
          source={content}
          components={components}
          options={{
            mdxOptions: {
              rehypePlugins: [
                [
                  rehypePrettyCode,
                  {
                    theme: 'github-dark-dimmed',
                    keepBackground: false,
                  },
                ],
              ],
            },
          }}
        />
      </div>

      <footer className="mt-16 pt-8 border-t" style={{ borderColor: 'var(--border-color)' }}>
        <a
          href="/methodology"
          className="text-sm transition-opacity hover:opacity-70"
          style={{ color: 'var(--text-muted)' }}
        >
          ← Methodology: how these numbers are produced
        </a>
      </footer>
    </article>
  )
}
