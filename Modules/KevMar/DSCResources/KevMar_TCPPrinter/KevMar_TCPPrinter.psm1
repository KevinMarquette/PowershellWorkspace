
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
    $printer = Get-WmiObject Win32_Printer | Where-Object{ $_.Name -eq $Name }

    if($Ensure -eq "Present"){

        # Check for and create/update printer port first
        $port = Get-WmiObject Win32_TCPIPPrinterPort | Where-Object{ $_.Name -eq $PortName }
        
        if($port -eq $null){
            Write-Verbose "Creating new printer port"
            $port = ([WMICLASS]"Win32_TCPIPPrinterPort").createInstance()
            $port.Protocol=1
            $port.SNMPEnabled=$false
            $port.Name= $Portname            
        }                
        $port.HostAddress= $PrinterIP
        Write-Verbose "Saving changes to printer port: $PortName"
        $verbose = $port.Put()
        Write-Verbose $verbose

        if($printer -eq $null){
            Write-Verbose "Printer does not exist, creating new one."
            $printer = ([WMICLASS]"Win32_Printer").createInstance()
        }

        $printer.DriverName = $DriverName
        $printer.PortName = $PortName
        $printer.Shared = $isShared

        if($isShared -eq $true){
            $printer.Sharename = $ShareName
        }
        $printer.Location = $Location
        $printer.Comment = $Comment

        # Use name for DeviceID if not defined
        if($DeviceID -eq $null -or $DeviceID -eq ""){
            $printer.DeviceID = $Name
        }else{
            $printer.DeviceID = $DeviceID
        }
       
        try
        {
           Write-Verbose "Saving changes to printer: $Name"
            $putOptions = new-Object System.Management.PutOptions
            $putOptions.Type = [System.Management.PutType]::CreateOnly;

            $verbose = $printer.PsBase.Put($putOptions )
            Write-Verbose $verbose   
        }
        catch [Exception]
        {
            Write-Verbose $_.Exception
            Write-Verbose "Test"
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



Export-ModuleMember -Function *-TargetResource

