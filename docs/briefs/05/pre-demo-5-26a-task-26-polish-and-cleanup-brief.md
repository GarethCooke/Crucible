# Crucible — task-26 polish + tracked cleanup — CC brief (26a)

Companion to `pre-demo-5-review-tasks.md` task 26. Brief 25c landed cleanly (build passing, all numerical claims verified). Task 26 surfaced four polish items in the MDX and confirmed three known-but-unactioned cleanup items. This brief handles all seven in one PR.

Scope: one MDX file, one JSON file, one or two markdown reference docs, and a `find`/delete sweep. No C++ source changes; no benchmark re-runs.

## Pre-flight (CC: do this first, abort if it fails)

```bash
python3 - << 'EOF'
import json, os, re

# JSON sanity (cross-CCX still the May 21 capture)
with open('site/src/data/perf/05-allocators-cross-ccx.json') as f:
    cc = json.load(f)
with open('site/src/data/perf/05-allocators.json') as f:
    main = json.load(f)

ok = True
for label, j in [('main', main), ('cross-ccx', cc)]:
    if j.get('captured_at') != '2026-05-21T17:52:54Z':
        print(f'CAPTURE DRIFT on {label}: {j.get("captured_at")}')
        ok = False

# Spot-check main JSON paced values (proof JSON unchanged)
paced = {r['variant']: r['latency_ns']['stats']
         for r in main['runs'] if r.get('mode') == 'paced'}
sentinels = {
    'cross-thread-malloc':   {'p50': 172, 'p99': 296, 'p99_9': 392, 'max': 46710},
    'freelist-return-queue': {'p50': 172, 'p99': 220, 'p99_9': 312, 'max': 10860},
    'arena-batch-handoff':   {'p50': 204, 'p99': 244, 'p99_9': 344, 'max': 14780},
}
for v, exp in sentinels.items():
    got = paced.get(v, {})
    for k, want in exp.items():
        if got.get(k) != want:
            print(f'SENTINEL MISMATCH {v}.{k}: expected {want}, got {got.get(k)}')
            ok = False

# Cross-CCX sentinels
cc_paced = {r['variant']: r['latency_ns']['stats'] for r in cc['runs']}
cc_sentinels = {
    'cross-thread-malloc':   {'p50': 408, 'p99': 1120, 'p99_9': 1760},
    'freelist-return-queue': {'p50': 408, 'p99': 688,  'p99_9': 720},
    'arena-batch-handoff':   {'p50': 408, 'p99': 688,  'p99_9': 720},
}
for v, exp in cc_sentinels.items():
    for k, want in exp.items():
        if cc_paced.get(v, {}).get(k) != want:
            print(f'CROSS-CCX SENTINEL MISMATCH {v}.{k}: expected {want}, got {cc_paced.get(v,{}).get(k)}')
            ok = False

# Prove 25c landed (post should have the post-rewrite frontmatter summary)
with open('site/src/posts/05-allocators.mdx') as f:
    mdx = f.read()
if 'The result that survives contact with the data' not in mdx:
    print('MDX state: 25c does NOT appear to have landed (missing post-rewrite thesis text)')
    ok = False
if 'The bump-pointer that doesn\'t win' not in mdx:
    print('MDX state: 25c bump-pointer section title missing')
    ok = False

print('PRE-FLIGHT PASS' if ok else 'PRE-FLIGHT FAIL — STOP, contact Opus')
EOF
```

If pre-flight fails: stop, surface mismatches, wait. If pass: proceed.

---

## Part A — MDX polish (4 edits on `site/src/posts/05-allocators.mdx`)

### A.1 — Thesis preview of the inversion (medium priority)

**Why:** A reader who only scans §Thesis comes away with "malloc has a tail problem" as the headline, missing the post's more original finding (the bump-pointer arena doesn't win). §Headline delivers the inversion within one page-down, but the lede should be in the thesis.

**Current (line 13):**

```
This post measures three strategies for the cross-thread free pattern: the baseline that most real systems actually ship, and two honest domain-specific designs. The result that survives contact with the data isn't the one the design discussion would lead you to expect.
```

**Replace with:**

```
This post measures three strategies for the cross-thread free pattern: the baseline that most real systems actually ship, and two honest domain-specific designs. The result that survives contact with the data isn't the one the design discussion would lead you to expect: the bump-pointer arena's theoretical fast-path advantage doesn't materialise against the freelist's amortised return queue, and the gap between the pool variants and `new`/`delete` is much smaller on same-CCX than the design framing implies.
```

### A.2 — Cross-CCX max acknowledgement (minor)

**Why:** §Headline calls out same-CCX max (line 82) but §Cross-CCX doesn't. The omitted statistic happens to be the one where the arena loses to both alternatives (arena max=12,200 vs malloc 10,460 vs freelist 7,200). The post's "freelist and arena both top out at p99.9 = 720 — within sample-noise" is true at p99.9 but a hostile reviewer will spot the asymmetry. Add one sentence mirroring the same-CCX max treatment.

**Current (lines 155, the cross-CCX tail paragraph):**

```
The tail picture is where the variants part. The freelist and arena both top out at p99.9 = 720 ns — within sample-noise of each other, both about 2.1–2.3× their same-CCX baselines. Malloc reaches p99 = 1120 ns and p99.9 = 1760 ns. That's 1.63× the pool variants at p99 and 2.44× at p99.9 in absolute terms, and a 4.5× expansion of malloc's same-CCX baseline (392 → 1760) versus the pools' 2.1–2.3× expansion. The cross-CCX environment amplifies malloc's allocator-overhead tail disproportionately — the lock-contention paths and arena coordination that malloc has to do internally pay an extra Infinity-Fabric round-trip every time they cross between threads on different L3 domains.
```

**Replace with:**

```
The tail picture is where the variants part. The freelist and arena both top out at p99.9 = 720 ns — within sample-noise of each other, both about 2.1–2.3× their same-CCX baselines. Malloc reaches p99 = 1120 ns and p99.9 = 1760 ns. That's 1.63× the pool variants at p99 and 2.44× at p99.9 in absolute terms, and a 4.5× expansion of malloc's same-CCX baseline (392 → 1760) versus the pools' 2.1–2.3× expansion. The cross-CCX environment amplifies malloc's allocator-overhead tail disproportionately — the lock-contention paths and arena coordination that malloc has to do internally pay an extra Infinity-Fabric round-trip every time they cross between threads on different L3 domains.

Single-sample max values cross-CCX don't track the percentile ordering: freelist 7,200, malloc 10,460, arena 12,200. Same caveat as the same-CCX headline — one sample out of five million doesn't carry a robust ordering, and these numbers reflect where an interrupt or scheduling event happened to land rather than a structural property of the variant.
```

### A.3 — "Naïve thread-local pool" wording (minor)

**Why:** Line 7's opening hook says cross-thread free "breaks naïve thread-local pool allocators." The three measured variants are: no pool (malloc), pool + return queue (freelist — the winner), and bump-pointer arena (arena). The "naïve thread-local pool" that would break — one without a return-path mechanism — isn't in the post. The hook reads conversationally but a careful reader can fault the mismatch.

**Current (line 7):**

```
A market-data thread hands off 64-byte Orders to a risk thread. The risk thread frees them after checking positions, limits, and velocity. This is the pattern every real trading system uses, and it is the one that breaks naïve thread-local pool allocators — the free happens on a different thread from the alloc.
```

**Replace with:**

```
A market-data thread hands off 64-byte Orders to a risk thread. The risk thread frees them after checking positions, limits, and velocity. This is the pattern every real trading system uses, and it is the one that breaks naïve thread-local pool allocators (those whose pool can only return memory on the allocating thread) — the free happens on a different thread from the alloc.
```

### A.4 — §Throughput predictability claim (conditional edit, verify first)

**Why:** §Throughput is unchanged from pre-rewrite and asserts "the pool variants show slightly tighter variance because the allocator cost is more predictable." This pluralises "pool variants" — true only if both freelist AND arena have iqr ≤ malloc's iqr. Brief 25c didn't touch this section; verifying it now closes the audit.

**Step 1 — Verify:**

```bash
python3 - << 'EOF'
import json
with open('site/src/data/perf/05-allocators.json') as f:
    j = json.load(f)
paced_iqr = {r['variant']: r['ns_per_op']['iqr']
             for r in j['runs'] if r.get('mode') == 'paced'}
print("Same-CCX paced iqr (ns):")
for v, iqr in paced_iqr.items():
    print(f"  {v:<25} iqr={iqr}")

m = paced_iqr.get('cross-thread-malloc', 0)
f = paced_iqr.get('freelist-return-queue', 0)
a = paced_iqr.get('arena-batch-handoff', 0)

if f <= m and a <= m:
    print('VERDICT: Both pool variants tighter than malloc — prose is correct, NO EDIT NEEDED.')
elif f <= m and a > m:
    print('VERDICT: Only freelist tighter — narrow "the pool variants" to "the freelist variant" (see Step 2a).')
elif f > m and a <= m:
    print('VERDICT: Only arena tighter — narrow "the pool variants" to "the arena variant" (see Step 2b).')
else:
    print('VERDICT: Neither pool tighter than malloc — claim is wrong, see Step 2c and STOP for Opus review.')
EOF
```

**Step 2 — Apply edit based on verdict:**

**Step 2a (only freelist tighter):**

Current (line 116):
```
At 1 MHz paced load the throughput numbers reflect how faithfully each variant sustains the offered rate over 5M items. All three variants sustain close to 1 M/s; the pool variants show slightly tighter variance because the allocator cost is more predictable. Throughput differences are secondary to latency at this load level.
```

Replace with:
```
At 1 MHz paced load the throughput numbers reflect how faithfully each variant sustains the offered rate over 5M items. All three variants sustain close to 1 M/s; the freelist variant shows slightly tighter variance than malloc or arena because its amortised return-queue drain smooths over per-allocation cost spikes. Throughput differences are secondary to latency at this load level.
```

**Step 2b (only arena tighter):**

Current line 116 (as above) → replace with:
```
At 1 MHz paced load the throughput numbers reflect how faithfully each variant sustains the offered rate over 5M items. All three variants sustain close to 1 M/s; the arena variant shows slightly tighter variance than malloc or freelist because its bump-pointer hot path has the most predictable per-allocation cost. Throughput differences are secondary to latency at this load level.
```

**Step 2c (neither pool tighter than malloc):** STOP. Surface the iqr values and abort this part of the brief — the prose needs a more substantial rewrite that Opus will draft based on the actual variance picture. Apply all other parts of this brief; flag this one for follow-up.

**Step 2d (both pool variants tighter — original prose correct):** No edit. Note "verified" in PR description.

---

## Part B — Cross-CCX JSON `notes` field copy-paste bug

**Why:** `site/src/data/perf/05-allocators-cross-ccx.json` `notes` field currently says *"Producer pinned to core 4, consumer to core 5 (same CCX1 on Zen 2 3800X). Background pressure thread (T_bg) pinned to core 6 (same CCX1)..."* — that's the same-CCX run's notes copy-pasted. The actual cross-CCX topology is consumer on core 1 (CCX0). The `notes` field is descriptive, not load-bearing for chart rendering, but it's wrong and any future tool that reads notes (debugger, audit script, downstream tooling) will hit the wrong description.

### B.1 — Apply post-process fix (immediate)

Run:

```bash
python3 - << 'EOF'
import json
path = 'site/src/data/perf/05-allocators-cross-ccx.json'
with open(path) as f:
    cc = json.load(f)

correct_notes = (
    "Producer pinned to core 4 (CCX1), consumer to core 1 (CCX0) — "
    "cross-CCX configuration on Zen 2 3800X (queue traverses Infinity Fabric "
    "rather than shared L3). Background pressure thread (T_bg) pinned to "
    "core 6 (CCX1). Order struct: 64 B, alignas(64). End-to-end latency: "
    "rdtscp after allocate() → rdtscp after simulated risk check. Warmup: "
    "100k items pre-roll per iteration. Paced: 1 MHz offered load, 1 M/s "
    "background pressure."
)

cc['notes'] = correct_notes

with open(path, 'w') as f:
    json.dump(cc, f, indent=2)
    f.write('\n')

print('Notes field updated.')
EOF
```

Verify `captured_at` is unchanged after the rewrite (it should be — the post-process only touches the `notes` field).

### B.2 — Locate and fix the source of the bug (investigation)

The `notes` field is most likely emitted by either:
- The C++ benchmark binary's JSON emission code (in `bench/demos/05-allocators/`)
- The Python aggregator script that stitches per-run outputs into the demo's JSON

Search for the offending string:

```bash
grep -rn 'same CCX1 on Zen 2 3800X' bench/ tools/ scripts/ 2>/dev/null
grep -rn 'Producer pinned to core 4' bench/ tools/ scripts/ 2>/dev/null
```

Once located:
- If it's a C++ string literal in the benchmark binary, the same-CCX and cross-CCX runs are presumably using the same emission path with a hardcoded notes string. The fix is to make the notes string a function of the actual core-pinning config rather than a hardcoded value. Apply the fix; flag whether a recompile is needed.
- If it's in the aggregator script, the fix is similar: derive notes from the actual config rather than hardcoding.

**Do not** re-run the benchmark to regenerate the JSON — that would change `captured_at` and break every downstream pre-flight check. The post-process in B.1 is sufficient for the JSON itself; B.2 is to prevent the next capture from having the same bug.

If the source can't be located in a reasonable search (15 minutes), flag and skip B.2 — B.1 has fixed the immediate symptom; B.2 can be tracked separately.

---

## Part C — Stale May 20 capture cleanup

**Why:** Brief 25b was based on a `2026-05-20T21:40:13Z` capture of `05-allocators.json` that contradicted the repo's May 21 file. The May 20 file isn't in the repo but is sitting somewhere on disk (was uploaded into a previous chat). Find and delete any local copies to prevent future audit contamination.

### C.1 — Search

```bash
echo "=== All 05-allocators*.json files on disk with captured_at ==="
find / -name '05-allocators*.json' -type f 2>/dev/null | while read f; do
    ts=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('captured_at','<no_ts>'))" "$f" 2>/dev/null || echo "<unreadable>")
    echo "  ${ts}  ${f}"
done
```

Expected canonical location: `site/src/data/perf/05-allocators.json` and `site/src/data/perf/05-allocators-cross-ccx.json`, both with `captured_at: 2026-05-21T17:52:54Z`. Anything else is a candidate for deletion.

### C.2 — Surface candidates

For every found file that:
- Is NOT under `site/src/data/perf/`, AND
- Has `captured_at` of `2026-05-20T*` OR is unreadable OR has a different timestamp than May 21

→ Surface the file path and timestamp in the PR description. **Do not delete automatically.** The user will confirm which to delete based on the list.

Acceptable to leave files in `~/.cache`, `node_modules`, etc. alone unless explicitly listed. The targets are likely in `Downloads/`, `Desktop/`, a chat-upload staging directory, or a stray `bench/captures/` archive.

---

## Part D — Pre-flight pattern documentation

**Why:** Brief 25b's failure (writing edits against a stale JSON that contradicted the repo) was caught by the captured_at + sentinel-values pre-flight check in 25c. That pattern should be the default for any future brief that prescribes prose edits against specific data values. Documenting it makes it the convention rather than a one-off save.

### D.1 — Decide where it goes

Read both:
```bash
head -50 BRIEF.md
head -50 crucible-handover.md
```

`BRIEF.md` is the convention/template doc for how briefs should be structured. The pre-flight pattern belongs there.
`crucible-handover.md` is the persistent context doc handed to new chats. A one-line reference to the pattern (and a pointer to BRIEF.md) belongs here, not the full pattern.

If `BRIEF.md` doesn't have a section structure that obviously accommodates this (e.g. it's pure narrative), surface its current outline and ask Opus before adding. Otherwise, add the section per D.2.

### D.2 — Add to `BRIEF.md`

Append a new section (at the end, or wherever briefs-against-data conventions logically fit — use your judgment):

````markdown
## Pre-flight checks for prose-against-data briefs

When a brief prescribes prose edits against specific data values (e.g. percentile claims in MDX based on JSON benchmark output), the brief MUST include a pre-flight check that validates two things:

1. **The data file's `captured_at` timestamp** matches the timestamp the brief was written against. Capture re-runs change every measurement value; a brief authored against one capture can't be safely applied to another.
2. **A handful of sentinel statistics** match the values the brief assumes. Catches the case where two captures share a timestamp but differ in values (shouldn't happen, but the check is cheap).

The check runs as a Python snippet at the top of the brief, before any edits. On failure: `STOP, surface the mismatches, contact Opus for a new brief.` No interpretation, no partial application.

Reference implementation: any of the `pre-demo-5-25c-*` or later briefs.

Why this matters: brief 25b (May 22) was authored against a `2026-05-20` JSON capture that didn't match the repo's `2026-05-21` capture. The pre-flight in its successor brief 25c caught the mismatch and prevented a wrong-direction rewrite from landing.

### When to skip

Pre-flight isn't needed for briefs that:
- Don't reference specific data values (e.g. pure refactoring, structural, code-only briefs).
- Reference data values only in passing for context, where the brief's correctness doesn't depend on those values being accurate.

When in doubt, include the pre-flight — it's a five-line Python snippet and costs nothing if everything's fine.
````

### D.3 — One-line reference in `crucible-handover.md`

Add to the "Tools & resources" or equivalent section a one-line note:

```markdown
- Prose-against-data briefs use a pre-flight check pattern (see `BRIEF.md` § "Pre-flight checks for prose-against-data briefs"). Established after the 25b → 25c stale-capture incident.
```

If the handover doc doesn't have an obviously matching section, surface its current outline and ask before inserting.

---

## Acceptance criteria

After CC's PR lands:

**MDX (Part A):**
- §Thesis previews the bump-pointer inversion finding (A.1).
- §Cross-CCX acknowledges single-sample max with all three numbers and the noise caveat (A.2).
- Line 7 hook parenthetical correctly characterises what "naïve" means (A.3).
- §Throughput's "pool variants tighter" claim is verified or narrowed to whichever variant is actually tighter than malloc (A.4).
- All numerical claims in the post are still traceable to the May 21 JSON values.
- Build still passes.
- Lighthouse ≥ 90 perf, ≥ 90 a11y still holds on `/posts/05-allocators`.

**JSON (Part B):**
- `05-allocators-cross-ccx.json` `notes` field describes the actual cross-CCX topology (consumer on core 1, CCX0).
- `captured_at` unchanged at `2026-05-21T17:52:54Z`.
- Every other field bit-identical to before. (Diff should be `notes`-line-only.)
- Source of the bug located and fixed in the benchmark binary or aggregator, OR explicit flag in PR description that B.2 is deferred.

**Cleanup (Part C):**
- PR description lists every `05-allocators*.json` file found outside the canonical site path with its `captured_at`.
- No file deleted without user confirmation.

**Convention (Part D):**
- `BRIEF.md` has the pre-flight section.
- `crucible-handover.md` has the one-line reference.
- Both edits are minimal and don't restructure surrounding sections.

## Out of scope

- C++ source changes other than the B.2 notes-field fix.
- Benchmark re-runs.
- Methodology page edits.
- Demo 1–4 MDX changes (any structural convention drift identified during this work is a separate cleanup brief).
- The `isolated_cpus_effective: 1-7` vs `requested: 0-7` GRUB question — the post (post-25c) already describes the actual state honestly; whether to change the kernel cmdline is a separate decision.

## Open items for CC to flag during implementation

1. **A.4 verdict.** State explicitly which of Step 2a / 2b / 2c / 2d was triggered, and what the iqr values were.
2. **B.2 outcome.** State whether the source of the notes bug was located and fixed, or deferred. If fixed and a recompile is needed, note it but DON'T run the recompile — that's a separate decision because it'd bump `captured_at` on any subsequent capture.
3. **Part C file list.** Surface the full found-file list with timestamps, even if it's just the two canonical site-path files. Negative result is information.
4. **D.1 decision.** Note which of `BRIEF.md` and `crucible-handover.md` actually contains the convention pattern; if neither has an obvious section, surface their outlines and pause for Opus.

## Brief ordering

This brief replaces the "tracked separately, outside this merge" list at the bottom of the task-26 review. After this lands, the demo-5 pre-merge sequence is:

- Tasks 1–24: ☑
- Task 25 (MDX honesty pass): ☑ (via 25c)
- Task 26 (pre-merge review): ☑ (via the review that produced this brief)
- This brief (26a, task-26 polish + cleanup): pending CC
- Task 27 onward: Demo 5 ships, Phase 2 closes, demo 6 scoping starts

Once 26a lands, demo 5 is ship-ready.
