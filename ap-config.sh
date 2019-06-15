#!/bin/bash
  
set -x

# Version 01.00.00

# Script Author:        Terrence Houlahan
# Contact:              houlahan@F1Linux.com

# Do not edit below sources
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


# Useful NetworkManager Commands:
# https://www.thegeekdiary.com/how-to-configure-and-manage-network-connections-using-nmcli/
#----------------
# nmcli general status
# nmcli radio wifi
# nmcli connection show --active
# nmcli device wifi
# nmcli dev wifi list
# nmcli connection show
# nmcli d show wlan0

# Useful wireless-tools commands:
#----------------
# iw dev


### hostapd configuration
#
# Troubleshooting:
# Start hostapd with the following to get verbose feedback to narrow how breaking:
#
# sudo hostapd -d /etc/hostapd/hostapd.conf

# Copy a default config which we will modify with sed afterwards:
zcat /usr/share/doc/hostapd/examples/hostapd.conf.gz > /etc/hostapd/hostapd.conf

# Persistently modify key directives in /etc/hostapd/hostapd.conf with sed
sed -i "s/^interface=.*/interface=$INTERFACEAP/" /etc/hostapd/hostapd.conf
sed -i "s/# driver=hostap/driver=nl80211/" /etc/hostapd/hostapd.conf
sed -i "s/channel=.*/channel=$CHANNEL/" /etc/hostapd/hostapd.conf
sed -i "s/macaddr_acl=0/macaddr_acl=$MACADDRACL/" /etc/hostapd/hostapd.conf
sed -i "s/#accept_mac_file=\/etc\/hostapd.accept/#accept_mac_file=\/etc\/hostapd\/hostapd.accept/" /etc/hostapd/hostapd.conf
sed -i "s/#ieee80211d=1/ieee80211d=1/" /etc/hostapd/hostapd.conf
sed -i "s/ssid=test/ssid=$SSIDNAME/" /etc/hostapd/hostapd.conf
sed -i "s/auth_algs=3/auth_algs=1/" /etc/hostapd/hostapd.conf
sed -i "s/#utf8_ssid=1/utf8_ssid=1/" /etc/hostapd/hostapd.conf
sed -i "s/hw_mode=.*/hw_mode=g/" /etc/hostapd/hostapd.conf
sed -i "s/#country_code=US/country_code=$WIFIREGULATORYDOMAIN/" /etc/hostapd/hostapd.conf
sed -i "s/#ieee80211h=1/ieee80211h=1/" /etc/hostapd/hostapd.conf
sed -i "s/#local_pwr_constraint=3/local_pwr_constraint=3/" /etc/hostapd/hostapd.conf
sed -i "s/#wpa=1/wpa=2/" /etc/hostapd/hostapd.conf
sed -i "s/#wpa_key_mgmt=WPA-PSK WPA-EAP/wpa_key_mgmt=WPA-PSK/" /etc/hostapd/hostapd.conf
sed -i "s/#wpa_passphrase=secret passphrase/wpa_passphrase=$APWPA2PASSWD/" /etc/hostapd/hostapd.conf
sed -i "s/#wpa_pairwise=TKIP CCMP/wpa_pairwise=TKIP/" /etc/hostapd/hostapd.conf
sed -i "s/#rsn_pairwise=CCMP/rsn_pairwise=CCMP/" /etc/hostapd/hostapd.conf

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=380632
chmod 600 /etc/hostapd/hostapd.conf

# Copy the file with MAC Addresses of devices allowed to connect to a GW via the WiFi AP just configured
cp -p ./hostapd.accept /etc/hostapd/

# Configure hostapd process as daemon:
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

systemctl unmask hostapd
systemctl enable hostapd


### /etc/default/crda Configuration:
# Set the AP country regulatory domain
sed -i "s/REGDOMAIN=/REGDOMAIN=$WIFIREGULATORYDOMAIN/" /etc/default/crda


### DNSMASQ Configuration:
sed -i "s/#interface=/interface=$INTERFACEAP/" /etc/dnsmasq.conf
sed -i "s/#dhcp-range=192.168.*,192.168.*,.*h/dhcp-range=$DHCPRANGE,$DHCPLEASETIMEHOURS\h/" /etc/dnsmasq.conf

if [[ $(systemctl list-unit-files|grep dnsmasq|awk '{print $2}') != 'enabled' ]]; then
	systemctl enable dnsmasq
fi

if [[ $(systemctl status dnsmasq|grep active|awk '{print $2}') != 'active' ]]; then
	systemctl start dnsmasq.service
else
	systemctl reload dnsmasq.service
fi

# NOTE: forwarding is configured in "kernel_modifications.sh" as its accomplished via the sysctl interface 

### DHCPCD Configuration:
echo "" >> /etc/dhcpcd.conf
echo "interface $INTERFACEAP/" >> /etc/dhcpcd.conf
echo "static ip_address=$IPV4IPWLAN0/" >> /etc/dhcpcd.conf
echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf
echo '' >> /etc/dhcpcd.conf

# Restart all the networky stuff:
systemctl restart dhcpcd.service
systemctl restart networking.service

# After all the fundamental config has been accomplished we finally restart hostapd:
# The required masquerading will be configured in the firewall section
systemctl start hostapd
