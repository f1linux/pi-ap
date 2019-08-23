#!/bin/bash

#set -x

# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point
# Source:	https://github.com/f1linux/pi-ap
# Version:	01.05.01
# License:	GPL 3.0

# Script Author:        Terrence Houlahan Linux & Network Engineer
# Contact:              houlahan@F1Linux.com
# Linkedin:				www.linkedin.com/in/terrencehoulahan


USEREXECUTINGSCRIPT='pi'
REPONAME='pi-ap'

OURHOSTNAME='3bplus-ap1'
OURDOMAIN='f1linux.com'


### AP Variables:

# The DHCP Pool will be derived from the IP and mask specified in "IPV4IPWLAN0" below. If you require a bigger pool than use a mask large than a /28
# ** Ensure that this subnet specified below is not already used on your network **
IPV4IPWLAN0='192.168.0.1/28'
#IPV6IPWLAN0="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

# nameservers WiFi clients are assigned by dnsmasq:
DNSRESOLVER1WIFICLIENTS='8.8.8.8'
DNSRESOLVER2WIFICLIENTS='8.8.4.4'


# NOTE: Both Hyphens and underscores are valid characters for use in an SSID
SSIDNAME='RPI-AP1'
WIFIREGULATORYDOMAIN='GB'
# Password must be min 8 characters and must NOT include single quotes- these are used as delimiters to encase the password so other special characters do not expand in bash
APWPA2PASSWD='cH4nG3M3'

# MACADDRACL restricts AP authentication to only hosts with their WiFi interface mac address listed in "hostapd.accept"
# "0" = DISABLE (password auth only)
# "1" = ENABLE (password *AND* Mac Address in "hostapd.accept" to authenticate to AP)
MACADDRACL='0'

# Set channel to a non-overlapping channel where possible: 1/6/11 .  If a non-overlapping channel is saturated try the next one before using overlapping channels. 
CHANNEL='6'

# NOTE: Only Pi3B+ and later models feature hardware support for 802.11ac
# '0'= Disabled  - '1'=Enabled
MODE80211AC='0'

# Operation Mode:
# a   = IEEE 802.11a (5 GHz)
# b   = IEEE 802.11b (2.4 GHz)
# g   = IEEE 802.11g (2.4 GHz). For IEEE 802.11ac (VHT) set to hw_mode=g
# ad  = IEEE 802.11ad (60 GHz); a/g options are used with IEEE 802.11n (HT), too, to specify band)
# any = used to indicate that any support band can be used.  Currently supported only with drivers with which offloaded ACS is used.
# Default: IEEE 802.11b
# NOTICE: If enabling MODE80211AC then "HWMODE" MUST be set to a value of "a"
HWMODE='g'


# Interfaces are aliased for 2 reasons:
# A. Illustrate the interfaces function within the configuration and
# B. Interface names might be unpredictable in the future as has happened with other distros.
INTERFACEAP='wlan0'
# Below variable used in "firewall_ipv4.sh" script
INTERFACEMASQUERADED='eth0'

# DNS Resolvers: These are specified in for the Pi host itself (not WiFi clients) in /etc/systemd/resolved.conf
DNSRESOLVERIPV41='8.8.8.8'
DNSRESOLVERIPV42='8.8.4.4'
DNSRESOLVERIPV61='2001:4860:4860::8888'
DNSRESOLVERIPV62='2001:4860:4860::8844'


### dhcpcd.conf Variables
# default: 12h
DHCPLEASETIMEHOURS='12'


# BELOW ARE SELF-POPULATING: They require no user input or modification
#######################################################################
### PLEASE NOTE: ###
# Although MOST variables are centralized in this file be aware
# that a subset of self-populating variables live in the file:
# 	ap-config.sh
# They were moved there because the dependent script "packages.sh" must execute BEFORE
# "ap-config.sh" to install "sipcalc" which is used in those variables for ip calculations
PATHSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)"
PATHLOGSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)/logs"

# Below three variables can be used to specify the subnetting of the eth0 interface in UFW rules or elsewhere
IPV4IPETH0="$(ip addr list|grep 'eth0'|awk 'FNR==2'|awk '{print $2}')"
IPV4SUBNETETH0="$(sipcalc $IPV4IPETH0|awk 'FNR==7'|awk '{print $4}')"
IPV4SUBNETMASKETH0="$(sipcalc $IPV4IPETH0|awk 'FNR==9'|awk '{print $5}')"

# ie: the following would give you the subnet and mask of eth0 if you source this variables.sh file
#	$IPV4SUBNETETH0/$IPV4SUBNETMASKETH0

