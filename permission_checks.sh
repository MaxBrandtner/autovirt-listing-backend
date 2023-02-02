#!/bin/bash
source functions/lib_basic.sh
source functions/lib_json.sh

cd "$(dirname "$(realpath "$BASH_SOURCE")")"

json_data=$1 || return 1

user=(echo $json_data | jq ".user")

groups $user | grep "libvirt" || [ $(whoami) == "root" ] && usermod -a -G libvirt $user || pkexec usermod -a -G libvirt $user 