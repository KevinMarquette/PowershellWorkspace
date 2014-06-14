Configuration ConfigExample
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
       MapPrinter EpsonPrinter
       {
            Path       =  '\\localhost\EpsonPrinter'            
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
       MapPrinter EpsonPrinter
       {
            Path       =  '\\localhost\EpsonPrinter'            
       }
   }
}

MinConfig

Start-DscConfiguration -Wait -Verbose -Path .\MinConfig

# Remove printer

Configuration RemoveMapPrinter
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
        MapPrinter EpsonPrinter
       {
            Path       =  '\\localhost\EpsonPrinter'            
            Ensure     = "Absent"
       }
   }
}

RemoveMapPrinter

Start-DscConfiguration -Wait -Verbose -Path .\RemoveMapPrinter
