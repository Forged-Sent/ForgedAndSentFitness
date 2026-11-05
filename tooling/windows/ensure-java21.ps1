#requires -Version 7.6
param([switch]$PrintHome)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
# Same search as "Check my setup" (Find-FSJava21 in diagnostic-model.ps1).
. (Join-Path $PSScriptRoot 'diagnostic-model.ps1')
function Find-Java21 {
  $found=Find-FSJava21
  if($found -and $found.Major -ge 21){return $found.Home}
  return $null
}
$jdk=Find-Java21
if(-not $jdk){
  Write-Host 'Installing JDK 21 via WinGet...'
  # Installer progress must go to the console, never to stdout: callers capture
  # stdout from -PrintHome as the JDK path.
  & winget.exe install --id EclipseAdoptium.Temurin.21.JDK --exact --source winget --accept-source-agreements --accept-package-agreements | Out-Host
  if($LASTEXITCODE -ne 0){Write-Warning 'Java installation may need approval or a reboot.'}
  $jdk=Find-Java21
}
if(-not $jdk){throw 'Java 21 not detected. Restart Windows or ask IT to install Temurin 21, then rerun.'}
# This script never alters user or machine JAVA_HOME/PATH. Callers set only their
# current emulator-process environment using the returned JDK path.
if($PrintHome){[Console]::Out.WriteLine($jdk)}
else{Write-Host 'JDK 21 available for local Firebase. No global Java settings changed.' -ForegroundColor Green}
exit 0
