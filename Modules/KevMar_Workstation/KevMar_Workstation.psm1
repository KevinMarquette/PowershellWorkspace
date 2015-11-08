

function Start-WsusUpdateCheck{
    wuauclt /Detectnow /ResetAuthorization /ReportNow
}

  # Clear-UnwantedUpdates ##################################
function Clear-WsusUnwantedUpdates{
    [CmdletBinding()]
    Param()
    Process
    {
        $update = new-object -com Microsoft.update.Session
        $searcher = $update.CreateUpdateSearcher()

        Write-Verbose "Gathering list of updates..."
        $pending = $searcher.Search("IsInstalled=0 And IsHidden=0")

        Write-Verbose "Marking Unwanted Updates Hidden ..."
        $pending.Updates | ?{$_.title -match "Language|Live Essentials|Windows Search|Bing"} | %{$_.isHidden = $true}
        $pending.Updates | ?{$_.isHidden -eq $true} | %{Write-Verbose ("Hide: {0} {1}" -f $_.Tittle, $_.Description)}
    }
}

# Windows Updates ##################################
function Install-WsusUpdates{
    [CmdletBinding()]
    Param()
    Process
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
        
            if($downloader.Updates.Count -eq "0"){
                Write-Verbose "No updates available"
            }else{
                $updates | %{Write-Verbose ("Available: {0} {1}" -f $_.Tittle, $_.Description)}

                Write-Verbose "Accepting Eula on all updates"
                $updates | %{$_.AcceptEula()}

                Write-Verbose "Downloading $($updates.count) Updates..."
                $result = $downloader.Download()
                $installer = $updateSession.CreateUpdateInstaller()
                $installer.Updates = $downloader.Updates 
                if($installer.Updates.Count -eq "0"){
                    Write-Verbose "No updates downloaded"
                }else{
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

function Get-ADComputerDetails{
    [CmdletBinding()]
    Param(
        [Alias("Name")]
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        $ComputerName="$env:computername")
    Process{
        Get-ADComputer $ComputerName -Properties Description,Modified,IPv4Address |
            Select-Object @{Name="ComputerName";Expression={$_.Name}}, Description, Modified, IPv4Address
    }
}

function Get-LogonUser{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        $computername="$Env:Computername"
    )
    Process
    {
        if(Test-Connection -ComputerName $computername -Count 1 -ErrorAction SilentlyContinue){
            Write-Verbose "Checking $Computer ..."
            gwmi Win32_Process  -Filter 'Name="explorer.exe"' -computername $computername |
              Foreach-Object {
                $o = $_.GetOwner()
                $o=$o.Domain + "\" + $o.User
                $obj = $_ |  Select-Object Name, CreationDate, Owner
                $obj.Owner = $o
                $obj.CreationDate = $_.ConvertToDateTime($_.CreationDate)
                $obj
            } |
            Group-Object -Property Owner |
            Select-Object  @{Name="UserName";Expression={$_.Name}},@{Name="ComputerName";Expression={$computername}}
        } else {
            Write-Verbose "$Computer offline"
        }
    }
}

function Clear-TempFiles(){
    ls $env:temp | Remove-Item -Recurse -Force
    if(Test-Path c:\windows\temp){
        ls c:\windows\temp | Remove-Item -Recurse -Force
    }
}

function Reset-UserProfile{
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        $UserName,

        [Parameter()]
        [switch]$Force
        )
    Process
    {
        if ($pscmdlet.ShouldProcess("User Profiles", "Delete")){
            $profiles = Get-WmiObject win32_UserProfile | ?{$_.LocalPath -imatch "c:\\users|c:\\documents"}

            #filter out the important profiles to save
            $profiles = $profiles | ?{$_.LocalPath -imatch "$UserName"}

             Write-Verbose "Deleting profiles..."
            $profiles | ForEach-Object{
                if($Force -or $pscmdlet.ShouldContinue("Delete this profile: $($_.LocalPath)","Deleteing Profile")){

                    Write-Verbose "Deleting $($_.LocalPath)"
                    $_.Delete()
                }
            }
        }
    }
}

function Reset-AllUserProfiles(){
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    Param(
        [Parameter()]
        [switch]$Force
        )
    Process
    {
        if ($pscmdlet.ShouldProcess("All User Profiles", "Delete")){

            $exceptions = "Administrator|admin|public|all users|default|$([Environment]::UserName)"
            Write-Verbose "These profiles will be skipped: $Exceptions"

	        $profiles = Get-WmiObject win32_UserProfile | ?{$_.LocalPath -imatch "c:\\users|c:\\documents"}

            #filter out the important profiles to save
            $profiles = $profiles | ?{$_.LocalPath -inotmatch  $exceptions}

            Write-Verbose "Deleting all user profiles..."
            $profiles | ForEach-Object{
                    if($Force -or $pscmdlet.ShouldContinue("Delete this profile: $($_.LocalPath)","Deleteing Profile")){

                        Write-Host "Deleting $($_.LocalPath)"
                        $_.Delete()
                    }
                }

            Write-Verbose "Deleting any profile folders that still exist"
            ls C:\Users |
                Where-Object{$_.Name -inotmatch  $exceptions } |
                ForEach-Object{
                    if($Force -or $pscmdlet.ShouldContinue("Delete this profile folder: $($_.FullName)","Deleteing Profile")){

                        Write-Verbose "Deleting $($_.FullName)"
                        Remove-Item -Force -Recurse $_.FullName
                    }
                }
        }
    }
}
