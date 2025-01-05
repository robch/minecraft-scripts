#!/bin/bash

# This script will start the specified world in the specified slot.
#
# USAGE:    90-start-world-in-slot.sh [world] [slot]
# EXAMPLE:  90-start-world-in-slot.sh World1 1
#

source $(dirname $0)/_functions.sh
mc_world_start_in_slot "$1" "$2"
