Param(
    [Parameter (Mandatory = $true)]
    [String] $oldthumb
,
    [Parameter (Mandatory = $true)]
    [String] $newthumb
)
$certSubject = "CN=awssqtrpw01.pomeroy.com"
$ssrsServerName = "RS_SSRS"
$httpsPort = 443
$ipAddress = "0.0.0.0"

$wmiName = (Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer -Filter "Name='$ssrsServerName'"  -class __Namespace).Name
$version = (Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer\$wmiName  -class __Namespace).Name
$rsConfig = Get-WmiObject -namespace "root\Microsoft\SqlServer\ReportServer\$wmiName\$version\Admin" -class MSReportServer_ConfigurationSetting

#$newthumb = (gci -path cert:/LocalMachine/My | Where-Object {$_.Subject.StartsWith($certSubject)} | Sort-Object -property NotAfter -descending | Select-Object -First 1).Thumbprint.ToLower()
#$oldthumb = $rsConfig.ListSSLCertificateBindings(1033).CertificateHash.Item([array]::LastIndexOf($rsConfig.ListSSLCertificateBindings(1033).Application, 'ReportServerWebApp'))

if ($oldthumb -ne $newthumb) {
    netsh http delete sslcert 0.0.0.0:443
	netsh http delete sslcert [::]:443
	$rsConfig.RemoveSSLCertificateBindings('ReportServerWebApp', $oldthumb, $ipAddress, $httpsport, 1033) 
    $rsConfig.RemoveSSLCertificateBindings('ReportServerWebService', $oldthumb, $ipAddress, $httpsport, 1033)
    $rsConfig.CreateSSLCertificateBinding('ReportServerWebApp', $newthumb, $ipAddress, $httpsport, 1033)
    $rsConfig.CreateSSLCertificateBinding('ReportServerWebService', $newthumb, $ipAddress, $httpsport, 1033) 
}
