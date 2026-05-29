# Crucible — Demo 07 §8 hostile cross-read cleanup

Remediation brief for Claude Code. Applies the verbatim-edit findings from `demo-07-hostile-cross-read-findings.md` (plan `demo-07-plan_1.md` §8, audit complete across demos 1–7). Companion docs: `BRIEF.md` (schema, methodology, `cset shield --reset` precondition), `demo-07-plan_1.md`, and the findings doc this brief discharges.

**Branch / staging.** All edits land on the **demo 7 feature branch**. Most are in `site/src/posts/07-flatmap-vs-hashmap.mdx`, but three touch shipped-on-`main` artefacts (`03-simd-blackscholes.mdx`, `06-aos-vs-soa.mdx`, `site/src/app/methodology/page.tsx`). Make those edits on the feature branch too; they reach `main` when demo 7 merges at plan §10, in one PR. Do **not** open a separate main-side PR — a hostile-cross-read cleanup is a single series-consistency pass.

## Context

Demo 7 is on its feature branch, pre-merge (§8/§9 still open). The cross-read read demo 7 against demos 1–6, the methodology page, and the index. It found no stale cross-link copy, consistent statistical conventions, and a sound defensive section. The edits below are numerical-accuracy and cross-series-consistency fixes. Numbers in this brief are anchors only — Tasks 1–2 require confirming them against `site/src/data/perf/07-no-crossover.json` before writing, per the "numbers come from the JSON, not the brief" rule. Per the standing instruction, the "cores 0–7 isolated" footer shorthand is **left alone** on all posts; isolation-set precision is fixed only on the methodology page (Task 6).

## Tasks

### Demo 7 post — `site/src/posts/07-flatmap-vs-hashmap.mdx`

**1. (M-1) Fix the false "slowest by a wide margin" claim at N=4M.**
The `std::map` bullet ends: *"At N ≥ 1 024 the node-based layout loses to the contiguous primitives, and at large N it is the slowest variant by a wide margin (455 ns/op at N = 4 M)."*
At N=4M the JSON has `sorted_vec` ≈ 437.5, `std_map` ≈ 455, `boost_flat` ≈ 457.2 ns/op — `std::map` is not the slowest (boost_flat is), and the three sit within ~4.5%. Confirm the three medians in the JSON, then replace the final sentence with:
*"…and by N = 4 M `std::map`, `vector + lower_bound`, and `boost::flat_map` have converged into a ~440–460 ns/op cluster — all roughly 24× slower than `absl::flat_hash_map`. The wide margin at large N is between the hash maps and this cluster, not within it."*

**2. (M-2) Replace both "within noise" claims.** Two occurrences, both sorted_vec≈boost_flat:
- Headline-chart bullet: *"track each other to within noise across the entire range — they are the same sorted-contiguous primitive."* → *"track each other within ~5% across the entire range — they are the same sorted-contiguous primitive; the residual is Boost's container bookkeeping over a raw vector."*
- Substitution section: replace "to within noise across the entire sweep" with "to within ~5% across the entire sweep" (leave the rest of the sentence).
Confirm ~5% is the worst-case divergence across the lookup sweep against the JSON; use the true figure if it materially exceeds 5%.

**3. (M-3) Note the cache markers are the sorted-contiguous footprint.**
After the marker-derivation sentence (*"…512 KiB L2, 16 MiB L3 per CCX)."*), add:
*"These boundaries are the contiguous (sorted-vector) footprint; the hash-map variants carry slot and metadata overhead, so they cross each tier somewhat earlier than the markers suggest — visible in `absl::flat_hash_map` departing its flat region before the L1 marker."*

**4. (L-2) Footer convention label.** "…median ns_per_op reported." → "…median ns_per_op reported (working-set-sweep convention)." (Leave "cores 0–7 isolated" as-is.)

### Demo 3 post — `site/src/posts/03-simd-blackscholes.mdx`

**5. (M-6) Fix the relative repo link that 404s in deploy.**
Line ~89: *"See the [repo](bench/demos/03-simd-blackscholes/) for all four variants…"*. The target is relative and resolves to `/posts/bench/demos/…` (404). Replace with the full GitHub URL form demos 5/6/7 use:
`[repo](https://github.com/GarethCooke/Crucible/tree/master/bench/demos/03-simd-blackscholes/)`.

### Demo 6 post — `site/src/posts/06-aos-vs-soa.mdx`

**6. (M-5, L-2) Footer + prose pin, and convention label.**
- "single thread pinned to core 4 (CCX1)" (footer) and "pinned to core 4" (line ~195 prose) → "cores 4–7" in both, to match demos 1/3/7 and the methodology page. (Leave "cores 0–7 isolated" as-is.)
- "(scan-throughput convention)" → "(working-set-sweep convention)".

### Methodology — `site/src/app/methodology/page.tsx`

**7. (L-1, L-2) Two label fixes.**
- Commitment 3: "Cores 0–7 are isolated at the kernel level via `isolcpus=1-7`" → "Cores 1–7 are isolated at the kernel level via `isolcpus=1-7`". **Leave the quoted GRUB-entry name** ("Ubuntu (benchmark — cores 0-7 isolated)") unchanged.
- Commitment 4: the demos-6-7 bullet header "**Scan-throughput across a working-set sweep** (demos 6, 7):" → "**Working-set sweep** (demos 6, 7):".

## Acceptance

- `grep -n "within noise" site/src/posts/07-flatmap-vs-hashmap.mdx` → 0 hits.
- `grep -n "slowest variant by a wide margin" site/src/posts/07-flatmap-vs-hashmap.mdx` → 0 hits.
- `grep -n "](bench/demos" site/src/posts/03-simd-blackscholes.mdx` → 0 hits (link is now a full GitHub URL).
- `grep -rn "scan-throughput convention" site/src/posts/` → 0 hits; "working-set-sweep convention" appears in both demo 6 and demo 7 footers.
- `grep -n "pinned to core 4" site/src/posts/06-aos-vs-soa.mdx` → 0 hits; "cores 4–7" present in demo 6's footer and the line-~195 prose.
- Methodology Commitment 3 reads "Cores 1–7 are isolated"; the GRUB-entry quoted string still contains "0-7".
- Numerical claims edited in Tasks 1–2 match `07-no-crossover.json` `ns_per_op.median` for the cited cells to the stated precision.
- Demo 7's headline-chart text carries the markers caveat (Task 3).
- `cd site && npm run build` succeeds; no MDX/parse errors on any edited post.

## Out of scope

- **"cores 0–7 isolated" footer shorthand.** Left as-is on every post per standing instruction; only the methodology page is made precise (Task 7).
- **Demos 1, 2, 4, 5 prose.** Read this cycle and clean — no edits. In particular do not touch their footers, the "CCX slices" wording in demos 4/5, or any cross-link.
- **The demo 7 title (L-3).** Editorial call for the user, not a CC edit.
- **JSON.** No recapture, no re-pretty-print, no field edits to any `*.json`. Tasks 1–2 read the JSON only.
- **Chart components.** No `<TimeVsN>` / `<ThroughputBars>` code changes (see Open items for the M-3 exception).

## Open items for CC to flag

- **M-4 (methodology reproduce path / cset).** The methodology "Building and reproducing" steps document a bare `run_one.sh` with no `cset shield`. Read `bench/scripts/run_one.sh`: if it invokes `cset shield --exec` internally, add one line stating the script runs the binary under `cset shield` (and that `sudo` / `cpuset` tooling is required). If a manual `sudo cset shield --reset` is a precondition the script does **not** perform, document that as a step before the `run_one.sh` line. Either way the page must let a reader reproduce the captured isolation. Surface which case held; do not invent a step. (Not in the Tasks list because the wording depends on this finding — treat it as Task 8 once the harness is read.)
- **M-3 component option.** If `<TimeVsN>` already supports per-variant threshold markers (unlikely), flag it — drawing the hash-map tiers separately would beat the Task 3 caveat sentence, and we'd reconsider. Otherwise Task 3's sentence stands; do not add component code on spec.
- **Task 6 pin.** If demo 6's "core 4" turns out to be a deliberate single-core pin (i.e. the harness for the scan demos pins to one core, not the CCX), stop and flag rather than normalising to "4–7" — the other four sources would then be the loose ones. Default action is the normalisation in Task 6.

## Notes for CC

~9 small edits across four files, plus the M-4 reproduce-path line once the harness is read. The only judgement is M-4 (read the harness first) and the two flag conditions above. Tasks 5–7 touch posts already merged to `main` — intended; they ride the demo 7 feature branch to `main` at §10. Keep the M-4 outcome in the PR description so §9 (pre-merge review) can confirm it against the harness.
