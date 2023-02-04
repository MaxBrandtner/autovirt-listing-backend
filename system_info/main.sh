#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"

[ $1 ] || return 1
json_input_data=$1

json_output_data=$(bash simple.sh $json_input_data)

json_output_data=$(echo $json_output_data | jq --argjson usb_json "$(bash usb_devices.sh)" '.usb_devices +=$usb_json')
bash pci_listing_setup.sh $json_input_data
json_output_data=$(echo $json_output_data | jq --argjson pci_json "$(bash pci_listing.sh)"  '.pci_devices +=$pci_json')

echo $json_output_data