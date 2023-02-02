#!/bin/bash
source functions/lib_json.sh || return 1
cd "$(dirname "$(realpath "$BASH_SOURCE")")"

json_input_data=$(obtain_json_data "$1" || echo "{}" ) 

json_input_data=$(bash complete_json_data.sh $json_input_data) || return 1

bash permission_checks.sh $json_input_data || return 1

json_output_data=$(bash system_info/main.sh $json_input_data) || return 1


echo $json_output_data