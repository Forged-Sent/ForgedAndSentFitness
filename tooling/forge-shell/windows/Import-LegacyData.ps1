#requires -Version 7.5
[CmdletBinding(SupportsShouldProcess)]
param([string]$Source=(Join-Path $HOME '.adhd-powershell'))
$ErrorActionPreference='Stop'
if(-not [IO.Directory]::Exists($Source)){throw 'Legacy data directory not found. Nothing imported.'}
$destination=Join-Path $PSScriptRoot 'data'
$pairs=@(@{From='bookmarks.json';To='bookmarks.json'},@{From='todos.json';To='todos.json'})
foreach($pair in $pairs){
    $src=Join-Path $Source $pair.From;$dst=Join-Path $destination $pair.To
    if(-not [IO.File]::Exists($src)){continue}
    if([IO.File]::Exists($dst)){Write-Warning "$($pair.To) already exists; skipped to preserve current data.";continue}
    $null=Get-Content -LiteralPath $src -Raw | ConvertFrom-Json -ErrorAction Stop
    if($PSCmdlet.ShouldProcess($dst,"Copy legacy $($pair.From); retain source")){$null=[IO.Directory]::CreateDirectory($destination);[IO.File]::Copy($src,$dst)}
}
$legacyNotes=Join-Path $Source 'engineering-notes.md'
if([IO.File]::Exists($legacyNotes)){
    $dst=Join-Path $destination 'legacy-engineering-notes.md'
    if(-not [IO.File]::Exists($dst) -and $PSCmdlet.ShouldProcess($dst,'Preserve original engineering Markdown notes')){$null=[IO.Directory]::CreateDirectory($destination);[IO.File]::Copy($legacyNotes,$dst)}
}
Write-Host 'Legacy import complete. Quick Access folders and backups remain at their original location; qa now uses managed bookmarks.'
