import { readFile } from 'fs/promises'
import path from 'path'

export async function loadPerfData<T>(slug: string): Promise<T> {
  const filePath = path.join(process.cwd(), 'src/data/perf', `${slug}.json`)
  const raw = await readFile(filePath, 'utf-8')
  return JSON.parse(raw) as T
}
