#!/bin/bash

# This script will check the status, waiting for "Timings Reset"
#
# USAGE:    91-wait-for-timings-reset.sh [slot]
# EXAMPLE:  91-wait-for-timings-reset.sh 1
#

source $(dirname $0)/-functions.sh
mc_service_slot_wait_for_timings_reset $1
