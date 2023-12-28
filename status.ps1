[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$UserId = $( Read-Host -prompt "Input SAMAccountName Name please" )
)
$env:ADPS_LoadDefaultDrive = 0
Import-Module ActiveDirectory -Cmdlet Get-ADUser
$ErrorActionPreference = "SilentlyContinue"
if ($UserId.length -lt 3) {
    Write-Output "Please enter a valid ID."
    $UserId = Read-Host "Re-enter user ID"
}
$adInfo=(get-aduser $userid -properties * | select-object badlogoncount,telephonenumber, userprincipalname, Manager,City, DisplayName, Department, Enabled, LastBadPasswordAttempt, LastLogonDate, Lockedout, Passwordexpired, passwordlastset, emailaddress, employeeID)
$Name=$adInfo.DisplayName
$location=$adinfo.city
$employeeID=$adinfo.employeeid
$pwExpired=$adInfo.PasswordExpired
$userprincipalname=$adinfo.userprincipalname
$pwLast=$adinfo.passwordlastset
$pwlocked=$adInfo.LockedOut
$manager=$adinfo.manager -replace '^CN=|,.*$'
$emailaddress=$adInfo.emailaddress
$enable=$adInfo.Enabled
$pwAttemp=$adInfo.LastBadPasswordAttempt
$telephonenumber=$adinfo.telephonenumber
$pwExpires=$pwLast.AddDays(90)
$Department=$adinfo.department
$badlogoncount=$adinfo.badlogoncount
$a=(dsquery user -samid $UserId)
if ($a -ne $null){
  write-host $name
  write-host "Manager:" $Manager
  write-host "Location:" $location
  write-host "Telephone:" $telephonenumber
  write-host $badlogoncount "bad password attempts"
  write-host $emailaddress
  write-host "EID:" $employeeid
  write-host "UPN:"$userprincipalname
  if ($pwExpired -Match "True"){write-host ('!*!*!*!Password is expired!*!*!*!') -foreground "red"}
  else {write-host('password is not expired') -foreground "green"}
  write-host "Password set on :" $pwLast 
  write-host "Expires on:" $pwExpires
  $today=(GET-DATE)
  $pwTime=(NEW-TIMESPAN –start $today –end $pwExpires)
  write-host "Password expires in" $pwTime.Days "days"
  if ($pwlocked -Match "True"){write-host ('!*!*!*!Account IS Locked !*!*!*!') -foreground "red"}
  else {write-host('Account IS NOT Locked') -foreground "green"}
  if ($enable -Match "False"){write-host ('!*!*!*! Account IS Suspended!*!*!*!') -foreground "red"}
  else {write-host('Account IS Active') -foreground "green"}
  write-host "Last bad password attempt: " $pwAttemp "`n`n`n`n`n`n"
}

else {
  write-host ('User ID not found in this Domain') -foreground "red" "`n`n`n`n`n`n" 
} 
write-host " Querying Azure Data now Please Wait"
if ([string]::IsNullOrEmpty($((Get-AzContext).Account))) {
  Connect-AzAccount -DeviceCode
}
else {
  Write-host "Azure AD Already Connected"
}

$azuser=(Get-AzADUser -Select 'Department,AccountEnabled,ProxyAddress,Mail,EmployeeId,ImAddress,MobilePhone,ApproximateLastSignInDateTime,CreatedDateTime,DeletedDateTime,DisplayName,LastPasswordChangeDateTime,OnPremisesLastSyncDateTime,OnPremisesSyncEnabled,SignInSessionsValidFromDateTime,UsageLocation,State,Country' -AppendSelected -UserPrincipalName $userprincipalname)
$azName=$azuser.DisplayName
$azLocation=$azure.UsageLocation
$azEmployeeID=$azuser.EmployeeId
$azPwLast=$azuser.LastPasswordChangeDateTime
$azPwExpires=$azPwLast.AddDays(90)
$azPwTime=(NEW-TIMESPAN –start $today –end $azPwExpires)
$azemailaddress=$azuser.Mail
$azenable=$azuser.AccountEnabled
$azsignin=$azuser.ApproximateLastSignInDateTime
$azDepartment=$azuser.Department
$azCountry=$azuser.Country
$azIMAddress=$azuser.ImAddress
$azMobile=$azuser.MobilePhone
$azProxy=$azuser.ProxyAddress
$azCreated=$azuser.CreatedDateTime
$azDeleted=$azuser.DeletedDateTime
$azSyncTime=$azuser.OnPremisesLastSyncDateTime
$azSyncEnabled=$azuser.OnPremisesSyncEnabled
$azSignInValidFrom=$azuser.SignInSessionsValidFromDateTime
$azState=$azuser.State


if ($azuser){
  write-host $azName
  write-host "Azure Department: " $azDepartment
  write-host "Mobile Number: " $azMobile
  write-host "User Created: " $azCreated
  write-host "User Deleted: " $azDeleted
  write-Host "Azure Country: " $azCountry
  Write-Host "Azure State: " $azState
  write-host "Azure Usage Location: " $azLocation
  write-host "Azure Employee ID: " $azEmployeeID
  write-host "Azure Password Last Set: " $azPwLast
  write-host "Azure Password Expires in " $azPWTime.ToString("dd") " Days"
  if ($azPwTime -le 0  ){write-host ('!*!*!*!Password is expired!*!*!*!') -foreground "red"}
  else {write-host('password is not expired') -foreground "green"}
  write-host "Azure Primary Email: " $azemailaddress
  write-host "Azure Proxy Addresses: " $azProxy
  write-host "Azure Teams Address: " $azIMAddress
  if ($azenable -Match "False"){write-host ('!*!*!*!Account IS Disabled !*!*!*!') -foreground "red"}
  else {write-host('Account IS Enabled') -foreground "green"}
  write-host "Approximate Last Signin: " $azsignin
  write-host "Sign-in Valid from: " $azSignInValidFrom
  write-host "Last AD Sync: " $azSyncTime
  if ($azSyncEnabled -Match "False"){write-host ('!*!*!*!ADSync IS Disabled !*!*!*!') -foreground "red"}
  else {write-host('ADSync IS Enabled') -foreground "green"}
}
else{
  write-host "User $UserID is not in Azure"
}






