# Crucible — special edition "Measuring the Gap" — companion explainer re-sync

Small content brief, Opus → CC, branch `feature/quantum-measuring-the-gap`. The companion explainer source `Crucible/quantum/docs/grover-explainer.md` has been updated (a new orientation section added, a now-redundant section removed). The published page was created verbatim from that source and is therefore out of sync. Re-sync it. Independent of the hardware capture and of the in-progress hotfix — can land on its own.

## Context

- Source of truth: `Crucible/quantum/docs/grover-explainer.md` (updated).
- Published page: `site/src/posts/special/grover-explained.mdx`, live at `/special/measuring-the-gap/grover-explained`.
- What changed in the source: a new section **"What Grover's algorithm is, and what it's for"** was added between the intro and "The one mental model …"; the standalone **"The problem being solved"** section was removed (its content absorbed into the new section). No other sections changed.
- The companion is complete and stays indexed/unbannered — the in-progress hotfix does **not** apply to it.

## Task

Re-sync `site/src/posts/special/grover-explained.mdx` so its body matches the updated `grover-explainer.md` verbatim (converted to the page's MDX format as before). Use the source as canonical — do not rewrite, reword, or re-order; mirror the current source exactly, including the new orientation section and the absence of the old standalone "problem being solved" section.

## Acceptance

- The page body matches the updated source: the heading "What Grover's algorithm is, and what it's for" is present (`grep -n` finds it in the `.mdx`).
- The standalone "The problem being solved" heading is **gone** (`grep -n "The problem being solved"` returns nothing — its content now lives inside the new section).
- No content drift beyond these two changes: a diff of the page body against the source shows only the added orientation section and the removed section, nothing reworded elsewhere.
- The page still renders at `/special/measuring-the-gap/grover-explained` with its special-edition marker, no banner, no noindex.

## Out of scope

- Any change to the main post, its in-progress markers, the charts, the JSON, or the harness.
- Editing `grover-explainer.md` itself (it is the source; mirror it, don't change it).

## Open items for CC to flag

- If the page wasn't in fact a verbatim copy of the source (i.e. CC adapted wording when first creating it), flag the divergence rather than silently reconciling — the intent is the page tracks the source exactly.
