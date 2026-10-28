#requires -Version 7.6
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$cli=Get-Command firebase.cmd -ErrorAction SilentlyContinue|Select-Object -First 1
if(-not $cli){
  $path=Join-Path $env:APPDATA 'npm\firebase.cmd'
  if(Test-Path -LiteralPath $path){$cli=[pscustomobject]@{Source=$path}}
}
if(-not $cli){throw 'Firebase CLI missing. Run Contributor setup.'}
& pwsh -NoProfile -File (Join-Path $PSScriptRoot 'ensure-java21.ps1') | Out-Host
if($LASTEXITCODE){throw 'JDK 21 required; check installer errors.'}
Write-Host 'Starting demo-forgedandsent local emulators (not cloud Firebase).' -ForegroundColor Cyan
Push-Location $root
try {
  & $cli.Source emulators:start --project demo-forgedandsent --only auth,firestore,storage
  if($LASTEXITCODE){throw 'Emulators failed. Check Java 21 and ports 8080/9099/9199.'}
}finally{Pop-Location}
