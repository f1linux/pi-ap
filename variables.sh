#!/bin/bash

USEREXECUTINGSCRIPT='pi'
REPONAME='pi-ap'

OURHOSTNAME='3bplus-ap1'
OURDOMAIN='f1linux.com'


### AP Variables:
SSIDNAME='BT99ABZ1'
WIFIREGULATORYDOMAIN='GB'
# Password must be min 8 characters and must NOT include single quotes- these are used as delimiters to encase the password so other special characters do not expand in bash
APWPA2PASSWD='cH4nG3M3'

# MACADDRACL restricts AP auth to only hosts with their WiFi interface mac address in "hostapd.accept"
# "0" = DISABLE (password auth only)
# "1" = ENABLE (password *AND* Mac Address in "hostapd.accept" to authenticate to AP)
MACADDRACL='1'

# Set channel to a non-overlapping channel where possible: 1/6/11 .  If a non-overlapping channel is saturated try the next one before using overlapping channels. 
CHANNEL='6'

# Operation Mode:
# a   = IEEE 802.11a (5 GHz)
# b   = IEEE 802.11b (2.4 GHz)
# g   = IEEE 802.11g (2.4 GHz). For IEEE 802.11ac (VHT) set to hw_mode=g
# ad  = IEEE 802.11ad (60 GHz); a/g options are used with IEEE 802.11n (HT), too, to specify band)
# any = used to indicate that any support band can be used.  Currently supported only with drivers with which offloaded ACS is used.
# Default: IEEE 802.11b
HWMODE='g'


# Interfaces are aliased for 2 reasons:
# A. Illustrate the interfaces function within the configuration and
# B. Interface names might be unpredictable in the future as has happened with other distros.
INTERFACEAP='wlan0'
# Below variable used in "firewall_ipv4.sh" script
INTERFACEMASQUERADED='eth0'

# DNS Resolvers:
DNSRESOLVERIPV41='8.8.8.8'
DNSRESOLVERIPV42='8.8.4.4'
DNSRESOLVERIPV61='2001:4860:4860::8888'
DNSRESOLVERIPV62='2001:4860:4860::8844'


### dhcpcd.conf Variables
# default: 12h
DHCPLEASETIMEHOURS='12'


# BELOW ARE SELF-POPULATING: They require no user input or modification
#######################################################################
PATHSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)"
PATHLOGSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)/logs"

IPV4IPETH0="$(ip addr list|grep eth0|awk 'FNR==2'| awk '{print $2}')"
IPV4IPWLAN0="$(ip addr list|grep wlan0|awk 'FNR==2'| awk '{print $2}')"
IPV6IPWLA0="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

DHCPRANGESTART="$(sipcalc $IPV4IPWLAN0 | awk 'FNR==15'|awk '{print $4}')"
DHCPRANGEFINISH="$(sipcalc $IPV4IPWLAN0 |awk 'FNR==15'|awk '{print $6}')"
# dhcpcd.conf default: 192.168.0.50,192.168.0.150
DHCPRANGE="$DHCPRANGESTART,$DHCPRANGEFINISH"

export DEBIAN_FRONTEND=noninteractive
