
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
            Name = $printer.$Name
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
        [parameter(Mandatory)]
        [string] $DriverName,

        # IP address of printer
        [parameter(Mandatory)]
        [string] $PrinterIP,

        # Name of printer port
        [string] $PortName,

        # Enable printer sharing
        [Boolean] $isShared=$false,

        # Name of shared printer
        [string] $ShareName,

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

    $printer = Get-WmiObject Win32_Printer | Where-Object{ $_.Name -eq $Name }

    if($Ensure -eq "Present"){
        $port = Get-WmiObject Win32_TCPIPPrinterPort | Where-Object{ $_.Name -eq $PortName }
        
        if($port -eq $null){
            Write-Verbose "Creating new printer port"
            $port = ([WMICLASS]"\\localhost\ROOT\cimv2:Win32_TCPIPPrinterPort").createInstance()
            $port.Protocol=1
            $port.SNMPEnabled=$false
            $port.Name= $Portname            
        }                
        $port.HostAddress= $PrinterIP
        Write-Verbose "Saving changes to printer port: $PortName"
        $port.Put()

        if($printer -eq $null){
            Write-Verbose "Printer does not exist, creating new one."
            $print = ([WMICLASS]"\\localhost\ROOT\cimv2:Win32_Printer").createInstance()
        }

        $print.drivername = $DriverName
        $print.PortName = $PortName
        if($isShared){
            $print.Shared = $isShared
            $print.Sharename = $ShareName
        }
        $print.Location = $Location
        $print.Comment = $Comment
        $print.DeviceID = $DeviceID

        Write-Verbose "Saving changes to printer: $Name"
        $print.Put()       
    }
    else #Absent
    {
        Write-Verbose "Removing Printer: $name"
        $printer.Pause()
        $printer.CancelAllJobs()
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
        [parameter(Mandatory)]
        [string] $DriverName,

        # IP address of printer
        [parameter(Mandatory)]
        [string] $PrinterIP,

        # Name of printer port
        [string] $PortName,

        # Enable printer sharing
        [Boolean] $isShared=$false,

        # Name of shared printer
        [string] $ShareName,

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
    
    Write-Verbose "Checking for printer: $Name"
    $printer = Get-TargetResource -Name $Name

    if($Ensure -eq "Present"){
        if($printer -eq $null) { return $false}

        Write-Verbose "Printer exists, validating other values"
        if($printer.DriverName -ne  $DriverName){ return $false}
        if($printer.PortName -ne $PortName){return $false}
        if($printer.isShared -ne $isShared){return $false}
        if($printer.ShareName -ne $ShareName){return $false}
        if($printer.Location -ne $Location){return $false}
        if($printer.Comment -ne $Comment){return $false}
        if($printer.DeviceID -ne $DeviceID){return $false}

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



Export-ModuleMember -Function *-TargetResource

