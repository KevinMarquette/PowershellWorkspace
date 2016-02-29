function Reset-AllUserProfiles
{
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
    param(
        [Parameter()]
        [switch]$Force
    )
    
    process
    {
        if ($pscmdlet.ShouldProcess('All User Profiles', 'Delete'))
        {

            $exceptions = "Administrator|admin|public|all users|default|$([Environment]::UserName)"
            Write-Verbose "These profiles will be skipped: $Exceptions"

	        $profiles = Get-WmiObject win32_UserProfile | ?{$_.LocalPath -imatch "c:\\users|c:\\documents"}

            #filter out the important profiles to save
            $profiles = $profiles | ?{$_.LocalPath -inotmatch  $exceptions}

            Write-Verbose "Deleting profiles..."
            foreach($profile in $profileList) 
            {
                if($Force -or $pscmdlet.ShouldContinue("Delete this profile: $($profile.LocalPath)","Deleteing Profile"))
                {
                    Write-Verbose "Deleting $($profile.LocalPath)"
                    $profile.Delete()
                }
            }
            
            Write-Verbose "Deleting any profile folders that still exist"
            $folderList = ls C:\Users |  Where-Object{$_.Name -inotmatch  $exceptions } 
            
            foreach($folder in $folderList)
            {
                if($Force -or $pscmdlet.ShouldContinue("Delete this profile folder: $($folder.FullName)","Deleteing Profile"))
                {
                    Write-Verbose "Deleting $($folder.FullName)"
                    Remove-Item -Force -Recurse $folder.FullName
                }
            }
        }
    }
}