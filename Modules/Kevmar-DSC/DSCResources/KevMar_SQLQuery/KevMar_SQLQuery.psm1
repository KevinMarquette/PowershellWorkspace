function Get-TargetResource
{
    [CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    param
	(	
        # Path to script to make changes
        [parameter(Mandatory)]
        [string] $SetScript,

        # Path to script to query for key file value
        [parameter(Mandatory)]
        [string] $GetScript,

        # Column name from get script to check
        [parameter(Mandatory)]
        [string] $KeyField,

        # Value that the key field should contain
        [parameter(Mandatory)]
        [string] $RequiredValue,

        # Database to execute the script on
        [string] $Database = "TempDB"
	)
    [System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMO’) | out-null
    $SMO        = New-Object (‘Microsoft.SqlServer.Management.Smo.Server’) “localhost”
    $SQL        = $GetScript
    $SMOResults = $SMO.Databases[$Database].ExecuteWithResults($sql)
        
    if($SMOResults.tables)
    {
        Write-Output @{
            KeyField = $KeyField;  
            RequiredValue = $SMOResults.tables[0]."$KeyField"
        }
    }
    else
    {
        Write-Output @{
            KeyField = $null;  
            RequiredValue = $null
        }
    }
}

function Set-TargetResource
{
    
    [CmdletBinding()]
	param
	(	
        # Path to script to make changes
        [parameter(Mandatory)]
        [string] $SetScript,

        # Path to script to query for key file value
        [parameter(Mandatory)]
        [string] $GetScript,

        # Column name from get script to check
        [parameter(Mandatory)]
        [string] $KeyField,

        # Value that the key field should contain
        [parameter(Mandatory)]
        [string] $RequiredValue,

        # Database to execute the script on
        [string] $Database = "tempdb"
	)

    Write-Verbose "Using $Database to execute script $SetScriptPath"
    $SQL = $SetScript
    
    $Connection = new-object system.data.SqlClient.SQLConnection("Data Source=localhost;Integrated Security=SSPI;Initial Catalog=$Database;");
    $cmd = new-object system.data.sqlclient.sqlcommand($SQL, $Connection);
    
    try
    {
        $Connection.Open()
        $cmd.ExecuteScalar() 
    }
    finally
    {
        $Connection.Close()  
    }  
}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource
{
	[CmdletBinding()]
    [OutputType([Boolean])]
	param
	(	
        # Path to script to make changes
        [parameter(Mandatory)]
        [string] $SetScript,

        # Path to script to query for key file value
        [parameter(Mandatory)]
        [string] $GetScript,

        # Column name from get script to check
        [parameter(Mandatory)]
        [string] $KeyField,

        # Value that the key field should contain
        [parameter(Mandatory)]
        [string] $RequiredValue,

        # Database to execute the script on
        [string] $Database = "TempDB"
	)
    # The Get-TargetResource already gets all the values that we need
    $SQLResult = Get-TargetResource -SetScript $SetScript -GetScript $GetScript -KeyField $KeyField -Database $Database
    
    if($SQLResult."$KeyField" -eq $RequiredValue)
    {
        Write-Output $true
    }
    else
    {
        Write-Output $false
    }
}



Export-ModuleMember -Function *-TargetResource

