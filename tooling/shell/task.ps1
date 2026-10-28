#requires -Version 7.6
param([ValidateSet('status','start','share','verify','run','emulators')][string]$Action='status')
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $PSScriptRoot 'fs-tools.ps1')
switch($Action){
  'status' {fs-status}
  'start' {fs-start (Read-Host 'What are you working on?')}
  'share' {fs-share}
  'verify' {& pwsh -NoProfile -File (Join-Path $root 'tooling/windows/verify-developer.ps1') -Profile Contributor}
  'run' {& (Join-Path $root 'RUN-APP.cmd')}
  'emulators' {& (Join-Path $root 'START-EMULATORS-WINDOWS.cmd')}
}
