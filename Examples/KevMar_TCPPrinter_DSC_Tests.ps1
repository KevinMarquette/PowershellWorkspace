$printer = @{
    PortName   =  "10.112.11.113"                                                        
    DriverName =  "EPSON NX430 Series"                                                   
    PrinterIP  =  "10.112.11.113"                                                        
    Comment    =  "Comment"                                                                               
    isShared   =  $false                                                                                                                              
    Name       =  "EPSON NX430 Series"                                                                            
    Location   =  "Location"                                                                          
    DeviceID   =  "EPSON NX430 Series" 
    ShareName = "ShareName"                                                  
}

Test-TargetResource @printer -Verbose


Set-TargetResource @printer -Verbose


Set-TargetResource -Name "EPSON NX430 Series" -Ensure Absent -Verbose


Configuration ConfigExample
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
       TCPPrinter EpsonPrinter
       {
            Name       =  "EPSON NX430 Series"
            DeviceID   =  "EPSON NX430 Series"
            DriverName =  "EPSON NX430 Series"
            PortName   =  "10.112.11.114"
            PrinterIP  =  "10.112.11.114"
            Comment    =  "Comment"
            Location   =  "Location"
            isShared   =  $false
            ShareName  = "ShareName"
            Ensure     = "Present"
       }
   }
}

ConfigExample

Start-DscConfiguration -Wait -Verbose -Path .\ConfigExample

