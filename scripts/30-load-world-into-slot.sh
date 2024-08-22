#!/bin/bash

# This script will load an existing world into the specified slot.
#
# USAGE:    30-load-world-into-slot.sh [world] [slot]
# EXAMPLE:  30-load-world-into-slot.sh World1 1
#

source $(dirname $0)/-functions.sh

WORLD=$(mc_world_name_get_or_default $1)
SLOT=$(mc_service_slot_get_or_default $2)
SERVICE_NAME=$(mc_service_slot_name_get $SLOT)

# stop the previous service
echo "Stopping previous service $SERVICE_NAME ..."
sudo systemctl stop $SERVICE_NAME
echo "Stopping previous service ... Done!"
echo

# create the service file
echo "Updating service for world: $WORLD, slot: $SLOT ..."

SERVICE_FILE=$(mc_world_service_slot_file_create $WORLD $SLOT)
SERVICE_NAME=$(basename $SERVICE_FILE)

echo "Updating service for world: $WORLD, slot: $SLOT ... Done!"
echo
echo "  File: $SERVICE_FILE"
echo "  Name: $SERVICE_NAME"
echo

# reload the systemd daemon
echo "Reloading systemd daemon ..."
sudo systemctl daemon-reload
echo "Reloading systemd daemon ... Done!"
echo

# enable the service
echo "Enabling service ..."
sudo systemctl enable $SERVICE_NAME
echo "Enabling service ... Done!"

# start the service
echo "Starting service ..."
sudo systemctl start $SERVICE_NAME
echo "Starting service ... Done!"

# check the service status
echo "Checking service status ..."
STATUS=$(systemctl status $SERVICE_NAME)
echo "$STATUS"