[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
   [string]$Identity,
  [Parameter(Mandatory=$False)]
   [string]$Company="Tolt Solutions",
  [Parameter(Mandatory=$False)]
   [string]$MailNickName,
  [Parameter(Mandatory=$False)]
   [string]$FirstName,
  [Parameter(Mandatory=$False)]
   [string]$LastName
   )
Import-module ActiveDirectory
Echo (Get-ADUser -Identity "$Identity" -properties *).displayName
if(!$FirstName){	
	$FirstName=(Get-ADUser -Identity "$Identity" -properties *).givenName
}
if(!$LastName){
	$LastName=(Get-ADUser -Identity "$Identity" -properties *).surname
}
$SAM=(Get-ADUser -Identity "$Identity" -properties *).samaccountname
if (!$MailNickName){
	$MailNickName=(Get-ADUser -Identity "$Identity" -properties *).mailNickName
}
set-ADUser -Identity "$Identity" -Clear ProxyAddresses
if ($MailNickName) {
	set-ADUser -identity "$Identity" -Add @{'ProxyAddresses'=@(("SMTP:$MailNickName.$LastName@toltsolutions.com"),("smtp:$MailNickName.$LastName@kyrus.com"),("smtp:$MailNickName.$LastName@kyrus.onmicrosoft.com"),("smtp:$MailNickName.$LastName@d06.us"),("smtp:$FirstName.$LastName@d06.us"),("smtp:$FirstName.$LastName@toltsolutions.com"),("smtp:$FirstName.$LastName@kyrus.com"),("smtp:$FirstName.$LastName@kyrus.onmicrosoft.com"),("smtp:$SAM@d06.us"))}
	set-ADUser -identity "$Identity" -GivenName $FirstName -Surname $LastName -Company $Company -DisplayName "$LastName, $MailNickName" -EmailAddress "$MailNickName.$LastName@toltsolutions.com" -Add @{'mailNickname'="$MailNickName"}
}
else {
	set-ADUser -identity "$Identity" -Add @{'ProxyAddresses'=@(("SMTP:$FirstName.$LastName@toltsolutions.com"),("smtp:$FirstName.$LastName@d06.us"),("smtp:$FirstName.$LastName@kyrus.com"),("smtp:$FirstName.$LastName@kyrus.onmicrosoft.com"),("smtp:$SAM@d06.us"))}
	set-ADUser -identity "$Identity" -GivenName $FirstName -Surname $LastName -Company $Company -DisplayName "$LastName, $FirstName" -EmailAddress "$FirstName.$LastName@toltsolutions.com"
}
Echo "*********************************************************************************************"
Get-ADUser -Identity "$Identity" -Properties * | Select-Object -ExpandProperty DisplayName |fl
Get-ADUser -Identity "$Identity" -Properties * | Select-Object -ExpandProperty mailnickname |fl
Get-ADUser -Identity "$Identity" -Properties * | Select-Object -ExpandProperty proxyaddresses |fl
