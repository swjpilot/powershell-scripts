﻿[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$userName = $( Read-Host "Input First Name please" )
)

Import-Module ActiveDirectory
$dcs = Get-ADDomainController -Filter {Name -like "*"}
$time = 0
foreach($dc in $dcs)
{ 
$hostname = $dc.HostName
$user = Get-ADUser $userName | Get-ADObject -Properties lastLogon 
if($user.LastLogon -gt $time) 
{
  $time = $user.LastLogon
}
}
$dt = [DateTime]::FromFileTime($time)
Write-Host $username "last logged on at:" $dt