#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source ../functions/lib_hardware.sh || return 1


pci_json_output_data="{}"

pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"GPUs":{}}')
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"NVMEs":{}}')
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"USBControllers":{}}')
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"SataControllers":{}}')
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"Wifi":{}}')
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"Ethernet":{}}')
pci_json_output_data=$(echo $pci_json_output_data | jq '. +={"AudioControllers":{}}')


function device_json(){
	[ $1 ] && [ $2 ] || return 1
	pci_id=$1
	device_name=$(lspci | grep $pci_id | sed 's/.*://')
	n_device=$2
	device="device_$n_device"

	device_json="{}"

	device_json=$(echo $device_json | jq '. +={'$device':{}}')
	device_json=$(echo $device_json | jq '.'$device' +={"pci_id":"'$pci_id'"}')
	[ $(pci_reset_check $pci_id) ] && reset_check="yes" || reset_check="no"
	device_json=$(echo $device_json | jq '.'$device' +={"resetable":"'$reset_check'"}')
	device_json=$(echo $device_json | jq '.'$device' +={"iommu_associated_pci_ids":['$(iommu_associated_pcis $pci_id | parse_inputs_to_array_format)']}')
	device_json=$(echo $device_json | jq '.'$device' +={"device_associated_pci_ids":['$(device_associated_pcis $pci_id | parse_inputs_to_array_format)']}')	
	device_json=$(echo $device_json | jq '.'$device' +={"iommu_associated_names":['$(iommu_associated_names $pci_id | parse_inputs_to_array_format)']}')
	device_json=$(echo $device_json | jq '.'$device' +={"device_associated_names":['$(device_associated_names $pci_id | parse_inputs_to_array_format)']}')
	( [ $(get_pci_device $pci_id) == $(get_pci_device 00:00.0) ] && [ $(echo $device_json | jq '.'$device'.iommu_associated_pci_ids') == $(echo $device_json | jq '.'$device'.device_associated_pci_ids') ] && acs_check="yes" ) || acs_check="no"
	device_json=$(echo $device_json | jq '.'$device' +={"acs_patch_required":"'$acs_check'"}')
	
	device_associated_json="[]"
	
	for ((i=0;i<$(echo $device_json | jq '.'$device'.iommu_associated_pci_ids | length'); i++ ))
	do
		pci_id=$(echo $device_json | jq '.'$device'.iommu_associated_pci_ids['$i']')
		device_associated_json=$(echo $device_associated_json "$(lspci | grep $pci_id | sed 's/.*://')",)
	done
	
	device_associated_json=$(echo $device_associated_json | )
}



for ((i=1;i<=$(lspci | grep "\[0300\]" | wc -l);i++))
do
	pci_id=$(lspci | grep "\[0300\]" | head -n $i | tail -n 1 | awk '{print $1}')
	
	echo pci_json_output_data=$(echo pci_json_output_data | jq '.GPUs +='$(device_json $pci_id $i)'')
done



for ((i=1;i<=$(lspci | grep "\[0108\]" | wc -l);i++))
do
	pci_id=$(lspci | grep "\[0108\]" | head -n $i | tail -n 1 | awk '{print $1}')
	
	echo pci_json_output_data=$(echo pci_json_output_data | jq '.GPUs +='$(device_json $pci_id $i)'')
done



for ((i=1;i<=$(lspci | grep "\[0c03\]" | wc -l);i++))
do
	pci_id=$(lspci | grep "\[0c03\]" | head -n $i | tail -n 1 | awk '{print $1}')
	
	echo pci_json_output_data=$(echo pci_json_output_data | jq '.GPUs +='$(device_json $pci_id $i)'')
done



for ((i=1;i<=$(lspci | grep "\[0106\]" | wc -l);i++))
do
	pci_id=$(lspci | grep "\[0106\]" | head -n $i | tail -n 1 | awk '{print $1}')
	
	echo pci_json_output_data=$(echo pci_json_output_data | jq '.GPUs +='$(device_json $pci_id $i)'')
done



for ((i=1;i<=$(lspci | grep "\[0280\]" | wc -l);i++))
do
	pci_id=$(lspci | grep "\[0280\]" | head -n $i | tail -n 1 | awk '{print $1}')
	
	echo pci_json_output_data=$(echo pci_json_output_data | jq '.GPUs +='$(device_json $pci_id $i)'')
done



for ((i=1;i<=$(lspci | grep "\[0200\]" | wc -l);i++))
do
	pci_id=$(lspci | grep "\[0200\]" | head -n $i | tail -n 1 | awk '{print $1}')
	
	echo pci_json_output_data=$(echo pci_json_output_data | jq '.GPUs +='$(device_json $pci_id $i)'')
done



for ((i=1;i<=$(lspci | grep "\[0108\]" | wc -l);i++))
do
	pci_id=$(lspci | grep "\[0108\]" | head -n $i | tail -n 1 | awk '{print $1}')
	
	echo pci_json_output_data=$(echo pci_json_output_data | jq '.GPUs +='$(device_json $pci_id $i)'')
done