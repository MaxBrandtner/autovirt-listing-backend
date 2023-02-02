#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source ../functions/lib_user_checks.sh | return 1 

[ $1 ] || return 1
json_input_data=$1

[ $(echo json_input_data | jq '.device_listing_setup' ) == "true" ] || return 1

# SR-IOV
[ $(echo json_input_data | jq '.SR-IOV_setup' ) == "true" ] && modprobe 40en max_vfs=8,8

# GIM
if [ $(echo json_input_data | jq '.GIM_setup' ) == "true" ]
then
	[ $(is_root) ] && bash pci_listing_setup/GIM_setup.sh || pkexec bash pci_listing_setup/GIM_setup.sh	
fi