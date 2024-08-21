#!/bin/bash

# This script will check the status of the Minecraft server for the specified slot.
#
# USAGE:    23-check-service-status.sh [slot]
# EXAMPLE:  23-check-service-status.sh 1
#

source $(dirname $0)/-functions.sh

SLOT=$(mc_get_slot_or_default $1)
SERVICE_NAME=$(mc_get_service_base_file_name $SLOT)

# check the service status
echo "Checking service status: $SERVICE_NAME ..."
STATUS=$(systemctl status $SERVICE_NAME)
echo "$STATUS"
