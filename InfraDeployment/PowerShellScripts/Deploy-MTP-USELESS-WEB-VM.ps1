param([Parameter(Position=0,mandatory=$false)][string]$azureUserName, [Parameter(Position=0,mandatory=$false)][string]$azurePassword, [string]$templateLocation = "C:\Users\Eric.Gubbels\OneDrive - MTPDemos\Documents")

#  Usage: .\Deploy-MTP-USE-WEB-VM.ps1 -azureUserName <azure-username> -azurePassword <azure-password> -templateLocation <vm-template-location>

#   Edit variables above to suit needs 

#   Edit parameters file with required URIs to point to assets in blob storage 

#   Run script and cross fingers! 

$dateValue = Get-Date -Format "MMddyyyy"

# Define MTP Web ARM VM Templates 

$MTPVMUnManagedARMTemplateLocation = "$templateLocation\MTPDemo.UselessWebVM.template.unmanaged.json" 

# Define MTP-AIR Pool ARM VM Parameters 

$MTPWEBARMParametersBaseTemplateLocation = "$templateLocation\MTP-Web.parameters.json" 
$MTPWEBARMParametersTemplateLocation = "$templateLocation\MTP-Web$dateValue.parameters.json" 

#Update the ARM template parameters file with current date string

((Get-Content -path $MTPWEBARMParametersBaseTemplateLocation -Raw) -replace '##Date##',$dateValue) | Set-Content -Path $MTPWEBARMParametersTemplateLocation

#Base image VHD location
$imageBlobLocation = "https://mtpdemovmimages.blob.core.windows.net/basevhds/Windows2019ServerCORE.vhd"

# Define MTP Resource Group 

$MTPResourceGroupName = 'MTPDemoEnvironment' 

# Define MTP Regions 

$MTPRegion = 'westus2' 

# Deployment Subscription (update as needed) 

$SubscriptionID = 'd12e1db0-00d4-499e-8429-d0f374fefced' 


# Define Azure Storage Info 

$StorageSKUType = "Standard_GRS" 

$MTPVHDStorageAccountName = "mtpdemovmimages" 

$MTPVHDBaseVHDStorageContainerName = "basevhds" 

$MTPVHDRunningVHDStorageContainerName = "vhds" 
 

# Store Login/password (update to your own plz) 

# NOTE: The azure account here must not be a Live ID. 

$azureUserName ="Admin@mtpdemos.onmicrosoft.com"
$azurePassword= "P3Y-294Sentinel"

$securePassword = ConvertTo-SecureString $azurePassword -AsPlainText -Force 

$cred = New-Object System.Management.Automation.PSCredential($azureUserName, $securePassword) 

 

# Login in to Azure 

Login-AzureRmAccount -Credential $cred 

 

# Set the subscription context 

Set-AzureRmContext  -SubscriptionID $SubscriptionID 

 

# Get MTP Storage Accounts 

$MTPVHDStorageAccount = Get-AzureRMStorageAccount -Name $MTPVHDStorageAccountName -ResourceGroupName $MTPResourceGroupName 

 

# Retrieve/Create the Storage Context 

$MTPVHDStorageContext = $MTPVHDStorageAccount.Context 

 

# Copy MTP Web VM BASE Image from Base Image Storage Container to MTP Running VMs VHD Storage Containers 

# Web Server VM 

Start-AzureStorageBlobCopy -AbsoluteUri $imageBlobLocation -DestBlob "MTP-Web$dateValue.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext 

# Deploy the VMs in the MTP Demo Resource Group 

# Run ARM template deployment 

#Start-Sleep -Seconds 180

New-AzureRmResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedARMTemplateLocation -TemplateParameterFile $MTPWEBARMParametersTemplateLocation -Force  