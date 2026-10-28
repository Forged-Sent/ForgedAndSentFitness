#requires -Version 7.6
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
function Find-Java21 {
  $paths=@()
  $found=Get-Command 'java.exe' -ErrorAction SilentlyContinue|Select-Object -First 1
  if($found){$paths+=($found.Source)}
  $root=Join-Path $env:ProgramFiles 'Eclipse Adoptium'
  if(Test-Path -LiteralPath $root){
    $paths+=@(Get-ChildItem $root -Directory -Filter 'jdk-21*' |
      ForEach-Object {Join-Path $_.FullName 'bin\java.exe'})
  }
  foreach($path in $paths){
    if(-not (Test-Path -LiteralPath $path)){continue}
    $output=(& cmd.exe /c ('"'+$path+'" -version 2>&1')|Out-String)
    if($output -match '(?:openjdk|version)\s+"?(\d+)'){
      $major=[int]$Matches[1]
      if($major -eq 1 -and $output -match 'version "1\.(\d+)'){$major=[int]$Matches[1]}
      if($major -ge 21){return (Split-Path (Split-Path $path -Parent) -Parent)}
    }
  }
  return $null
}
$jdk=Find-Java21
if(-not $jdk){
  Write-Host 'Installing JDK 21 via WinGet...'
  & winget.exe install --id EclipseAdoptium.Temurin.21.JDK --exact --source winget --accept-source-agreements --accept-package-agreements
  if($LASTEXITCODE -ne 0){Write-Warning 'Java installation may need approval or a reboot.'}
  $jdk=Find-Java21
}
if(-not $jdk){throw 'Java 21 not detected. Restart Windows or ask IT to install Temurin 21, then rerun.'}
Write-Host "JDK 21 located: $jdk" -ForegroundColor Green
exit 0
