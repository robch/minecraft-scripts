#!/bin/bash

# This script will check the status of the specified service slot.
#
# USAGE:    92-check-service-slot.sh [slot]
# EXAMPLE:  92-check-service-slot.sh 1
#

source $(dirname $0)/-functions.sh
mc_service_slot_check $1
