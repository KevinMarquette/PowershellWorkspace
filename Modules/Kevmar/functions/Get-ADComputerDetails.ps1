function Get-ADComputerDetails
{
    [cmdletbinding()]
    param(
        [Alias("Name")]
        [Parameter(
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string]
        $ComputerName="$env:computername"
    )
    
    process
    {
        $computers = Get-ADComputer $ComputerName -Properties Description,Modified,IPv4Address 
        
        foreach($node in $computers)
        {
            $ADObject = [pscustomobject][ordered]@{
                ComputerName = $node.Name
                Description  = Description
                Modified     = Modified
                IPv4Address  = IPv4Address
            }
            
            Write-Output $ADObject
        }
    }
}
