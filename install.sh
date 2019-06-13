#!/bin/bash

set -x

# Version 01.00.00

# Script Author: 	Terrence Houlahan
# Contact:		houlahan@F1Linux.com

# Do not edit below sources  
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


if [ ! -d $PATHLOGSCRIPTS ]; then
        mkdir $PATHLOGSCRIPTS
        chmod 700 $PATHLOGSCRIPTS
        chown admin:admin $PATHLOGSCRIPTS
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
echo "$(tput setaf 5)****** FireWall Config: ******$(tput sgr 0)"
echo

./firewall_Default-Policies.sh 2>> $PATHLOGSCRIPTS/install.log
./firewall_ipv4.sh 2>> $PATHLOGSCRIPTS/install.log
./firewall_ipv6.sh 2>> $PATHLOGSCRIPTS/install.log

echo "$(tput setaf 4)Load UFW Firewall Changes$(tput sgr 0)"
echo "y" | ufw disable
echo "y" | ufw enable

ufw logging on



echo
echo "$(tput setaf 4)Reloading FW Rules$(tput sgr 0)"
ufw reload
echo



echo "$(tput setaf 4)Printing Firewall Status$(tput sgr 0)"
ufw status numbered verbose
echo



echo
echo "$(tput setaf 4)Troubleshooting FW Rules:$(tput sgr 0)"
echo
echo "$(tput setaf 4)Execute 'sudo ufw show user-rules' and view packet counts for non-zero values to determine if rules are matching$(tput sgr 0)"
echo "$(tput setaf 4)Specimen output of the command shown below:$(tput sgr 0)"
echo
ufw show user-rules
echo



echo "Config Completed. Host will reboot now"
echo
#systemctl reboot

