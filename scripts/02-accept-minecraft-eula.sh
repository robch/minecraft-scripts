#!/bin/bash

# This script will accept the Minecraft EULA for the specified world.
#
# USAGE:    bash 02-accept-minecrat-eula.sh [world]
# EXAMPLE:  bash 02-accept-minecrat-eula.sh World1
# PRE-REQS: none
#

source $(dirname $0)/_functions.sh
mc_world_eula_accept "$1"