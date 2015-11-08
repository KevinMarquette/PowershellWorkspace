
Function Test-TargetResource 
{
    [OutputType([boolean])]
    Param(
        [parameter(Mandatory)]
        [ValidateSet("Enabled","Disabled")]
		[String]$State
    )

    $TestResult = $false

    if(Get-Command Get-ScheduledTask*)
    {
        $task = Get-ScheduledTask | ?{$_.taskname -eq "servermanager"}

        if($task)
        {
            $CurrentState = $task.State

            if($CurrentState -eq "Ready" -and $State -eq "Enabled")
            {
                Write-Output $true
            } 
            elseif ($CurrentState -ne "Ready" -and $State -eq "Disabled")
            {
                Write-Output $true
            }
            else
            {
                Write-Output $false
            }
        }
        else
        {
            Write-Output $true
        }
    } 
    else 
    {
        Write-Output $true
    }
}

Function Get-TargetResource
{
    [OutputType([Hashtable])]
    Param(
        [parameter(Mandatory)]
        [ValidateSet("Enabled","Disabled")]
        [String]$State
    )

    $task = Get-ScheduledTask | ?{$_.taskname -eq "servermanager"}

    Write-Output = @{
        TaskName    = $Task.TaskName;
        Description = $task.Description;
        State       = $Task.state 
    }
}

Function Set-TargetResource
{
    Param(
        [parameter(Mandatory)]
        [ValidateSet("Enabled","Disabled")]
		[String]$State
    )

    if(Get-Command Get-ScheduledTask*)
    {
        Switch($State)
        {
            "Disabled" 
            {
                Get-ScheduledTask | 
                    Where-Object{$_.taskname -eq "servermanager"} | 
                    Disable-ScheduledTask
            }
            "Enabled" 
            {
                Get-ScheduledTask | 
                    Where-Object{$_.taskname -eq "servermanager"} | 
                    Enable-ScheduledTask
            }
        }
    }
}


Export-ModuleMember -Function *-TargetResource

