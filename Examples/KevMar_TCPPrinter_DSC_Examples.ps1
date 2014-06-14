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
            PortName   =  "10.112.11.113"
            PrinterIP  =  "10.112.11.113"
            Comment    =  "Comment"
            Location   =  "Location"
            isShared   =  $false
            ShareName  = "TestShare"
            Ensure     = "Present"
       }
   }
}

ConfigExample

Start-DscConfiguration -Wait -Verbose -Path .\ConfigExample

# Minimal values for config to work

Configuration MinConfig
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
       TcpPrinter EpsonPrinter
       {
            Name       =  "EPSON NX430 Series"            
            DriverName =  "EPSON NX430 Series"            
            PrinterIP  =  "10.112.11.113"            
       }
   }
}

MinConfig

Start-DscConfiguration -Wait -Verbose -Path .\MinConfig

# Remove printer

Configuration RemoveTCPPrinter
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
       TcpPrinter EpsonPrinter
       {
            Name       =  "EPSON NX430 Series"            
            Ensure     =  "Absent"          
       }
   }
}

RemoveTCPPrinter

Start-DscConfiguration -Wait -Verbose -Path .\RemoveTCPPrinter
