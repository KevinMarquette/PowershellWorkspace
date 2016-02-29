
function Enable-PrintHistory
{
    <#
    .Synopsis
    Enables logging of print jobs
    .DESCRIPTION
    This enables the Microsoft-Windows-PrintService/Operational in the event log. Every time something is printed, details about the print job will be recorded into that event log.
    .EXAMPLE
    Enable-PrintHistory
    #>
    
    [cmdletbinding()]
    param()

    process
    {
        Write-Verbose "Check for administrator rights"
        if( ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {           
            Write-Verbose "Retreiving Microsoft-Windows-PrintService/Operational Object"
            $EventLog = Get-WinEvent -ListLog Microsoft-Windows-PrintService/Operational 
            
            Write-Verbose ("Current Values: IsEnabled = {0}; MaximumSize = {1}MB; LogMode = {2}" -f $EventLog.IsEnabled,($EventLog.MaximumSizeInBytes / 1MB),$EventLog.LogMode)
              
            Write-Verbose "Enabling Microsoft-Windows-PrintService/Operational event log"
            Write-Verbose "Setting Values: IsEnabled = True; MaximumSizeInBytes=50MB; LogMode = AutoBackup"
            
            foreach($log in $EventLog)
            {
                $log.IsEnabled          = $true
                $log.MaximumSizeInBytes = 50MB
                $log.LogMode            = "AutoBackup"
                $log.SaveChanges()             
            } 
        }
        else
        {
            Write-Error "This action requires administrator rights to modify the eventlog"
        }
    }
}
