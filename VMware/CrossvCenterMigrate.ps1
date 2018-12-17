Import-Module VMware.vim
$sourceCreds = Get-Credential
$targetCreds = Get-Credential

$sourceVC = Connect-VIServer -Server vcsa.rubrik.us -Credential $sourceCreds
$destinationVC = Connect-VIServer -Server vcsa03.rubrik.us -Credential $targetCreds

$destinationHost = "esxi41.rubrik.us"
$destinationDatastore = Get-Datastore -Server $destinationVC -Name "Datastore"
$destinationPortGroup = Get-VirtualPortGroup -Server $destinationVC -Name 'VM_Production'

$vm = Get-VM -Server $sourceVC "MPRESTON-VMLINK"
$sourceNetworkAdapter = Get-NetworkAdapter -VM $vm

Move-VM -VM $vm -VMotionPriority High -Destination (Get-VMHost -Server $destinationVC -Name $destinationHost) `
 -NetworkAdapter $networkAdapter -PortGroup $destinationPortGroup -Datastore $destinationDatastore