#!/bin/bash

# This script will accept the Minecraft EULA for the specified world.
#
# USAGE:    bash 02-accept-minecrat-eula.sh [world]
# EXAMPLE:  bash 02-accept-minecrat-eula.sh World1
# PRE-REQS: none
#

source $(dirname $0)/-functions.sh
mc_accept_eula "$1"