#!/bin/bash

# This script will download the PaperMC server jar file for the specified world.
#
# USAGE:    bash 01-download-paper-server.sh [world] [version] [build]
# EXAMPLE:  bash 01-download-paper-server.sh World1 1.21 130
# PRE-REQS: none

THIS_DIR=$(dirname $0)
WORLD_FQ_DIR=$(bash $THIS_DIR/-get-minecraft-world-fq-dir.sh $1)
WORLD=$(basename $WORLD_FQ_DIR)

JAR_URL=$(bash $THIS_DIR/-get-paper-mc-jar-url.sh $2 $3)
JAR_FQ_FILE=$(bash $THIS_DIR/-get-paper-mc-jar-fq-file.sh $WORLD)

# download the PaperMC server jar file
echo "Downloading PaperMC"
echo
echo "  FROM: $JAR_URL"
echo "    TO: $JAR_FQ_FILE"
echo

curl -J -L $JAR_URL -o $JAR_FQ_FILE

# check to make sure it's at least 1 mega byte
if [ $(stat -c%s $JAR_FQ_FILE) -lt 1000000 ]; then
  echo -e "\e[31mDownload failed. File is too small.\e[0m"
  echo -e "\e[31mCheck the version and build number and try again.\e[0m"
  echo -e "\e[31mCheck https://papermc.io/downloads/paper for the latest version and build number.\e[0m"
  exit 1
fi

# show success message
LS_FILE=$(ls -l $JAR_FQ_FILE)
echo 
echo -e "\e[32m**************\e[0m"
echo -e "\e[32m* DOWNLOADED *   $LS_FILE\e[0m"
echo -e "\e[32m**************\e[0m"
echo 

# we're ready to run!
WORLD_NAME=$($THIS_DIR/04-get-world-name.sh $WORLD)
echo -e "\e[32m**************\e[0m"
echo -e "\e[32m* RUN READY  *   $WORLD_NAME\e[0m"
echo -e "\e[32m**************\e[0m"
echo