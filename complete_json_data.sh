#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source functions/lib_json.sh || return 1

json_data=$1


json_data=$(echo "$json_data" | json_add_default_value "user" "$(users | head -n 1 | tail -n 1)")
json_data=$(echo "$json_data" | json_add_default_value "check_permissions" "true")
json_data=$(echo "$json_data" | json_add_default_value "device_listing_setup" "false")
json_data=$(echo "$json_data" | json_add_default_value "SR_IOV_setup" "false")
json_data=$(echo "$json_data" | json_add_default_value "GIM_setup" "false")
json_data=$(echo "$json_data" | json_add_default_value "storage_dir" "/")


echo "$json_data"
