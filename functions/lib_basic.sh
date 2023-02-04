#!/bin/bash
functions=("get_pipe" "cd_file_dir")

for in in ${functions[@]}
do
	declare -f "${functions[$i]}" >/dev/null
done


function get_pipe(){
	[ -p /dev/stdin ] && input=$(</dev/stdin) && echo "$input" || return 1
}


function cd_file_dir(){
	cd "$(dirname "$(realpath "$BASH_SOURCE")")"
}


unset functions