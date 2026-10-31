#requires -Version 5.1
# Shared package installer error classification. Safe to load in Windows PowerShell 5.1.
function Get-FSWinGetOutcome {
  param([long]$ExitCode)
  $hex=('{0:X8}' -f ($ExitCode -band 4294967295L))
  switch($hex){
    '00000000' {return 'Installed'}
    '8A15002B' {return 'AlreadyPresent'}
    '8A150061' {return 'AlreadyPresent'}
    '8A150109' {return 'RestartRequired'}
    '8A15010B' {return 'RestartRequired'}
    '8A15010A' {return 'RestartRequired'}
    '8A15010D' {return 'AlreadyPresent'}
    '8A15010E' {return 'AlreadyPresent'}
    '8A150014' {return 'NoApplicationsFound'}
    default {return 'Failed'}
  }
}
function Invoke-FSWinGetPackage {
  param(
    [Parameter(Mandatory=$true)][string]$Id,
    [ValidateSet('Install','Upgrade')][string]$Action='Install'
  )
  if(-not (Get-Command winget.exe -ErrorAction SilentlyContinue)){
    throw 'WinGet is unavailable. Update App Installer in Microsoft Store, restart, or ask IT if managed.'
  }
  $exeArgs=@($Action.ToLowerInvariant(),'--id',$Id,'--exact','--source','winget',
    '--accept-package-agreements','--accept-source-agreements')
  & winget.exe @exeArgs | Out-Host
  $outcome=Get-FSWinGetOutcome $LASTEXITCODE
  if($outcome -eq 'NoApplicationsFound' -and $Action -eq 'Upgrade'){$outcome='AlreadyPresent'}
  if($outcome -in @('Failed','NoApplicationsFound')){
    $hex=('{0:X8}' -f ([long]$LASTEXITCODE -band 4294967295L))
    throw "WinGet $Action for $Id failed (code 0x$hex). Check installation permissions, network, and IT policy."
  }
  if($outcome -eq 'RestartRequired'){
    Write-Warning "$Id installed/updated but Windows needs a restart. Close VS Code and rerun the wizard after restarting."
  }elseif($outcome -eq 'AlreadyPresent'){
    Write-Host "[ALREADY] $Id is installed or no applicable update exists."
  }
  return $outcome
}
