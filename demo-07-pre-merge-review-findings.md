# Crucible — Demo 07 pre-merge review (plan §9)

**Review date:** 2026-05-29
**Method:** Final check of `07-flatmap-vs-hashmap.mdx` against three sources — (1) the captured data `07-no-crossover.json`, (2) the methodology page `app/methodology/page.tsx`, and (3) the conventions established by the six shipped posts `0[1-6]-*.mdx`. Every numerical claim in the prose was re-derived from the JSON medians programmatically; footers, statistical-convention statements, machine spec, and cross-links were diffed against demos 1–6.
**Scope:** Prose, numbers, footer, link/slug integrity, methodology alignment, cross-demo consistency. Not C++, not chart-component source, not the bench README, not the index page (file not in this review set — see L-2).

The post has clearly already had a skeptical pass. The data backs the headline completely: `absl_flat` is the fastest variant in **all 32** distinct `(N, workload, modify_pct)` cells, so "wins at every N and workload mix" is literally true, not rhetorically true. Every specific number quoted in the prose matches the JSON to the stated precision. The findings below are the residue.

---

## Summary

| #   | Severity | Class       | One-line                                                                                                       |
| --- | -------- | ----------- | -------------------------------------------------------------------------------------------------------------- |
| C-1 | Critical | Verify      | Split identity: route/filename `07-flatmap-vs-hashmap` vs data slug `07-no-crossover`. Confirm the loader resolves charts by `slug` prop before merge. |
| M-1 | Material | Consistency | Single-thread pinning described as "CCX1 (cores 4–7)" (L312); demo 6 — the sibling sweep — pins to "core 4" (L214). Harmonise or confirm the capture genuinely differs. |
| M-2 | Material | Factual     | "libstdc++ did not implement `<flat_map>` until GCC 14" (L246–247) is off by one — it landed in GCC 15.        |
| L-1 | Low      | Editorial   | Demo 6 title ends "…not a crossover"; demo 7 title opens "No crossover". Adjacent headlines negating the same word. |
| L-2 | Low      | Verify      | Index card not in review set — confirm at merge it links `/posts/07-flatmap-vs-hashmap`, shows the reframed title, no in-progress pill. |
| L-3 | Low      | Quality     | Throughput-bar label "N = 4 096 (L1 → L2 boundary)" — 4 096 entries = 64 KiB = 2× L1; it's early-L2, not the boundary. |
| L-4 | Low      | Quality     | "near 3.5 ns/op from N = 8 through N ≈ 512" smooths a real bump at N = 16/32 (~4.24 ns, ~21% above 3.5) the chart will show. |

1 critical-to-verify, 2 material, 4 low. No numerical errors found.

---

## Critical

### C-1 — Split identity between route slug and data slug

**Location:** filename `07-flatmap-vs-hashmap.mdx` and inbound links (`01-branch-prediction.mdx:153`, `06-aos-vs-soa.mdx:210`) vs chart `slug="07-no-crossover"` (L89, 133, 142, 151, 176, 188, 200), JSON `07-no-crossover.json`, and source links (L68, 251, 316).

**Problem:** The post carries two slugs. The **route** is `07-flatmap-vs-hashmap` (from the filename; both inbound cross-links and plan §6/§11 use it). The **data** slug is `07-no-crossover` (every chart's `slug` prop, the JSON filename, the bench dir, and all source links). This is internally coherent — charts pass an explicit `slug` prop and the JSON is named to match it — and the reframe from "flatmap-vs-hashmap" to "no-crossover" is correct (the pilot found no crossover, exactly the §1 contingency the plan anticipated). But it only works if the chart data loader resolves JSON by the **`slug` prop**, never by the post route/filename. If anything in the data path derives the JSON name from the route (an index "download JSON" link, a generated OG card, a loader fallback), it will request `07-flatmap-vs-hashmap.json`, which does not exist.

Also note this is a deviation from plan §6, which specified output to `07-flatmap-vs-hashmap.json`. The shipped artefact is `07-no-crossover.json`. That's fine as a decision, but it should be a *decision*, not an accident.

**Action before merge:** Render the page and confirm all eight charts load. Grep the site for any route→JSON derivation. If the loader is prop-driven (expected), this is clean — downgrade to "noted." If not, either rename the JSON to match the route or fix the loader.

---

## Material

### M-1 — Single-thread pinning diverges from demo 6

**Location:** `07-flatmap-vs-hashmap.mdx:311-312` vs `06-aos-vs-soa.mdx:214`

Demo 7 footer: "single thread pinned to **CCX1 (cores 4–7)**".
Demo 6 footer (the only other working-set-sweep demo, same convention, same harness family): "single thread pinned to **core 4 (CCX1)**".

**Problem:** Both are single-threaded. Demo 6 pins to one core; demo 7's wording allows the thread to float across four cores. The JSON has `cpu_affinity: "4-7"` (the `cset` shield set), which is consistent with the demo 7 wording — but for a single-threaded sweep, floating across a 4-core CCX is methodologically *weaker* than demo 6's single-core pin: cross-core migration within the CCX evicts per-core L1/L2 and adds variance the sweep is trying to suppress. Two posts that share a statistical convention and sit next to each other in the cache-staircase narrative should describe their pinning identically.

**Action:** Determine which is true. If the demo 7 capture actually pinned to one core (like demo 6) and the footer just describes the shield set, change L312 to "single thread pinned to core 4 (CCX1)" to match demo 6. If the thread genuinely floated across cores 4–7, that's a real methodology difference from demo 6 — confirm it didn't inflate the medians (the 5-rep IQRs in the JSON are the place to check) and consider whether it warrants a one-line note rather than silent divergence. This is a user/capture question, not a CC edit.

### M-2 — `<flat_map>` availability claim is off by one

**Location:** `07-flatmap-vs-hashmap.mdx:246-247`

> …does not provide `std::flat_map`; libstdc++ did not implement `<flat_map>` until GCC 14.

**Problem:** libstdc++'s `<flat_map>` first appears in **GCC 15**, not GCC 14. The libstdc++ `flat_map` header is documented from gcc-15.1.0; GCC 14 toolchains report no such header. The substitution *rationale* is unaffected — GCC 13.3.0 (this capture's toolchain) lacks `std::flat_map` regardless of whether the cutoff is 14 or 15 — so this doesn't touch any result. It's a citable factual slip that a sharp reader will catch.

**Fix:** Change "until GCC 14" to "until GCC 15", or sidestep the version pinpoint entirely: "…the GCC 13.3 toolchain used here does not provide `std::flat_map`." The second form is safer and needs no future maintenance. (Verify against the GCC 15 release notes / cppreference compiler-support table when applying — cppreference has carried a GCC-14 claim that the shipping toolchains contradict.)

---

## Low

### L-1 — Adjacent titles both negate "crossover"

**Location:** `06-aos-vs-soa.mdx:2` ("…bandwidth amplification, not a crossover") and `07-flatmap-vs-hashmap.mdx:2` ("No crossover: …")

The "no crossover, but a mechanism" framing is a deliberate through-line for the project, and it's earned in both cases. But two consecutive headlines built on negating the same word read as a motif running thin — exactly the repeated-framing drift the §8 hostile cross-read watches for. Editorial call for the user: keep (the repetition reinforces a real finding) or vary demo 7's headline to lead with the actionable result ("`absl::flat_hash_map` wins at every size") and let the body carry the no-crossover beat.

### L-2 — Index card not verified

The index page is not in this review set, so the demo 7 card can't be checked here. Plan §10/§11 require it to link `/posts/07-flatmap-vs-hashmap`, show the reframed title, and carry no in-progress pill once merged. Confirm at merge.

### L-3 — Throughput-bar tier label imprecise

**Location:** `07-flatmap-vs-hashmap.mdx` — `<ThroughputBars targetN={4096} title="N = 4 096 (L1 → L2 boundary)" />`

4 096 entries × 16 B = 64 KiB = 2× the 32 KiB L1d. That's already spilled into L2, not sitting at the L1→L2 boundary. The N = 64 ("L1-resident", 1 KiB) and N = 1 048 576 ("L3 → DRAM boundary", 16 MiB = exactly L3/CCX) labels are precise; only the middle one is loose. Minor — "early L2" or "past L1" would be exact.

### L-4 — "near 3.5" smooths a visible bump

**Location:** `07-flatmap-vs-hashmap.mdx` — first bullet under the headline chart

`absl_flat` lookup is 3.51 @ N=8, then **4.24 @ N=16 and 4.26 @ N=32** (~21% above 3.5), back to 3.50 @ N=64/128. The prose says "sits near 3.5 ns/op from N = 8 through N ≈ 512", which the chart will visibly contradict at the left edge. Defensible as a generalisation, but a reader cross-checking the chart against the sentence will notice the wobble. Optional: "hovers around 3.5–4 ns/op through N ≈ 512".

---

## Verified clean (for the record)

These were checked and are correct — listed so the next pass doesn't re-litigate them.

**Numbers (all re-derived from JSON medians):**
- Lookup: `absl` 3.5 (N=8–512), 3.81 @ 1024, 18.5 @ 4M ✓ · `std_unord` 14.2 @ 64 (4.1×), 29.3 @ 4M (1.58×) ✓ · `sorted_vec` 11.4 @ 8 (3.2×), 48.3 @ 1024 (12.7×), 437.5 @ 4M (23.6×) ✓
- `sorted_vec`↔`boost_flat` tracking: 11.2% max overall, 4.5% max for N ≥ 16 ✓ (post: "~11%", "under 5% for N ≥ 16")
- Modify-mix N=65536 @ 90%: `sorted_vec` 17 308, `boost_flat` 17 217, `absl` 22.2, gap 778× ✓ (post: 17 308 / 17 217 / 22 / "~780×") · `std_map` 340 ✓
- `std::map` small-N edge: beats both `sorted_vec` and `boost_flat` at every N ≤ 512, loses at N=1024 — boundary is exact ✓
- 4M convergence cluster: `std_map`/`sorted_vec`/`boost_flat` = 455/437/457, all 23.6–24.7× `absl` ✓ (post: "~440–460", "roughly 24×")
- `absl_flat` is fastest in all 32 cells — headline universality holds with zero exceptions ✓

**Grid / counts:** 14 lookup N (8→4 194 304), 3 modify N (256/4096/65536), 6 modify_pct (0/10/25/50/75/90), 70 + 90 = 160 cells — matches prose, chart filters, and JSON `notes` ✓

**Cache markers:** L1=2048, L2=32768, L3=1 048 576 — and the arithmetic (32 KiB / 16 B = 2048, etc., for `pair<u64,u64>`) is correct and matches the caption ✓

**Footer / machine vs JSON:** Ryzen 7 3800X, Zen 2, SMT off, GCC 13.3.0, governor=performance, turbo off, `-O3 -march=native -DNDEBUG`, "cores 0–7 isolated (core 0 carries kernel housekeeping)" — all match the JSON `machine` block and the demo 6 convention ✓ (the "0–7 isolated / effective 1-7" reconciliation matches the methodology page's GRUB-label convention)

**Statistical convention:** "5 outer repetitions per cell, median ns_per_op reported (working-set-sweep convention)" matches the methodology page's demos-6-7 group exactly ✓

**Cross-links:** all four present and route-correct — demo 1 → 7 and demo 6 → 7 inbound; demo 7 → 1 and demo 7 → 6 outbound ✓

**Frontmatter:** format consistent with demos 1–6; date 2026-05-26 matches `captured_at` and is the latest in the set ✓
