#!/usr/bin/env bash
set -euo pipefail

sudo systemctl isolate graphical.target

tracker3 daemon --terminate
sudo systemctl stop unattended-upgrades.service
