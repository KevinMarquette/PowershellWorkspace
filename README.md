This is my first git repo. Using it as a place to store various script and modules that I create in my free time.

DSC Resource KevMar_WindowsUpdate
<#
.SYNOPSIS
Configures Automatic Updates for a system.

.NOTES
This resource manages the registry keys related to Windows Updates. Detailed documentation related to the underlying registry keys can be found here: http://technet.microsoft.com/en-us/library/dd939844(v=ws.10).aspx

.PARAMETER AutomaticUpdate
Enables or disables automatic updates

.PARAMETER AutoUdateOptions

"Notify" = Notify before download.

"Download" = Automatically download and notify of installation. 

"Install" = Automatically download and schedule installation. Only valid if values exist for ScheduledInstallDay and ScheduledInstallTime.

"Configurable" = Automatic Updates is required and users can configure it.

.PARAMETER UseWUServer
Enables or disables the use of WSUS to manage updates.
.PARAMETER WUServer
HTTP(S) URL of the WSUS server that is used by Automatic Updates and API callers (by default). 

.PARAMETER TargetGroup
Name of the computer group to which the computer belongs. 

.PARAMETER ScheduledInstallDay
"Every day","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"
        
.PARAMETER ScheduledInstallTime
Hour of the day from 0 to 23
#>

Modules should be copied into c:\program files\WindowsPowershell

Examples are just that


Notes to self:

git pull

git add -A

git diff

git commit -m "Commit message"

git push
