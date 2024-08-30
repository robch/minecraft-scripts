#!/bin/bash

# This script will check the status of the Minecraft server for the specified slot.
#
# USAGE:    23-check-service-status.sh [slot]
# EXAMPLE:  23-check-service-status.sh 1
#

source $(dirname $0)/-functions.sh
mc_service_slot_check $1
