$log = git log --shortstat


$currentRecord = $null
$project = 'workspace'
$records = switch -Regex ( $log )
{
    '^commit (?<commit>\w+)' 
    {
        if ( $null -ne $currentRecord )
        {
            $currentRecord
        }
        $currentRecord = @{
            commit = $matches.commit
            project = $project
        }
    }
    '^Author:\s+(?<author>.*)$'
    {
        $currentRecord['Author'] = $matches.Author
    }
    '^Merge:\s+(?<merge>.*)$'
    {
        $currentRecord['Merge'] = $matches.merge -split ' '
    }
    '^Date:\s+(?<weekday>\w+)\s(?<month>\w+)\s(?<day>\d+)\s(?<time>[\d:]+)\s(?<year>\d+)\s.*$'
    {
        $currentRecord['weekday'] = $matches.weekday
        $currentRecord['month'] = $matches.month
        $currentRecord['day'] = $matches.day
        $currentRecord['time'] = $matches.time
        $currentRecord['year'] = $matches.year
    }
    '^\s*(?<filechanged>\d+) file changed(, (?<insertions>\d+) insertions\(\+\))?(), (?<deletions>\d+) deletions\(\-\))?$'
    {
        $currentRecord['filechanged'] = $matches.filechanged
        $currentRecord['insertions'] = $matches.insertions
        $currentRecord['deletions'] = $matches.deletions
    }
}

$records += $currentRecord
$records | % {[pscustomobject]$_}
