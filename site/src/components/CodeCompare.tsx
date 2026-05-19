import { codeToHtml } from 'shiki'
import { CodeComparePanels } from './CodeComparePanels'
import { SYNTAX_THEME } from '@/lib/syntax'

interface CodeCompareProps {
  lang?: string
  naive: string
  optimized: string
  highlightLines?: number[]
  labels?: [string, string]
}

export async function CodeCompare({
  lang = 'cpp',
  naive,
  optimized,
  highlightLines = [],
  labels = ['Naive', 'Optimised'],
}: CodeCompareProps) {
  const sharedOpts = {
    lang,
    themes: {
      dark:  SYNTAX_THEME,
      light: 'github-light',
    } as const,
    transformers: [
      {
        line(node: { properties: { class?: string; style?: string } }, line: number) {
          if (highlightLines.includes(line)) {
            node.properties.class = (node.properties.class ?? '') + ' highlighted'
          }
        },
      },
    ],
  }

  const [naiveHtml, optimizedHtml] = await Promise.all([
    codeToHtml(naive.trim(), sharedOpts),
    codeToHtml(optimized.trim(), sharedOpts),
  ])

  return (
    <CodeComparePanels
      naiveHtml={naiveHtml}
      optimizedHtml={optimizedHtml}
      labels={labels}
    />
  )
}
