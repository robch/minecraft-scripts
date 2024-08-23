#!/bin/bash

# This script will stop the Minecraft server for the specified slot.
#
# USAGE:    22-stop-service.sh [slot]
# EXAMPLE:  22-stop-service.sh 1
#

source $(dirname $0)/-functions.sh

SLOT=$(mc_service_slot_get_or_default $1)
SERVICE_NAME=$(mc_service_slot_name_get $SLOT)

# stop the service
echo "Stopping service: $SERVICE_NAME ..."
sudo systemctl stop $SERVICE_NAME
echo "Stopping service: $SERVICE_NAME ... Done!"
