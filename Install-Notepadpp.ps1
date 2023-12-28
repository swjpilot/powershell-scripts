[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Silent Install Firefox
# Download URL: https://www.mozilla.org/en-US/firefox/all/

# Path for the workdir
$workdir = "c:\installer\"

# Check if work directory exists if not create it

If (Test-Path -Path $workdir -PathType Container)
{ Write-Host "$workdir already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $workdir  -ItemType directory }

# Download the installer

$source = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.2/npp.8.1.2.Installer.x64.exe"
$destination = "$workdir\notepadpp.exe"

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

Start-Process -FilePath "$destination" -ArgumentList "/S"

# Wait XX Seconds for the installation to finish

Start-Sleep -s 35

# Remove the installer

rm -Force $workdir\notepadpp*
