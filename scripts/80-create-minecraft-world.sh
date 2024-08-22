#!/bin/bash

# This script will create a new Minecraft world.
#
# USAGE:    80-create-minecraft-world.sh [world] [description] [version] [build]
# EXAMPLE:  80-create-minecraft-world.sh World1 "My first world" 1.21 130
#

source $(dirname $0)/-functions.sh
mc_world_create $1 "$2" "$3" "$4"
