#!/bin/bash

# This script will download the PaperMC server jar file for the specified world.
#
# USAGE:    bash 01-download-paper-server.sh [world] [version] [build]
# EXAMPLE:  bash 01-download-paper-server.sh World1 1.21 130
# PRE-REQS: none

source $(dirname $0)/-functions.sh
mc_paper_java_jar_download "$1" "$2" "$3"