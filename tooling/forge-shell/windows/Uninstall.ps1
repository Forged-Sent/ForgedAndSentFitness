#requires -Version 7.5
[CmdletBinding(SupportsShouldProcess)]
param([string]$ProfilePath=$PROFILE.CurrentUserAllHosts,[switch]$ProfileOnly,[string]$StateRoot=$PSScriptRoot)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'scripts\Transactions.ps1')
if([IO.File]::Exists($ProfilePath)){
    $old=[IO.File]::ReadAllText($ProfilePath)
    $pattern='(?ms)^# >>> Forge Shell managed bootstrap >>>\r?\n.*?^# <<< Forge Shell managed bootstrap <<<\r?\n?'
    $new=[regex]::Replace($old,$pattern,'')
    if($old -ne $new -and $PSCmdlet.ShouldProcess($ProfilePath,'Back up and remove only the Forge loader')){
        $tx=New-ForgeTransaction $StateRoot @($ProfilePath) 'uninstall'
        try{Write-ForgeTransactionFile $tx $ProfilePath $new;$tx.Status='installed';Save-ForgeTransaction $tx}catch{Undo-ForgeTransaction $tx;throw}
    }
}
if(-not $ProfileOnly){
    $pointer=Join-Path $StateRoot 'data\terminal-backup.txt'
    $chainPath=Join-Path $StateRoot 'data\terminal-backups.json'
    $chain=@(if([IO.File]::Exists($chainPath)){Get-Content -LiteralPath $chainPath -Raw | ConvertFrom-Json}elseif([IO.File]::Exists($pointer)){[IO.File]::ReadAllText($pointer).Trim()})
    [array]::Reverse($chain)
    foreach($backup in $chain){
        if($WhatIfPreference){$null=$PSCmdlet.ShouldProcess($backup,'Restore terminal transaction in reverse installation order; refuse later edits')}
        else{& (Join-Path $PSScriptRoot 'Restore.ps1') -Backup $backup -Confirm:$false}
    }
}
Write-Host 'Uninstall processed. Start a fresh shell. Notes, bookmarks, source files and backups are retained.'
