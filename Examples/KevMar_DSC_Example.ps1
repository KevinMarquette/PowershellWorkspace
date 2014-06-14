#KevMar_WindowsUpdate and TCPPrinter are custom DSC Resources

Configuration ConfigExample
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
       TcpPrinter EpsonPrinter
       {
            Name       =  "EPSON NX430 Series"
            DeviceID   =  "EPSON NX430 Series"
            DriverName =  "EPSON NX430 Series"
            PortName   =  "10.10.11.113"
            PrinterIP  =  "10.10.11.113"
            Comment    =  "Comment"
            Location   =  "Location"
            isShared   =  $false
            ShareName  = "TestShare"
            Ensure     = "Present"
       }

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

