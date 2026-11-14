#requires -Version 7.4
<#
.SYNOPSIS
  Starts the local Forged & Sent Flutter preview in Chrome.
  Run with launchers\windows\2 - Run the app.cmd; no Firebase setup is required for the foundation screen.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
# A window opened from setup (for example "Try it now") inherits the PATH from
# before setup installed Node, Git or Java. Read the saved PATH again first.
$env:Path=[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')+';'+$env:Path
$mobile = Join-Path $root 'mobile'
$localFlutter = Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'
$flutter = $null

if (Test-Path -LiteralPath $localFlutter) {
    $flutter = $localFlutter
} else {
    $command = Get-Command flutter.bat -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { $flutter = $command.Source }
}
if (-not $flutter) {
    Write-Host 'Flutter is not installed. Double-click launchers\windows\1 - Set up this computer.cmd first.' -ForegroundColor Yellow
    exit 1
}

try {
    Push-Location $mobile
    try {
        if (-not (Test-Path -LiteralPath (Join-Path $mobile 'web\index.html'))) {
            Write-Host 'Creating browser preview files...'
            & $flutter create --platforms=web --project-name=forged_and_sent --org=com.forgedandsent .
            if ($LASTEXITCODE -ne 0) { throw 'Could not initialize the browser preview.' }
        }
        & $flutter pub get
        if ($LASTEXITCODE -ne 0) { throw 'Could not install Flutter dependencies.' }
        Write-Host ''
        Write-Host 'Starting Chrome. Keep this window open while testing.' -ForegroundColor Cyan
        Write-Host 'The app opens on Today. Most other tabs are placeholders; the HTML prototype is not fully migrated yet.'
        & $flutter run -d chrome
        if ($LASTEXITCODE -ne 0) { throw 'Flutter preview did not start.' }
    } finally {
        Pop-Location
    }
} catch {
    Write-Host ('Preview error: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
