#!/bin/sh

lab_dir="$(pwd)"
action="${1:-deploy}"

if [ ! -d /var/run/netns ]; then
    sudo mkdir -p /var/run/netns
fi

docker run \
    --rm \
    -it \
    --net=host \
    --pid=host \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/netns:/var/run/netns \
    -v /sys:/sys \
    -v "$lab_dir:$lab_dir" \
    -w "$lab_dir" \
    ghcr.io/srl-labs/clab:latest containerlab "$action" -t ./netwerk.cabl.yaml

