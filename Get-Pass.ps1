$bat = @"
<!-- :
@ECHO off
setlocal EnableDelayedExpansion
for /f "tokens=* delims=" %%p in ('mshta.exe "%~f0') do (
    set "adminPass=%%p"
)
(
    endlocal
    set "%~2=%adminPass%"
)
-->

<html>
<head><title>Password submitter</title></head>
<body>

    <script language='javascript' >
        function pipePass() {
            var pass=document.getElementById('pass').value;
            var fso= new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(fso.Write(pass));

        }
    </script>

    <input type='password' name='pass' size='50'></input>
    <hr>
    <button onclick='pipePass()'>Submit</button>

</body>
</html>
"@
$tempFile = "$env:TEMP\password.bat"
Out-File -FilePath $tempFile -Encoding ascii -InputObject $bat
$password = Invoke-Command -Command {cmd /k $tempfile}
Remove-Item -path $tempFile
Write-Host "This is your Password: $password"


