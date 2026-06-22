# Crucible — Demo 05: pressure-sweep no-pressure reference fix

Implementation brief for Claude Code. Touches the `<PressureSweep>` chart component and two prose passages in `05-allocators.mdx`. **Render and prose only — no JSON, no data change.** Self-contained; companion to `BRIEF.md` and `crucible-handover.md`.

## Context

The Demo 05 background-pressure sweep is numerically correct against the committed boost-off capture (`captured_at: 2026-06-05T06:07:50Z`, `turbo:false`, `turbo_source:cpb`, `freq_max_available_mhz:3900`). The p99.9 sweep, straight from `05-allocators.json`:

- `cross-thread-malloc`: 344 (no pressure) → 376 across 100 k/s–1.39 M/s → 360 at 2.68 M/s and up.
- `freelist-return-queue`: 344 at every sweep point, baseline included.
- `arena-batch-handoff`: 344 at every sweep point, baseline included.

The prose matches the data. The **chart** doesn't render it legibly. All three variants' no-pressure references are 344 ns, and both pools' sweep lines are also 344 ns — so the chart stacks three coincident dashed references and two solid pool lines on a single `y = 344`, with only malloc's solid line (376/360) sitting above. Two consequences, both reported from the live site:

1. Malloc's "rise from 344 to 376" has no visible origin — its leftmost plotted sweep point is already at 376, and the 344 baseline is buried in the cluster.
2. The "faint horizontal reference lines" the prose points at are invisible — three coincide at 344, and two sit directly under their own solid sweep lines.

The honest fix: draw a variant's no-pressure reference **only when it diverges from that variant's own sweep**. Here that leaves exactly one reference (malloc's, at 344), and the gap up to malloc's 376/360 solid line becomes the visible rise. The two pools' references are redundant (each equals its own sweep line) and are suppressed. Prose is updated to match.

Note: the project-knowledge copy of this MDX is the superseded **May draft** (the 328 → 424 numbers). This brief targets the committed **June** version — see Preconditions and Open item 1.

## Preconditions

Before any edit, verify the committed artefacts are the June boost-off versions. If any check fails, **stop and report** — do not edit against stale data or stale prose.

Run against the committed JSON:

```python
import json
d = json.load(open('site/src/data/perf/05-allocators.json'))  # adjust to repo path
assert d['captured_at'] == '2026-06-05T06:07:50Z', d['captured_at']
assert d['machine']['turbo'] is False and d['machine']['turbo_source'] == 'cpb'

def p999(variant, bg):
    for r in d['runs']:
        if r['variant'] == variant and r['background_pressure_hz'] == bg:
            return r['latency_ns']['stats']['p99_9']

assert p999('cross-thread-malloc', None)    == 344
assert p999('cross-thread-malloc', 100000)  == 376
assert p999('cross-thread-malloc', 2682695) == 360
assert p999('freelist-return-queue', 100000) == 344
assert p999('arena-batch-handoff', 100000)   == 344
print('JSON sentinel OK')
```

Confirm the committed `05-allocators.mdx` is the June version: frontmatter `date: "2026-06-05"`, and it contains the string `settles back to 360 from 2.7 M/s up`. If the frontmatter date is `2026-05-21`, or the post states `peak of 424` as the live result without the May/June reconciliation paragraph, **stop and flag** — the deployed prose is the stale May draft and needs the June content before this chart tweak applies.

## Tasks

### 1. Gate no-pressure reference lines on divergence from the sweep

**File:** the component backing `<PressureSweep>` — likely `site/src/components/charts/PressureSweep.tsx` (confirm; the chart components live under `site/src/components/charts/`).

The component currently draws a horizontal dashed no-pressure reference for each variant at that variant's no-pressure p99.9. Change it so a variant's reference line is drawn **only if** its no-pressure value differs from that variant's plotted sweep values by more than a tolerance:

- For each variant, compute `diverges = max(|reference − y| for y in that variant's plotted sweep points) > TOL`.
- Draw the dashed reference line (and let the variant contribute to any "no pressure" legend entry) only when `diverges`.
- `TOL`: use a small epsilon (e.g. `1` ns). The values are bucket-quantized under `log2_subbuckets_16`, so a coincident reference is an exact match (diff 0) and a real divergence is ≥ 16 ns at this magnitude — any threshold in `(0, 16)` is correct. If the component already defines an epsilon constant, reuse it.

End state for Demo 05: only `cross-thread-malloc`'s reference renders (dashed at 344), distinct from its solid sweep line at 376/360. `freelist-return-queue` and `arena-batch-handoff` references are suppressed (each equals its own 344 sweep line).

Keep the dashed reference in the variant's own series colour and the existing dash pattern. Do **not** add new text annotations — the existing "no pressure" legend entry plus the now-visible gap is sufficient.

### 2. Align the two prose passages with the rendered chart

**File:** `05-allocators.mdx` (repo path under `site/src/`). The current prose describes plural reference lines "for each variant"; after Task 1 only malloc's renders. Update two passages. Hard-wrap replacements to ~80 cols to match surrounding paragraphs.

**2a. Intro sentence (currently line 164).** Find:

```
a no-T_bg baseline (faint dashed horizontal reference lines)
```

Replace the parenthetical with:

```
a no-T_bg baseline (the faint dashed reference line)
```

Leave the rest of the sentence unchanged.

**2b. Reference-line paragraph (currently lines 185–187).** Find verbatim:

```
The faint horizontal reference lines show each variant's p99.9 with no background
pressure. Both pools' references sit on their sweep lines. Only malloc's sweep
diverges from its no-pressure reference, and only in the moderate-pressure band.
```

Replace with:

```
The dashed line marks malloc's p99.9 with no background pressure (344 ns); the gap
up to its solid sweep line is the moderate-pressure rise. It's the only reference
drawn — both pools sit on 344 ns at every sweep point, baseline included, so their
no-pressure references coincide with their sweep lines and aren't shown separately.
```

The 2b wording is the proposed editorial form — adjust before routing if you want it phrased differently.

## Acceptance

### Site

- `cd site && npm run build` succeeds.
- The divergence gate is present on reference rendering: `grep -n -iE "reference|noPressure|baseline" site/src/components/charts/PressureSweep.tsx` shows the conditional (`TOL`/epsilon comparison) guarding the reference-line draw call, not an unconditional draw.
- Visual: the Demo 05 sweep renders exactly one dashed reference line (at 344, malloc's), sitting below malloc's solid 376/360 line; no dashed reference is drawn coincident with the freelist or arena solid lines.

### Post

- `grep -n "faint dashed horizontal reference lines\|faint horizontal reference lines show each variant\|references sit on their sweep lines" 05-allocators.mdx` returns zero hits.
- `grep -n "the faint dashed reference line\|the only reference\ndrawn\|It's the only reference" 05-allocators.mdx` returns the two new passages.
- No internal contradiction: prose, chart, and JSON all carry 344 (no-pressure and both pools) and 376/360 (malloc band/high); no surviving reference to plural per-variant reference lines.

## Out of scope

- Any change to `05-allocators.json` or any other committed JSON. The data is correct; this is render + prose only. (Includes the `isolated_cpus: "1-7"` value and any machine-block schema items.)
- The numerical values 344 / 376 / 360 — they match the JSON; do not "correct" them.
- The cross-CCX section and its separate capture (`05-allocators-cross-ccx`).
- Refreshing the project-knowledge copy of the MDX from May to June — Opus/user task, not CC.
- Any other demo's MDX, charts, or JSON.
- Series-palette / colour-blind-safety changes (separate brief, M-12) and any re-opening of light/dark theming — read existing CSS vars only.

## Open items for CC to flag

1. **Stale committed prose.** If the committed `05-allocators.mdx` is the May draft (frontmatter `2026-05-21`, or `peak of 424` stated as the live result), stop — the Task 2 find blocks won't match and the deployed post needs the June content first. Report rather than forcing the edit.
2. **JSON sentinel mismatch.** If any Preconditions assertion fails, stop — the committed capture isn't the boost-off corpus and the 344/376/360 contract doesn't hold.
3. **Reference-line mechanism.** If `<PressureSweep>` draws no-pressure references via a mechanism that doesn't map cleanly onto per-variant divergence gating (a single shared baseline line; references computed off a different field), implement the gate at the right locus and report what you found rather than forcing the assumed structure.
4. **Other consumers.** `<PressureSweep>` is used only by Demo 05 in the current MDX set. If the repo has another consumer, verify the divergence gate doesn't hide a meaningful reference there; if it would, scope to avoid the regression and flag.
