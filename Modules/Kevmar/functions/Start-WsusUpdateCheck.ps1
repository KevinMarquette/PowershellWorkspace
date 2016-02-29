function Start-WsusUpdateCheck
{
    [cmdletbining()]
    param()
    wuauclt /Detectnow /ResetAuthorization /ReportNow
}
