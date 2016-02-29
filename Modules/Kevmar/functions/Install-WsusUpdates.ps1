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