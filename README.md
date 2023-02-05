# autovirt listing backend

The purpose of this script is to provide inputs for the front-end for an application, that will automate a large part of virtualization (especially setup).

## dependencies
**Arch**
`pacman -S jq xorg-xrandr gawk sed grep`

**Debian**
`apt install jq x11-xserver-utils gawk sed grep`

**Fedora**
`dnf install jq xrandr gawk sed grep`


## install

```bash
git clone https://www.github.com/MaxBrandtner/autovirt-listing-backend.git
cd autovirt-listing-backend
```
**run**

*input.json is optional*
*alternatively the json data can be provided as an option*

```bash
bash main.sh input.json
```

## usage

### input
*providing input is optional*
*if an input key isn't provided it will be filled in with its default value*

**the input values listed here are the default values**

```json
{
	"user":"$(user)",
	"check_permissions":"true",
	"device_listing_setup":"false",
	"SR_IOV_setup":"false",
	"GIM_setup":"false",
	"storage_dir":"/",
	"output_PCIOther":"false"
}
```
*note that if GIM_setup="true" the corresponding github repo will be installed*
*without SR-IOV and GIM some GPU listings may be incorrect*


### output
*the output is echoed in the terminal(no file is created)*

```json
{
	"free_storage":"100",
	"full_storage":"500",
	"ram_size":"16000",
	"CPU_cores":"6",
	"CPU_threads":"2",
	
	"n_displays":"1",
	
	"usb_devices":{
		"device_1":{
			"id":"1234:1234",
			"name":"usb device name",
			"types":["microphone","webcam","keyboard","mouse","controller","storage"]
		}
	},

	
	"pci_devices":{
		"GPUs":{
			"device_1":{
				"pci_id":"0a:00.0",
				"name":"lspci name",
				"resetable":"yes",
				"acs_patch_required":"no",
				"iommu_associated_pci_ids":["0a:00.1","0a:00.2","0a:00.3"],
				"device_associated_pci_ids":["0a:00.1","0a:00.2","0a:00.3"],
				"iommu_associated_names":["name","name","name","name"],
				"device_associated_names":["name","name","name","name"]
			}
		},
		
		"NVMEs":{},
		"USBControllers":{},
		"SataControllers":{},
		"Wifi":{},
		"Ethernet":{},
		"AudioControllers":{}
	}
}
```

*acs_patch_required is not a foolproof check.* **It only checks if all of their devices are in the same iommu group as it is**  *while the device may work without the acs patch, eg if the device serves as a hub*
**device associated pci_id are only listed for external devices**

