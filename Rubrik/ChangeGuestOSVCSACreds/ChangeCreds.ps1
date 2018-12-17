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

#Invoke-WebRequest -Method "POST" -Uri "https://"