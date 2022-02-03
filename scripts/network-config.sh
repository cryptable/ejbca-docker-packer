#!/bin/sh

sudo rm /etc/netplan/00*

sudo cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ${ETH_POINT}:
      dhcp4: yes
EOF

cat <<EOF > /etc/hosts
127.0.0.1 localhost
127.0.1.1 ${HOSTNAME}

# The following lines are desireable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
fe02::1 ip6-allnodes
fe02::2 ip6-allrouters
EOF
