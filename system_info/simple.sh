#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source ../functions/lib_hardware.sh
source ../functions/lib_json.sh
source ../functions/lib_basic.sh

json_input_data=$1

storage_dir=$(echo $json_input_data | jq ".storage_dir" | sed 's/\"//g')

CPU_virtualisation_bios_enabled=$( ( run_as_root CPU_virtualisation_in_bios_enabled && echo "true" ) || echo "false")

json_output_data="{}"

json_output_data=$(echo "$json_output_data" | jq '. +={"CPU_cores":"'$(CPU_cores)'"}' || echo "$json_output_data")
json_output_data=$(echo "$json_output_data" | jq '. +={"CPU_threads":"'$(CPU_threads)'"}' || echo "$json_output_data")
json_output_data=$(echo "$json_output_data" | jq '. +={"CPU_virtualisation_bios_enabled":"'$CPU_virtualisation_bios_enabled'"}' || echo "$json_output_data")
json_output_data=$(echo "$json_output_data" | jq '. +={"ram_size":"'$(ram_size)'"}' || echo "$json_output_data")
json_output_data=$(echo "$json_output_data" | jq '. +={"full_storage":"'$(storage_size_full $storage_dir)'"}' || echo "$json_output_data")
json_output_data=$(echo "$json_output_data" | jq '. +={"free_storage":"'$(storage_size_free $storage_dir)'"}' || echo "$json_output_data")
json_output_data=$(echo "$json_output_data" | jq '. +={"n_displays":"'$(n_displays)'"}' || echo "$json_output_data")

echo $json_output_data