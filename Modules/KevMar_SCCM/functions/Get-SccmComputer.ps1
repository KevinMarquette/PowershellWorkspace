function Get-SccmComputer
{
    [cmdletbinding()]
    param(
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $CollectionID = "",
        
        [string]
        $SccmServer = "$env:computername",
        
        [string]
        $Site = ""
    )
    
    process
    {
        Write-Verbose "Checking sms_cm_res_coll_$CollectionID in namespace root\sms\site_$site on $SccmServer"
        Get-WMIObject -Namespace "root\sms\site_$site" -Query "select * from sms_cm_res_coll_$CollectionID" -ComputerName  $SccmServer | 
            Select-Object @{Name="ComputerName";Expression={$_.Name}} 
    }
}