
Configuration KevMar_WindowsUpdate
{
    param
    (
		[System.Boolean]
		$AutomaticUpdate,
        [ValidateSet("Notify","Download","Install","Configurable")]
		[System.String]		
        $AutoUpdateOptions,
        [System.Boolean]
        $UseWUServer,
        [System.String]
        $WUServer,
        [ValidateSet("Every day","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")]
        [System.String]
        $ScheduledInstallDay,
        [ValidateRange(0,23)]
        [System.Int16]
        $ScheduledInstallTime,
        [String]
        $TargetGroup
    )
    
    #Initialize variables to default values.
    $AUOptions = 1
    $ScheduledInstallDayValue=0

    switch ($AutoUpdateOptions)
    {
        "Notify" 
        {
            $AUOptions = 2
        }    
        "Download" 
        {
            $AUOptions = 3
        }    
        "Install" 
        {
            $AUOptions = 4
        }    
        "Configurable" 
        {
            $AUOptions = 5
        }    
     
    }
    
    switch($ScheduledInstallDay){
        "Every day" {$ScheduledInstallDayValue=0}    
        "Sunday" {$ScheduledInstallDayValue=1}  
        "Monday" {$ScheduledInstallDayValue=2}  
        "Tuesday" {$ScheduledInstallDayValue=3}  
        "Wednesday" {$ScheduledInstallDayValue=4}  
        "Thursday" {$ScheduledInstallDayValue=5}  
        "Friday" {$ScheduledInstallDayValue=6}  
        "Saturday" {$ScheduledInstallDayValue=7}  
    }

    $AUKey = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $WUKey = "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate"
    if($AutoUpdateOptions){
        Registry WindowsUpdateAutoUpdateOptions
        {       
            Ensure = "Present"
            Key = $AUKey
            ValueName = "AUOptions"
            ValueData = [string] $AUOptions
            ValueType = "Dword"
        }
    }
    Registry WindowsUpdateNoAutoUpdate
    {       
        Ensure = "Present"
        Key = $AUKey
        ValueName = "NoAutoUpdate"
        ValueData = [string] [int](-not $AutomaticUpdate)
        ValueType = "Dword"
    }
    
    
    if ($UseWUServer -eq $false) {
        Registry WindowsUpdateUseWUServer
        {       
            Ensure = "Present"
            Key = $AUKey
            ValueName = "UseWUServer"
            ValueData = "0"
            ValueType = "Dword"
        }
        Registry WindowsUpdateWUServer
        {       
            Ensure = "Absent"
            Key = $WUKey
            ValueName = "WUServer"
        }
        Registry WindowsUpdateWUStatusServer
        {       
            Ensure = "Absent"
            Key = $WUKey
            ValueName = "WUStatusServer"
        }
    } #WSUS settings
    elseif($UseWUServer -eq $true -or $WUServer){
        Registry WindowsUpdateUseWUServer
        {       
            Ensure = "Present"
            Key = $AUKey
            ValueName = "UseWUServer"
            ValueData = [string] [int]$true
            ValueType = "Dword"
        }
        Registry WindowsUpdateWUServer
        {       
            Ensure = "Present"
            Key = $WUKey
            ValueName = "WUServer"
            ValueData = [string] $WUServer
            ValueType = "String"
        }
        Registry WindowsUpdateWUStatusServer
        {       
            Ensure = "Present"
            Key = $WUKey
            ValueName = "WUStatusServer"
            ValueData = [string] $WUServer
            ValueType = "String"
        }
    }
    if($ScheduledInstallDay -ne $null){
        Registry WindowsUpdateScheduledInstallDay
        {       
            Ensure = "Present"
            Key = $AUKey
            ValueName = "ScheduledInstallDay"
            ValueData = [string] [int]$ScheduledInstallDayValue
            ValueType = "Dword"
        }
    }
    if($ScheduledInstallTime -ne $null){
        Registry WindowsUpdateInstallTime
        {       
            Ensure = "Present"
            Key = $AUKey
            ValueName = "ScheduledInstallTime"
            ValueData = [string] [int]$ScheduledInstallTime
            ValueType = "Dword"
        }
    }
    if($TargetGroup -ne $null){
        Registry WindowsUpdateTargetGroup
        {       
            Ensure = "Present"
            Key = $WUKey
            ValueName = "TargetGroup"
            ValueData = [string] $TargetGroup
            ValueType = "String"
        }
        Registry WindowsUpdateTargetGroupEnabled
        {       
            Ensure = "Present"
            Key = $WUKey
            ValueName = "TargetGroupEnabled"
            ValueData = "1"
            ValueType = "Dword"
        }
    }
    
}

