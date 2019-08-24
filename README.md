\#

\# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point

\# Source:	https://github.com/f1linux/pi-ap

# Version:	01.06.00

\# License:	GPL 3.0

\# Script Author:        Terrence Houlahan Linux & Network Engineer

\# Contact:              houlahan@F1Linux.com

\# Linkedin:				www.linkedin.com/in/terrencehoulahan


# README CONTENTS:

1.  ABOUT "pi-ap"
2.  USE-CASES
3.  COMPATIBILITY
4.  FEATURES
5.  LICENSE
6.  HARDWARE REQUIREMENTS
7.  INSTALLATION
8.  CONNECTING TO AP
9.  TROUBLESHOOTING
10. USEFUL LINKS: 	Wiki & YouTube Channel


# 1. ABOUT "pi-ap":

"***pi-ap***" is a series of **bash scripts** that automates configuration of below standardized packages to transform a PI into a wireless Access Point ("AP"):

- ***hostapd***: Probably the most widely used package for creating an AP in Linux and a standard

- ***wpa_supplicant***: Client Authentication

- ***dhcpcd***: Interface management

- ***dnsmasq***: DHCP for connecting AP clients:  Assigns IPs and the DNS servers clients should use

Other host configuration is performed, but the foregoing are the key packages related to delivering the AP functionality


# 2. USE-CASES

***pi-ap*** is NOT meant to replace enterprise class AP systems which offer beefier hardware and joined-up management interfaces for building or campus deployments.
The obvious use cases for these scripts is:

- **Dead-Spot Coverage**: Individuals and small businesses with a few dead-spots in their WiFi coverage can use this solution

- **Event Coverage**: Connect a ***pi-ap*** to a long Ethernet cable out of a window into your back yard for hammock surfing :-)

- **Network Training**: An AP is a networking microcosm offering wide opportunities for teaching networking configuration & troubleshooting on inexpensive commodity hardware


# 3. COMPATIBILITY

These scripts have been tested on the following Pi models & OSs and found to work correctly:

- Pi 3B+:	Raspbian Stretch (2019-04-08) and Buster (2019-07-10)

- Pi 4:		Raspbian Buster (2019-07-10)


# 4. FEATURES

- **No Subnetting Required**: DHCP IP pool for connecting clients is automatically calculated from a single IP and mask you specify

- **Auto Config of WiFi Regulatory Zone**: This is derived from the Public IP you are NATing out from and ensures you cannot make an error setting it

- **MAC Address Restriction**: In addition to restricting by password you also have the ability to restrict by hardware address of connecting devices

- **Centralized Package Management**: Customize the package list by editing the list in "***packages-list-install.txt***"

- **Modular Design**: Configuration is broken down into scripts organized by taxonomy: ie FW, packages, Kernel, AP stuff, etc...

- **Crypto uses Hardware Random Number Generator ("RNG")**: Entropy generated via hardware RNG using ***rng-tools***

# 5. LICENSE

Terrence Houlahan developed "***pi-ap***" and opensources it under the terms of the GPL 3.0 License that is distributed with my repo source files

# 6. HARDWARE REQUIREMENTS

Pi Case:
---

**AVOID METAL CASES!!!** If you wrap a metal case around your Pi it is going to cause Layer 1 problems by impeding the signal.

Probably worth trying a few different cases of differing materials to see which gives you the best result in respect to signal performance.

**NON-POE**:
---

A long Ethernet cable, a Pi and a power supply are minimum requirements.

**HOWEVER**: Using an AP implies covering an area the antenna(s) of the router cannot itself reach.
At such a distance- probably greater than 40 feet- or any distance their is not a mains outlet to power the Pi,
using a single Ethernet cable for both **Data + Power** becomes more interesting.

**POE**:
---

POE gear I have had success with- YMMV- with my Pi applications is:

- **Ethernet Cable**: A Tripp Lite Cat6 24 AWG Ethernet Cable is suggested (for most use cases). Amazon sells them in various lengths & colours

- **POE Switch**: ZyXEL 8-Port GS1900-8HP-GB0102F switch. Also found on Amazon. Lots of features for a reasonable price

- **POE Hat or POE Splitter**:  Although most Pi vendors sell the POE ***Hat***, POE ***Splitters*** will be found on Amazon.

I discuss POE gear and perform a ***cost*** vs. ***benefit*** analysis at below link for those considering a POE implementation for their ***pi-ap***:

[choosing-a-pi4-power-supply](https://raspberrypi.stackexchange.com/questions/99983/choosing-a-pi4-power-supply/99986#99986)

# 7. INSTALLATION & CONFIGURATION:

**Hardware Configuration**:
---

- Connect the Pi's `eth0` port to a DHCP-enabled port in a router configured with Internet connection or a switch connected to this router.

NOTE: You can connect a "***pi-ap**" to some intermediate router but you will of course have to configure the routing so the Pi can reach the router with the Internet connection.

**Software Configuration**:
---

All the complex configuration is abstracted into a centralized variables file named "***variables.sh***". This file is sourced by all repo scripts.
Edit this file in ***nano*** to modify default values and execute ***install.sh***. All the other scripts are chained off of ***install.sh***
That it to achieve a working Pi AP

Either using a local or SSH connection to the Pi execute the following commands:

- a) `git clone https://github.com/f1linux/pi-ap`

- b) Change Default Pi Password! Open a terminal and execute `sudo su -` and `passwd pi`

- c) `cd pi-ap`

- d) `nano variables.sh`	# Modify default variable values. Most default values can be kept but change "APWPA2PASSWD" and if default WiFi subnet in "IPV4IPWLAN0='192.168.0.1/28' exists on your LAN set to a different subnet"

- e) `nano hostapd.accept`	# If variable "***MACADDRACL***" set to "1" then add MAC addresses of clients allowed to connect to ***pi-ap*** before executing script

- f) `sudo ./install.sh`	# Execute the install script which will call all the other scripts in the repo.

- g) `cd ..;rm -rf pi-ap`	# Optionally delete the repo after "***install.sh***" completes.

# 8. CONNECTING TO AP:

After setup completes, to connect to your new Pi Access Point:

- a) Find its SSID inWireless Networks and connect with the password you set in variable "APWPA2PASSWD" when modifying `variables.sh`

- ssh pi@192.168.0.1	# This is the default IP variable "IPV4IPWLAN0"

You're in.


# 9. TROUBLESHOOTING

A suggested _non-exhausitive_ list of things to investigate if ***pi-ap*** broken:

- ***sudo ufw status***: Check FW not disabled. Needs to be up or masquerading in NAT table breaks

- **Non-Metallic**: If using a case for your Pi, only use a **NON-METALLIC** one to avoid Layer 1 connectivity problems

- **Physical Positioning**: Is there anything that will impede or interfere with the radio?

- **FW In Front of Pi Not Blocking**: Look for restrictive rules on any FW's in front of the pi-ap

- ***ip addr list***: Check interfaces are all up. ***wlan0*** must be up to connect to AP. ***eth0*** must be up for AP traffic to reach Internet

- ***sudo systemctl status hostapd.service***: When ***hostapd*** is not happy, your AP will be down.

- ***sudo systemctl status wpa_supplicant.service***: When ***wpa_supplicant*** is not happy, clients cannot connect to AP.

- ***cat /proc/sys/kernel/random/entropy_avail***: Use this command to investigate insufficient entropy errors when checking ***wpa_supplicant*** status

- ***tail -fn 100 /var/log/syslog***: Review syslog for any interesting errors to investigate

- **No Clashing Subnets**: Variable "***IPV4IPWLAN0***" in ***variables.sh*** is used to setup the AP interface & create IP pool to assign addresses to connecting clients. Ensure "***IPV4IPWLAN0***" does not clash with any existing subnets


# 10. USEFUL LINKS:

[Pi-AP YouTube Channel: F1Linux](www.YouTube.com/user/LinuxEngineer)

[Pi-AP Wiki: Github](https://github.com/f1linux/pi-ap/wiki)



I think that about covers it.  Not a lot really to do to configure a Pi into a working Access Point with this pile of scripts...

Terrence Houlahan, Linux & Network Engineer F1Linux.com

[Linkedin: Terrence Houlahan](https://www.linkedin.com/in/terrencehoulahan)
