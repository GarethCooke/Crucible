#!/usr/bin/env node
/**
 * Deep inspection of overflow sources and specific component visibility.
 */

const { chromium } = require('/Users/garethcooke/.npm/_npx/e41f203b7505f1fb/node_modules/playwright');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'http://localhost:3099';
const OUT_DIR = path.join(__dirname, '..', 'mobile-screenshots');

async function inspectPage(page, slug, vpWidth) {
  const url = `${BASE_URL}/posts/${slug}`;
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(2000);

  return page.evaluate((vpW) => {
    const report = {};

    // Find overflow culprits
    const overflowCulprits = [];
    document.querySelectorAll('*').forEach(el => {
      const rect = el.getBoundingClientRect();
      if (rect.right > vpW + 5 && el.tagName !== 'HTML' && el.tagName !== 'BODY') {
        const cls = el.className ? (typeof el.className === 'string' ? el.className.slice(0, 60) : '') : '';
        const tag = el.tagName.toLowerCase();
        const id = el.id ? `#${el.id}` : '';
        overflowCulprits.push({
          el: `${tag}${id} .${cls.replace(/\s+/g, '.')}`,
          right: rect.right.toFixed(0),
          width: rect.width.toFixed(0),
          left: rect.left.toFixed(0),
        });
      }
    });
    report.overflowCulprits = overflowCulprits.slice(0, 20);

    // CodeCompare: look for two-column code panels
    // They render as pre/code elements or divs with code
    const preTags = Array.from(document.querySelectorAll('pre'));
    report.preElements = preTags.map((pre, i) => {
      const rect = pre.getBoundingClientRect();
      const parent = pre.parentElement?.getBoundingClientRect();
      const overflowX = getComputedStyle(pre).overflowX;
      const parentOverflowX = pre.parentElement ? getComputedStyle(pre.parentElement).overflowX : 'n/a';
      return {
        i,
        w: rect.width.toFixed(0),
        right: rect.right.toFixed(0),
        overflowX,
        parentOverflowX,
        clipped: rect.right > vpW + 2 && overflowX === 'visible',
      };
    });

    // Tables
    const tables = Array.from(document.querySelectorAll('table'));
    report.tables = tables.map((tbl, i) => {
      const rect = tbl.getBoundingClientRect();
      const wrapper = tbl.parentElement;
      const wrapperRect = wrapper?.getBoundingClientRect();
      const wrapperOvX = wrapper ? getComputedStyle(wrapper).overflowX : 'n/a';
      return {
        i,
        tableW: rect.width.toFixed(0),
        tableRight: rect.right.toFixed(0),
        wrapperW: wrapperRect ? wrapperRect.width.toFixed(0) : 'n/a',
        wrapperOvX,
        scrollsH: wrapperOvX === 'auto' || wrapperOvX === 'scroll',
        visiblyClipped: rect.right > vpW + 2 && wrapperOvX === 'visible',
      };
    });

    // SVG legend labels specifically (x-axis legend)
    const svgLegendIssues = [];
    document.querySelectorAll('svg').forEach((svg, si) => {
      const svgRect = svg.getBoundingClientRect();
      // Find text that might be legend items (often at bottom of SVG)
      const texts = Array.from(svg.querySelectorAll('text'));
      const clippedTexts = texts.filter(t => {
        const tr = t.getBoundingClientRect();
        return tr.right > svgRect.right + 2 || tr.left < svgRect.left - 2 || tr.right > vpW + 2;
      });
      if (clippedTexts.length > 0) {
        svgLegendIssues.push({
          svgIndex: si,
          svgW: svgRect.width.toFixed(0),
          clippedTexts: clippedTexts.map(t => ({
            content: t.textContent?.trim().slice(0, 40),
            right: t.getBoundingClientRect().right.toFixed(0),
            left: t.getBoundingClientRect().left.toFixed(0),
          })).slice(0, 10),
        });
      }
    });
    report.svgLegendIssues = svgLegendIssues;

    // Article prose check
    const article = document.querySelector('article') || document.querySelector('main');
    if (article) {
      const ar = article.getBoundingClientRect();
      report.articleWidth = ar.width.toFixed(0);
      report.articleRight = ar.right.toFixed(0);
      report.articleOverflowX = getComputedStyle(article).overflowX;
    }

    // Body scroll info
    report.bodyScrollW = document.body.scrollWidth;
    report.docScrollW = document.documentElement.scrollWidth;
    report.innerW = vpW;

    return report;
  }, vpWidth);
}

async function main() {
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const results = {};

  const posts = [
    '01-branch-prediction',
    '02-false-sharing',
    '03-simd-blackscholes',
    '04-spsc-queue',
  ];

  // Deep inspect at 375px (worst case) for all posts
  for (const slug of posts) {
    const context = await browser.newContext({
      viewport: { width: 375, height: 812 },
      deviceScaleFactor: 2,
    });
    const page = await context.newPage();
    console.log(`\n=== ${slug} @ 375px ===`);
    try {
      const data = await inspectPage(page, slug, 375);
      results[slug] = data;

      if (data.overflowCulprits.length > 0) {
        console.log('Overflow culprits:');
        data.overflowCulprits.slice(0, 8).forEach(c => {
          console.log(`  ${c.el}: right=${c.right} w=${c.width}`);
        });
      } else {
        console.log('No overflow culprits');
      }

      if (data.tables.length > 0) {
        console.log('Tables:');
        data.tables.forEach(t => {
          console.log(`  Table[${t.i}]: w=${t.tableW} right=${t.tableRight} wrapperOvX=${t.wrapperOvX} scrollsH=${t.scrollsH} clipped=${t.visiblyClipped}`);
        });
      }

      if (data.svgLegendIssues.length > 0) {
        console.log('SVG legend/text issues:');
        data.svgLegendIssues.forEach(s => {
          console.log(`  SVG[${s.svgIndex}] (w=${s.svgW}):`);
          s.clippedTexts.forEach(t => console.log(`    "${t.content}" right=${t.right} left=${t.left}`));
        });
      }

      console.log(`Pre elements: ${data.preElements.length}`);
      data.preElements.forEach(p => {
        console.log(`  pre[${p.i}]: w=${p.w} right=${p.right} ovX=${p.overflowX} parentOvX=${p.parentOverflowX} clipped=${p.clipped}`);
      });

    } catch (err) {
      console.error(`  ERROR: ${err.message}`);
    }
    await context.close();
  }

  // Also do 04-spsc-queue at 390 and 414 for the SVG label issue
  for (const vpW of [390, 414]) {
    const context = await browser.newContext({
      viewport: { width: vpW, height: 812 },
      deviceScaleFactor: 2,
    });
    const page = await context.newPage();
    console.log(`\n=== 04-spsc-queue @ ${vpW}px ===`);
    try {
      const data = await inspectPage(page, '04-spsc-queue', vpW);
      if (data.svgLegendIssues.length > 0) {
        console.log('SVG legend/text issues:');
        data.svgLegendIssues.forEach(s => {
          console.log(`  SVG[${s.svgIndex}] (w=${s.svgW}):`);
          s.clippedTexts.forEach(t => console.log(`    "${t.content}" right=${t.right} left=${t.left}`));
        });
      }
    } catch (err) {
      console.error(`  ERROR: ${err.message}`);
    }
    await context.close();
  }

  const summaryPath = path.join(OUT_DIR, 'deep-inspect.json');
  fs.writeFileSync(summaryPath, JSON.stringify(results, null, 2));
  console.log(`\nDeep inspect written to ${summaryPath}`);
  await browser.close();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
