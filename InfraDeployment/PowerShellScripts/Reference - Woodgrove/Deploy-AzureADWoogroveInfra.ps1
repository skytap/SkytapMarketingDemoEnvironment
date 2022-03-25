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
# this section needs to be updated - this is quick and dirty currently. 
CD "E:\Repos\iwashuman2021\Projects\MicrosoftAzureActiveDirectoryProjects\Woodgrove.net";
$root = "E:\Repos\iwashuman2021\Projects\MicrosoftAzureActiveDirectoryProjects\Woodgrove.net";

Install-Module -Name AzureADPreview
Install-Module -Name Az -AllowPrerelease
Import-Module -Name AzureAD
Install-Module -Name MSOnline -force

# ============ GENERAL CONFIGURATION ============

# Currently Set to Deploy Pool(s): Woodgrove.net

# Define AzureAD GTP Pool ARM VM Templates
$WoodgroveInfraVMPoolUnManagedARMTemplateLocation = "$($root)\aad.woodgrove.infravmpool.template.unmanaged.json"
$WoodgroveDMZVMPoolUnManagedARMTemplateLocation = "$($root)\aad.woodgrove.dmzvmpool.template.unmanaged.json"
$WoodgroveLinuxVMPoolUnManagedARMTemplateLocation = "$($root)\aad.woodgrove.infralinuxvmpool.template.unmanaged.json"
$WoodgroveClientVMPoolUnManagedARMTemplateLocation = "$($root)\aad.woodgrove.clientvmpool.template.unmanaged.json"

# Define AzureAD GTP Pool ARM VM Parameters
# Server Infra
$WoodgroveDC01ARMParametersTemplateLocation = "$($root)\Woodgrove-DC01.parameters.json"
$WoodgroveADFS01ARMParametersTemplateLocation = "$($root)\Woodgrove-ADFS01.parameters.json"
$WoodgroveAPPProxy01ARMParametersTemplateLocation = "$($root)\Woodgrove-AppProxy01.parameters.json"

# Linux Server Endpoints
$WoodgroveUbuntuLinuxVM01ARMParametersTemplateLocation = "$($root)\Woodgrove-UbuntuLinuxServer01.parameters.json"
$WoodgroveUbuntuLinuxVM02ARMParametersTemplateLocation = "$($root)\Woodgrove-UbuntuLinuxServer02.parameters.json"
$WoodgroveUbuntuLinuxVM03ARMParametersTemplateLocation = "$($root)\Woodgrove-UbuntuLinuxServer03.parameters.json"

# Client Endpoints
$WoodgroveWindows10ClientVM01ARMParametersTemplateLocation = "$($root)\Woodgrove-Windows10ClientVM01.parameters.json"
$WoodgroveWindows10ClientVM02ARMParametersTemplateLocation = "$($root)\Woodgrove-Windows10ClientVM02.parameters.json"

# Define Woodgrove Pool Resource Groups
$WoodgroveResourceGroupName = 'Woodgrove-RG'

# Define Woodgrove Pool Regions
$WoodgroveRegion = 'westus2'

# Deployment Subscription (update as needed)
$SubscriptionID = 'ab48f397-fc82-4634-aa52-62dd91b3ebaa'

# Store Login/password (update to your own plz)
# NOTE: The azure account here must not be a Live ID.
$UserEmail = 'mattr@woodgrove.ms'
$azureAccountName ="mattr@woodgrove.ms"
$azurePassword = ConvertTo-SecureString "L0l@thec@t" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

# Define Azure Storage Info
$StorageSKUType = "Standard_GRS"
$StorageSKUKind = "StorageV2"
$WoodgroveVHDStorageAccountName = "woodgrovevmimages"

$WoodgroveVHDBaseVHDStorageContainerName = "basevhds"
$WoodgroveVHDRunningVHDStorageContainerName = "vhds"

# Login in to Azure
#Login-AzureRmAccount -Credential $cred
# THe silent login is broken due to MFA - Use Prompt - sorry.
Connect-AzAccount 

# Set the subscription context
Set-AzContext  -SubscriptionID $SubscriptionID

# Create Woodgrove Pool Resource Groups (check before running - may already exist)
#New-AzResourceGroup -Name $WoodgroveResourceGroupName -Location $WoodgroveRegion

# Create Woodgrove Pool Storage Accounts (check before running - may already exist)
#New-AzStorageAccount -Name $WoodgroveVHDStorageAccountName -Location $WoodgroveRegion -Type $StorageSKUType -ResourceGroupName $WoodgroveResourceGroupName

# Get Woodgrove Pool Storage Accounts
$WoodgroveVHDStorageAccount = Get-AzStorageAccount -Name $WoodgroveVHDStorageAccountName -ResourceGroupName $WoodgroveResourceGroupName

# Retrieve/Create the Storage Context
$WoodgroveVHDStorageContext = $WoodgroveVHDStorageAccount.Context

# Create Woodgrove Pool Storage Containers for the VHDs (check before running - may already exist)
#New-AzureStorageContainer -Name $WoodgroveVHDBaseVHDStorageContainerName -Context $WoodgroveVHDStorageContext -Permission Container
#New-AzureStorageContainer -Name $WoodgroveVHDRunningVHDStorageContainerName -Context $WoodgroveVHDStorageContext -Permission Container

# Copy Woodgrove VM BASE Images from the 3Sharp Base VHD Storage Containers to ensure the Environment has all the needed assets prior to deploying the VHDs.

# Client VM Base - Windows 10 N Workstation Edition - Build 2004 - Last updated May 2020
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/Client/Win10NWorkstation2004Base-Updated05112020.vhd" -DestBlob "Win10NWorkstation2004Base-Updated05112020.vhd" -DestContainer $WoodgroveVHDBaseVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext 

# Server VM Base - Windows Server 2019 - Data Center - Server Core Edition - Last updated May 2020
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/Server/WindowsServerCore1909-Update05112020.vhd" -DestBlob "WindowsServerCore1909-Update05112020.vhd" -DestContainer $WoodgroveVHDBaseVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext 

# Server VM Base - Windows Server 2019 - Data Center - Last updated May 2020
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/Server/WindowsServer2019StandardGUI-Update05112020.vhd" -DestBlob "WindowsServer2019StandardGUI-Update05112020.vhd" -DestContainer $WoodgroveVHDBaseVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext 

# Server VM Base - Ubuntu Server 19.10 - Last updated March 2020
#Start-AzStorageBlobCopy -AbsoluteUri "https://holassets.blob.core.windows.net/basevhds/Server/UbuntuServer19.10Base.vhd" -DestBlob "UbuntuServer19.10Base.vhd" -DestContainer $WoodgroveVHDBaseVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext 

# Copy Woodgrove VM BASE Images from Base Image Storage Container to Woodgrove Running VMs VHD Storage Containers 
# DC01
#Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/WindowsServerCore1909-Update05112020.vhd" -DestBlob "Woodgrove-DC01.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# ADFS01
#Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/WindowsServer2019StandardGUI-Update05112020.vhd" -DestBlob "Woodgrove-ADFS01.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# AppProxy01
#Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/WindowsServer2019StandardGUI-Update05112020.vhd" -DestBlob "Woodgrove-AppProxy01.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# ClientVM01
Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/Win10NWorkstation2004Base-Updated05112020.vhd" -DestBlob "Woodgrove-Windows10ClientVM-01.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# ClientVM02
Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/Win10NWorkstation2004Base-Updated05112020.vhd" -DestBlob "Woodgrove-Windows10ClientVM-02.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# LinuxServerVM01
#Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/UbuntuServer19.10Base.vhd" -DestBlob "Woodgrove-UbuntuLinuxServer-01.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# LinuxServerVM02
#Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/UbuntuServer19.10Base.vhd" -DestBlob "Woodgrove-UbuntuLinuxServer-02.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# LinuxServerVM03
#Start-AzStorageBlobCopy -AbsoluteUri "https://woodgrovevmimages.blob.core.windows.net/basevhds/UbuntuServer19.10Base.vhd" -DestBlob "Woodgrove-UbuntuLinuxServer-03.vhd" -DestContainer $WoodgroveVHDRunningVHDStorageContainerName -DestContext $WoodgroveVHDStorageContext

# Deploy the RAW VMs in the Woodgrove Resource Group
# DC01
#New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveInfraVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveDC01ARMParametersTemplateLocation -Force

# ADFS01
#New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveInfraVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveADFS01ARMParametersTemplateLocation -Force

# AppProxy01
#New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveInfraVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveAPPProxy01ARMParametersTemplateLocation -Force

# ClientVM01
New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveClientVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveWindows10ClientVM01ARMParametersTemplateLocation -Force

# ClientVM02
New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveClientVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveWindows10ClientVM02ARMParametersTemplateLocation -Force

# UbuntuLinuxServerVM01
#New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveLinuxVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveUbuntuLinuxVM01ARMParametersTemplateLocation -Force

# UbuntuLinuxServerVM02
#New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveLinuxVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveUbuntuLinuxVM02ARMParametersTemplateLocation -Force

# UbuntuLinuxServerVM03
#New-AzResourceGroupDeployment -ResourceGroupName $WoodgroveResourceGroupName -TemplateFile $WoodgroveLinuxVMPoolUnManagedARMTemplateLocation -TemplateParameterFile $WoodgroveUbuntuLinuxVM03ARMParametersTemplateLocation -Force
