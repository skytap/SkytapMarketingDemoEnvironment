$userlist = import-csv 'C:\users\aadcadmin\Desktop\Users\msusers.csv' -Encoding UTF8 
foreach ($user in $userlist) {
    $SAM = $user.Firstname + "." + $user.Lastname
    $SAM
    Remove-ADUser $SAM -Confirm:$false
}