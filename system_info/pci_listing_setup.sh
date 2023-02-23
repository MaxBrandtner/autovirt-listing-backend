#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"

source ../functions/lib_user_checks.sh || exit 1
source ../functions/lib_root.sh || exit 1

[ $1 ] || exit 1
json_input_data=$1

[ $(echo $json_input_data | jq '.device_listing_setup' ) == "true" ] || exit 0

# GVT setup
if [ $(echo "$json_input_data" | jq '.GVT_setup') == "true" ]
then
	add_kernel_parameter intel_iommu=on i915.enable_guc=0
	update_grub
	run_as_root modprobe mdev --enable_gvt=1 kvmgt vfio-iommu-type1
fi


# GIM
if [ $(echo $json_input_data | jq '.GIM_setup' ) == "true" ]
then
	run_as_root bash pci_listing_setup/GIM_setup.sh
fi