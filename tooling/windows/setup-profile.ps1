#requires -Version 7.6
param([ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile='Preview')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
function Run([string]$path,[string[]]$arguments=@()){
  & pwsh -NoLogo -NoProfile -File $path @arguments | Out-Host
  if($LASTEXITCODE -ne 0){throw "Setup step failed: $path. Run diagnostics for a repair guide."}
}
Write-Host "Forged & Sent: Installing $TargetProfile profile" -ForegroundColor Cyan
Run (Join-Path $PSScriptRoot 'setup.ps1')
if($TargetProfile -eq 'Preview'){exit 0}
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
$leaks=Get-Command gitleaks.exe -ErrorAction SilentlyContinue | Select-Object -First 1
if(-not $leaks){
  & winget.exe install --id Gitleaks.Gitleaks --exact --source winget --accept-source-agreements --accept-package-agreements
  if($LASTEXITCODE -ne 0){throw 'Gitleaks could not be installed. Ask IT or rerun setup.'}
}
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if(Test-Path -LiteralPath (Join-Path $root '.git')){
  & git -C $root config core.hooksPath .githooks
  & git -C $root config pull.ff only
  & git -C $root config push.autoSetupRemote true
  & git -C $root config fetch.prune true
  Write-Host 'Installed repository-scoped Git hooks and safe defaults.'
}else{
  Write-Host 'This folder came from a ZIP. Use the Git clone option in the wizard before contributing.' -ForegroundColor Yellow
}
Write-Host 'FlutterFire CLI activated; flutterfire configure was NOT run.' -ForegroundColor Green
Write-Host 'Firebase emulator project is demo-forgedandsent. No cloud login required.'
if($TargetProfile -eq 'Contributor'){exit 0}
Run (Join-Path $PSScriptRoot 'setup.ps1') @('-Android')
Run (Join-Path $PSScriptRoot 'install-maestro.ps1')
Write-Host 'Complete Android Studio SDK licenses and device/emulator setup manually.'
if($TargetProfile -eq 'Mobile'){exit 0}
Write-Host 'Maintainer DEV IAM is separate: requires explicit invitation; no PROD credentials.' -ForegroundColor Yellow
exit 0
