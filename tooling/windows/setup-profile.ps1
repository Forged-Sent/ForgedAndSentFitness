#requires -Version 7.6
param([ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$Profile='Preview')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
function Run([string]$path,[string[]]$arguments=@()){
  & pwsh -NoLogo -NoProfile -File $path @arguments | Out-Host
  if($LASTEXITCODE -ne 0){throw "Setup step failed: $path. Run diagnostics for a repair guide."}
}
Write-Host "Forged & Sent: Installing $Profile profile" -ForegroundColor Cyan
Run (Join-Path $PSScriptRoot 'setup.ps1')
if($Profile -eq 'Preview'){exit 0}
Run (Join-Path $PSScriptRoot 'setup-developer.ps1') @('-SkipBase','-SkipMaestro')
Run (Join-Path $PSScriptRoot 'ensure-java21.ps1')
$dart=Join-Path $env:USERPROFILE 'develop\flutter\bin\dart.bat'
if(-not (Test-Path $dart)){
  $resolved=Get-Command dart.bat -ErrorAction SilentlyContinue|Select-Object -First 1
  if($resolved){$dart=$resolved.Source}
}
if(-not (Test-Path $dart)){throw 'Flutter Dart launcher not found. Rerun Preview.'}
& $dart pub global activate flutterfire_cli
if($LASTEXITCODE){throw 'FlutterFire CLI activation failed.'}
$pubBin=Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin'
$old=[Environment]::GetEnvironmentVariable('Path','User')
if(($old -split ';') -notcontains $pubBin){
  [Environment]::SetEnvironmentVariable('Path',($old.TrimEnd(';')+';'+$pubBin),'User')
}
Write-Host 'FlutterFire CLI activated; flutterfire configure was NOT run.' -ForegroundColor Green
Write-Host 'Firebase emulator project is demo-forgedandsent. No cloud login required.'
if($Profile -eq 'Contributor'){exit 0}
Run (Join-Path $PSScriptRoot 'setup.ps1') @('-Android')
Run (Join-Path $PSScriptRoot 'install-maestro.ps1')
Write-Host 'Complete Android Studio SDK licenses and device/emulator setup manually.'
if($Profile -eq 'Mobile'){exit 0}
Write-Host 'Maintainer DEV IAM is separate: requires explicit invitation; no PROD credentials.' -ForegroundColor Yellow
exit 0
