param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_\config.json})]
    [String]$ConfigFolder
)

clear

Import-Module Rubrik

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
$null = Connect-Rubrik -Server $Config.rubrikServer -Credential $Credential
Write-Output "Rubrik Status: Connected to $($rubrikConnection.server)"


#Get Current SLAs

$previousslas = Import-Clixml $PSScriptRoot\slas\masterlist.txt
$currentslas = Get-RubrikSLA 

#run comparasin
$comparasins = Compare-Object -ReferenceObject $previousslas -DifferenceObject $currentslas -IncludeEqual -Property Id

foreach ($comparasin in $comparasins)
{

    if ($comparasin.SideIndicator -eq "=>")
    {
        Write-Output "SLA ($($comparasin.id)) still exists in current, but not in previous - this means it's new"
       
        
        #Get New SLA info
        #Log to change file
    }

    if ($comparasin.SideIndicator -eq "<=")
    {
        Write-Output "SLA ($($comparasin.id)) still exists previous, but not in current - this means it's deleted"
        # Get old SLA Info
        # Log to change file
        # rename individual sla file to -deleted
        

    }
    if ($comparasin.SideIndicator -eq "==")
    {
        Write-Output "SLA ($($comparasin.id)) still exists, time to dive deeper"
        # loop through these ids comparing current to previous
        # if change, log to change file
    }
}

# Export current SLA info into individual files.
 



