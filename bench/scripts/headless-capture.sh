#!/usr/bin/env bash
# bench/scripts/headless-capture.sh
#
# Run a Crucible capture headless from a GUI session, then restore the desktop.
#
# Pre-flights BEFORE tearing down the GUI, so a bad machine state is readable
# on screen instead of failing into a black console. The capture itself runs
# inside a transient systemd unit, which survives the session teardown that
# `systemctl isolate multi-user.target` causes.
#
# Usage (from repo root, as your normal user — it sudos internally):
#   ./bench/scripts/headless-capture.sh ./bench/scripts/run_one.sh 03-simd-blackscholes
#   ./bench/scripts/headless-capture.sh ./bench/pilot/10-core-to-core/run_pilot.sh --a4
#
# The desktop drops ~5s after launch, the capture runs, the desktop returns.
# Log back in and read the log path printed before the drop.

set -euo pipefail

# ─── Inner mode: runs as root inside the transient unit ──────────────────────
if [[ "${1:-}" == "--inner" ]]; then
    shift
    LOG="${CRUCIBLE_LOG:?}"
    OWNER="${CRUCIBLE_OWNER:?}"
    WORKDIR="${CRUCIBLE_WORKDIR:?}"
    START="${CRUCIBLE_START:?}"

    # Restore the desktop no matter how this exits.
    trap 'systemctl isolate graphical.target' EXIT

    rc=0
    {
        echo "=== crucible headless capture $(date -Is) ==="
        echo "=== cmd: $* ==="
        echo "--- dropping to multi-user.target ---"
        systemctl isolate multi-user.target
        sleep 10   # let the session tear down and the machine settle

        echo "--- machine state at capture time ---"
        echo "isolated:   $(cat /sys/devices/system/cpu/isolated)"
        echo "nohz_full:  $(cat /sys/devices/system/cpu/nohz_full)"
        echo "smt/active: $(cat /sys/devices/system/cpu/smt/active 2>/dev/null || echo n/a)"
        echo "boost:      $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo n/a)"
        echo "graphical:  $(systemctl is-active graphical.target)"
        echo "-------------------------------------"

        cd "$WORKDIR"
        "$@"
    } >>"$LOG" 2>&1 || rc=$?

    echo "=== exit $rc ===" >>"$LOG"

    # Hand back anything root created during the run (JSON captures, logs),
    # so git doesn't see a pile of root-owned files.
    find "$WORKDIR" -path "$WORKDIR/.git" -prune -o \
         -newermt "@$START" -user root -print0 2>/dev/null \
        | xargs -0 -r chown "$OWNER:$OWNER" 2>/dev/null || true
    chown -R "$OWNER:$OWNER" "$(dirname "$LOG")" 2>/dev/null || true

    exit $rc
fi

# ─── Outer mode: runs as the user, GUI still up ──────────────────────────────
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <capture command> [args...]" >&2
    exit 1
fi

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
REPO_ROOT="$(cd "$(dirname "$SELF")/../.." && pwd)"
RUN_USER="${SUDO_USER:-$USER}"
LOG_DIR="${REPO_ROOT}/capture_logs"
mkdir -p "$LOG_DIR"
LOG="${LOG_DIR}/capture-$(date +%Y%m%dT%H%M%S).log"
START_EPOCH="$(date +%s)"

echo "==> Pre-flight (GUI still up — errors are readable here)"

fail() { echo "ERROR: $*" >&2; exit 1; }

ISOLATED="$(cat /sys/devices/system/cpu/isolated 2>/dev/null || echo '')"
[[ "$ISOLATED" == "${EXPECTED_ISOLATED:-1-7}" ]] \
    || fail "isolated='$ISOLATED', expected '${EXPECTED_ISOLATED:-1-7}'. Boot the benchmark GRUB entry."

NOHZ="$(cat /sys/devices/system/cpu/nohz_full 2>/dev/null || echo '')"
[[ "$NOHZ" == "${EXPECTED_ISOLATED:-1-7}" ]] \
    || fail "nohz_full='$NOHZ', expected '${EXPECTED_ISOLATED:-1-7}'."

SMT="$(cat /sys/devices/system/cpu/smt/active 2>/dev/null || echo '')"
[[ "$SMT" == "0" ]] || fail "SMT active ('$SMT'). Disable in BIOS."

BOOST="$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo '')"
[[ "$BOOST" == "0" ]] || fail "cpufreq/boost='$BOOST', expected 0 (CPB disabled in BIOS)."

CMD="$1"
[[ -x "$CMD" ]] || command -v "$CMD" >/dev/null 2>&1 \
    || fail "'$CMD' is not executable / not on PATH."

echo "    isolated=$ISOLATED  nohz_full=$NOHZ  smt=off  boost=off   OK"
echo "==> Log: $LOG"
echo "==> Desktop drops in 5s; it will come back automatically when the capture ends."
sleep 5

sudo systemd-run \
    --unit="crucible-capture-$(date +%s)" \
    --collect \
    --service-type=oneshot \
    --property=TimeoutStartSec=infinity \
    --setenv=CRUCIBLE_LOG="$LOG" \
    --setenv=CRUCIBLE_OWNER="$RUN_USER" \
    --setenv=CRUCIBLE_WORKDIR="$REPO_ROOT" \
    --setenv=CRUCIBLE_START="$START_EPOCH" \
    "$SELF" --inner "$@"
