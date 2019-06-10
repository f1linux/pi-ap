#!/bin/bash

USEREXECUTINGSCRIPT='pi'
REPONAME="pi-ap"

OURHOSTNAME='!cH4g3-mE!'
OURDOMAIN='f1linux.com'

APINTERFACE='wlan0'

# Below variables need to be restructured for auto-population
# Subnet to be masqueraded in the Pi NAT table:
SUBNETPI='192.168.3.54'
NETMASKPI='28'

# Below is subnetting for addressing and routing users connected to AP
SUBNETDHCP='192.168.0.0'
NETMASKDHCP='28'

# Used in dhcpcd.conf
ROUTER='192.168.3.62'
# dhcpcd.conf default: 12h
DHCPLEASETIMEHOURS='12'

# dhcpcd.conf default: 192.168.0.50,192.168.0.150
# .1-.14 is a /28 mask
DHCPRANGE='192.168.0.1,192.168.0.14'

### AP Variables:
SSIDNAME='BT99ABZ1'
WIFIREGULATORYDOMAIN='GB'
# Password must be min 8 characters and must NOT include single quotes- these are used as delimiters to encase the password so other special characters do not expand in bash
APWPA2PASSWD='cH4nG3-Me!''
# Set channel to a non-overlapping channel where possible: 1/6/11 .  If a non-overlapping channel is saturated try the next one before using overlapping channels. 
CHANNEL='6'


# Resolvers:
DNSRESOLVERIPV41="8.8.8.8"
DNSRESOLVERIPV42="8.8.4.4"
DNSRESOLVERIPV61="2001:4860:4860::8888"
DNSRESOLVERIPV62="2001:4860:4860::8844"


# BELOW ARE SELF-POPULATING: They require no user input
########################################################
PATHSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)"
PATHLOGSCRIPTS="/home/$(echo $USEREXECUTINGSCRIPT)/$(echo $REPONAME)/logs"

# Below sifts IP address for eth0 and strips trailing mask off end:
IPV4SERVERIPINT1="$(ip addr list|grep inet|grep -oE '[1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|awk 'FNR==2')"
IPV6SERVERIPINT1="$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1)"

export DEBIAN_FRONTEND=noninteractive
