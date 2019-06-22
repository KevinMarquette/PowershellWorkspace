function Get-TypeDescriptions
{
    [cmdletbinding()]
    param()

    $library = @{}

    $available = [AppDomain]::CurrentDomain.
    GetAssemblies().
    GetTypes().
    Where{
        [Exception].IsAssignableFrom($_) -and $_.IsPublic
    }

    foreach($exception in $available)
    {
        $library[$exception.fullname] = ''
    }

    $xmlFiles = LS 'C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.6.1\*.xml'
    foreach($file in $xmlFiles)
    {
        $xml = [xml]::new()
        $xml.Load($file)
        $xml.doc.members.member |
           Where Name -Like 'T:*' | 
           ForEach-Object{$library[($_.name.replace('T:',''))] = $_.summary}
    }

    $library
}