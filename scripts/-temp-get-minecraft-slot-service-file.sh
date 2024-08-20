#!/bin/bash

# This script will return the contents of the "minecraft.service" file for
# the specified slot.
#
# USAGE:    bash -get-minecraft-slot-service-file.sh [world] [slot]
# EXAMPLE:  bash -get-minecraft-slot-service-file.sh World1 1
# PRE-REQS: none
#

source $(dirname $0)/-functions.sh

WORLD=$(mc_get_world_basename_or_default $1)
WORLD_FQ_DIR=$(mc_get_world_fq_dir $WORLD)
SERVER_SLOT=$(mc_get_slot_or_default $2)
JAR_FQ_FILE=$(mc_get_world_paper_server_jar_fq_filename $WORLD)
JAVA_DIR=$(dirname $(which java))

# if the world directory doesn't exist, error out
if [ ! -d $WORLD_FQ_DIR ]; then
  echo -e "\e[31mERROR: The world directory does not exist for $WORLD.\e[0m"
  exit 1
fi

# if the world isn't "registered" via mc_get_worlds
WORLDS=$(mc_get_worlds)
if [ -z "$(echo $WORLDS | grep $WORLD)" ]; then
  echo -e "\e[31mERROR: The world $WORLD has no description. Please set one.\e[0m"
  exit 1
fi

_=$(mc_set_world_description $WORLD)

# output the service file
cat <<EOF
# minecraft.service

[Unit]
Description=minecraft-slot-$SERVER_SLOT.service
After=network.target

[Service]
ExecStart=$JAVA_DIR -Xms4G -Xmx4G -jar $JAR_FQ_FILE
WorkingDirectory=$WORLD_FQ_DIR
Restart=always
RestartSec=10
User=mcuser$MC_USER

[Install]
WantedBy=multi-user.target

EOF
