#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source functions/lib_json.sh || return 1

json_data=$1


json_data=$(echo "$json_data" | json_add_default_value "user" "$(users | head -n 1 | tail -n 1)")
json_data=$(echo "$json_data" | json_add_default_value "check_permissions" "true")
json_data=$(echo "$json_data" | json_add_default_value "device_listing_setup" "false")
json_data=$(echo "$json_data" | json_add_default_value "GVT_setup" "false")
json_data=$(echo "$json_data" | json_add_default_value "GVT_check" "false")
json_data=$(echo "$json_data" | json_add_default_value "SR_IOV_check" "$( ( lscpu | grep Vendor | grep Intel >/dev/null 2>&1 ) && echo "true" || echo "false")")
json_data=$(echo "$json_data" | json_add_default_value "GIM_setup" "false")
json_data=$(echo "$json_data" | json_add_default_value "storage_dir" "/")
json_data=$(echo "$json_data" | json_add_default_value "output_PCIOther" "false")


echo "$json_data"
