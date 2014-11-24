Describe "KevMar_SQLQuery"{
    It "Creates a mof file"{
        configuration DSCTest{
            Import-DscResource -modulename KevMar   
            Node Localhost{
               SQLQuery SampleConfig{
                    SetScript     = "Required"
                    GetScript     = "Required"
                    KeyField      = "Required"
                    RequiredValue = "Required"
                    Database      = ""                    
               }    
            }
        }
        DSCTest -OutputPath Testdrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist
    }
}



