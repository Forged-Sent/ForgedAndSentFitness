#requires -Version 7.6
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
# A window opened from setup (for example "Try it now") inherits the PATH from
# before setup installed Node, Git or Java. Read the saved PATH again first.
$env:Path=[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')+';'+$env:Path
$cli=Get-Command firebase.cmd -ErrorAction SilentlyContinue|Select-Object -First 1
if(-not $cli){
  $path=Join-Path $env:APPDATA 'npm\firebase.cmd'
  if(Test-Path -LiteralPath $path){$cli=[pscustomobject]@{Source=$path}}
}
if(-not $cli){throw 'Firebase CLI missing. Run Contributor setup.'}
# Only the last line is the JDK path. If the JDK had to be installed just now, the
# lines above it are installer progress (a child pwsh prints those to stdout too).
$jdkOutput=[string](@((& pwsh -NoProfile -File (Join-Path $PSScriptRoot 'ensure-java21.ps1') -PrintHome) | ForEach-Object {"$_".Trim()} | Where-Object {$_}) | Select-Object -Last 1)
if($LASTEXITCODE -ne 0 -or -not $jdkOutput -or -not (Test-Path -LiteralPath (Join-Path $jdkOutput 'bin\java.exe'))){
  throw 'JDK 21 required; rerun Contributor setup and check Java install messages.'
}
$env:JAVA_HOME=$jdkOutput
$env:Path=(Join-Path $jdkOutput 'bin')+';'+$env:Path
Write-Host 'Starting demo-forgedandsent local emulators (not cloud Firebase).' -ForegroundColor Cyan
Push-Location $root
try {
  & $cli.Source emulators:start --project demo-forgedandsent --only auth,firestore,storage
  if($LASTEXITCODE){throw 'Emulators failed. Check Java 21 and ports 8080/9099/9199.'}
}finally{Pop-Location}
