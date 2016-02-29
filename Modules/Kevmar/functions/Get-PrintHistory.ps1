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