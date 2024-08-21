#!/bin/bash

# This script will start the Minecraft server for the specified slot.
#
# USAGE:    21-start-service.sh [slot]
# EXAMPLE:  21-start-service.sh 1
#

source $(dirname $0)/-functions.sh

SLOT=$(mc_get_slot_or_default $1)
SERVICE_NAME=$(mc_get_service_base_file_name $SLOT)

# start the service
echo "Starting service: $SERVICE_NAME ..."
sudo systemctl start $SERVICE_NAME
echo "Starting service: $SERVICE_NAME ... Done!"
