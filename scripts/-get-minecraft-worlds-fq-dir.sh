#!/bin/bash

# This script will return the base directory for Minecraft worlds. The base
# directory is different depending on whether the script is running on WSL or not.
# Also, if the directory does not exist, it will be created.
#
# USAGE:    bash -get-minecraft-worlds-fq-dir.sh
# EXAMPLE:  bash -get-minecraft-worlds-fq-dir.sh
# PRE-REQS: none
#

BASE_WORLD_DIR_ON_WSL=/mnt/c/data/mc/worlds
BASE_WORLD_DIR_ON_LINUX=/data/mc/worlds

# determine if we are running on WSL or not
if [ -d /mnt/c/users ]; then
  export WORLDS_DIR=$BASE_WORLD_DIR_ON_WSL
else
  export WORLDS_DIR=$BASE_WORLD_DIR_ON_LINUX
fi

# create the directory if it does not exist
if [ ! -d $WORLDS_DIR ]; then
  mkdir -p $WORLDS_DIR
fi

# output the directory
echo $WORLDS_DIR
