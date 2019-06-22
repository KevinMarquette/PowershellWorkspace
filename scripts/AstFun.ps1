using namespace System.Management.Automation.Language
$script = {
    $first = 1
    $second = $third
    $object.property = 4
    foreach($item in $collection)
    {
        1
    }
}

#Show-AstGraph -ScriptBlock $script -Annotate

$assignment = $script | Select-AST -Type AssignmentStatementAst
$variables = $script | Select-AST -Type VariableExpressionAst

$assignmentMap = @{}
foreach($node in $assignment)
{
    $expression = $node.Left
    $name = $expression.VariablePath.UserPath
    $extent = $expression.extent
    if($name)
    {
        "[$name]"
        if($assignmentMap.Contains($name))
        {
            if($assignmentMap[$name].StartOffset -gt $extent.StartOffset)
            {
                $assignmentMap[$name] = @{
                    StartLineNumber = $extent.StartLineNumber
                    StartOffset = $extent.StartOffset
                }
            }
        }
        else
        {
            $assignmentMap[$name] = @{
                StartLineNumber = $extent.StartLineNumber
                StartOffset = $extent.StartOffset
            }
        }
    }
}

$variableMap = [ordered]@{}
foreach($node in $variables)
{
    if($node.Parent -is [ForEachStatementAst])
    {
        continue
    }
    $name = $node.VariablePath.UserPath
    if ($assignmentMap[$name].StartLineNumber -gt $node.Extent.StartLineNumber)
    {
        continue
    }
    if ($assignmentMap[$name].StartOffset -eq $node.Extent.StartOffset)
    {
        continue
    }
    Write-Verbose "Adding [$name]" -verbose
    $variableMap[$name]=$node.Extent.StartOffset
}

$script.tostring()

$refactorText = [System.Collections.Generic.List[string]]::new()
$textInfo = (Get-Culture).TextInfo

$parameters = $variableMap.keys | ForEach-Object {
'        [Parameter()]
        ${0}' -f $textInfo.ToTitleCase($_)
}

$refactorText += @(
    'function Do-Something'
    '{'
    '    [CmdletBinding()]'
    '    param ('
    ($parameters -join ("," + [System.Environment]::NewLine + [System.Environment]::NewLine))
    '    )'
)

$body = $script.ToString() -split [System.Environment]::NewLine
$indentFinder = '^(?<indent>\s+)'
if($body[1] -match $indentFinder)
{
    $removeIndent = '^{0}' -f $matches.indent
    $body = $body | ForEach-Object {$_ -replace $removeIndent,'    '}
}

$refactorText += $body
$refactorText += '}'
$functionCall = @('Do-Something')

$functionCall += $variableMap.keys | ForEach-Object {
    '-{0} ${1}' -f $textInfo.ToTitleCase($_), $_
}
$refactorText += $functionCall -join ' '

$refactorText