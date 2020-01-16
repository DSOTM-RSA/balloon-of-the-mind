param([string]$rg, [string]$loc)

# import az module
Import-Module -name Az

# connect to azure
Connect-AzAccount

# create specific resource group
New-AzResourceGroup -Name $rg -Location $loc