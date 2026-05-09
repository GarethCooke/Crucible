#!/usr/bin/env bash
set -euo pipefail

# Always: stop indexing and updates during runs
tracker3 daemon --terminate
sudo systemctl stop unattended-upgrades.service

# Verify the governor and SMT survived GNOME login.** GNOME Power settings can override `cpupower`; SMT state can be reset by firmware updates. After logging into GNOME and dropping back to TTY:

cpupower frequency-info | grep "current policy"     # should still be performance
cat /sys/devices/system/cpu/smt/active              # should still be 0

# If either has been stomped, re-apply via the per-boot commands; consider a systemd unit that re-applies them on graphical-session start.
