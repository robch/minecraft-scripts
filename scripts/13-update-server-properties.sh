#!/bin/bash

# This script will update the server.properties file
#
# USAGE:    13-update-server-properties.sh [world] [slot]
# EXAMPLE:  13-update-server-properties.sh World1 1
#

source $(dirname $0)/-functions.sh
mc_world_server_properties_update "$1" "$2"
