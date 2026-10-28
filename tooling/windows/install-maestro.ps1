#requires -Version 5.1
<#
Maestro official Windows CLI installer. Requires Java 17+. Uses official
https://github.com/mobile-dev-inc/maestro/releases/latest/download/maestro.zip .
Installs under %LOCALAPPDATA%, never invokes downloaded scripts.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$home = Join-Path $env:LOCALAPPDATA 'Programs\Maestro'
$archive = Join-Path $env:TEMP ('ForgedAndSent-Maestro-' + [guid]::NewGuid().ToString('n') + '.zip')
$staging = Join-Path $env:TEMP ('ForgedAndSent-Maestro-' + [guid]::NewGuid().ToString('n'))
function Find-Tool([string]$name) {
  $hit = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
  if($hit){return $hit.Source}
  return $null
}
function Add-UserPath([string]$bin) {
  $existing = [Environment]::GetEnvironmentVariable('Path','User')
  $entries = @($existing -split ';' | Where-Object { $_ -and $_.Trim() })
  if(-not ($entries | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') })){
    [Environment]::SetEnvironmentVariable('Path', (($entries + $bin) -join ';'), 'User')
  }
  if(-not (($env:Path -split ';') | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') })){
    $env:Path = $bin + ';' + $env:Path
  }
}
function JavaVersion {
  $j = Find-Tool 'java.exe'
  if(-not $j){return 0}
  $info = (& cmd.exe /c 'java -version 2>&1' | Out-String)
  if($info -match 'version "(\d+)'){
    $major = [int]$Matches[1]
    if($major -eq 1 -and $info -match 'version "1\.(\d+)'){$major=[int]$Matches[1]}
    return $major
  }
  if($info -match 'openjdk (\d+)'){return [int]$Matches[1]}
  return 0
}
$version=JavaVersion
if($version -lt 17) {
  Write-Host 'Maestro requires Java 17 or newer. Installing Temurin 17 JDK through WinGet...'
  if(-not (Find-Tool 'winget.exe')){throw 'WinGet is required to install Java 17. Install App Installer from Microsoft Store.'}
  & winget.exe install --exact --id EclipseAdoptium.Temurin.17.JDK --source winget --accept-package-agreements --accept-source-agreements
  if($LASTEXITCODE -ne 0){throw 'Java 17 installation failed. Restart Windows and rerun setup.'}
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
  if((JavaVersion) -lt 17){
    Write-Warning 'Java may need a fresh terminal after installation. Restart Windows and rerun the developer setup.'
    throw 'Java 17 not detected after installation.'
  }
}
$existing=Find-Tool 'maestro.bat'
if(-not $existing){$existing=Find-Tool 'maestro.exe'}
if(-not $existing){
  foreach($item in @((Join-Path $home 'bin\maestro.bat'),(Join-Path $home 'bin\maestro.exe'))){
    if(Test-Path -LiteralPath $item){$existing=$item;break}
  }
}
if($existing){
  Write-Host ('Maestro already installed: '+$existing)
  Add-UserPath (Split-Path $existing -Parent)
  exit 0
}
try {
  $url='https://github.com/mobile-dev-inc/maestro/releases/latest/download/maestro.zip'
  Write-Host 'Downloading Maestro CLI from its official GitHub release...'
  Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $archive
  if((Get-Item $archive).Length -lt 100000){throw 'Maestro download looks incomplete.'}
  New-Item -ItemType Directory -Force -Path $staging | Out-Null
  Expand-Archive -LiteralPath $archive -DestinationPath $staging -Force
  $launcher=Get-ChildItem $staging -Recurse -File | Where-Object{$_.Name -in @('maestro.bat','maestro.exe')} | Select-Object -First 1
  if(-not $launcher){throw 'Downloaded Maestro ZIP has no native Windows launcher. Check the official release or use the installer manually.'}
  $installRoot=Split-Path (Split-Path $launcher.FullName -Parent) -Parent
  if(-not (Test-Path -LiteralPath $installRoot)){throw 'Unexpected Maestro package layout.'}
  $target=Join-Path $home 'bin'
  if(Test-Path -LiteralPath $home){throw 'Maestro install directory exists but is incomplete. Inspect it before rerunning.'}
  New-Item -ItemType Directory -Force -Path (Split-Path $home -Parent) | Out-Null
  Move-Item -LiteralPath $installRoot -Destination $home
  $installedLauncher=Join-Path $target $launcher.Name
  if(-not (Test-Path -LiteralPath $installedLauncher)){
    # Some release archives contain a different root layout; search inside the installed package.
    $found=Get-ChildItem $home -Recurse -File | Where-Object{$_.Name -in @('maestro.bat','maestro.exe')} | Select-Object -First 1
    if(-not $found){throw 'Maestro moved but executable was not found.'}
    $target=Split-Path $found.FullName -Parent
  }
  Add-UserPath $target
  Write-Host ('Maestro CLI installed: '+$target)
  Write-Host 'Actual UI testing also requires a connected Android device or emulator.'
} finally {
  if(Test-Path -LiteralPath $archive){Remove-Item $archive -Force -ErrorAction SilentlyContinue}
  if(Test-Path -LiteralPath $staging){Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue}
}
