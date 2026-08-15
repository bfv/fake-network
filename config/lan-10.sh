#!/bin/sh

set -eu

apk add --no-cache iproute2
ip link add br0 type bridge

for interface in eth1 eth2 eth3 eth4; do
    ip link set "$interface" master br0
    ip link set "$interface" up
done

ip link set br0 up