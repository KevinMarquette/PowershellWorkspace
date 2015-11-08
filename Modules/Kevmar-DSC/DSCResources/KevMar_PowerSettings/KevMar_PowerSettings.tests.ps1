Describe "KevMar_PowerSettings"{
    It "Creates a mof file"{
        configuration DSCTest{
            Import-DscResource -modulename KevMar   
            Node Localhost{
               KevMar_PowerSettings SampleConfig{
                    PowerPlan = "High Performance"                    
               }    
            }
        }
        DSCTest -OutputPath Testdrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist
    }
}



