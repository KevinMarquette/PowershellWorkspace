$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "KevMar_Firewall" {

    It "Creates a mof file" {

        Configuration DSCTest
        {
            Import-DscResource -modulename KevMar   
            
            Node Localhost
            {
               KevMar_Firewall SampleConfig
               {
                    State = "ON"
               }
            }
        }
        DSCTest -OutputPath Testdrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist
    }

    Copy-Item "$here\KevMar_Firewall.psm1" TestDrive:\script.ps1
    Mock Export-ModuleMember {return $true}

    . "TestDrive:\script.ps1"
    It "Test-TargetResource returns true or false" {
        Test-TargetResource -state "ON" | Should Not BeNullOrEmpty
    }

    It "Get-TargetResource returns State = on or off" {
        (Get-TargetResource -state "ON").state | Should Match "on|off"
    }
}



