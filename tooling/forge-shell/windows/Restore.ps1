#requires -Version 7.5
[CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
param([Parameter(Mandatory)][string]$Backup,[switch]$Force)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'scripts\Transactions.ps1')
$backupPath=(Resolve-Path -LiteralPath $Backup -ErrorAction Stop).ProviderPath
$tx=Get-Content -LiteralPath (Join-Path $backupPath 'manifest.json') -Raw | ConvertFrom-Json -AsHashtable
if($tx.SchemaVersion -ne 1){throw 'Unsupported backup manifest.'}
if($tx.Status -eq 'rolled-back'){Write-Host 'This transaction is already restored; later edits are preserved.';return}
$tx.Directory=$backupPath
foreach($entry in $tx.Entries){
    if(-not $entry.Written){continue}
    $target=[IO.Path]::GetFullPath($entry.Target)
    if(-not $target.StartsWith($env:USERPROFILE+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Recovery targets must be inside your user directory.'}
    $copy=[IO.Path]::GetFullPath($entry.BackupFile,$backupPath)
    if(-not $copy.StartsWith($backupPath+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Backup path escapes its directory.'}
    if($entry.Existed -and (Get-ForgeFileHash $copy) -ne $entry.OriginalHash){throw 'Backup integrity check failed.'}
    if(-not $Force -and (Get-ForgeFileHash $target) -ne $entry.InstalledHash){throw "File changed after installation: $target. Preserve later edits; use Uninstall.ps1 for a targeted profile removal."}
}
if($PSCmdlet.ShouldProcess($backupPath,'Restore exact backed-up files')){
    if($Force){foreach($entry in $tx.Entries){$entry.InstalledHash=Get-ForgeFileHash $entry.Target}}
    Undo-ForgeTransaction $tx
    Write-Host 'Transaction restored. Open a fresh PowerShell tab.'
}
