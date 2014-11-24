# 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced) *
# 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)
# a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)

Function Test-TargetResource
{
    [OutputType([boolean])]
    param(
        [parameter(Mandatory = $true)]
        [string] $PowerPlan
    )

    $target     = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' 
    $currScheme = POWERCFG -GETACTIVESCHEME
    $tokens     = $currScheme.Split() 

    Write-Output ($tokens[3] -eq $target)
}

 Function Get-TargetResource
 {
    [OutputType([Hashtable])]
    param(
        [parameter(Mandatory = $true)]
        [string] $PowerPlan
    )

    $target     = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' 
    $currScheme = POWERCFG -GETACTIVESCHEME
    $tokens     = $currScheme.Split()
    $result     = ($tokens[3] -eq $target)

    Write-Output @{
        ActiveGUID   = $tokens[3]
        RequiredGUID = $target
        Configured   = $result
    }
}

 Function Set-TargetResource
 {
    param(
        [parameter(Mandatory = $true)]
        [string] $PowerPlan
    )

    $target = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'

    PowerCfg.exe /SetActive $target
    
}



