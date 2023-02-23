#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source ../functions/lib_hardware.sh
source ../functions/lib_json.sh

usb_device_json_data="{}"

for ((i=1;i<=$(lsusb | wc -l);i++))
do
	usb_device_json_data=$(echo $usb_device_json_data | jq '. +={"device_'$i'":{}}' || echo "$usb_device_json_data")
	usb_id=$(lsusb | head -n $i | tail -n 1 | awk '{print $6}')
	usb_device_json_data=$(echo $usb_device_json_data | jq '.device_'$i' +={"id":"'$usb_id'"}' || echo "$usb_device_json_data")
	usb_device_json_data=$(echo $usb_device_json_data | jq --arg usb_name "$(list_USB_name $usb_id)" '.device_'$i' +={"name":$usb_name}' || echo "$usb_device_json_data")
	usb_device_json_data=$(echo $usb_device_json_data | jq '.device_'$i' +={"types":['$(USB_device_obtain_types $usb_id | parse_inputs_to_array_format)']}' || echo "$usb_device_json_data")
done

echo "$usb_device_json_data"