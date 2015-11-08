# http://technet.microsoft.com/en-us/magazine/hh855069.aspx
# Don Jon wrote these but I use them in other scripts

function Get-DatabaseData {
    [CmdletBinding()]
    param (
        [string]$connectionString,
        [string]$query,
        [switch]$isSQLServer = $true
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    } else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }

    Write-Verbose "ConnectionString: $connectionString"
    $connection.ConnectionString = $connectionString

    $command = $connection.CreateCommand()

    Write-Verbose "CommandText: $query"
    $command.CommandText = $query

    if ($isSQLServer) {
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    } else {
        $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
    }
    $dataset = New-Object -TypeName System.Data.DataSet

    Write-Verbose "Executing Query"
    $adapter.Fill($dataset)

    Write-Verbose "Returing System.Data.DataSet"
    $dataset.Tables[0]
}

function Invoke-DatabaseQuery {
    [CmdletBinding()]
    param (
        [string]$connectionString,
        [string]$query,
        [switch]$isSQLServer = $true
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    } else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $connection.Open()
    $command.ExecuteNonQuery()
    $connection.close()
}

function Get-DatabaseConnectionString{
    [CmdletBinding()]
     param (
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)]
        [string]$ServerName='localhost',

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=1)]
        [string]$DatabaseName='TempDB'
    )

    [string]$ConnectionString = "Server=$ServerName;Database=$DatabaseName;Trusted_Connection=True;"
    Write-Verbose  $ConnectionString
    Write-Output  $ConnectionString
}