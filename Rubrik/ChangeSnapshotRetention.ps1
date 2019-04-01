Import-Module Rubrik
$creds = Get-Credential
$cluster = "192.168.150.121"

$null = Connect-Rubrik -Server $cluster -Credential $creds

#sla domain id to change to
$sladomainid = (Get-RubrikSLA -Name "Bronze").id 

$unmanaged_vms = Get-RubrikUnmanagedObject -Type VirtualMachine

foreach ($vm in $unmanaged_vms)
{
    if ($vm.name -eq 'MPRESTON-VM2')
    {       
        $snapshots = (Invoke-RubrikRESTCall -Endpoint "unmanaged_object/$($vm.id)/snapshot" -Method "GET" -api "internal").data.id

        $body = [pscustomobject]@{
            'slaDomainId'= $sladomainid
            "snapshotIds" = $snapshots
        }
        Invoke-RubrikRESTCall -Endpoint "unmanaged_object/snapshot/assign_sla" -Method "POST" -api "internal" -Body $body
    }
}
