#!/bin/bash

# This script will create a new minecraft world
#
# USAGE:    11-create-minecraft-world.sh [world]
# EXAMPLE:  11-create-minecraft-world.sh my-world
#

source $(dirname $0)/-functions.sh
mc_world_create $1
