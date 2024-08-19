#!/bin/bash

# This script will return the directory for the specified Minecraft server slot. This
# directory is different depending on whether the script is running on WSL or not. Also,
# if the directory does not exist, it will be created.
#
# USAGE:    bash -get-minecraft-slot-fq-dir.sh [slot]
# EXAMPLE:  bash -get-minecraft-slot-fq-dir.sh 1
# PRE-REQS: none
#

DEFAULT_MC_SLOT=1
BASE_SLOT_FQ_DIR_ON_WSL=/mnt/c/data/mc/slots
BASE_SLOT_FQ_DIR_ON_LINUX=/data/mc/slots

# if parameter is not set, set it to 1
if [ -z "$1" ]; then
  export SERVER_SLOT=$DEFAULT_MC_SLOT
else
  export SERVER_SLOT=$1
fi

# determine if we are running on WSL or not
if [ -d /mnt/c/users ]; then
  export SLOT_FQ_DIR=$BASE_SLOT_FQ_DIR_ON_WSL/$SERVER_SLOT
else
  export SLOT_FQ_DIR=$BASE_SLOT_FQ_DIR_ON_LINUX/$SERVER_SLOT
fi

# create the directory if it does not exist
if [ ! -d $SLOT_FQ_DIR ]; then
  mkdir -p $SLOT_FQ_DIR
fi

# output the directory
echo $SLOT_FQ_DIR
