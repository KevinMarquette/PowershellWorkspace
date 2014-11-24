Describe "KevMar_AutoLogon"{

    context "Present, Domain defined, skip check for user account" {

        configuration DSCTest
        {
            Import-DscResource -modulename KevMar   
            Node Localhost
            {
                KevMar_AutoLogon SampleConfig{
                    UserName = "USER_NAME"
                    Password = "Password"
                    Domain = "Domain"
                    Ensure = "Present"
                }    
            }
        }

        DSCTest -OutputPath Testdrive:\dsc

        It "Created a mof file"{
            
            "TestDrive:\dsc\localhost.mof" | Should Exist
        }

        It "Contains paramater values"{

            "TestDrive:\dsc\localhost.mof" | Should contain USER_NAME
        }

        It "Contains Domain resource section"{

            "TestDrive:\dsc\localhost.mof" | Should contain AutoLogon_DefaultDomainName
        }

        It "Does not contains user account resource section"{

            "TestDrive:\dsc\localhost.mof" | Should not contain AutoLogon_UserAccount
        }
    }

    context "Absent, Domain not defined, Check for user account" {

        $ConfigData = @{
            AllNodes = @(
                @{
                    NodeName = "*";
                    PSDscAllowPlainTextPassword = $true;
                }
                @{ 
                    NodeName = "localhost2";
                }
            )    
        }

        configuration DSCTest2
        {
            Import-DscResource -modulename KevMar   
            
            Node $AllNodes.NodeName
            {
                KevMar_AutoLogon SampleConfig
                {
                    UserName = "UserName"
                    Password = "Password"
                    Ensure = "Absent"
                }    
            }
        }

        DSCTest2 -OutputPath Testdrive:\dsc -ConfigurationData $ConfigData

        It "Creates a mof file with Ensure = absent" {
            
            "TestDrive:\dsc\localhost2.mof" | Should Exist
        }

        It "Does not contain Domain resource section"{

            "TestDrive:\dsc\localhost2.mof" | Should not contain AutoLogon_DefaultDomainName
        }

        It "Does contain user account resource section"{

            "TestDrive:\dsc\localhost2.mof" | Should contain AutoLogon_UserAccount
        }
    }
}





