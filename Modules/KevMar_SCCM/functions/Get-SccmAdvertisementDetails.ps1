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
