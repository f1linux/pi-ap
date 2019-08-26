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


cat <<EOF> $PATHSCRIPTS/pwr-mgmnt-wifi-disable.sh
#!/bin/bash
iw dev wlan0 set power_save off
EOF

chmod 700 $PATHSCRIPTS/pwr-mgmnt-wifi-disable.sh

echo "Created: $PATHSCRIPTS/pwr-mgmnt-wifi-disable.sh"


cat <<EOF> /etc/systemd/system//pwr-mgmnt-wifi-disable.service
[Unit]
Description=Disable WiFi Power Management
Requires=network-online.target
After=hostapd.service

[Service]
User=root
Group=root
Type=oneshot
ExecStart=$PATHSCRIPTS/pwr-mgmnt-wifi-disable.sh

[Install]
WantedBy=multi-user.target

EOF


chmod 644 /etc/systemd/system/pwr-mgmnt-wifi-disable.service

systemctl enable pwr-mgmnt-wifi-disable.service
systemctl start pwr-mgmnt-wifi-disable.service

echo "Created: /etc/systemd/system/pwr-mgmnt-wifi-disable.service"
