#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if netdata -W buildinfo | grep -i 'installation type' | grep -c 'binpkg-' >/dev/null; then
  if [ -x /usr/bin/apt ] && ! dpkg -l netdata-plugin-chartsd >/dev/null; then
    sudo apt install -yq netdata-plugin-chartsd
  elif [ -x /usr/bin/yum ] && ! rpm -q netdata-plugin-chartsd >/dev/null; then
    sudo yum install -yq netdata-plugin-chartsd
  fi
fi

set -x

sudo cp "$SCRIPT_DIR"/ytdlbot.chart.sh /usr/libexec/netdata/charts.d/ytdlbot.chart.sh
sudo chown root:netdata /usr/libexec/netdata/charts.d/ytdlbot.chart.sh
sudo chmod 0644 /usr/libexec/netdata/charts.d/ytdlbot.chart.sh

sudo mkdir -p /var/run/ytdlbot
sudo chown root:netdata /var/run/ytdlbot
sudo chmod 0777 /var/run/ytdlbot

sudo systemctl restart netdata
