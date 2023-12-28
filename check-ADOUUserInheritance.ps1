param(
    [Parameter(Mandatory = $true)]
[string] $OU,
    [Parameter(Mandatory = $false)]
[boolean] $EnableInheritance = $false
)

Write-Host "These Users have inheritance disabled in the OU: $OU"
Get-ADUser -SearchBase $OU -Filter * -Properties nTSecurityDescriptor | ?{ $_.nTSecurityDescriptor.AreAccessRulesProtected -eq "True" }

if ($EnableInheritance) {
    Write-Host " I am now going to Enable Inherittance on the Users listed above in the OU: $OU"
    Get-ADUser -SearchBase $OU -Filter * -Properties nTSecurityDescriptor | Where-Object { $_.nTSecurityDescriptor.AreAccessRulesProtected -eq "True" } | ForEach-Object {
        $_.ntSecurityDescriptor.SetAccessRuleProtection($false, $true)
        $_ | Set-ADUser -Replace @{ntSecurityDescriptor = $_.ntSecurityDescriptor }
    }
}
else {
    Write-Host " I am NOT going to Enable Inherittance on the Users listed above because EnableInheritance was not specified or was set to FALSE"
}