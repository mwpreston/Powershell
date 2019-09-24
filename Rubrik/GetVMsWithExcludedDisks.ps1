$allVirtualDisks = (Invoke-RubrikRESTCall -Endpoint 'vmware/vm/virtual_disk' -Method GET -api internal).data
$results = @()
$total = ($allVirtualDisks | Measure-Object).Count 
$i = 0
foreach ($virtualdisk in $allVirtualDisks) {
    $vdInfo = Invoke-RubrikRestCall -Endpoint "vmware/vm/virtual_disk/$($virtualdisk.id)" -Method GET  
    $i++
    $percentComplete = ($i/$total)*100
    Write-Progress -Activity "Searching all virtual disks for exclusions..." -Status "$i of $total"  -PercentComplete $percentComplete
    if ($vdInfo.excludeFromSnapshots) {
        $vdInfo | Add-Member -MemberType NoteProperty -Name VMName -Value "$($virtualDIsk.vmName)"
        $results += $vdInfo
    }
    
}
$results