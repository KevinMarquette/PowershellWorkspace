Function Get-TargetResource
{
	[OutputType([System.Collections.Hashtable])]
    param
	(	
        # Path to script to make changes
        [parameter(Mandatory)]
        [string] $SetScriptPath,

        # Path to script to query for key file value
        [parameter(Mandatory)]
        [string] $GetScriptPath,

        # Column name from get script to check
        [parameter(Mandatory)]
        [string] $KeyField,

        # Value that the key field should contain
        [parameter(Mandatory)]
        [string] $RequiredValue,

        # Database to execute the script on
        [string] $Database = "TempDB"
	)
    
    Write-Verbose "Checking for $GetScriptPath"
    if(Test-Path $GetScriptPath)
    {
        Write-Verbose "Establish SQL Connection"
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server=localhost;Database=$Database;User Id=SA;Password=Password#1;"
    
        Write-Verbose "Build the command object"
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = Get-Content -path $GetScriptPath -Raw
        $SqlCmd.Connection = $SqlConnection

        Write-Verbose "New DataAdapter"
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd

        # Fill a dataset with the results
        $DataSet = New-Object System.Data.DataSet
        Try
        {
            Write-Verbose "Execute SQL"
            $SqlAdapter.Fill($DataSet) | Out-Null
        } 
        Finally
        {
            Write-Verbose "Close Connection"
            $SqlConnection.Close() | Out-Null
        }
        
        
        if($DataSet.Tables)
        {
            Write-Verbose ("Value found {0} = '{1}'"-f $KeyField,  $DataSet.Tables[0]."$KeyField")
            Write-Output @{
                KeyField      = $KeyField
                RequiredValue = $DataSet.Tables[0]."$KeyField"
            }
        }
        else
        {
            Write-Verbose "Value Missing for $KeyField"
            Write-Output @{
                KeyField      = $KeyField
                RequiredValue = $null}
        }
    } 
    else 
    {
        Throw "Cannot find file $GetScriptPath"
    }

}

Function Set-TargetResource
{
	param
	(	
        # Path to script to make changes
        [parameter(Mandatory)]
        [string] $SetScriptPath,

        # Path to script to query for key file value
        [parameter(Mandatory)]
        [string] $GetScriptPath,

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

    $SQL = Get-Content -path $SetScriptPath -Raw
    
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

Function Test-TargetResource
{
	[OutputType([Boolean])]
	param
	(	
        # Path to script to make changes
        [parameter(Mandatory)]
        [string] $SetScriptPath,

        # Path to script to query for key file value
        [parameter(Mandatory)]
        [string] $GetScriptPath,

        # Column name from get script to check
        [parameter(Mandatory)]
        [string] $KeyField,

        # Value that the key field should contain
        [parameter(Mandatory)]
        [string] $RequiredValue,

        # Database to execute the script on
        [string] $Database = "TempDB"
	)
    
    Write-verbose "Get-TargetResource to verify test case"
    $SQLResult = Get-TargetResource -SetScriptPath $SetScriptPath -GetScriptPath $GetScriptPath -KeyField $KeyField -Database $Database
    
    Write-Verbose ("check values {0} -eq {1} " -f $SQLResult."$KeyField", $RequiredValue)
    
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

