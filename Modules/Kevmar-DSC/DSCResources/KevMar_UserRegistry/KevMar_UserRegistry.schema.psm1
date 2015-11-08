<#
    Some system setting only apply to the user profile.
    This makes an entry into the Active Setup Manager
    It makes sure that every user runs this command once
    Works for existing users and new users

    More info
    http://sccmpackager.blogspot.com/2013/07/active-setup-what-is-active-setup.html

    Must change the version every time the command is changed or it won't get ran
    Active Setup Manager uses the version to keep track of who needs to run the command
#>

Configuration KevMar_UserRegistry{
    param(
    $ID,
    $Ensure = "Present",
    $Version  = "1.3",
    $ValueName,
    $ValueData,
    $Key
    )

    $ActiveSetupKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\$ID"
    $ActiveSetupVersion = ($Version.replace('.',','))

    # Translate key path for use with Set-ItemProperty
    $HKLUKey = $Key.Replace("HKEY_CURRENT_USER\","HKCU:\")

    $Command = ('C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell -NoProfile -Command "Set-ItemProperty ''{0}'' -Name {1} -Value ''{2}''"' -f $HKLUKey,$ValueName,$ValueData)
    Write-verbose "ActiveSetup Command: $Command"

    Registry "KevMar_UserRegistry_$($ID)_StubPath"
    {
        Ensure = $Ensure
        Key = $ActiveSetupKey
        ValueName = "StubPath"
        ValueData = $Command
    }

    Registry "KevMar_UserRegistry_$($ID)_Version"
    {
        Ensure = $Ensure
        Key = $ActiveSetupKey
        ValueName = "Version"
        ValueData = $ActiveSetupVersion
        DependsOn = "[Registry]KevMar_UserRegistry_$($ID)_StubPath"
    }
}

