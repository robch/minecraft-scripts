#!/bin/bash

# This script will start the Minecraft server for the specified slot and world.
#
# USAGE:    bash 10-start-minecraft-server.sh [world]
# EXAMPLE:  bash 10-start-minecraft-server.sh World1
#
# PRE-REQS:
# 00-download-install-jdk21.sh
#

source $(dirname $0)/-functions.sh

THIS_DIR=$(dirname $0)
WORLD=$(mc_get_world_basename_or_default $1)
WORLD_FQ_DIR=$(mc_get_world_fq_dir $WORLD)
JAR_FQ_FILE=$(mc_get_world_paper_server_jar_fq_filename $WORLD)

# ensure the jar file exists
if [ ! -f $JAR_FQ_FILE ]; then
  # IN YELLOW
  echo -e "\e[33mWARNING: The server jar file does not exist for $WORLD.\e[0m"
  echo
  $THIS_DIR/01-download-paper-server.sh "$WORLD"
  $THIS_DIR/02-accept-minecraft-eula.sh "$WORLD"
  $THIS_DIR/03-set-world-description.sh "$WORLD" "$2"
fi
