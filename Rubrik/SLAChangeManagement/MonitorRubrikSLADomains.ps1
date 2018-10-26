param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$EnvironmentFile
)

function CheckForCredentials
{
    #Check For Rubrik Credentials
    $CredFile = $IdentityPath + $Environment.rubrikCred
    If (-not (Test-Path -Path $CredFile))
    {
        Write-Host -ForegroundColor Yellow "$CredFile does not exist"
        $null = Read-Host "Press any key to continue and create the appropriate credential files"
        CreateCredentialFile -FilePath $CredFile -Message "Please enter a username and password with access to the Rubrik cluster..."
    }

    #Check for SQL Credentials
    foreach ($database in $config.databases)
    {
        $CredFile = $IdentityPath + $database.TargetDBSQLCredentials
        If (-not (Test-Path -Path $CredFile))
        {
            Write-Host -ForegroundColor Yellow "$CredFile does not exist"
            $null = Read-Host "Press any key to continue and create the appropriate credential files"
            CreateCredentialFile -FilePath $CredFile -Message "Please enter a SQL username and password with access to $($database.TargetDBServer).  ***NOTE*** This must be a SQL account - Domain accounts are not supported."
        }
    }

}

#function to create xml credentials files if they do not exist
function CreateCredentialFile ($FilePath, $Message)
{
    $Credential = Get-Credential -Message $Message
    $Credential | Export-Clixml -Path ($FilePath)
}
clear

Import-Module Rubrik

