Configuration ConfigExample
{
   Import-DscResource -ModuleName KevMar
   Node localhost
   {
       MapPrinter NetworkPrinter
       {
            Path   =  '\\server\EpsonPrinter'
            Ensure = "Present"
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
       MapPrinter NetworkPrinter
       {
            Path = '\\server\EpsonPrinter'
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
       MapPrinter NetworkPrinter
       {
            Path   =  '\\server\EpsonPrinter'
            Ensure = "Absent"
       }
   }
}

RemoveMapPrinter

Start-DscConfiguration -Wait -Verbose -Path .\RemoveMapPrinter
