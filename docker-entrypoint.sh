#!/usr/bin/env bash

set -euxo pipefail

mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

./gost "$@" &
./corplink-rs config.json
