#!/bin/bash

# This script will return the URL for the specified PaperMC version and build number.
#
# USAGE:    bash -get-paper-mc-jar-url.sh [version] [build]
# EXAMPLE:  bash -get-paper-mc-jar-url.sh 1.21 130
# PRE-REQS: none
#

DEFAULT_PAPER_VERSION=1.21
DEFAULT_PAPER_BUILD=130

# if parameter is not set, set it to the default version
if [ -z "$1" ]; then
  export PAPER_VERSION=$DEFAULT_PAPER_VERSION
else
  export PAPER_VERSION=$1
fi

# if parameter is not set, set it to the default build
if [ -z "$2" ]; then
  export PAPER_BUILD=$DEFAULT_PAPER_BUILD
else
  export PAPER_BUILD=$2
fi

# output the URL
echo https://api.papermc.io/v2/projects/paper/versions/$PAPER_VERSION/builds/$PAPER_BUILD/downloads/paper-$PAPER_VERSION-$PAPER_BUILD.jar
