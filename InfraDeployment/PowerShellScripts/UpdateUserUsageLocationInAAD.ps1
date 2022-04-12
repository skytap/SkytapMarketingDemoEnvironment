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

# Install and import needed Azure PowerShell Modules.
Install-Module MSOnline
Install-Module AzureADPreview
Import-Module -Name AzureRM


# ============ GENERAL CONFIGURATION ============

# Deployment Subscription (update as needed)
$SubscriptionID = '******************'
$TenantName = '******************'
$TenantID = '******************************'

# Store Login/password (update to your own plz)
# NOTE: The azure account here must not be a Live ID.
$UserEmail = '**********@**********'
$azureAccountName ="**********@**********"
$azurePassword = ConvertTo-SecureString "******************" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)


# Set the AAD Tenant ID
Select-AzureRmSubscription -TenantId $TenantID

Set-AzureRmContext -Tenant ******************

# Login to MSOnline (O365)
connect-msolservice -Credential $cred

# Import the AAD Users
import-csv '$($root)\DataInput\SMDEAADUsers.csv' -Encoding UTF8 |
     ForEach{
          Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
     }

# Import the AD Users
import-csv '$($root)\DataInput\SMDEFULLImport.csv' -Encoding UTF8 |
     ForEach{
          Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
     }