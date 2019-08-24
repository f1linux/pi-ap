#!/bin/bash

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.06.00
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


# Do not edit below sources
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


# Below variables can be used to specify the subnetting of the eth0 interface in UFW rules or elsewhere
IPV4IPETH0="$(ip addr list|grep 'eth0'|awk 'FNR==2'|awk '{print $2}')"
IPV4SUBNETETH0="$(sipcalc $IPV4IPETH0|awk 'FNR==7'|awk '{print $4}')"
IPV4SUBNETMASKETH0="$(sipcalc $IPV4IPETH0|awk 'FNR==9'|awk '{print $5}')"

# ie: the following would give you the subnet and mask of eth0 if you source this variables.sh file
#	$IPV4SUBNETETH0/$IPV4SUBNETMASKETH0


# Enable Forwarding between the eth0 and wlan0 Interfaces
sed -i "s|#net/ipv4/ip_forward=1|net/ipv4/ip_forward=1|" /etc/ufw/sysctl.conf


# Append the NAT table to the bottom of /etc/ufw/before.rules
# Masquerading is done here:
echo "*nat" >> /etc/ufw/before.rules
echo ":POSTROUTING ACCEPT [0:0]" >> /etc/ufw/before.rules
echo "-A POSTROUTING -s 0.0.0.0/0 -o $INTERFACEMASQUERADED -j MASQUERADE" >> /etc/ufw/before.rules
echo "COMMIT" >> /etc/ufw/before.rules



rm /etc/ufw/user.rules

cat <<EOF> /etc/ufw/user.rules
#
# PLEASE NOTE: These FW rules are restored by script on every reboot
#

*filter
:ufw-user-input - [0:0]
:ufw-user-output - [0:0]
:ufw-user-forward - [0:0]
:ufw-before-logging-input - [0:0]
:ufw-before-logging-output - [0:0]
:ufw-before-logging-forward - [0:0]
:ufw-user-logging-input - [0:0]
:ufw-user-logging-output - [0:0]
:ufw-user-logging-forward - [0:0]
:ufw-after-logging-input - [0:0]
:ufw-after-logging-output - [0:0]
:ufw-after-logging-forward - [0:0]
:ufw-logging-deny - [0:0]
:ufw-logging-allow - [0:0]
:ufw-user-limit - [0:0]
:ufw-user-limit-accept - [0:0]
### RULES ###

### tuple ### allow any 22 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p tcp --dport 22 -j ACCEPT
-A ufw-user-input -p udp --dport 22 -j ACCEPT

### tuple ### allow any 53 0.0.0.0/0 any 0.0.0.0/0 DNS - out
-A ufw-user-output -p tcp --dport 53 -j ACCEPT -m comment --comment 'dapp_DNS'
-A ufw-user-output -p udp --dport 53 -j ACCEPT -m comment --comment 'dapp_DNS'

### tuple ### allow udp 123 0.0.0.0/0 any 0.0.0.0/0 out
-A ufw-user-output -p udp --dport 123 -j ACCEPT

### tuple ### allow tcp 443 0.0.0.0/0 any 0.0.0.0/0 out
-A ufw-user-output -p tcp --dport 443 -j ACCEPT

### tuple ### allow tcp 67:68 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p tcp -m multiport --dports 67:68 -j ACCEPT

### tuple ### allow udp 67 0.0.0.0/0 68 0.0.0.0/0 in
-A ufw-user-input -p udp --dport 67 --sport 68 -j ACCEPT

### tuple ### allow udp 68 0.0.0.0/0 any 0.0.0.0/0 out
-A ufw-user-output -p udp --dport 68 -j ACCEPT

### tuple ### allow udp 53 0.0.0.0/0 any 192.168.0.0/28 in
-A ufw-user-input -p udp --dport 53 -s 192.168.0.0/28 -j ACCEPT

### tuple ### allow tcp 53 0.0.0.0/0 any 192.168.0.0/28 in
-A ufw-user-input -p tcp --dport 53 -s 192.168.0.0/28 -j ACCEPT

### tuple ### allow tcp 80 0.0.0.0/0 any 192.168.0.0/28 in
-A ufw-user-input -p tcp --dport 80 -s 192.168.0.0/28 -j ACCEPT

### tuple ### allow tcp 443 0.0.0.0/0 any 192.168.0.0/28 in
-A ufw-user-input -p tcp --dport 443 -s 192.168.0.0/28 -j ACCEPT

### tuple ### allow udp 5353 0.0.0.0/0 any 192.168.0.0/28 in
-A ufw-user-input -p udp --dport 5353 -s 192.168.0.0/28 -j ACCEPT

### tuple ### route:allow tcp 80 0.0.0.0/0 any 0.0.0.0/0 in_eth0!out_wlan0
-A ufw-user-forward -i eth0 -o wlan0 -p tcp --dport 80 -j ACCEPT

### tuple ### route:allow tcp 80 0.0.0.0/0 any 0.0.0.0/0 in_wlan0!out_eth0
-A ufw-user-forward -i wlan0 -o eth0 -p tcp --dport 80 -j ACCEPT

### tuple ### route:allow tcp 443 0.0.0.0/0 any 0.0.0.0/0 in_eth0!out_wlan0
-A ufw-user-forward -i eth0 -o wlan0 -p tcp --dport 443 -j ACCEPT

### tuple ### route:allow tcp 443 0.0.0.0/0 any 0.0.0.0/0 in_wlan0!out_eth0
-A ufw-user-forward -i wlan0 -o eth0 -p tcp --dport 443 -j ACCEPT

### tuple ### route:allow tcp 53 0.0.0.0/0 any 0.0.0.0/0 in_eth0!out_wlan0
-A ufw-user-forward -i eth0 -o wlan0 -p tcp --dport 53 -j ACCEPT

### tuple ### route:allow tcp 53 0.0.0.0/0 any 0.0.0.0/0 in_wlan0!out_eth0
-A ufw-user-forward -i wlan0 -o eth0 -p tcp --dport 53 -j ACCEPT

### tuple ### route:allow udp 53 0.0.0.0/0 any 0.0.0.0/0 in_eth0!out_wlan0
-A ufw-user-forward -i eth0 -o wlan0 -p udp --dport 53 -j ACCEPT

### tuple ### route:allow udp 53 0.0.0.0/0 any 0.0.0.0/0 in_wlan0!out_eth0
-A ufw-user-forward -i wlan0 -o eth0 -p udp --dport 53 -j ACCEPT

### END RULES ###

### LOGGING ###
-A ufw-after-logging-input -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
-A ufw-after-logging-forward -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
-I ufw-logging-deny -m conntrack --ctstate INVALID -j RETURN -m limit --limit 3/min --limit-burst 10
-A ufw-logging-deny -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
-A ufw-logging-allow -j LOG --log-prefix "[UFW ALLOW] " -m limit --limit 3/min --limit-burst 10
### END LOGGING ###

### RATE LIMITING ###
-A ufw-user-limit -m limit --limit 3/minute -j LOG --log-prefix "[UFW LIMIT BLOCK] "
-A ufw-user-limit -j REJECT
-A ufw-user-limit-accept -j ACCEPT
### END RATE LIMITING ###
COMMIT
EOF
