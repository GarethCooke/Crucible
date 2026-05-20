type PostStatus = 'in-progress' | 'shipped'

interface Props {
  status?: PostStatus
  className?: string
}

export function StatusPill({ status, className }: Props) {
  if (!status || status === 'shipped') return null

  if (status === 'in-progress') {
    return (
      <span
        className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium${className ? ` ${className}` : ''}`}
        style={{
          border: '1px solid rgba(245, 158, 11, 0.30)',
          background: 'rgba(245, 158, 11, 0.10)',
          color: '#fcd34d',
        }}
      >
        <span
          aria-hidden
          className="size-1.5 rounded-full"
          style={{ background: '#fbbf24' }}
        />
        In Progress
      </span>
    )
  }

  return null
}
