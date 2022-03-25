# Deployment Subscription (update as needed)
$SubscriptionID = 'a73c2be5-9be8-4ec4-88ac-793de056902b'
$TenantName = 'MTPDemos'
$TenantID = 'cfda2bf1-d0e7-4417-ac82-a7c9a3001d22'

# Store Login/password (update to your own plz)
# NOTE: The azure account here must not be a Live ID.
$UserEmail = 'admin@MTPDemos.onmicrosoft.com'
$azureAccountName ="admin@MTPDemos.onmicrosoft.com"
$azurePassword = ConvertTo-SecureString "anupk@9363" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)


# Set the AAD Tenant ID
Select-AzureRmSubscription -TenantId $TenantID

Set-AzureRmContext -Tenant cfda2bf1-d0e7-4417-ac82-a7c9a3001d22

# Login to MSOnline (O365)
connect-msolservice -Credential $cred

# Import the Users
import-csv 'C:\Users\MatthewR\Source\Repos\MatthewAt3Sharp\Projects\MTP-AIR\MTP-AIR Deployment\MTPDemosFULLImport.csv' |
     ForEach{
          Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
     }