#!/bin/bash

#set -x

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


# Set systemd-timesyncd to start on boot if it is not already:
if [[ $(systemctl list-unit-files|grep systemd-timesyncd.service|awk '{print $2}') = 'enabled' ]]; then
    timedatectl set-ntp true
fi


sed -i 's/#NTP=/NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org/' /etc/systemd/timesyncd.conf
sed -i 's/#FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org/FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org/' /etc/systemd/timesyncd.conf

sed -i 's/#RootDistanceMaxSec=5/RootDistanceMaxSec=5/' /etc/systemd/timesyncd.conf
sed -i 's/#PollIntervalMinSec=32/PollIntervalMinSec=32/' /etc/systemd/timesyncd.conf
sed -i 's/#PollIntervalMaxSec=2048/PollIntervalMaxSec=2048/' /etc/systemd/timesyncd.conf


# Re-read config with changes and restart systemd-timesyncd:
systemctl daemon-reload
systemctl restart systemd-timesyncd.service


echo 'Output of *timedatectl status* Follows:'
echo
timedatectl status
echo

echo "$(tput setaf 6)Validate above time against your computer clock to ensure it approximates current time in your geography$(tput sgr 0)"
echo
