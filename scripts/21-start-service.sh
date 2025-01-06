#!/bin/bash

# This script will start the Minecraft server for the specified slot.
#
# USAGE:    21-start-service.sh [slot]
# EXAMPLE:  21-start-service.sh 1
#

source $(dirname $0)/_functions.sh
mc_service_slot_start $1
