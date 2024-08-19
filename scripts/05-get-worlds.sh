#!/bin/bash

# This script will get the name of the Minecraft world.
#
# USAGE:    bash 04-get-world-name.sh world
# EXAMPLE:  bash 04-get-world-name.sh World1
# PRE-REQS: none
#

THIS_DIR=$(dirname $0)
WORLDS_FQ_DIR=$($THIS_DIR/-get-minecraft-worlds-fq-dir.sh $1)

WORLDS=$(find $WORLDS_FQ_DIR -type f -name "world-name.txt")
if [ ! -z "$WORLDS" ]; then
  for WORLD in $WORLDS; do
    echo "$(basename $(dirname $WORLD))"
  done
fi
