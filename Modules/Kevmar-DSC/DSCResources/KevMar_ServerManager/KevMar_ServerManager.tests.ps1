Describe "KevMar_ServerManager"{
    It "Creates a mof file"{
        configuration DSCTest{
            Import-DscResource -modulename KevMar   
            Node Localhost{
               KevMar_ServerManager SampleConfig{
                    State = "Disabled"
               }    
            }
        }
        DSCTest -OutputPath Testdrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist
    }
}



