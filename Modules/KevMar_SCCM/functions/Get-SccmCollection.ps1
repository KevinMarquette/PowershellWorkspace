function Get-SccmCollection
{
    [cmdletbinding()]
    param(
        [Parameter(
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string]
        $Name = "",
        
        [string]
        $SccmServer = "$env:computername",
        
        [string]
        $Site = ""
    )
    
    process
    {
        Write-Verbose "Checking sms_collection in namespace root\sms\site_$site on $SccmServer"
        Get-WMIObject -Namespace "root\sms\site_$site" -Class 'sms_collection' -ComputerName $SccmServer | 
            Select-Object Name, CollectionID, MemberCount, LimitToCollectionName | 
            Where-Object{$_.name -imatch $Name -or $Name -eq ""}       
    }
}
