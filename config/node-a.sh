apk add --no-cache iproute2
sysctl -w net.ipv6.conf.all.disable_ipv6=1
ip addr replace 192.168.5.5/24 dev eth1
ip link set eth1 up
sleep 1
ip route replace default via 192.168.5.1
