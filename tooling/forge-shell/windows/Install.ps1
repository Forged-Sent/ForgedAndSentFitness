#requires -Version 7.5
[CmdletBinding(SupportsShouldProcess)]
param([string]$ProfilePath=$PROFILE.CurrentUserAllHosts,[string]$StateRoot=$PSScriptRoot)
$ErrorActionPreference='Stop'
if(-not [Environment]::Is64BitProcess){throw 'Use 64-bit PowerShell 7.5+.'}
. (Join-Path $PSScriptRoot 'scripts\Transactions.ps1')
if($WhatIfPreference){& (Join-Path $PSScriptRoot 'scripts\Build-Module.ps1') -Check}else{& (Join-Path $PSScriptRoot 'scripts\Build-Module.ps1')}
foreach($file in Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File | Where-Object {$_.Extension -in @('.ps1','.psm1','.psd1') -and $_.FullName -notmatch '\\(backups|data)\\'}){
    $tokens=$null;$parseErrors=$null;$null=[Management.Automation.Language.Parser]::ParseFile($file.FullName,[ref]$tokens,[ref]$parseErrors)
    if($parseErrors.Count){throw "Syntax error in $($file.FullName). Installation stopped."}
}
$config=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'config\settings.json') -Raw | ConvertFrom-Json -ErrorAction Stop
if($config.SchemaVersion -ne 1){throw 'Unsupported config version.'}
$bootstrap=Join-Path $PSScriptRoot 'Microsoft.PowerShell_profile.ps1'
$escaped=$bootstrap.Replace("'","''")
$block=@'
# >>> Forge Shell managed bootstrap >>>
if ($PSVersionTable.PSEdition -eq 'Core' -and $PSVersionTable.PSVersion -ge [version]'7.5' -and $env:FORGE_DISABLE -ne '1') {
    if (Test-Path -LiteralPath '__BOOTSTRAP__') { . '__BOOTSTRAP__' }
}
# <<< Forge Shell managed bootstrap <<<
'@
$block=$block.Replace('__BOOTSTRAP__',$escaped)
$old=if([IO.File]::Exists($ProfilePath)){[IO.File]::ReadAllText($ProfilePath)}else{''}
$pattern='(?ms)^# >>> Forge Shell managed bootstrap >>>\r?\n.*?^# <<< Forge Shell managed bootstrap <<<\r?\n?'
$count=[regex]::Matches($old,$pattern).Count
if($count -gt 1 -or (($old.Contains('# >>> Forge Shell managed bootstrap >>>')) -and $count -eq 0)){throw 'Ambiguous managed block; inspect the profile before installing.'}
$new=if($count -eq 1){[regex]::Replace($old,$pattern,[Text.RegularExpressions.MatchEvaluator]{param($m);$block+"`r`n"})}else{$old.TrimEnd()+"`r`n`r`n"+$block+"`r`n"}
if($new -eq $old){Write-Host 'Forge loader is already current.';return}
if(-not $PSCmdlet.ShouldProcess($ProfilePath,'Back up and append/update the Forge all-hosts loader')){return}
$tx=New-ForgeTransaction $StateRoot @($ProfilePath) 'profile'
try{
    Write-ForgeTransactionFile $tx $ProfilePath $new
    $tx.Status='installed';Save-ForgeTransaction $tx
    Write-Host "Installed Forge Shell 2.0. Backup: $($tx.Directory)"
    Write-Host 'Open a new PowerShell tab, then use helpme or dash.'
}catch{Undo-ForgeTransaction $tx;throw}
