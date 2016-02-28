

function Start-WsusUpdateCheck
{
    [cmdletbining()]
    param()
    wuauclt /Detectnow /ResetAuthorization /ReportNow
}

  # Clear-UnwantedUpdates ##################################
function Clear-WsusUnwantedUpdates
{
    [cmdletbinding()]
    param()
    
    process
    {
        $update = New-Object -com Microsoft.update.Session
        $searcher = $update.CreateUpdateSearcher()

        Write-Verbose "Gathering list of updates..."
        $pending = $searcher.Search("IsInstalled=0 And IsHidden=0")

        Write-Verbose "Marking Unwanted Updates Hidden ..."
        $pending.Updates | ?{$_.title -match "Language|Live Essentials|Windows Search|Bing"} | %{$_.isHidden = $true}
        $pending.Updates | ?{$_.isHidden -eq $true} | %{Write-Verbose ("Hide: {0} {1}" -f $_.Tittle, $_.Description)}
    }
}

# Windows Updates ##################################
function Install-WsusUpdates
{
    [cmdletbinding()]
    param()
    
    process
    {
        if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
        {
             Write-Verbose "Reboot pending from previous install"
        }
        else
        {
            Clear-WsusUnwantedUpdates
        
            $updateSession = new-object -com Microsoft.update.Session
            $searcher = $updateSession.CreateUpdateSearcher()
            
            Write-Verbose "Gathering list of updates..."
            $updates = $searcher.Search("IsInstalled=0 And IsHidden=0 And Type='Software'").Updates
       
            $downloader = $updateSession.CreateUpdateDownloader()
            $downloader.Updates = $updates
        
            if($downloader.Updates.Count -eq "0")
            {
                Write-Verbose "No updates available"
            }
            else
            {
                $updates | %{Write-Verbose ("Available: {0} {1}" -f $_.Tittle, $_.Description)}

                Write-Verbose "Accepting Eula on all updates"
                $updates | %{$_.AcceptEula()}

                Write-Verbose "Downloading $($updates.count) Updates..."
                $result = $downloader.Download()
                $installer = $updateSession.CreateUpdateInstaller()
                $installer.Updates = $downloader.Updates 
                
                if($installer.Updates.Count -eq "0")
                {
                    Write-Verbose "No updates downloaded"
                }
                else
                {
                    Write-Verbose "Installing Updates..."
                
                    $installer.Install()
                    Write-Verbose "Installing Updates Finished"
                
                    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
                    {
                       Write-Verbose "Reboot required to finish updates"
                    }
                }        
            }
         }      
     }
}

function Get-ADComputerDetails
{
    [cmdletbinding()]
    param(
        [Alias("Name")]
        [Parameter(
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string]
        $ComputerName="$env:computername"
    )
    
    process
    {
        $computers = Get-ADComputer $ComputerName -Properties Description,Modified,IPv4Address 
        
        foreach($node in $computers)
        {
            $ADObject = [pscustomobject][ordered]@{
                ComputerName = $node.Name
                Description  = Description
                Modified     = Modified
                IPv4Address  = IPv4Address
            }
            
            Write-Output $ADObject
        }
    }
}

function Get-LogonUser
{
    [cmdletbinding()]
    param(
        [Parameter(
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string[]]
        $ComputerName="$Env:Computername"
    )
    
    process
    {
        foreach($node in $ComputerName)
        {
            Write-Verbose "Verifying $node is online"
            
            if(Test-Connection -ComputerName $node -Count 1 -ErrorAction SilentlyContinue)
            {
                Write-Verbose "Getting processes from $Computer"            
                $processList = Get-WMIObject Win32_Process  -Filter 'Name="explorer.exe"' -ComputerName $node
                
                foreach ($process in $processList) 
                {
                    $owner = $process.GetOwner()
                    
                    $userSession = [pscustomobject][ordered]@{
                        UserName =  $owner.Domain + "\" + $owner.User
                        CreationDate = $process.ConvertToDateTime($process.CreationDate)
                        ComputerName = $node 
                    } 
                    
                    Write-Output $userSession
                }
            }
            else
            {
                Write-Verbose "$Computer offline"
            }
        }
    }
}

function Clear-TempFiles
{
    [cmdletbing()]
    param()
    
    ls $env:temp | Remove-Item -Recurse -Force
    if(Test-Path c:\windows\temp)
    {
        ls c:\windows\temp | Remove-Item -Recurse -Force
    }
}

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
