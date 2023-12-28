param(
    [Parameter(Mandatory = $false)]
[string] $awsregion
)

if (!($awsregion)) {
    Write-Host "Enter your selection for the AWS Region: "
    Write-Host "1 - us-east-1"
    Write-Host "2 - us-west-2"
    Write-Host "3 - us-east-2"
    Write-Host "4 - ap-southeast-1"
    Write-Host "5 - ap-south-1"
    $awsregion = Read-Host
}
switch -Wildcard ($awsregion) {
    1 {$Env:AWS_REGION="us-east-1"; break}
    2 {$Env:AWS_REGION="us-west-2"; break}
    3 {$Env:AWS_REGION="us-east-2"; break}
    4 {$Env:AWS_REGION="ap-southeast-1"; break}
    5 {$Env:AWS_REGION="ap-south-1"; break}
    * { Write-Host "Your have not choosen a valid Region"}
}
