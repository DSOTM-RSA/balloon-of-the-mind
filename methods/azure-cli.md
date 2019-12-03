# Managing Azure Resources via the CLI

## Initializing a storage account

- **create a resource group**

*az group create \
	--name demo-rg \
	--location westeurope*
	
- **check regions available**

*az account list-locations \
	--query "[].{Region:name}" \
	--out table*
	
- **create a general V2 storage account**

*az storage account create \
	--name demo-store \
	--resource-group demo-rg \
	--location westeurope \
	--sku Standard_LRS \
	--kind StorageV2*
	
- **delete a resource group**

*az group delete \
	--name demo-rg*
	
## Working with blobs
	
- **list storage account keys*

*az storage-account keys list \
	--account-name demo-store \
	--resource-group demo-rg \
	--output table*

- **export variables**

*export AZURE_STORAGE_ACCOUNT=" " \
	export AZURE_STORAGE_KEY=" "*

- **create a container**

*az storage container create \
	--name demo-container*
	
- **upload a blob to a container**

*az storage blob upload \
	--container-name demo-container \
	--name sample.txt \
	--file sample.txt* 
	
- **bulk upload blobs to a container**

*az storage blob upload-batch \
	--destination demo-container \
	--source /home \
	--pattern \*.txt \
  --if-unmodifed-since 2019-09-15T2000Z \
	--[dry-run]*
	
- **list the blobs in a container**	
	
*az storage blob list \
	--container-name demo-container \
	--output table*
	
- **download a blob**

*az storage blob download \
	--container-name demo-container \
	--name sample.txt \
	--file ~/destination/path/to/file*
	
	
## Managing VMs

- **create a Linux VM**

*az vm create \
	--resource-group demo-rg \
	--name SampleVM \
	--image UbuntuLTS \
	--size "Standard_DS5_v2" \
	--admin-username azureuser \
	--generate-ssh-keys \
	--verbose
	--[no-wait]*
	
- **get all images in the Marketplace of a particular type**

*az vm image list \
	--sku Wordpress \
	--output table \
	--all*
	
*az vm image list \
	--location westus \
	--publisher Microsoft \
	--output table*
	
- **list resize possibilities for a given VM**

*az vm list-vm-resize-options \
	--resource-group demo-rg \
	--name SampleVM \
	--output table*
	
- **resize a VM**

*az vm resize \
	--resource-group demo-rg \
	--name SampleVM \
	--size Standard_D2s_v3*
	
- **querying VM using JMES**

*az vm list-ip-addresses \
	--name SampleVM \
	--ouput table*
	
*az vm show \
	--resource-group demo-rg \
	--name SampleVM*
	
*az vm show \
	--resource-group demo-rg \
	--name SampleVM \
	--query "osProfile.adminUsername"*
	
*az vm show \
	--resource-group demo-rg \
	--name SampleVM \
	--query "netorkProfile.networkInterfaces[].id" -o tsv*
	
## Create a virtual network (VNet)

**- create a resource group**

*az group create \
	--name <resource-group> \
	--location <location>*
	
**- create a virtual network**

*az network vnet create \
	--name <vnet-name> \
	--resource-group <resource-group> \
	--subnet default*
	
## Encrypting VM disks

**- enable encrpytion [pre-req :: an enabled keyvault]**

	*az keyvault create \
	--name <keyvault-name> \
	--resource-group <resource-group> \
	--location <location> \
	--enabled-for-disk-encryption True*
	
**- encrpyt an existing disk**
	
	*az vm encryption enable \
	--resource-group <resource-group> \
	--name <vm-name> \
	--disk-encrption-keyvault <keyvault-name> \
	-volume-type [all | os | data] \
	--skipvmbackup*
	
**- view status of disk**

	*az vm encrpytion show \
	--resource-group <resource-group> \
	--name <vm-name>*
	
**- decrpyt a drive**

	*az vm encrpytion disable \
	--resource-group <resource-group> \
	--name <vm-name> \
	--volume-type [all | disk | data]*