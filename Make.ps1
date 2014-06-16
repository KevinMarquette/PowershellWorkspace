# Deploys modules to the local system
Write-Host "Copying .\Modules\KevMar to 'C:\Program Files\WindowsPowerShell\Modules\'"
Copy-Item .\Modules\KevMar 'C:\Program Files\WindowsPowerShell\Modules\' -Recurse -Force

###
### find the Process that is hosting the DSC engine
###
Get-WmiObject msft_providers | 
Where-Object {$_.provider -like 'dsccore'} | 
Select-Object -ExpandProperty HostProcessIdentifier -OutVariable dscProcessID

###
### Kill it
###
Write-Host "Restarting DSC process"
if($dscProcessID){
    Write-Host "  ID $dscProcessID"
    Get-Process -Id $dscProcessID | Stop-Process
}else {Write-Host "  No Process"}

Write-Host "Done"
