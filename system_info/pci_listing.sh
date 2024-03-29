#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source ../functions/lib_hardware.sh || exit 1

json_input_data=$1

check_SRIOV=$(echo "$json_input_data" | jq .SR_IOV_check | sed 's/\"//g')
check_GVT=$(echo "$json_input_data" | jq .GVT_check | sed 's/\"//g')

pci_json_output_data="{}"

pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"GPUs":{}}' || echo "$pci_json_output_data")
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"NVMEs":{}}'|| echo "$pci_json_output_data")
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"USBControllers":{}}'|| echo "$pci_json_output_data")
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"SataControllers":{}}'|| echo "$pci_json_output_data")
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"Wifi":{}}'|| echo "$pci_json_output_data")
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"Ethernet":{}}'|| echo "$pci_json_output_data")
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"AudioControllers":{}}'|| echo "$pci_json_output_data")


function device_json(){
	[ $1 ] || return 1
	pci_id=$1
	device_name=$(lspci | grep $pci_id | sed 's/.*://')

	device_json="{}"
	device_json=$(echo $device_json | jq '. +={"pci_id":"'$pci_id'"}' || echo "$device_json")
	device_json=$(echo $device_json | jq --arg name "$(get_pci_name $pci_id)" '. +={"name":$name}' || echo "$device_json")
	pci_reset_check $pci_id && reset_check="true" || reset_check="false"
	device_json=$(echo $device_json | jq '. +={"resetable":"'$reset_check'"}' || echo "$device_json")

	if [ $check_SRIOV == "true" ]
	then
		pci_SRIOV_check $pci_id && SRIOV_check="true" || SRIOV_check="false"
		device_json=$(echo $device_json | jq '. +={"SR-IOV_support":"'$SRIOV_check'"}' || echo "$device_json")
	fi

	if [ $check_GVT == "true" ]
	then
		pci_GVT_check $pci_id && GVT_check="true" || GVT_check="false"
		device_json=$(echo $device_json | jq '. +={"GVT_support":"'$GVT_check'"}' || echo "$device_json")

		[ $GVT_check == "yes" ] && device_json=$(echo $device_json | jq --argjson types "$(list_GVT_types $pci_id | parse_inputs_to_array_format | append_brackets)" '.GVT_types? +=$types' || echo "$device_json")
	fi

	device_json=$(echo $device_json | jq '. +={"iommu_associated_pci_ids":['$(iommu_associated_pcis $pci_id | parse_inputs_to_array_format)']}' || echo "$device_json")
	device_json=$(echo $device_json | jq '. +={"device_associated_pci_ids":['$(device_associated_pcis $pci_id | parse_inputs_to_array_format)']}' || echo "$device_json")

	device_json=$(echo $device_json | jq --argjson names "$(iommu_associated_names $pci_id | parse_inputs_to_array_format | append_brackets)" '.iommu_associated_names? +=$names' || echo "$device_json")
	device_json=$(echo $device_json | jq --argjson names "$(device_associated_names $pci_id | parse_inputs_to_array_format | append_brackets)" '.device_associated_names? +=$names' || echo "$device_json")

	[ $(echo $device_json | jq '.iommu_associated_pci_ids' | wc -l) == $(echo $device_json | jq '.device_associated_pci_ids' | wc -l) ] \
	&& acs_check="false" || acs_check="true"

	device_json=$(echo $device_json | jq '. +={"acs_patch_required":"'$acs_check'"}' || echo "$device_json")
	
	device_json=$(echo "$device_json" | jq --arg vram $(get_vram $pci_id) '. +={"vram":$vram}' || echo "$device_json")
	device_json=$(echo "$device_json" | jq --arg vgpu_support $(has_vgpu_support $pci_id) '. +={"has_vgpu_support":$vgpu_support}' || echo "$device_json")
	echo "$device_json"
}


#GPUs
for ((i=1;i<=$(lspci -nn | grep "\[0300\]" | wc -l);i++))
do
	pci_id=$(lspci -nn | grep "\[0300\]" | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.GPUs.device_'$i' += $device'|| echo "$pci_json_output_data" )
done


#NVMEs
for ((i=1;i<=$(lspci -nn | grep "\[0108\]" | wc -l);i++))
do
	pci_id=$(lspci -nn | grep "\[0108\]" | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.NVMEs.device_'$i' += $device' || echo "$pci_json_output_data")
done


#USBControllers
for ((i=1;i<=$(lspci -nn | grep "\[0c03\]" | wc -l);i++))
do
	pci_id=$(lspci -nn | grep "\[0c03\]" | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.USBControllers.device_'$i' += $device'|| echo "$pci_json_output_data" )
done


#SataControllers
for ((i=1;i<=$(lspci -nn | grep "\[0106\]" | wc -l);i++))
do
	pci_id=$(lspci -nn | grep "\[0106\]" | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.SataControllers.device_'$i' += $device'|| echo "$pci_json_output_data" )
done


#Wifi
for ((i=1;i<=$(lspci -nn | grep "\[0280\]" | wc -l);i++))
do
	pci_id=$(lspci -nn | grep "\[0280\]" | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.Wifi.device_'$i' += $device'|| echo "$pci_json_output_data" )
done


#Ethernet
for ((i=1;i<=$(lspci -nn | grep "\[0200\]" | wc -l);i++))
do
	pci_id=$(lspci -nn | grep "\[0200\]" | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.Ethernet.device_'$i' += $device' || echo "$pci_json_output_data")
done


#AudioControllers
for ((i=1;i<=$(lspci -nn | grep "\[0403\]" | wc -l);i++))
do
	pci_id=$(lspci -nn | grep "\[0403\]" | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.AudioControllers.device_'$i' += $device' || echo "$pci_json_output_data")
done


#PCIOther
if [ $(echo $json_input_data | jq ".output_PCIOther" | sed 's/\"//g') == "true" ]
then
for ((i=1;i<=$(lspci -nn | grep -v '\[0403\]\|\[0200\]\|\[0280\]\|\[0106\]\|\[0c03\]\|\[0108\]\|\[0300\]' | wc -l);i++))
do
	pci_id=$(lspci -nn | grep -v '\[0403\]\|\[0200\]\|\[0280\]\|\[0106\]\|\[0c03\]\|\[0108\]\|\[0300\]' | head -n $i | tail -n 1 | awk '{print $1}')

	pci_json_output_data=$(echo "$pci_json_output_data" | jq --argjson device "$(device_json $pci_id)" '.PCIOther.device_'$i' += $device' || echo "$pci_json_output_data" )
done
fi

echo "$pci_json_output_data"