function Disable-PrintHistory
{
    <#
    .Synopsis
    Disables logging of print jobs
    .DESCRIPTION
    This disables the Microsoft-Windows-PrintService/Operational in the event log. Every time something is printed, details about the print job will not be recorded into that event log.
    .EXAMPLE
    Disable-PrintHistory
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
            
            Write-Verbose ("Current Values: IsEnabled = {0}; " -f $EventLog.IsEnabled)
              
            Write-Verbose "Disabling Microsoft-Windows-PrintService/Operational event log"
            Write-Verbose "Setting Values: IsEnabled = False;"
            
            foreach($log in $EventLog)
            {
                $log.IsEnabled = $false
                $log.SaveChanges()             
            }
        }
        else
        {
            Write-Error "This action requires administrator rights to modify the eventlog"
        }
    }
}
