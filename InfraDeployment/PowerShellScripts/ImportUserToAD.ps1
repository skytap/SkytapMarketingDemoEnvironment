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

$password = read-host "Password?" -AsSecureString
import-csv '$($root)\DataInput\SMDEFULLImport.csv' -Encoding UTF8 | foreach-object {New-ADUser -Name $_.Displayname -SamAccountName ($_.Firstname + "." + $_.Lastname) -GivenName $_.FirstName -Surname $_.LastName -City $_.City -Department $_.Department -DisplayName $_.DisplayName -EmailAddress $_.UserPrincipalName -Fax $_.Fax -MobilePhone $_.MobilePhone -Office $_.Office -OfficePhone $_.PhoneNumber -PostalCode $_.PostalCode -State $_.State -StreetAddress $_.StreetAddress -Title $_.Title -UserPrincipalName $_.UserPrincipalName -Enable $True -AccountPassword (ConvertTo-SecureString -string $password -AsPlainText -force) -passwordneverexpires $true}