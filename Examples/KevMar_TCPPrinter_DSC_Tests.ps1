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

Get-WmiObject win32_printer | where name -eq $printer.Name | fl *

