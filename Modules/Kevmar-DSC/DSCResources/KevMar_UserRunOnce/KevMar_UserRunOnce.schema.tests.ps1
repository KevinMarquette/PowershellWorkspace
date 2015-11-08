Describe "KevMar_UserRunOnce"{
    It "Creates a mof file"{
        configuration DSCTest{
            Import-DscResource -modulename KevMar   
            Node Localhost{
               KevMar_UserRunOnce SampleConfig{
                    ID = ""
                    Command = ""
                    Version = ""                    
               }    
            }
        }
        DSCTest -OutputPath Testdrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist
    }
}



