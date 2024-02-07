#!/bin/bash

PUID=${PUID:-911}
PGID=${PGID:-911}
groupmod -o -g "$PGID" abc
usermod -o -u "$PUID" abc
NETDATA_GID=${NETDATA_GID:-995}
groupmod -o -g "$NETDATA_GID" netdata

echo "---------------------
User UID:    $(id -u abc)
User GID:    $(id -g abc)
Netdata GID: $NETDATA_GID"

TZ=${TZ:-UTC}
ln -fs /usr/share/zoneinfo/"$TZ" /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
export TZ

echo "---------------------"

DIRSHARD_N=${DIRSHARD_N:-1}
DIRSHARD_CI=${DIRSHARD_CI:-true}
DIRSHARD_SKIP=${DIRSHARD_SKIP:-true}
export DIRSHARD_N
export DIRSHARD_CI
export DIRSHARD_SKIP

SHARD_BY_UPLOADER=${SHARD_BY_UPLOADER:-false}
ORGANIZE_BY_UPLOADER=${ORGANIZE_BY_UPLOADER:-true}
export SHARD_BY_UPLOADER
export ORGANIZE_BY_UPLOADER

touch /ytdlbot-media/_queue.txt
touch /ytdlbot-media/_failures.txt
[ -e /ytdlbot-media/_disambiguations.json ] || echo "{}" >/ytdlbot-media/_disambiguations.json

chown abc:abc /processor.sh /stats.sh /logfiles-maintenance.sh /healthcheck.sh
chown abc:abc /ytdlbot-logs
chown abc:abc /ytdlbot-media/_queue.txt /ytdlbot-media/_failures.txt /ytdlbot-media/_disambiguations.json

env >>/etc/environment

echo "running CMD: $*"
exec "$@"
