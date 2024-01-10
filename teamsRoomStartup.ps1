start-process -FilePath "C:\Program Files\Virtual Audio Cable\audiorepeater.exe" -ArgumentList '/Config:"C:\TeamsConf\Mic1.cfg" /WindowName:"Microphone 1 Input" /AutoStart' -WindowStyle Hidden
start-process -FilePath "C:\Program Files\Virtual Audio Cable\audiorepeater.exe" -ArgumentList '/Config:"C:\TeamsConf\Mic2.cfg" /WindowName:"Microphone 2 Input" /AutoStart' -WindowStyle Hidden
start-process -FilePath "C:\Program Files\Virtual Audio Cable\audiorepeater.exe" -ArgumentList '/Config:"C:\TeamsConf\Speak1.cfg" /WindowName:"Speaker 1 Output" /AutoStart' -WindowStyle Hidden
start-process -FilePath "C:\Program Files\Virtual Audio Cable\audiorepeater.exe" -ArgumentList '/Config:"C:\TeamsConf\Speak2.cfg" /WindowName:"Speaker 2 Output" /AutoStart' -WindowStyle Hidden
