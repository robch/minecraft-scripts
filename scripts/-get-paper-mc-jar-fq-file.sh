#!/bin/bash

# This script will return the PaperMC server jar filename for the specified world.
#
# USAGE:    bash -get-paper-mc-jar-fq-file.sh [world]
# EXAMPLE:  bash -get-paper-mc-jar-fq-file.sh World1
# PRE-REQS: none
#

THIS_DIR=$(dirname $0)
WORLD_FQ_DIR=$(bash $THIS_DIR/-get-minecraft-world-fq-dir.sh $1)
JAR_FQ_FILE=$WORLD_FQ_DIR/paper-server.jar

echo $JAR_FQ_FILE