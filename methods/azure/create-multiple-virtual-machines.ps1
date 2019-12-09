param([string]$resourceGroup, [int]$total)

# import az module
Import-Module -name Az

# connect to azure
Connect-AzAccount

# get user input
$adminCredential = Get-Credential -Message "Enter a strong admin username and password"

# create virtual machines
For ($i=1; $i -le $total; $i++)
{

$vmName = "DemoVM" + $i
Write-Host "creating VM: " $vmName

New-AzVm -ResourceGroupName $resourceGroup -Name $vmName -Credential $adminCredential -Image UbuntuLTS 



} 