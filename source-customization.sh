#!/bin/bash

#This is a Script Modified and adapted by Charlie Vaca, copied and original from MartinGavanda.

set -x
exec 2>/home/customization.log

echo -e "\n=== Start Pre-Freeze ==="

INTERFACE_NAME="ens192"
echo "Disabling ${INTERFACE_NAME} interface ..."
ip addr flush dev ${INTERFACE_NAME}
ip link set ${INTERFACE_NAME} down

echo -e "=== End of Pre-Freeze ===\n"

echo -e "Freezing ...\n"

vmware-rpctool "instantclone.freeze"

echo -e "\n=== Start Post-Freeze ==="

# retrieve VM customization info passed from vSphere API
HOSTNAME=$(vmware-rpctool "info-get guestinfo.ic.hostname")
IP_ADDRESS=$(vmware-rpctool "info-get guestinfo.ic.ipaddress")

echo "Updating IP Address ..."
cat > /etc/sysconfig/network-scripts/ifcfg-ens192 <<EOF

TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens192"
DEVICE="ens192"
ONBOOT="yes"
IPADDR="$IP_ADDRESS"
PREFIX="24"
GATEWAY="172.20.10.10"
DNS1="172.20.10.10"
IPV6_PRIVACY="no"
EOF

echo "Updating Hostname ..."
hostnamectl set-hostname ${HOSTNAME}

echo "Restart networking ..."
ip link set ${INTERFACE_NAME} up
systemctl restart network

echo "Updating Hardware Clock on the system ..."
hwclock --hctosys

echo "=== End of Post-Freeze ==="

echo -e "\nCheck /home/customization.log for details\n\n"
[root@localhost ~]#
