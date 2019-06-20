#!/bin/bash

# Version 01.00.00

# Script Author:        Terrence Houlahan
# Contact:              houlahan@F1Linux.com

# Do not edit below sources
source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/functions.sh"


echo
echo "$(tput setaf 5)******  PACKAGES: Remove conflicting packages or bloatware from default Raspbian image  ******$(tput sgr 0)"
echo

# usbmount: interferes with SystemD auto-mounts which we will use for the USB Flash Drive where video and images are written locally to
# libreoffice: it is just crap and not required on a device being used as a video camera

echo
echo "Removing packages listed in packages-list-purge.txt"
echo
readarray arrayPackagesListPURGE < $PATHSCRIPTS/packages-list-purge.txt

for i in ${arrayPackagesListPURGE[@]}; do
if [[ ! $(dpkg -l | grep "^ii  $i[[:space:]]") = '' ]]; then
	apt-get -y purge $i
	echo "Removed package $i"
else
	echo "Package $i not present on system"
fi
done



echo
echo "$(tput setaf 5)******  PACKAGES: Re-Sync Index:  ******$(tput sgr 0)"
echo

until apt-get -y update
	do
		echo
		echo "$(tput setaf 5)apt-get update failed. Retrying$(tput sgr 0)"
		echo "$(tput setaf 3)Check Internet Connection$(tput sgr 0)"
		echo
	done

echo 'Package Index Updated'
echo



echo
echo "$(tput setaf 5)******  Install Packages:  ******$(tput sgr 0)"
echo

# For info about a particular package in the list of packages to be installed in packages-list-install.txt:
#	sudo apt-cache show packagename

# Package debconf-utils must be installed separately and FIRST before mass package installation occurs:
# If a subsequent package tries to open a dialog requiring user input and debconf-utils has not been installed
# it will break unattended installation by pausing script for user input.  Very bad.

if [[ $(dpkg -l | grep "^ii  debconf-utils[[:space:]]") = '' ]]; then
	until apt-get -y install debconf-utils
	do
		echo
		echo "Package $(tput setaf 3)$i $(tput sgr 0)not found"
		echo
		echo "Skipping to next package in packages-list-install.txt"
		echo
		break
	done
elif [[ $(dpkg -l | grep "^ii  debconf-utils[[:space:]]") =  $(dpkg -l | grep "^ii  debconf-utils[[:space:]]") ]]; then
	echo "Package debconf-utils already installed"
fi

export DEBIAN_FRONTEND=noninteractive



readarray arrayPackagesListInstall < $PATHSCRIPTS/packages-list-install.txt

for i in ${arrayPackagesListInstall[@]}; do
if [[ $(dpkg -l | grep "^ii  $i[[:space:]]") = '' ]]; then
	until apt-get -y install $i
	do
		echo
		echo "Package $(tput setaf 3)$i $(tput sgr 0)not found"
		echo
		echo "Skipping to next package in packages-list-install.txt"
		echo
		break
	done
elif [[ $(dpkg -l | grep "^ii  $i[[:space:]]") =  $(dpkg -l | grep "^ii  $i[[:space:]]") ]]; then
	echo "Package $i already installed"
fi
done



echo
echo "Updating the $(tput setaf 3)apt-file$(tput sgr 0) DB:"
echo
# Update apt-file DB with new packages installed so they can be searched with this utility:
$(command -v apt-file) update

echo "Updating the $(tput setaf 6)locate$(tput sgr 0) DB"

# Populate the *locate* DB:
$(command -v updatedb)
echo



echo
echo "$(tput setaf 5)******  Set Default Package Preferences:  ******$(tput sgr 0)"
echo


update-alternatives --set editor /usr/bin/vim.basic
