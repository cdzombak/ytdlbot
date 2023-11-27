#!/usr/bin/env bash
set -euo pipefail

queue_count=$(wc -l </ytdlbot-media/_queue.txt)
failures_count=$(wc -l </ytdlbot-media/_failures.txt)
bytes_used=$(du --summarize /ytdlbot-media | cut -f1)
videos_count=$(find /ytdlbot-media \( -path /ytdlbot-media/_failures.txt -o -path /ytdlbot-media/_queue.txt -o -path /ytdlbot-media/_disambiguations.json \) -prune -o -type f -name "[!.]*" -print | wc -l)

cat <<EOF >/ytdlbot-run/.stats.json.tmp
{
  "failures": $failures_count,
  "queue_count": $queue_count,
  "bytes_used": $bytes_used,
  "videos_count": $videos_count
}
EOF
chown root:netdata /ytdlbot-run/.stats.json.tmp
chmod 0644 /ytdlbot-run/.stats.json.tmp
mv /ytdlbot-run/.stats.json.tmp /ytdlbot-run/stats.json
