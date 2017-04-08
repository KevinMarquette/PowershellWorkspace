
function Get-DotNetType
{
    param(
        $TypeName = "*exception"
    )
    $thisAssembly = [System.Reflection.Assembly]::GetExecutingAssembly()
	$assemblyList = $thisAssembly.GetReferencedAssemblies()
    foreach($assemblyName in $assemblyList) # $assemblyName = $assemblyList | select -first 1
    {
        $assembly = [System.Reflection.Assembly]::Load($assemblyName)
        $moduleList = $assembly.GetModules()
        foreach($module in $assembly.GetModules()) # $module = $moduleList | select -first 1 -skip 1
        {
            $typeList = $module.GetTypes()
            foreach($type in $typeList)
            {
                if($type.fullname -like $TypeName)
                {
                    $type
                }
            }
        }
    }
}


