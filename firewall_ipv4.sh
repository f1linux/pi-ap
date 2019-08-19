#!/bin/bash

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.04.00
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


# Do not edit below sources
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


# Append the NAT table to the bottom of /etc/ufw/before.rules
# Masquerading is done here:
echo "*nat" >> /etc/ufw/before.rules
echo ":POSTROUTING ACCEPT [0:0]" >> /etc/ufw/before.rules

echo "-A POSTROUTING -s $IPV4IPWLAN0 -o $INTERFACEMASQUERADED -j MASQUERADE" >> /etc/ufw/before.rules
echo "">> /etc/ufw/before.rules
echo "COMMIT" >> /etc/ufw/before.rules



rm /etc/ufw/user.rules

cat <<EOF> /etc/ufw/user.rules
#
# PLEASE NOTE: These FW rules are restored by script on every reboot
#
# nat Table rules
*nat
:POSTROUTING ACCEPT [0:0]

# Config Masquerading on the AP interface
-A POSTROUTING -s $IPV4IPWLAN0 -o $INTERFACEAP -j MASQUERADE

# Don't delete 'COMMIT' line or NAT table rules will not be processed
COMMIT

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
# Required for SSH
-A ufw-user-input -p tcp --dport 22 -j ACCEPT

### tuple ### allow any 53 0.0.0.0/0 any 0.0.0.0/0 DNS - out
# Required for DNS which uses both TCP and UDP
-A ufw-user-output -p tcp --dport 53 -j ACCEPT -m comment --comment 'dapp_DNS'
-A ufw-user-output -p udp --dport 53 -j ACCEPT -m comment --comment 'dapp_DNS'

### tuple ### allow udp 123 0.0.0.0/0 any 0.0.0.0/0 out
# Required to update system time via NTP
-A ufw-user-output -p udp --dport 123 -j ACCEPT

### tuple ### allow tcp 443 0.0.0.0/0 any 0.0.0.0/0 out
# Required for package management
-A ufw-user-output -p tcp --dport 443 -j ACCEPT

### tuple ### allow tcp 67:68 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p tcp -m multiport --dports 67:68 -j ACCEPT

### tuple ### allow udp 67 0.0.0.0/0 68 0.0.0.0/0 in
-A ufw-user-input -p udp --dport 67 --sport 68 -j ACCEPT

### tuple ### allow udp 68 0.0.0.0/0 any 0.0.0.0/0 out
-A ufw-user-output -p udp --dport 68 -j ACCEPT

### tuple ### allow tcp 8000 0.0.0.0/0 any 0.0.0.0/0 in
# Requested by Client
-A ufw-user-input -p tcp --dport 8000 -j ACCEPT

### tuple ### allow tcp 8883 0.0.0.0/0 any 0.0.0.0/0 in
# Requested by Client
-A ufw-user-input -p tcp --dport 8883 -j ACCEPT

### ok icmp code for FORWARD
-A ufw-user-output -p icmp --icmp-type destination-unreachable -j ACCEPT
-A ufw-user-output -p icmp --icmp-type time-exceeded -j ACCEPT
-A ufw-user-output -p icmp --icmp-type parameter-problem -j ACCEPT
-A ufw-user-output -p icmp --icmp-type echo-request -j ACCEPT

### tuple ### allow any any 0.0.0.0/0 any 10.0.60.0/24 in
-A ufw-user-input -s 10.0.60.0/24 -j ACCEPT

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
