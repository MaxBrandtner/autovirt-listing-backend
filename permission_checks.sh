#!/bin/bash
source functions/lib_basic.sh
source functions/lib_json.sh

cd "$(dirname "$(realpath "$BASH_SOURCE")")"

json_data=$1 || return 1

user=$(echo $json_data | jq ".user" | sed 's/\"//g')

( groups $user | grep "libvirt" >/dev/null) \
|| ( [ $(whoami) == "root" ] && usermod -a -G libvirt $user ) \
|| ( pkexec usermod -a -G libvirt $user || echo "authorization canceled by user" >/dev/stderr)