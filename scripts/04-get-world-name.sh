#!/bin/bash

# This script will get the name of the Minecraft world.
#
# USAGE:    bash 04-get-world-name.sh world
# EXAMPLE:  bash 04-get-world-name.sh World1
# PRE-REQS: none
#

THIS_DIR=$(dirname $0)
NAME_FQ_FILE=$(bash $THIS_DIR/-get-minecraft-world-fq-name-file.sh $1)
DEFAULT_WORLD_NAME=$(basename $(dirname $NAME_FQ_FILE))

# if the file does not exist, return an error
if [ ! -f $NAME_FQ_FILE ]; then
  echo $DEFAULT_WORLD_NAME > $NAME_FQ_FILE
fi

# read and return the name of the world
WORLD_NAME=$(cat $NAME_FQ_FILE)
echo $WORLD_NAME
