#!/bin/bash

#set -x

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.10.01
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


cat <<'EOF'> /etc/update-motd.d/99-pi-ap
#!/bin/sh
#
# Note: this filename prefaced with "99" to ensure it prints output after all other login motd messages
#

export TERM=xterm-256color

echo
echo '#######################################################################################'
echo "                $(tput setaf 5)pi-ap: Wireless AP$(tput sgr 0): https://github.com/f1linux/pi-ap"
echo '                            Developer: Terrence Houlahan'
echo '                  https://www.linkedin.com/in/terrencehoulahan'
echo
echo '                      Pi-AP Wiki: https://github.com/f1linux/pi-ap/wiki'
echo '           Pi-AP YouTube Channel: https://www.YouTube.com/user/LinuxEngineer'
echo '#######################################################################################'
echo
echo "$(tput setaf 5)Change WiFi Password:$(tput sgr 0)"
echo '     sudo nano /etc/wpa_supplicant/wpa_supplicant.conf'
echo '     Change the "psk" - PreShared Key- value with the new WiFi password'
echo '     sudo systemctl restart wpa_supplicant.service'					
echo
echo '#######################################################################################'
echo
echo "$(tput setaf 5)Change Pi User Login Password$(tput sgr 0)"
echo '     sudo su -'
echo '     passwd pi'
echo '     After changing password return to pi user shell by executing:'
echo '     exit'
echo
echo '#######################################################################################'
echo
echo "$(tput setaf 5)Display Wireless Clients Connected to AP:$(tput sgr 0)"
echo '     iw dev wlan0 station dump'
echo
echo '#######################################################################################'
EOF

chmod 755 /etc/update-motd.d/99-pi-ap

echo
echo 'Created /etc/update-motd.d/99-pi-ap'
echo
