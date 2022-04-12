
#Requires -Version 4
#Requires -RunAsAdministrator
#######################################
$DebugPreference = "Continue";
$VerbosePreference = "Continue";
$WarningPreference = "Continue";
$ErrorActionPreference = "Stop";
Set-PSDebug -Strict;
Set-StrictMode -Version 4;
#######################################
#
# Usage:
#
#   1. Edit variables below to suit needs
#   2. Edit parameters file with required URIs to point to assets in blob storage
#   3. Run script and cross fingers!
#
#######################################

cls
$root = "I:\Repos\SkytapMarketingDemoEnvironment\InfraDeployment";
CD $root;

# Set the module repository.
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Set the Connection type from Public to Private for WinRM
Get-NetConnectionProfile | % { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }

# Configure Windows Remote Management (WinRM), if it's not already configured.
winrm quickconfig -quiet

# Install the AzureRM.Bootstrapper module. 
Install-Module -Name AzureRm.BootStrapper

# Install and import needed Azure PowerShell Modules.
Install-Module MSOnline
Install-Module AzureADPreview
Import-Module -Name AzureRM

# ============ GENERAL CONFIGURATION ============

# Deployment Subscription (update as needed)
$SubscriptionID = '******************************'

# Store AAD Login & Password as "azureCred" (update to your own plz)
# NOTE: The azure account here must not be a Live ID.
$UserEmail = '**********@**********'
$azureAccountName ="**********@**********"
$azurePassword = ConvertTo-SecureString "******************" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

# Login to your Azure Subscription
Login-AzureRmAccount -Credential $azureCred

# Set the subscription context
Set-AzureRmContext  -SubscriptionID $AzureSubscriptionId

# Set the AAD Tenant ID
Select-AzureRmSubscription -TenantId ******************

# Login to MSOnline (O365)
connect-msolservice -Credential $azureCred

# Import the CSV of Bulk Users to import
$users = import-csv '$($root)\DataInput\SMDEAADUsers.csv' -Encoding UTF8 

# Import the Users
$users | foreach-object {New-MsolUser -DisplayName $_.Displayname -FirstName $_.FirstName -LastName $_.LastName -City $_.City -Department $_.Department -Fax $_.Fax -PasswordNeverExpires $True -PhoneNumber $_.PhoneNumber -PostalCode $_.PostalCode -State $_.State -StreetAddress $_.StreetAddress -Title $_.Title -UserPrincipalName $_.UserPrincipalName -Country $_.Country -Password C0ldL@b2277!}