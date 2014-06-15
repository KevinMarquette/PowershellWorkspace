# Deploys modules to the local system
Write-Host "Copying .\Modules\KevMar to 'C:\Program Files\WindowsPowerShell\Modules\'"
Copy-Item .\Modules\KevMar 'C:\Program Files\WindowsPowerShell\Modules\' -Recurse -Force

###
### find the Process that is hosting the DSC engine
###
$dscProcessID = Get-WmiObject msft_providers | 
Where-Object {$_.provider -like 'dsccore'} | 
Select-Object -ExpandProperty HostProcessIdentifier 

###
### Kill it
###
Write-Host "Restarting DSC process"
Get-Process -Id $dscProcessID | Stop-Process

Write-Host "Done"
