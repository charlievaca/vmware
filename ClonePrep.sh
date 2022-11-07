#!/bin/bash
 
# This is a Script Modified and adapted by Charlie Vaca. Original Code from MartinGavanda.

# Disclaimer: The name of this Script is inspired by the same concept that Horizon View launches when you clone desktops
# since it does the same thing, but do not confuse that the current one is developed manually by the ARQ team at ICA (CharlieV)
# and is for internal use by our deployments.

set -x
exec 2>/home/customization.log

echo -e "\n=== Start Pre-Freeze ==="

INTERFACE_NAME="ens160"
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
GATEWAY=$(vmware-rpctool "info-get guestinfo.ic.gateway")

echo "Updating IP Address ..."
cat > /etc/sysconfig/network-scripts/ifcfg-ens160 <<EOF
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
NAME="ens160"
DEVICE="ens160"
ONBOOT="yes"
IPADDR="$IP_ADDRESS"
PREFIX="24"
GATEWAY="$GATEWAY"
DNS1="192.168.148.50"
DNS2="192.168.148.51"
IPV6_PRIVACY="no"
EOF

echo "Updating Hostname ..."
hostnamectl set-hostname ${HOSTNAME}

echo "Restart networking ..."
ip link set ens160 up
systemctl restart network

echo "Updating Hardware Clock on the system ..."
hwclock --hctosys

echo "=== End of Post-Freeze ==="

echo -e "\nCheck /home/customization.log for details\n\n"
