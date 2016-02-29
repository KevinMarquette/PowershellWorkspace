function Reset-UserProfile
{
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string]$UserName,

        [Parameter()]
        [switch]$Force
    )
    
    process
    {
        if ($pscmdlet.ShouldProcess("User Profiles", "Delete"))
        {
            $profileList = Get-WmiObject win32_UserProfile | ?{$_.LocalPath -imatch "c:\\users|c:\\documents"}

            #filter out the important profiles to save
            $profileList = $profileList | ?{$_.LocalPath -imatch "$UserName"}

            Write-Verbose "Deleting profiles..."
            foreach($profile in $profileList) 
            {
                if($Force -or $pscmdlet.ShouldContinue("Delete this profile: $($profile.LocalPath)","Deleteing Profile"))
                {
                    Write-Verbose "Deleting $($profile.LocalPath)"
                    $profile.Delete()
                }
            }
        }
    }
}
