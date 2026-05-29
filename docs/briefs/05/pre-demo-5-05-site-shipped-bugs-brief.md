# Crucible — site shipped bugs brief

**Pre-demo-5 brief 5 of 9. Two visible bugs on the live site, both small fixes.**

---

## 1. Context

Site code review surfaced two issues that affect what visitors currently see (or fail to see):

- **C-02:** the `Commitment` component on `/methodology` wraps children in `<p>`, but n=4 passes a `<ul>` as a child. HTML auto-closes the `<p>` before the `<ul>`, so the list ends up outside the styled parent — wrong font size, wrong colour, visually inconsistent with the rest of the methodology prose. Live now.
- **C-03:** the topnav logo `<img>` has no `width`/`height` attributes. The browser can't reserve space before the SVG loads, producing a CLS event on every page load. Drives the topnav height (88px), which means every page's content shifts on load. Directly hits the Lighthouse CLS score that the demo-2/3/4 verification task (pre-demo-5 task 9) is about to measure.

Both are independent of any other brief; this brief packages them for a single small PR.

---

## 2. Goals

- The methodology page n=4 list renders with the same font size, line height, and colour as the surrounding Commitment prose.
- Page loads no longer produce a CLS event from the topnav logo. Lighthouse CLS approaches 0 on every route.

---

## 3. C-02 — `Commitment` wrapper change

**File:** `site/src/app/methodology/page.tsx`

In the `Commitment` component (around lines 8–44), change the children wrapper from `<p>` to `<div>`:

```tsx
// BEFORE
<p className="text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
  {children}
</p>

// AFTER
<div className="text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
  {children}
</div>
```

No call-site changes needed. `text-sm`, `leading-relaxed`, and the `color` inline style all inherit through the `<div>` to text nodes and the `<ul>`/`<li>` descendants. Commitments n=1–3 (pure prose children) render identically to before; Commitment n=4's `<ul>` now sits inside its parent's box rather than being auto-promoted out of it.

The element semantics shift from "paragraph" to "generic block container." Acceptable for this use case — none of the Commitment bodies is semantically a single paragraph (n=4 is prose + list), so `<p>` was the wrong wrapper to begin with.

---

## 4. C-03 — logo dimensions

**File:** `site/src/components/TopNav.tsx`, line 99 (the `<img src="/iguana.svg">`)

The reviewer's suggested `width="auto" height="88"` doesn't work — `width="auto"` is not a valid HTML attribute; the keyword is CSS-only. HTML's `width`/`height` attributes must be non-negative integers.

The correct fix sets both attributes to integers matching the SVG's intrinsic aspect ratio. The browser uses the ratio for layout space reservation (`aspect-ratio` is computed from the attribute pair); CSS `height: 88px; width: auto` continues to control the rendered size.

**Steps:**

1. Read `site/public/iguana.svg` (or wherever the asset lives — the import path is `/iguana.svg`).
2. Extract the `viewBox` attribute. Format is `viewBox="minX minY width height"`.
3. Use the `width` and `height` integers from the viewBox directly as the `<img>` element's `width` and `height` attributes:

```tsx
// BEFORE
<img src="/iguana.svg" alt="Gareth Cooke" />

// AFTER (example numbers — substitute the actual viewBox values)
<img src="/iguana.svg" alt="Gareth Cooke" width="120" height="120" />
```

The numbers don't need to be `88` — the browser only uses them to compute the aspect ratio for layout reservation. Existing CSS (`height: 88px; width: auto`) handles the rendered size.

The existing `eslint-disable next/no-img-element` comment on line 98 can stay. The tradeoff it documents (no `next/image` for an SVG that doesn't benefit from WebP conversion) is still valid; the dimension attributes fix the CLS without changing the element type.

---

## 5. Verification

- Open `/methodology` in dev, scroll to the "Statistical reporting" commitment (n=4). The `<Median>`, `<P99>`, etc. list items should render at the same font size and colour as the prose paragraph above them. Spot-check with DOM inspector: the `<ul>` should now be a child of the new `<div>`, not promoted to a sibling.
- Open any route (homepage is simplest) in Chrome DevTools with **Performance → record on page load**. The Performance panel's CLS metric for the load should be 0 or near it. Cross-check with a Lighthouse run: CLS score should be ≥ 0.95.
- Confirm the logo still renders at its existing visual size (88px tall) — the CSS rule is unchanged, so this should be automatic.

---

## 6. Out of scope

- **Light-mode chart breakage (M-01).** Separate brief (6). Not a shipped-now visual bug in the same sense — light mode is opt-in via the toggle; default dark mode is fine. The Commitment and logo issues affect every visitor in the default state.
- **Methodology page inline-code styling inconsistency (N-04).** Different concern from the structural HTML bug. Folds into the minor-cleanup brief (9).
- **Logo conversion to `next/image`.** The existing eslint-disable is intentional; not changing the approach here.

---

## 7. Acceptance checklist

- [ ] `Commitment` component in `methodology/page.tsx` wraps children in `<div>` (not `<p>`).
- [ ] Visual: methodology page n=4 list items render in same font size and colour as the parent commitment prose.
- [ ] DOM inspector: `<ul>` in n=4 is a child of the new `<div>`, not a sibling.
- [ ] `<img src="/iguana.svg">` in `TopNav.tsx` has explicit integer `width` and `height` attributes matching the SVG's viewBox aspect ratio.
- [ ] CSS rule on the logo (`height: 88px; width: auto`) is unchanged.
- [ ] Lighthouse run on `/` and on any post page: CLS score ≥ 0.95 (target 1.0).
- [ ] Visual: logo renders at the same size as before the change.
- [ ] `npm run build` succeeds; static export still clean.
