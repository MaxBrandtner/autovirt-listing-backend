#!/bin/bash
source ../functions/lib_hardware.sh
source ../functions/lib_json.sh

var_acs_applied=$(acs_patch_applied && echo "true" || echo "false")
var_acs_kernel=$(acs_patch_kernel && echo "true" || echo "false")

json_output_data='{}'

json_output_data=$(echo "$json_output_data" | jq '. +={"acs_patch_applied":"'$var_acs_applied'"}' || echo "$json_output_data")
json_output_data=$(echo "$json_output_data" | jq '. +={"acs_patch_kernel":"'$var_acs_kernel'"}' || echo "$json_output_data")

echo "$json_output_data"