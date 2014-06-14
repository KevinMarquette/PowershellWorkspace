
#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    param
	(	
        # Network path to printer
        [parameter(Mandatory)]
        [string] $Path
	)
    
    $printer = Get-WmiObject Win32_Printer | Where-Object{$_.Name -eq $Path}	
    if($printer){
       return @{
            Name = $printer.Name
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
        # Network path of printer
        [parameter(Mandatory)]
        [string] $Path,

        # Should the printer be created or deleted
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)

    if($Ensure -eq "Present"){     
        
        rundll32 printui.dll,PrintUIEntry /ga /n$path /z
    } 
    else #$Ensure -eq "Absent"
    {
         rundll32 printui.dll,PrintUIEntry /da /n$path
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
        # Network path to printer
        [parameter(Mandatory)]
        [string] $Path,

        # Should the printer be created or deleted
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)

    $printer = Get-TargetResource -Path $Path

    # found printer and there should be one
    if($printer -ne $null -and $Ensure -eq "Present"){return $true}

    # no printer should be found
    elseif($printer -eq $null -and $Ensure -eq "Absent"){return $true}

    # everything else indicates test failed
    return $false
    
}

Export-ModuleMember -Function *-TargetResource

