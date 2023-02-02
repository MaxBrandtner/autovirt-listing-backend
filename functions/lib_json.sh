#!/bin/bash
initial_dir=$(pwd)
cd "$(dirname "$(realpath "$BASH_SOURCE")")"

source lib_basic.sh || return 1 

functions=("check_json" "file_exists" "obtain_json_data" "")

for in in ${functions[@]}
do
	declare -f "${functions[$i]}" >/dev/null
done



function check_json(){
	[ $1 ] || return 1
	json_data=$1
	
	echo "$json_data" | jq "." >/dev/null && return 0 || return 1
}



function file_exists(){
	[ -b $1 ] || return 1
}


function obtain_json_data(){
	# $1 can be file or json data
	file_exists "$1" && cat "$1" && return 0 \
	|| check_json $1 && echo "$1" && return 0 \
	|| return 1
}



function json_add_default_value(){
	json_data=$(get_pipe) && piped="true" || json_data=$1
	[ "$piped" == "true" ] && key=$1 && default_value=$2 || [ "$piped" != "true" ] && key=$2 && default_value=$3 || return 1
	
	echo "$json_data" | jq -e ".$key" || echo "$json_data" | jq -e '. +={"'$(echo $key)'":"'$(echo $default_value)'"}'	
}


function parse_inputs_to_array_format(){
	data=$(get_pipe) || [ $1 ] && data=$1 || return 1
	echo $data | paste -d '"' /dev/null - /dev/null | paste -sd' ' - | sed 's/" "/","/'
}



cd "$initial_dir"
unset functions