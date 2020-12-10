# ======================== Script Variables ========================
# Nutanix cluster and prism information
$prism = "192.168.10.170"
$rubrik = "192.168.150.131"
# Path to credential file
$NutanixCredPath = "C:\trash\nutanix\Nutanixcreds.xml"
$RubrikCredPath = "C:\trash\nutanix\RubrikCreds.xml"
# Category name containing SLA Values
$SLADomainCategory = "SLADomain"
# ==================================================================

# If CredPaths doesn't exist, create it.
$NutanixCredPathExists = [System.IO.File]::Exists($NutanixCredPath)
if ($NutanixCredPathExists -eq $false) {
  Get-Credential -Message "Need Nutanix Credentials" | EXPORT-CLIXML "$NutanixCredPath"
}
$RubrikCredPathExists = [System.IO.File]::Exists($RubrikCredPath)
if ($RubrikCredPathExists -eq $false) {
  Get-Credential -Message "Need Rubrik Credentials" | EXPORT-CLIXML "$RubrikCredPath"
}

# Build out headers for Nutanix
$NutanixCredentials = IMPORT-CLIXML "$NutanixCredPath"
$RESTAPIUser = $NutanixCredentials.UserName
$RESTAPIPassword = $NutanixCredentials.GetNetworkCredential().Password
$Headers = @{
    "Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($RESTAPIUser+":"+$RESTAPIPassword ))}

# Establish connection to Rubrik
Connect-Rubrik $rubrik -Credential (Import-CLIXML $RubrikCredPath) | Out-Null

# Get list of all values within $SLADomainCategory
$Uri = "https://$($prism):9440/api/nutanix/v3/categories/$($SLADomainCategory)/list"
$body = '{"kind":"category"}'
$categoryValues = (Invoke-RestMethod -uri $Uri -Body $body -Method POST -Headers $Headers  -ContentType "application/json" -SkipCertificateCheck).entities

#Loop through each category value
foreach ($categoryValue in $categoryValues) {
    $catVal = $categoryValue.value

    #Ensure SLA Domain exists within Rubrik
    $sladomain = Get-RubrikSLA -Name $catVal -PrimaryClusterID $local

    if ($sladomain) {


        Write-Host "Processing $catVal"

        # Retrieve list of VMs in category
        $Uri = "https://$($prism):9440/api/nutanix/v3/category/query"
        $body = @"
        {
            "usage_type": "APPLIED_TO",
            "group_member_offset": 0,
            "group_member_count": 100,
            "category_filter": {
            "type": "CATEGORIES_MATCH_ANY",
            "params": {
                "$SLADomainCategory": ["$catVal"]
        },
        "kind_list": ["vm"]
            },
            "api_version": "3.1.0"
        }
"@

        $vms = (Invoke-RestMethod -Method Post -Uri $Uri -Headers $Headers -Body $body -ContentType "application/json" -SkipCertificateCheck).results.kind_reference_list

        # loop through each vm in vms and assign to proper SLA Domain ($catVal)
        foreach ($vm in $vms) {
            Write-Host "Adding $($vm.name) to $catVal"
            # Assign SLA in Rubrik
            Get-RubrikNutanixVM -Name "$($vm.name)" | Protect-RubrikNutanixVM -SLA $catVal
        }
    }
    else {
        Write-Host "$catVal doesn't exist in Rubrik, skipping"
    }

}








