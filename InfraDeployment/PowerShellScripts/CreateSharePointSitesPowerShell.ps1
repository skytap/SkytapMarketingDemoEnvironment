# Import MS Online (O365) Powershell Module
Install-Module MSOnline
Install-Module -Name AzureAD -Force
Import-Module MSOnline 

# Install SPO modules
$SPOModulePath = 'C:\Program Files\SharePoint Online Management Shell\'
$Env:PSModulePath = '{0};{1}' -f $Env:PSModulePath, $SPOModulePath
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking


function get-SPOnlineWebTemplates {
 #variables that needs to be set before starting the script
 $adminUrl = "https://mtpdemos-admin.sharepoint.com"
 $userName = "ergubbe@mtpdemos.net"
 $password = Read-Host "Please enter the password for $($userName)" –AsSecureString
  
 #set credentials for SharePoint Online
 $credentials = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $password
  
 #connect to SharePoint Online
 Connect-SPOService -Url $adminUrl -Credential $credentials
  
 get-spoWebTemplate
}
get-SPOnlineWebTemplates

function new-SPOnlineSite {
# variables that needs to be set before starting the script
$url = "https://mtpdemos.sharepoint.com/sites/NewTeamSite07012019B"
$title = "T"
$owner = "ergubbe@mtpdemos.net"
$storageQuota = 1000
$resourceQuota = 50
$template = "STS#3"
$adminUrl = "https://mtpdemos-admin.sharepoint.com"
$userName = "ergubbe@mtpdemos.net"
 
# Let the user fill in their password in the PowerShell window
$password = Read-Host "Please enter the password for $($userName)" -AsSecureString
 
# Set credentials
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $password
 
# Connect to to Office 365
try{
Connect-SPOService -Url $adminUrl -Credential $credentials
write-host "Info: Connected succesfully to Office 365" -foregroundcolor green
}
catch{
write-host "Error: Could not connect to Office 365" -foregroundcolor red
Break new-SPOnlineSite
}
 
#verify if site already exists in SharePoint Online
$siteExists = get-SPOSite | where{$_.url -eq $url}
 
#verify if site already exists in the recycle bin
$siteExistsInRecycleBin = get-SPODeletedSite | where{$_.url -eq $url}
 
#create site if it doesn't exists
if (($siteExists -eq $null) -and ($siteExistsInRecycleBin -eq $null)) {
write-host "info: Creating $($title)" -foregroundcolor green
New-SPOSite -Url $url -title $title -Owner $owner -StorageQuota $storageQuota -NoWait -ResourceQuota $resourceQuota -Template $template
}
elseif ($siteExists -eq $true){
write-host "info: $($url) already exists" -foregroundcolor red
}
else{
write-host "info: $($url) still exists in the recyclebin" -foregroundcolor red
}
}
new-SPOnlineSite

function new-spOnlineWeb {
    #variables that needs to be set before starting the script
    $siteURL = "https://mtpdemos.sharepoint.com/sites/blogdemo"
    $webURL = "MyFirstWeb"
    $title = "My First Web"
    $template = "STS#0"
    $adminUrl = "https://mtpdemos-admin.sharepoint.com"
    $userName = "ergubbe@mtpdemos.net"
    $useSamePermissionsAsParentSite = $true
     
    # Let the user fill in their password in the PowerShell window
    $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
     
    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
         
    #Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    $context.credentials = $SPOCredentials
     
    #create web using WebCreationInformatin object (wci)
    $wci = New-Object Microsoft.SharePoint.Client.WebCreationInformation 
    $wci.url = $webURL
    $wci.title = $title
    $wci.webtemplate = $template
    $wci.useSamePermissionsAsParentSite = $useSamePermissionsAsParentSite
    $createWeb = $context.web.webs.add($wci)
    $context.load($createWeb)
     
    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Creating $($title)" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }
}
new-spOnlineWeb

function new-SPOnlineSiteColumns {
    # variables that needs to be set before starting the script
    $siteURL = "https://mtpdemos.sharepoint.com/sites/BlogDemo"
    $CSVLocation = "C:\<Full Path to file>\siteColumns.csv"
    $userName = "ergubbe@mtpdemos.net"
     
    # Let the user fill in their password in the PowerShell window
    $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
     
    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
         
    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    $context.credentials = $SPOCredentials
    $fields = $context.web.fields
    $context.load($fields)
     
    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Loaded all Site Columns" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }
     
    #load CSV file
    $siteColumns = import-csv $CSVLocation


# CSV example: https://www.sharepointfire.com/2016/01/create-new-site-columns-sharepoint-online-powershell/ 
     
    #loop through each entry and create the columnGroup
    foreach ($column in $sitecolumns){
        #check if column already exists
        foreach($field in $fields){
            if ($field.internalname -eq $column.name){
                $columnExists = 1
            }
            else{
                $columnExists = 0
            }        
        }
         
        if ($columnExists -eq 0){
            #create XML entry for a new field 
            $fieldAsXML = "<Field Type='$($column.FieldType)' 
            DisplayName='$($column.DisplayName)' 
            Name='$($column.name)' 
            ID='$($column.ID)' 
            Group='$($column.group)'
            Required='$($column.required)' />"
             
            #see tips below for info about fieldOptions
            $fieldOption = [Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint
            $field = $fields.AddFieldAsXML($fieldAsXML, $true, $fieldOption)
            $context.load($field)
             
            #send the request containing all operations to the server
            try{
                $context.executeQuery()
                write-host "info: column $($column.name) created" -foregroundcolor green
            }
            catch{
                write-host "info: $($_.Exception.Message)" -foregroundcolor red
            }
        }
        else{
        write-host "Info: The column $($column.name) already exists." -foregroundcolor red
        }
    }
}
new-SPOnlineSiteColumns

function new-SPOnlineContentType {
    #variables that needs to be set before starting the script
    $siteURL = "https://mtpdemos.sharepoint.com/sites/blogdemo"
    $adminUrl = "https://mtpdemos-admin.sharepoint.com"
    $userName = "ergubbe@mtpdemos.net"
    $contentTypeGroup = "My Content Types"
    $contentTypeName = "Blog Content Type"
    $columns = "BlogNumber", "BlogText", "BlogUser"
    $parentContentTypeID = "0x0101"
     
    # Let the user fill in their password in the PowerShell window
    $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
     
    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
         
    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    $context.credentials = $SPOCredentials
    $fields = $context.web.fields
    $contentTypes = $context.web.contenttypes
    $context.load($fields)
    $context.load($contentTypes)
     
    # send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Loaded Fields and Content Types" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }
         
    # Loop through all content types to verify it doesn't exist
    foreach ($contentType in $contentTypes){
        if ($contentType.name -eq $contentTypeName){
            write-host "Info: The content type $($contentTypeName) already exists." -foregroundcolor red
            $contentTypeExists = $true
        }
        else{
            $contentTypeExists = $false
        }
    }
         
    # create content type if it doesnt exist based on specified Content Type ID
    if($contentTypeExists -eq $false){
        # load parent content type
        $parentContentType = $contentTypes.GetByID($parentContentTypeID)
        $context.load($parentContentType)
         
        # send the request containing all operations to the server
        try{
            $context.executeQuery()
            write-host "info: loaded parent Content Type" -foregroundcolor green
        }
        catch{
            write-host "info: $($_.Exception.Message)" -foregroundcolor red
        }
         
        # create Content Type using ContentTypeCreationInformation object (ctci)
        $ctci = new-object Microsoft.SharePoint.Client.ContentTypeCreationInformation
        $ctci.name = $contentTypeName
        $ctci.ParentContentType = $parentContentType
        $ctci.group = $contentTypeGroup
        $ctci = $contentTypes.add($ctci)
        $context.load($ctci)
         
        # send the request containing all operations to the server
        try{
            $context.executeQuery()
            write-host "info: Created content type" -foregroundcolor green
        }
        catch{
            write-host "info: $($_.Exception.Message)" -foregroundcolor red
        }
         
        # get the new content type object
        $newContentType = $context.web.contenttypes.getbyid($ctci.id)
         
        # loop through all the columns that needs to be added
        foreach ($column in $columns){
            $field = $fields.GetByInternalNameOrTitle($column)
            #create FieldLinkCreationInformation object (flci)
            $flci = new-object Microsoft.SharePoint.Client.FieldLinkCreationInformation
            $flci.Field = $field
            $addContentType = $newContentType.FieldLinks.Add($flci)
   write-host "info: added $($column) to array" -foregroundcolor green
        }        
        $newContentType.Update($true)
         
        # send the request containing all operations to the server
        try{
            $context.executeQuery()
            write-host "info: Added columns to content type" -foregroundcolor green
        }
        catch{
            write-host "info: $($_.Exception.Message)" -foregroundcolor red
        }
    }
}
new-SPOnlineContentType

function get-SPOnlineListTemplates {
    #variables that needs to be set before starting the script
    $siteURL = "https://mtpdemos.sharepoint.com/sites/blogdemo"
    $adminUrl = "https://mtpdemos-admin.sharepoint.com"
    $userName = "ergubbe@mtpdemos.net"
     
    # Let the user fill in their password in the PowerShell window
    $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
     
    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
         
    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    $context.credentials = $SPOCredentials
 $listTemplates = $context.web.listtemplates
 $context.load($listTemplates)
     
    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Loaded list templates" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }
      
 #List available templates
 $listTemplates | select baseType, Description, ListTemplateTypeKind | ft –wrap
}
get-SPOnlineListTemplates

function new-SPOnlineList {
    #variables that needs to be set before starting the script
    $siteURL = "https://mtpdemos.sharepoint.com/sites/BlogDemo"
    $adminUrl = "https://mtpdemos-admin.sharepoint.com"
    $userName = "ergubbe@mtpdemos.net"
    $listTitle = "Finance"
    $listDescription = "Finance documents"
    $listTemplate = 101
     
    # Let the user fill in their password in the PowerShell window
    $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
     
    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
         
    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    $context.credentials = $SPOCredentials
     
    #create list using ListCreationInformation object (lci)
    $lci = New-Object Microsoft.SharePoint.Client.ListCreationInformation
    $lci.title = $listTitle
    $lci.description = $listDescription
    $lci.TemplateType = $listTemplate
    $list = $context.web.lists.add($lci)
    $context.load($list)
    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Created $($listTitle)" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }  
}
new-SPOnlineList

function update-spOnlineListWithContentType {
 #variables that needs to be set before starting the script
 $siteURL = "https://mtpdemos.sharepoint.com/sites/BlogDemo"
 $adminUrl = "https://mtpdemos-admin.sharepoint.com"
 $userName = "ergubbe@mtpdemos.net"
 $listName = "finance"
 $ctID = "0x010100DD6BABAC17A5504DB29949148A37DA61"
  
 # Let the user fill in their password in the PowerShell window
 $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
  
 # set SharePoint Online credentials
 $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
   
 # Creating client context object
 $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
 $context.credentials = $SPOCredentials
 $list = $context.web.lists.GetByTitle($listName)
 $ct = $context.web.contenttypes.getbyid($ctID)
 $context.load($ct)
 $context.load($list)
 $context.load($list.contenttypes)
  
 #send the request containing all operations to the server
 try{
  $context.executeQuery()
  write-host "info: ClientContext object executed" -foregroundcolor green
 }
 catch{
  write-host "info: Error executing ClientContext object" -foregroundcolor red
 }
  
 #enable multiple content types for the library and add the content type
 $list.ContentTypesEnabled = $true
 $AddCT = $list.ContentTypes.AddExistingContentType($ct)
 $list.update()
 write-host "info: Enabled multiple content types"
  
 #send the request containing all operations to the server
 try{
  $context.executeQuery()
  write-host "info: added the content type to the list" -foregroundcolor green
 }
 catch{
  write-host "info: $($_.Exception.Message)" -foregroundcolor red
 }
}
update-spOnlineListWithContentType

function new-SPOnlineView {
 #variables that needs to be set before starting the script
 $siteURL = "https://mtpdemos.sharepoint.com/sites/blogdemo"
 $adminUrl = "https://mtpdemos-admin.sharepoint.com"
 $userName = "ergubbe@mtpdemos.net"
 $listName = "finance"
 $viewName = "Blog View"
 $viewColumns = "Name", "Blog Text", "Blog Number", "Blog User", "Created", "Modified"
  
 # Let the user fill in their password in the PowerShell window
 $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
  
 # set credentials
 $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
   
 # Creating client context object
 $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
 $context.credentials = $SPOCredentials
 $web = $context.web
 $list = $web.lists.GetByTitle($listName)
 $context.load($list)
  
 #Creating new view using ViewCreationInformation (VCI)
 $vci = New-Object Microsoft.SharePoint.Client.ViewCreationInformation 
 $vci.Title = $viewName
 $vci.ViewTypeKind= [Microsoft.SharePoint.Client.ViewType]::None
 $vci.RowLimit=50
    $vci.SetAsDefaultView=$true 
 $vci.ViewFields=@($viewColumns)</pre>
#adding view to list
$listViews = $list.views
$context.load($listViews)
$addListView = $listViews.Add($vci)
$context.load($addListView)
 
#send the request containing all operations to the server
try{
$context.executeQuery()
write-host "info: View created succesfully" -foregroundcolor green
}
catch{
write-host "info: $($_.Exception.Message)" -foregroundcolor red
}
}
new-SPOnlineView

function update-SPOnlineSitePermissions {
  #variables that needs to be set before starting the script
  $webURL = "https://mtpdemos.sharepoint.com/sites/NewTeamSite07012019A"
  $adminUrl = "https://mtpdemos-admin.sharepoint.com"
  $userName = "ergubbe@mtpdemos.net"
  $members = "i:0#.f|membership|ergubbe@mtpdemos.net, secops@mtpdemos.net, Helpdesk@mtpdemos.net"
# Let the user fill in their password in the PowerShell window
$password = Read-Host "Please enter the password for $($userName)" -AsSecureString
 
# set SharePoint Online credentials
$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
 
# Creating client context object
$context = New-Object Microsoft.SharePoint.Client.ClientContext($webURL)
$context.credentials = $SPOCredentials
$web = $context.web
$context.load($web)
 
$web.breakroleinheritance($false, $false)
$web.update()
#send the request containing all operations to the server
try{
$context.executeQuery()
write-host "info: Broken inheritance for $($web.title)" -foregroundcolor green
}
catch{
write-host "info: $($_.Exception.Message)" -foregroundcolor red
}
 
#Create new groups
$siteGroups = "$($web.title) visitors", "$($web.title) members", "$($web.title) owners"
foreach ($siteGroup in $siteGroups){
if ($siteGroup -like "*visitors")
{
$gci = New-Object Microsoft.SharePoint.Client.GroupCreationInformation
$gci.Title = $siteGroup
$siteGroup = $Context.Web.SiteGroups.Add($gci)
$PermissionLevel = $Context.Web.RoleDefinitions.GetByName("Read")
 
#Bind Permission Level to Group
$RoleDefBind = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Context)
$RoleDefBind.Add($PermissionLevel)
$Assignments = $Context.Web.RoleAssignments
$RoleAssignOneNote = $Assignments.Add($siteGroup,$RoleDefBind)
$Context.Load($siteGroup)
#send the request containing all operations to the server
try{
$context.executeQuery()
write-host "info: Added visitors group" -foregroundcolor green
}
catch{
write-host "info: $($_.Exception.Message)" -foregroundcolor red
}
}
 
if ($siteGroup -like "*members")
{
$gci = New-Object Microsoft.SharePoint.Client.GroupCreationInformation
$gci.Title = $siteGroup
$siteGroup = $Context.Web.SiteGroups.Add($gci)
$PermissionLevel = $Context.Web.RoleDefinitions.GetByName("Edit")
 
#Bind Permission Level to Group
$RoleDefBind = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Context)
$RoleDefBind.Add($PermissionLevel)
$Assignments = $Context.Web.RoleAssignments
$RoleAssignOneNote = $Assignments.Add($siteGroup,$RoleDefBind)
$Context.Load($siteGroup)
#send the request containing all operations to the server
try{
$context.executeQuery()
write-host "info: Added members group" -foregroundcolor green
}
catch{
write-host "info: $($_.Exception.Message)" -foregroundcolor red
}
}
 
if ($siteGroup -like "*owners")
{
$gci = New-Object Microsoft.SharePoint.Client.GroupCreationInformation
$gci.Title = $siteGroup
$siteGroup = $Context.Web.SiteGroups.Add($gci)
$PermissionLevel = $Context.Web.RoleDefinitions.GetByName("Full Control")
 
#Bind Permission Level to Group
$RoleDefBind = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Context)
$RoleDefBind.Add($PermissionLevel)
$Assignments = $Context.Web.RoleAssignments
$RoleAssignOneNote = $Assignments.Add($siteGroup,$RoleDefBind)
$Context.Load($siteGroup)
#send the request containing all operations to the server
try{
$context.executeQuery()
write-host "info: Added owners group" -foregroundcolor green
}
catch{
write-host "info: $($_.Exception.Message)" -foregroundcolor red
}
}
}
 
#add user to group
$spGroups = $Web.SiteGroups
$context.Load($spGroups)
$spGroup=$spGroups.GetByName("$($web.title) members")
 
$spUser = $context.Web.EnsureUser($members)
$context.Load($spUser)
$spUserToAdd=$spGroup.Users.AddUser($spUser)
$context.Load($spUserToAdd)
try{
$context.executeQuery()
write-host "info: Added user to members group" -foregroundcolor green
}
catch{
write-host "info: $($_.Exception.Message)" -foregroundcolor red
}
}
update-SPOnlineSitePermissions