function Remove-TempFiles
{
    <#
    .SYNOPSIS
    Delete temp files
    .EXAMPLE
    Remove-TempFiles    
    #>
    
    [cmdletbinding()]
    param()
    
    ls $env:temp | Remove-Item -Recurse -Force
    if(Test-Path c:\windows\temp)
    {
        ls c:\windows\temp | Remove-Item -Recurse -Force
    }
}
