@echo off
wmic /node:localhost product get name | findstr /R /C:"Automox" > %installed%
if %installed%=="" c:\windows\syswow64\windowspowershell\powershell.exe -c "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://pomeroy-tst.s3.amazonaws.com/scripts/Install-Automox.ps1'))"
