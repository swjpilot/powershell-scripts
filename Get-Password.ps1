$htmlContent = @"
<html>
<head><title>Password submitter</title></head>
<body>

    <script language='javascript' >
        function pipePass() {
            var pass=document.getElementById('pass').value;
            var shell = new ActiveXObject("WScript.Shell");
            var fso = new ActiveXObject("Scripting.FileSystemObject");
            var tempFolder = fso.GetSpecialFolder(2);
            var env = shell.Environment("Process");
            var file = fso.CreateTextFile(tempFolder + "\\pass.txt", true);
            file.Write(pass);
            file.Close();
            window.close();
        }
    </script>

    <input type='password' name='pass' size='50'></input>
    <hr>
    <button onclick='pipePass()'>Submit</button>

</body>
</html>
"@
$tempFile = "$env:TEMP\password.html"
Out-File -FilePath $tempFile -Encoding ascii -InputObject $htmlContent
Start-Process -FilePath $env:windir\system32\mshta.exe -ArgumentList $tempFile -Wait -WorkingDirectory $env:TEMP
$password = Get-Content -Path "$env:TEMP\pass.txt"
Remove-Item -Path $tempFile
Remove-Item -Path "$env:TEMP\pass.txt"
Write-Host "This is your Password: $password"
