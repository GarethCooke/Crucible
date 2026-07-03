# Crucible — methodology rdtscp drift-paragraph fix

Micro remediation brief for CC. Follow-up to PR #10 (live-read cleanup, merged 2026-07-03): the post-merge source-verification pass found the new rdtscp section's drift paragraph makes two claims the bench code does not support, plus two one-line nits. Three verbatim edits, one branch (`fix/rdtscp-drift-paragraph`), one small PR. No judgement calls remain — everything below is quote-and-replace.

## Context

PR #10 added the `rdtscp-calibration` section to `site/src/app/methodology/page.tsx`. Paragraphs 1–3 verify against `bench/common/tsc_utils.h` exactly. Paragraph 4 does not: no drift threshold or stderr warn exists anywhere in `bench/` (demo 06 prints the value unconditionally; 04/05 print nothing), and "once all measurement phases complete … brackets all runs" describes only demo 04's paced path (recalibrates post-runs) — demo 05 computes drift at each variant's dispatch, before its runs, and demo 06 back-to-back at startup. The replacement text below states the mechanism as implemented. Separately: paragraph 2's `invariant_tsc` sentence is faithful to the code, but that token never appears in mainline `/proc/cpuinfo` (the CPUID invariant-TSC bit surfaces as `constant_tsc` + `nonstop_tsc`), so the prose documents a check that cannot fire — trim the sentence, leave the code alone. And `risk_check.h` line 2 still carries the pre-M-3 "fit comfortably in L1d" claim in a comment (34,816 B > 32 KB L1d).

## Preconditions — verify before any edit; if any fail, stop and report

1. Repo clean, on `master`, up to date; PR #10 is merged (`grep -c 'id="rdtscp-calibration"' site/src/app/methodology/page.tsx` → 1).
2. `grep -c "verified after the fact" site/src/app/methodology/page.tsx` → exactly 1.
3. `grep -c "invariant_tsc" site/src/app/methodology/page.tsx` → exactly 1.
4. `grep -c "fit comfortably in L1d" bench/demos/05-allocators/risk_check.h` → exactly 1.

## Tasks

### 1. Replace the drift paragraph

File: `site/src/app/methodology/page.tsx` (~line 409). Find (verbatim, entire block):

```
            The calibration is verified after the fact: once all measurement
            phases complete, the harness calibrates a second time and computes
            the relative change in ns-per-cycle between the two calibrations —
            a window that brackets all runs of the capture. Drift above 0.1%
            warns on stderr, and the measured value is recorded in each
            capture&rsquo;s JSON as <code>calibration_drift_pct</code>. That
            field is the source of footer lines like demo 4&rsquo;s
            &ldquo;TSC drift ≤0.0001% across all 5 runs&rdquo;.
```

Replace with:

```
            The calibration is cross-checked rather than gated: a second{" "}
            <code>calibrate_tsc()</code> is taken and the relative change in
            ns-per-cycle between the two readings is committed with the results
            as <code>calibration_drift_pct</code> — no threshold; the value
            itself is the evidence. Where the second reading lands varies by
            pipeline: demo 4 recalibrates after its paced runs complete and
            after each sweep step, demo 5 at each variant&rsquo;s dispatch,
            demo 6 back-to-back at startup. On a <code>constant_tsc</code>{" "}
            machine this is a repeatability check of the calibration itself;
            the committed captures show ≤0.0001% throughout, and that field is
            the source of footer lines like demo 4&rsquo;s
            &ldquo;TSC drift ≤0.0001% across all 5 runs&rdquo;.
```

### 2. Trim the vacuous invariant_tsc sentence

Same file (~line 396). Find (verbatim):

```
            before any benchmark executes. <code>invariant_tsc</code> is also
            checked but is advisory — noted in the output, non-fatal.
```

Replace with:

```
            before any benchmark executes.
```

Do **not** modify `tsc_utils.h` — the code's advisory check stays as-is; only the prose stops advertising it.

### 3. Fix the risk_check.h comment

File: `bench/demos/05-allocators/risk_check.h`, line 2. Find (verbatim):

```
// Simulated risk-check work. Three small tables sized to fit comfortably in L1d.
```

Replace with:

```
// Simulated risk-check work. Three small tables totalling ~34 KB (L1d plus a slice of L2).
```

## Acceptance

- `npm run build` (site) succeeds.
- `grep -c "verified after the fact" site/src/app/methodology/page.tsx` → 0; `grep -c "cross-checked rather than gated" …/page.tsx` → 1; `grep -c "warns on stderr" …/page.tsx` → 0.
- `grep -c "invariant_tsc" site/src/app/methodology/page.tsx` → 0; `grep -c "invariant_tsc" bench/common/tsc_utils.h` → unchanged from pre-edit (code untouched).
- `grep -c "fit comfortably in L1d" bench/demos/05-allocators/risk_check.h` → 0; `grep -c "totalling ~34 KB" …/risk_check.h` → 1.
- `git diff --stat master...HEAD` touches exactly two files: `site/src/app/methodology/page.tsx` and `bench/demos/05-allocators/risk_check.h`.
- No demo capture JSON shows a diff.

## Out of scope

- Any change to `tsc_utils.h` or any other bench code — Task 3 edits a comment only, no compiled-code change anywhere in this brief.
- The rest of the rdtscp section (paragraphs 1–3) and all other methodology content.
- All post MDX, the quantum files, and everything shipped in PR #10 not named above.

## Open items for CC to flag

- Any find block not matching exactly once → stop and report the actual text; master may have moved since this brief was cut (2026-07-03, post-PR-#10 merge).

## Stop condition

Acceptance green, PR open referencing this brief and PR #10. User merges; Amplify deploys. Done.
