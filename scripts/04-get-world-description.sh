#!/bin/bash

# This script will get the name of the Minecraft world.
#
# USAGE:    bash 04-get-world-name.sh world
# EXAMPLE:  bash 04-get-world-name.sh World1
# PRE-REQS: none
#

source $(dirname $0)/-functions.sh
mc_world_description_get_or_default "$1"
