function Get-PrintHistory
{
    <#
    .Synopsis
    Pulls the printer history from the target computer.
    .DESCRIPTION
    It parses the print log file for printer events related to printing. It is important that the log be enabled. If a log is cleared, then this data will be inaccurate.
    .PARAMETER computername
    The computer name(s) to retrieve the info from.
    .EXAMPLE
    Get-PrintHistory
    .EXAMPLE
    Get-PrintHistory -ComputerName localhost
    #>
    [cmdletbinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position=0)]
        [string]$ComputerName="localhost"
    )
    
    begin
    {
        $messageRegEx = "(?<Document>.+), Print Document owned by (?<Username>.+) on (?<Computer>.+) was printed on (?<Printer>.+) through port (?<IP>.+)\.  Size in bytes: (?<Size>\d+)\. Pages printed: (?<Pages>\d+)\. No user action is required\."
    }

    process
    {
        Write-Verbose "Getting Events from Computer: $ComputerName"
        $winEvent = Get-WinEvent -FilterHashTable @{ "LogName"= "Microsoft-Windows-PrintService/Operational";"ID"="307"} -ComputerName $ComputerName
      
        Write-Verbose "Parsing $($winEvent.Count) events"
        
        foreach($event in $winEvent)
        {
            if($event.message -match $messageRegEx)
            {
                $message = [PSCustomObject]@{
                    Document     = $Matches.Document;
                    UserName     = $Matches.Username;
                    IP           = $Matches.IP;
                    ComputerName = $Matches.Computer;
                    Pages        = $Matches.Pages;
                    TimeStamp    = $event.TimeCreated;
                    Printer      = $Matches.Printer;
                    PrintHost    = $event.MachineName
                }
                
                Write-Output $message
            }
        }
    }
}


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

Export-Modulemember -function *
