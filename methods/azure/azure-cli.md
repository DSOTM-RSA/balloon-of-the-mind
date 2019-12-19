# Managing Azure Resources via the CLI

## Initializing a storage account

**Create a resource group**

```bash
az group create \
	--name demo-rg \
	--location westeurope
```	

**Check regions available**

```bash
az account list-locations \
	--query "[].{Region:name}" \
	--out table
```

**Create a general V2 storage account**

```bash
az storage account create \
	--name demo-store \
	--resource-group demo-rg \
	--location westeurope \
	--sku Standard_LRS \
	--kind StorageV2
```
	
- **Delete a resource group**

```bash
az group delete \
	--name demo-rg
```

## Working with blobs
	
**List storage account keys*

```bash
az storage-account keys list \
	--account-name demo-store \
	--resource-group demo-rg \
	--output table*
```

**Export variables**

```bash
export AZURE_STORAGE_ACCOUNT=" " \
	export AZURE_STORAGE_KEY=" 
```

**Create a container**

```bash
az storage container create \
	--name demo-container
```	

**Upload a blob to a container**

```bash
az storage blob upload \
	--container-name demo-container \
	--name sample.txt \
	--file sample.txt
```

**Bulk upload blobs to a container**

```bash
az storage blob upload-batch \
	--destination demo-container \
	--source /home \
	--pattern \*.txt \
  	--if-unmodifed-since 2019-09-15T2000Z \
	--[dry-run]
```	
	
**List the blobs in a container**	

```bash	
az storage blob list \
	--container-name demo-container \
	--output table
```	
	
**Download a blob**

```bash
az storage blob download \
	--container-name demo-container \
	--name sample.txt \
	--file ~/destination/path/to/file
```	
	
## Managing VMs

**create a Linux VM**

```bash
az vm create \
	--resource-group demo-rg \
	--name SampleVM \
	--image UbuntuLTS \
	--size "Standard_DS5_v2" \
	--admin-username azureuser \
	--generate-ssh-keys \
	--verbose
	--[no-wait]
```

**Get all images in the marketplace of a particular type**

```bash
az vm image list \
	--sku Wordpress \
	--output table \
	--all
```

```bash
az vm image list \
	--location westus \
	--publisher Microsoft \
	--output table
```

**List resize possibilities for a given VM**

```bash
az vm list-vm-resize-options \
	--resource-group demo-rg \
	--name SampleVM \
	--output table
```

**Resize a VM**

```bash
az vm resize \
	--resource-group demo-rg \
	--name SampleVM \
	--size Standard_D2s_v3
```

**Querying VM using JMES**

```bash
az vm list-ip-addresses \
	--name SampleVM \
	--ouput table
```

```bash
az vm show \
	--resource-group demo-rg \
	--name SampleVM
```	

```bash
az vm show \
	--resource-group demo-rg \
	--name SampleVM \
	--query "osProfile.adminUsername"
```

```bash
az vm show \
	--resource-group demo-rg \
	--name SampleVM \
	--query "netorkProfile.networkInterfaces[].id" -o tsv
```

## Create a virtual network (VNet)

**Create a resource group**

```bash
az group create \
	--name <resource-group> \
	--location <location>
```

**Create a virtual network**

```bash
az network vnet create \
	--name <vnet-name> \
	--resource-group <resource-group> \
	--subnet default
```
	
## Encrypting VM disks

**Enable encrpytion [pre-req :: an enabled keyvault]**

```bash
az keyvault create \
	--name <keyvault-name> \
	--resource-group <resource-group> \
	--location <location> \
	--enabled-for-disk-encryption True
```

**Encrpyt an existing disk**

```bash
az vm encryption enable \
	--resource-group <resource-group> \
	--name <vm-name> \
	--disk-encrption-keyvault <keyvault-name> \
	-volume-type [all | os | data] \
	--skipvmbackup
```
	
**View status of disk**

```bash
az vm encrpytion show \
	--resource-group <resource-group> \
	--name <vm-name>
```

**Decrpyt a drive**

```bash
az vm encrpytion disable \
	--resource-group <resource-group> \
	--name <vm-name> \
	--volume-type [all | disk | data]
```
