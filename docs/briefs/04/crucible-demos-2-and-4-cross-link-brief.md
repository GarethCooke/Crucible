# Crucible — demos 2 and 4 cross-link brief

Read `BRIEF.md` and `crucible-handover.md` for project context. This is task 8 of the pre-demo-5 review (`pre-demo-5-review-tasks.md`).

Scope: pure MDX edits in two files, one new sentence in each direction. No code, no JSON, no chart components, no captures.

## Why this edit

Demos 2 and 4 are both cache-line stories told from different ends. Demo 2 measures false-sharing cost at runtime and prescribes `alignas(64)` as the fix. Demo 4 ships that fix in production form: `head_` and `tail_` are wrapped in a `PaddedAtomic<T>` template whose `static_assert(alignof(PaddedAtomic<T>) == 64)` rejects any layout regression at compile time. Each post stands alone; together they are stronger as a pair when the reader can move between them.

The brief adds one sentence per direction — a back-link from demo 4 to the underlying false-sharing measurement, and a forward-link from demo 2 to the disciplined enforcement of its lesson.

## Route convention

Both edits use the `/posts/<slug>` route format, matching the slug derived from the MDX filename (`/posts/02-false-sharing`, `/posts/04-spsc-queue`). Before applying, verify this is the route the index page uses to link out — open `site/src/app/page.tsx` (or whichever file renders the index) and check the `href` it generates for each post card. If the routes differ (e.g. `/02-false-sharing` at the root, or `/blog/02-false-sharing`), substitute the correct prefix in both links below. The Methodology link in both posts already uses `/methodology` at the root, so the index page is the authoritative reference for the per-post route shape.

## Edit 1 — demo 4 back-link to demo 2

**File:** `site/src/posts/04-spsc-queue.mdx`
**Location:** The `lockfree-handrolled` bullet in the Setup section, currently around line 16–19. The hook is the existing claim that head and tail sit "each on its own 64-byte cache line."

**Before:**

```mdx
- **`lockfree-handrolled`** — ~50-line ring buffer, 1024 entries, power-of-2
  bitmask indexing. `std::atomic` head and tail, each on its own 64-byte cache
  line. `acquire`/`release` ordering only — no `seq_cst` in the hot path. Non-blocking
  `try_push`/`try_pop`; the harness spins on false.
```

**After:**

```mdx
- **`lockfree-handrolled`** — ~50-line ring buffer, 1024 entries, power-of-2
  bitmask indexing. `std::atomic` head and tail, each on its own 64-byte cache
  line — a `PaddedAtomic<T>` wrapper with `static_assert(alignof(PaddedAtomic<T>) == 64)`
  makes [the false-sharing cost measured in demo 2](/posts/02-false-sharing) a
  compile-time invariant rather than a discipline to remember. `acquire`/`release`
  ordering only — no `seq_cst` in the hot path. Non-blocking `try_push`/`try_pop`;
  the harness spins on false.
```

The change extends the existing cache-line sentence with an em-dash continuation rather than inserting a new sentence break. Reads as one beat: "each on its own 64-byte cache line — [here's the mechanism that enforces it], [here's where you can see why it matters]." Doesn't fragment the bullet.

## Edit 2 — demo 2 forward-link to demo 4

**File:** `site/src/posts/02-false-sharing.mdx`
**Location:** The closing sentence of the `alignas(64)` paragraph in the "What this means in practice" section, currently around lines 158–161. The hook is the existing claim that the layout discipline is "almost always worthwhile."

**Before:**

```mdx
The fix is straightforward: align each per-thread slot to the cache-line size.
`alignas(64)` is sufficient on x86-64 (and most ARM64 deployments). The trade-off is
memory: 8 threads × 64 bytes = 512 bytes instead of 64 bytes. For hot-path accumulators
the trade-off is almost always worthwhile.
```

**After:**

```mdx
The fix is straightforward: align each per-thread slot to the cache-line size.
`alignas(64)` is sufficient on x86-64 (and most ARM64 deployments). The trade-off is
memory: 8 threads × 64 bytes = 512 bytes instead of 64 bytes. For hot-path accumulators
the trade-off is almost always worthwhile. [The lock-free SPSC queue in demo 4](/posts/04-spsc-queue)
ships this pattern productionised — a `PaddedAtomic<T>` template with a `static_assert`
that catches any layout regression at compile time, rather than relying on a test to
notice the throughput collapse.
```

The new sentence sits at the end of the existing paragraph (no paragraph break), so the flow is: "here's the fix, here's the cost, here's why it's worth it, here's what disciplined production code does with it." The clause "rather than relying on a test to notice the throughput collapse" links the forward-reference back to the measurement the reader has just seen in this post.

## Acceptance criteria

- [ ] Both routes verified against the index page before commit (see "Route convention" above).
- [ ] Demo 4 edit applied: `grep -n 'PaddedAtomic' site/src/posts/04-spsc-queue.mdx` returns at least one hit on the line in the `lockfree-handrolled` bullet.
- [ ] Demo 2 edit applied: `grep -n 'PaddedAtomic\|spsc-queue' site/src/posts/02-false-sharing.mdx` returns at least one hit in the "What this means in practice" section.
- [ ] No other text in either MDX file is touched. `git diff site/src/posts/02-false-sharing.mdx site/src/posts/04-spsc-queue.mdx` shows only the two additions above.
- [ ] `npm run build` (or whichever site build command the repo uses) completes without MDX parse errors. Both new links resolve in dev (`npm run dev`, click each from the rendered post page, lands on the linked post — no 404).

## Out of scope

- Any other cross-linking between posts (demo 1 ↔ demo 3, etc.). Task 8 specifically scopes to the 2↔4 pair.
- Adding a "Related posts" component or sidebar pattern. The two inline links are sufficient for v1; a generalised related-posts mechanism is a demo-5+ concern if it becomes worth it.
- Editing the index page summaries to hint at the connection. The cross-links live inside the posts; the index stays one-line-per-post.
- Any prose adjustments to demo 2 or demo 4 beyond the two sentences specified. Both posts have passed skeptical review in their current shape; this brief is additive only.

## Notes for CC

Two diffs, both small. The only judgement call is the route prefix (Route convention section). If the index page reveals the routes are something other than `/posts/<slug>`, fix both links to match — they share the same prefix so it's one substitution applied twice.

After this lands, task 8 of `pre-demo-5-review-tasks.md` closes. Remaining: tasks 9 (Lighthouse), 10 (mobile), 11 (hostile cross-read — this one is mine to run after 8-10 ship), and 12 (Amplify deploy verification — your manual step).
