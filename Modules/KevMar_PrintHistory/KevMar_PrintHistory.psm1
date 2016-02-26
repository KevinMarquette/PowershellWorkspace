




Write-Verbose "Importing Functions"
# Import everything in the functions folder
"$PSScriptRoot\Functions\*.ps1" |
  Resolve-Path |
  Where-Object { -not ($_.ProviderPath.Contains(".Tests.")) } |
  ForEach-Object { . $_.ProviderPath ; Write-Verbose $_.ProviderPath}


Export-Modulemember -function *
