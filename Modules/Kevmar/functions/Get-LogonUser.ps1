function Get-LogonUser
{
    <#
    .SYNOPSIS
    Identifies the logged on users of a system
    .EXAMPLE
    Get-LogonUser -ComputerName workstation
    .NOTES
    It enumerates the explorer.exe processes on the system and identifes the owner.
    #>
    
    [cmdletbinding()]
    param(
        [Parameter(
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string[]]
        $ComputerName="$Env:Computername"
    )
    
    process
    {
        foreach($node in $ComputerName)
        {
            Write-Verbose "Verifying $node is online"
            
            if(Test-Connection -ComputerName $node -Count 1 -ErrorAction SilentlyContinue)
            {
                Write-Verbose "Getting processes from $Computer"            
                $processList = Get-WMIObject Win32_Process  -Filter 'Name="explorer.exe"' -ComputerName $node
                
                foreach ($process in $processList) 
                {
                    $owner = $process.GetOwner()
                    
                    $userSession = [pscustomobject][ordered]@{
                        UserName =  $owner.Domain + "\" + $owner.User
                        CreationDate = $process.ConvertToDateTime($process.CreationDate)
                        ComputerName = $node 
                    } 
                    
                    Write-Output $userSession
                }
            }
            else
            {
                Write-Verbose "$Computer offline"
            }
        }
    }
}
