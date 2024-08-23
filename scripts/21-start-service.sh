#!/bin/bash

# This script will start the Minecraft server for the specified slot.
#
# USAGE:    21-start-service.sh [slot]
# EXAMPLE:  21-start-service.sh 1
#

source $(dirname $0)/-functions.sh

SLOT=$(mc_service_slot_get_or_default $1)
SERVICE_NAME=$(mc_service_slot_name_get $SLOT)

# start the service
echo "Starting service: $SERVICE_NAME ..."
sudo systemctl start $SERVICE_NAME
echo "Starting service: $SERVICE_NAME ... Done!"
