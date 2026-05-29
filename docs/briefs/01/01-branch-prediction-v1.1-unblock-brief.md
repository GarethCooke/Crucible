# Crucible · CC Brief: `01-branch-prediction` v1.1 — unblock and finish

**Context.** The v1.1 back-port brief was handed; CC implemented §1 (branchless + sort-cost variants) and §2 (asm verifier). The run hit two issues:

1. **Warning during §2 verify:** `sum_threshold_branchless` auto-vectorised into `vpcmpgtd`/`vpand`/`vpaddd`. The verifier correctly flagged this but the lock between "force cmov" and "accept SIMD" was left to a follow-up.
2. **Error during §3 capture:** `bench/scripts/assemble_results.py:39` blew up on `BM_Sort_32M/min_time:2.000` because it tries to parse the second `/`-separated part as `n`, and the sort-cost benchmark has no `->Arg()` — only `->MinTime(2.0)`.

The benchmarks themselves ran cleanly (cset shield, 20 reps per variant×size, etc.). Only the post-processing assembled JSON failed.

This brief locks the cmov decision, tightens the verifier, fixes the parser, and lays out the MDX work that follows (§4–7 of the original v1.1 brief still applies; small additions noted below).

**Priority order.** (1) cmov fix, (2) verifier tightening, (3) parser fix, (4) re-capture, (5) MDX rewrite per original v1.1 brief plus two additions noted in §5 below.

---

## 1. Force cmov in the branchless variant

Decision: keep the branchless variant scalar-cmov, not SIMD. Reasoning:

- Demo 1's job is to isolate the **branch** effect. If branchless = 8-wide SIMD, the bar chart conflates mispredict cost with vectorisation width — two different stories competing.
- Demo 3 owns vectorisation (Black-Scholes per the handover). Don't preempt it here.
- All three variants should do identical scalar arithmetic; only the control-flow shape differs. Apples-to-apples comparison.

### Patch

`bench/demos/01-branch-prediction/benchmark.cpp`:

```cpp
// Match the branching variant's compiler discipline. Without this, GCC
// auto-vectorises the loop into vpcmpgtd/vpand/vpaddd (verified at -O3
// -march=znver2 with GCC 13.3) — a separate ~8x effect that muddles
// what this demo measures. Demo 3 explores vectorisation properly.
__attribute__((noinline, optimize("no-tree-vectorize")))
static int64_t sum_threshold_branchless(const std::vector<int32_t>& data) {
    int64_t sum = 0;
    for (auto x : data) {
        sum += (x >= 128) ? x : 0;
    }
    return sum;
}
```

Rebuild. Verifier should now show `OK · cmov confirmed` with no SIMD warning.

---

## 2. Tighten the verifier

The current behaviour is "warn and continue" — useful for the iteration we just did, but the choice is now locked. Change the SIMD check on `sum_threshold_branchless` from a warning to a hard fail, matching the existing behaviour for `sum_threshold`.

In whatever script holds the verifier logic (likely `run_one.sh` or a helper it calls):

```bash
# sum_threshold_branchless: must contain cmov; must NOT contain SIMD ops.
asm_branchless=$(objdump -d "$BIN" | awk '/<_ZL23sum_threshold_branchless/,/^$/')

echo "$asm_branchless" | grep -qE '\bcmov' \
  || { echo "FAIL: no cmov found in sum_threshold_branchless"; exit 1; }

if echo "$asm_branchless" | grep -qE '\b(vpcmpgtd|vpand|vpaddd|vmovdqa)\b'; then
    echo "FAIL: sum_threshold_branchless was vectorised."
    echo "      Compiler defeated the experiment — add optimize(\"no-tree-vectorize\")."
    exit 1
fi

echo "OK · cmov confirmed in sum_threshold_branchless"
```

Same `exit 1` discipline as the existing `sum_threshold` check. No more warnings — the rule is now: scalar cmov in branchless, full stop. Future toolchain changes that defeat this should break the build, not slip through.

---

## 3. Fix `bench/scripts/assemble_results.py`

### Root cause

Line 39 does the equivalent of:

```python
parts = bench['name'].split('/')
n = int(parts[1]) if len(parts) > 1 else 0
```

This assumes the second slash-separated component is the size argument. That's true for variants registered with `->Arg(n)->MinTime(0.5)` (e.g. `BM_Sorted/1024/min_time:0.500` → `parts[1] == '1024'`), but false for `BM_Sort_32M/min_time:2.000` where the only suffix is `min_time:2.000`.

Two fixes needed: defensive name parsing, and routing the sort-cost result to the `sort_cost_32m` sidecar block rather than treating it as a regular variant in `runs[]`.

### 3a. Defensive name parsing

Replace the brittle `int(parts[1])` with a scan that picks the first numeric part. This is robust to:

- Variants with `->Arg(n)` only.
- Variants with `->Arg(n)->MinTime(t)`.
- Variants with `->MinTime(t)` only (no `Arg`).
- Future variants using `->Args({a, b})` or named args.

```python
def parse_bench_name(name: str) -> tuple[str, int]:
    """Parse a Google Benchmark name like:
        'BM_Sorted/1024/min_time:0.500'  -> ('sorted', 1024)
        'BM_Sort_32M/min_time:2.000'     -> ('sort_32m', 0)
        'BM_Branchless/10240'            -> ('branchless', 10240)
    Returns (variant_lowercase, n). n=0 means "no size argument".
    """
    parts = name.split('/')
    variant = parts[0].removeprefix('BM_').lower()
    n = 0
    for p in parts[1:]:
        try:
            n = int(p)
            break
        except ValueError:
            continue
    return variant, n
```

Replace line 39 (and any similar logic elsewhere in the file) with calls to this helper. Add a couple of inline unit tests at the bottom of the module — these are cheap and prevent future regressions:

```python
if __name__ == '__main__' and '--self-test' in sys.argv:
    assert parse_bench_name('BM_Sorted/1024/min_time:0.500')  == ('sorted', 1024)
    assert parse_bench_name('BM_Unsorted/33554432')           == ('unsorted', 33554432)
    assert parse_bench_name('BM_Branchless/1024')             == ('branchless', 1024)
    assert parse_bench_name('BM_Sort_32M/min_time:2.000')     == ('sort_32m', 0)
    print('parse_bench_name: OK')
```

### 3b. Route `sort_32m` to the sidecar

The sort-cost measurement is not a comparable hot-loop variant; it's a one-shot fact ("how long does std::sort take on 32M ints"). It shouldn't appear in `runs[]` next to sorted/unsorted/branchless because no chart should plot it on the same axis. Per the original brief, it lives at the top level as `sort_cost_32m`.

In `main()`, after parsing each benchmark entry:

```python
variant, n = parse_bench_name(entry['name'])

if variant == 'sort_32m':
    # Sidecar: not a runs[] row.
    output['sort_cost_32m'] = {
        'n':            33554432,
        'ns_per_op':    entry['real_time'],            # whatever field GB emits
        'wall_seconds': entry['real_time'] * 33554432 / 1e9,
        'iterations':   entry['iterations'],
    }
    continue

# Otherwise: regular variant, appended to runs[].
output['runs'].append({
    'variant': variant,
    'n':       n,
    'ns_per_op': {...},
    ...
})
```

Field names should match whatever the existing assembler emits — don't invent new ones here, mirror the surrounding code. The point is the routing, not the precise shape.

If the assembler aggregates across 20 reps before emitting (it should, given the project's median + IQR commitment), apply the same aggregation to the sort entries. A single median wall-seconds is the only number the MDX needs from it.

### 3c. Add the self-test to the run script

In `run_one.sh`, before the benchmark step, add:

```bash
python3 bench/scripts/assemble_results.py --self-test
```

Cheap and catches name-parsing regressions before a full bench run is wasted.

---

## 4. Re-capture

After §1–3, run `./bench/scripts/run_one.sh 01-branch-prediction` again. Acceptance:

- Verifier outputs `OK · cmov confirmed in sum_threshold_branchless` with no SIMD warning.
- JSON assembly completes without traceback.
- `runs[]` contains three variants (sorted, unsorted, branchless) at six N each = 18 rows.
- Top-level `sort_cost_32m` block is present with `wall_seconds` between roughly 0.5 and 2.0 on the 3800X (sanity range; record whatever it is).
- `branch_misses_per_op` for branchless at all N is < 0.01.
- Sorted/unsorted numbers should not have moved meaningfully from the previous v1 capture — same code path, same input, same seed.

---

## 5. MDX rewrite — proceed per original v1.1 brief, with two additions

§5 of the original v1.1 brief (`01-branch-prediction-v1.1-brief.md`) is unchanged. Do all of 5a–5i as specified. Two additions integrate the journey above into the post:

### 5j. Both variants needed compiler attributes — lean into it

The original §5a code block showed `sum_threshold` with `optimize("no-tree-vectorize", "no-if-conversion", "no-if-conversion2")` and the branchless variant _without_ attributes. That was wrong — the branchless variant also needs `optimize("no-tree-vectorize")` to stay scalar. Show both attributes side-by-side in the `<CodeCompare>`:

```mdx
<CodeCompare
  lang="cpp"
  labels={["Branching (sorted or unsorted input)", "Branchless"]}
  naive={`// GCC will turn this into a SIMD masked add or a scalar cmov
// at -O3 -march=native — both eliminate the branch we're studying.
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
  optimized={`// Same ternary that gives cmov on most compilers will also
// auto-vectorise here — we keep it scalar to stay apples-to-apples
// with the branching variants. Demo 3 covers SIMD properly.
__attribute__((noinline, optimize("no-tree-vectorize")))
static int64_t sum_threshold_branchless(const std::vector<int32_t>& data) {
    int64_t sum = 0;
    for (auto x : data) {
        sum += (x >= 128) ? x : 0;    // compiles to cmov
    }
    return sum;
}`}
/>
```

This reinforces the running theme: the compiler is the adversary in measurement. The reader sees that _both_ variants needed deliberate handling to stay scalar — that's the originality angle, not "sorted is faster."

### 5k. Forward-link the SIMD finding

Add a short footnote near the branchless section, ideally just after the cmov asm is shown:

> Without the `no-tree-vectorize` attribute, GCC 13.3 at `-O3 -march=znver2` turns this same ternary into `vpcmpgtd`/`vpand`/`vpaddd` — an 8-wide masked add that beats the cmov version by a further ~8×. That's a different story (SIMD width, not branch behaviour), and gets its own [post](/posts/03-simd-blackscholes).

Forward-links to demo 3, turns the tooling hiccup into a content asset, and pre-empts the "why didn't this auto-vectorise?" objection from anyone who skims the asm.

---

## 6. Acceptance criteria (full v1.1)

Carry over the original v1.1 acceptance criteria, plus the additions below.

Added by this brief:

- [ ] `sum_threshold_branchless` carries `optimize("no-tree-vectorize")`.
- [ ] objdump of `sum_threshold_branchless` shows `cmov*`; no `vp*` SIMD ops; no data-dependent conditional jump.
- [ ] Verifier `exit 1`s on SIMD-in-branchless (no longer a warning).
- [ ] `assemble_results.py --self-test` passes; runs as a pre-step in `run_one.sh`.
- [ ] `assemble_results.py` does not raise on `BM_Sort_32M/min_time:2.000` or any other `Arg`-less benchmark name.
- [ ] Top-level `sort_cost_32m` block exists in the JSON; `BM_Sort_32M` does not appear in `runs[]`.
- [ ] MDX `<CodeCompare>` shows the `optimize` attribute on _both_ variants.
- [ ] MDX contains the SIMD forward-link footnote pointing at demo 3.

---

## 7. Out of scope

- Changing demo 1's story to "branch prediction _and_ SIMD." Demo 3 owns SIMD; this demo isolates branches.
- Retroactive parser audit of earlier demos' JSON. The parser bug surfaced because BM_Sort_32M has no Arg; earlier demos all use Arg and weren't affected. If a future demo wants Arg-less benchmarks, the §3a fix already covers them.
- Refactoring `assemble_results.py` beyond the parsing fix. Tactical change only.
- Hardware re-runs. The 20-rep capture infrastructure already works; this just fixes the assembly step that runs after.
