$days = 90
$dcServer = 'gvdc1.d06.us'
$emailto = 'scott.john@toltsolutions.com', 'graham.clinch@toltsolutions.com'
$smtpserver = 'gvsmtp.d06.us'
$fromaddress = 'PasswordExpiration@toltsolutions.com'

$daysin = -$days
get-aduser -filter * -searchbase "OU=Migrated,DC=d06,DC=us" -Properties * -Server $dcServer |
where {$_.passwordlastset -lt ((get-date).adddays($daysin)) -and ($_.enabled -eq $true)}|
select -Property samaccountname,userprincipalname,passwordlastset,passwordneverexpires,enabled,title | Export-Csv c:\1\PasswordExpiringSoon.csv
get-aduser -filter * -searchbase "OU=SSG,DC=d06,DC=us" -Properties * -Server $dcServer |
where {$_.passwordlastset -lt ((get-date).adddays($daysin)) -and ($_.enabled -eq $true)}|
select -Property samaccountname,userprincipalname,passwordlastset,passwordneverexpires,enabled,title | Export-Csv c:\1\PasswordExpiringSoon.csv -Append
get-aduser -filter * -searchbase "OU=Temporary,DC=d06,DC=us" -Properties * -Server $dcServer |
where {$_.passwordlastset -lt ((get-date).adddays($daysin)) -and ($_.enabled -eq $true)}|
select -Property samaccountname,userprincipalname,passwordlastset,passwordneverexpires,enabled,title | Export-Csv c:\1\PasswordExpiringSoon.csv -Append

Send-MailMessage -to $emailto -Subject "Expired User IDs" -SmtpServer $smtpserver -From $fromaddress -Attachments c:\1\PasswordExpiringSoon.csv
