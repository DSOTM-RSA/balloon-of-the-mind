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
	
	
	