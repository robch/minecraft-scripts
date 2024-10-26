#!/bin/bash

# This script will update the Minecraft world to the specified version.
#
# USAGE:    81-update-minecraft-world-paper-version.sh [world] [version] [build]
# EXAMPLE:  81-update-minecraft-world-paper-version.sh World1 1.21 130
#

source $(dirname $0)/-functions.sh
mc_world_update_paper_version "$1" "$2" "$3"
