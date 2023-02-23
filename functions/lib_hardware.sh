#!/bin/bash
initial_dir="$(pwd)"
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source lib_json.sh || exit 1



function CPU_threads(){
	lscpu | grep "Thread(s)" | awk '{print $4}'
}


function CPU_cores(){
	lscpu | grep "Core(s)" | awk '{print $4}'
}


function ram_size(){
	free -m | head -n 2 | tail -n 1 | awk '{print $2}'
}


function storage_size_free(){
	[ $1 ] || return 1; file_dir=$1
	df -h $file_dir | tail -n 1 | awk '{print $4}' | sed 's/G//'
}


function storage_size_full(){
	[ $1 ] || return 1; file_dir=$1
	df -h $file_dir | tail -n 1 | awk '{print $2}' | sed 's/G//'
}


function n_displays(){
	xrandr --listmonitors | tail -n +2 | wc -l
}


function list_USB_devices(){
	device_type=$@

	while IFS= read -r usb_id
	do
		( echo $device_type | grep -i -q "microphone"  && lsusb -v -d $usb_id 2>/dev/null | grep wTerminalType      2>/dev/null | grep "Microphone"    >/dev/null 2>&1 && lsusb -d $usb_id | awk '{print $6}' ) \
		|| ( echo $device_type | grep -i -q "webcam"   && lsusb -v -d $usb_id 2>/dev/null | grep wTerminalType      2>/dev/null | grep "Camera Sensor" >/dev/null 2>&1 && lsusb -d $usb_id | awk '{print $6}' ) \
		|| ( echo $device_type | grep -i -q "keyboard" && lsusb -v -d $usb_id 2>/dev/null | grep bInterfaceProtocol 2>/dev/null | grep "Keyboard"      >/dev/null 2>&1 && lsusb -d $usb_id | awk '{print $6}' ) \
		|| ( echo $device_type | grep -i -q "mouse"    && lsusb -v -d $usb_id 2>/dev/null | grep bInterfaceProtocol 2>/dev/null | grep "Mouse"         >/dev/null 2>&1 && lsusb -d $usb_id | awk '{print $6}' ) \
		|| ( [ $1 ] || echo $usb_id )
	done <<< $(lsusb | awk '{print $6}')
}


function USB_device_obtain_types(){
	[ $1 ] || return 1
	usb_id=$1
	
	lsusb -v -d $usb_id 2>/dev/null \
	| awk '{for (f=3; f<=NF; ++f) { if (f!=2) {printf("%s",OFS);} printf("%s",$f)}; printf "\n" }' \
	| sed -e 's/^ *//' -e 's/\n//' | sed -r '/^\s*$/d' \
	| grep -i 'Microphone\|Camera Sensor\|Keyboard\|Mouse\|Mass Storage\|Human Interface Device\|USB Joystick' \
	| sed -e 's/Camera Sensor/webcam/' -e 's/Human Interface Device/HID/' -e 's/Mass Storage/storage/' -e 's/USB Joystick/controller/' | tr '[:upper:]' '[:lower:]' | sort -u
}


function list_USB_name(){
	usb_id=$1
	lsusb | grep "$usb_id" | head -n 1 | awk '{for (f=7; f<=NF; ++f) { if (f!=2) {printf("%s",OFS);} printf("%s",$f)}; printf "\n" }' | sed 's/ //'
}


function GPU_vendor(){
	pci_id=$1
	lspci -s $pci_id >/dev/null 2>&1; [ $? != 0 ] && return 1 
	( lspci -s $pci_id | grep -i "AMD"    >/dev/null 2>&1 ) && echo "AMD"    && return 0
	( lspci -s $pci_id | grep -i "NVIDIA" >/dev/null 2>&1 ) && echo "NVIDIA" && return 0
	( lspci -s $pci_id | grep -i "Intel"  >/dev/null 2>&1 ) && echo "Intel"  && return 0
}


function get_pci_device(){
	( [ $1 ] && lspci -nn | grep $1 >/dev/null 2>&1 && pci_id=$1 ) || return 1
	lspci -nn | grep $1 | sed 's/.*\[//' | sed 's/\].*//' | awk '{print $1}' | sed 's/\:/ /' | awk '{print $1}'
}


function device_associated_pcis(){
	( [ $1 ] && lspci -nn | grep $1 >/dev/null 2>&1 && pci_id=$1 ) || return 1
	
	main_device=$(get_pci_device "00:00.0")
	device=$(get_pci_device $1)
	
	[ $main_device == $device ] && return 0
	
	lspci -nn | grep $device | awk '{print $1}' | grep -v $pci_id
}


function pci_reset_check(){
	[ $1 ] || return 1; pci_id=$1
	[ -f "/sys/bus/pci/devices/0000:$pci_id/reset" ] && return 0 || return 1
}



function pci_SRIOV_check(){
	[ $1 ] || return 1; pci_id=$1
	[ -f "/sys/bus/pci/devices/0000:$pci_id/SR-IOV_numvfs" ] && return 0 || return 1
}


function pci_GVT_check(){
	[ $1 ] || return 1; pci_id=$1
	[ -f "/sys/bus/pci/devices/0000:$pci_id/mdev_supported_types" ] && return 0 || return 1
}


function list_GVT_types(){
	[ $1 ] || return 1; pci_id=$1
	ls "/sys/bus/pci/devices/0000:$pci_id/mdev_supported_types" 2>/dev/null | awk '{print $1}'
}



function ls_iommu_groups(){
        for d in /sys/kernel/iommu_groups/*/devices/*; do
        n=${d#*/iommu_groups/*}; n=${n%%/*}
        printf '%s ' "$n"
        lspci -nns "${d##*/}"
    done
}


function iommu_group_pci(){
	[ $1 ] || return 1; pci_id=$1
	ls_iommu_groups | grep $pci_id | awk '{print $1}'
}


function iommu_associated_pcis(){
	[ $1 ] || return 1; pci_id=$1
	ls_iommu_groups | grep "^$(iommu_group_pci $pci_id)" | awk '{print $2}' | grep -v $pci_id
}

function get_pci_name(){
	[ $1 ] || return 1; pci_id=$1
	lspci | grep $pci_id | sed -e 's/.*\://' -e 's/^ //'
}

function iommu_associated_names(){
	[ $1 ] || return 1; input_pci_id=$1
	
	while IFS= read -r pci_id
	do
		get_pci_name $pci_id
	done <<< $(iommu_associated_pcis $input_pci_id)
}

function device_associated_names(){
	[ $1 ] || return 1; input_pci_id=$1
	
	while IFS= read -r pci_id
	do
		get_pci_name $pci_id
	done <<< $(device_associated_pcis $input_pci_id)
}


cd "$initial_dir"