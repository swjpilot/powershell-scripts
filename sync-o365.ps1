$s = New-PSSession -ComputerName gv365.d06.us
Invoke-Command -Session $s -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }
Remove-PSSession $s