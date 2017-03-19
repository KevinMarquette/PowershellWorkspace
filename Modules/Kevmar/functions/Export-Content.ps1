function Export-Content
{
    <#
        .Description
            Saves content to a file

        .Example
            Export-Content -Path testfile.txt -value 'testing' -Append

        .Example
            $Data | Export-Content -Path $Path -Append

        .Notes
            This is optimizes bulk writting of data
    #>
    [cmdletbinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Value,

        [Parameter(
            Mandatory=$true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [switch]
        $Append
    )

    begin
    {
        $parentFolder = Split-Path $Path

        if( # a full path to the save location is required
            [string]::IsNullOrWhiteSpace( $parentFolder ) -or 
            -Not ( Test-Path -Path $parentFolder -PathType Container )
        )
        {
            Write-Verbose "Saving file to local folder."
            $Path = Join-Path -Path ( Get-Location ) -ChildPath $Path
        }
        if( -Not ( Test-Path -Path $Path ) )
        {
            if( $Pscmdlet.ShouldProcess( $Path,'Create new file' ) )
            {
                $shouldProcess = $true
            }
        }
        else
        {
            if( $Pscmdlet.ShouldProcess( $Path,'Write to file' ) )
            {
                $shouldProcess = $true
            } 
        }

        if($shouldProcess)
        {
            $streamWriter = [System.IO.StreamWriter]::new( $Path, [bool]$Append )
        }
    }

    process
    {
        if($ShouldProcess)
        {
            try 
            {
                foreach($line in $Value)
                {
                    $streamWriter.WriteLine( $line )
                }            
            }
            catch
            {
                $streamWriter.Close()
                throw
            }
        }
    }
    end
    {
        if($ShouldProcess)
        {
            $streamWriter.Close()
        }
    }
}
