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
$MTPVMUnManagedInfraARMTemplateLocation = "$($root)\JSON\MTPDemo.InfraVMPool.template.unmanaged.json"
$MTPVMUnManagedClientARMTemplateLocation = "$($root)\JSON\MTPDemo.ClientVMPool.template.unmanaged.json"
$MTPVMUnManagedLinuxARMTemplateLocation = "$($root)\JSON\MTPDemo.LinuxVMPool.template.unmanaged.json"

# Define MTP-AIR Pool ARM VM Parameters
# Windows Server 2019 Infra Parameters
$MTPDC01ARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-DC01.parameters.json"
$MTPAADC01ARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-AADConnect01.parameters.json"

# Windows Server 2012 R2 Infra Parameters
$MTPWEB01ARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-WebServer01.parameters.json"

# Linux Ubuntu Server Infra Parameters
$MTPSQL01ARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-SQLServer01.parameters.json"

# Windows 10 Client Endpoint Parameters
$AarifSVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-AarifS.parameters.json"
$AlexWVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-AlexW.parameters.json"
$AnFulleVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-AnFulle.parameters.json"
$AnnHillVMARMParametersTemplateLocation = "$($root)\JSON\AATPDemo-AnnHill.parameters.json"
$BaMorelVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-BaMorel.parameters.json"
$DePoeVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-DePoe.parameters.json"
$ErGubbeVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-ErGubbe.parameters.json"
$GaErickVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-GaErick.parameters.json"
$JaLeverVMARMParametersTemplateLocation = "$($root)\JSON\AATPDemo-JaLever.parameters.json"
$LoSunshVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-LoSunsh.parameters.json"
$RoTambuVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-RoTambu.parameters.json"
$StConroVMARMParametersTemplateLocation = "$($root)\JSON\AATPDemo-StConro.parameters.json"

# Windows 8 Client Endpoint Parameters
$WiJohnsVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-WiJohns.parameters.json"

# Windows 7 Client Endpoint Parameters
$PeKrebsVMARMParametersTemplateLocation = "$($root)\JSON\MTPDemo-PeKrebs.parameters.json"

# Define MTP Pool Resource Groups
$MTPResourceGroupName = 'MTPDemoEnvironment'

# Define MTP Pool Regions
$MTPRegion = 'westus2'

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
$MTPVHDStorageAccountName = "mtpdemovmimages"

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
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-AADConnect01.vhd" -DestBlob "MTPDemo-AADConnect01.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-DC01.vhd" -DestBlob "MTPDemo-DC01.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows Server 2012 R2 Infra
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-WebServer01.vhd" -DestBlob "MTPDemo-WebServer01.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Linux Ubuntu Server Infra
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-SQLServer01.vhd" -DestBlob "MTPDemo-SQLServer01.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 10 Client Endpoints
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-AarifS.vhd" -DestBlob "MTPDemo-AarifS.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-AlexW.vhd" -DestBlob "MTPDemo-AlexW.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-AnFulle.vhd" -DestBlob "MTPDemo-AnFulle.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/AATPDemo-AnnHill.vhd" -DestBlob "AATPDemo-AnnHill.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-BaMorel.vhd" -DestBlob "MTPDemo-BaMorel.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-DePoe.vhd" -DestBlob "MTPDemo-DePoe.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-ErGubbe.vhd" -DestBlob "MTPDemo-ErGubbe.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-GaErick.vhd" -DestBlob "MTPDemo-GaErick.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/AATPDemo-JaLever.vhd" -DestBlob "AATPDemo-JaLever.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-LoSunsh.vhd" -DestBlob "MTPDemo-LoSunsh.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-RoTambu.vhd" -DestBlob "MTPDemo-RoTambu.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/AATPDemo-StConro.vhd" -DestBlob "AATPDemo-StConro.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 8.1 Enterprise N Client Endpoint
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-WiJohns.vhd" -DestBlob "MTPDemo-WiJohns.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 7 Ultimate N Client Endpoint
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/MTP/MTPDemo-PeKrebs.vhd" -DestBlob "MTPDemo-PeKrebs.vhd" -DestContainer $MTPVHDBaseVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Copy MTP VM BASE Image Storage Containers to MTP Running VMs VHD Storage Containers
# Windows Server 2019 Infra
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-AADConnect01.vhd" -DestBlob "MTPDemo-AADConnect01.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-DC01.vhd" -DestBlob "MTPDemo-DC01.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows Server 2012 Infra
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-WebServer01.vhd" -DestBlob "MTPDemo-WebServer01.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Linux Ubuntu Server Infra
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-SQLServer01.vhd" -DestBlob "MTPDemo-SQLServer01.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 10 Client Endpoints
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-AarifS.vhd" -DestBlob "MTPDemo-AarifS.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-AlexW.vhd" -DestBlob "MTPDemo-AlexW.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-AnFulle.vhd" -DestBlob "MTPDemo-AnFulle.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/AATPDemo-AnnHill.vhd" -DestBlob "AATPDemo-AnnHill.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-BaMorel.vhd" -DestBlob "MTPDemo-BaMorel.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-DePoe.vhd" -DestBlob "MTPDemo-DePoe.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-ErGubbe.vhd" -DestBlob "MTPDemo-ErGubbe.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-GaErick.vhd" -DestBlob "MTPDemo-GaErick.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/AATPDemo-JaLever.vhd" -DestBlob "AATPDemo-JaLever.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-LoSunsh.vhd" -DestBlob "MTPDemo-LoSunsh.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-RoTambu.vhd" -DestBlob "MTPDemo-RoTambu.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext
Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/AATPDemo-StConro.vhd" -DestBlob "AATPDemo-StConro.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 8.1 Enterprise N Client Endpoint
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-WiJohns.vhd" -DestBlob "MTPDemo-WiJohns.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Windows 7 Ultimate N Client Endpoint
#Start-AzStorageBlobCopy -AbsoluteUri "https://mtpdemovmimages.blob.core.windows.net/basevhds/MTPDemo-PeKrebs.vhd" -DestBlob "MTPDemo-PeKrebs.vhd" -DestContainer $MTPVHDRunningVHDStorageContainerName -DestContext $MTPVHDStorageContext

# Deploy the VMs in the MTP Resource Group
# Run ARM template deployment in Pool 01

# Windows Server 2019 Infra
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedInfraARMTemplateLocation -TemplateParameterFile $MTPDC01ARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedInfraARMTemplateLocation -TemplateParameterFile $MTPAADC01ARMParametersTemplateLocation -Force

# Windows Server 2012R2 Infra
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $MTPWEB01ARMParametersTemplateLocation -Force

# Linux Ubuntu Server Infra
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedLinuxARMTemplateLocation -TemplateParameterFile $MTPSQL01ARMParametersTemplateLocation -Force

# Windows 10 Client Endpoints
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $AarifSVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $AlexWVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $AnFulleVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $AnnHillVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $BaMorelVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $DePoeVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $ErGubbeVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $GaErickVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $JaLeverVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $LoSunshVMARMParametersTemplateLocation -Force
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $RoTambuVMARMParametersTemplateLocation -Force
New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $StConroVMARMParametersTemplateLocation -Force

# Windows 8.1 Enterprise N Client Endpoint
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $WiJohnsVMARMParametersTemplateLocation -Force

# Windows 7 Ultimate N Client Endpoint
#New-AzResourceGroupDeployment -ResourceGroupName $MTPResourceGroupName -TemplateFile $MTPVMUnManagedClientARMTemplateLocation -TemplateParameterFile $PeKrebsVMARMParametersTemplateLocation -Force
