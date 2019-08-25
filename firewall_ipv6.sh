#!/bin/bash

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.10.00
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


# Do not edit below sources
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


# Enable Forwarding in the Kernel
sed -i "s|#net/ipv6/conf/default/forwarding=1|net/ipv6/conf/default/forwarding=1|" /etc/ufw/sysctl.conf
sed -i "s|#net/ipv6/conf/all/forwarding=1|net/ipv6/conf/all/forwarding=1|" /etc/ufw/sysctl.conf


# NOTE: IPv6 does *not* NAT and therefore does not require masquerading as configured in IPv4 rules.

rm /etc/ufw/user6.rules

cat <<EOF> /etc/ufw/user6.rules
#
# PLEASE NOTE: These FW rules are restored by script on every reboot
#
*filter
:ufw6-user-input - [0:0]
:ufw6-user-output - [0:0]
:ufw6-user-forward - [0:0]
:ufw6-before-logging-input - [0:0]
:ufw6-before-logging-output - [0:0]
:ufw6-before-logging-forward - [0:0]
:ufw6-user-logging-input - [0:0]
:ufw6-user-logging-output - [0:0]
:ufw6-user-logging-forward - [0:0]
:ufw6-after-logging-input - [0:0]
:ufw6-after-logging-output - [0:0]
:ufw6-after-logging-forward - [0:0]
:ufw6-logging-deny - [0:0]
:ufw6-logging-allow - [0:0]
:ufw6-user-limit - [0:0]
:ufw6-user-limit-accept - [0:0]
### RULES ###

### tuple ### allow any 22 ::/0 any ::/0 in
-A ufw6-user-input -p tcp --dport 22 -j ACCEPT

### tuple ### allow any 53 ::/0 any ::/0 DNS - out
-A ufw6-user-output -p tcp --dport 53 -j ACCEPT -m comment --comment 'dapp_DNS'
-A ufw6-user-output -p udp --dport 53 -j ACCEPT -m comment --comment 'dapp_DNS'

### tuple ### allow tcp 8000 ::/0 any ::/0 in
-A ufw6-user-input -p tcp --dport 8000 -j ACCEPT

### tuple ### allow tcp 8883 ::/0 any ::/0 in
-A ufw6-user-input -p tcp --dport 8883 -j ACCEPT

### tuple ### allow any 123 ::/0 any ::/0 in
-A ufw6-user-input -p udp --dport 123 -j ACCEPT

### tuple ### allow tcp 67:68 ::/0 any ::/0 in
-A ufw6-user-input -p tcp -m multiport --dports 67:68 -j ACCEPT

### tuple ### allow tcp 443 ::/0 any ::/0 out
-A ufw6-user-output -p tcp --dport 443 -j ACCEPT

### END RULES ###

### LOGGING ###
-A ufw6-after-logging-input -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
-A ufw6-after-logging-forward -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
-I ufw6-logging-deny -m conntrack --ctstate INVALID -j RETURN -m limit --limit 3/min --limit-burst 10
-A ufw6-logging-deny -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
-A ufw6-logging-allow -j LOG --log-prefix "[UFW ALLOW] " -m limit --limit 3/min --limit-burst 10
### END LOGGING ###

### RATE LIMITING ###
-A ufw6-user-limit -m limit --limit 3/minute -j LOG --log-prefix "[UFW LIMIT BLOCK] "
-A ufw6-user-limit -j REJECT
-A ufw6-user-limit-accept -j ACCEPT
### END RATE LIMITING ###
COMMIT
EOF

