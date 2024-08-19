#!/bin/bash

# This script will return the directory for the specified Minecraft world. This
# directory is different depending on whether the script is running on WSL or not.
# Also, if the directory does not exist, it will be created.
#
# USAGE:    bash -get-minecraft-world-fq-dir.sh [world]
# EXAMPLE:  bash -get-minecraft-world-fq-dir.sh World1
# PRE-REQS: none
#

DEFAULT_MC_WORLD=World1
THIS_DIR=$(dirname $0)
WORLDS_FQ_DIR=$($THIS_DIR/-get-minecraft-worlds-fq-dir.sh)

# if world parameter is not set, use the default
if [ -z "$1" ]; then
  export MC_WORLD=$DEFAULT_MC_WORLD
else
  export MC_WORLD=$1
fi

# set the world directory
WORLD_DIR=$WORLDS_FQ_DIR/$MC_WORLD

# create the directory if it does not exist
if [ ! -d $WORLD_DIR ]; then
  mkdir -p $WORLD_DIR
fi

# output the directory
echo $WORLD_DIR
