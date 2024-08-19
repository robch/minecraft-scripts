#!/bin/bash

# This script will download and install the Microsoft OpenJDK 21 for Ubuntu.
#
# USAGE:    bash 00-download-install-jdk21.sh
# EXAMPLE:  bash 00-download-install-jdk21.sh
# PRE-REQS: none
#

# update the package list
UBUNTU_RELEASE=`lsb_release -rs`
wget https://packages.microsoft.com/config/ubuntu/${UBUNTU_RELEASE}/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# install the Microsoft OpenJDK 21
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install msopenjdk-21

# set the default Java version to Microsoft OpenJDK 21
sudo update-java-alternatives --set msopenjdk-21-amd64

# check to make sure it is installed
VERSION=$(java --version)

# Check that the default Java version is Microsoft OpenJDK 21
if [[ $VERSION == *"OpenJDK"* && $VERSION == *"64-Bit"* && $VERSION == *"Microsoft"* && $VERSION == *"21"* ]]; then
  echo -e "\e[32mMicrosoft OpenJDK 21 installed successfully.\e[0m"
else
  echo -e "\e[31mMicrosoft OpenJDK 21 did not install successfully.\e[0m"
  exit 1
fi
