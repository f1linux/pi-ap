#!/bin/bash
  
#set -x

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.03.00
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


# Do not edit below sources
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"

#
### Loading/unloading drivers, modifcations to Kernel Parameters and any other changes related to the Kernel are configured here ###
#

### sysctl changes:

# Enable Forwarding:
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sed -i "s/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/" /etc/sysctl.conf

# Read the new changes:
sysctl -p

