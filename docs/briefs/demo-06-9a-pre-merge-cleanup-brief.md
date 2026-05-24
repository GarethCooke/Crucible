# Crucible — demo 06 pre-merge cleanup — CC brief (9a)

Companion to `demo-06-plan.md` §9. The pre-merge review (`demo-06-pre-merge-review-findings.md`) surfaced three Critical and three Medium items. C-2 (the XOR→sum kernel-name mismatch) is already fixed in the working copy of `site/src/posts/06-aos-vs-soa.mdx` — the user has changed line 64 to read _"a floating-point sum of the scanned fields"_. This brief handles the remaining five MDX items plus four site-level verifications in one PR.

Scope: one MDX file (five distinct edits, four definite + one conditional), one cross-MDX wording check against demo 5, one methodology-page check, one index-page check, one local-build/Lighthouse check. No JSON changes, no bench code changes, no recapture.

## Pre-flight (CC: do this first, abort if it fails)

```bash
python3 - << 'EOF'
import json

# JSON sanity (captured 2026-05-23, must not have drifted)
with open('site/src/data/perf/06-aos-vs-soa.json') as f:
    j = json.load(f)

ok = True
if j.get('captured_at') != '2026-05-23T21:01:16Z':
    print(f'CAPTURE DRIFT: {j.get("captured_at")}  (expected 2026-05-23T21:01:16Z)')
    ok = False

# Sentinel values the prose edits assume
runs = {(r['variant'], r['n'], r['k']): r for r in j['runs']}
sentinels = [
    # variant,         n,       k,  field,    expected (to 4 sf, ish)
    ('aos-scalar',    4096,    1, 'median',  1.3062),  # the L2-floor 1.31
    ('aos-scalar',   65536,    1, 'median',  1.5100),  # the L3-plateau-end 1.51
    ('aos-scalar',  131072,    1, 'median',  3.4100),  # the L3-boundary 3.41
    ('aos-scalar',  262144,    1, 'median',  4.168),   # DRAM non-monotonic point
    ('aos-scalar',  524288,    1, 'median',  3.995),   # DRAM non-monotonic point
    ('aos-scalar', 1048576,    1, 'median',  5.3739),  # the DRAM-band 5.37
    ('soa-scalar', 1048576,    1, 'median',  0.7699),  # the 0.77 reference
    ('soa-scalar', 1048576,   16, 'median', 12.6242),  # SIMD section K=16
    ('soa-autovec',1048576,   16, 'median',  5.0079),  # SIMD section K=16
    ('soa-autovec',1048576,    1, 'median',  0.1928),  # SIMD section K=1
]
for v, n, k, field, want in sentinels:
    got = runs.get((v, n, k), {}).get('ns_per_op', {}).get(field)
    if got is None or abs(got - want) > 0.0005:
        print(f'SENTINEL MISMATCH {v} n={n} k={k} {field}: expected ~{want}, got {got}')
        ok = False

# MDX state checks
with open('site/src/posts/06-aos-vs-soa.mdx') as f:
    mdx = f.read()

# C-2 must already be applied (user did this)
if 'floating-point sum of the scanned fields' not in mdx:
    print('MDX state: C-2 fix NOT present — expected "floating-point sum of the scanned fields"')
    ok = False
if 'accumulating XOR' in mdx:
    print('MDX state: stale "accumulating XOR" still present somewhere')
    ok = False

# C-1 must still be pending (two H2s named "The setup")
if mdx.count('\n## The setup\n') != 2:
    print(f'MDX state: expected 2 "## The setup" H2s pending C-1 fix, found {mdx.count(chr(10) + "## The setup" + chr(10))}')
    ok = False

# C-3 must still be pending (italics overclaim cores 0-7)
if 'cores 0–7 isolated' not in mdx:
    print('MDX state: expected "cores 0–7 isolated" pending C-3 fix; either already applied or wording changed')
    ok = False

# M-1 must still be pending ("~25% swings")
if '~25% swings between adjacent points' not in mdx:
    print('MDX state: expected "~25% swings between adjacent points" pending M-1 fix')
    ok = False

# M-2 must still be pending ("multiplies cost by 4×" with no parenthetical)
if 'multiplies cost by 4×. Crossing the L2' not in mdx:
    print('MDX state: expected unparenthesised "multiplies cost by 4×" pending M-2 fix')
    ok = False

print('PRE-FLIGHT PASS' if ok else 'PRE-FLIGHT FAIL — STOP, contact Opus')
EOF
```

If pre-flight fails: stop, surface mismatches, wait. If pass: proceed.

---

## Part A — MDX edits (5 edits on `site/src/posts/06-aos-vs-soa.mdx`)

All five edits are isolated text-level changes at distinct, non-adjacent lines. They don't interact, so apply order doesn't matter. The brief lists them in semantic order (highest-severity first).

### A.1 — Rename the first "## The setup" (C-1, critical)

**Why:** the post has two H2 headings both named "## The setup" (one at line 14, the folklore framing; one at line 35, the actual benchmark setup). The MDX renderer will collide on the `#the-setup` anchor — either the second wins and the first is unreachable, or the toolchain auto-renames to `#the-setup-1` and the in-post anchor convention breaks. Demo 5's section structure uses content-loaded, distinctive titles (`The freelist-vs-arena trade-off`, `Background pressure sweep`, `Cross-CCX`); demo 6 should match.

The first section is really about the workload pattern — what the hot path _is_ — before the thesis. Rename it.

**Current (line 14):**

```
## The setup

A trading shop's hot path is rarely "do something to every field of every quote." It's "scan a million quotes for the one field that matters right now." Filter by symbol. Re-mark by `mid`. Recompute Greeks across the chain. Compress a snapshot for the wire. Each pass touches a small subset of fields, scans a lot of objects, and lives or dies on memory bandwidth.
```

**Replace with:**

```
## The hot path

A trading shop's hot path is rarely "do something to every field of every quote." It's "scan a million quotes for the one field that matters right now." Filter by symbol. Re-mark by `mid`. Recompute Greeks across the chain. Compress a snapshot for the wire. Each pass touches a small subset of fields, scans a lot of objects, and lives or dies on memory bandwidth.
```

Only the heading changes. The second `## The setup` at line 35 stays — it's genuinely the benchmark setup.

After applying, verify the post has exactly one `## The setup` and one `## The hot path`:

```bash
grep -c '^## The setup$' site/src/posts/06-aos-vs-soa.mdx   # expect 1
grep -c '^## The hot path$' site/src/posts/06-aos-vs-soa.mdx  # expect 1
```

### A.2 — Match demo 5's framing of effective isolation (C-3, critical)

**Why:** the trailing italics block claims _"cores 0–7 isolated"_, but the JSON discloses two fields — `isolated_cpus_requested: "0-7"` and `isolated_cpus_effective: "1-7"`. The kernel cmdline asked for 0–7, but cpuset v1 / PID 1's affinity prevents core 0 from being effectively isolated. Demo 5's post (per the 26a brief's "out of scope" note) describes the actual state honestly; demo 6 needs to match or the pair of posts contradict each other on what the test environment was.

**Step 1 — check demo 5's exact wording:**

```bash
grep -n -A1 'isolated\|core 4\|CCX1' site/src/posts/05-allocators.mdx | head -30
```

Look at how demo 5's trailing italics (or equivalent methodology footer) describes the isolated-cores state. Two patterns are likely:

- (a) Demo 5 says something like _"cores 1–7 isolated"_ — the simple, honest form.
- (b) Demo 5 says something longer like _"cores 1–7 effectively isolated (cmdline requested 0–7; core 0 reserved for PID 1)"_ — the fuller explanation form.

**Step 2 — apply edit based on what demo 5 says:**

Current (line 211):

```
*AMD Ryzen 7 3800X, Zen 2 (SMT off), 3.9 GHz base, governor = performance, turbo disabled (BIOS Core Performance Boost off), cores 0–7 isolated, single thread pinned to core 4 (CCX1), headless Ubuntu 24.04. GCC 13.3, -O3 -march=znver2 -fno-tree-vectorize. 5 outer repetitions per cell, median ns_per_op reported (scan-throughput convention).*
```

- If demo 5 uses the short form (a): replace `cores 0–7 isolated` with `cores 1–7 isolated`.
- If demo 5 uses the long form (b): replace `cores 0–7 isolated` with the matching long form, adjusted minimally to fit the demo 6 sentence (the surrounding clauses stay).
- If demo 5 has no equivalent italics block or doesn't address this point at all: use the short form (a) for demo 6, and note in the PR description that demo 5 didn't surface this — it's now a candidate for a separate consistency pass (defer to a future cleanup brief, don't expand this one).

State explicitly in the PR description which of (a) / (b) / (c) you went with, and quote demo 5's relevant sentence so the next reviewer can spot-check.

### A.3 — Tighten "~25% swings" to honest range (M-1, medium)

**Why:** the DRAM-band non-monotonicity paragraph contrasts the IQR (small, ~1.7%) with adjacent-point swings (claimed ~25%). Actual adjacent-point swings in the DRAM band: 22.3%, 4.2%, 34.5%. The "~25%" understates the largest swing and overstates the smallest. The take-away (IQR ≪ adjacent-point variation, therefore non-monotonicity is real signal) holds; only the specific number needs tightening.

**Current (line 94, the long paragraph after the table):**

```
The DRAM band is non-monotonic — N = 262 144 lands at 4.17 ns, N = 524 288 at 3.99 ns, N = 1 048 576 at 5.37 ns. IQR/median is at most 1.7% at any of the three points — well below the ~25% swings between adjacent points, so the shape is a real signal rather than measurement noise. The most likely cause is a TLB / transparent-huge-page / DRAM bank-parallelism interaction: at certain working-set sizes the page table fits in the L1 TLB, at others it spills; transparent-huge-page promotion is probabilistic at this scale. None of that changes the cliff. The chart should be read as "above L3 capacity, AoS-K=1 costs 4–5.5 ns/element with some microarchitectural variation," not as a clean rising line.
```

**Replace with:**

```
The DRAM band is non-monotonic — N = 262 144 lands at 4.17 ns, N = 524 288 at 3.99 ns, N = 1 048 576 at 5.37 ns. IQR/median is at most 1.7% at any of the three points — well below the swings of up to 35% between adjacent points, so the shape is a real signal rather than measurement noise. The most likely cause is a TLB / transparent-huge-page / DRAM bank-parallelism interaction: at certain working-set sizes the page table fits in the L1 TLB, at others it spills; transparent-huge-page promotion is probabilistic at this scale. None of that changes the cliff. The chart should be read as "above L3 capacity, AoS-K=1 costs 4–5.5 ns/element with some microarchitectural variation," not as a clean rising line.
```

Only the clause `well below the ~25% swings between adjacent points` becomes `well below the swings of up to 35% between adjacent points`. The rest is unchanged.

### A.4 — Parenthesise the 4× cliff like the 15% step (M-2, medium)

**Why:** the §Thesis bullet contrasts the L2 boundary step (~15%) with the L3 boundary step (4×). The L2 sentence makes its reference points explicit (`L2-floor 1.31 → L3-plateau 1.48 step`); the L3 sentence doesn't. As a result the "4×" reads as an immediate-after-boundary cost, but it's actually the full L2-floor-to-DRAM-band cliff (4.11×, also stated correctly on line 92). Add a parallel parenthetical to the L3 sentence.

**Current (lines 29–32, the second thesis bullet):**

```
2. **A cache cliff, not a staircase.** The "cache hierarchy" on this machine is binary in practice: things either fit in L3 or they don't. Crossing the L3 boundary at AoS K=1 multiplies cost by 4×. Crossing the L2 boundary on the way out costs ~15% (the L2-floor 1.31 → L3-plateau 1.48 step) and is barely visible against the cliff that follows.
```

**Replace with:**

```
2. **A cache cliff, not a staircase.** The "cache hierarchy" on this machine is binary in practice: things either fit in L3 or they don't. Crossing the L3 boundary at AoS K=1 multiplies cost by 4× (the L2-floor 1.31 → DRAM band 5.37 step). Crossing the L2 boundary on the way out costs ~15% (the L2-floor 1.31 → L3-plateau 1.48 step) and is barely visible against the cliff that follows.
```

The change: insert ` (the L2-floor 1.31 → DRAM band 5.37 step)` after `multiplies cost by 4×`. Now both sentences expose their reference points in parallel form.

### A.5 — SoA chart L3 threshold marker — visual check + conditional edit (M-3, medium)

**Why:** the SoA scalar chart (line 98–105) passes `thresholdMarkers={[{ label: "L2", n: 65536 }, { label: "L3", n: 2097152 }]}`. The L3 marker's math is right — at SoA K=1 the working set is N × 8 B, so 16 MB L3 hits at N=2,097,152 — but no data point reaches that N (the sweep tops out at N=1,048,576). The marker is past the rightmost data point.

The right behaviour depends on what `<TimeVsN>` does with an out-of-range marker. Three plausible outcomes:

- (a) Marker is silently dropped → harmless but the prop is dead code. Fine; the deployed chart looks the same with or without the L3 entry in the array.
- (b) Marker renders clipped to the right edge with a "→" or similar overflow indicator → arguably informative ("here's where the boundary _would_ be").
- (c) Chart's X axis extends to include the marker → data points get compressed to the left two-thirds, looks visually odd.

In (a) and (b), keeping the marker is fine. In (c), it should be dropped.

**Step 1 — local build and visual inspection:**

```bash
cd site
pnpm install --frozen-lockfile  # if not already
pnpm dev &
# open http://localhost:<port>/posts/06-aos-vs-soa in a browser
```

Scroll to the §Headline picture section. The chart immediately after _"Then the same trace for SoA, K=1:"_ (line 96 in the MDX) is the one to check. Compare it visually to the AoS chart immediately above it.

**Step 2 — decide based on what you see:**

- If outcome (a) or (b) — marker absent or clipped cleanly — leave the chart alone. State in the PR description what you observed and that no edit was applied.
- If outcome (c) — X axis extended, data points compressed — apply the edit below.

**Edit (only if outcome (c)):**

Current (lines 98–105):

```jsx
<TimeVsN
  slug="06-aos-vs-soa"
  variants={["soa-scalar"]}
  kFilter={1}
  yAxisLabel="ns per element"
  thresholdMarkers={[
    { label: "L2", n: 65536 },
    { label: "L3", n: 2097152 },
  ]}
  title="SoA scalar, K=1 — same one field, contiguous"
/>
```

Replace with:

```jsx
<TimeVsN
  slug="06-aos-vs-soa"
  variants={["soa-scalar"]}
  kFilter={1}
  yAxisLabel="ns per element"
  thresholdMarkers={[{ label: "L2", n: 65536 }]}
  title="SoA scalar, K=1 — same one field, contiguous"
/>
```

(Drops the L3 entry from `thresholdMarkers`; everything else identical.)

No prose change is needed — line 107 already explains that SoA K=1 at the largest N is still half-L3-capacity, so the chart's absence of an L3 marker is consistent with what the text says.

State explicitly in the PR description which of (a) / (b) / (c) was observed and whether the edit was applied.

---

## Part B — Site-level verifications (4 checks outside the MDX)

These were listed in §"Verifications outside this scope" of the findings doc. None require code changes by default — they're checks that may or may not surface follow-up work.

### B.1 — Methodology page demo count (V-1)

Plan §7 acceptance: _"Methodology page reviewed — does it reference a demo total that needs bumping?"_

```bash
grep -nE 'five demos|5 demos|five posts|5 posts' site/src/pages/methodology.{mdx,md,astro} 2>/dev/null
grep -nE 'demos? 1[-– ]5|demo[s]? one through five' site/src/pages/methodology.{mdx,md,astro} 2>/dev/null
```

(Adjust path for your repo's methodology page location — could be `site/src/pages/methodology.mdx`, `site/src/content/methodology.mdx`, or elsewhere; `find site/src -iname 'methodology*'` if uncertain.)

If matches found: bump to _"six demos"_ / _"6 demos"_ / _"demos 1–6"_ respectively. State the edits in the PR description.

If no matches found: the methodology page doesn't reference a total count, no edit needed. Note in the PR description.

### B.2 — Forward-links from demos 1 and 3 to demo 6 (V-2)

Plan §7 acceptance: _"Cross-links: forward-link from demo 1 (cache-hierarchy intro) and demo 3 (SIMD) inserted; backward-link from demo 6 to those two added."_

Demo 6's backward-links to demos 1, 3, 5 are present and correct (lines 183, 190, 192, 207 of the MDX). The forward-links from demos 1 and 3 — pointing forward to demo 6 — need confirming.

```bash
grep -n '06-aos-vs-soa\|demo 6\|Demo 6' site/src/posts/01-branch-prediction.mdx
grep -n '06-aos-vs-soa\|demo 6\|Demo 6' site/src/posts/03-simd-blackscholes.mdx
```

- If both posts already reference demo 6: ✓, note in PR description.
- If either is missing the forward-link: surface the relevant section of that post (a couple of paragraphs around where a forward-link would naturally sit — usually near a §Takeaway, §What this doesn't show, or a footer cross-link section) and **stop before editing**. Forward-link insertion in demos 1 or 3 is a different post's content change; it needs Opus drafting before CC applies. Flag in the PR description as deferred to a follow-up brief.

### B.3 — Index card state (V-3)

Plan §10 acceptance: _"Index renders six fully shipped cards (no pill on demo 6)"_. The teaser stub from §0 had `status: "in-progress"` and an `expectedAt` field in its frontmatter — those drove an "In Progress" pill on the index card. The final MDX's frontmatter no longer has those fields (verified during the pre-merge review).

Verify the index page (likely `site/src/pages/index.{astro,mdx}` or similar) renders demo 6 without the pill on a local build:

```bash
# with `pnpm dev` running from B.5
# open http://localhost:<port>/ and look at the six demo cards
```

Visual check only. State in PR description: card present, no pill, summary text matches the MDX frontmatter summary, date shows 2026-05-24.

### B.4 — Lighthouse on `/posts/06-aos-vs-soa` (V-5) + build pass (V-4)

`pnpm build` must pass without MDX errors, then Lighthouse on the post must show ≥ 90 perf, ≥ 90 a11y (matching the pre-demo-5 task 26 acceptance threshold).

```bash
cd site
pnpm build
# expect: no errors, all 6 post pages emitted
```

If `pnpm build` fails on `06-aos-vs-soa.mdx`: surface the error and stop. The most likely culprit is one of the chart components rejecting a prop shape — `<TimeVsN>` is called with `kFilter={1}`, `kFilter="all"`, and `xAxis="k"` modes; `<ThroughputBars>` is called with `kFilter={[1, 16]}`. If the component types reject any of these, that's a §5 (component implementation) regression and needs a follow-up brief, not a 9a fix.

If build passes, run Lighthouse:

```bash
pnpm preview &
npx lighthouse http://localhost:<port>/posts/06-aos-vs-soa --only-categories=performance,accessibility --output=json --output-path=/tmp/lh-06.json --chrome-flags='--headless'
python3 -c "import json; d=json.load(open('/tmp/lh-06.json')); print(f'perf={d[\"categories\"][\"performance\"][\"score\"]*100:.0f}, a11y={d[\"categories\"][\"accessibility\"][\"score\"]*100:.0f}')"
```

State both scores in the PR description. If either is < 90, surface the Lighthouse audit details and flag for a separate follow-up (don't try to fix in 9a).

### B.5 — (deferred) BRIEF.md cset-shield-reset hoist (V-6)

The demo-06-plan "Open items" §6 asked whether `BRIEF.md` or `crucible-handover.md` should hoist the `sudo cset shield --reset` precondition into the global precondition checklist. This is independent of the demo 6 merge — closes a separate open item from the plan.

Quick check:

```bash
grep -n 'cset shield' BRIEF.md crucible-handover.md
```

If either file already documents `cset shield --reset` as a precondition: ✓, V-6 closed, note in PR description.

If neither does: don't add it in 9a — out of scope. Flag in the PR description as a follow-up: _"`cset shield --reset` precondition still only lives in the demo-5 calibration-notes README; consider hoisting to `BRIEF.md` as a separate one-line edit."_

---

## Acceptance criteria

After CC's PR lands:

**MDX (Part A):**

- C-1: post has exactly one `## The hot path` (line 14) and exactly one `## The setup` (line 35); no duplicate H2s anywhere.
- C-3: trailing italics block describes the isolated-cores state in a way that matches `site/src/posts/05-allocators.mdx`'s wording, or uses the honest short form _"cores 1–7 isolated"_ if demo 5 doesn't address this. PR description quotes demo 5's relevant sentence.
- M-1: `~25% swings between adjacent points` no longer appears; replaced with `swings of up to 35% between adjacent points`.
- M-2: the line-31 4× cliff sentence has the parenthetical `(the L2-floor 1.31 → DRAM band 5.37 step)` added, parallel to the L2 sentence's parenthetical.
- M-3: the SoA chart's `thresholdMarkers` array either still contains both `L2` and `L3` entries (visual outcome (a) or (b)) or contains only `L2` (visual outcome (c)). PR description states which outcome and what was applied.
- All other numerical claims in the MDX still traceable to the 2026-05-23 JSON values (no incidental drift introduced).
- C-2 (already-applied) sentinel `floating-point sum of the scanned fields` is still present on line 64.

**Site-level (Part B):**

- B.1: methodology page demo count bumped if needed, or PR description confirms no count to bump.
- B.2: forward-links from demos 1 and 3 confirmed present, or flagged for a follow-up brief.
- B.3: index page renders six cards, no in-progress pill on demo 6 card.
- B.4: `pnpm build` passes, Lighthouse on `/posts/06-aos-vs-soa` reports both scores in the PR description (≥ 90 / ≥ 90 expected).
- B.5: V-6 either confirmed already-documented or flagged as a separate follow-up.

**General:**

- JSON unchanged. `captured_at: 2026-05-23T21:01:16Z` after the PR, same as before.
- No bench code changes. No recapture.
- PR description states explicitly which finding each commit (or logical edit) closes.

## Out of scope

- L-1 (the "at most 1.7%" / 1.71% rounding nit) — leave it. Standard rounding convention.
- L-2 (K=12 exclusion disclosure in MDX) — the JSON `notes` field documents this and the post's K-sweep range is internally consistent. Defer.
- L-3 (JSON `struct_field_count: 16` vs 12 named fields) — convention question, not user-facing. Defer; consider a `BRIEF.md` schema-doc note in a separate brief.
- L-4 ("(scan-throughput convention)" parenthetical clarity) — depends on methodology page contents; if B.1 surfaces that the methodology page has a section explaining the median-vs-percentile convention choice, consider linking from the parenthetical in a separate brief. Don't expand inline in this PR.
- Forward-link insertion into demos 1 and 3 (B.2 follow-up) — Opus drafts those before CC applies.
- `BRIEF.md` cset-shield-reset hoist (B.5 follow-up) — separate one-line brief if needed.
- Any C++ source / bench code changes.
- Any chart-component (`<TimeVsN>`, `<ThroughputBars>`) implementation changes — if B.4's build surfaces a prop-shape rejection, that's a §5 regression and needs its own brief.

## Open items for CC to flag during implementation

1. **A.2 wording choice.** Quote demo 5's exact sentence about isolated cores, and state which of (a) / (b) / (c) was applied to demo 6.
2. **A.5 visual outcome.** State (a) / (b) / (c) explicitly, and whether the chart edit was applied.
3. **B.1 outcome.** State whether the methodology page needed bumping; if yes, state the exact edit. If no methodology page count was found, state that.
4. **B.2 outcome.** Did both demo 1 and demo 3 have forward-links? If either was missing, surface the section that should contain the link and flag for follow-up.
5. **B.3 outcome.** Index card looks right? No pill?
6. **B.4 Lighthouse scores.** State both numbers.
7. **B.5 outcome.** Already-documented or flagged?

If any one of these blocks (build fails, M-3 reveals outcome (c) and a chart component issue, demo 1/3 missing forward-links require Opus drafting): land what's clean, flag the rest, stop.

## Brief ordering

This brief is the cleanup half of `demo-06-plan.md` §9. The plan sequence:

- §1–§8: ☑
- §9 (pre-merge review): ☑ (via the review that produced this brief)
- This brief (9a, pre-merge cleanup): pending CC
- §10 (merge to main): unblocked once 9a lands
- §11 (post-ship verification): user manual, post-merge

Once 9a lands and demo 5's `site/src/posts/05-allocators.mdx` has been spot-checked for the A.2 wording reference, demo 6 is ship-ready.
