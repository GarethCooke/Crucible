# Demo 10 · A5 reconciliation inventory

Cross-check of every cross-CCX / Infinity-Fabric prose claim in the Crucible
blog posts against the numbers in the companion JSON under
`site/src/data/perf/`. Every figure below was **re-derived independently from
the raw JSON values** (medians, percentiles, ops/sec) — the prose's own
numbers were never trusted, only compared against the arithmetic. All numeric
CCX/Fabric claims live in demos **02** and **05**; the CCX mentions in demos
03, 04, 06, 07, 08 are architectural hardware-spec or qualitative/deferred
statements with no backing perf field (listed as N/A).

Scope note: this inventory **flags** disagreements; it does not fix them. It
feeds the §2 reconciliation section. (Result below: none to fix.)

## Inventory

| Post | Sentence (file:line) | Claimed direction & magnitude | Source JSON field | JSON value | Re-derived | Match? |
|---|---|---|---|---|---|---|
| 02 | "At 4 threads on a single CCX, unpadded is 3.61 ns/op against padded's 0.71 ns/op — **a 5× wall-clock penalty inside one core complex**" (02-false-sharing.mdx:92-93) | intra-CCX unpadded slower than padded, ~5× | `02-false-sharing-pnl.json` runs[placement=intra-ccx, threads=4].ns_per_op.median (unpadded / padded) | 3.6113 / 0.7125 | 3.6113 ÷ 0.7125 = **5.07× ≈ 5×** | YES |
| 02 | "the cross-CCX unpadded result is 4.38 ns/op against intra-CCX 4t unpadded at 3.61 ns/op — **a 1.21× additional penalty from crossing the Fabric**" (02:119-120) | cross-CCX slower than intra-CCX at 4t, 1.21× | same file, runs[cross-ccx,4t,unpadded].median / runs[intra-ccx,4t,unpadded].median | 4.3765 / 3.6113 | 4.3765 ÷ 3.6113 = **1.212× ≈ 1.21×** | YES |
| 02 | "The cross-CCX 4t result has IQR/median under 0.4% across 20 repetitions" (02:121-122) | dispersion < 0.4% | runs[cross-ccx,4t,unpadded].ns_per_op {iqr, median} | 0.0077 / 4.3765 | 0.0077 ÷ 4.3765 = **0.176% < 0.4%** | YES |
| 02 | "unpadded variant settles at 3.36 ns/op; the padded variant reaches 0.25 ns/op — a **13.6× throughput gap**" at 8t cross-CCX (02:126-128; also intro 8-9, takeaway 186-190) | 8t cross-CCX unpadded slower than padded, 13.6× | runs[cross-ccx,8t].ns_per_op.median (unpadded / padded) | 3.3606 / 0.2475 | 3.3606 ÷ 0.2475 = **13.58× ≈ 13.6×** | YES |
| 02 | "Under a perfect-scaling assumption the gap is still 9.4×… (2.9× throughput from 2× threads)" (02:145-146) | perfect-scaling gap 9.4×; padded 8t/4t throughput 2.9× | runs: 8t-unpadded.median, 4t-padded.median, ops_per_sec (8t-padded / 4t-padded) | 3.3606; 0.7125; 4040281527 / 1403298906 | 3.3606 ÷ (0.7125/2) = **9.43× ≈ 9.4×**; 4040281527 ÷ 1403298906 = **2.88× ≈ 2.9×** | YES |
| 02 | Config table: 6 rows of Median ns/op, Throughput, IQR/median (02:130-137) | all six intra/cross rows | runs[*].ns_per_op.median, .ops_per_sec, .iqr | see appendix | all 6 rows reproduce median, ops/sec and IQR/median (0.06%–26%) exactly | YES |
| 05 | thesis + takeaway: malloc-vs-pools p99.9 gap "modest (~1.15–1.3× p99.9) when … share a CCX, substantial (~2.3–2.5×) when they don't" (05-allocators.mdx:11; 257-258) | gap malloc/pools: same-CCX ~1.15–1.3×, cross-CCX ~2.3–2.5× | `05-allocators.json` (bg=1e6) malloc/pool p99_9; `05-allocators-cross-ccx.json` malloc/pool p99_9 | same-CCX 376 / 328; cross 1824 / {784,720} | same-CCX 376 ÷ 328 = **1.15×**; cross 1824 ÷ 784 = 2.33×, ÷ 720 = 2.53× → **2.3–2.5×** | YES* |
| 05 | headline same-CCX: pools "p99 = 220, p99.9 = 328 here" vs malloc "p99 = 312 … p99.9 = 376 — about **1.4× the pools at p99 and 1.15× at p99.9**" (05:88-92) | malloc tail vs pools same-CCX: 1.4× at p99, 1.15× at p99.9 | `05-allocators.json` bg=1e6 stats: malloc {p99=312,p99_9=376}, pool {p99=220,p99_9=328} | 312/220; 376/328 | 312 ÷ 220 = **1.42× ≈ 1.4×**; 376 ÷ 328 = **1.146× ≈ 1.15×** | YES |
| 05 | "The p50 floor more than doubles for all three variants — 408 ns for the arena and 488 ns for malloc and the freelist" (05:208-209) | cross-CCX p50 floors ≈2×+ same-CCX; absolute 408/488/488 | `05-allocators-cross-ccx.json` p50 {arena 408, malloc 488, freelist 488} vs same-CCX p50 {172,204,188} | 408, 488, 488 / 172, 204, 188 | absolute floors match JSON exactly; 408/172=2.37, 488/204=2.39, 488/188=2.60 → all **>2×** | YES |
| 05 | "pools top out … **p99.9 = 720 and 784 ns here** … about **2.2–2.4× their same-CCX baselines**" (05:213-215) | cross-CCX pool p99.9 720/784; 2.2–2.4× same-CCX | cross json arena/freelist p99_9; same-CCX pool p99_9=328 | 720, 784 / 328 | 720 ÷ 328 = **2.20×**, 784 ÷ 328 = **2.39×** → 2.2–2.4× | YES |
| 05 | "Malloc reaches p99 = 1184 … p99.9 = 1824: roughly **1.7× the pools at p99** and **2.3–2.5× at p99.9**, and a **~4.9× expansion of its own same-CCX p99.9 (376 → 1824)**" (05:215-218) | cross malloc vs pools 1.7× p99 / 2.3–2.5× p99.9; vs own same-CCX 4.9× | cross json malloc {p99=1184,p99_9=1824}, pool p99=688; same-CCX malloc p99_9=376 | 1184/688; 1824/{784,720}; 1824/376 | 1184 ÷ 688 = **1.72× ≈ 1.7×**; 1824 ÷ 784 = 2.33×, ÷ 720 = 2.53× → **2.3–2.5×**; 1824 ÷ 376 = **4.85× ≈ 4.9×** | YES |
| 05 | takeaway: "roughly a **5× expansion** of malloc's own same-CCX tail against the pools' ~2.2–2.4×" (05:257-259) | cross malloc vs own same-CCX ~5×; pools ~2.2–2.4× | cross malloc p99_9=1824 / same-CCX malloc p99_9=376; pools as above | 1824 / 376 | 1824 ÷ 376 = **4.85× ≈ 5×** (pools 2.20–2.39× as above) | YES |
| 02/03/06/07 | "16 MB / 16 MiB L3 per CCX" hardware spec (02:112-113,175; 03:98; 06:120,132-133; 07:4,80,82) | architectural cache-size statement | none — L3 size is not a perf field; JSON `machine.lscpu_extended` lists topology columns, no L3 byte size | n/a | not a re-derivable perf figure | N/A |
| 04 | "same CCX sharing an L3"; "Cross-CCX … crosses the Infinity Fabric; latency increases. Deferred" (04:34-35, 131-132, 251, 278-279) | qualitative; cross-CCX explicitly deferred | none — no cross-CCX run captured for demo 04 | n/a | no number to derive | N/A |
| 06 | "The cross-CCX picture is in demo 5's side note" (06:206) | qualitative cross-reference | none | n/a | n/a | N/A |
| 08 | methodology footer "single thread pinned to core 4 (CCX1)" (08:133) | thread-placement note, no magnitude | none | n/a | n/a | N/A |

## Mismatches

**No mismatches found — every cross-CCX / Infinity-Fabric figure re-derives
cleanly from its JSON source.** All twelve numeric rows agree with the JSON to
rounding. The single asterisk (row 05 thesis) is not a mismatch: the
re-derivable endpoint matches exactly (see Notes).

A clean result is a valid, informative outcome for §2: the earlier posts'
cross-CCX / Fabric numbers are internally consistent with their captured data,
so demo 10 can cite them without first correcting them.

## Notes

- **Row 05-thesis (YES\*)** — the same-CCX gap is quoted as a **range**
  "~1.15–1.3× p99.9 … across captures." The **1.15×** lower bound re-derives
  exactly from the repo JSON (June 6 capture: malloc p99.9 376 ÷ pool p99.9
  328 = 1.146). The **1.3×** upper bound is explicitly attributed to "across
  captures" i.e. the **May capture, which is not present in
  `site/src/data/perf/`** (only the June 6 capture is committed). So the upper
  end of the range cannot be re-derived from repo data — it rests on out-of-repo
  history. Direction and the derivable endpoint are correct; flagged only for
  transparency, not as a discrepancy.
- **Interpretation resolved:** in demo 05 "that drift"/"the gap" consistently
  means **malloc p99.9 ÷ pools p99.9** (not malloc-under-pressure ÷
  malloc-baseline). Confirmed by the takeaway (05:258) — "the gap opens to
  ~2.3–2.5× … against the pools' ~2.2–2.4×." The alternative reading (malloc vs
  its own no-pressure baseline: 376÷344 = 1.09×) does not fit the stated
  1.15–1.3×, so it was rejected.
- **Same-CCX pool baseline choice:** demo 05 uses the **headline (bg=1 MHz)
  pool p99.9 = 328** as the same-CCX baseline for its cross-CCX ratios, not the
  pressure-sweep baseline of 344. Using 328 reproduces all quoted ratios
  (2.2–2.4×, 1.15×); the prose is internally consistent in using 328.
- **May-capture numbers throughout demo 05** ("both 720 in May," "arena at 204
  … malloc at 172 in May," "ranged 296–328," "all three on 408") reference a
  prior capture absent from the repo. These are historical/qualitative context,
  not claims about the committed JSON, and were not scored.
- **JSON files referenced:** `02-false-sharing-pnl.json`, `05-allocators.json`
  (30 runs: 3 variants × 10 pressure levels; headline `background_pressure_hz`
  = 1000000), `05-allocators-cross-ccx.json` (3 variants, cross-CCX). Demo 05
  percentiles come from `latency_ns.stats.{p50,p90,p99,p99_9}`; demo 02 figures
  from `ns_per_op.median` and `ops_per_sec`.
- **"16 MB L3 per CCX"** is a Zen 2 hardware fact, not stored as a numeric
  field in any perf JSON (the `machine.lscpu_extended` block gives per-core
  L1d:L1i:L2:L3 *topology indices*, not byte sizes), so it is correctly N/A.
- The 8-thread demo-02 configuration exists **only** cross-CCX (it spans both
  CCXs and pulls in cpu0); there is no intra-CCX 8t counterpart in the JSON,
  consistent with the prose.

---

## Verification appendix

Raw JSON numbers, with exact file:line, so every verdict can be re-checked
independently. (All values below were re-pulled and confirmed against the
committed JSON during this audit.)

**`site/src/data/perf/02-false-sharing-pnl.json`** — `runs[*]`, keyed by
`{placement, threads, padded}`; fields `ns_per_op.{median,iqr}`, `ops_per_sec`:

| placement | threads | padded | median | iqr | ops_per_sec |
|---|---|---|---|---|---|
| intra-ccx | 4 | false | 3.6113 | 0.0036 | 276909512 |
| intra-ccx | 4 | true  | 0.7125 | 0.0004 | 1403455536 |
| cross-ccx | 4 | false | 4.3765 | 0.0077 | 228491969 |
| cross-ccx | 4 | true  | 0.7126 | 0.0013 | 1403298906 |
| cross-ccx | 8 | false | 3.3606 | 0.0334 | 297567820 |
| cross-ccx | 8 | true  | 0.2475 | 0.0649 | 4040281527 |

Derivations: 3.6113/0.7125 = 5.068; 4.3765/3.6113 = 1.2119; 0.0077/4.3765 =
0.176%; 3.3606/0.2475 = 13.578; 3.3606/(0.7125/2) = 9.434; 4040281527/1403298906
= 2.879.

**`site/src/data/perf/05-allocators.json`** — same-CCX headline,
`background_pressure_hz`=1000000, `latency_ns.stats`:

| variant | p50 | p99 | p99_9 |
|---|---|---|---|
| cross-thread-malloc  | 204 | 312 | 376 |
| freelist-return-queue| 188 | 220 | 328 |
| arena-batch-handoff  | 172 | 220 | 328 |

**`site/src/data/perf/05-allocators-cross-ccx.json`** — `latency_ns.stats`:

| variant | p50 | p99 | p99_9 |
|---|---|---|---|
| cross-thread-malloc  | 488 | 1184 | 1824 |
| freelist-return-queue| 488 |  688 |  784 |
| arena-batch-handoff  | 408 |  688 |  720 |

Derivations: 376/328 = 1.146; 312/220 = 1.418; 720/328 = 2.195; 784/328 =
2.390; 1184/688 = 1.721; 1824/784 = 2.327; 1824/720 = 2.533; 1824/376 = 4.851;
p50 floors 408/172 = 2.37, 488/204 = 2.39, 488/188 = 2.60 (all > 2×).
