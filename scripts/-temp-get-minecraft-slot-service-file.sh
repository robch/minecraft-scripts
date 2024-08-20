#!/bin/bash

# This script will return the contents of the "minecraft.service" file for
# the specified slot.
#
# USAGE:    bash -get-minecraft-slot-service-file.sh [slot]
# EXAMPLE:  bash -get-minecraft-slot-service-file.sh 1
# PRE-REQS: none
#

DEFAULT_MC_SLOT=1
THIS_DIR=$(dirname $0)
MC_USER=$($THIS_DIR/-get-mc-user-name.sh)
WORLD_FQ_PATH=$($THIS_DIR/-get-minecraft-world-fq-dir.sh $1)


# if parameter is not set, set it to the default
if [ -z "$1" ]; then
  export SERVER_SLOT=$DEFAULT_MC_SLOT
else
  export SERVER_SLOT=$1
fi

# output the service file
cat <<EOF
# minecraft.service

[Unit]
Description=minecraft-slot-$SERVER_SLOT.service
After=network.target

[Service]
ExecStart=/mnt/c/data/java21/jdk-21.0.3+9/bin/java -Dlog4j2.formatMsgNoLookups=true -Xms4G -Xmx4G -jar /mnt/c/data/mc/1/paper-1.21-46.jar
WorkingDirectory=$WORLD_FQ_PATH
Restart=always
RestartSec=10
User=mcuser$MC_USER

[Install]
WantedBy=multi-user.target

EOF
