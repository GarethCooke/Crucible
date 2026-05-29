# Crucible — heading-permalink affordance follow-on brief

**Follow-on to `pre-demo-6-hostile-cross-read-cleanup-brief.md`. That brief installs `rehype-slug` so demo 6's `§SIMD` in-page anchors resolve. This brief adds the sibling plugin `rehype-autolink-headings` so every heading on the site renders a visible permalink affordance — a `#` symbol that fades in on hover and gives readers a copyable section URL.**

---

## 1. Context

The cleanup brief makes in-page anchors _work_. This brief makes them _discoverable_. With `rehype-slug` alone, anchor links land correctly when someone has the URL — but there's no visible affordance telling a reader they _can_ link directly to a section. Most well-built technical-doc sites (Anthropic docs, MDN, Stripe API ref) pair the two: slug for the `id`, autolink-headings for the hover-revealed `#` icon next to each heading. This brief adds the second half.

**Precondition.** The cleanup brief has been applied. `rehype-slug` is installed and registered in the MDX `rehypePlugins` array. All `h1`–`h4` elements on the rendered site have non-null `id` attributes generated from their text. If that hasn't happened yet, this brief can't proceed — autolink-headings depends on slug having run first.

**Scope.** Small targeted change. One package, one MDX config edit, one CSS rule. No prose changes. No per-post edits. Same MDX config file the cleanup brief touched.

---

## 2. Files touched

- `package.json` — add `rehype-autolink-headings` dependency.
- MDX pipeline config (whichever file the cleanup brief registered `rehype-slug` in — most likely `next.config.{ts,js,mjs}` or `mdx.config.ts`) — register `rehype-autolink-headings` immediately after `rehype-slug` in the same `rehypePlugins` array.
- Global stylesheet (most likely `site/src/app/globals.css`; CC to surface the actual path in the PR description) — add a `.heading-anchor` rule.

---

## 3. Changes

### 3.1 Install the package

```bash
npm install rehype-autolink-headings
```

In `dependencies`, not `devDependencies` (runs at build time).

### 3.2 Register the plugin

Open the MDX config file that the cleanup brief modified to register `rehypeSlug`. Add the autolink-headings plugin immediately after, in the same array.

```js
import rehypeSlug from "rehype-slug";
import rehypeAutolinkHeadings from "rehype-autolink-headings";

const withMDX = createMDX({
  options: {
    remarkPlugins: [...],
    rehypePlugins: [
      rehypeSlug,
      [
        rehypeAutolinkHeadings,
        {
          behavior: "append",
          properties: {
            className: "heading-anchor",
            ariaHidden: true,
            tabIndex: -1,
          },
          content: { type: "text", value: "#" },
        },
      ],
      ...
    ],
  },
});
```

Notes on the options:

- **`behavior: "append"`** — anchor appears _after_ the heading text. Less visually loud than `"prepend"`; doesn't make the whole heading clickable like `"wrap"` (which breaks text selection).
- **`content: { type: "text", value: "#" }`** — renders a `#` character as the visible affordance. No SVG / Lucide dependency.
- **`ariaHidden: true`** — screen-readers skip the anchor, so they don't read every heading twice ("SIMD escapes compute not memory, link to SIMD escapes compute not memory"). The heading already has a permanent URL via its `id`; the visible `#` is purely a pointer-device affordance.
- **`tabIndex: -1`** — keeps the anchor out of the keyboard tab order. Without this, every heading on every page becomes a tab stop, which makes keyboard navigation noisier.

Plugin order matters: `rehypeSlug` must come first so it has populated the heading `id`s by the time `rehypeAutolinkHeadings` runs. If the cleanup brief registered slug in a different position (e.g. at the end of the array), move slug to the front of the array and place autolink directly after it.

### 3.3 Add the CSS

Add to the global stylesheet. Most likely `site/src/app/globals.css` — surface the actual path in the PR description if it lives elsewhere (e.g. a Tailwind v4 `@theme` setup with a separate base CSS file).

```css
.heading-anchor {
  margin-left: 0.4em;
  opacity: 0;
  text-decoration: none;
  color: var(--text-muted);
  font-weight: 400;
  transition: opacity 150ms ease-out;
}

h2:hover > .heading-anchor,
h3:hover > .heading-anchor,
h4:hover > .heading-anchor,
.heading-anchor:focus-visible {
  opacity: 1;
}

.heading-anchor:hover {
  color: var(--cyan);
}
```

Visual target: `#` sits roughly half a character to the right of the heading text in muted tone, invisible at rest, fades in on heading hover, brightens to the cyan accent on its own hover. Uses the existing `--text-muted` and `--cyan` design tokens from the methodology page; consistent palette across the site.

Selectors target `h2`, `h3`, `h4` only — `h1` (the post title) doesn't need a permalink since there's nothing on the page that isn't already covered by the page URL itself. (If `h1` _does_ receive the autolink, the `opacity: 0` keeps it invisible regardless.)

`focus-visible` keeps the affordance reachable for keyboard users who explicitly tab to the heading anchor link (e.g. via assistive-tech-style "all links" navigation), even though it's `tabIndex: -1` in normal flow.

---

## 4. Acceptance criteria

- `package.json` has `rehype-autolink-headings` in `dependencies`.
- The MDX `rehypePlugins` array registers `rehypeSlug` followed immediately by `rehypeAutolinkHeadings` with the options shown in §3.2.
- `npm run build` succeeds with zero new warnings.
- On the live deploy:
  - Hovering over any h2 or h3 on the methodology page, any post, or the index page reveals a `#` character to the right of the heading text.
  - The anchor is in muted tone (`var(--text-muted)`); hovering the anchor itself turns it cyan (`var(--cyan)`).
  - Clicking the anchor updates the URL to `<page-url>#<heading-slug>` and the page scrolls to the heading.
  - Right-click → "copy link address" on the anchor yields a working permalink URL.
  - The anchor is invisible by default (opacity 0) — no visual noise in screenshots, no `#` characters scattered through the page text at rest.
  - Inspecting the anchor element confirms `aria-hidden="true"` and `tabindex="-1"`.
- No regression on demo 6's three existing `§SIMD` in-text links — they still resolve as before.
- No regression on any post's prose — the only DOM change is the added anchor elements inside `h2`/`h3`/`h4` tags.

---

## 5. Out of scope

- Any change to MDX content. No post is edited.
- Any change to the slug-generation behaviour itself — `rehype-slug` is assumed already in place per the cleanup brief.
- Icon styling beyond the cyan-on-hover treatment. If the user later wants a Lucide `link` icon instead of the `#` character, that's a one-line `content` change and a CSS swap; defer for now.
- Auto-scrolling to a heading when arriving with a `#hash` in the URL — that's browser-default behaviour; no action needed.
- "Copied!" toast on click — interactive affordance, separate decision.
- TOC component derived from headings — different scope; would be a separate post-side component.

---

## 6. Notes for CC

- The MDX config file is whichever one the cleanup brief touched to register `rehype-slug`. If the cleanup-brief PR is already merged, this is `next.config.{ts,js,mjs}` or equivalent — same file, same array.
- The CSS file path is the same flag from the cleanup brief — most likely `globals.css`, but surface the actual location.
- Verify on at least three different headings (methodology page h2, a post body h2, an index-page h2 if any) that the hover behaviour is consistent. Differences would point to a CSS-specificity issue worth flagging.
- If the project uses a CSS-in-JS approach (styled-components, emotion) rather than a global stylesheet, adapt the §3.3 rule accordingly and flag in the PR description.
- Verify `lighthouse` Accessibility ≥ 90 on the methodology page and on demo 6 after this change lands. The `ariaHidden` + `tabIndex: -1` configuration should keep a11y unchanged; if Lighthouse flags anything new, the configuration in §3.2 needs revisiting before merge.

---

## 7. Stop condition

Brief is complete when all §4 acceptance criteria pass on the feature-branch deploy (or `main` if the cleanup brief has already merged). No follow-up brief expected from this change; either the affordance ships as scoped or doesn't.
