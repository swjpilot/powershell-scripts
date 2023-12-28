param(
[string] $CurrentThumbprint = "null",
[string] $PFXFilePath = "null",
[string] $PFXPassword = "null"
)

$certThumbprint = $CurrentThumbprint
$pfxPath = $PFXFilePath

If (($certThumbprint -eq "null") -or ($pfxPath -eq "null")) {

    Write-Host "Parameter is missing." -BackgroundColor "Black" -ForegroundColor "Green"
    Write-Host " "
    Write-Host ".\get-custom-domain-replace-cert.ps1 -CurrentThumbprint <thumbprint of the current certificate> -PFXFilePath <full path with PFX filename>" -BackgroundColor "Black" -ForegroundColor "Green"
    Write-Host " "

    Exit
}

If ((Test-Path -Path $pfxPath) -eq $False) {

    Write-Host "The pfx file does not exist." -BackgroundColor "Black" -ForegroundColor "Red"
    Write-Host " "

    Exit
}

$securePassword =  ConvertTo-SecureString $PFXPassword -AsPlainText -Force

Write-Host "Reading service principals. This operation might take longer..." -BackgroundColor "Black" -ForegroundColor "Green"

$aadapServPrinc = Get-AzureADServicePrincipal -Top 100000 | where-object {$_.Tags -Contains "WindowsAzureActiveDirectoryOnPremApp"}  

Write-Host "Reading Azure AD applications. This operation might take longer..." -BackgroundColor "Black" -ForegroundColor "Green"

$allApps = Get-AzureADApplication -Top 100000 

Write-Host "Reading application. This operation might take longer..." -BackgroundColor "Black" -ForegroundColor "Green"

$aadapApp = $aadapServPrinc | ForEach-Object { $allApps -match $_.AppId} 

foreach ($item in $aadapApp) { 

    $tempApps = Get-AzureADApplicationProxyApplication -ObjectId $item.ObjectId

    Write-Host ("")
    Write-Host ("SSL certificate change for the Azure AD Application Proxy apps below:")
    Write-Host ("")

    If ($tempApps.VerifiedCustomDomainCertificatesMetadata -match $certThumbprint) {
 
      $aadapServPrinc[$aadapApp.IndexOf($item)].DisplayName + " (AppId: " + $aadapServPrinc[$aadapApp.IndexOf($item)].AppId + ")"; 

       $tempApps | select ExternalUrl,InternalUrl,ExternalAuthenticationType | fl

       Set-AzureADApplicationProxyApplicationCustomDomainCertificate -ObjectId  $item.ObjectId -PFXFilePath $pfxPath -Password $securePassword

    }
}

Write-Host ("")
Write-Host ("Finished.") -BackgroundColor "Black" -ForegroundColor "Green"
Write-Host ("") 