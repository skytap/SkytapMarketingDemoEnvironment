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
$root = "D:\Repos\ADOMTPDemos\MTPInfraDeployment\";
CD $root;


# ============ GENERAL CONFIGURATION ============

# Currently Set to Deploy Pool(s): MTP Demos

# Define MTP Pool ARM VM Templates
$MTPVMUnManagedInfraARMTemplateLocation = "$($root)\JSON\M365Defender.InfraVMPool.template.unmanaged.json"
$MTPVMUnManagedClientARMTemplateLocation = "$($root)\JSON\M365Defender.ClientVMPool.template.unmanaged.json"

# Define MTP-AIR Pool ARM VM Parameters
# Windows Server 2019 Infra Parameters
$MTPDC01ARMParametersTemplateLocation = "$($root)\JSON\M365Defender-DC01.parameters.json"

# Windows 10 Client Endpoint Parameters
$AlexWVMARMParametersTemplateLocation = "$($root)\JSON\M365Defender-AlexW.parameters.json"
$AarifSVMARMParametersTemplateLocation = "$($root)\JSON\M365Defender-AarifS.parameters.json"
$BaMorelVMARMParametersTemplateLocation = "$($root)\JSON\M365Defender-BaMorel.parameters.json"
$ErGubbeVMARMParametersTemplateLocation = "$($root)\JSON\M365Defender-ErGubbe.parameters.json"
$RoTambuVMARMParametersTemplateLocation = "$($root)\JSON\M365Defender-RoTambu.parameters.json"

# Define MTP Pool Resource Groups
$MTPResourceGroupName = 'M365DefenderEnvironment'

# Define MTP Pool Regions
$MTPRegion = 'NorthCentralUS'

# Deployment Subscription (update as needed)
$SubscriptionID = 'd12e1db0-00d4-499e-8429-d0f374fefced'

# Store Login/password (update to your own plz)
# NOTE: The azure account here must not be a Live ID.
$UserEmail = 'admin@MTPDemos.onmicrosoft.com'
$azureAccountName ="admin@MTPDemos.onmicrosoft.com"
$azurePassword = ConvertTo-SecureString "P3Y-294Sentinel" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

# Define Azure Storage Info
$StorageSKUType = "Standard_GRS"
$MTPVHDStorageAccountName = "m365defendervmimages"

$MTPVHDBaseVHDStorageContainerName = "basevhds"
$MTPVHDRunningVHDStorageContainerName = "vhds"

# Login in to Azure
Login-AzAccount -Credential $cred

# Set the subscription context
Set-AzContext  -SubscriptionID $SubscriptionID

# Create MTP Pool Resource Groups (check before running - may already exist)
#New-AzResourceGroup -Name $MTPResourceGroupName -Location $MTPRegion

# Create MTP Pool Storage Accounts (check before running - may already exist)
#New-AzStorageAccount -Name $MTPVHDStorageAccountName -Location $MTPRegion -Type $StorageSKUType -ResourceGroupName $MTPResourceGroupName

# Get MTP Pool Storage Accounts
$MTPVHDStorageAccount = Get-AzStorageAccount -Name $MTPVHDStorageAccountName -ResourceGroupName $MTPResourceGroupName

# Retrieve/Create the Storage Context
$MTPVHDStorageContext = $MTPVHDStorageAccount.Context

# Create MTP-AIR Storage Containers for the VHDs (check before running - may already exist)
#New-AzStorageContainer -Name $MTPVHDBaseVHDStorageContainerName -Context $MTPVHDStorageContext -Permission Container
#New-AzStorageContainer -Name $MTPVHDRunningVHDStorageContainerName -Context $MTPVHDStorageContext -Permission Container

# Copy MTP Primary Base Images to MTP BASE Image Storage Containers - TAKES A VERY LONG TIME!
# Windows Server 2019 Infra
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/M365Defender/M365Defender-DC01.vhd" -DestBlob "M365Defender-DC01.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 10 Client Endpoints
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/M365Defender/M365Defender-AlexW.vhd" -DestBlob "M365Defender-AlexW.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/M365Defender/M365Defender-BaMorel.vhd" -DestBlob "M365Defender-BaMorel.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/M365Defender/M365Defender-ErGubbe.vhd" -DestBlob "M365Defender-ErGubbe.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/M365Defender/M365Defender-RoTambu.vhd" -DestBlob "M365Defender-RoTambu.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/M365Defender/M365Defender-AarifS.vhd" -DestBlob "M365Defender-AarifS.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Copy MTP VM BASE Image Storage Containers to MTP Running VMs VHD Storage Containers
# Windows Server 2019 Infra
#Start-AzStorageBlobCopy -AbsoluteUri "https://m365defendervmimages.blob.core.windows.net/basevhds/M365Defender-DC01.vhd" -DestBlob "M365Defender-DC01.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 10 Client Endpoints
#Start-AzStorageBlobCopy -AbsoluteUri "https://m365defendervmimages.blob.core.windows.net/basevhds/M365Defender-AlexW.vhd" -DestBlob "M365Defender-AlexW.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://m365defendervmimages.blob.core.windows.net/basevhds/M365Defender-AarifS.vhd" -DestBlob "M365Defender-AarifS.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
Start-AzStorageBlobCopy -AbsoluteUri "https://m365defendervmimages.blob.core.windows.net/basevhds/M365Defender-BaMorel.vhd" -DestBlob "M365Defender-BaMorel.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
Start-AzStorageBlobCopy -AbsoluteUri "https://m365defendervmimages.blob.core.windows.net/basevhds/M365Defender-ErGubbe.vhd" -DestBlob "M365Defender-ErGubbe.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://m365defendervmimages.blob.core.windows.net/basevhds/M365Defender-RoTambu.vhd" -DestBlob "M365Defender-RoTambu.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Deploy the VMs in the MTP Resource Group
# Run ARM template deployment in Pool 01

# Windows Server 2019 Infra
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedInfraARMTemplateLocation -TemplateParameterFile $MTPDC01ARMParametersTemplateLocation -Force

# Windows 10 Client Endpoints
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $AarifSWVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $AlexWVMARMParametersTemplateLocation -Force
New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $BaMorelVMARMParametersTemplateLocation -Force
New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $ErGubbeVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $RoTambuVMARMParametersTemplateLocation -Force