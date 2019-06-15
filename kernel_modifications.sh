#!/bin/bash
  
set -x

# Version 01.00.00

# Script Author:        Terrence Houlahan
# Contact:              houlahan@F1Linux.com

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

