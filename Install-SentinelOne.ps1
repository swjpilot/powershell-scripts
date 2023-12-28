[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Path for the workdir
$workdir = "c:\installer\"

# Check if work directory exists if not create it

If (Test-Path -Path $workdir -PathType Container)
{ Write-Host "$workdir already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $workdir  -ItemType directory }

# Download the installer

$source = "https://pomeroy-tst.s3.amazonaws.com/software/SentinelOneInstaller_windows+65.exe"
$destination = "$workdir\S1.exe"

# Check if Invoke-Webrequest exists otherwise execute WebClient

if (Get-Command 'Invoke-Webrequest')
{
     Invoke-WebRequest $source -OutFile $destination
}
else
{
    $WebClient = New-Object System.Net.WebClient
    $webclient.DownloadFile($source, $destination)
}

# Start the installation 
# Server Key - eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMDEtbXNzcC5zZW50aW5lbG9uZS5uZXQiLCAic2l0ZV9rZXkiOiAiNDEyMjBiNmM3ZGM2MmYyZSJ9
# RDS Key - eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMDEtbXNzcC5zZW50aW5lbG9uZS5uZXQiLCAic2l0ZV9rZXkiOiAiMTQzMjZiMzg4NGYxYjFhNiJ9

Start-Process -FilePath "$workdir\S1.exe" -ArgumentList "--qn -t eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMDEtbXNzcC5zZW50aW5lbG9uZS5uZXQiLCAic2l0ZV9rZXkiOiAiNDEyMjBiNmM3ZGM2MmYyZSJ9"

# Wait XX Seconds for the installation to finish

Start-Sleep -s 35

# Remove the installer

del /f $workdir\S1.*
