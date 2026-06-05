# Demo 02 re-derivation patch brief — boost-off recapture

Branch: `feature/boost-off-recapture`. Scope: `content/posts/02-false-sharing.mdx` only.

## Context

Demo 02 was recaptured 2026-06-05 at true base clock with the l1d perf event substituted (`l1d.replacement` → `L1-dcache-load-misses`). Re-derivation against the new `02-false-sharing-pnl.json` shows the **8-thread headline ratio did not survive the recapture**: padded slowed ~12% with the clock while unpadded (coherency-latency-bound) barely moved, so 15× → **13.6×** (3.3606 / 0.2475). The headline appears in the frontmatter title, intro, a section header, and the takeaway twice — all change. The 4t intra story (5× wall-clock, 5× IPC lockstep) holds exactly. The Fabric penalty softens 1.27× → 1.21×. Counter figures shift (1t miss ratio 28–30% → 19–22%; 2t 96% → 94%). The MDX never cites an l1d-event-derived number, so no event relabelling is needed in prose.

Two pre-existing defects are folded in: the "two missing bytes" phrase (padding is 56 bytes, as the intro itself states) and the footer's incorrect isolation/pinning description. One disclosure is added for the 8t padded superlinear-scaling anomaly, which inflates the headline's denominator.

## Pre-flight sentinel (mandatory — abort on mismatch)

Verify in `02-false-sharing-pnl.json`:

- `captured_at` == `"2026-06-05T05:56:48Z"`
- `machine.turbo` == `false`, `machine.turbo_source` == `"cpb"`, `machine.freq_max_available_mhz` == `3900`
- run `variant=="unpadded", threads==8, placement=="cross-ccx"` has `ns_per_op.median` == `3.3606`
- run `variant=="padded", threads==8, placement=="cross-ccx"` has `ns_per_op.median` == `0.2475`
- every run's `counters.l1d_misses_per_op` is non-null

Any mismatch → stop, report, do not edit.

## Tasks

### T1 — Frontmatter title

Find: `title: "False sharing: a 15× throughput gap from two missing bytes"`
Replace: `title: "False sharing: a 13.6× throughput gap from 56 missing bytes"`

(Two defects in one line: stale ratio, and "two missing bytes" — the actual padding delta is 56 bytes. Wording approved by Gareth 2026-06-05.)

### T2 — Intro figures and ratio

Find: `only difference is 56 bytes of padding. At 8 threads, the unpadded version runs at
3.31 ns/op; the padded version reaches 0.22 ns/op. A 15× gap from a layout choice the
compiler never warned about.`

Replace: `only difference is 56 bytes of padding. At 8 threads, the unpadded version runs at
3.36 ns/op; the padded version reaches 0.25 ns/op. A 13.6× gap from a layout choice the
compiler never warned about.`

### T3 — 1t counter parity figures

Find: `indistinguishable: IPC sits near 0.56, miss ratio near 28-30% (the steady-state`
Replace: `indistinguishable: IPC sits near 0.58, miss ratio near 19–22% (the steady-state`

(Derivation: IPC 0.5815/0.5748; cache_miss_ratio 0.1881/0.2216.)

### T4 — 2t counter collapse figures

Find: `threads the unpadded miss ratio jumps to 96% — once two cores write to the
same line, nearly every access misses — and IPC collapses to 0.21. At 4`

Replace: `threads the unpadded miss ratio jumps to 94% — once two cores write to the
same line, nearly every access misses — and IPC collapses to 0.20. At 4`

(Derivation: 0.9391; 0.2041.)

### T5 — 4t saturation figure

Find: `threads the miss ratio barely moves (still ~96%, already saturated), but IPC`
Replace: `threads the miss ratio barely moves (still ~95%, already saturated), but IPC`

(Derivation: 0.9496.)

### T6 — Fabric penalty figures

Find: `At 4 threads, the cross-CCX unpadded result is 4.59 ns/op against intra-CCX 4t unpadded
at 3.61 ns/op — **a 1.27× additional penalty from crossing the Fabric, on top of the`

Replace: `At 4 threads, the cross-CCX unpadded result is 4.38 ns/op against intra-CCX 4t unpadded
at 3.61 ns/op — **a 1.21× additional penalty from crossing the Fabric, on top of the`

(Derivation: 4.3765 / 3.6113 = 1.212.)

### T7 — 8t section header

Find: `## 15× at 8 threads cross-CCX`
Replace: `## 13.6× at 8 threads cross-CCX`

### T8 — 8t section body figures

Find: `At 8 threads spanning both CCXs, the gap widens. The unpadded variant settles at
3.31 ns/op; the padded variant reaches 0.22 ns/op — a **15× throughput gap** from a
single struct layout decision.`

Replace: `At 8 threads spanning both CCXs, the gap widens. The unpadded variant settles at
3.36 ns/op; the padded variant reaches 0.25 ns/op — a **13.6× throughput gap** from a
single struct layout decision.`

### T9 — Summary table (full replacement)

Find:

```
| Configuration         | Median ns/op | Throughput (ops/sec) | IQR/median |
| --------------------- | ------------ | -------------------- | ---------- |
| Intra-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.04%      |
| Intra-CCX 4t unpadded | 3.61         | 277 M/s              | 0.08%      |
| Cross-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.35%      |
| Cross-CCX 4t unpadded | 4.59         | 218 M/s              | 0.17%      |
| Cross-CCX 8t padded   | 0.22         | 4.59 G/s             | 16%        |
| Cross-CCX 8t unpadded | 3.31         | 302 M/s              | 1.4%       |
```

Replace:

```
| Configuration         | Median ns/op | Throughput (ops/sec) | IQR/median |
| --------------------- | ------------ | -------------------- | ---------- |
| Intra-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.06%      |
| Intra-CCX 4t unpadded | 3.61         | 277 M/s              | 0.10%      |
| Cross-CCX 4t padded   | 0.71         | 1.40 G/s             | 0.18%      |
| Cross-CCX 4t unpadded | 4.38         | 228 M/s              | 0.18%      |
| Cross-CCX 8t padded   | 0.25         | 4.04 G/s             | 26%        |
| Cross-CCX 8t unpadded | 3.36         | 298 M/s              | 1.0%       |
```

(Derivation: medians and ops_per_sec direct from JSON; IQR/median = ns_per_op.iqr / ns_per_op.median per row: 0.056%, 0.100%, 0.182%, 0.176%, 26.2%, 0.99%.)

### T10 — 8t noise paragraph (framing strengthened; approved)

Find: `false-sharing cost dwarfs cpu0 background noise — but the padded baseline has
IQR/median around 16% rather than the sub-1% seen everywhere else. The 15× headline is
real; treat the third significant figure with skepticism.`

Replace: `false-sharing cost dwarfs cpu0 background noise — but the padded baseline has
IQR/median around 26% rather than the sub-1% seen everywhere else. The padded 8t median
also scales *better* than perfectly against 4t (2.9× throughput from 2× threads), which
is not physical for this workload — the denominator is optimistic. Under a
perfect-scaling assumption the gap is still 9.4×; the measured-median figure is 13.6×.
Treat the headline as "order 10×, plausibly 13×", not a third-significant-figure claim.`

(Approved 2026-06-05: discloses the superlinear anomaly rather than papering over it; the anomaly existed in the shipped capture too. 8t diagnostic remains open item 3 but does not gate this patch.)

### T11 — Takeaway figures

Find: `False sharing is a 15× throughput collapse from two missing bytes of padding — a`
Replace: `False sharing is a 13.6× throughput collapse from 56 missing bytes of padding — a`

Find: `hardware-specific: 5× within a Zen 2 CCX, 15× once the Infinity Fabric is in`
Replace: `hardware-specific: 5× within a Zen 2 CCX, 13.6× once the Infinity Fabric is in`

### T12 — "What this doesn't show" 15× reference

Find: `cpu0 in the worker pool. The 15× number is robust because the false-sharing signal`
Replace: `cpu0 in the worker pool. The headline number is robust in direction and order because the false-sharing signal`

### T13 — Footer isolation/pinning correction (pre-existing defect)

Find: `cores 0–7 isolated, pinned to 4–7. Headless Ubuntu 24.04.`
Replace: `cores 1–7 isolated (cpu0 cannot be kernel-isolated); thread placement per configuration — intra-CCX runs on cores 4–7, cross-CCX spans both CCXs, the 8t run includes cpu0. Headless Ubuntu 24.04.`

(JSON: `isolated_cpus_effective: "1-7"`, `cpu_affinity: "0-7"`, per-run `cores_used`. The shipped footer was wrong for this demo on both halves: isolation set and pinning.)

## Acceptance criteria (grep against the MDX; all must hold)

1. `grep -c '15×'` → 0; `grep -c '13\.6×'` → 5 (title, intro, header, 8t body, takeaway ×1) — takeaway second instance plus T11 makes title+intro+header+body+takeaway×2 = 6 if title counts; CC: verify exact count equals number of replacements applied and report it
2. `grep -c 'two missing bytes'` → 0; `grep -c '56 missing bytes'` → 2 (title + takeaway)
3. `grep -c '3\.31 ns/op\|0\.22 ns/op\|4\.59 ns/op\|1\.27×'` → 0
4. `grep -c '3\.36 ns/op'` → 2; `grep -c '4\.38'` → 2 (prose + table)
5. `grep -c '28-30%\|jumps to 96%\|still ~96%\|IPC collapses to 0\.21'` → 0
6. `grep -c 'around 26%'` → 1; `grep -c 'around 16%'` → 0
7. `grep -c '4\.04 G/s'` → 1; `grep -c '4\.59 G/s'` → 0
8. `grep -c 'cores 0–7'` → 0; `grep -c 'cores 1–7 isolated'` → 1
9. `grep -c '9\.4×'` → 1

## Out of scope

- All other demo MDX files, the methodology page, and the correction note.
- The bench-side stale label fix (JSON `notes` still says `l1d event: l1d.replacement`) — belongs in the pending `prepare_bench.sh` / `parse_perf.py` hardening brief, not in MDX.
- `perf_event_paranoid<=0` precondition hardening — separate pending brief.
- "Padded holds at IPC ~0.55 and miss ratio under 30%" — re-derived, still true (17–22%), retained as a safe bound. Do not edit.
- "Per-thread latency for padded sits near 2.85 ns/op" — holds for the intra-CCX context it describes (2.846–2.850). Do not edit.
- "IQR/median under 0.4% across 20 repetitions" (cross-CCX 4t) — holds (0.18%). Do not edit.
- 5× intra-CCX claims and IPC-lockstep framing — re-derived, hold exactly. Do not edit.

## Open items

1. **RESOLVED — old-JSON audit (2026-06-05).** Old capture (2026-05-18, kernel 6.8.0-111): `l1d_misses_per_op` null in all 12 runs — the event never resolved, the field was empty, and nothing in the shipped post cited it. No invalid numbers shipped. Correction-note framing: misconfigured event → null field → substituted in recapture. Additional finding for the correction note: old demo-02 clock-sensitive rows match the new base-clock capture within 0.2% (1t padded 11.12 vs 11.11 cycles), so this old capture ran at base clock despite unverified boost state — the note must say "boost state unverified, verified per-demo", not "all prior captures boosted". The 15.2× → 13.6× headline shift decomposes as unpadded +1.5%, padded-8t +13.7% (instability of the same broken measurement), confirming T10's framing. Footer defect origin: old `isolated_cpus_requested:"0-7"` leaked into prose as "cores 0–7 isolated".
2. **Stale event label at source.** New JSON per-run `notes` still names `l1d.replacement` despite the substitution; values flowed (non-null, plausible), so only the label is wrong. Fold into the hardening brief.
3. **8t padded measurement integrity.** Superlinear 4t→8t scaling (2.88×), per-thread time 2.85 → 1.98 ns, wall-clock median falling 2.92 → 2.03 ms with min 1.41 ms. Suggests the 8t padded timing aggregation is contaminated (candidate: Google Benchmark per-thread time accounting interacting with the non-isolated cpu0 thread). T10 discloses; a diagnostic or recapture of the 8t row would resolve. Gareth's call whether to gate the patch on it.
4. **1t miss-ratio shift (28–30% → 19–22%) between captures** — clock ruled out (old capture was at base; see item 1). Remaining candidates: the perf event-group change (the now-resolving l1d event alters group scheduling/multiplexing of the generic counters) and the kernel bump (6.8.0-111 → 117). Correction-note material; no MDX action beyond T3.
5. Decisions resolved 2026-06-05: D1=13.6× everywhere; D2=patch now with anomaly disclosure (8t diagnostic stays open, non-gating); D3=title "56 missing bytes". Brief is unblocked for CC.
