#!/bin/bash

#set -x

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.10.01
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


USEREXECUTINGSCRIPT='pi'
REPONAME='pi-ap'

# Ensure all hostnames are UNIQUE:
# If using "pi-ap" to configure other APs on your LAN change default hostname by at least incrementing number in name ie: "3bplus-ap2" as you add them
OURHOSTNAME='3bplus-ap1'
OURDOMAIN='f1linux.com'

### AP Variables:

# DHCP Pool will be derived from the IP and mask specified in "IPV4IPWLAN0" variable. If larger pool of addresses required use a wider mask than a /28
# ** Ensure that this subnet specified below is not already used on your network **
IPV4IPWLAN0='192.168.0.1/28'
#IPV6IPWLAN0="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

# NOTE: Both Hyphens and underscores are valid characters for use in an SSID
SSIDNAME='RPI-AP1'
# Password must be min 8 characters and must NOT include single quotes- these are used as delimiters to encase the password so other special characters do not expand in bash
APWPA2PASSWD='cH4nG3M3'

# Default port systemd-resolved start on '5353' collides with dnsmasq (which does DHCP for WiFi clients) which also uses '5353' as its default port.
# I chose 5454 but that number is arbitrary: if you have another process which listens on port 5454 feel free to change it to a different value
DNSMASQPORT='5454'


# Nameservers WiFi clients are assigned by dnsmasq:
# NOTE: First resolver is the systemd-resolved stub resolver the Pi AP where names can be reolved from cached queries before reaching out to a DNS resolver on the Internet:
DNSRESOLVER1WIFICLIENTS=$(echo $IPV4IPWLAN0 |cut -d '/' -f1)
DNSRESOLVER2WIFICLIENTS='8.8.4.4'

# DNS Resolvers Raspberry Pi Host: These are resolvers the Pi itself (not WiFi clients) will use and are specified in /etc/systemd/resolved.conf
DNSRESOLVERIPV41='8.8.8.8'
DNSRESOLVERIPV42='8.8.4.4'
DNSRESOLVERIPV61='2001:4860:4860::8888'
DNSRESOLVERIPV62='2001:4860:4860::8844'

# Set channel to a non-overlapping one where possible: 1/6/11 . If a non-overlapping channel is saturated try the next one before using overlapping ones 
CHANNEL='6'

# Operation Mode:
# a   = IEEE 802.11a (5 GHz)
# b   = IEEE 802.11b (2.4 GHz)
# g   = IEEE 802.11g (2.4 GHz). For IEEE 802.11ac (VHT) set to hw_mode=g
# ad  = IEEE 802.11ad (60 GHz); a/g options are used with IEEE 802.11n (HT), too, to specify band)
# any = used to indicate that any support band can be used.  Currently supported only with drivers with which offloaded ACS is used.
# Default: IEEE 802.11b
HWMODE='g'

# Enable 802.11ac
# NOTE: Only Pi3B+ and later models support 802.11ac
# '0'= Disabled  - '1'=Enabled
# NOTICE: When enabling MODE80211AC then "HWMODE" MUST be set to a value of "a"
#	 When the install executes it will validate that this dependency has been met or ignore enabling MODE80211AC
MODE80211AC='0'

# MACADDRACL (White-listing clients by their MAC address) restricts AP authentication to only hosts with their WiFi interface mac address listed in "hostapd.accept"
# "0" = DISABLE (password auth only)
# "1" = ENABLE (password *AND* Mac Address in "hostapd.accept" to authenticate to AP)
# NOTE: If "MACADDRACL" set to "1" and "hostapd.access" file is empty- does not contain at least 1 MAC address- Whitelisting will remain disabled
MACADDRACL='0'

# Interfaces are aliased for 2 reasons:
# A. Illustrate the interfaces function within the configuration and
# B. Interface names might be unpredictable in the future as has happened with other distros.
INTERFACEAP='wlan0'
# Below variable used in "firewall_ipv4.sh" script
INTERFACEMASQUERADED='eth0'

### dhcpcd.conf Variables
# default: 12h
DHCPLEASETIMEHOURS='12'


# BELOW ARE SELF-POPULATING: They require no user input or modification
#######################################################################
### PLEASE NOTE: ###
# Although MOST variables are centralized in this file be aware
# that a subset of self-populating variables live in the file:
#	ap-config.sh
# They were moved there because dependent script "packages.sh" must execute BEFORE
# "ap-config.sh" to install "sipcalc" which used in those variables for ip calculations

# "scripts" seemed a sensible enough name for the root users scripts directory but the name is arbitrary and can be set to some other name:
PATHSCRIPTSROOT='scripts'
PATHSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)"
PATHLOGSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)/logs"

WIFIREGULATORYDOMAIN=$(curl --silent ipinfo.io|grep country|awk '{print $2}'|grep -oE [Aa-Zz][Aa-Zz])
