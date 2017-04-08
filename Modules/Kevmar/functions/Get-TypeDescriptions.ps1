function Get-TypeDescriptions
{
    [cmdletbinding()]
    param()

    $library = @{}
    $xmlFiles = LS 'C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETPortable\v4.6\*.xml'
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