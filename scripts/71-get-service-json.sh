#!/bin/bash

# This script will get the JSON for all the service slots.
#
# USAGE:    71-get-service-json.sh
# EXAMPLE:  71-get-service-json.sh
#

source $(dirname $0)/_functions.sh
mc_service_slot_json_get
