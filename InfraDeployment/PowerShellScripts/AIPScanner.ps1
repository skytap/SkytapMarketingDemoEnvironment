Install-Module AzureADPreview 
Install-AIPScanner 
Connect-AzureAD 
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile $PasswordProfile.ForceChangePasswordNextLogin = $false $Password = Read-Host -assecurestring "Please enter password for cloud service account" $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)) $PasswordProfile.Password = $Password 
$Tenant = Read-Host "Please enter tenant name for UserPrincipalName (e.g. contoso.com)" New-AzureADUser -AccountEnabled $True -DisplayName "AIP Scanner Cloud Service" -PasswordProfile $PasswordProfile -MailNickName "AIPScannerCloud" -UserPrincipalName "AIPScannerCloud@$Tenant" 
New-AzureADApplication -DisplayName AIPOnBehalfOf -ReplyUrls http://localhost $WebApp = Get-AzureADApplication -Filter "DisplayName eq 'AIPOnBehalfOf'" 
New-AzureADServicePrincipal -AppId $WebApp.AppId $WebAppKey = New-Guid $Date = Get-Date New-AzureADApplicationPasswordCredential -ObjectId $WebApp.ObjectID -startDate $Date -endDate $Date.AddYears(1) -Value $WebAppKey.Guid -CustomKeyIdentifier "AIPClient" 
New-AzureADApplication -DisplayName AIPClient -ReplyURLs http://localhost -RequiredResourceAccess $Access -PublicClient $true $NativeApp = Get-AzureADApplication -Filter "DisplayName eq 'AIPClient'" New-AzureADServicePrincipal -AppId $NativeApp.AppId 
"Set-AIPAuthentication -WebAppID " + $WebApp.AppId + " -WebAppKey " + $WebAppKey.Guid + " -NativeAppID " + $NativeApp.AppId | Out-File ~\Desktop\Set-AIPAuthentication.txt Start ~\Desktop\Set-AIPAuthentication.txt 
### As On Premises Scanner Account 
# Set-AIPAuthentication comand from Set-AIPAuthentication.txt 
# Restart-Service AIPScanner 
### Configure Repositories # 
Set-AIPScannerConfiguration -DiscoverInformationTypes All # Start-AIPScan 