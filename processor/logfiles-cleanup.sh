#!/usr/bin/env bash
set -euo pipefail

ionice -c2 -n7 nice -n 19 \
  find /ytdlbot-logs -mtime +7 -name "*.log*" -delete
ionice -c2 -n7 nice -n 19 \
  find /ytdlbot-logs -mtime +1 -name "stats*.log*" -delete
ionice -c2 -n7 nice -n 19 \
  find . -name "*.log*" -exec grep -q 'nothing to do' '{}' \; -delete
