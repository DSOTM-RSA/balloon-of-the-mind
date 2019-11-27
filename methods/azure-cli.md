# Managing Azure Resources via the CLI

- create a resource group

az group create \
	--name demo-rg
	--location westeurope
	
- check regions available

az account list-locations \
	--query "[].{Region:name}" \
	--out table
	
	
	