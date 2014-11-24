$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Modules = LS $here -Directory 

Describe "All Modules" {

    foreach($CurrentModule in $Modules)
    {
        if(Test-Path "$($CurrentModule.fullname)\functions")
        {
            $Functions = ls "$($CurrentModule.fullname)\functions\*.ps1" | ? name -NotMatch "Tests.ps1"
            foreach($CurrentFunction in $Functions)
            {
                Context "$CurrentModule $($CurrentFunction.BaseName)" {
                        
                    #it "Has a Pester test" {
                    #    $CurrentFunction.FullName.Replace(".ps1",".Tests.ps1") | should exist
                    #}

                    It "dot-sourcing should not throw an error" {
                        $path = $CurrentFunction.FullName
                        { Invoke-expression (Get-Content $path -raw) } | should not throw
                    }
                }
            }
        }
    }
}