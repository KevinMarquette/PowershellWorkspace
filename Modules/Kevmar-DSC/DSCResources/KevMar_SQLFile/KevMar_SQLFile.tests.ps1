Describe "KevMar_SQLFile"{
    It "Creates a mof file"{
        configuration DSCTest{
            Import-DscResource -modulename KevMar   
            Node Localhost{
               SQLFile SampleConfig{
                    SetScriptPath = "Required"
                    GetScriptPath = "Required"
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



