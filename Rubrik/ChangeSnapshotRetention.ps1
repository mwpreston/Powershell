Import-Module Rubrik
$creds = Get-Credential
$cluster = "192.168.150.121"

$null = Connect-Rubrik -Server $cluster -Credential $creds

#sla domain id to change to
$sladomainid = (Get-RubrikSLA -Name "Silver").id 

$unmanaged_vms = (Invoke-RubrikRESTCall -Endpoint "unmanaged_object?object_type=VirtualMachine" -Method "GET" -api "internal").data

foreach ($vm in $unmanaged_vms)
{
    if ($vm.Name -eq 'MPRESTON-VM2')
    {       
        $snapshots = (Invoke-RubrikRESTCall -Endpoint "unmanaged_object/$($vm.id)/snapshot" -Method "GET" -api "internal").data.id
        $body = New-Object -TypeName PSObject -Property @{'slaDomainId'=$sladomainid}
        $body | Add-Member -Name "snapshotIds" -MemberType NoteProperty -Value $snapshots

        Invoke-RubrikRESTCall -Endpoint "unmanaged_object/snapshot/assign_sla" -Method "POST" -api "internal" -Body $body
    }
}
