function Start-WsusUpdateCheck
{
    [cmdletbinding()]
    param()
    wuauclt /Detectnow /ResetAuthorization /ReportNow
}
