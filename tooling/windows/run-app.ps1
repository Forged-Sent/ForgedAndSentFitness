#requires -Version 7.4
<#
.SYNOPSIS
  Starts the local Forged & Sent Flutter preview in Chrome.
  Run with RUN-APP.cmd; no Firebase setup is required for the foundation screen.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
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
    Write-Host 'Flutter is not installed. Double-click SETUP-WINDOWS.cmd first.' -ForegroundColor Yellow
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
        Write-Host 'The current Flutter app is a foundation screen, not the full HTML prototype.'
        & $flutter run -d chrome
        if ($LASTEXITCODE -ne 0) { throw 'Flutter preview did not start.' }
    } finally {
        Pop-Location
    }
} catch {
    Write-Host ('Preview error: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
