
#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    param
	(	
        # Name of printer
        [parameter(Mandatory)]
        [string] $Name
	)
    
    $printer = Get-WmiObject Win32_Printer | Where-Object{$_.Name -eq $Name}	
    if($printer){
       return @{
            Name = $printer.Name
            DriverName = $printer.DriverName
            PrinterIP = $printer.PortName
            PortName = $printer.PortName
            isShared = $printer.Shared
            ShareName = $printer.ShareName
            Location = $printer.Location
            Comment= $printer.Comment
            DeviceID = $printer.DeviceID
        }
    } else {
        return $null;
    }
}

######################################################################## 
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource
{
    
    [CmdletBinding()]
	param
	(	
        # Name of printer
        [parameter(Mandatory)]
        [string] $Name,

        # Name of driver
        [string] $DriverName,

        # Install source location
        [string] $DriverInf,

        # IP address of printer
        [string] $PrinterIP,

        # Name of printer port
        [string] $PortName,

        # Enable printer sharing
        [Boolean] $isShared=$false,

        # Name of shared printer
        [string] $ShareName = "",

        # Location of printer
        [string] $Location="",

        # Additional comments
        [string] $Comment="",

        # Device ID
        [string] $DeviceID,

        # Should the printer be created or deleted
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)

    # Generate portname from IP address if not defines
    if($PortName -eq $null -or $PortName -eq ""){
        $PortName = "IP_$PrinterIP"
    }

    # Use name for DeviceID if not defined
    if($DeviceID -eq $null -or $DeviceID -eq ""){
        $DeviceID = $Name
    }

    $printer = Get-WmiObject Win32_Printer | Where-Object{ $_.Name -eq $Name }

    if($Ensure -eq "Present"){

        if(isDriverInstalled($DriverName) -eq $false){
            InstallDriver($DriverName, $DriverInf)
        }
        # Check for and create/update printer port first
        $port = Get-WmiObject Win32_TCPIPPrinterPort | Where-Object{ $_.Name -eq $PortName }

        if($port -eq $null){
            Write-Verbose "Creating new printer port"
            $port = ([WMICLASS]"Win32_TCPIPPrinterPort").createInstance()
            $port.Protocol=1
            $port.SNMPEnabled=$false
            $port.Name= $PortName            
        }                
        $port.HostAddress= $PrinterIP

        Write-Verbose "Saving changes to printer port: $PortName"
        $verbose = $port.Put()
        Write-Verbose $verbose

        if($printer -eq $null){
            Write-Verbose "Printer does not exist, creating new one."
            AddPrinter $Name $PortName $DriverName

            # retreive printer object we just created
            $printer = Get-WmiObject Win32_Printer | Where-Object{ $_.Name -eq $Name }
        }


        $printer.DriverName = $DriverName
        $printer.PortName = $PortName
        $printer.Location = $Location
        $printer.Comment = $Comment
        $printer.DeviceID = $DeviceID
        $printer.Shared = $isShared

        if($isShared -eq $true){
            $printer.Sharename = $ShareName
        }
       
        try
        {
            Write-Verbose "Saving changes to printer: $Name"
            $verbose = $printer.Put( )
            Write-Verbose $verbose   
        }
        catch [Exception]
        {
            Write-Verbose $_.Exception
            Throw $_.Exception.Message
           
            
        }
      
      
    }
    else #Absent
    {
        Write-Verbose "Removing Printer: $name"
        $printer.Delete()
    }
}

#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource
{
	[CmdletBinding()]
	param
	(	
        # Name of printer
        [parameter(Mandatory)]
        [string] $Name,

        # Name of driver
        [string] $DriverName,

        # IP address of printer
        [string] $PrinterIP,

        # Name of printer port
        [string] $PortName,

        # Enable printer sharing
        [Boolean] $isShared=$false,

        # Name of shared printer
        [string] $ShareName="",

        # Location of printer
        [string] $Location="",

        # Additional comments
        [string] $Comment="",

        # Device ID
        [string] $DeviceID,

        # Should the printer be created or deleted
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)

    # Generate portname from IP address if not defines
    if($PortName -eq $null -or $PortName -eq ""){
        $PortName = "IP_$PrinterIP"
    }

    # Use name for DeviceID if not defined
    if($DeviceID -eq $null -or $DeviceID -eq ""){
        $DeviceID = $Name
    }

    Write-Verbose "Checking for printer: $Name"
    $printer = Get-TargetResource -Name $Name

    if($Ensure -eq "Present"){
        if($printer -eq $null) { return $false}

        Write-Verbose "Printer exists, validating other values"
        if($printer.DriverName -ne  $DriverName){ 
            Write-Verbose "DriveName does not match"
            return $false
        }
        if($printer.PortName -ne $PortName){
            Write-Verbose "PortName does not match"
            return $false
        }
        if($printer.isShared -ne $isShared){
            Write-Verbose "Shared does not match"
            return $false
        }

        # Only check the share name if the printer is shared
        if($printer.ShareName -ne $ShareName -and $printer.isShared -eq $true ){
            Write-Verbose "ShareName does not match"
            if($printer.ShareName -eq $null -and $ShareName -eq ""){
                Write-Verbose "Null or empty value exception"
            }else{
                return $false
            }
        }
        if($printer.Location -ne $Location){
            Write-Verbose "Location does not match"
            if($printer.Location -eq $null -and $Location -eq ""){
                Write-Verbose "Null or empty value exception"
            }else{
                return $false
            }
        }
        if($printer.Comment -ne $Comment){
            Write-Verbose "Comment does not match"
            if($printer.Comment -eq $null -and $Comment -eq ""){
                Write-Verbose "Null or empty value exception"
            }else{
                return $false
            }
            
        }
        if($printer.DeviceID -ne $DeviceID){
            Write-Verbose "DeviceID does not match"
            return $false
        }

        # at this point, everything matches
        Write-Verbose "Passed all validation checks"
        return $true
    }
    else # $Ensure -eq "Absent"
    {
        if($printer -eq $null){
            return $true
        } 
    }
    
    return $false
}

# Check to see if the driver is installed
function isDriverInstalled{
    [CmdletBinding()]
    param([string]$driverName)

    Write-Verbose "Checking for Driver: $driverName"
    $driver = Get-WmiObject Win32_PrinterDriver | Where-Object {$_.name -eq $driverName}

    if($driver){
        Write-Verbose "  Driver OK"
        return $true
    }

    Write-Verbose "  Driver not installed!!"
    return $false
}

function InstallDriver{
    [CmdletBinding()]
    param(

    # Name of driver
    [Parameter(Mandatory=$True,Position=0)]
    [string]$DriverName,

    # Location of inf for installation of driver
    [Parameter(Mandatory=$True,Position=1)]
    [string]$DriverInf
    )

    if($DriverInf -eq $null -or $DriverInf -eq ""){
        Write-Verbose "DriverInf is undefined, required to install this driver"
        throw "DriverInf is undefined, required to install this driver"
    }

    Write-Verbose "Installing driver from $DriverInf"
    if(Test-Path($DriverInf)){
        Write-Verbose "  Location OK"

        Write-Verbose "Create Win32_PrinterDriver instance"
        $Driver = ([WMICLASS]"Win32_PrinterDriver").createInstance()
        $Driver.Name = $DriverName
        $Driver.InfName = $DriverInf

        try
        {
            Write-Verbose "Add Driver to the system"
            $Result = $Driver.AddPrinterDriver($Driver)
            Write-Verbose $Result

        }
        catch [exception]
        {
            Write-Verbose $_.Exception
            Throw $_.Exception.Message
        }

    }
    else # Could not find driver inf
    {
        Write-Verbose "Access Denied or file does not exist: $DriverInf"
        Throw "Unable to find or access $DriverInf"
    }
    Write-Verbose "Done with driver: $DriverName"
}

function AddPrinter{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=0)]
        [string]$printerName,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$portName,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$driverName
    )
    
    Write-Verbose "New-Printer('$printerName','$portName','$driverName')"

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

    Write-Verbose "Calling custom C# module to add printer"
    $result = [KevMar.PrintSpooler]::NewPrinter(  $printerName, $portname, $driverName)
    Write-Verbose "KevMar.PrintSpooler::NewPrinter result: $result"

}

Export-ModuleMember -Function *-TargetResource

