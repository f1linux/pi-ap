\#

\# pi-ap:	These scripts configure a Raspberry Pi into a wireless Access Point

\# Source:	https://github.com/f1linux/pi-ap

# Version:	01.00.00

\# Script Author:        Terrence Houlahan Linux & Network Engineer

\# Contact:              houlahan@F1Linux.com


# README CONTENTS:
1.  ABOUT "pi-ap"
2.  USE-CASES
3.  COMPATIBILITY
4.  FEATURES
5.  LICENSE
6.  HARDWARE REQUIREMENTS
7.  INSTALLATION
8.  TROUBLESHOOTING
9.  USEFUL LINKS


# 1. ABOUT "pi-ap":
"***pi-ap***" is a series of **bash scripts** that automates configuration of standardized packages to transform a PI into a wireless Access Point ("AP")

- ***hostapd***: Probably the most widely used package for creating an AP in Linux and a standard

- ***wpa_supplicant***: Client Authentication

- ***dhcpcd***: Interface management

- ***dnsmasq***: DHCP for connecting AP clients

Other host configuration is performed, but the foregoing are the key packages related to delivering the AP functionality


# 2. USE-CASES
***pi-ap*** is NOT meant to replace enterprise class AP systems which offer beefier hardware and joined-up management interfaces for building or campus deployments.
The obvious use cases for these scripts is:

- **Dead-Spot Coverage**: Individuals and small businesses with a few dead-spots in their WiFi coverage can use this solution

- **Event Coverage**: Run a ***pi-ap*** out of a window into your back yard for hammock surfing ;-)

- **Network Training**: An AP is a networking microcosm offering wide opportunities for teaching networking configuration & troubleshooting on inexpensive commodity hardware


# 3. COMPATIBILITY
These scripts have been tested on the following Pi models & OSs and found to work correctly:

- Pi 3B+ Running Raspbian Stretch


# 4. FEATURES

- **No Subnetting Required**: DHCP IP pool for connecting clients is automatically calculated from a single IP and mask you specify

- **MAC Address Restriction**: In addition to restricting by password you also have the ability to restrict by hardware address of connecting devices

- **Centralized Package Management**: Customize the package list by editing the list in "***packages-list-install.txt***"

- **Modular Design**: Configuration is broken down into scripts organized by taxonomy: ie FW, packages, Kernel, AP stuff, etc...

- **Crypto uses Hardware Random Number Generator ("RNG")**: Entropy generated via hardware RNG using ***rng-tools***

# 5. LICENSE
Terrence Houlahan developed "***pi-ap***" and opensources it under the terms of the GPL 3.0 License that is distributed with my repo source files

# 6. HARDWARE REQUIREMENTS
**NON-POE**:
--
A long Ethernet cable, a Pi and a power supply are the minimum requirements.

**HOWEVER**: Using an AP implies covering an area the antenna(s) of the router cannot itself reach.
At such a distance- probably greater than 40 feet- or any distance their is not a mains outlet to power the Pi,
using a single Ethernet cable for both **Data + Power** becomes more interesting.

**POE**:
--
POE gear I have had success with- YMMV- with my Pi applications is

- **Ethernet Cable**: A Tripp Lite Cat6 24 AWG Ethernet Cable is suggested (for most use cases). Amazon sells them in various lengths & colours

- **POE Switch**: ZyXEL 8-Port GS1900-8HP-GB0102F switch. Also found on Amazon. Lots of features for a reasonable price

- **POE Hat or POE Splitter**:  Although most Pi vendors sell the POE ***Hat***, POE ***Splitters*** will be found on Amazon.

I discuss POE gear and perform a ***cost*** vs. ***benefit*** analysis at below link for those considering a POE implementation for their ***pi-ap***:

[choosing-a-pi4-power-supply](https://raspberrypi.stackexchange.com/questions/99983/choosing-a-pi4-power-supply/99986#99986)

# 7. INSTALLATION & Configuration:

**Hardware Configuration**:

- Connect the Pi to a DHCP-enabled Ethernet port in router configured with Internet connection or a switch connected to this router

**Software Configuration**:
All the complex configuration is abstracted into a centralized variables file named "***variables.sh***". This file is sourced by all repo scripts.
Edit this file in ***nano*** to modify default values and execute ***install.sh***. All the other scripts are chained off of ***install.sh***
That it to achieve a working Pi AP

Either using a local or SSH connection to the Pi execute the following commands:

- a) `git clone https://github.com/f1linux/pi-ap`

- b) `cd pi-ap`

- c) `nano variables.sh`	# Modify default values for variables

- d) `nano hostapd.accept`	# If variable "***MACADDRACL***" set to "1" then add MAC addresses of clients allowed to connect to ***pi-ap*** before executing script

- e) `sudo ./install.sh`	# Execute the install script which will call all the other scripts in the repo.

- f) `cd ..;rm -rf pi-ap`	# Optionally delete the repo after "***install.sh***" completes. 

# 8. TROUBLESHOOTING
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


# 9. USEFUL LINKS


Well, I think that about covers it...
