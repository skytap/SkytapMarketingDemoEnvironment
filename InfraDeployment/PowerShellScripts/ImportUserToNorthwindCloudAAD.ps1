$ErrorActionPreference = "Stop";
Set-PSDebug -strict;
Set-StrictMode -version 3;

# Set the module repository and the execution policy.
Set-ExecutionPolicy RemoteSigned 
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Set the Connection type from Public to Private for WinRM
Get-NetConnectionProfile | % { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }

# Configure Windows Remote Management (WinRM), if it's not already configured.
winrm quickconfig -quiet

# Install the AzureRM.Bootstrapper module. 
Install-Module -Name AzureRm.BootStrapper

# Install and import the API Version Profile required by Azure Stack into the current PowerShell session.
Use-AzureRmProfile -Profile 2017-03-09-profile -Force
Import-Module -Name AzureRM -RequiredVersion 1.2.11

# Store AAD Login & Password as "azureCred"
$azureAccountName = "svcAzureStackAdmin@northwindcloud.onmicrosoft.com"
$azurePassword = ConvertTo-SecureString "C0ldL@b2277!" -AsPlainText -Force
$azureCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

# Set your Subscription ID - This is subscription ID you want to link your Azure Stack deployment to.
$AzureSubscriptionId ="5b3392d5-4e67-474b-af6b-437f6c38cbc4"

# Login to your Azure Subscription
Login-AzureRmAccount -Credential $azureCred

# Set the subscription context
Set-AzureRmContext  -SubscriptionID $AzureSubscriptionId

# Set the AAD Tenant ID
Select-AzureRmSubscription -TenantId cc92a154-387d-4123-9411-37689fa05418

# Login to MSOnline (O365)
connect-msolservice -Credential $azureCred

# Import the CSV of Bulk Users to import
$users = import-csv 'C:\Users\MatthewR\3Sharp\Azure IT Pro Demos - Azure Stack Deployment\Northwind AAD\NorthwindImportFull.csv' -Encoding UTF8 

# Import the Users
$users | foreach-object {New-MsolUser -DisplayName $_.Displayname -FirstName $_.FirstName -LastName $_.LastName -City $_.City -Department $_.Department -Fax $_.Fax -PasswordNeverExpires $True -PhoneNumber $_.PhoneNumber -PostalCode $_.PostalCode -State $_.State -StreetAddress $_.StreetAddress -Title $_.Title -UserPrincipalName $_.UserPrincipalName -Country $_.Country -Password C0ldL@b2277!}