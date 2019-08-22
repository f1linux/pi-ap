#!/bin/bash

#set -x

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.05.00
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


# Do not edit below sources
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


# "systemd-resolved" is a native name caching stub resolver service within the systemd world
# Tell /etc/nsswitch.conf to use systemd-resolved as a name resolution resource after checking static "name:ip" mappings.
# This ensures if a name was previously resolved then that mapping can be retrieved from the local cache before going out on the Internet

sed -i 's/hosts:.*files mdns4_minimal \[NOTFOUND=return\] resolve \[\!UNAVAIL=return\] dns/hosts:          files resolve dns mdns4_minimal /' /etc/nsswitch.conf


# Config /etc/systemd/resolved:
# Edit default systemd-resolved config file which has all directives disabled by default

sed -i "s/#DNS=/DNS=$DNSRESOLVERIPV41 $DNSRESOLVERIPV61/" /etc/systemd/resolved.conf
sed -i "s/#FallbackDNS=/FallbackDNS=$DNSRESOLVERIPV42 $DNSRESOLVERIPV62/" /etc/systemd/resolved.conf
sed -i "s/#LLMNR=yes/LLMNR=yes/" /etc/systemd/resolved.conf
sed -i "s/#Cache=yes/Cache=yes/" /etc/systemd/resolved.conf
sed -i "s/#DNSStubListener=yes/DNSStubListener=yes/" /etc/systemd/resolved.conf

# Any value other than "no" for directive "DNSSEC" breaks name resolution including "allow-downgrade" oddly enough
# So we hedge our bets and match for different possible default values other than "no" to ensure they are set to "no":
sed -i "s/#DNSSEC=no/DNSSEC=no/" /etc/systemd/resolved.conf
sed -i "s/DNSSEC=no/DNSSEC=no/" /etc/systemd/resolved.conf
sed -i "s/#DNSSEC=yes/DNSSEC=no/" /etc/systemd/resolved.conf
sed -i "s/DNSSEC=yes/DNSSEC=no/" /etc/systemd/resolved.conf
sed -i "s/#DNSSEC=allow-downgrade/DNSSEC=no/" /etc/systemd/resolved.conf
sed -i "s/DNSSEC=allow-downgrade/DNSSEC=no/" /etc/systemd/resolved.conf

systemctl daemon-reload

systemctl enable systemd-resolved.service
systemctl restart systemd-resolved.service
