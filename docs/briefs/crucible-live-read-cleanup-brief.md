# Crucible — live-read cleanup brief

Remediation brief for CC. Source: `crucible-live-site-hostile-cross-read-findings.md` (v2, 2026-07-03), finding IDs C-2, M-1–M-5, L-1, L-2, L-3, L-4, L-5, L-6. All items are prose/site/JSON-additive; no perf recapture, no Machine 1 time. Work on a single branch (`cleanup/live-read-2026-07`), one PR. The PR description must list the finding IDs and the two sign-off items named in Open items.

## Context

A full-corpus hostile cross-read of the site (2026-07-03) re-derived every headline number from the committed 2026-06-05 JSONs and verified all post MDX against user-supplied latest copies. The posts' numbers are clean. What remains is one factual error on the methodology page that contradicts demo 03, a promised methodology section that doesn't exist, four small technical/scope corrections in post prose, two template artifacts on the quantum special page, one additive JSON field for the special edition, and one convention codification. The user has signed off on the resolution path for every item below; nothing here requires further scoping judgement — anything that turns out ambiguous goes to Open items, not guesswork.

## Preconditions — verify before any edit; if any fail, stop and report

1. Repo clean, on `master`, up to date with origin.
2. `grep -c "as two 128-bit µops — called out" site/src/app/methodology/page.tsx` → exactly 1.
3. `grep -c "slide into shallower C-states" site/content/posts/04-spsc-queue.mdx` → exactly 1. (Adjust content path to actual repo layout throughout; locate posts with `grep -rl "slide into shallower" site/`.)
4. `grep -c "sized to fit in L1d (~34 KB total)" <05 mdx>` → exactly 1.
5. `grep -c "2.85 ns/op across all" <02 mdx>` → exactly 1.
6. `grep -c "cores 1–7 isolated. Producer core 4" <04 mdx>` → exactly 1.
7. `grep -c "for the rdtscp calibration path" <04 mdx> <05 mdx>` → exactly 1 in each.
8. The committed quantum JSON (locate: `grep -rl "quantum-measuring-the-gap-v1" .`) has `circuit_depth.grover` depths `[10, 14, 18]`, `circuit_depth.bv` depths `[1, 1, 1]`, and `two_qubit_gates: 0` on all six rows. Any other values → stop; the brief was written against different data.
9. Confirm the eleven perf-capture JSONs (demos 01–09 incl. 04-overload-modes, 05-cross-ccx) are untouched at close: `git status` must show no diff on any of them.

## Tasks

### 1. Methodology — fix the Zen 2 AVX2 µop claim (C-2)

File: `site/src/app/methodology/page.tsx`, Machine 1 blurb (~line 161). This sentence asserts the opposite of demo 03's `ex_ret_cops` finding and must align with the post and the JSON notes field ("Zen 2 executes 256-bit AVX2 as single µops (verified ex_ret_cops ≈1.0/instr)").

Find (verbatim, two lines):

```
        Zen 2 implements 256-bit AVX2 as two 128-bit µops — called out
        explicitly in any SIMD post. Full{" "}
```

Replace with:

```
        Zen 2 executes 256-bit AVX2 as single µops — verified per capture with
        the retired-µop counter (<code>ex_ret_cops</code> ≈ 1.0 µops/instruction;
        demo 03), unlike Zen and Zen+, which cracked each 256-bit op into two
        128-bit µops. Full{" "}
```

### 2. Methodology — add the rdtscp calibration section (M-1)

Demos 04 and 05 footers promise "the rdtscp calibration path" on the methodology page; no such content exists. Add it rather than retracting the footers.

1. Locate the timestamping implementation: `grep -rn "rdtscp_ordered" bench/` — expect a definition in `bench/common/` plus call sites in demos 04/05. Read the definition and any TSC calibration / drift-check code around it.
2. Insert a new subsection at the end of the **Measurement commitments** section — i.e. immediately before the `<h2 id="best-practices">` element (~line 361) in `page.tsx`:
   - `<h3 id="rdtscp-calibration">` titled "Timestamping: rdtscp calibration".
   - Content, drafted **from the code you just read, not from general knowledge**: (a) the exact instruction sequence `rdtscp_ordered()` uses and why (serialization semantics as implemented); (b) the TSC preconditions the harness checks or assumes (`constant_tsc` / `nonstop_tsc`); (c) how ticks convert to nanoseconds — the actual calibration mechanism in the code; (d) the cross-thread drift check that produces the "TSC drift ≤0.0001% across all 5 runs" figure demo 04's footer quotes, described as implemented.
   - Match the section's existing JSX/typography patterns (same `className`/`style` conventions as neighbouring h3 blocks).
   - If the code's actual mechanism for (c) or (d) does not exist or differs from what the footer claims, **stop and surface** — do not document a mechanism that isn't there.
3. Update both footers to anchor-link the new section. In each of `<04 mdx>` and `<05 mdx>`, find (verbatim): `See [Methodology](/methodology) for the rdtscp calibration path._` → replace: `See [Methodology](/methodology#rdtscp-calibration) for the rdtscp calibration path._`

### 3. Demo 04 — C-state direction (M-2)

Find (verbatim): `even let it slide into shallower C-states), so wake-up cost` → replace: `even let it slide into deeper C-states), so wake-up cost`

### 4. Demo 05 — table sizing vs L1d (M-3)

The claim "All tables are sized to fit in L1d (~34 KB total)" is self-refuting against the 32 KB Zen 2 L1d stated in demos 02/04. Derive the true number from source rather than guessing:

1. In the demo 05 bench source, locate the three consumer tables (positions by symbol, limits by client, velocity by client) and compute total resident bytes from their declared sizes/element types. Record the arithmetic in the PR description.
2. Apply exactly one of these to the sentence in `<05 mdx>` (~line 60), substituting the computed `NN`:
   - If total ≤ 32768 bytes — find: `All tables are sized to fit in L1d (~34 KB total).` → replace: `All tables are sized to fit in L1d (~NN KB total).`
   - If total > 32768 bytes — find: same → replace: `All tables total ~NN KB — sized to sit within L1d plus a slice of L2 rather than strictly inside the 32 KB L1d.`
3. If the tables are runtime-sized such that a static total is not derivable, stop and report the constants found.

### 5. Demo 05 — connect the 328/344 baselines (L-1)

Find (verbatim, spans two lines):

```
travel together (p99 = 220, p99.9 = 328 here, within one bucket of each other in
every dataset), while
```

Replace with:

```
travel together (p99 = 220, p99.9 = 328 here, within one bucket of each other in
every dataset; the pressure-sweep section's separately-captured baseline puts the
same pools at 344 — one log₂-subbucket-16 bucket up, i.e. within resolution), while
```

### 6. Demo 04 — footer parenthetical (L-2)

Find (verbatim): `cores 1–7 isolated. Producer core 4` → replace: `cores 1–7 isolated (cpu0 cannot be kernel-isolated and carries housekeeping). Producer core 4`

### 7. Demo 02 — scope the per-thread claim (L-4)

Find (verbatim, spans two lines):

```
ping-pong. Per-thread latency for padded sits near 2.85 ns/op across all
thread counts (the inner loop's architectural floor); the system-level number
```

Replace with:

```
ping-pong. Per-thread latency for padded sits near 2.85 ns/op across all
intra-CCX thread counts (the inner loop's architectural floor); the system-level number
```

### 8. Special edition — two-qubit gate count (M-4, Path A preferred)

Decide path by `python3 -c "import qiskit; print(qiskit.__version__)"`. Success → Path A. ImportError → Path B, and note the fallback in the PR.

**Path A — additive decomposed count.**

1. Locate the script that generated the committed quantum JSON (`grep -rn "quantum-measuring-the-gap-v1" .` for the generator; reuse its Grover/BV circuit builders — do not reimplement circuit construction).
2. Write `add_decomposed_counts.py` alongside it: load the committed JSON; rebuild each circuit (grover n=3,4,5; bv n=3,4,5) with the generator's own builders; **pre-flight assert** each rebuilt circuit's abstract `depth()` equals the committed depth (10/14/18; 1/1/1) and its abstract two-qubit op count equals the committed `two_qubit_gates` (0). Any mismatch → stop; the reconstruction does not match what produced the committed data.
3. For each circuit: `transpile(qc, basis_gates=['cx','rz','sx','x'], optimization_level=1, seed_transpiler=42)`; count `cx` ops → add `two_qubit_gates_decomposed` to that row. Add one sibling key under `circuit_depth`: `"decomposition": {"basis": ["cx","rz","sx","x"], "optimization_level": 1, "seed_transpiler": 42, "qiskit_version": "<recorded>"}`.
4. Write the JSON back **additively only**: a deep-diff against the original must show zero modified or removed keys — only the new fields. Assert this in the script.
5. Prose: `grep -rn "on the order of many two-qubit gates" site/` (if the literal is absent, locate the template that renders it and edit there). Replace the sentence so it reads: `A Grover circuit at N=32 decomposes into {G} two-qubit gates when transpiled to a CX basis — the committed two_qubit_gates_decomposed figure — before device routing adds more.` where `{G}` is the grover n=5 value just computed. If the page renders from the JSON, prefer wiring the field over hard-coding the number; surface which you did in the PR.

**Path B — reword only (qiskit unavailable).** Same grep-locate; replace the sentence with: `A Grover circuit at N=32 decomposes into a substantial two-qubit-gate count on real hardware; the exact transpiled figure is reported alongside the hardware capture below.` No JSON change.

### 9. Special edition — BV layer pluralization (L-6)

`grep -rn "roughly 1 layers" site/` — if found as a literal, replace the fragment `roughly 1 layers` → `a single layer`. If not found as a literal, locate the template (`grep -rn "layers" site/` near the transpile-depth rendering) and make it pluralization-aware, e.g. `depth === 1 ? "a single layer" : \`roughly ${depth} layers\``, adapted to the actual code — the Grover "roughly 18 layers" output must be unchanged.

### 10. Special edition — card/page drift (L-5)

`grep -rn "shows precisely why" site/` — expect exactly one hit (the index card source). Replace `precisely` → `exactly`, aligning the card to the page subtitle. Zero or multiple hits → stop and report the actual strings.

### 11. Demo 03 — counter provenance note (M-5)

In `<03 mdx>`, find (verbatim, spans two lines):

```
per instruction**, indistinguishable from SSE's **1.00**, not the ~2× a 128-bit
split would force.
```

Replace with:

```
per instruction**, indistinguishable from SSE's **1.00**, not the ~2× a 128-bit
split would force. (These instruction and µop figures are measured with `perf`
over the same pinned binaries but are not fields in the committed JSON capture;
per-variant counter fields are planned for the next recapture.)
```

This wording asserts provenance — see Open items before merging it.

### 12. Codify the Reproducing-this convention (L-3)

In `BRIEF.md`, locate the footer/post-template conventions block (grep `footer`). Append one sentence: `"Reproducing this" sections appear only where a post has reproduction subtleties beyond the methodology page (currently demos 08 and 09); their absence elsewhere is deliberate.` Adapt placement to the block's existing formatting.

## Acceptance

Run from repo root; all must pass.

- **Build:** `npm run build` (site) succeeds.
- **Methodology:** `grep -c "implements 256-bit AVX2 as two" site/src/app/methodology/page.tsx` → 0; `grep -c "executes 256-bit AVX2 as single µops" …/page.tsx` → 1; `grep -c 'id="rdtscp-calibration"' …/page.tsx` → 1.
- **Footers:** `grep -c "methodology#rdtscp-calibration" <04 mdx>` → 1; same for `<05 mdx>` → 1.
- **Demo 04:** `grep -c "shallower C-states" <04 mdx>` → 0; `grep -c "deeper C-states" <04 mdx>` → 1; `grep -c "cpu0 cannot be kernel-isolated" <04 mdx>` → 1.
- **Demo 05:** `grep -c "sized to fit in L1d (~34 KB total)" <05 mdx>` → 0; `grep -c "separately-captured baseline" <05 mdx>` → 1.
- **Demo 02:** `grep -c "across all$" <02 mdx>` → 0 for the padded-latency sentence, i.e. `grep -c "2.85 ns/op across all" <02 mdx>` → 1 **and** the following line begins `intra-CCX thread counts`.
- **Demo 03:** `grep -c "not fields in the committed JSON capture" <03 mdx>` → 1.
- **Special:** `grep -rc "on the order of many" site/` → 0; built HTML for the special page contains `a single layer` and does not contain `roughly 1 layers`; `grep -rc "shows precisely why" site/` → 0.
- **Quantum JSON (Path A only):** python assert — all six `circuit_depth` rows carry integer `two_qubit_gates_decomposed`; grover n=5 value > 0; deep-diff vs `git show HEAD:<json>` shows additive-only change; the number rendered in the special page's two-qubit sentence equals the grover n=5 field.
- **Perf JSONs:** `git status` shows no diff on any of the eleven demo capture JSONs.
- **BRIEF.md:** `grep -c "their absence elsewhere is deliberate" BRIEF.md` → 1.

## Out of scope

- Any perf recapture or any modification to the eleven committed demo JSONs.
- All post prose not named above; chart components; the index page beyond the single L-5 string.
- The methodology page beyond Task 1's sentence and Task 2's new subsection.
- Hardware quantum capture, mitigation cells, or any non-null hardware value in the quantum JSON.
- Restructuring Reproducing-this sections in any post (Task 12 codifies; it does not move content).

## Open items for CC to flag

- **M-5 provenance (Task 11):** the inserted note asserts the counts came from `perf` over the same pinned binaries. Ask the user to confirm this wording in the PR before merge; if it's wrong, hold that one edit and surface.
- **M-1 prose (Task 2):** the new methodology subsection is fresh prose — mark it in the PR description for the user's editorial sign-off before merge.
- **Task 8:** qiskit import failure → Path B (pre-authorized), noted in PR. Reconstruction-vs-committed mismatch → stop entirely, no JSON change.
- **Task 4:** table sizes not statically derivable → stop and report.
- **Tasks 9/10:** grep-locate returning 0 or >1 hits → stop and report the actual strings found; the special page's source may phrase things differently from the rendered text observed.
- If the special page turns out to hard-code its numbers rather than render from the committed JSON, apply the literal edits and flag it — deriving that page from JSON is a candidate follow-up, not this brief.

## Stop condition

All acceptance checks green, PR open with finding IDs and the two sign-off items called out. User merges after signing off Tasks 2 and 11; deploy follows the normal Amplify flow. No further work under this brief.
