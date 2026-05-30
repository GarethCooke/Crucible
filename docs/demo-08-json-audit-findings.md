# Demo 08 — capture JSON audit findings

Audit of `site/src/data/perf/08-sorting-shootout.json` against `required-fields.md` (machine-block schema) and `08-sorting-shootout-brief.md` (structure + data integrity). Capture delivered 2026-05-29.

## Verdict: **PASS** (structure + schema), with one **material framing finding** (F-1) and two minor flags (F-2, F-3).

---

## Machine block — PASS

| Field | Value | Verdict |
| --- | --- | --- |
| `turbo` | `false` | ✅ |
| `governor` | `"performance"` | ✅ |
| `isolated_cpus` | `"1-7"` | flag — see F-2 |
| `captured_at` | `2026-05-29T23:52:21Z` | ✅ post-dates patch, `Z` suffix |
| patched sub-fields | `isolated_cpus_{requested,effective,source}`, `cpu_affinity` (`"4-7"`), `lscpu_extended` all present | ✅ |
| forbidden fields | `compiler_flags`, `isolated_cores`, `smt_active` all absent at machine level | ✅ |

`compile_flags` correctly per-run. `requested`/`effective` agree (`"1-7"`/`"1-7"`) — unlike demos 1/4 which requested `"0-7"`; this machine was booted with `isolcpus=1-7`, consistent.

## Structure — PASS

- 66 runs = 63 u32 + 3 u64. Matches the brief: Set A (random u32, 2¹⁰…2²⁶ = 17 N × 3 variants = 51) + Set B (u32, N=2²², 5 distributions × 3 variants = 15, of which the 3 random@2²² overlap Set A) → 63 unique u32, + 3 u64 (one per variant, random@2²²).
- Set A: random u32 N values are exactly 2¹⁰…2²⁶. ✅
- Set B: all five distributions present at N=2²². ✅
- All required per-run fields present on all 66 runs; `ns_per_op` carries `median`/`min`/`p99`/`iqr` throughout. ✅
- `ops_per_sec` internally consistent with `ns_per_op.median` (0/66 mismatches >2%). ✅
- Stat ordering `min ≤ median ≤ p99`, `iqr ≥ 0` holds on all 66 runs. ✅

## Destructive-sort restore — PASS (verified via data)

`std_sort` on random@4 M = 63.9 ns/elem, matching the pilot's 63.2. The destructive-sort bug signature would have collapsed this to ~9 ns/elem (the sorted-input cost). It did not collapse — the harness restore worked. Brief acceptance check satisfied.

---

## F-1 — MATERIAL: the "radix wins at every N" claim is falsified at N=4096 and N=8192

Chart-1 data (random u32, ns/elem median):

| N | std_sort | pdqsort | radix | winner |
| --- | --- | --- | --- | --- |
| 1024 | 9.03 | 8.06 | **6.08** | radix |
| 2048 | 14.12 | 10.31 | **7.27** | radix |
| 4096 | 30.61 | **15.65** | 23.08 | **pdqsort** |
| 8192 | 36.23 | **18.33** | 19.41 | **pdqsort** |
| 16384 | 39.81 | 19.10 | **8.07** | radix |
| … | | | | radix from here up |
| 67 108 864 | 74.02 | 28.75 | **14.82** | radix |

Radix has a localised ~3× bump at N=4096–8192 (≈23/19 ns/elem vs ~7–8 on either side), and pdqsort wins both points. Everywhere else radix wins.

**This is almost certainly real and explainable, not noise:** LSD radix ping-pongs between two N-element buffers (`a` + `tmp`), so its working set is **2N×4 bytes**. At N=4096 that's 32 KB = exactly L1d; at N=8192 it's 64 KB, spilling to L2. An in-place sort like pdqsort crosses that boundary at twice the N. So radix's double-buffer hits the L1→L2 wall in precisely this window. The numbers on either side (radix wins at 2048 and 16384) bracket it cleanly.

**Action required (user / Opus editorial call):** the post must NOT say "radix wins at every size." Three honest options:

1. **Tell the truth as a story beat (recommended).** "Radix wins across the sweep *except* a narrow window around N=4–8 K, where its two-buffer working set crosses L1 while the in-place comparison sorts don't yet." This turns the bump into evidence *for* the "different cost models" thesis — radix pays for its O(n) auxiliary memory exactly where cache capacity bites. Strengthens the post.
2. **Trim chart 1's left edge to 2¹⁴** (brief Open item 8). Hides real, interesting data to protect a tidy claim — not recommended.
3. **Reframe to the tail-latency headline only**, where the small-N comparison-sort race is beside the point. Still need a true caption on chart 1.

My recommendation is (1). It costs one honest paragraph and makes the post better. Whichever you pick determines chart 1's caption and the headline sentence, so it has to be settled before §7 drafting.

---

## F-2 — MINOR: `isolated_cpus: "1-7"` not documented in root `notes`

Per `required-fields.md`, a `"1-7"` value should be documented in root `notes` with the cpu0 statement. The root `notes` field describes the run structure (cell counts, GB iterations) but not the isolation limitation. Same situation as demos 1 and 4 (machine sub-fields carry the info; not a recapture trigger). **Low priority:** append to `notes` — *"cpu0 cannot be kernel-isolated on this machine; effective isolcpus is 1-7."*

## F-3 — MINOR: `ram_speed_mhz: null`

Methodology page records DDR4-3200; the JSON leaves it null. Consistent with prior demos if they're also null — verify and, if the project convention is to populate it, regenerate or leave as-is and rely on the methodology page. Not blocking.

---

## Confirmed for the post (all from captured JSON, ready for §7 prose)

- **Cache inflection in the radix line:** 11.3 (1 M) → 12.2 (4 M) → 14.3 (16 M) → 14.8 (64 M) ns/elem — flat through L3, rising into DRAM past ~4 M (16 MB ≈ L3/CCX). Brief thesis #2 holds.
- **Distribution spread (N=4 M):** pdqsort 0.75→27.50 (36.5×), std_sort 7.08→63.91 (9.0×), radix 12.20→21.76 (1.8×, near-flat). Chart 2 carries.
- **Inversion holds:** radix slower on sorted (21.8) than random (12.2). Brief Open item 5 → the sidebar is earned.
- **Sawtooth defeats pdqsort:** 27.50 ≈ its random 25.71. Honest limit-of-pattern-detection beat intact.
- **Key-width callout confirmed:** radix-vs-std_sort advantage shrinks from **5.24× (u32)** to **1.83× (u64)** at 4 M random. Radix still wins at u64. Quantified claim ready.
