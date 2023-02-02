#!/bin/bash
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source ../../functions/lib_hardware.sh || return 1

exit_non_root

while IFS= read -r GPU_pci
do
	[ $(GPU_vendor $GPU_pci) == "AMD" ] && contains_AMD_GPU="true"
done <<< $(lspci -nn | grep "\[0300\]" | awk '{print $1}')



if [ $contains_AMD_GPU == "true" ]
then
	add_kernel_parameter "module.sig_enforce=0"
	update_grub

	cd /opt
	git clone https://github.com/GPUOpen-LibrariesAndSDKs/MxGPU-Virtualization.git
	cd /opt/MxGPU-Virtualization
	make; make install

	echo blacklist amdgpu >> /etc/modprobe.d/blacklist.conf
	echo blacklist amdkfd >> /etc/modprobe.d/blacklist.conf

	modprobe gim
fi