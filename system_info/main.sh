#!/bin/bash
source functions/lib_hardware.sh
cd "$(dirname "$(realpath "$BASH_SOURCE")")"

[ $1 ] || return 1
json_input_data=$1

json_output_data=$(bash simple.sh)
json_output_data=$(echo $json_output_data | jq '. +='$(bash usb_devices.sh)'')
bash pci_listing_setup.sh $json_input_data
json_output_data=$(echo $json_output_data | jq '. +='$(bash pci_listing.sh)'')