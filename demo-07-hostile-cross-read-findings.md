# Crucible — demo 7 hostile cross-read findings (plan §8)

**Read date:** 2026-05-29 (updated same day with demos 2–5)
**Method:** Back-to-back read of demo 7 (`07-flatmap-vs-hashmap.mdx`, on the feature branch) against demos 1–6 as shipped, the `/methodology` page source, and the index page source. Watching for the five drift classes named in `demo-07-plan_1.md` §8: statistical-convention drift, Zen 2 / CCX framing consistency, methodology consistency, tonal drift, repeated or contradictory caveats. Numerical claims cross-checked against the recovered JSON analysis (160 runs, 5 variants).
**Scope:** Prose, structure, footers, cross-link integrity, numerical self-consistency, methodology reconciliation. Not C++, not the JSON schema, not chart-component code.
**Coverage:** All of demos 1–7 read. Per the user's standing instruction, the "cores 0–7 isolated" footer shorthand is left as-is on the posts (all captures assume the `isolcpus=1-7` set); isolation-set precision is treated as load-bearing only on the methodology page.

---

## Summary

| #   | Severity | Area              | Class       | One-line                                                                                                              |
| --- | -------- | ----------------- | ----------- | --------------------------------------------------------------------------------------------------------------------- |
| M-1 | Material | demo 7            | Numerical   | "std::map slowest by a wide margin" at N=4M is wrong — boost_flat is slower, and the three trail within ~4.5% (line 116) |
| M-2 | Material | demo 7            | Numerical   | "within noise" for sorted_vec≈boost_flat (~4.5% at N=4M) — and the same spread is called a "wide margin" elsewhere      |
| M-3 | Material | demo 7            | Factual     | Cache-tier markers derived from the 16 B pair footprint; don't fit the hash-map variants — prose contradicts own marker |
| M-4 | Material | methodology       | Methodology | `/methodology` reproduce path omits the `cset shield` session precondition that demos 5–7 captures actually require     |
| M-6 | Material | demo 3            | Bug         | Relative repo link `[repo](bench/demos/03-simd-blackscholes/)` (line 89) 404s in the static deploy                      |
| M-5 | Low      | demo 6 footer     | Drift       | Demo 6 says "pinned to core 4"; demos 1/3/7 + methodology all say "cores 4–7" — single outlier                          |
| L-1 | Low      | methodology       | Factual     | Commitment 3 says "Cores 0–7 are isolated via `isolcpus=1-7`" — the param isolates 1–7; cpu0 is explicitly not isolated |
| L-2 | Low      | demo 7 / demo 6   | Drift       | Demo 7 footer omits the "(…convention)" label demos 1/6 carry; "scan-throughput" is a misnomer for demo 7's map ops     |
| L-3 | Low      | demo 6 / demo 7   | Structural  | Two consecutive posts headline "no crossover" / "not a crossover" with the same folklore→no-crossover→mechanism arc     |

4 material + 1 material bug + 4 low. M-1, M-2, M-5, M-6, L-1, L-2 are 1–3 line text edits. M-3 and M-4 need a one-line judgement call before the edit.

---

## Material findings

### M-1 — Demo 7: "std::map slowest by a wide margin" is false at N=4M

**Location:** `07-flatmap-vs-hashmap.mdx:111-116`

**Quote:** *"At N ≥ 1 024 the node-based layout loses to the contiguous primitives, and at large N it is the slowest variant by a wide margin (455 ns/op at N = 4 M)."*

**Problem:** At N=4M the trailing cluster is `sorted_vec` 437.5, `std_map` 455, `boost_flat` 457.2 ns/op. So `std::map` is **not** the slowest — `boost_flat` is, by ~2 ns — and there is no "wide margin" among the three: they sit within ~4.5% of each other. The "loses to the contiguous primitives" clause is likewise only half true at N=4M (std_map beats boost_flat, loses to sorted_vec). The genuine "wide margin" is between the hash maps (18.5 / 29.3) and the trailing cluster, not within it. A hostile reader pulls the JSON and sees the cluster immediately.

**Fix:** *"…and by N = 4 M `std::map`, `vector + lower_bound`, and `boost::flat_map` have converged into a ~440–460 ns/op cluster — all roughly 24× slower than `absl::flat_hash_map`. The wide margin at large N is between the hash maps and this cluster, not within it."*

---

### M-2 — Demo 7: "within noise" overclaim, and inconsistent treatment of the same ~5% spread

**Locations:** `:104-106` and `:241` (the load-bearing one)

**Quotes:** *"track each other to within noise across the entire range"* and *"its lookup curve tracks `sorted_vec` to within noise across the entire sweep — empirical confirmation that the substitution does not change the story."*

**Problem:** At N=4M the two are 437.5 vs 457.2 ns/op — ~4.5% apart. With 5 reps/cell and no IQR shown anywhere in the post, "within noise" is unsupported and almost certainly false: demo 2's measured floor is IQR/median under 0.4% at 20 reps (`02-false-sharing.mdx:122`), an order of magnitude tighter. The deeper problem is internal: the post treats this ~5% spread as **noise** when comparing sorted_vec↔boost_flat (M-2) and as a **wide margin** when ranking std_map (M-1). It can't be both. (Line 108 also cites only the lower of the two, 437.5; the 457.2 boost_flat figure isn't shown.) Note demo 5 uses "within sample-noise" correctly — for two values that are literally equal (`05-allocators.mdx:154`, both 720 ns); demo 7's is the one that stretches the term.

**Fix:** Replace "to within noise" with a claim that survives the JSON: *"track each other within ~5% across the sweep — consistent with being the same sorted-contiguous primitive, modulo Boost's container bookkeeping."* That explains the residual rather than waving it away, and is *more* convincing for the substitution argument than "noise." Resolve M-1 in the same pass so the two magnitude descriptions agree.

---

### M-3 — Demo 7: cache-tier markers fit the sorted-vector footprint, not the hash maps

**Locations:** `:17-21` (CACHE_MARKERS), `:80-82` (derivation), `:96-97` (prose)

**Problem:** The markers are placed at N = 2048 / 32768 / 1048576, derived as "32 KiB L1d, 512 KiB L2, 16 MiB L3 ÷ 16 B per `pair<uint64_t,uint64_t>`." Correct for `sorted_vec` / `boost_flat` (contiguous 16 B/entry) but not for `absl_flat` / `std_unord`, which carry load-factor and control-byte overhead (and the lookup keeps a resident 4096-entry index), so the hash maps spill to the next tier at a lower N than the marker. The prose shows the seam: `absl::flat_hash_map` "only rises meaningfully once the table exceeds L1" at **N≈512** (`:96`), well left of the L1 marker drawn at **N=2048**. A cache-aware reader — the target audience — notices the band and the curve disagree.

**Fix (small judgement call):** Either (a) one sentence under the headline chart: *"markers are the sorted-contiguous footprint; the hash-map variants carry slot overhead and cross each tier somewhat earlier,"* or (b) per-variant annotation if the chart component supports it. (a) is cheap and honest; (b) is more work than it's worth here.

---

### M-4 — Methodology: reproduce path omits the `cset shield` session precondition

**Location:** `/methodology` — "Building and reproducing" and Commitment 3.

**Problem:** The page documents core isolation as `isolcpus=1-7` + `taskset` only, and the reproduce steps are a plain `run_one.sh <NN-slug>` with no `cset shield`. But every fresh capture for demos 5–7 runs under `cset shield` (the cpuset-v1 / PID-1 affinity precondition hoisted to `BRIEF.md` at demo 6 close-out, recorded per-run in the JSON `isolated_cpus_source`). Keeping cset *off the posts* is the right call — all seven post footers correctly omit it, consistent with the plan's reasoning that surfacing it would manufacture a non-existent confound. But the methodology page is the reproduce reference, and it reconciles the cset/isolcpus lineage nowhere reader-visible. (Confirmed: none of demos 1–7 mention cset; the methodology page is the only candidate place and it doesn't.)

**Fix:** One line in "Building and reproducing": *"Fresh capture sessions run under `sudo cset shield --reset` before `run_one.sh`; see each demo's bench README."* — or, if `run_one.sh` fully encapsulates the shield, state that so the bare command is genuinely sufficient. CC determines which from the harness.

---

### M-6 — Demo 3: relative repo link 404s in deploy

**Location:** `03-simd-blackscholes.mdx:89`

**Quote:** *"See the [repo](bench/demos/03-simd-blackscholes/) for all four variants and the polynomial helpers."*

**Problem:** The link target `bench/demos/03-simd-blackscholes/` is relative, so from the deployed post at `/posts/03-simd-blackscholes` it resolves to `/posts/bench/demos/03-simd-blackscholes/` — a 404. This is the pre-demo-5 M-7 link class, still live in demo 3. Demos 5, 6, and 7 all use full GitHub URLs (`https://github.com/GarethCooke/Crucible/tree/master/bench/demos/<slug>/`); demo 3 is the lone holdout.

**Fix:** `[repo](https://github.com/GarethCooke/Crucible/tree/master/bench/demos/03-simd-blackscholes/)`.

---

## Low findings

### M-5 — Demo 6 pin description is the lone outlier

**Locations:** `06-aos-vs-soa.mdx:195, :214`; vs `01:262`, `03:251`, `07:304`, `/methodology` Commitment 3.

Demos 1, 3, 7 and the methodology page all say "pinned to (cores) 4–7"; demo 6 says "pinned to core 4" (footer and line ~195 prose). Demos 4 and 5 name specific per-thread cores (4/5, 4/5/6) appropriate to their multi-thread topologies — not part of this drift. Per the standing "assume uniform setup" instruction this is wording-only and optional, but demo 6 is a single clean outlier.

**Fix (optional):** Normalise demo 6's "core 4" → "cores 4–7" in both places to match the other four sources.

### L-1 — Methodology: "cores 0–7 isolated" vs `isolcpus=1-7`

`/methodology` Commitment 3 opens *"Cores 0–7 are isolated at the kernel level via `isolcpus=1-7`…"* — but `isolcpus=1-7` isolates **1–7**, and the same commitment explains cpu0 carries unmovable kernel work (so cpu0 is not isolated). Per the standing instruction this is left alone in the post footers; on the methodology page it should be precise.

**Fix:** "Cores 1–7 are isolated at the kernel level via `isolcpus=1-7`…". Leave the quoted GRUB-entry name ("Ubuntu (benchmark — cores 0-7 isolated)") unchanged — it is the literal boot-entry label.

### L-2 — Demo 7 footer drops the convention label; "scan-throughput" is a misnomer for demo 7

Demo 1 footer: "(throughput convention)". Demo 6: "(scan-throughput convention)". Demo 7 (`:306`): no label. Add one. Separately, the methodology page groups demos 6 **and 7** under "Scan-throughput across a working-set sweep," but demo 7 measures map lookup/modify *operations*, not a scan.

**Fix:** Generalise the methodology bullet to "**Working-set sweep** (demos 6, 7)" and use "(working-set-sweep convention)" in both demo 6 and demo 7 footers.

### L-3 — Two consecutive "no crossover" posts

Demo 6 title: "AoS vs SoA: bandwidth amplification, **not a crossover**." Demo 7 title: "**No crossover**: …". Both lead with the absence of an expected crossover and run the folklore→no-crossover→real-mechanism arc. Differentiators are real (demo 7's 780× modify collapse, "even `std::unordered_map` beats the sorted-vector primitives," the `std::map` small-N edge), and demo 6's forward-link sets demo 7 up as the same question on new turf — so this is mitigated, not broken. On a back-to-back read the title-level echo is noticeable.

**Editorial (user call, not a CC edit):** consider leading demo 7's title with its unique result (the modify-load collapse, or "reach for `absl` by default") rather than the reveal demo 6 already owns.

---

## Checked and clean (not findings — recorded so they aren't re-flagged)

- **Cross-link copy is reframe-safe, all directions.** Demo 1 (`:152-155`) and demo 6 (`:210`) both frame demo 7 as one that *asks whether* sorted containers beat hash maps / *whether* a small-N crossover exists — open questions demo 7 answers "no." Demo 7's back-links (`:292-298`) are cache-hierarchy framed. The established cross-links (2↔4 via PaddedAtomic, 3↔6 via SIMD/bandwidth, 5→4, 6→1/3/5) are all intact and none assert a stale crossover.
- **Slug split is an established pattern, not a demo-7 novelty.** Demo 2 already splits post-slug `02-false-sharing` from data-slug `02-false-sharing-pnl` (its `<Benchmark slug=...>` calls). Demo 7 follows the precedent: post `07-flatmap-vs-hashmap`, data/bench/JSON `07-no-crossover`, with every chart `slug=` prop and both source links consistently `07-no-crossover`. Consistent and intentional. (Optional: one sentence noting the repo dir is `07-no-crossover`, for a reader heading to source.)
- **Statistical conventions are fully consistent and disclosed.** Three conventions, codified on the methodology page Commitment 4 and named in every footer: throughput / median+IQR, ≥20 reps (demos 1, 2, 3); tail-latency p50/p99/p99.9, 5×1M samples (demos 4, 5); working-set-sweep median, 5 reps/cell (demos 6, 7). No median-quoted-as-p99 errors, no unstated statistics. The pre-demo-5 M-5/M-6 (uneven disclosure, 20-vs-30-vs-unstated) are properly closed.
- **Demo 3 carries no stale `cset` reference** and no "Reproducing this" cset comment — the pre-demo-5 C-2 fix held.
- **Demo 4's prior-cycle findings all held fixed:** `[Methodology](/methodology)` link (was broken C-1), "roughly 130 ns" floor matching 132 ns p50 (was M-1), "shared CCX L3" not "L3 slice" (was M-8), the explicit 8%-vs-16% p50/p99.9 distinction (was M-10), and "5 runs" matching the tail-latency convention (was M-6).
- **The prescriptive takeaway is earned.** "Reach for `absl::flat_hash_map` by default" (`:277`) is backed by a robust "What this doesn't show" (`:245-273`) and the "if you can't take `absl`…" paragraph (`:287-290`).
- **Template + Zen 2/CCX facts consistent.** Demos 1–7 route reproduction to `/methodology`, close with a Takeaway, and share section architecture. Cache sizes (32 KiB L1d / 512 KiB L2 / 16 MiB-per-CCX L3), the 19-cycle pipeline, 35-cycle L3, CCD/CCX/IOD/Infinity-Fabric description agree across every post that mentions them. (Minor shared looseness: "CCX slices" in demos 4 and 5 — a CCX isn't a slice — consistent between them, left per the standing instruction.)

---

## Recommendations

**Quick-fix bundle (one CC pass).** M-1, M-2, M-5, M-6, L-1, L-2 are verbatim text edits — fixes specified above. Bundle as `demo-07-08-hostile-cross-read-cleanup-brief.md`.

**Two need a one-line decision first.** M-3 (markers caveat vs per-variant annotation) and M-4 (methodology cset wording, contingent on what `run_one.sh` encapsulates) — settle wording, then fold into the same brief.

**Editorial, defer.** L-3 (title echo) — raise with the user, don't auto-fix.

**The cross-read is now complete** — demos 1–7 all read. No outstanding coverage gap before §9 (pre-merge review).

---

## Stop condition for §8

Audit half complete across all seven posts. Triage: (1) settle M-3 and M-4 wording; (2) Opus writes the cleanup brief; (3) CC applies; (4) mark §8 ☑. Then §9 (pre-merge review) and §10 (merge) remain.
