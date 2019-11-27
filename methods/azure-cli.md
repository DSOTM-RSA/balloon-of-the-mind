# Managing Azure Resources via the CLI

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

*export AZURE_STORAGE_ACCOUNT=" " \*
*export AZURE_STORAGE_KEY=" "*

- **create a container**

*az storage container create \
	--name demo-container*
	
- **upload a blob to the container**

*az storage blob upload \
	--container-name demo container \
	--name sample.txt \
	--file sample.txt* 
