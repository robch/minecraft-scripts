#!/bin/bash

# This script will start the Minecraft server for the specified slot and world.
#
# USAGE:    bash 10-start-minecraft-server.sh [world] [slot] 
# EXAMPLE:  bash 10-start-minecraft-server.sh World1 1
#
# PRE-REQS:
# 00-download-install-jdk21.sh
#

THIS_DIR=$(dirname $0)
WORLD_FQ_DIR=$(bash $THIS_DIR/-get-minecraft-world-fq-dir.sh $1)
JAR_FQ_FILE=$(bash $THIS_DIR/-get-paper-mc-jar-fq-file.sh $1)
WORLD=$(basename $WORLD_FQ_DIR)

# ensure the jar file exists
if [ ! -f $JAR_FQ_FILE ]; then
  echo -e "\e[31mERROR: The server jar file does not exist for $WORLD.\e[0m"
  ./01-download-paper-server.sh $WORLD
  ./02-accept-minecrat-eula.sh $WORLD
fi

# start the server
cd $WORLD_FQ_DIR
echo -e "\e[32mStarting Minecraft server for $2 ...\e[0m"
java -Xms4096M -Xmx4096M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar $JAR_FQ_FILE nogui
