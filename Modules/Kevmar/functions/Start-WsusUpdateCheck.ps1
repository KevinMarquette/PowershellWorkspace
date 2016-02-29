function Start-WsusUpdateCheck
{
    <#
    .SYNOPSIS
    Tells the windows update service to check in with the wsus server
    .EXAMPLE
    Start-WsusUpdateCheck
    #>
    
    [cmdletbinding()]
    param()
    
    wuauclt /Detectnow /ResetAuthorization /ReportNow
}
