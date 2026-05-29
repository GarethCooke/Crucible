# Crucible — demo 6 pre-merge review findings

§9 of `demo-06-plan.md`. Mirrors pre-demo-5 phase 2 task 26. Inputs: final `site/src/posts/06-aos-vs-soa.mdx` (216 lines) and `site/src/data/perf/06-aos-vs-soa.json` (135 cells, captured 2026-05-23T21:01:16Z). The MDX has been through §7 (drafting), §8 (hostile cross-read). This is the last gate before §10 (merge).

Method: every numerical claim in the prose round-tripped against the JSON; section structure compared to demo 5's outline as inferred from the 26a polish brief; methodology/Zen-2/CCX framing checked for internal consistency and consistency with demo 5's surviving conventions. Items I could not verify from the artifacts at hand are listed in §"Verifications outside this scope" at the bottom.

Severity legend: **C** critical (blocks merge), **M** medium (fix before merge), **L** low (defer if pressed).

---

## Critical findings

### C-1 — Duplicate H2 heading "The setup"

**Location:** `06-aos-vs-soa.mdx` line 14 and line 35.

**Evidence:** Two `## The setup` H2s, with different content:

- Line 14's section is the folklore framing — "A trading shop's hot path is rarely 'do something to every field of every quote.'" Sets up the question.
- Line 35's section is the benchmark setup — "`bench/demos/06-aos-vs-soa/` sweeps three variants across two axes" plus the `struct Quote` definition.

**Why this is critical:**

- The MDX renderer will generate two anchors for the same slug (`#the-setup`). The second wins, the first becomes unreachable, or one is collision-renamed (`#the-setup-1`) depending on the toolchain. Either way, in-post anchors are broken.
- Any future "link to §The setup of demo 6" lands in the wrong place 50% of the time.
- The TOC (if any) shows duplicate entries.
- Demo 5's section structure (per the 26a brief) uses content-loaded titles like "The freelist-vs-arena trade-off", "Background pressure sweep", "Cross-CCX" — distinctive, never duplicated. Demo 6 should match.

**Fix:** rename one of them. The second one (line 35) is genuinely _the setup_. The first one (line 14) is closer to motivation / problem statement.

Suggested rename for line 14: **"The hot path"** or **"The question"** or **"The folklore answer"**.

I'd pick "The hot path" — it foreshadows the structure of the headline (hot path determines K, which determines layout-mattering).

---

### C-2 — MDX–JSON kernel-name mismatch (XOR vs sum)

**Location:** MDX line 64 vs JSON `runs[*].kernel`.

**Evidence:**

- MDX line 64: _"Each call computes a real reduction (an accumulating XOR of bit-cast fields) so the optimiser can't drop the load."_
- JSON: every cell has `"kernel": "sum_reduction"`. No XOR-named kernels anywhere.

These cannot both be right. Either:

- (a) The bench actually does a sum-reduction (matching the JSON) and the MDX prose is stale — XOR was the §1/§2 plan that got replaced during implementation. Most likely.
- (b) The bench does XOR (matching the MDX) and the JSON metadata is mis-labelled.
- (c) There are two reductions and they got mixed up. Implausible.

**Why this is critical:** the prose makes a specific claim about what the inner loop does. A reader who clones the repo and looks at the bench source will see the mismatch immediately. This is the kind of cross-artifact contradiction the hostile-cross-read discipline is designed to catch.

**Fix:** verify which kernel the bench actually runs, then:

- If sum: change line 64 to _"an accumulating sum of bit-cast fields"_. Single word edit.
- If XOR: update the JSON's `kernel` field to `"xor_reduction"` via post-process (same pattern as demo 5's notes-field fix in the 26a brief — touches metadata only, leaves `captured_at` alone). Then locate the source of the wrong label and fix it for the next capture.

Sum-reduction is the more conventional benchmarking kernel and the more likely truth. Recommend confirming and then editing the MDX.

---

### C-3 — Trailing italics overclaims isolated cores

**Location:** MDX line 211 ("cores 0–7 isolated") vs JSON `isolated_cpus_effective: "1-7"`.

**Evidence:**

- MDX line 211: _"…cores 0–7 isolated, single thread pinned to core 4 (CCX1)…"_
- JSON:
  - `isolated_cpus: "1-7"`
  - `isolated_cpus_requested: "0-7"`
  - `isolated_cpus_effective: "1-7"`

The kernel cmdline requested cores 0–7 to be isolated, but core 0 is effectively not isolated (PID 1 / cpuset v1 affinity issue — same one logged in demo 5's calibration notes). The JSON discloses both fields honestly. The MDX trailing block doesn't.

**Why this is critical for consistency:** demo 5 (per the 26a brief's "out of scope" note) describes the actual state honestly. Demo 6 needs to match, or the pair of posts contradict each other on what the test environment was.

**Fix:** change line 211 from _"cores 0–7 isolated"_ to _"cores 1–7 effectively isolated (cmdline requested 0–7; core 0 reserved for PID 1)"_.

That's wordier than the rest of the italics block. A tighter alternative: _"cores 1–7 isolated"_ — drops the explanation, accepts a tiny loss of information, keeps the italics block uniform.

Either works. Pick one and apply.

---

## Medium findings

### M-1 — "~25% swings" understates the largest adjacent-point variation

**Location:** MDX line 94.

**Evidence:** MDX says: _"IQR/median is at most 1.7% at any of the three points — well below the ~25% swings between adjacent points, so the shape is a real signal rather than measurement noise."_

Actual DRAM-band adjacent-point swings:

| Pair                 | Values        | Swing |
| -------------------- | ------------- | ----- |
| N=131072 → N=262144  | 3.410 → 4.168 | 22.3% |
| N=262144 → N=524288  | 4.168 → 3.995 | 4.2%  |
| N=524288 → N=1048576 | 3.995 → 5.374 | 34.5% |

Average |swing| ≈ 20%. Largest is 34.5%. "~25%" is loose in both directions — too high for one pair (the 4.2% middle swing), too low for the largest.

**Why this matters:** the take-away (1.7% IQR ≪ several-times-larger adjacent-point variation, therefore the non-monotonicity is real signal) is correct. But the specific "~25%" is a number a hostile reader could call out. The argument is more robust with honest framing.

**Fix:** replace "~25% swings between adjacent points" with one of:

- _"adjacent-point swings of 4–35%"_ (range form, accurate)
- _"swings of up to 35% between adjacent points"_ (worst-case form, still correct)
- _"adjacent-point swings an order of magnitude larger than the IQR"_ (qualitative, sidesteps the number)

The middle option preserves the rhetorical force ("well below" → "an order of magnitude below").

---

### M-2 — "Crossing the L3 boundary at AoS K=1 multiplies cost by 4×" — loose framing

**Location:** MDX line 31.

**Evidence:** the post (line 29–31) draws a contrast between L2-step (~15%) and L3-step (4×). Actual numbers:

| Step                                        | Ratio |
| ------------------------------------------- | ----- |
| L2 floor (N=4096) → L3 plateau (N=65k)      | 1.16× |
| L3 plateau end (N=65k) → just past (N=131k) | 2.26× |
| L3 plateau end (N=65k) → DRAM band (N=1M)   | 3.56× |
| L2 floor (N=4096) → DRAM band (N=1M)        | 4.11× |

The "4×" on line 31 matches the L2-floor-to-DRAM ratio (4.11×, also stated correctly on line 92). The phrase "crossing the L3 boundary" suggests the immediate L3-step, which is 2.26×, not 4×.

**Why this matters:** the L2 number on the same line (~15%) is described precisely as the L2-floor → L3-plateau transition. The L3 number "4×" should be described with comparable precision. As written, the two halves of the sentence use different reference points (L2's "~15%" is a single step; L3's "4×" is the full cliff).

**Fix:** keep "4×" if it's the cliff-magnitude framing, but tighten the phrasing. Two options:

- (a) _"The L3 cliff at AoS K=1 — from L2-resident floor to DRAM band — costs 4×."_
- (b) _"The L3 boundary at AoS K=1 starts a cliff that reaches 4× over the L2-resident floor by N=1M."_

Option (a) is tighter. Apply (a) or equivalent.

---

### M-3 — SoA chart's L3 threshold marker (n=2097152) sits outside the swept range

**Location:** MDX line 103, the `<TimeVsN>` for SoA scalar K=1.

**Evidence:**

```jsx
<TimeVsN
  ...
  thresholdMarkers={[{ label: "L2", n: 65536 }, { label: "L3", n: 2097152 }]}
/>
```

The N axis in the data sweeps up to 1,048,576 (max). The L3 marker is at N=2,097,152 — beyond the rightmost data point. The marker's math is right (2,097,152 × 8 B/elem = 16 MB = L3 capacity at SoA K=1), but no data point reaches it.

**Why this matters:** depending on the `<TimeVsN>` component's behaviour, this either:

- (a) renders the L3 marker outside the plotted X-axis range — silently dropped, harmless but the prop is dead code; or
- (b) extends the X axis to include the marker — the data points get compressed to the left two-thirds of the chart, looking odd; or
- (c) renders the marker with overflow — visually ambiguous.

**Fix:** decide what behaviour `<TimeVsN>` actually has, then either:

- Drop the L3 marker from the SoA chart and add a one-line annotation in the prose ("SoA K=1's L3 boundary would land at N=2,097,152 — beyond this sweep"). The post already implies this on line 107.
- Keep the marker if the component handles out-of-range markers gracefully (clipping to the right edge with a "→" or similar).

I'd lean toward dropping and clarifying in prose, because the AoS chart's L3 marker is _inside_ the swept range and visible; the SoA chart's isn't, and the asymmetry between the two charts is itself the point ("SoA K=1 doesn't see the cliff"). Dropping the un-reachable marker makes that asymmetry clearer.

**This needs a visual check on the deployed page either way.**

---

## Low findings

### L-1 — "At most 1.7%" — N=524288 IQR/median is 1.71%

**Location:** MDX line 94, _"IQR/median is at most 1.7% at any of the three points"_.

**Evidence:** the three DRAM-band points have IQR/median of 1.01%, 1.71%, 0.07%. Strictly, 1.71% > 1.7%. Rounding to one decimal place gives 1.7%.

**Fix:** if you care, change to _"at most 1.8%"_ or _"around 1.7%"_. If you don't, leave it — 1.71% rounds to 1.7% by standard convention and most readers won't grade against the third significant figure.

I'd leave it. Flagging only for completeness.

---

### L-2 — K=12 exclusion is in JSON notes, not in MDX

**Location:** JSON `notes` field documents _"K=12 excluded: pilot showed no discontinuity at the cache-line-fill boundary — sits on a smooth ramp between K=8 and K=16."_ The MDX doesn't mention K=12 anywhere.

**Why this matters (or doesn't):** the MDX states K ∈ {1, 2, 4, 8, 16} on line 66, which is accurate. A hostile reader might ask "but K=9 would be the moment AoS starts reading a second cache line — did you check?". The JSON's pilot-finding answer is good, but it's buried.

**Fix:** add one sentence to §The setup or §What happens when you actually use the fields, e.g. before line 156:

> _(K=12 was tested in the calibration pilot — the AoS curve sits on a smooth ramp between K=8 and K=16 with no discontinuity at the cache-line-fill boundary, so it's omitted from the headline sweep.)_

Optional. The post is internally consistent without it. Adds robustness to a hostile read; costs one sentence.

---

### L-3 — JSON `struct_field_count: 16` doesn't match the 12 named fields in the C++ struct

**Location:** JSON metadata on every run vs MDX line 56.

**Evidence:**

- JSON: `struct_field_count: 16` (every cell).
- MDX: _"Twelve named fields, two 64 B cache lines per element"_.
- C++ struct: 12 named 8-byte fields + 24 bytes of explicit padding + 8 B trailing alignas padding = 128 B total.

`struct_field_count: 16` is presumably "number of 8 B slots in the struct" (128 B / 8 B) — but as a label that's misleading; the slot count includes 32 B of padding. The named-field count is 12.

**Why this matters (or doesn't):** the JSON metadata isn't user-facing. No reader of the post will see it unless they go digging. But anyone who builds tooling that reads the JSON's `struct_field_count` to derive "fields per element" will get 16 and be wrong by 4.

**Fix:** two options:

- (a) Leave the JSON alone; document the interpretation in the schema doc or `BRIEF.md` ("struct_field_count = struct_size_bytes / field_type_bytes; this includes padding").
- (b) Patch the JSON in-place (notes-field-bug pattern from demo 5): rename to `struct_slot_count` or split into two fields. Heavier; touches schema.

Defer. Not a merge-blocker. Worth a line in `BRIEF.md` so future demos don't propagate the same convention question.

---

### L-4 — `(scan-throughput convention)` parenthetical in the trailing italics

**Location:** MDX line 211, _"5 outer repetitions per cell, median ns_per_op reported (scan-throughput convention)"_.

**Evidence:** demos 1–5 use mixes of median + p99 + p99.9 for latency-sensitive workloads. Demo 6 reports median only and labels this choice "scan-throughput convention". The phrase is a new label.

**Why this matters (or doesn't):** demo 5 explicitly uses percentiles (p50/p99/p99.9) and explains why. Demo 6 explicitly doesn't. The terminology shift is sensible — scan-throughput workloads have tight ns/op distributions and the median is informative; latency-sensitive workloads need tail statistics. But "scan-throughput convention" presupposes the reader knows what that means.

**Fix:** if the methodology page covers the per-demo statistical convention choice, this parenthetical is fine and points there. If it doesn't, consider either:

- Expanding inline: _"median ns_per_op reported (scan-throughput workloads have tight distributions; this differs from the percentile reporting used in demos 4 and 5)"_. Wordier.
- Linking: _"median ns_per_op reported ([scan-throughput convention](/methodology#statistics))"_ with a matching anchor on the methodology page.

I'd link if there's a methodology section to link to; expand inline only as a fallback. **Hinges on methodology page contents — see §Verifications outside this scope.**

---

## Verifications outside this scope

These are items §9 should normally check, but the artifacts aren't in the inputs I have. Listing them so they can be confirmed before or alongside the cleanup brief.

### V-1 — Methodology page demo count

Plan §7 says: _"Methodology page reviewed — does it reference a demo total that needs bumping?"_

I can't see `site/src/pages/methodology.{mdx,md,astro}` (or wherever it lives). If the methodology page mentions "five demos", it needs to become "six". Quick check before merge.

### V-2 — Forward-links from demo 1 and demo 3 to demo 6

Plan §7 says: _"Cross-links: forward-link from demo 1 (cache-hierarchy intro) and demo 3 (SIMD) inserted; backward-link from demo 6 to those two added."_

Demo 6's _backward_-links to demos 1 and 3 are present (lines 183, 190, 207). The _forward_-links from demos 1 and 3 forward to demo 6 — I can't confirm those from the demo 6 MDX alone. Open the demo 1 and demo 3 MDXs and verify each contains a paragraph or sentence pointing to `/posts/06-aos-vs-soa`. If missing, add.

### V-3 — Demo 6 card on the index page

Plan §10 acceptance: _"Index renders six fully shipped cards (no pill on demo 6)"_. The teaser stub from §0 had an "In Progress" pill — confirm it's removed and the card has summary + date matching the new frontmatter.

### V-4 — `<TimeVsN>` component handles all the prop shapes used here

Demo 6 calls `<TimeVsN>` three times with three different prop shapes:

- Headline AoS: `kFilter={1}`, no `xAxis` (defaults to N), `thresholdMarkers` populated and in-range.
- SoA scalar: `kFilter={1}`, no `xAxis`, `thresholdMarkers` populated but L3 marker is out-of-range (see M-3).
- K-sweep: `kFilter="all"`, `nFilter={1048576}`, `xAxis="k"`, no `thresholdMarkers`.

§5 of the plan implemented `<TimeVsN>` extension for cache-tier markers. Confirm the component handles:

- `kFilter` accepting `number | "all" | number[]` (and that `<ThroughputBars>` also handles `kFilter={[1, 16]}` on line 166).
- `xAxis="k"` mode with `nFilter` as the slice.
- `thresholdMarkers` with N values outside the rendered range (per M-3).

A local `pnpm dev` or `pnpm build` against the new MDX is the right check. If the build passes and the three charts render correctly on `/posts/06-aos-vs-soa`, this is closed.

### V-5 — Lighthouse on `/posts/06-aos-vs-soa`

Same threshold as pre-demo-5 task 26 acceptance: ≥90 perf, ≥90 a11y on the deployed (or local-built) post.

### V-6 — `BRIEF.md` cset-shield-reset hoist

Plan's "Open items" §6 asks whether `BRIEF.md` or `crucible-handover.md` needs the `cset shield --reset` precondition hoisted into the global precondition checklist. The demo-5 detour notes flagged it; demo 6 was a good moment to do it. Confirm whether this was folded into §2 (the brief) and now lives in `BRIEF.md`, or whether it's still only in the demo-5 calibration-notes README. Not blocking for the demo 6 merge specifically; closes the open item.

---

## Pieces this review explicitly did NOT surface

For symmetry with the demo-5 hostile-cross-read findings' "didn't surface" section:

- **No statistical-convention contradictions inside demo 6 itself.** The post commits to median throughout, declares it once in the trailing italics, and doesn't accidentally invoke p99/p99.9 anywhere. The shift from demos 4/5's percentile reporting is signposted.
- **No Zen 2 / CCX factual contradictions.** "16 MB L3 per CCX", "core 4 (CCX1)", "Infinity-Fabric round-trip" (line 192 cross-link to demo 5) all match the architecture facts the prior posts established.
- **No headline-number contradictions against the JSON.** Every percentile/ratio/ns figure I spot-checked round-trips cleanly: 1.31 / 1.48 / 3.41 / 5.37 AoS K=1; 0.77 SoA K=1 at N=1M; 6.98× ratio at K=1; 3.99× SIMD speedup at K=1 L3-resident; 2.52× SIMD speedup at K=16 DRAM-bound; ~0.23 vs ~0.0022 LLC misses per element. All match.
- **Cross-link directions are consistent.** The post forward-links to demo 3 (compute-bound SIMD continuation) and backward-references demos 1 and 5. No orphaned or broken in-post anchors (the §SIMD anchor `#simd-escapes-compute-not-memory` is internally consistent at lines 33, 183, 207).
- **Tonal register matches demo 5.** Declarative, willing to disclose what isn't shown (§What this doesn't show is the right shape — six bounded-scope caveats, not one panicky one). No tonal whiplash between sections.
- **Frontmatter is in the right state.** `status: "in-progress"` removed; no `expectedAt`. `date: "2026-05-24"` (today) is a day after `captured_at` (2026-05-23T21:01) — fine.

---

## Recommendation

Three critical items (C-1, C-2, C-3) plus three medium items (M-1, M-2, M-3). All are 1–3 line text edits to the MDX, except C-2 which depends on a bench-source check first.

Bundle as a single cleanup brief — call it `demo-06-9a-pre-merge-cleanup-brief.md` to mirror the demo-5 26a numbering. Brief structure:

- Part A: MDX edits (C-1, C-3, M-1, M-2, L-1 if user opts in, L-2 if user opts in).
- Part B: C-2 resolution — first verify which kernel the bench actually runs (look at `bench/demos/06-aos-vs-soa/`); then either MDX prose edit (most likely) or JSON post-process.
- Part C: M-3 — visually inspect both charts on a local build; drop the out-of-range L3 marker from the SoA chart or confirm the component renders it acceptably.
- Part D: verifications V-1, V-2, V-3 from outside-scope above (methodology demo-count, forward-links, index card).

After 9a lands: plan §10 (merge) is unblocked.

---

## Stop condition for §9

This findings doc closes §9's audit half. Triage / cleanup half is:

1. User confirms C-2 by spot-checking the bench source (sum or XOR).
2. Opus writes `demo-06-9a-pre-merge-cleanup-brief.md` covering the items above.
3. CC applies the brief.
4. CC reports back on V-3 / V-4 / V-5 from the build.
5. Mark §9 ☑.

Then §10 (merge to main) is clear to land.
