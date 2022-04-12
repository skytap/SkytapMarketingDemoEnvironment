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

# Currently Set to Deploy Pool(s): Skytap Marketing Demo Environment

# Define SMDE Pool ARM SaaS Template
$SMDESaaSARMTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.SaaS.template.unmanaged.json"

# Define SMDE Pool ARM VM Templates
$SMDEVMUnManagedInfraARMTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.InfraVMPool.template.unmanaged.json"
$SMDEVMUnManagedClientARMTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.ClientVMPool.template.unmanaged.json"

# Define SMDE Pool ARM vNet Template
$SMDEvNetARMTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.vNet.template.unmanaged.json"

# Define SMDE Pool ARM Network Security Group Template
$SMDENSGARMTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.NSG.template.unmanaged.json"

# Define SMDE Pool ARM Virtual Network Gateway Template
$SMDEVNGARMTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.VNG.template.unmanaged.json"

# Define SMDE Pool ARM SaaS Parameters
$SMDESaaSARMParametersTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.SaaS.parameters.json"

# Windows Server 2022 Infra Endpoint Parameters
$SMDEDC02ARMParametersTemplateLocation = "$($root)\JSON\SMDE-DC02.parameters.json"

# Windows 10 Client Endpoint Parameters
$WSAVM01ARMParametersTemplateLocation = "$($root)\JSON\SMDE-WindowsServerAdmin01.parameters.json"

# Define SMDE Pool ARM vNet Parameters
$SMDEvNetARMParametersTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.vNet.parameters.json"

# Define SMDE Pool ARM Network Security Group Parameters
$SMDENSGARMParametersTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.NSG.parameters.json"

# Define SMDE Pool ARM Virtual Network Gateway Template
$SMDEVNGARMParametersTemplateLocation = "$($root)\JSON\SMDE.MarketingSoADemoEnvironment.VNG.parameters.json"

# Define SMDE Pool Resource Groups
$SMDEResourceGroupName = 'MarketingDemoEnvironment'

# Define SMDE Pool Regions
$SMDERegion = 'UKSouth'

# Deployment Subscription (update as needed)
$SubscriptionID = '******************************'

# Store Login/password (update to your own plz)
# NOTE: The azure account here must not be a Live ID.
$UserEmail = '**********@**********'
$azureAccountName ="**********@**********"
$azurePassword = ConvertTo-SecureString "******************" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

# Define Azure Storage Info
$StorageSKUType = "Standard_GRS"
$SMDEVHDStorageAccountName = "smdeinfrastorage"

$SMDEVHDBaseVHDStorageContainerName = "basevhds"
$SMDEVHDRunningVHDStorageContainerName = "vhds"

# Login in to Azure
Login-AzAccount -Credential $cred

# Set the subscription context
Set-AzContext  -SubscriptionID $SubscriptionID

# Create SMDE Pool Resource Groups (check before running - may already exist)
New-AzResourceGroup -Name $SMDEResourceGroupName -Location $SMDERegion

# Create SMDE Pool Storage Accounts (check before running - may already exist)
New-AzStorageAccount -Name $SMDEVHDStorageAccountName -Location $SMDERegion -Type $StorageSKUType -ResourceGroupName $SMDEResourceGroupName

# Get SMDE Pool Storage Accounts
$SMDEVHDStorageAccount = Get-AzStorageAccount -Name $SMDEVHDStorageAccountName -ResourceGroupName $SMDEResourceGroupName

# Retrieve/Create the Storage Context
$SMDEVHDStorageContext = $SMDEVHDStorageAccount.Context

# Create SMDE-AIR Storage Containers for the VHDs (check before running - may already exist)
New-AzStorageContainer -Name $SMDEVHDBaseVHDStorageContainerName -Context $SMDEVHDStorageContext -Permission Container
New-AzStorageContainer -Name $SMDEVHDRunningVHDStorageContainerName -Context $SMDEVHDStorageContext -Permission Container

# Deploy the SoA Marketplace SaaS offering
New-AzResourceGroupDeployment -ResourceGroupName $SMDEResourceGroupName -TemplateFile $SMDESaaSARMTemplateLocation -TemplateParameterFile $SMDESaaSARMParametersTemplateLocation -Force

# Deploy the SMDE vNet
New-AzResourceGroupDeployment -ResourceGroupName $SMDEResourceGroupName -TemplateFile $SMDEvNetARMTemplateLocation -TemplateParameterFile $SMDEvNetARMParametersTemplateLocation -Force

# Deploy the SMDE Network Security Group
New-AzResourceGroupDeployment -ResourceGroupName $SMDEResourceGroupName -TemplateFile $SMDENSGARMTemplateLocation -TemplateParameterFile $SMDENSGARMParametersTemplateLocation -Force

# Deploy the SMDE Virtual Network Gateway
New-AzResourceGroupDeployment -ResourceGroupName $SMDEResourceGroupName -TemplateFile $SMDEVNGARMTemplateLocation -TemplateParameterFile $SMDEVNGARMParametersTemplateLocation -Force

# Copy SMDE VM BASE Image Storage Containers to SMDE Running VMs VHD Storage Containers
# Windows Server 2022 Base Image
Start-AzStorageBlobCopy -AbsoluteUri "https://smdeinfrastorage.blob.core.windows.net/basevhds/SMDE-Server2022BaseImage.vhd" -DestBlob "SMDE-DC02.vhd" -DestContainer $SMDEVHDRunningVHDStorageContainerName -DestContext $SMDEVHDStorageContext

# Windows 11 Client Endpoints
Start-AzStorageBlobCopy -AbsoluteUri "https://smdeinfrastorage.blob.core.windows.net/basevhds/SMDE-Windows11BaseImage.vhd" -DestBlob "SMDE-WindowsServerAdmin01.vhd" -DestContainer $SMDEVHDRunningVHDStorageContainerName -DestContext $SMDEVHDStorageContext

# Deploy the VMs in the SMDE Resource Group
# Run ARM template deployment in Pool 01

# Windows Server 2022 Endpoints
New-AzResourceGroupDeployment -ResourceGroupName $SMDEResourceGroupName -TemplateFile $SMDEVMUnManagedInfraARMTemplateLocation -TemplateParameterFile $SMDEDC02ARMParametersTemplateLocation -Force

# Windows 11 Client Endpoints
New-AzResourceGroupDeployment -ResourceGroupName $SMDEResourceGroupName -TemplateFile $SMDEVMUnManagedClientARMTemplateLocation -TemplateParameterFile $WSAVM01ARMParametersTemplateLocation -Force
