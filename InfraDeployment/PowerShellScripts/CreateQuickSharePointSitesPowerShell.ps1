#Requires -Version 4
#Requires -RunAsAdministrator
#######################################
$DebugPreference = "Continue";
$VerbosePreference = "Continue";
$WarningPreference = "Continue";
$ErrorActionPreference = "Stop";
Set-PSDebug -Strict;
Set-StrictMode -Version 4;
cd $PSScriptRoot;
#######################################

#region Setup Parameters

# Set credentials
$SiteAdmin = "svcAdmin@skytapmarketingdemo.net";
$Password = ConvertTo-SecureString "MTPr0cks!" -AsPlainText -Force;

$DateTime = [DateTime]::Now.ToString("yyyyMMdd");
$SiteUrl = "https://skytapmarketingdemo.sharepoint.com"
$NewSitePrefix = "NewTeamSite";

$SiteBaseUrl = "${SiteUrl}/sites/";
$Sites = @(
    "${NewSitePrefix}${DateTime}A",
    "${NewSitePrefix}${DateTime}B",
    "${NewSitePrefix}${DateTime}C",
    "${NewSitePrefix}${DateTime}D",
    "${NewSitePrefix}${DateTime}E",
    "${NewSitePrefix}${DateTime}F"
);

$SiteCollectionAdmins = @(
    "svcAdmin@skytapmarketingdemo.net",
    "RoTambu@skytapmarketingdemo.net", 
    "ErGubbe@skytapmarketingdemo.net"
)

$SiteCollectionMembers = @(
    "SecOps@skytapmarketingdemo.net", 
    "svcAdmin@skytapmarketingdemo.net", 
    "RoTambu@skytapmarketingdemo.net", 
    "ErGubbe@skytapmarketingdemo.net", 
    "BaMorel@skytapmarketingdemo.net", 
    "LoSunsh@skytapmarketingdemo.net", 
    "GaErick@skytapmarketingdemo.net", 
    "DePoe@skytapmarketingdemo.net", 
    "AnFulle@skytapmarketingdemo.net", 
    "AlexW@skytapmarketingdemo.onmicrosoft.com", 
    "AarifS@skytapmarketingdemo.onmicrosoft.com"
)

$DeleteOldSites = $true;
$CreateNewSites = $true;
$SetupAccounts = $true;

$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $SiteAdmin, $password;

#endregion

#region Module Installation

try
{
    # In strict mode, the check alone will throw.
    if ($alreadyInstalledModules) { Write-Host "Skipping Module Installation."; }
}
catch
{
    $oldPref = $ProgressPreference;
    $ProgressPreference = "SilentlyContinue";

    Write-Host "Installing Modules . . .";

    # Import MS Online (O365) Powershell Module
    Install-Module MSOnline -Force -AllowClobber -Confirm:$false -Scope AllUsers;
    Install-Module AzureAD -Force -AllowClobber -Confirm:$false -Scope AllUsers;
    Import-Module MSOnline -Force -Global;

    # Install SPO modules
    $SPOModulePath = 'C:\Program Files\SharePoint Online Management Shell\';
    $Env:PSModulePath = '{0};{1}' -f $Env:PSModulePath, $SPOModulePath;
    Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -Force;
    Write-Host "Modules Installed.";
    
    $alreadyInstalledModules = $true;
    $ProgressPreference = $oldPref;
}

#endregion

#region Functions

function Get-SpoAdminSiteUrl([parameter(Mandatory=$true, position=0)][string]$spoUrl)
{
    <#
    .Description
    Get-SpoAdminSiteUrl converts the URL of a SharePoint Online site into the corresponding Admin Site URL.
    #>

    $spoUri = new-object System.Uri -ArgumentList $spoUrl;
    $adminUri = new-object System.Uri -ArgumentList $spoUri, "/";

    
    if (-not ($adminUri.ToString() -imatch '\.sharePoint\.com')) { throw "Not a SharePoint.com site!"; }
    if (-not ($adminUri.ToString() -imatch '\-admin\.sharePoint\.com'))
    {
        $adminUri = $adminUri.ToString() -ireplace '.sharepoint.com', '-admin.sharepoint.com'
    }

    return $adminUri.ToString();
}

function New-SPOnlineSite
(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$Title,
    [int]$StorageQuota = 1000,
    [string]$Template = 'STS#3',
#    [string]$Template = 'EHS#1',
    [Parameter(Mandatory=$true)][PSCredential]$Credentials
)
{
    $AdminUrl = Get-SpoAdminSiteUrl $Url;

    return Start-Job -Name "Creating Site '${Title}' at '${Url}'" `
        -ArgumentList $Url, $Title, $StorageQuota, $Template, $Credentials, $AdminUrl `
        -ScriptBlock `
        {
            # Because we're using Start-Job, we have to pass in the parameters into the job; this is because there's no "-AsJob" switch on 
            $Url = $args[0];
            $Title = $args[1];
            $StorageQuota = $args[2];
            $Template = $args[3];
            $Credentials = $args[4];
            $AdminUrl = $args[5];
            $Owner = $Credentials.UserName;

            Connect-SPOService -Url $AdminUrl -Credential $Credentials;

            # Verify if site already exists in SharePoint Online
            $siteExists = Get-SPOSite | ? { $_.url -eq $url };

            # Verify if site already exists in the recycle bin
            $siteExistsInRecycleBin = Get-SPODeletedSite | ? { $_.url -eq $url };

            #create site if it doesn't exists
            if ($siteExistsInRecycleBin -ne $null)  { throw "Site '${Url}' still exists in the recycle bin!"; }
            if ($siteExists -ne $null)  { throw "Site '${Url}' already exists!"; }

            Write-Verbose "Creating $($title)";
            New-SPOSite -Url $url -title $title -Owner $owner -StorageQuota $storageQuota -Template $template;
        }
}

function Add-UserToGroup([string]$Url, [string]$User, [string]$GroupPattern, [switch]$SetSiteAdmin)
{
    $retryCount = 0;
    $mustExecute = $true;
    
    while ($mustExecute)
    {
        $mustExecute = $false;
        try
        {
            # Get the owner group name
               $group = Get-SPOSiteGroup -Site $url | ? { $_.Title -like $GroupPattern } | Select -First 1;
               $groupName = $group.Title;
            if ($groupName -ilike "Site*" -and $retryCount -lt 4)
            {
                $mustExecute = $true;
                $retryCount++;
                Write-Verbose "Group name is still ""${groupName}""; Waiting 45 seconds and trying again . . .";
                Sleep 45;
                continue;
            }

                 Write-Verbose "Adding ""${user}"" to ""${url}"" in group ""${groupName}"" ...";
                 Add-SPOUser  -Site $url -LoginName $user -Group $groupName;
                 Write-Host "Added ""${user}"" to ""${url}"" in group ""${groupName}""." -ForegroundColor Green;
             
            if ($SetSiteAdmin)
            {
                     # Set the site collection admin flag for the Site collection admin
                     Write-Verbose "Setting up ""${user}"" as a site collection admin on ""${url}""...";
                     Set-SPOUser -Site $url -LoginName $user -IsSiteCollectionAdmin $true;
                     Write-Host """${user}"" is now a site collection admin on ""${url}""." -ForegroundColor Green;
               }

            $mustExecute = $false;
            return;
        }
        catch
        {
            $retryCount++;
            Write-Warning "Attempt #${retryCount} failed!";
            if ($retryCount -gt 10)
            {
                throw $_;
            }
            else
            {
                Write-Verbose "... sleeping for 30 seconds and trying again.";
                $mustExecute = $true;
                sleep 30;
            }
        }
    }
}

function Wait-ForJobsToComplete([Array]$jobs)
{
    if ($jobs -eq $null) { return; }
    if ($jobs.Length -lt 1) { return; }

    # Wait for the "Create Sites" jobs to complete
    $keepGoing = $true;
    while ($keepGoing)
    {
        $jobStatuses = $jobs | Get-Job;
    
        Cls;
        $jobStatuses | Format-Table -Property Name, State
        $keepGoing = ($jobStatuses | ? { $_.State -ne "Completed" -and $_.State -ne "Failed" } | Measure-Object).Count -gt 0;

        $jobs | Wait-Job -Timeout 5 > $null;
    }

    $ErrCount = 0;
    foreach ($job in $jobs)
    {
        $name = ($job | Get-Job).Name;
        try
        {
            $job | Receive-Job # > $null;
            Write-Host "Job ""${name}"" Completed Successfully." -ForegroundColor Green;
        }
        catch
        {
            Write-Host "Job ""${name}"" Failed with error:`r`n`t${_}" -ForegroundColor Red;
            $errCount++;
        }
        Write-Host;
    }
    Write-Host;
    if ($ErrCount -gt 0) { throw "Errors: ${errCount}"; }
}


#endregion

#region Validate Credentials

$Adminurl = Get-SpoAdminSiteUrl $SiteBaseUrl;
Write-Host "Validating Admin Credentials";
Connect-SPOService -Url $Adminurl -Credential $Credentials;
Write-Host "Success!" -ForegroundColor Green;

#endregion

#region Run the "Delete [old sites]" jobs.

if ($DeleteOldSites)
{
    $jobs = @();
    $allSites = Get-SPOSite -Limit All | ? { $_.URL -like "*${NewSitePrefix}*" };
    foreach ($spSite in $allSites)
    {
        $adminSite = Get-SpoAdminSiteUrl $spSite.Url;

        $jobs += Start-Job -Name "Deleting $($spSite.Url). . ." -ArgumentList $spSite, $Credentials, $adminSite -ScriptBlock `
        {
            $spSite = $args[0];
            $creds = $args[1];
            $adminSite = $args[2];
        

            Connect-SPOService -Url $adminSite -Credential $creds

            Remove-SPOSite -Confirm:$false -Identity $spSite.Url;
            Remove-SPODeletedSite -Confirm:$false -Identity $spSite.Url;
        };
    }

    Wait-ForJobsToComplete $jobs;
}

#endregion

#region Run the "Create Sites" Jobs

if ($CreateNewSites)
{

    Write-Host "Kicking off Site Creation . . .";

    $jobs = @();
    if (-not $SiteBaseUrl.EndsWith("/")) { $SiteBaseUrl += "/"; }
    foreach ($site in $sites)
    {
        $jobs += New-SPOnlineSite -Url "${SiteBaseUrl}${site}" -Title $site -Credentials $Credentials;
    }

    Wait-ForJobsToComplete -Jobs $jobs;
}

#endregion

#region Setup User Accounts

if ($SetupAccounts)
{
    foreach ($site in $sites)
    {
        $url = "${SiteBaseUrl}${site}";
        Write-Host "Adding users to ${url}" -ForegroundColor Yellow;
       
        # Add the Site Collection Admin to the site in the owners group
           foreach ($user in $SiteCollectionAdmins)
           {
            Add-UserToGroup -Url $Url -User $User -GroupPattern "*Owners" -SetSiteAdmin;
           }

        # Add the Site Collection Members to the site in the members group
           foreach ($user in $SiteCollectionMembers)
           {
                 Add-UserToGroup -Url $Url -User $User -GroupPattern "*Members";
           }

        Write-Host;
        Write-Host;
    }

    # All Done!
    Get-SPOSite -Limit All | ? { $_.URL -like "*${NewSitePrefix}*" } | Format-Table;
    Write-Host;
    Write-Host;
}

#endregion

Write-Host "Done with everything" -ForegroundColor Green;
Write-Host; 
