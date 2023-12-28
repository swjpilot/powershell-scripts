param(
    [Parameter(Mandatory = $false)]
[string] $awsprofile,
    [Parameter(Mandatory = $false)]
[string] $awsregion
)

if (!($awsprofile)) {
    Write-Host "Enter your selection for the AWS Profile: "
    Write-Host "1 - thejohnweb"
    Write-Host "2 - Backup"
    Write-Host "3 - infrastructure"
    Write-Host "4 - retail"
    Write-Host "5 - mns"
    Write-Host "6 - prod-apps"
    Write-Host "7 - master"
    Write-Host "8 - tolt"
    Write-Host "9 - tst-apps"
    Write-Host "10 - dev"
    Write-Host "11 - webapps"
    Write-Host "12 - master 2"
    Write-Host "13 - sandbox - sj"
    Write-Host "14 - sandbox - nk"
    Write-Host "15 - sandbox - rb"
    Write-Host "16 - sandbox - sp"
    Write-Host "17 - logs"
    Write-Host "18 - audit"
    Write-Host "19 - Pomeroy Connect Prod"
    Write-Host "20 - Pomeroy Connect Test"
    Write-Host "21 - AI"
    $awsprofile = Read-Host
}
if (!($awsregion)) {
    Write-Host "Enter your selection for the AWS Region: "
    Write-Host "1 - us-east-1"
    Write-Host "2 - us-west-2"
    Write-Host "3 - us-east-2"
    Write-Host "4 - ap-southeast-1"
    Write-Host "5 - ap-south-1"
    $awsregion = Read-Host
}
switch -Wildcard ($awsprofile) {
    1 {$Env:AWS_PROFILE="thejohnweb"; break}
    2 {$Env:AWS_PROFILE="backup"; break}
    3 {$Env:AWS_PROFILE="infrastructure"; break}
    4 {$Env:AWS_PROFILE="retail"; break}
    5 {$Env:AWS_PROFILE="mns"; break}
    6 {$Env:AWS_PROFILE="prod-apps"; break}
    7 {$Env:AWS_PROFILE="master"; break}
    8 {$Env:AWS_PROFILE="tolt"; break}
    9 {$Env:AWS_PROFILE="tst-apps"; break}
    10 {$Env:AWS_PROFILE="dev"; break}
    11 {$Env:AWS_PROFILE="webapps"; break}
    12 {$Env:AWS_PROFILE="master2"; break}
    13 {$Env:AWS_PROFILE="sandboxsj"; break}
    14 {$Env:AWS_PROFILE="sandboxnk"; break}
    15 {$Env:AWS_PROFILE="sandboxrb"; break}
    16 {$Env:AWS_PROFILE="sandboxsp"; break}
    17 {$Env:AWS_PROFILE="logs"; break}
    18 {$Env:AWS_PROFILE="audit"; break}
    19 {$Env:AWS_PROFILE="prod-connect"; break}
    20 {$Env:AWS_PROFILE="test-connect"; break}
    21 {$Env:AWS_PROFILE="ai"; break}
    * { Write-Host "Your have not choosen a valid Profile"}
}
switch -Wildcard ($awsregion) {
    1 {$Env:AWS_REGION="us-east-1"; break}
    2 {$Env:AWS_REGION="us-west-2"; break}
    3 {$Env:AWS_REGION="us-east-2"; break}
    4 {$Env:AWS_REGION="ap-southeast-1"; break}
    5 {$Env:AWS_REGION="ap-south-1"; break}
    * { Write-Host "Your have not choosen a valid Region"}
}
