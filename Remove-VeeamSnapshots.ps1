Add-PSSnapin vmware*
$snapshots = get-vm | get-snapshot
foreach ($snapshot in $snapshots) { 
	if ($snapshot.name -like "VEEAM*"){
		remove-snapshot $Snapshot -confirm:$false -runAsync
	}
}