# Brief — demo 9 §10 methodology-page reconciliation

**Source findings:** §10 pre-merge review of `09-arm-neon.mdx` against the methodology page. Addresses §10-M1 (Material), §10-L1 (Low), §10-L2 (Low).

## Context

All edits are to the methodology page component behind the `/methodology` route (`site/src/app/methodology/page.tsx` — confirm the path; it's the file the demo footers link to). No MDX, no benchmark code, no JSON. The demo 9 and demo 3 MDX are already correct from the §9 cleanup brief — **do not touch them**.

These edits bring the methodology page into line with demo 9, the first post on the second reference machine. The one merge-blocker is **M-1**: the page buckets demo 9 under the working-set-sweep convention, but demo 9's footer declares the **throughput** convention. They must agree, and the page is the side that's wrong — demo 9 is the compute-bound sibling of demo 3 (throughput, 20 reps), and its N-sweep carries no cache-tier markers, unlike the working-set demos (6, 7, 8) where the cache sweep _is_ the convention. The two Low items generalise the page's Machine-1-only mechanism descriptions to acknowledge Machine 2.

These are JSX string fragments, not markdown — the source wraps strings across lines with `{" "}` joins and uses `<code>`/`&rsquo;` entities. Match on the **rendered** text below; preserve the file's existing JSX structure and `{" "}` style when inserting.

---

## Tasks

### M-1 — Commitment 4 convention buckets (the merge-blocker)

**Task 1 — throughput bucket: add demo 9.** In the Commitment 4 `<li>` for the throughput convention, change:

> **Throughput / steady-state median** (demos 1, 2, 3): ≥20 outer repetitions (Google Benchmark `--benchmark_repetitions`); aggregates computed across those repetitions.

to:

> **Throughput / steady-state median** (demos 1, 2, 3, 9): ≥20 outer repetitions (Google Benchmark `--benchmark_repetitions`); aggregates computed across those repetitions.

(Only the parenthetical changes: `(demos 1, 2, 3)` → `(demos 1, 2, 3, 9)`.)

**Task 2 — working-set bucket: remove demo 9, revert rep count.** In the Commitment 4 `<li>` for the working-set sweep, change:

> **Working-set sweep** (demos 6, 7, 8, 9): 5–20 outer repetitions per cell; median `ns_per_op` reported. Sweep coverage substitutes for higher per-cell rep count. Each post's footer states the exact rep count used.

to:

> **Working-set sweep** (demos 6, 7, 8): 5 outer repetitions per cell; median `ns_per_op` reported. Sweep coverage substitutes for higher per-cell rep count.

(Three changes: `(demos 6, 7, 8, 9)` → `(demos 6, 7, 8)`; `5–20 outer repetitions` → `5 outer repetitions`; delete the trailing sentence "Each post's footer states the exact rep count used." — it existed only to cover demo 9's 20-rep outlier, now moot.)

### L-1 — "Building and reproducing" is Machine-1-only

**Task 3.** The paragraph describing `run_one.sh` ends:

> `run_one.sh` requires `sudo` and the `cpuset` package (`sudo apt install cpuset` on Ubuntu); it runs the benchmark binary inside a `cset shield` on cores 4–7 and tears the shield down automatically.

Append, as a new sentence in the same paragraph:

> On Machine 2 (the Pi 5) `cset` is not used — Raspberry Pi OS is cgroup v2, which `cset` does not target; AArch64 demos isolate with `isolcpus=2,3` at boot and pin with `taskset -c 3`, as documented in each demo's README.

### L-2 — Commitments 2 and 3 describe only Machine 1

**Task 4 — Commitment 2 (Turbo Boost disabled).** The body ends:

> Boost obscures the true steady-state throughput the predictor and cache hierarchy deliver at nominal frequency.

Append, as a new sentence:

> On Machine 2 there is no BIOS turbo to disable; the equivalent is a pinned clock (governor `performance`, min = max at 2400 MHz) with `get_throttled = 0x0` verified before and after each capture — see Machine 2 above.

**Task 5 — Commitment 3 (Core isolation).** Locate the sentence ending the main body, immediately before the `Cross-CCX results.` sub-paragraph:

> Isolated CPU IDs are recorded in each demo's JSON `machine.isolated_cpus` field.

Append, as a new sentence in the same position (before the `<br /><br />` that precedes the Cross-CCX block):

> On Machine 2 isolation uses `isolcpus=2,3` in the Pi kernel cmdline with benchmarks pinned to core 3 via `taskset -c 3`; the A76 exposes no SMT to disable. See Machine 2 above.

---

## Acceptance

- `grep -c "demos 1, 2, 3, 9"` → 1; `grep -c "demos 6, 7, 8, 9"` → 0.
- `grep -c "5–20 outer repetitions"` → 0; `grep -c "5 outer repetitions per cell"` → 1.
- `grep -c "states the exact rep count used"` → 0.
- L-1: `grep -c "cgroup v2"` → 1 (the new Building-and-reproducing caveat present).
- L-2: Commitment 2 body now contains "get_throttled = 0x0 verified before and after"; Commitment 3 body now contains "isolcpus=2,3 in the Pi kernel cmdline".
- The page type-checks and builds; `/methodology` renders with no JSX error; the four `<Commitment>` blocks and both Reference-machine cards are visually intact.
- §10-M1, §10-L1, §10-L2 in the §10 review are now satisfied — demo 9's footer "(throughput convention)" matches the page's bucketing.

## Out of scope

- `09-arm-neon.mdx` and `03-simd-blackscholes.mdx` — already corrected by the §9 cleanup brief; do not edit.
- The **Reference machines** section (both Machine 1 and Machine 2 cards) — already correct; do not touch the card contents.
- The index page / nine-card render / demo-total bump — that is the §11 merge step, not this brief.
- Commitment 3's GRUB-entry label "Ubuntu (benchmark — cores 0-7 isolated)" — the `0-7` shorthand against the stated `isolcpus=1-7` is pre-existing and tolerated per the standing instruction; **leave it unchanged**.
- Restructuring the four Commitments into per-machine variants — the fix here is appended pointer sentences only, not a rewrite. Do not refactor the `<Commitment>` component or split the commitments per machine.

## Open items for CC to flag

- If a quoted source string isn't found verbatim because of `{" "}` line-joins or entity encoding (`&rsquo;`, `&mdash;`), match on the rendered text and preserve the surrounding JSX style; if a target genuinely can't be located, stop and report rather than guessing the insertion point.
- Confirm the route file path before editing — it is the component rendered at `/methodology`. If the repo uses a different location than `site/src/app/methodology/page.tsx`, edit that file and note the actual path.
- If Task 2's deletion would leave demos 6, 7, 8 with anything other than exactly "5 outer repetitions per cell" in their footers, stop and flag — the revert assumes all three working-set demos are 5-rep (they are, per their shipped footers), and a mismatch would reopen the convention question.
