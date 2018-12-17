param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_\config.json})]
    [String]$ConfigFolder
)

Clear-Host

function CheckForCredentials
{
    #Check For Rubrik Credentials
    $CredFile = $ConfigFolder + $Config.rubrikCred
    If (-not (Test-Path -Path $CredFile))
    {
        Write-Host -ForegroundColor Yellow "$CredFile does not exist"
        $null = Read-Host "Press any key to continue and create the appropriate credential files"
        CreateCredentialFile -FilePath $CredFile -Message "Please enter a username and password with access to the Rubrik cluster..."
    }
}
function CreateCredentialFile ($FilePath, $Message)
{
    $Credential = Get-Credential -Message $Message
    $Credential | Export-Clixml -Path ($FilePath)
}
#append backslash if not there
if ($ConfigFolder -notmatch '.+?\\$') { $ConfigFolder += '\' }

#path to config file
$ConfigFile = $ConfigFolder + "config.json"

#load config into variable
$script:Config = Get-Content -Path $ConfigFile | ConvertFrom-Json

#check if credential file exists
CheckForCredentials


$Credential = Import-Clixml -Path ($ConfigFolder + $Config.rubrikCred)
$RubrikCluster = $config.rubrikServer

#Build header
$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.username + ':' + $Credential.GetNetworkCredential().password))
$header = @{'Authorization' = "Basic $auth" }
$token = ((Invoke-WebRequest -Headers $header -Method "POST" -Uri "https://$RubrikCluster/api/v1/session").Content | ConvertFrom-Json ).token
#update header to token for internal API calls
$header = @{'Authorization' = "Bearer $token"}
#=======================================
#Change vCenter Password inside Rubrik
#=======================================
$vcentername = "vcsa03.rubrik.us"
$vcenterusername = "administrator@vsphere.local"
$vcenterpassword = "SuperSecretPassword"

#Get vCenter ID
$response = Invoke-WebRequest -Method "Get" -Uri "https://$RubrikCluster/api/v1/vmware/vcenter" -Headers $head
$vcenterid = ((($response.Content | ConvertFrom-Json).Data) | Where-object { $_.name -eq "$vcentername" }).id

$body = @{
"hostname" = "$vcentername";
"username" = "$vcenterusername";
"password" = "$vcenterpassword";
} | ConvertTo-Json
$response = Invoke-WebRequest -Method "PUT" -uri "https://$RubrikCluster/api/v1/vmware/vcenter/$vcenterid" -Headers $head -Body $body
#================================================
# vCenter Done
#================================================

#================================================
#Guest OS Credentials
#================================================
$credentialUsername = "mike.preston@rubrik.us"
$credentialPassword = "NewSecretPassword"
# get credential ID
$response = Invoke-WebRequest -Method "Get" -Uri "https://$RubrikCluster/api/internal/vmware/guest_credential" -Headers $head
$credentialID = ((($response.Content | ConvertFrom-Json).Data) | Where-object { $_.username -eq "$credentialUsername" }).id
$body = @{
    "username" = "$credentialUsername";
    "password" = "$credentialPassword";
    } | ConvertTo-Json
$response = Invoke-WebRequest -Method "PUT" -uri "https://$RubrikCluster/api/internal/vmware/guest_credential/$credentialID" -Headers $head -Body $body
#================================================
# Guest Credential Done
#================================================

