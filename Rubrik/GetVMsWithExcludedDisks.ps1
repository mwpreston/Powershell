$vms = Get-RubrikVM -PrimaryClusterID local -Relic:$false -DetailedObject
$totalvms = ($vms | Measure-Object).Count
$i = 0
$results = @()
foreach ($vm in $vms) {
    $i++
    $percentComplete = ($i/$totalvms)*100
    Write-Progress -Activity "Searching all VMs for disk exclusions..." -Status "VM $i of $totalvms"  -PercentComplete $percentComplete
    foreach ($vdisk in $vm.virtualDiskIds) {
        $vdInfo = Invoke-RubrikRestCall -Endpoint "vmware/vm/virtual_disk/$vdisk" -Method GET
        if ($vdInfo.excludeFromSnapshots) {
            $vdInfo | Add-Member -MemberType NoteProperty -Name VMName -Value "$($vm.Name)"
            $vdInfo | Add-Member -MemberType NoteProperty -Name VMId -Value "$($vm.id)"
            $results += $vdInfo
        }
    }
    
}
$results