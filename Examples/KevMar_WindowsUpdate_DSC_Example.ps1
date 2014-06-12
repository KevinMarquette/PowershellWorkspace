#KevMar_WindowsUpdate is a custom DSC Resource

Configuration ConfigExample
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
       KevMar_WindowsUpdate WindowsUpdates
       {
           AutomaticUpdate = $true;
           AutoUpdateOptions = "Install";
           UseWUServer = $true;
           WUServer= "http://ServerName"                      
           ScheduledInstallDay = "Every day";
           ScheduledInstallTime = 3;
           TargetGroup = "TestGroup"
       }
   }
} 

ConfigExample

Start-DscConfiguration -Wait -Verbose -Path .\ConfigExample

