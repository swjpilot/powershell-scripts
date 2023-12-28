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

$source = "https://s3.amazonaws.com/pomeroy-tst/downloads/vmtools/VMware-tools-11.2.6-17901274-x86_64.exe"
$destination = "$workdir\vmtools.exe"

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

Start-Process -FilePath $destination -ArgumentList '/S /v "/qn ADDLOCAL=ALL"'

# Wait XX Seconds for the installation to finish

Start-Sleep -s 30

# Remove the installer

rm -Force $destination
