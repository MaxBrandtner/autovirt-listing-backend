#!/bin/bash
initial_dir="$(pwd)"
cd "$(dirname "$(realpath "$BASH_SOURCE")")"
source lib_user_checks.sh


function add_kernel_parameter(){
	[ $(is_root) ] || pkexec add_kernel_parameter "$@"

	for parameter in "$@"
	do
		cat /etc/default/grub | grep $parameter >/dev/null 2>&1
		if [ $? != 0 ]
		then
			sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"'$parameter' /' /etc/default/grub
		fi
	done
}

function update_grub(){
	run_as_root grub-mkconfig -o /boot/grub/grub.cfg
}


cd $initial_dir