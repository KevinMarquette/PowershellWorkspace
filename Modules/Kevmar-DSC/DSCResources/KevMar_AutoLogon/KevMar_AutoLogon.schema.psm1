Configuration KevMar_AutoLogon
{
    Param([string]$UserName,

          [string]$Domain,

          [string]$Password,

          [ValidateSet("Present","Absent")]
          [string]$Ensure = "Present",

          [boolean]$CreateUser = $false
    )

    Registry AutoLogon_AutoAdminLogon
    {
        Key = "HKey_Local_Machine\Software\Microsoft\Windows NT\CurrentVersion\winlogon"
        ValueName = "AutoAdminLogon"
        ValueData = "1"
        Ensure    = $Ensure
    }

    Registry AutoLogon_DefaultUserName
    {
        Key = "HKey_Local_Machine\Software\Microsoft\Windows NT\CurrentVersion\winlogon"
        ValueName = "DefaultUserName"
        ValueData = "$UserName"
        Ensure    = $Ensure
        DependsOn = "[Registry]AutoLogon_AutoAdminLogon"
    }
    
    Registry AutoLogon_DefaultPassword
    {
        Key = "HKey_Local_Machine\Software\Microsoft\Windows NT\CurrentVersion\winlogon"
        ValueName = "DefaultPassword"
        ValueData = "$Password"
        Ensure    = $Ensure
        DependsOn = "[Registry]AutoLogon_AutoAdminLogon"
    }
    
    if($Domain)
    {
        Registry AutoLogon_DefaultDomainName 
        {
            Key = "HKey_Local_Machine\Software\Microsoft\Windows NT\CurrentVersion\winlogon"
            ValueName = "DefaultDomainName"
            ValueData = "$Domain"
            Ensure    = $Ensure
            DependsOn = "[Registry]AutoLogon_AutoAdminLogon"
        }
    }
    else
    {
        $secstr   = New-Object -TypeName System.Security.SecureString
        $Password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
        $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $secstr

        User AutoLogon_UserAccount
        {
            UserName = $UserName
            Disabled = $false
            Ensure = "Present"
            Password = $credential # TODO: fix this
            PasswordNeverExpires  = $true
            PasswordChangeRequired = $false
        }

        Script AutoLogon_LocalComputerName
        {
            GetScript={
                Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\winlogon' -Name DefaultDomainName
            }
            SetScript={
                Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\winlogon' -Name DefaultDomainName -Value "$ENV:Computername"
            }
            TestScript={
                ((Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\winlogon').DefaultDomainName -eq "$ENV:Computername")
            }
        }

    }
}

