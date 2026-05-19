#!/usr/bin/env node
/**
 * Mobile screenshot audit for Crucible post pages.
 * Takes full-page screenshots at three mobile viewport widths for all four posts.
 * Run with: node tools/mobile-screenshots.js
 */

const { chromium } = require('/Users/garethcooke/.npm/_npx/e41f203b7505f1fb/node_modules/playwright');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'http://localhost:3099';
const OUT_DIR = path.join(__dirname, '..', 'mobile-screenshots');

const POSTS = [
  { slug: '01-branch-prediction', charts: ['CodeCompare', 'ThroughputBars', 'CounterOverlay', 'TimeVsN'] },
  { slug: '02-false-sharing', charts: ['CodeCompare', 'CounterOverlay x3', 'ThroughputBars x2'] },
  { slug: '03-simd-blackscholes', charts: ['CodeCompare', 'ThroughputBars x2'] },
  { slug: '04-spsc-queue', charts: ['CodeCompare', 'LatencyHistogram x2', 'LatencyVsLoad', 'ThroughputBars'] },
];

const VIEWPORTS = [
  { width: 375, label: '375px' },
  { width: 390, label: '390px' },
  { width: 414, label: '414px' },
];

const DPR = 2;

async function main() {
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const results = [];

  for (const post of POSTS) {
    for (const vp of VIEWPORTS) {
      const context = await browser.newContext({
        viewport: { width: vp.width, height: 812 },
        deviceScaleFactor: DPR,
      });
      const page = await context.newPage();

      const url = `${BASE_URL}/posts/${post.slug}`;
      console.log(`Screenshotting ${post.slug} @ ${vp.label}...`);

      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });

        // Wait for charts to render (SVG elements should be present)
        await page.waitForTimeout(2000);

        const filename = `${post.slug}--${vp.label}.png`;
        const filepath = path.join(OUT_DIR, filename);
        await page.screenshot({ path: filepath, fullPage: true });

        // Collect diagnostic data
        const diagnostics = await page.evaluate(() => {
          const issues = [];

          // Check SVGs for overflow
          document.querySelectorAll('svg').forEach((svg, i) => {
            const vb = svg.getAttribute('viewBox');
            const rect = svg.getBoundingClientRect();
            const parent = svg.parentElement?.getBoundingClientRect();
            if (parent && rect.width > parent.width + 2) {
              issues.push(`SVG[${i}] overflows parent: svg.w=${rect.width.toFixed(0)} parent.w=${parent.width.toFixed(0)}`);
            }
            // Check text inside SVG that might overflow
            svg.querySelectorAll('text').forEach((t, ti) => {
              const tr = t.getBoundingClientRect();
              const svgR = svg.getBoundingClientRect();
              if (tr.right > svgR.right + 10 || tr.left < svgR.left - 10) {
                const content = t.textContent?.trim().slice(0, 30);
                issues.push(`SVG[${i}] text[${ti}] "${content}" outside SVG bounds (x=${tr.left.toFixed(0)}-${tr.right.toFixed(0)}, svg=${svgR.left.toFixed(0)}-${svgR.right.toFixed(0)})`);
              }
            });
          });

          // Check for horizontal overflow on body/article
          const body = document.body;
          const bodyW = body.scrollWidth;
          const vpW = window.innerWidth;
          if (bodyW > vpW + 2) {
            issues.push(`Body horizontal overflow: scrollWidth=${bodyW} > innerWidth=${vpW}`);
          }

          // Check CodeCompare panels visibility
          const comparePanels = document.querySelectorAll('[data-compare-panel], .code-compare, [class*="compare"]');
          if (comparePanels.length === 0) {
            // Try finding by code blocks structure
          }

          // Check tables
          document.querySelectorAll('table').forEach((tbl, i) => {
            const tblR = tbl.getBoundingClientRect();
            const wrapper = tbl.parentElement?.getBoundingClientRect();
            if (wrapper) {
              const clipped = tblR.right > wrapper.right + 20 && !tbl.parentElement?.style?.overflowX?.includes('auto') &&
                getComputedStyle(tbl.parentElement).overflowX === 'visible';
              if (clipped) {
                issues.push(`Table[${i}] appears to clip: table.right=${tblR.right.toFixed(0)} wrapper.right=${wrapper.right.toFixed(0)}, wrapper overflow-x=${getComputedStyle(tbl.parentElement).overflowX}`);
              }
            }
          });

          // Check document overflow
          const docOverflow = document.documentElement.scrollWidth > window.innerWidth + 2;
          if (docOverflow) {
            issues.push(`Document horizontal overflow: scrollWidth=${document.documentElement.scrollWidth} > innerWidth=${window.innerWidth}`);
          }

          // Gather SVG summary
          const svgSummary = Array.from(document.querySelectorAll('svg')).map((svg, i) => {
            const rect = svg.getBoundingClientRect();
            const vb = svg.getAttribute('viewBox');
            const textCount = svg.querySelectorAll('text').length;
            return { i, w: rect.width.toFixed(0), h: rect.height.toFixed(0), viewBox: vb, texts: textCount };
          });

          return { issues, svgSummary, bodyScrollW: bodyW, vpW, docScrollW: document.documentElement.scrollWidth };
        });

        results.push({ post: post.slug, viewport: vp.label, filename, diagnostics });
        console.log(`  -> ${filename}`);
        if (diagnostics.issues.length > 0) {
          console.log(`  ISSUES: ${diagnostics.issues.join('; ')}`);
        } else {
          console.log(`  No overflow issues detected`);
        }
        console.log(`  SVGs found: ${diagnostics.svgSummary.length}`);
        diagnostics.svgSummary.forEach(s => {
          console.log(`    SVG[${s.i}]: ${s.w}x${s.h} viewBox="${s.viewBox}" texts=${s.texts}`);
        });
      } catch (err) {
        console.error(`  ERROR: ${err.message}`);
        results.push({ post: post.slug, viewport: vp.label, filename: null, error: err.message });
      }

      await context.close();
    }
  }

  // Write JSON summary
  const summaryPath = path.join(OUT_DIR, 'diagnostics.json');
  fs.writeFileSync(summaryPath, JSON.stringify(results, null, 2));
  console.log(`\nDiagnostics written to ${summaryPath}`);
  console.log(`Screenshots in ${OUT_DIR}`);

  await browser.close();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
