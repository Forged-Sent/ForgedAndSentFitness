# Interactive smoke harness. Uses disposable history; never reads existing PSReadLine history.
$root=Split-Path -Parent $PSScriptRoot
$env:FORGE_HOME=Join-Path $env:TEMP ('ForgeShell-interactive-'+[guid]::NewGuid().ToString('N'))
$null=[IO.Directory]::CreateDirectory((Join-Path $env:FORGE_HOME 'config'))
$settings=Get-Content -LiteralPath (Join-Path $root 'config\settings.json') -Raw | ConvertFrom-Json -AsHashtable
$settings.EnableDirectoryHistory=$false;$settings.EnableFzf=$false
$settings | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $env:FORGE_HOME 'config\settings.json')
Import-Module PSReadLine
Set-PSReadLineOption -HistorySavePath (Join-Path $env:FORGE_HOME 'isolated-history.txt') -HistorySaveStyle SaveNothing -PredictionSource None
. (Join-Path $root 'Microsoft.PowerShell_profile.ps1')
Set-PSReadLineOption -PredictionSource None
Write-Host 'Isolated interactive verification: native picker, keys and prompt.'
