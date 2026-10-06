import { readdir } from 'fs/promises'
import path from 'path'
import { loadPerfData } from '@/lib/perf-data'
import type { HeadlineSpec, RunSelector } from '@/lib/perf-types'

const PERF_DIR = path.join(process.cwd(), 'src/data/perf')
const SIDECAR_SUFFIX = '.headline.json'

export interface FindingRow {
  slug: string
  /** Two-digit demo number taken from the slug prefix, e.g. "02". */
  num: string
  topic: string
  what_it_is: string
  /** Computed ratio; null for text headlines. */
  value: number | null
  display: string
  condition: string
  finding: string
}

function getPath(obj: unknown, dotted: string): unknown {
  return dotted
    .split('.')
    .reduce<unknown>(
      (o, key) => (o !== null && typeof o === 'object' ? (o as Record<string, unknown>)[key] : undefined),
      obj,
    )
}

function median(values: number[]): number {
  const sorted = [...values].sort((a, b) => a - b)
  const mid = sorted.length >> 1
  return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
}

function resolveSelector(data: unknown, sel: RunSelector, role: string): number {
  const collection = sel.collection ?? 'runs'
  const aggregate = sel.aggregate ?? 'single'
  const desc = `${role} ${JSON.stringify(sel.where)} in "${collection}"`

  if (aggregate !== 'single' && aggregate !== 'median') {
    throw new Error(`${desc}: unknown aggregate "${aggregate}"`)
  }

  const elements = getPath(data, collection)
  if (!Array.isArray(elements)) {
    throw new Error(`${desc}: "${collection}" is not an array`)
  }

  const matches = elements.filter((el) =>
    Object.entries(sel.where).every(([key, want]) => getPath(el, key) === want),
  )
  if (matches.length === 0) {
    throw new Error(`${desc} matched 0 elements`)
  }
  if (aggregate === 'single' && matches.length > 1) {
    throw new Error(`${desc} matched ${matches.length} elements; add where keys until exactly one matches`)
  }

  const values = matches.map((el) => {
    const v = getPath(el, sel.field)
    if (typeof v !== 'number' || !Number.isFinite(v)) {
      throw new Error(`${desc}: field "${sel.field}" is non-numeric (${JSON.stringify(v)})`)
    }
    return v
  })

  return aggregate === 'median' ? median(values) : values[0]
}

async function buildRow(file: string): Promise<FindingRow> {
  const spec = await loadPerfData<HeadlineSpec>(file.slice(0, -'.json'.length))
  const { headline, ...text } = spec
  const num = spec.slug.split('-')[0]

  if (headline.kind === 'text') {
    return { ...text, num, value: null, display: headline.text }
  }
  if (headline.kind !== 'ratio') {
    throw new Error(`unknown headline kind "${(headline as { kind: unknown }).kind}"`)
  }

  const data = await loadPerfData<unknown>(headline.source)
  const numerator = resolveSelector(data, headline.numerator, 'numerator')
  const denominator = resolveSelector(data, headline.denominator, 'denominator')
  if (denominator === 0) {
    throw new Error(`denominator ${JSON.stringify(headline.denominator.where)} is 0`)
  }

  const value = numerator / denominator
  return { ...text, num, value, display: value.toFixed(headline.decimals) + headline.suffix }
}

/**
 * Rows for the homepage "At a glance" table, one per `*.headline.json` sidecar.
 *
 * Runs at build time. Any bad selector throws with the sidecar's filename so
 * `next build` fails rather than shipping a stale or wrong figure. Only the
 * top level of src/data/perf is read, so archive/ is never picked up.
 */
export async function getFindings(): Promise<FindingRow[]> {
  const files = (await readdir(PERF_DIR, { withFileTypes: true }))
    .filter((e) => e.isFile() && e.name.endsWith(SIDECAR_SUFFIX))
    .map((e) => e.name)

  const rows = await Promise.all(
    files.map(async (file) => {
      try {
        return await buildRow(file)
      } catch (err) {
        throw new Error(`${file}: ${err instanceof Error ? err.message : String(err)}`)
      }
    }),
  )

  return rows.sort((a, b) => a.slug.localeCompare(b.slug))
}
