function Import-Content
{
    <#
        .Description
            Reads the content of files using System.IO.File

        .Example
            Import-Content -Path $Path

        .Example
            Get-ChildItem -Filter *.txt | Import-Content -Raw
    #>
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        [switch]
        $Raw
    )
    process
    {
        foreach( $file in ( Resolve-Path -Path $Path ) )
        {            
            if(Test-Path -Path $file -PathType Leaf)
            {
                if($Raw)
                {
                    [System.IO.File]::ReadAllText( $file )
                }
                else
                {
                    [System.IO.File]::ReadAllLines( $file )
                }
            }
        }
    }
}
