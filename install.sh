#!/bin/bash

#set -x

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.01.00
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com


# Do not edit below sources  
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"



echo
echo "$(tput setaf 5)******  GPL3 LICENSE:  ******$(tput sgr 0)"
echo

echo 'All scripts/files in the pi-ap repository are Copyright (C) 2019 Terrence Houlahan'
echo
echo "This program comes with ABSOLUTELY NO WARRANTY express or implied."
echo "This is free software and you are welcome to redistribute it under certain conditions."
echo "Consult * LICENSE.txt * for full terms of GPL 3 License and conditions of use."

read -p "Press ENTER to accept GPL v3 license terms to continue or terminate this bash shell to exit script"



# Create directory where logs will be written
if [ ! -d $PATHLOGSCRIPTS ]; then
        mkdir $PATHLOGSCRIPTS
        chmod 770 $PATHLOGSCRIPTS
        chown $USEREXECUTINGSCRIPT:$USEREXECUTINGSCRIPT $PATHLOGSCRIPTS
fi


cd $PATHSCRIPTS


echo
echo "$(tput setaf 5)****** PACKAGE MANAGEMENT:  ******$(tput sgr 0)"
echo
echo 'Elapsed Time for Package Management will be printed after this section completes:'
echo

time ./packages.sh 2>> $PATHLOGSCRIPTS/install.log



echo "$(tput setaf 4)If packet count does not increment for the rule- proving its not matching- check log using following command:$(tput sgr 0)"
echo "          'sudo tail -fn 100 /var/log/kern.log'           "
echo



echo
echo "$(tput setaf 5)****** AP Configuration: ******$(tput sgr 0)"
echo

./ap-config.sh 2>> $PATHLOGSCRIPTS/install.log




echo
echo "$(tput setaf 5)****** Kernel: Driver Loading/Unloading and Setting Kernel Parameters ******$(tput sgr 0)"
echo

./kernel_modifications.sh 2>> $PATHLOGSCRIPTS/install.log


echo '###################################################################################################'


echo
echo "$(tput setaf 4)Troubleshooting: Show Processes Status:$(tput sgr 0)"
echo

echo
echo
systemctl status hostapd.service --no-pager 2>> $PATHLOGSCRIPTS/install.log
echo
echo


echo
echo
systemctl status dhcpcd.service --no-pager 2>> $PATHLOGSCRIPTS/install.log
echo
echo


echo
echo
systemctl status dnsmasq.service --no-pager 2>> $PATHLOGSCRIPTS/install.log
echo
echo

echo '###################################################################################################'

echo
echo "$(tput setaf 4)Troubleshooting: Show Key Config Files:$(tput sgr 0)"
echo

echo "Show $(tput setaf 4)/etc/dnsmasq.conf$(tput sgr 0)"
echo
cat /etc/dnsmasq.conf | grep "^[^#]"
echo
echo

echo "Show $(tput setaf 4)/etc/dhcpcd.conf$(tput sgr 0)"
echo
cat /etc/dhcpcd.conf | grep "^[^#]"
echo
echo

echo "Show $(tput setaf 4)/etc/hostapd/hostapd.conf$(tput sgr 0)"
echo
cat /etc/hostapd/hostapd.conf | grep "^[^#]"
echo
echo

echo "Check below feedback from $(tput setaf 4)rfkill list$(tput sgr 0) to determine if any interfaces register a hardblock"
echo
rfkill list
echo
echo

echo "Show radio Status: $(tput setaf 4)nmcli radio$(tput sgr 0)":
nmcli radio
echo
echo

echo "Show $(tput setaf 4)NetworkManager$(tput sgr 0) managed interfaces: $(tput setaf 4)nmcli connection show$(tput sgr 0) :"
nmcli connection show
echo
echo

echo "Show $(tput setaf 4)systemd-networkd$(tput sgr 0) managed connections: $(tput setaf 4)networkctl list$(tput sgr 0) :"
networkctl list
echo
echo

echo 'Show Wireless Driver Mode: "cat /etc/modprobe.d/rs9113.conf" :'
echo 'Expected value is "6" - A value of "13" (default) breaks WiFi'
cat /etc/modprobe.d/rs9113.conf
echo
echo


echo
echo "$(tput setaf 5)****** FireWall Config: ******$(tput sgr 0)"
echo

./firewall_ipv4.sh 2>> $PATHLOGSCRIPTS/install.log
./firewall_ipv6.sh 2>> $PATHLOGSCRIPTS/install.log
./firewall_Default-Policies.sh 2>> $PATHLOGSCRIPTS/install.log

echo "$(tput setaf 4)Load UFW Firewall Changes$(tput sgr 0)"
echo "y" | ufw disable
echo "y" | ufw enable

ufw logging on


echo "$(tput setaf 4)Print Firewall Rules$(tput sgr 0)"
ufw status numbered verbose
echo


echo
echo "$(tput setaf 4)Print Firewall USER Rules Only$(tput sgr 0)"
echo
echo "$(tput setaf 4)Execute 'sudo ufw show user-rules' and view packet counts for non-zero values to determine if rules are matching$(tput sgr 0)"
echo "$(tput setaf 4)Specimen output of the command shown below:$(tput sgr 0)"
echo
ufw show user-rules
echo




echo "Config Completed. Host will reboot now"
echo
systemctl reboot
