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
WORLD=$(mc_world_name_get_or_default $1)
WORLD_FQ_DIR=$(mc_world_fq_dir_get_or_default $WORLD)
JAR_FQ_FILE=$(mc_world_java_jar_fq_filename_get_or_default $WORLD)

# ensure the jar file exists
if [ ! -f $JAR_FQ_FILE ]; then
  # IN YELLOW
  echo -e "\e[33mWARNING: The server jar file does not exist for $WORLD.\e[0m"
  echo
  $THIS_DIR/01-download-paper-server.sh "$1" "$2" "$3"
  $THIS_DIR/02-accept-minecraft-eula.sh "$1"
fi

# start the server
cd $WORLD_FQ_DIR
echo -e "\e[32m**************\e[0m"
echo -e "\e[32mStarting Minecraft server for $1 ...\e[0m"
echo -e "\e[32m**************\e[0m"
echo
java -Xms4096M -Xmx4096M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar $JAR_FQ_FILE nogui
