# shellcheck shell=bash
# no need for shebang - this file is loaded from charts.d.plugin
# SPDX-License-Identifier: GPL-3.0-or-later

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
#

# if this chart is called X.chart.sh, then all functions and global variables
# must start with X_

# based on https://raw.githubusercontent.com/netdata/netdata/master/collectors/charts.d.plugin/example/example.chart.sh
#
# charts.d.plugin looks for scripts in /usr/lib/netdata/charts.d.
# The scripts should have the filename suffix: .chart.sh.
# By default, charts.d.plugin is not included as part of the install
# when using our official native DEB/RPM packages. You can install it
# by installing the netdata-plugin-chartsd package.

# _update_every is a special variable - it holds the number of seconds
# between the calls of the _update() function
ytdlbot_update_every=10

# the priority is used to sort the charts on the dashboard
# 1 = the first chart
ytdlbot_priority=85000

# global variables to store our collected data
# remember: they need to start with the module name example_
ytdlbot_failures_count=0
ytdlbot_queue_count=0
ytdlbot_bytes_used=0
ytdlbot_videos_count=0
ytdlbot_backup_bytes_used=0

ytdlbot_get() {
  # do all the work to collect / calculate the values
  # for each dimension
  #
  # Remember:
  # 1. KEEP IT SIMPLE AND SHORT
  # 2. AVOID FORKS (avoid piping commands)
  # 3. AVOID CALLING TOO MANY EXTERNAL PROGRAMS
  # 4. USE LOCAL VARIABLES (global variables may overlap with other modules)

  ytdlbot_queue_count=$(jq '.queue_count' </var/run/ytdlbot/stats.json)
  ytdlbot_failures_count=$(jq '.failures' </var/run/ytdlbot/stats.json)
  ytdlbot_bytes_used=$(jq '.bytes_used' </var/run/ytdlbot/stats.json)
  ytdlbot_videos_count=$(jq '.videos_count' </var/run/ytdlbot/stats.json)
  ytdlbot_backup_bytes_used=$(jq '.backup_bytes_used' </var/run/ytdlbot/stats.json)
  return $?

  # this should return:
  #  - 0 to send the data to netdata
  #  - 1 to report a failure to collect the data
}

# _check is called once, to find out if this chart should be enabled or not
ytdlbot_check() {
  # check that we can collect data
  ytdlbot_get || return 1

  # this should return:
  #  - 0 to enable the chart
  #  - 1 to disable the chart
  return 0
}

# _create is called once, to create the charts
ytdlbot_create() {
  # create the chart with 1 dimension
  cat <<EOF
CHART ytdlbot.queue '' "Queue" "queue items" "ytdlbot" ytdlbot.queue_count area $((ytdlbot_priority)) $ytdlbot_update_every '' '' 'ytdlbot'
DIMENSION queue_count items absolute 1 1
CHART ytdlbot.failures '' "Download Failures" "uncleared failures" "ytdlbot" ytdlbot.failure_count area $((ytdlbot_priority + 1)) $ytdlbot_update_every '' '' 'ytdlbot'
DIMENSION failure_count failures absolute 1 1
CHART ytdlbot.videos '' "Archived Videos" "videos" "ytdlbot" ytdlbot.videos_count area $((ytdlbot_priority + 2)) $ytdlbot_update_every '' '' 'ytdlbot'
DIMENSION videos_count videos absolute 1 1
CHART ytdlbot.bytes '' "Bytes On Disk" "bytes" "ytdlbot" ytdlbot.bytes_used area $((ytdlbot_priority + 3)) $ytdlbot_update_every '' '' 'ytdlbot'
DIMENSION bytes_used bytes absolute 1024 1
CHART ytdlbot.backup_bytes '' "Bytes In Backup Set" "bytes" "ytdlbot" ytdlbot.backup_bytes area $((ytdlbot_priority + 4)) $ytdlbot_update_every '' '' 'ytdlbot'
DIMENSION backup_bytes bytes absolute 1024 1
EOF

  return 0
}

# _update is called continuously, to collect the values
ytdlbot_update() {
  # the first argument to this function is the microseconds since last update
  # pass this parameter to the BEGIN statement (see below).

  ytdlbot_get || return 1

  # write the result of the work.
  cat <<VALUESEOF
BEGIN ytdlbot.queue $1
SET queue_count = $ytdlbot_queue_count
END
BEGIN ytdlbot.failures $1
SET failure_count = $ytdlbot_failures_count
END
BEGIN ytdlbot.bytes $1
SET bytes_used = $ytdlbot_bytes_used
END
BEGIN ytdlbot.backup_bytes $1
SET backup_bytes = $ytdlbot_backup_bytes_used
END
BEGIN ytdlbot.videos $1
SET videos_count = $ytdlbot_videos_count
END
VALUESEOF

  return 0
}
