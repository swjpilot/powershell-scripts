$VCENTER = Get-VBRServer -Name hqvc.pomeroy.com
Set-VBRvCenter -Server $VCENTER -Port 443 -Force