apk add --no-cache iproute2
sysctl -w net.ipv6.conf.all.disable_ipv6=1
ip addr add 192.168.5.1/24 dev eth1
ip link set eth1 up
ip addr add 10.1.1.1/24 dev eth2
ip link set eth2 up
sysctl -w net.ipv4.ip_forward=1
ip route replace 192.168.16.0/24 via 10.1.1.2
