# autovirt listing backend

The purpose of this script is to provide inputs for the front-end of an application, that will largely automate virtualization and the associated setup process.

## Dependencies
**Arch**
```bash
sudo pacman -S jq gawk sed grep
```

**Debian**
```bash
sudo apt install jq gawk sed grep
```

**Fedora**
```bash
sudo dnf install jq gawk sed grep
```


## Install

```bash
git clone https://www.github.com/MaxBrandtner/autovirt-listing-backend.git
cd autovirt-listing-backend
```
**Run**

*Providing inputs is optional*

*Json data can be provided both as a json file or as an input string*

```bash
bash main.sh
```

## Usage

### Input
*If an input key isn't provided the key will be added with its default value*

**The input values listed here are the default values**

```json
{
	"user":"$USER",
	"check_permissions":"true",
	"device_listing_setup":"false",
	"GVT_setup":"false",
	"GVT_check":"false",
	"SR_IOV_check":"$IS_CPU_VENDOR_INTEL",
	"GIM_setup":"false",
	"storage_dir":"/",
	"output_PCIOther":"false",
}
```
*Note: if GIM_setup="true" the corresponding github repo will be installed*

*Without SR-IOV and GIM some GPU listings may be incorrect*


### output
*The output is written to the standard output(stdout)*

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
			"types":["microphone","webcam","keyboard","mouse","controller","storage","hid"]
		}
	},

	
	"pci_devices":{
		"GPUs":{
			"device_1":{
				"pci_id":"0a:00.0",
				"name":"lspci name",
				"resetable":"true",
				"SR-IOV_support":"false",
				"GVT_support":"false",
				"GVT_types":[],
				"acs_patch_required":"false",
				"iommu_associated_pci_ids":["0a:00.1","0a:00.2","0a:00.3"],
				"device_associated_pci_ids":["0a:00.1","0a:00.2","0a:00.3"],
				"iommu_associated_names":["name","name","name","name"],
				"device_associated_names":["name","name","name","name"],
				"vram":"6144",
				"has_vgpu_support":"false"
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



