#!/bin/bash

# This script will get the world name for the specified slot
#
# USAGE:    24-get-service-world-name.sh [slot]
# EXAMPLE:  24-get-service-world-name.sh 1
#

source $(dirname $0)/_functions.sh
mc_service_slot_world_name_get_or_default $1
