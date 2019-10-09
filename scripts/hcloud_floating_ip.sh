#!/usr/bin/env bash

set -euo pipefail


IP=$1

ip addr flush dev eth0
ip addr add ${IP}/32 dev eth0

cat > /etc/network/interfaces.d/60-my-floating-ip.cfg <<EOF
auto eth0:1
iface eth0:1 inet static
    address ${IP}
    netmask 32
EOF

service networking restart

