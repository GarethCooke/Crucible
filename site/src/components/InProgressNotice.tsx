interface Props {
  expectedAt: string
}

export function InProgressNotice({ expectedAt }: Props) {
  return (
    <div
      className="my-6 rounded-md px-4 py-3 text-sm"
      style={{
        border: '1px solid rgba(245, 158, 11, 0.30)',
        background: 'rgba(245, 158, 11, 0.05)',
      }}
    >
      <p className="font-medium" style={{ color: '#fcd34d' }}>
        This post is in progress.
      </p>
      <p className="mt-1" style={{ color: 'rgba(253, 230, 138, 0.80)' }}>
        Expected to land in {expectedAt}. The implementation and measurements aren&apos;t
        complete — what follows is a tease of what the post will cover.
      </p>
    </div>
  )
}
