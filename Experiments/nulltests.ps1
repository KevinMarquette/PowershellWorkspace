function Get-Something
{
    [cmdletbinding()]
    param($ID)
    if ($ID -eq 2)
    {
        return
    }
    if ($ID -eq 1)
    {
        throw "Invalid object"
    }
    return $ID
}

function Update-Something
{
    param($result)
    Write-Host "Updating [$result]"
}

function Do-Something
{
    $result = $null
    foreach ( $node in 1..6 )
    {
        try
        {
            $result = Get-Something -ID $node
        }
        catch
        {
            Write-Verbose "[$result] not valid"
        }

        if ( $null -ne $result )
        {
            Update-Something $result
        }
    }
}

function Invoke-Something 
{
    $result = 'ParentScope'
    Do-Something
}

Invoke-Something

if ( $undefined -ea $null ) {$true}