#!/usr/bin/env bash
set -euo pipefail

pgrep cron >/dev/null || exit 1
test -f /ytdlbot-media/_queue.txt || exit 1
