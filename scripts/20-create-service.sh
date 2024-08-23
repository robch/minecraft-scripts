#!/bin/bash

# This script will create the Minecraft server service for the specified world and slot.
#
# USAGE:    20-create-service.sh [world] [slot]
# EXAMPLE:  20-create-service.sh World1 1
#

source $(dirname $0)/-functions.sh

WORLD=$(mc_world_name_get_or_default $1)
SLOT=$(mc_service_slot_get_or_default $2)

# create the service file
echo "Creating service for world: $WORLD, slot: $SLOT ..."

SERVICE_FILE=$(mc_world_service_slot_file_create $WORLD $SLOT)
SERVICE_NAME=$(basename $SERVICE_FILE)

echo "Creating service for world: $WORLD, slot: $SLOT ... Done!"
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