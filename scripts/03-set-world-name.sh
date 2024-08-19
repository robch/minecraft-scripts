#!/bin/bash

# This script will set the name of the Minecraft world.
#
# USAGE:    bash 04-set-world-name.sh [world] "Name of World"
# EXAMPLE:  bash 04-set-world-name.sh World1 "My World"
# PRE-REQS: none
#

THIS_DIR=$(dirname $0)
DEFAULT_WORLD=$(basename $($THIS_DIR/-get-minecraft-world-fq-dir.sh))

# if there are 3 or more parameters, that's an error
if [ ! -z "$3" ]; then
  echo -e "\e[31mERROR: Too many parameters.\e[0m"
  exit 1
fi

# if there's 2 parameters, first one is the world, and the 2nd is the name
if [ ! -z "$2" ]; then
  WORLD=$1
  NAME=$2
fi

# if there's 1 parameter, it's the name of the world
if [ -z "$2" ]; then
  NAME=$1
  WORLD=$DEFAULT_WORLD
fi

# if there's no parameters, that's an error
if [ -z "$1" ]; then
  echo -e "\e[31mERROR: Name of world not specified.\e[0m"
  exit 1
fi

# get the full path to the world name file
NAME_FQ_FILE=$(bash $THIS_DIR/-get-minecraft-world-fq-name-file.sh $WORLD)

# set the name of the world
echo $NAME > $NAME_FQ_FILE
cat $NAME_FQ_FILE
