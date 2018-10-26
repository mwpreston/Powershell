# Monitor SLA Domains

This project is designed with the intent of running the script on a scheduled task in order to detect, monitor, and alert upon changes to SLA Domains within Rubrik CDM.

## Prerequisites
 - [Rubrik Powershell Module](https://github.com/rubrikinc/PowerShell-Module)

 
## Configuration

There are a couple main files used to hold configuration for the script. The config.json file and an encrypted xml file holding credentials to the Rubrik CDM.  Both should be placed in a folder which is passed to the script via an argument

### Configuration Folder

The config folder contains a JSON file (config.json) that describe the Rubrik Cluster information. A sample configuration looks like:
```javascript
{
    "rubrikServer": "172.17.28.11",
    "rubrikCred": "rubrikCred.xml"
}
```
### Identity

Inside of the config folder you should also have a secure XML file containing encrypted credentials to the Rubrik CDM. This filename should match the one entered in the "rubrikCred" attribute of the config.json configuration file.

Secure XML files may be created manually utilizing the Export-Clixml cmdlet, or better yet, let the script create them for you. Before each run a check is executed for the existance of the credential files listed in the config.json file. If the file does not exist, you will be prompted to create them automatically. * This is the only time manual intervention will be required in this script.

Note: Secure XML files can only be decrypted by the user account that created them.

## Usage

Once the configuration and identity requirements are met, the script can be executed using the following syntax...
```javascript
.\MonitorRubrikSLADomains.ps1 -ConfigFolder c:\config\
```
Output from script may be logged to a file by piping the entire script to Out-File as follows:
```javascript
.\MonitorRubrikSLADomains.ps1 -ConfigFolder ./config  | Out-File C:\scriptoutput.txt
```
