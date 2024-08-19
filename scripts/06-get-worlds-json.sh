#!/bin/bash

# This script will get the name of the Minecraft world.
#
# USAGE:    bash 04-get-world-name.sh world
# EXAMPLE:  bash 04-get-world-name.sh World1
# PRE-REQS: none
#

THIS_DIR=$(dirname $0)
WORLDS_FQ_DIR=$($THIS_DIR/-get-minecraft-worlds-fq-dir.sh $1)

WORLD_NAME_FILES=$(find $WORLDS_FQ_DIR -type f -name "world-name.txt")
if [ ! -z "$WORLD_NAME_FILES" ]; then
  echo "["
  first_entry=true
  for WORLD_NAME_FILE in $WORLD_NAME_FILES; do
    if [ "$first_entry" = true ]; then
      first_entry=false
    else
      echo ","
    fi
    WORLD_NAME=$(cat $WORLD_NAME_FILE)
    WORLD_FQ_DIR=$(dirname $WORLD_NAME_FILE)
    WORLD=$(basename $WORLD_FQ_DIR)
    echo -n "  {\"Name\": \"$WORLD\", \"Description\": \"$WORLD_NAME\", \"Directory\": \"$WORLD_FQ_DIR\", \"Version\": \"1.21\" }"
  done
  echo
  echo "]"
fi
