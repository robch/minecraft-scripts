#!/bin/bash

# This script will stop the Minecraft server for the specified slot.
#
# USAGE:    22-stop-service.sh [slot]
# EXAMPLE:  22-stop-service.sh 1
#

source $(dirname $0)/_functions.sh
mc_service_slot_stop $1
