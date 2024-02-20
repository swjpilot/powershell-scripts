 Param ($command)

$oldPreference = $ErrorActionPreference
$ErrorActionPreference = ‘stop’
try {if(Get-Command $command){“$command exists”}}
Catch {“$command does not exist”}
Finally {$ErrorActionPreference=$oldPreference} 