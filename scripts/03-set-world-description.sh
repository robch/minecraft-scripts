#!/bin/bash

# This script will set the name of the Minecraft world.
#
# USAGE:    bash 04-set-world-name.sh [world] "Name of World"
# EXAMPLE:  bash 04-set-world-name.sh World1 "My World"
# PRE-REQS: none
#

source $(dirname $0)/_functions.sh
mc_world_description_set "$1" "$2"