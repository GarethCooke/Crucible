#!/usr/bin/env bash
# Demo 04 Phase 0 verification — checks CC's per-iteration instrumentation
# against the brief's acceptance criteria. Correctness only; no rig/shield needed.
# Run from the repo root (the dir containing bench/).  Usage: ./verify_phase0.sh
set -uo pipefail

PASS=0; FAIL=0
ok(){ echo "  PASS: $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL: $1"; FAIL=$((FAIL+1)); }

# --- locate binary --------------------------------------------------------
BIN="$(find . -type f -executable -name 'bench_04*' 2>/dev/null | head -n1)"
[[ -z "$BIN" ]] && BIN="$(find . -type f -executable -iname '*04*spsc*' 2>/dev/null | head -n1)"
SRC="bench/demos/04-spsc-queue/benchmark.cpp"

echo "=== 1. BUILD ==="
if [[ -d bench ]]; then
  if (cd bench && cmake --build build) >/tmp/p0_build.log 2>&1; then
    ok "build clean (all demos)"
  else
    no "build FAILED — see /tmp/p0_build.log"; tail -20 /tmp/p0_build.log
    echo "Aborting; fix build first."; exit 1
  fi
else
  no "no bench/ dir here — run from repo root"; exit 1
fi
# re-locate binary after build
BIN="$(find . -type f -executable -name 'bench_04*' 2>/dev/null | head -n1)"
[[ -z "$BIN" ]] && BIN="$(find . -type f -executable -iname '*04*spsc*' 2>/dev/null | head -n1)"
if [[ -z "$BIN" || ! -x "$BIN" ]]; then no "bench_04 binary not found after build"; exit 1; fi
echo "  binary: $BIN"

echo "=== 2. HOT LOOP UNTOUCHED ==="
if [[ -f "$SRC" ]]; then
  HITS="$(git diff HEAD~1 -- "$SRC" 2>/dev/null | grep -E '^[+-]' | grep -v '^[+-][+-]' \
          | grep -iE 'try_push|try_pop|tail_\.|head_\.|rdtscp|enq_ts\[|deq_ts\[|->load|->store' || true)"
  if [[ -z "$HITS" ]]; then
    ok "no added/removed lines touch push/pop/timestamp/atomics"
  else
    no "diff touches hot-loop lines — REVIEW:"; echo "$HITS" | sed 's/^/      /'
  fi
else
  no "source not at $SRC — check path manually"
fi

echo "=== 3. ITER + DIAG LINES ==="
"$BIN" lockfree-handrolled --mode paced --rate-hz 1000000 >/dev/null 2>/tmp/p0_iter.txt || true
NITER="$(grep -c 'ITER' /tmp/p0_iter.txt || true)"
NDIAG="$(grep -c 'DIAG' /tmp/p0_iter.txt || true)"
[[ "$NITER" == "5" ]] && ok "exactly 5 ITER lines" || no "expected 5 ITER lines, got $NITER"
[[ "$NDIAG" -ge 1 ]] && ok "DIAG line(s) present ($NDIAG)" || no "no DIAG line — spike instrumentation missing"
# non-negative sanity
NEG="$(grep 'ITER' /tmp/p0_iter.txt | grep -oE '=-[0-9]' || true)"
[[ -z "$NEG" ]] && ok "no negative values in ITER lines" || no "negative value(s) in ITER lines"
echo "  --- ITER/DIAG sample ---"; grep -E 'ITER|DIAG' /tmp/p0_iter.txt | sed 's/^/    /'

echo "=== 4. depth_mean ARITHMETIC (Little's law) ==="
DCHECK="$(awk '/ITER/{a=m=d=""; for(i=1;i<=NF;i++){
            if($i~/^achieved=/)a=$i; if($i~/^mean=/)m=$i; if($i~/depth_mean=/)d=$i}
          gsub(/[^0-9.]/,"",a); gsub(/[^0-9.]/,"",m); gsub(/[^0-9.]/,"",d);
          if(a!=""&&m!=""&&d!=""){rc=a*m/1000; err=(d>rc?d-rc:rc-d);
            tol=(rc*0.05<0.5?0.5:rc*0.05);
            printf "    reported=%-8s recomputed=%-8.2f %s\n", d, rc, (err<=tol?"ok":"MISMATCH")}}' /tmp/p0_iter.txt)"
echo "$DCHECK"
if echo "$DCHECK" | grep -q MISMATCH; then no "depth_mean != achieved*mean/1000 on some line"
elif [[ -z "$DCHECK" ]]; then no "could not parse achieved/mean/depth_mean from ITER lines"
else ok "depth_mean matches achieved*mean/1000"; fi

echo "=== 5. JSON SCHEMA UNCHANGED + --iterations DRIVES LOOP ==="
EXPECT="calibration_drift_pct,items_measured,items_warmup,iterations,latency_ns,mode,n,ns_per_op,offered_rate_hz,ops_per_sec,top_bucket_count,variant"
RES="$("$BIN" lockfree-handrolled --mode paced --rate-hz 1000000 --iterations 3 2>/dev/null \
      | python3 -c "import json,sys
d=json.load(sys.stdin); o=d[0] if isinstance(d,list) else d
print(','.join(sorted(o.keys())))
print(o.get('iterations'))" 2>/tmp/p0_json.err)" || true
GOT_FIELDS="$(echo "$RES" | sed -n 1p)"
GOT_ITERS="$(echo "$RES" | sed -n 2p)"
if [[ -z "$GOT_FIELDS" ]]; then no "JSON did not parse — see /tmp/p0_json.err"; cat /tmp/p0_json.err
else
  [[ "$GOT_FIELDS" == "$EXPECT" ]] && ok "field set unchanged (no schema additions)" \
    || { no "field set changed"; echo "      expected: $EXPECT"; echo "      got:      $GOT_FIELDS"; }
  [[ "$GOT_ITERS" == "3" ]] && ok "--iterations 3 drives the loop (iterations=3)" \
    || no "--iterations not honoured (iterations=$GOT_ITERS, expected 3)"
fi

echo
echo "=============================================="
echo "  Phase 0 verification: $PASS passed, $FAIL failed"
if [[ "$FAIL" -eq 0 ]]; then
  echo "  -> Phase 0 GENUINELY DONE. Clear to run Phase 1."
  echo "     (Still get CC's one-sentence answer: do the N runs re-alloc/re-warm"
  echo "      the queue per iteration, or share process state?)"
else
  echo "  -> NOT done. Fix the FAIL items before Phase 1."
fi
echo "=============================================="
exit $FAIL
