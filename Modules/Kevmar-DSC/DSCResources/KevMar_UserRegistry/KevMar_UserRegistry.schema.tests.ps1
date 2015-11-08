Describe "KevMar_UserRegistry"{
    It "Creates a mof file"{
        configuration DSCTest{
            Import-DscResource -modulename KevMar   
            Node Localhost{
               KevMar_UserRegistry SampleConfig{
                    ID = ""
                    Key = ""
                    Version = ""
                    ValueName = ""
                    ValueData = ""
               }    
            }
        }
        DSCTest -OutputPath Testdrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist
    }
}



