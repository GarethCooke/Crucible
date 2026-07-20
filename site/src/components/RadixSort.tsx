'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import { tokens } from '@/lib/design-tokens'

/*
 * RadixSort — an animated, frame-indexed walkthrough of an LSD radix sort.
 *
 * Companion to demo 08. Runs the real counting-sort machinery on a tiny fixed
 * array (eight two-digit numbers, base 10) so every count / prefix-sum / scatter
 * step is legible. The whole animation is precomputed as an immutable array of
 * frames; rendering is a pure function of the current frame index, so stepping
 * backward is exact and there is no incremental state to get out of sync.
 *
 * Theming rides entirely on CSS custom properties (--text-primary, --bg-card,
 * …) plus three phase accents pulled from the shared design tokens, so the
 * component follows the site's light/dark toggle with no JavaScript.
 */

// ── Fixed problem instance (load-bearing: the MDX prose quotes these) ─────────
const VALUES = [45, 12, 48, 91, 42, 18, 43, 15]
const N = VALUES.length
const RADIX = 10
const PASSES = 2 // ones digit, then tens digit

const digitOf = (v: number, pass: number) => Math.floor(v / 10 ** pass) % 10
const digitName = (pass: number) => (pass === 0 ? 'ones' : 'tens')

// ── Frame model ───────────────────────────────────────────────────────────────
type Row = 'in' | 'out'
type Phase = 'start' | 'count' | 'offsets' | 'scatter' | 'swap' | 'done'
type CodeKey = 'hist' | 'offsets' | 'scatter' | 'swap' | null

interface KeyPos {
  row: Row
  slot: number
}

interface Frame {
  pass: number // -1 during the setup frame
  phase: Phase
  pos: KeyPos[] // indexed by key id (original index)
  counts: number[] // length RADIX
  offsets: number[] // length RADIX
  revealed: boolean // whether bucket positions are shown at all
  revealUpto: number // during 'offsets', positions shown for buckets 0..revealUpto
  readSlot: number | null // input slot being read during 'count'
  activeBucket: number | null
  placedId: number | null // key that just landed during 'scatter'
  filled: boolean[] // which scratch slots hold a key
  payoffIds: number[] // keys highlighted on the final frame (tens digit 4)
  codeLine: CodeKey
  narration: string
}

function buildFrames(): Frame[] {
  const frames: Frame[] = []
  const zeros = () => new Array<number>(RADIX).fill(0)
  const falses = () => new Array<boolean>(N).fill(false)
  const clonePos = (pos: KeyPos[]) => pos.map((p) => ({ row: p.row, slot: p.slot }))
  const idsWithTens = (t: number) => {
    const out: number[] = []
    for (let id = 0; id < N; id++) if (Math.floor(VALUES[id] / 10) % 10 === t) out.push(id)
    return out
  }

  // pos[id] tracks where key `id` currently lives; src[i] is the id in input slot i.
  const pos: KeyPos[] = VALUES.map((_, id) => ({ row: 'in', slot: id }))
  let src = VALUES.map((_, i) => i)

  frames.push({
    pass: -1,
    phase: 'start',
    pos: clonePos(pos),
    counts: zeros(),
    offsets: zeros(),
    revealed: false,
    revealUpto: RADIX - 1,
    readSlot: null,
    activeBucket: null,
    placedId: null,
    filled: falses(),
    payoffIds: [],
    codeLine: null,
    narration:
      "Eight keys, unsorted. We sort by digit, least-significant first: pass 1 orders on the ones digit, pass 2 on the tens. Each pass is a counting sort — count, turn the counts into positions, scatter. No two keys are ever compared.",
  })

  for (let p = 0; p < PASSES; p++) {
    const counts = zeros()
    const offsets = zeros()
    const filled = falses()

    // Phase 1 — histogram: tally each key's current digit.
    for (let i = 0; i < N; i++) {
      const id = src[i]
      const d = digitOf(VALUES[id], p)
      counts[d]++
      frames.push({
        pass: p,
        phase: 'count',
        pos: clonePos(pos),
        counts: counts.slice(),
        offsets: offsets.slice(),
        revealed: false,
        revealUpto: RADIX - 1,
        readSlot: i,
        activeBucket: d,
        placedId: null,
        filled: filled.slice(),
        payoffIds: [],
        codeLine: 'hist',
        narration: `Read ${VALUES[id]}. Its ${digitName(p)} digit is ${d}, so bucket ${d}'s count rises to ${counts[d]}. Just tallying how many keys fall in each bucket — nothing has moved yet.`,
      })
    }

    // Phase 2 — prefix sum: counts become each bucket's starting position.
    let run = 0
    for (let b = 0; b < RADIX; b++) {
      offsets[b] = run
      run += counts[b]
      frames.push({
        pass: p,
        phase: 'offsets',
        pos: clonePos(pos),
        counts: counts.slice(),
        offsets: offsets.slice(),
        revealed: true,
        revealUpto: b,
        readSlot: null,
        activeBucket: b,
        placedId: null,
        filled: filled.slice(),
        payoffIds: [],
        codeLine: 'offsets',
        narration: `Bucket ${b} will start writing at output position ${offsets[b]} — the running total of every earlier bucket's count. Counts turn into starting positions; the running total is now ${run}.`,
      })
    }

    // Phase 3 — scatter: place each key, advancing its bucket's pointer (stable).
    for (let i = 0; i < N; i++) {
      const id = src[i]
      const d = digitOf(VALUES[id], p)
      const dst = offsets[d]
      pos[id] = { row: 'out', slot: dst }
      filled[dst] = true
      offsets[d]++
      frames.push({
        pass: p,
        phase: 'scatter',
        pos: clonePos(pos),
        counts: counts.slice(),
        offsets: offsets.slice(),
        revealed: true,
        revealUpto: RADIX - 1,
        readSlot: null,
        activeBucket: d,
        placedId: id,
        filled: filled.slice(),
        payoffIds: [],
        codeLine: 'scatter',
        narration: `Place ${VALUES[id]} (digit ${d}) at position ${dst}, then bump bucket ${d}'s pointer to ${offsets[d]}. Because the sweep runs left-to-right, equal digits land in input order — that is what makes the pass stable.`,
      })
    }

    // Rebuild the input order from the scattered output.
    const nextSrc = new Array<number>(N)
    for (let id = 0; id < N; id++) nextSrc[pos[id].slot] = id
    src = nextSrc

    if (p < PASSES - 1) {
      // Phase 4 — ping-pong: the scratch buffer becomes the next input.
      for (let s = 0; s < N; s++) pos[src[s]] = { row: 'in', slot: s }
      frames.push({
        pass: p,
        phase: 'swap',
        pos: clonePos(pos),
        counts: zeros(),
        offsets: zeros(),
        revealed: false,
        revealUpto: RADIX - 1,
        readSlot: null,
        activeBucket: null,
        placedId: null,
        filled: falses(),
        payoffIds: [],
        codeLine: 'swap',
        narration: `Pass ${p + 1} done — the array is now ordered by its ${digitName(p)} digit. Swap: the scratch buffer becomes the input for the next pass. This ping-pong is the O(n) scratch memory the post charges radix for.`,
      })
    } else {
      // Final frame: lift the sorted result back up and flag the stability payoff.
      for (let s = 0; s < N; s++) pos[src[s]] = { row: 'in', slot: s }
      frames.push({
        pass: p,
        phase: 'done',
        pos: clonePos(pos),
        counts: zeros(),
        offsets: zeros(),
        revealed: false,
        revealUpto: RADIX - 1,
        readSlot: null,
        activeBucket: null,
        placedId: null,
        filled: falses(),
        payoffIds: idsWithTens(4),
        codeLine: null,
        narration:
          'Sorted — two linear passes, no comparisons. Look at 42, 43, 45, 48 (highlighted): pass 2 grouped them by tens digit 4, and their order within that group is exactly the ones-digit order pass 1 left behind. That is stability doing the work — the whole reason least-significant-first is correct.',
      })
    }
  }

  return frames
}

// ── Geometry (internal stage coordinate system, scaled to fit) ────────────────
const CELL_W = 48
const CELL_H = 40
const CELL_PITCH = 62
const ARR_X0 = 14
const Y_INPUT = 16
const Y_OUTPUT = 178

const BKT_W = 44
const BKT_H = 62
const BKT_PITCH = 50
const BKT_X0 = 8
const Y_BKT = 88

const STAGE_W = 512
const STAGE_H = 222

const cellX = (slot: number) => ARR_X0 + slot * CELL_PITCH
const bktX = (b: number) => BKT_X0 + b * BKT_PITCH

// ── Code panel (base-256 loop; padding aligns the comments) ───────────────────
const CODE_LINES: { key: Exclude<CodeKey, null>; full: string }[] = [
  { key: 'hist', full: 'for (auto k : a) ++count[(k>>s)&0xFF];        // 1 histogram' },
  { key: 'offsets', full: 'for (b) { count[b]=sum; sum+=cnt[b]; }        // 2 prefix sum' },
  { key: 'scatter', full: 'for (auto k : a) tmp[count[(k>>s)&0xFF]++]=k; // 3 scatter' },
  { key: 'swap', full: 'a.swap(tmp);                                  // 4 ping-pong' },
]

// Speed slider bounds (ms). The slider value binds *inverted* to the delay so
// that left = slow and right = fast (see delayFor).
const SPEED_MIN = 180
const SPEED_MAX = 1100
const SPEED_DEFAULT = 620
// Invert: a low slider value (left) yields a long delay (slow); a high value
// (right) yields a short delay (fast).
const delayFor = (sliderValue: number) => SPEED_MIN + SPEED_MAX - sliderValue

const PHASE_META: Record<Phase, { label: string; cls: string }> = {
  start: { label: 'setup', cls: '' },
  count: { label: '1 · count', cls: 'count' },
  offsets: { label: '2 · positions', cls: 'offsets' },
  scatter: { label: '3 · scatter', cls: 'scatter' },
  swap: { label: '4 · ping-pong', cls: 'swap' },
  done: { label: 'sorted', cls: 'done' },
}

const lineAccent = (line: CodeKey): string => {
  switch (line) {
    case 'hist':
      return 'var(--rx-read)'
    case 'offsets':
      return 'var(--rx-route)'
    case 'scatter':
      return 'var(--rx-placed)'
    case 'swap':
      return 'var(--rx-route)'
    default:
      return 'transparent'
  }
}

export function RadixSort() {
  const frames = useMemo(() => buildFrames(), [])
  const last = frames.length - 1

  const [cur, setCur] = useState(0)
  const [playing, setPlaying] = useState(false)
  const [speed, setSpeed] = useState(SPEED_DEFAULT)
  const [scale, setScale] = useState(1)

  const wrapRef = useRef<HTMLDivElement>(null)

  // Scale the fixed-geometry stage down to fit narrow viewports (the ten-bucket
  // row is the binding constraint). Never scales above 1. A small margin keeps
  // the accent glows from clipping / overflowing.
  useEffect(() => {
    const el = wrapRef.current
    if (!el) return
    const measure = () => setScale(Math.min(1, (el.clientWidth - 12) / STAGE_W))
    measure()
    const ro = new ResizeObserver(measure)
    ro.observe(el)
    return () => ro.disconnect()
  }, [])

  // Playback: reschedule one step at a time; stop at the final frame.
  useEffect(() => {
    if (!playing) return
    if (cur >= last) {
      setPlaying(false)
      return
    }
    const t = setTimeout(() => setCur((c) => Math.min(last, c + 1)), delayFor(speed))
    return () => clearTimeout(t)
  }, [playing, cur, speed, last])

  const f = frames[cur]
  const phaseMeta = PHASE_META[f.phase]

  const reset = () => {
    setPlaying(false)
    setCur(0)
  }
  const stepBack = () => {
    setPlaying(false)
    setCur((c) => Math.max(0, c - 1))
  }
  const stepFwd = () => {
    setPlaying(false)
    setCur((c) => Math.min(last, c + 1))
  }
  const togglePlay = () => {
    if (playing) {
      setPlaying(false)
      return
    }
    setCur((c) => (c >= last ? 0 : c)) // restart if parked at the end
    setPlaying(true)
  }

  const showBoth = f.pass < 0
  const onesActive = showBoth || f.pass === 0
  const tensActive = showBoth || f.pass === 1

  const rootStyle = {
    '--rx-read': tokens.color.chart.series[0],
    '--rx-route': tokens.color.chart.series[2],
    '--rx-placed': tokens.color.chart.series[4],
  } as React.CSSProperties

  return (
    <div className="rx-root" style={rootStyle}>
      <style>{STYLES}</style>

      {/* Pass + phase status */}
      <div className="rx-passbar">
        <span className={`rx-pill${f.pass === 0 ? ' on' : ''}`}>Pass 1 · ones digit</span>
        <span className={`rx-pill${f.pass === 1 ? ' on' : ''}`}>Pass 2 · tens digit</span>
        <span className="rx-passbar-spacer" />
        <span className={`rx-phasechip ${phaseMeta.cls}`}>{phaseMeta.label}</span>
      </div>

      {/* Animated stage — scaled to fit; treated as a single image for AT. */}
      <div className="rx-stage-wrap" ref={wrapRef} style={{ height: STAGE_H * scale }}>
        <div
          className="rx-stage"
          role="img"
          aria-label="Diagram of an LSD radix sort. Eight two-digit keys move from an input row, through ten digit buckets that record a count and a position, into a scratch row — one digit per pass. The step-by-step narration below describes each frame."
          style={{ width: STAGE_W, height: STAGE_H, transform: `translateX(-50%) scale(${scale})` }}
        >
          <div className="rx-rowlabel" style={{ left: ARR_X0, top: 0 }}>
            input a[]
          </div>
          <div className="rx-rowlabel" style={{ left: BKT_X0, top: Y_BKT - 16 }}>
            buckets · digit → count / position
          </div>
          <div className="rx-rowlabel" style={{ left: ARR_X0, top: Y_OUTPUT + CELL_H + 2 }}>
            scratch tmp[]
          </div>

          {/* Slot outlines */}
          {Array.from({ length: N }, (_, s) => (
            <div key={`in-${s}`} className="rx-slot" style={{ left: cellX(s), top: Y_INPUT, width: CELL_W, height: CELL_H }} />
          ))}
          {Array.from({ length: N }, (_, s) => (
            <div
              key={`out-${s}`}
              className={`rx-slot${f.filled[s] ? ' solid' : ''}`}
              style={{ left: cellX(s), top: Y_OUTPUT, width: CELL_W, height: CELL_H }}
            />
          ))}

          {/* Buckets */}
          {Array.from({ length: RADIX }, (_, b) => {
            const showPos = f.revealed && b <= f.revealUpto
            return (
              <div
                key={`bkt-${b}`}
                className={`rx-bucket${f.activeBucket === b ? ' on' : ''}`}
                style={{ left: bktX(b), top: Y_BKT, width: BKT_W, height: BKT_H }}
              >
                <div className="rx-bucket-digit">{b}</div>
                <div className="rx-bucket-mini">
                  cnt <b>{f.counts[b]}</b>
                </div>
                <div className="rx-bucket-mini pos">
                  pos <b>{showPos ? f.offsets[b] : '·'}</b>
                </div>
              </div>
            )
          })}

          {/* Persistent value cells (flown between rows via transform) */}
          {VALUES.map((v, id) => {
            const p = f.pos[id]
            const y = p.row === 'in' ? Y_INPUT : Y_OUTPUT
            const reading = f.phase === 'count' && p.row === 'in' && p.slot === f.readSlot
            const placed = f.phase === 'scatter' && f.placedId === id
            const payoff = f.payoffIds.includes(id)
            const tens = Math.floor(v / 10) % 10
            const ones = v % 10
            const cls = ['rx-cell', reading ? 'reading' : '', placed ? 'placed' : '', payoff ? 'payoff' : '']
              .filter(Boolean)
              .join(' ')
            return (
              <div
                key={`cell-${id}`}
                className={cls}
                style={{ width: CELL_W, height: CELL_H, transform: `translate(${cellX(p.slot)}px, ${y}px)` }}
              >
                <span className={`d${tensActive ? ' active' : ''}`}>{tens}</span>
                <span className={`d${onesActive ? ' active' : ''}`}>{ones}</span>
              </div>
            )
          })}
        </div>
      </div>

      {/* Controls */}
      <div className="rx-controls">
        <button type="button" className="rx-btn" onClick={reset} disabled={cur === 0 && !playing}>
          ↺ Reset
        </button>
        <button type="button" className="rx-btn" onClick={stepBack} disabled={cur === 0}>
          ← Back
        </button>
        <button type="button" className="rx-btn primary" onClick={togglePlay}>
          {playing ? '❙❙ Pause' : '▶ Play'}
        </button>
        <button type="button" className="rx-btn" onClick={stepFwd} disabled={cur === last}>
          Step →
        </button>
        <span className="rx-controls-spacer" />
        <label className="rx-speed">
          slow
          <input
            type="range"
            min={SPEED_MIN}
            max={SPEED_MAX}
            step={20}
            value={speed}
            onChange={(e) => setSpeed(Number(e.target.value))}
            aria-label="Animation speed (left slower, right faster)"
          />
          fast
        </label>
        <span className="rx-stepcount" aria-hidden="true">
          {cur} / {last}
        </span>
      </div>

      {/* Narration + code, side by side */}
      <div className="rx-grid">
        <div className="rx-card">
          <h3>What&rsquo;s happening</h3>
          <p className="rx-narration" aria-live="polite">
            {f.narration}
          </p>
        </div>
        <div className="rx-card">
          <h3>The same three phases, in the real code (base 256)</h3>
          <pre className="rx-code" style={{ '--rx-line': lineAccent(f.codeLine) } as React.CSSProperties}>
            {CODE_LINES.map(({ key, full }) => {
              const idx = full.indexOf('//')
              const code = full.slice(0, idx)
              const comment = full.slice(idx)
              return (
                <span key={key} className={`rx-ln${f.codeLine === key ? ' on' : ''}`}>
                  <span>{code}</span>
                  <span className="cmt">{comment}</span>
                </span>
              )
            })}
          </pre>
        </div>
      </div>
    </div>
  )
}

// ── Scoped styles ─────────────────────────────────────────────────────────────
// Everything is prefixed with .rx-root so nothing leaks. Colours come from the
// site's theme custom properties (which track the light/dark toggle) plus the
// three accent vars set inline on .rx-root. No new colour literals are introduced.
const STYLES = `
.rx-root {
  margin: 1.75rem 0;
  font-family: var(--font-body, ui-sans-serif, system-ui, sans-serif);
  color: var(--text-primary);
}
.rx-root *,
.rx-root *::before,
.rx-root *::after { box-sizing: border-box; }

/* Pass + phase bar */
.rx-passbar { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; }
.rx-passbar-spacer { flex: 1 1 auto; }
.rx-pill {
  font-family: var(--font-mono, ui-monospace, monospace);
  font-size: 12px; padding: 3px 11px; border-radius: 999px;
  border: 1px solid var(--border-color); background: var(--bg-card); color: var(--text-muted);
}
.rx-pill.on { color: var(--text-primary); border-color: var(--rx-read); background: color-mix(in srgb, var(--rx-read) 12%, transparent); }
.rx-phasechip {
  font-family: var(--font-mono, ui-monospace, monospace);
  font-size: 12px; padding: 3px 10px; border-radius: 6px;
  border: 1px solid var(--border-color); background: var(--bg-card); color: var(--text-muted);
}
.rx-phasechip.count   { color: var(--rx-read);   border-color: var(--rx-read);   background: color-mix(in srgb, var(--rx-read) 12%, transparent); }
.rx-phasechip.offsets { color: var(--rx-route);  border-color: var(--rx-route);  background: color-mix(in srgb, var(--rx-route) 12%, transparent); }
.rx-phasechip.scatter,
.rx-phasechip.done    { color: var(--rx-placed); border-color: var(--rx-placed); background: color-mix(in srgb, var(--rx-placed) 12%, transparent); }

/* Stage */
.rx-stage-wrap { position: relative; width: 100%; overflow: hidden; }
.rx-stage { position: absolute; left: 50%; top: 0; transform-origin: top center; user-select: none; }
.rx-rowlabel {
  position: absolute;
  font-family: var(--font-mono, ui-monospace, monospace);
  font-size: 10.5px; letter-spacing: 0.02em; color: var(--text-muted); white-space: nowrap;
}
.rx-slot {
  position: absolute; border: 1.5px dashed var(--border-color); border-radius: 8px; background: transparent;
}
.rx-slot.solid { border-style: solid; border-color: var(--border-hover); background: color-mix(in srgb, var(--text-muted) 8%, transparent); }

.rx-cell {
  position: absolute; left: 0; top: 0;
  display: flex; align-items: center; justify-content: center; gap: 1px;
  border-radius: 8px; border: 1.5px solid var(--border-hover); background: var(--bg-card);
  font-family: var(--font-mono, ui-monospace, monospace); font-size: 18px; font-weight: 600;
  color: var(--text-primary);
  transition: transform 0.5s cubic-bezier(0.22, 0.61, 0.36, 1), border-color 0.25s, box-shadow 0.25s, background 0.25s;
  will-change: transform; z-index: 3;
}
.rx-cell .d { opacity: 0.3; }
.rx-cell .d.active { opacity: 1; }
.rx-cell.reading {
  border-color: var(--rx-read); background: color-mix(in srgb, var(--rx-read) 14%, transparent);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--rx-read) 24%, transparent); z-index: 6;
}
.rx-cell.reading .d.active { color: var(--rx-read); }
.rx-cell.placed {
  border-color: var(--rx-placed); background: color-mix(in srgb, var(--rx-placed) 14%, transparent);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--rx-placed) 24%, transparent); z-index: 6;
}
.rx-cell.placed .d.active { color: var(--rx-placed); }
.rx-cell.payoff {
  border-color: var(--rx-placed);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--rx-placed) 30%, transparent);
}

/* Buckets */
.rx-bucket {
  position: absolute; display: flex; flex-direction: column; align-items: center;
  padding-top: 3px; border: 1.5px solid var(--border-color); border-radius: 8px;
  background: var(--bg-card); transition: border-color 0.2s, box-shadow 0.2s, background 0.2s; z-index: 1;
}
.rx-bucket.on {
  border-color: var(--rx-route); background: color-mix(in srgb, var(--rx-route) 12%, transparent);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--rx-route) 22%, transparent);
}
.rx-bucket-digit { font-family: var(--font-mono, ui-monospace, monospace); font-size: 15px; font-weight: 700; line-height: 1; color: var(--text-primary); }
.rx-bucket-mini { font-family: var(--font-mono, ui-monospace, monospace); font-size: 10px; line-height: 1.35; margin-top: 2px; color: var(--text-muted); }
.rx-bucket-mini b { color: var(--text-secondary); font-weight: 600; }
.rx-bucket.on .rx-bucket-mini.pos b { color: var(--rx-route); }

/* Controls */
.rx-controls { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 16px; }
.rx-controls-spacer { flex: 1 1 auto; }
.rx-btn {
  font-family: var(--font-sans, ui-sans-serif, system-ui, sans-serif); font-size: 13px;
  padding: 7px 13px; border-radius: 8px; cursor: pointer;
  border: 1px solid var(--border-color); background: var(--bg-card); color: var(--text-primary);
  transition: background 0.15s, border-color 0.15s, opacity 0.15s;
}
.rx-btn:hover:not(:disabled) { border-color: var(--border-hover); }
.rx-btn:disabled { opacity: 0.4; cursor: default; }
.rx-btn.primary { border-color: var(--rx-read); background: color-mix(in srgb, var(--rx-read) 16%, transparent); }
.rx-btn:focus-visible { outline: 2px solid var(--rx-read); outline-offset: 2px; }
.rx-speed {
  display: flex; align-items: center; gap: 7px;
  font-family: var(--font-mono, ui-monospace, monospace); font-size: 12px; color: var(--text-muted);
}
.rx-speed input[type='range'] { accent-color: var(--rx-read); }
.rx-stepcount { font-family: var(--font-mono, ui-monospace, monospace); font-size: 12px; color: var(--text-muted); min-width: 48px; text-align: right; }

/* Narration + code */
.rx-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-top: 16px; }
.rx-card { border: 1px solid var(--border-color); border-radius: 10px; background: var(--bg-card); padding: 13px 15px; }
/* .rx-root-prefixed so these reliably beat .prose p / .prose h3 element+class rules. */
.rx-root .rx-card h3 {
  margin: 0 0 8px; font-family: var(--font-mono, ui-monospace, monospace);
  font-size: 11px; letter-spacing: 0.05em; text-transform: uppercase; color: var(--text-muted); font-weight: 600;
}
.rx-root .rx-narration { margin: 0; font-size: 14.5px; line-height: 1.55; min-height: 66px; color: var(--text-secondary); }
.rx-root .rx-code { margin: 0; font-family: var(--font-mono, ui-monospace, monospace); font-size: 12.5px; line-height: 1.7; white-space: pre; overflow-x: auto; color: var(--text-secondary); }
.rx-root .rx-ln { display: block; padding: 0 8px; border-radius: 5px; border-left: 2px solid transparent; }
.rx-root .rx-ln.on { background: color-mix(in srgb, var(--rx-line) 12%, transparent); border-left-color: var(--rx-line); color: var(--text-primary); }
.rx-root .rx-code .cmt { color: var(--text-muted); }

@media (max-width: 640px) {
  .rx-grid { grid-template-columns: 1fr; }
}

/* First animated component on the site — respect reduced-motion by removing the
   key-cell tween (stepping jumps instead of sliding). Play still advances. */
@media (prefers-reduced-motion: reduce) {
  .rx-root .rx-cell { transition-duration: 0ms; }
}
`
