# Deploys system modules to the local system
Write-Host "Cleaning 'C:\Program Files\WindowsPowerShell\Modules\KevMar'"
Remove-Item "C:\Program Files\WindowsPowerShell\Modules\KevMar" -Recurse -Force -ea 0
Write-Host "Copying '.\DSCModules\KevMar' to 'C:\Program Files\WindowsPowerShell\Modules\'"
Copy-Item ".\DSCModules\KevMar" 'C:\Program Files\WindowsPowerShell\Modules\' -Recurse -Force

# Deploys user modules to the local system
$modulePath = Split-Path $profile
Write-Host "Cleaning '$modulePath\Modules\KevMar User'"
Remove-Item "$modulePath\Modules\KevMar User" -Recurse -Force -ea 0
Write-Host "Copying '.\Modules\KevMar User' to '$modulePath\Modules\'"
Copy-Item ".\Modules\KevMar User" "$modulePath\Modules\" -Recurse -Force


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
