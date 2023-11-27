#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
set -x

sudo cp "$SCRIPT_DIR"/ytdlbot.conf /etc/netdata/health.d/ytdlbot.conf
sudo chown root:netdata /etc/netdata/health.d/ytdlbot.conf
sudo chmod 0644 /etc/netdata/health.d/ytdlbot.conf

sudo systemctl restart netdata
