#!/bin/bash

# This script will update the Minecraft world's description
#
# USAGE:    82-update-minecraft-description.sh [world] [description]
# EXAMPLE:  82-update-minecraft-description.sh World1 "My first world"
#

source $(dirname $0)/_functions.sh
mc_world_update_description "$1" "$2"
