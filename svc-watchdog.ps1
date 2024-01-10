[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
[string]$ServiceName = $( Read-Host "Input Service Name please" )
)
$logpath = $MyInvocation.MyCommand.Path
$logpath = Split-Path $logpath -Parent
$logFile = "serviceWatchdog-$($ServiceName).log"
if (!(test-Path "$logpath\\$logfile")){
	New-Item -path $logpath -name $logFile -type "file" -value "****************New log file for Service Watchdog created on $(Get-Date)**********************" -Force
}
$svc = Get-Service $ServiceName
if($svc.Status.ToString().ToLower() -eq "stopped"){
  $svc.Start()
  "$(Get-Date) - The Service $ServiceName was restarted" | out-file -path "$logpath\\$logfile" -append
  return 0
}
elseif($svc.Status.ToString().ToLower() -eq "running"){
  return 0
}
else{
  return 1
}
