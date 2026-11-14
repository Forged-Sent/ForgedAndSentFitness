#requires -Version 7.6
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
# A window opened from setup (for example "Try it now") inherits the PATH from
# before setup installed Node, Git or Java. Read the saved PATH again first.
$env:Path=[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')+';'+$env:Path
function Check-Port([int]$port){
  $client=[System.Net.Sockets.TcpClient]::new()
  try{
    $job=$client.ConnectAsync('127.0.0.1',$port)
    if(-not $job.Wait(1500) -or -not $client.Connected){return $false}
    return $true
  }catch{return $false}
  finally{$client.Dispose()}
}
foreach($port in @(9099,8080,9199)){
  if(-not (Check-Port $port)){
    throw "Local Firebase emulator port $port is unavailable. First run launchers\windows\3 - Start practice Firebase.cmd."
  }
}
# Prefer the pinned SDK in the user folder, like run-app.ps1 and VS Code.
$flutter=$null
$local=Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'
if(Test-Path -LiteralPath $local){$flutter=[pscustomobject]@{Source=$local}}
else{$flutter=Get-Command flutter.bat -ErrorAction SilentlyContinue|Select-Object -First 1}
if(-not $flutter){throw 'Flutter SDK missing. Run Preview setup.'}
Write-Host 'Flutter will use only demo-forgedandsent emulators (FS_ENV=emulator).' -ForegroundColor Cyan
Write-Host 'To see the connection check: Today > round person button (top right) > Build status.'
Push-Location (Join-Path $root 'mobile')
try {
  & $flutter.Source pub get
  if($LASTEXITCODE){throw 'Flutter pub get failed.'}
  & $flutter.Source run -d chrome --dart-define=FS_ENV=emulator
  if($LASTEXITCODE){throw 'Flutter emulator-mode run failed.'}
}finally{Pop-Location}
