#!/bin/bash

# This script will check/copy the default files for a new world
#
# USAGE:    12-check-world-files.sh [world]
# EXAMPLE:  12-check-world-files.sh my-world
#

source $(dirname $0)/-functions.sh
mc_world_default_files_copy "$1"
