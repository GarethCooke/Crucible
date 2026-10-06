import type { ReactNode } from 'react'
import type { FindingRow } from '@/lib/findings'

interface Props {
  rows: FindingRow[]
}

// Editorial text marks identifiers with backticks (e.g. `if`); render those as code.
function withCode(text: string): ReactNode[] {
  return text.split('`').map((part, i) => (i % 2 ? <code key={i} className="font-mono text-[0.9em]">{part}</code> : part))
}

// Padding mirrors the post list (px-4, w-6 number, gap-6) so the Topic column
// lines up with the post titles below.
const thClass = 'font-mono text-xs font-normal uppercase tracking-wider text-left pb-3 pr-6 first:pl-4 last:pr-4'
const tdClass =
  'align-baseline py-4 pr-6 first:pl-4 last:pr-4 first:rounded-l-lg last:rounded-r-lg transition-colors group-hover:bg-white/[0.03]'

/**
 * Homepage "At a glance" summary: one row per numbered demo.
 *
 * lg and up is a real <table>; each row links to its post via a stretched
 * link on the topic (an <a> cannot wrap a <tr>). Below lg the same rows
 * render as stacked cards; between sm and lg the table is too cramped.
 */
export function FindingsTable({ rows }: Props) {
  return (
    <>
      <table className="hidden lg:table -mx-4 w-[calc(100%+2rem)] border-separate border-spacing-0">
        <thead>
          <tr style={{ color: 'var(--text-muted)' }}>
            <th className={thClass} scope="col">#</th>
            <th className={thClass} scope="col">Topic</th>
            <th className={thClass} scope="col">Headline</th>
            <th className={thClass} scope="col">Measured at</th>
            <th className={thClass} scope="col">Finding</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.slug} className="group relative">
              <td className={`${tdClass} font-mono text-xs`} style={{ color: 'var(--text-muted)' }}>
                <span className="inline-block w-6">{row.num}</span>
              </td>
              <td className={`${tdClass} w-[34%]`}>
                <a
                  href={`/posts/${row.slug}`}
                  className="font-sans font-medium text-base group-hover:text-white transition-colors after:absolute after:inset-0"
                  style={{ color: 'var(--text-primary)' }}
                >
                  {row.topic}
                </a>
                <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
                  {withCode(row.what_it_is)}
                </p>
              </td>
              <td
                className={`${tdClass} font-mono text-lg whitespace-nowrap tabular-nums`}
                style={{ color: 'var(--cyan)' }}
              >
                {row.display}
              </td>
              <td className={`${tdClass} text-sm w-[18%]`} style={{ color: 'var(--text-secondary)' }}>
                {row.condition}
              </td>
              <td className={`${tdClass} text-sm`} style={{ color: 'var(--text-secondary)' }}>
                {row.finding}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <ul className="lg:hidden space-y-px">
        {rows.map((row) => (
          <li key={row.slug}>
            <a
              href={`/posts/${row.slug}`}
              className="group flex items-baseline gap-6 rounded-lg px-4 py-4 -mx-4 transition-colors hover:bg-white/[0.03]"
            >
              <span className="font-mono text-xs shrink-0 w-6" style={{ color: 'var(--text-muted)' }}>
                {row.num}
              </span>
              <div className="flex-1 min-w-0">
                <h3
                  className="font-sans font-medium text-base mb-1 group-hover:text-white transition-colors"
                  style={{ color: 'var(--text-primary)' }}
                >
                  {row.topic}
                </h3>
                <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                  {withCode(row.what_it_is)}
                </p>
                <p className="text-sm mt-3" style={{ color: 'var(--text-secondary)' }}>
                  <span className="font-mono text-lg tabular-nums mr-3" style={{ color: 'var(--cyan)' }}>
                    {row.display}
                  </span>
                  {row.condition}
                </p>
                <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
                  {row.finding}
                </p>
              </div>
            </a>
          </li>
        ))}
      </ul>
    </>
  )
}
