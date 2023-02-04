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
	( file_exists "$1" && check_json $1 && cat "$1" && return 0 ) \
	|| ( check_json $1 && echo "$1" && return 0 ) \
	|| ( return 1 )
}



function json_add_default_value(){
	json_data=$(get_pipe) || return 1
	key=$1 && default_value=$2 || return 1
	
	(echo "$json_data" | jq -e -c ".$key" >/dev/null 2>&1 ) || json_data=$(echo "$json_data" | jq -e -c '. +={"'$(echo $key)'":"'$(echo $default_value)'"}')

	echo $json_data
}


function parse_inputs_to_array_format(){
	data=$(get_pipe) || return 1
	[ "$data" ] && echo "$data" | paste -d '"' /dev/null - /dev/null | paste -sd' ' - | sed 's/" "/","/g'
}

function append_brackets(){
	data=$(get_pipe) || return 1
	echo "[ "$data" ]"
}



cd "$initial_dir"
unset functions