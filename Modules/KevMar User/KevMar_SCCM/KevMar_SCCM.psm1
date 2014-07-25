
## SCCM Scripts ##########################################################
function Get-SccmCollection{
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        $Name="",
        [string]
        $SccmServer = "$env:computername",
        [string]
        $Site = ""
        )
    Process
    {
        Write-Verbose "Checking sms_collection in namespace root\sms\site_$site on $SccmServer"
        Get-WmiObject -Namespace "root\sms\site_$site" -class 'sms_collection' -ComputerName $SccmServer | 
            Select-Object Name, CollectionID, MemberCount, LimitToCollectionName | 
            Where-Object{$_.name -imatch $Name -or $Name -eq ""}       
    }
}

#List all the computers in a collection
function Get-SccmComputer{
[CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        $CollectionID="",
        [string]
        $SccmServer = "$env:computername",
        [string]
        $Site = ""
        )
    Process
    {
        Write-Verbose "Checking sms_cm_res_coll_$CollectionID in namespace root\sms\site_$site on $SccmServer"
        get-wmiobject -namespace "root\sms\site_$site" -query "select * from sms_cm_res_coll_$CollectionID" -ComputerName  $SccmServer | 
            Select-Object @{Name="ComputerName";Expression={$_.Name}} 
    }
}

<#
# I like this functionality, but I don't think we need it at the moment.

#List all the application advertisements and general stats
function Get-SccmAdvertisement([string]$filter){
    $advertisements = get-wmiobject -namespace 'root\sms\site_$site' -ComputerName $computername -query "select * from SMS_ClientAdvertisementSummary" |
             Select-Object AdvertisementID, AdvertisementName, Succeeded, Failed, Running, Retrying, Waiting, Targeted |
             Sort-Object AdvertisementName

    if($filter){
        $advertisements |  ?{$_.advertisementName -imatch $filter -or $_.advertisementID -imatch $filter} 
          }else{
        $advertisements
    }
}

#Will list status of each advertisement on each computer
function Get-SccmAdvertisementDetails{
    $Advertisements = @{}
    $Computers = @{}

    Get-SCCMAdvertisement | %{$Advertisements.Add($_.advertisementID, $_.advertisementName)}
    get-wmiobject -namespace 'root\sms\site_$site' -ComputerName $computername -query "select * from SMS_Resource" | 
        %{$Computers.Add($_.ResourceID, $_.Name )}

    get-wmiobject -namespace 'root\sms\site_$site' -ComputerName $computername -query "select * from SMS_ClientAdvertisementStatus" | 
        Select-Object  @{Name="Name"; Expression={$Computers.Get_Item($_.ResourceID)}},  @{Name="Advertisement"; Expression={$Advertisements.Get_Item($_.AdvertisementID)}}, 
            LastAcceptanceMessageIDName, LastAcceptanceStateName, LastStateName, LastStatusMessageIDName, LastStatusTime
}
#>

