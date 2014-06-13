<#
This file is full off one off commands that I use to test various parts of the module
#>

$printer = @{
    portname   =  "10.112.11.113"                                                        
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

Cscript c:\windows\System32\Printing_Admin_Scripts\en-US\Prnmngr.vbs -a -p $printer.Name -m $printer.drivername -r $printer.PortName

Cscript Prnmngr.vbs -a -p $printer.Name -m $printer.drivername -r $printer.PortName


rundll32 printui.dll,PrintUIEntry /if /b "Test Printer" /f %windir%\inf\ntprint.inf /r  "IP_157.57.50.98" /m "HP Laserjet 4000 Series PCL" /Z

Get-CimInstance CIM_Printer | ft name, portname

New-CimInstance cim_printer -Property $printer

Get-Command *cim*
get-cimclass cim_printer | Select-Object -ExpandProperty CimClassProperties | ft -auto


$source = @"
using System;
  using System.Collections.Generic;
  using System.Linq;
  using System.Text;
  using System.Runtime.InteropServices;

  namespace KevMar
  {
    public class PrintSpooler
    {
      [DllImport("winspool.drv", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall,     SetLastError = true)]
      static extern int AddPrinter(string pName, uint Level, [In] ref PRINTER_INFO_2 pPrinter);

      [DllImport("winspool.drv")]
      static extern int ClosePrinter(int hPrinter);

      public static int NewPrinter(string printerName, string portName, string driverName){
        
        PRINTER_INFO_2 pInfo = new PRINTER_INFO_2();
        int hPrt;
        int iError;
      
        pInfo.pPrinterName = printerName;
        pInfo.pPortName = portName;
        pInfo.pDriverName = driverName;
        pInfo.pPrintProcessor = "WinPrint";

        hPrt = AddPrinter("", 2, ref pInfo);
        if (hPrt == 0){
            iError = Marshal.GetLastWin32Error();
            return iError;
        }else{
             ClosePrinter(hPrt);
        }
        return 0;
        } 

      }

      [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
      public struct PRINTER_INFO_2
      {
        public string pServerName;
        public string pPrinterName;
        public string pShareName;
        public string pPortName;
        public string pDriverName;
        public string pComment;
        public string pLocation;
        public IntPtr pDevMode;
        public string pSepFile;
        public string pPrintProcessor;
        public string pDatatype;
        public string pParameters;
        public IntPtr pSecurityDescriptor;
        public uint Attributes;
        public uint Priority;
        public uint DefaultPriority;
        public uint StartTime;
        public uint UntilTime;
        public uint Status;
        public uint cJobs;
        public uint AveragePPM;
     }
  }
"@

Add-Type -TypeDefinition $source 

$printer = @{
    portname   =  "10.112.11.112"                                                        
    DriverName =  "EPSON NX430 Series"                                                   
    PrinterIP  =  "10.112.11.112"                                                        
    Comment    =  "Comment"                                                                               
    isShared   =  $false                                                                                                                              
    Name       =  "EPSON NX430 Series"                                                                            
    Location   =  "Location"                                                                          
    DeviceID   =  "EPSON NX430 Series" 
    ShareName = "ShareName"                                                  
}

[KevMar.PrintSpooler]::NewPrinter($printer.Name,$printer.portname,$printer.DriverName)


Get-Command *type*
get-help Remove-TypeData

Remove-TypeData PRINTER_INFO_2