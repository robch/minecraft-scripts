#!/bin/bash

# This script will accept the Minecraft EULA for the specified world.
#
# USAGE:    bash 02-accept-minecrat-eula.sh [world]
# EXAMPLE:  bash 02-accept-minecrat-eula.sh World1
# PRE-REQS: none
#

THIS_DIR=$(dirname $0)
WORLD_FQ_DIR=$(bash $THIS_DIR/-get-minecraft-world-fq-dir.sh $1)
WORLD=$(basename $WORLD_FQ_DIR)

# change to the world directory
cd $WORLD_FQ_DIR

# if there is no eula.txt file, create one
if [ ! -f eula.txt ]; then
  echo "eula=false" > eula.txt
fi

# replace the eula=false with eula=true
sed -i 's/eula=false/eula=true/g' eula.txt

# verify the eula.txt file
EULA_CONTENTS=$(cat eula.txt)
if [[ $EULA_CONTENTS == *"eula=true"* ]]; then
  echo -e "\e[32mEULA accepted for $WORLD.\e[0m"
else
  echo -e "\e[31mEULA not accepted.\e[0m"
  exit 1
fi
