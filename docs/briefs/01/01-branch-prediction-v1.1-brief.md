# Crucible · CC Brief: `01-branch-prediction` v1.1 — review pass back-port

**Context.** Demo 1 shipped a while ago; demos 2–4 have since raised the methodology bar (perf-counter capture in JSON, `<CounterOverlay>` rendered alongside throughput, committed asm snippets, multi-N curves). A skeptical-review pass found the bench itself is sound — measurements are internally consistent, the disasm shows a real branch, `branch_misses_per_op` and `ipc` are already captured in the JSON — but the **post** leaves the most interesting evidence on the floor and answers the wrong production question.

Specifically, the review found:

1. The MDX shows a naïve `for` loop and implies that's what `-O3 -march=native` produces. The actual binary only has a branch because the function carries `__attribute__((optimize("no-tree-vectorize", "no-if-conversion", "no-if-conversion2")))`. A reader who pastes the displayed loop into Compiler Explorer will get cmov/masked-add and conclude the post is wrong.
2. The "Takeaway" tells readers to sort their input. The production-grade answer to a hot data-dependent branch is branchless code (cmov, mask). The post doesn't mention it.
3. `branch_misses_per_op` is captured but never visualised — quoted only as prose ("≈ 49.8%").
4. The committed asm proves the branch is real but is not embedded in the post.
5. Headline N = 32M is 128 MiB — DRAM-streaming territory. The 6× gap there conflates branch effect with bandwidth behaviour. The bench captures six sizes (1 K → 32 M); only the largest is shown.
6. "The predictor has no exploitable history" overclaims — Zen 2's TAGE predictor _can_ in principle find correlations; what the data shows is that it didn't find one in this shuffle.
7. "10–20 cycles" mispredict penalty is generic; the whole project is single-machine, should say Zen 2.
8. `std::sort` on 32 M ints stated as "2–3 seconds" — closer to ~1 s on a 3800X; either measure it or hedge.

All measurements stand. This is a back-port pass: add a third variant (branchless), measure the sort cost, recapture, then rewrite the MDX against the new evidence.

**Priority order.** (1) extend the benchmark with branchless + sort-cost variants, (2) verify the new asm, (3) re-capture, (4) build `<TimeVsN>` if it doesn't yet exist, (5) rewrite the MDX, (6) build/verify. **Do not start the MDX rewrite until re-capture is complete.**

---

## 1. Extend `bench/demos/01-branch-prediction/benchmark.cpp`

### 1a. Add a branchless variant

Add a third hot function alongside `sum_threshold`. Same input, same output, no branch on the data:

```cpp
// Branchless variant: ternary compiles to cmov on GCC at -O3, no data-
// dependent jump. `noinline` to keep it comparable to sum_threshold and to
// prevent the caller from re-optimising after inlining. No optimize() attribute
// needed — we want the compiler's natural cmov here.
__attribute__((noinline))
static int64_t sum_threshold_branchless(const std::vector<int32_t>& data) {
    int64_t sum = 0;
    for (auto x : data) {
        sum += (x >= 128) ? x : 0;
    }
    return sum;
}
```

Register a third Google Benchmark function `BM_Branchless` that calls this, mirroring `BM_Sorted` / `BM_Unsorted` structure. Use the shuffled input (same `make_shuffled(n)`, same seed 42) — the whole point is to show that on the _adversarial_ input, branchless beats both sorted and unsorted, because there is no branch to mispredict.

Apply `->Apply(sizes)` so the new variant is captured at all six N.

### 1b. Add a sort-cost measurement

Add a fourth benchmark that measures `std::sort` over a freshly-shuffled 32M-element vector. Single N (the headline size); this exists only to back the "sorting isn't free" caveat in the post with a real number rather than a guess.

```cpp
static void BM_Sort_32M(benchmark::State& state) {
    constexpr int64_t n = 33554432;
    auto base = make_shuffled(n);
    for (auto _ : state) {
        state.PauseTiming();
        auto v = base;                  // fresh copy per iteration
        state.ResumeTiming();
        std::sort(v.begin(), v.end());
        benchmark::DoNotOptimize(v.data());
    }
    state.SetItemsProcessed(static_cast<int64_t>(state.iterations()) * n);
}
BENCHMARK(BM_Sort_32M)->MinTime(2.0);
```

Use `PauseTiming`/`ResumeTiming` so the per-iteration copy is excluded. Acceptance: a single per-op number reported, which when multiplied by 32M gives total sort wall-time. Expect roughly 0.8–1.2 s for the full sort on a 3800X.

---

## 2. Verify the new asm before re-capturing

The existing inner-loop check (a `jl`/`jge` in `sum_threshold`) must still pass. Add two more:

```bash
# Branchless variant: must contain cmov*, must NOT contain a data-dependent
# conditional jump on the comparison result.
objdump -d build/demos/01-branch-prediction/bench_01_branch_prediction \
  | awk '/<_ZL23sum_threshold_branchless/,/^$/' \
  | grep -E '\bcmov' \
  || { echo "branchless variant: no cmov found, abort"; exit 1; }

# And it must not have re-vectorised — that would beat the sorted variant by
# 8x and obscure the comparison.
objdump -d build/demos/01-branch-prediction/bench_01_branch_prediction \
  | awk '/<_ZL23sum_threshold_branchless/,/^$/' \
  | grep -E '\b(vpcmpgtd|vpand|vpaddd)\b' \
  && { echo "branchless variant got vectorised; add no-tree-vectorize"; exit 1; } || true
```

If the branchless variant _does_ auto-vectorise into `vpcmpgtd`/`vpand`/`vpaddd`, that's actually fine for the production-answer story — but it changes the framing from "cmov beats mispredict" to "SIMD beats mispredict." If that happens, either:

- add `__attribute__((optimize("no-tree-vectorize")))` to keep the comparison apples-to-apples cmov-vs-branch, **or**
- accept the vectorisation and adjust the MDX prose to discuss it explicitly (this is honest and arguably more interesting). Choose the first if the cmov asm is clean; the second if `-O3` insists on SIMD-ing it.

Capture both inner loops (`sum_threshold` and `sum_threshold_branchless`) to disk during the run — the MDX will embed both.

---

## 3. Re-capture

After §1 and §2, run the existing `run_one.sh 01-branch-prediction`. Acceptance criteria for the new JSON:

- A third variant `"branchless"` appears in `runs[]` at all six N values, with `branch_misses_per_op` close to zero (cmov path has no data-dependent branch).
- `branchless` ns/op at N = 32M is between sorted and unsorted, ideally close to sorted. If branchless is _faster_ than sorted, that's fine — sorted still has the comparison branch, just a predictable one; the cmov path skips the comparison-as-control-flow entirely.
- Existing sorted/unsorted numbers should not have moved meaningfully (same code path, same input generation, same seed).
- A new top-level field `sort_cost` (or similar — pick one and document) reports the measured `std::sort` ns/op and the total wall time for 32M elements. Format suggestion:
  ```json
  "sort_cost_32m": {
    "ns_per_op": 28.5,
    "wall_seconds": 0.96,
    "iterations": 5
  }
  ```
  Place it as a sibling of `runs`, not inside it — it isn't a comparable hot-loop variant.

---

## 4. Build `<TimeVsN>` if not already present

Demo 2 built `<CounterOverlay>` as needed. Same pattern: if `site/src/components/charts/TimeVsN.tsx` does not exist, build it now. Contract from `BRIEF.md`:

```
<TimeVsN slug="01-branch-prediction" variants={["sorted","unsorted","branchless"]} stat="median" />
```

Renders ns/op vs N on log-x, with one line per variant. Markers at each measured N. Uses `theme.ts` palette and axis treatment shared with the other charts. The interesting visual feature here is the _ratio_ between lines — annotate the largest gap (likely at a cache-resident N) and the smallest (likely at N = 32M where bandwidth compresses everything). Optional: a secondary axis or twin chart showing the ratio sorted/unsorted across N, but only if it doesn't clutter; a single time-vs-N is acceptable.

If the component exists, just use it; do not refactor.

---

## 5. Rewrite `site/src/posts/01-branch-prediction.mdx`

Do not start this until §1–3 are complete and the new JSON is in.

### 5a. Code block — show what actually runs

Replace the current `<CodeCompare>` block (lines ~15-32). The current version shows a naïve loop and pretends that's what runs. The honest version shows the attributed function on one side and the branchless version on the other:

```mdx
<CodeCompare
  lang="cpp"
  labels={["Branching (sorted or unsorted input)", "Branchless"]}
  naive={`// The compiler will happily turn this loop into a masked SIMD add or a
// scalar cmov — both of which eliminate the branch we're trying to study.
// Function-level attributes disable the two transformations that defeat
// the experiment, keeping -O3 -march=native everywhere else.
__attribute__((noinline,
               optimize("no-tree-vectorize",
                        "no-if-conversion",
                        "no-if-conversion2")))
static int64_t sum_threshold(const std::vector<int32_t>& data) {
    int64_t sum = 0;
    for (auto x : data) {
        if (x >= 128) sum += x;       // real conditional jump
    }
    return sum;
}`}
  optimized={`// No attributes needed — GCC emits cmov for the ternary at -O3.
// There is no data-dependent branch for the predictor to get wrong.
__attribute__((noinline))
static int64_t sum_threshold_branchless(const std::vector<int32_t>& data) {
    int64_t sum = 0;
    for (auto x : data) {
        sum += (x >= 128) ? x : 0;    // compiles to cmov
    }
    return sum;
}`}
/>
```

Adjust the prose around the block. The new framing is "three runs of the same loop body, with two axes of variation: input order (sorted vs shuffled) and control flow (branching vs branchless)." The sorted/unsorted comparison still drives the headline; the branchless variant is what a real hot-path engineer would actually ship.

### 5b. Branchless section — production-grade answer

Add a new section (before "Takeaway" feels right) titled something like **"What you'd actually ship"** or **"The branchless variant"**. Content:

- Show the cmov in the asm (extracted in §2). One-line annotation pointing at the `cmovge`/`cmovl` instruction.
- Report its ns/op at N = 32M from the new JSON.
- Make the point explicitly: sorting your input is the right answer when ordering is free or naturally maintained (time-ordered events, a sorted index structure, an already-sorted column store). It is not the right answer for a generic hot data-dependent branch in a tight loop — there, you write branchless code and the predictor never enters the picture.
- One caveat: branchless trades a possible-skip for a guaranteed-execute. If the predicate is very rarely true _and_ the unselected work is expensive, the predictable branch can win. Don't belabour this; one sentence.

### 5c. Embed the counter overlay

After the throughput bars, add:

```mdx
<CounterOverlay
  slug="01-branch-prediction"
  metric="branch_misses_per_op"
  variants={["sorted", "unsorted", "branchless"]}
/>
```

The component already exists from demo 2. This makes the proximate cause (mispredict rate) visible alongside the effect (ns/op). One short paragraph between the two charts is enough — they speak for themselves.

### 5d. Embed the asm snippet

After the new `<CodeCompare>` block, paste the inner loop from the committed disasm. The hot loop is seven instructions in `sum_threshold`:

```asm
b8d0:  movslq (%rax),%rdx        # load x
b8d3:  cmp    $0x7f,%edx         # x >= 128 ?  (0x7f = 127)
b8d6:  jle    b8db               # ← the branch we're studying
b8d8:  add    %rdx,%rsi          # sum += x
b8db:  add    $0x4,%rax          # ++p
b8df:  cmp    %rcx,%rax
b8e2:  jne    b8d0               # loop
```

Then a one-line "and here is the branchless version" with the corresponding extracted snippet for `sum_threshold_branchless` (will contain a `cmovge` or `cmovl` instead of `jle`/`add`). Annotate the cmov.

### 5e. Add `<TimeVsN>` and discuss the gap across the cache hierarchy

After the bar chart and counter overlay, add a `<TimeVsN>` view across all six captured N. Then a short section discussing how the gap evolves. Suggested talking points (CC: check against the actual new JSON, do not write to expectation):

- At cache-resident N the per-element cost is dominated by the loop's arithmetic and the mispredict penalty; expect the largest _ratio_ between sorted and unsorted there.
- At N = 32M (128 MiB, well beyond L3's 32 MiB on this part) both variants are partially DRAM-bound; mispredict cost overlaps with memory waits, so the ratio compresses but the absolute throughput gap stays meaningful.
- Branchless tracks sorted closely at small N (no branch to mispredict, predictable memory access for both) and tracks the floor at large N (both variants become bandwidth-bound).

The current "6.1× at N=32M" headline still works; reframe it as the _floor_ of the effect rather than the peak. The peak ratio across N is the more interesting number once the curve is visible.

### 5f. TAGE caveat

Replace the current "The predictor has no exploitable history" sentence with something honest about modern predictors. Suggested:

> Unsorted input is adversarial. The condition resolves `true` or `false` in pseudo-random order (seed 42, uniform over 0–255). Zen 2's TAGE-style predictor _can_ in principle pick up long-history correlations even on superficially random data — what the measured 49.8% mispredict rate tells us is that no such pattern exists in this shuffle, and the predictor converges on the 50% ceiling for a fair binary outcome.

### 5g. Zen 2-specific mispredict penalty

Replace "a stall of roughly 10–20 cycles on a modern microarchitecture" with the Zen 2 figure. Zen 2's frontend-to-retire mispredict penalty is roughly 19 cycles. Suggested:

> When the guess is wrong, the pipeline is flushed and the correct path must be re-fetched and re-executed — roughly 19 cycles on Zen 2 (the frontend-to-retire depth).

### 5h. Sort cost — replace the guess with the measured value

Replace the current "around 2–3 seconds" with the measured `sort_cost_32m.wall_seconds` from the new JSON. Round to one decimal. Suggested template:

> `std::sort` on these 32 M integers takes **~0.96 s** on the reference machine — measured, not estimated. If the array is consumed once, sorting first is a net loss. The technique pays when the same data is scanned many times, when a sorted structure can be maintained incrementally, or when ordering falls out of the problem (events in time order, an index column).

(Use whatever the new JSON actually reports; the 0.96 s is illustrative.)

### 5i. Closing reframe

The current closing paragraph ("algorithmic complexity does not account for branch mispredicts… Always measure.") is fine but lands weaker once branchless is in the picture. Suggested replacement:

> Two O(n) algorithms with identical instruction counts can differ by 6× in wall time if one is predictor-friendly and the other is not. And both can lose to the same loop written branchlessly. The classic branch-prediction demo isn't really a lesson about sorting — it's a lesson about how much performance is hiding in the control-flow shape of your hot loop. Always check the disassembly, always measure, and when the branch is the bottleneck, consider removing it rather than feeding it predictable inputs.

---

## 6. Footer / metadata

- Update the trailing `*All numbers: …*` line to reflect any methodology changes. If `sort_cost_32m` is in the JSON, mention it. If branchless is shown, mention compiler flags relevant to it.
- `date:` front-matter: update to the re-capture date.

---

## 7. Build verification

```bash
cd site && npm run build
```

Visually verify on `npm run dev`:

- `<CodeCompare>` shows the two attributed functions, side-by-side, properly highlighted.
- Throughput bars render three variants: sorted, unsorted, branchless.
- `<CounterOverlay>` renders branch-miss rate per variant — sorted ~0, unsorted ~0.5, branchless ~0.
- `<TimeVsN>` renders three lines across the six N values.
- The asm snippets render as code blocks with monospaced text.
- No `2–3 seconds`, `10–20 cycles`, or naïve unattributed `for` loop survives anywhere in the body.

---

## Acceptance criteria

- [ ] `bench/demos/01-branch-prediction/benchmark.cpp` defines `sum_threshold_branchless`, `BM_Branchless`, and `BM_Sort_32M`.
- [ ] objdump of `sum_threshold_branchless` shows a `cmov*` instruction; no `jle`/`jge` on the comparison result; no `vp*` SIMD ops in the inner loop (unless explicitly accepted per §2).
- [ ] New JSON includes a `branchless` variant at all six N with `branch_misses_per_op < 0.01`.
- [ ] New JSON includes a `sort_cost_32m` block with `wall_seconds` between roughly 0.5 and 2.0 (sanity range; report whatever it is).
- [ ] `<TimeVsN>` component exists at `site/src/components/charts/TimeVsN.tsx` and renders cleanly with three variants.
- [ ] MDX `<CodeCompare>` shows the attributed `sum_threshold` and the branchless variant — not a naïve loop.
- [ ] MDX embeds an asm snippet for each variant.
- [ ] MDX renders `<CounterOverlay>` and `<TimeVsN>` after the throughput bars.
- [ ] No prose number contradicts the JSON; sort cost reported is the measured value.
- [ ] TAGE caveat and Zen-2-specific 19-cycle figure are present.
- [ ] `npm run build` succeeds; Lighthouse performance ≥ 90 on the post page (carry-over from v1 acceptance).

---

## Out of scope

- Methodology page changes. The page already documents the four locked commitments; nothing here invalidates them. If the page lists the demos and their headlines, update only that line.
- Other demos. The CounterOverlay-in-post pattern this brief uses was established by demo 2 — do not retroactively touch demos 2/3/4.
- Data schema changes beyond adding `sort_cost_32m` (or whatever you name it). Do not rename existing fields.
- Cross-machine comparisons. Single reference machine, as always.
- Replacing `std::sort` with a faster sort to make the caveat weaker. The point of the caveat is to be honest about cost; don't engineer around it.
