import { readdir, readFile } from 'fs/promises'
import path from 'path'
import matter from 'gray-matter'

const POSTS_DIR = path.join(process.cwd(), 'src/posts')

export interface PostMeta {
  slug: string
  title: string
  date: string
  summary: string
}

export async function getAllPosts(): Promise<PostMeta[]> {
  let files: string[]
  try {
    files = await readdir(POSTS_DIR)
  } catch {
    return []
  }

  const posts = await Promise.all(
    files
      .filter((f) => f.endsWith('.mdx'))
      .map(async (f) => {
        const slug = f.replace(/\.mdx$/, '')
        const raw = await readFile(path.join(POSTS_DIR, f), 'utf-8')
        const { data } = matter(raw)
        return {
          slug,
          title:   (data.title   as string) ?? slug,
          date:    (data.date    as string) ?? '',
          summary: (data.summary as string) ?? '',
        }
      })
  )

  return posts.sort((a, b) => a.slug.localeCompare(b.slug))
}
