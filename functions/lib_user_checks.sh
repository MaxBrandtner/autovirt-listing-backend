#!/bin/bash
functions=("is_root" "add_user_to_group" "is_only_user")

for in in ${functions[@]}
do
	declare -f "${functions[$i]}" >/dev/null
done


function is_root(){
	[ "$(whoami)" == "root" ] && return 0 ; return 1
}

function exit_non_root(){
	[ $(whoami) == "root" ] || echo "not root user" >/dev/stderr && exit 1
}

function add_user_to_group(){
	group=$1
	usermod -a -G $group $(users)
}

function is_only_user(){
	[ $(users | wc -l) == 1 ] && return 0; return 1
}


unset functions