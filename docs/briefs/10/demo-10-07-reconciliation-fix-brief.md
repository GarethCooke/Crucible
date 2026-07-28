# Crucible — demo 10 §7 reconciliation fix (§8 cross-read finding)

Opus → CC, on `feat/demo-10-core-to-core`. One edit to `site/src/posts/10-core-to-core.mdx`: replace the reconciliation paragraph. This is the sole fix from the §8 hostile cross-read; everything else in the post re-derived clean.

## Why

The committed reconciliation paragraph was written from memory of an old A5 inventory rather than re-derived from the committed JSON, and it was wrong three ways: it implied demos 02 and 05 both corroborate a shared "~2.2×" (they don't — they measure different quantities and give different magnitudes), it flattened demo 02's effect, and it carried a stale "out-of-repo May capture" caveat that a later re-capture had already closed. The corrected paragraph states the three real magnitudes and why they differ.

Every number below is re-derived from committed JSON, not recalled:

| source | quantity | figure | file |
|---|---|---|---|
| demo 02, unpadded, 4 threads | intra vs cross-CCX, ns/op | 3.6113 → 4.3765 = **1.21×** | `02-false-sharing-pnl.json` |
| demo 05, malloc, paced 1 MHz | same vs cross-CCX, p50 | 204 → 488 = **2.39×** | `05-allocators.json` / `-cross-ccx.json` |
| demo 05, malloc, paced 1 MHz | same vs cross-CCX, p99.9 | 376 → 1824 = **4.85×** | same |
| demo 10, median intra vs cross | RTT | ~72 → ~160 = **2.2×** | `10-core-to-core.json` |

Both demo 05 files are in the repo at `captured_at 2026-06-05T06:07:50Z`; there is no missing capture, so the old out-of-repo caveat is deleted, not reworded.

## The edit

In `site/src/posts/10-core-to-core.mdx`, under the `## Reconciliation` heading, replace the entire paragraph that currently begins "This measurement doesn't stand alone." and ends "...rather than left silent." with:

```
This measurement doesn't stand alone. Two earlier posts leaned on the same CCX boundary. The false-sharing demo saw cross-CCX placement widen the contention gap by about 1.2× at the operation level — small, because there the interconnect cost is one component amortised across everything else each operation does. The allocator demo saw a cross-CCX queue handoff cost about 2.4× at the median and as much as 4.85× at malloc's tail — close to this demo's bare-line 2.2× at the median, because a queue handoff is essentially a cache-line transfer, and worse at the tail because cross-complex crossings serialise badly under load. Same boundary, three magnitudes: heavily amortised, bare, and amplified. This demo is the bare-metal figure the other two were implicitly assuming, and the L3-sharing split it reads from `shared_cpu_list` is the same split the false-sharing demo's `lscpu` topology reports independently.
```

## Acceptance

- The paragraph is replaced verbatim; the surrounding `## Reconciliation` heading and the `---` footer separator are untouched.
- `grep -c "out-of-repo\|isn't in the repository\|predates the current corpus" site/src/posts/10-core-to-core.mdx` → 0 (the stale caveat is gone).
- `grep -c "4.85\|2.4×\|1.2×" site/src/posts/10-core-to-core.mdx` → the three figures are present.
- No other file changed; `next build` clean.

## Out of scope

- Any other prose in the post — the cross-read cleared it.
- The `notes` field in `10-core-to-core.json` — already reads "70-73 ns" in the committed file; no fix needed.
- The corpus red/cyan palette colourblind-simulator check — a standalone hardening item, not this edit.
```
