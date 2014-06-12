# Deploys modules to the local system
Write-Host "Copying .\Modules\KevMar to 'C:\Program Files\WindowsPowerShell\Modules\'" -ForegroundColor Yellow
Copy-Item .\Modules\KevMar 'C:\Program Files\WindowsPowerShell\Modules\' -Recurse -Force