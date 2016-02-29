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

