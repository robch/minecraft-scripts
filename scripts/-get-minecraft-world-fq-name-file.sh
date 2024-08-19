#!/bin/bash

# This script will return the fully qualified filename for a file that contains
# the name of the specified Minecraft world.
#
# USAGE:    bash -get-minecraft-world-fq-name-file.sh [world]
# EXAMPLE:  bash -get-minecraft-world-fq-name-file.sh World1
# PRE-REQS: none
#

THIS_DIR=$(dirname $0)
WORLD_FQ_DIR=$(bash $THIS_DIR/-get-minecraft-world-fq-dir.sh $1)
NAME_FILE=$WORLD_FQ_DIR/world-name.txt

echo $NAME_FILE
