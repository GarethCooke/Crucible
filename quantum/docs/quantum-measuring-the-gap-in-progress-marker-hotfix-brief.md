# Crucible — special edition "Measuring the Gap" — in-progress marker hotfix

Hotfix brief, Opus → CC. **The post is live on master and deployed** with device numbers still showing `[hardware capture pending]` and empty hardware panels. This lands a clear in-progress marker so the deployed version doesn't read as a finished post with empty charts — a real credibility cost on a rigor-first site. Land this fast (direct hotfix or a tiny branch you fast-merge), ahead of the pending verification work.

## Context

- Affected route: `/special/measuring-the-gap` (`site/src/app/special/measuring-the-gap/page.tsx`) — incomplete numbers, live.
- **Not affected: the companion explainer** (`/special/measuring-the-gap/grover-explained`). It has no data dependency and is complete — leave it normal: no banner, no noindex.
- The markers added here are temporary and **must be removed when the hardware capture completes** (wired into the verification brief's post-capture step — Task 4 below).

## Tasks

### Task 1 — In-progress banner on the post
Add a prominent, unmissable banner at the top of `/special/measuring-the-gap`, above the hook. Plain and honest, e.g.: "In progress — this post is awaiting its hardware capture. The device measurements shown are placeholders; the simulator, theory, and explainer are final." It must be visually distinct (not a subtle footnote) so no reader mistakes the placeholders for results.

### Task 2 — Prevent indexing of the incomplete post
Set `noindex` (robots meta) on the post route only, via the Next.js metadata mechanism (e.g. `export const metadata = { robots: { index: false, follow: true } }` in `page.tsx`, or the route's `generateMetadata`). This stops search engines indexing the placeholder version; if it was already crawled, it drops on recrawl. **Do not** noindex the companion or anything else.

### Task 3 — Mark the listing
On the homepage "Special editions" section and any index card for this post, add an "in progress" tag alongside the ★ special marker, so the incompleteness is visible before a reader clicks through.

### Task 4 — Register the removal (so the markers come off at completion)
Add the removal of Tasks 1–3 (banner, noindex, listing tag) to the deferred post-capture re-verification in `quantum-measuring-the-gap-pre-merge-verification-brief.md` (Task 5). When the capture fills the JSON nulls and the `[hardware capture pending]` strings are gone, these markers must be removed in the same pass. State this as an explicit checklist item there so it isn't forgotten and the post doesn't ship "complete" still wearing a draft banner.

## Acceptance

- The banner renders at the top of `/special/measuring-the-gap` and is visually prominent; `grep -n` finds the banner text in `page.tsx`.
- The post route emits `noindex` (grep the robots metadata); the companion route does **not** (confirm it has no noindex).
- The homepage/index entry for this post shows the in-progress tag.
- The verification brief's post-capture section now contains an explicit "remove banner, noindex, and in-progress tag" item, gated on zero `[hardware capture pending]` strings remaining.

## Out of scope

- Any change to the post's content, numbers, charts, or the companion explainer.
- The hardware capture, C++ baseline, and the rest of the verification brief's tasks (separate; this is only the marker).
- Reverting/unpublishing the post — the decision is to keep it live and flagged.

## Open items for CC to flag

- If the site has a global robots/sitemap config rather than per-route metadata, apply the noindex at the route level there and confirm it doesn't catch the companion or the numbered demos.
- If the homepage "Special editions" listing has no slot for a per-post status tag, flag where it should go rather than restructuring the section.
