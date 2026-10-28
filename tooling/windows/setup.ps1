#requires -Version 5.1
<#
.SYNOPSIS
  Idempotent local Windows setup for the Forged & Sent Flutter development preview.
.DESCRIPTION
  Installs Git, Visual Studio Code, Chrome and the stable Flutter SDK using official
  GitHub/WinGet sources. Optional -Android adds Android Studio but cannot finish the
  interactive SDK/license/device setup. No Firebase credentials or cloud changes.
  Launch through SETUP-WINDOWS.cmd or SETUP-ANDROID.cmd.
#>
param(
    [switch]$Android
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$mobileRoot = Join-Path $projectRoot 'mobile'
$flutterRoot = Join-Path $env:USERPROFILE 'develop\flutter'
$flutterBin = Join-Path $flutterRoot 'bin'
$flutterFile = Join-Path $flutterBin 'flutter.bat'
$log = Join-Path $env:TEMP ('ForgedAndSent-setup-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))
$transcriptStarted = $false
$exitCode = 0

function Announce([string]$text) {
    Write-Host ''
    Write-Host ('=== ' + $text + ' ===') -ForegroundColor Cyan
}

function Refresh-ProcessPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = ($machine, $user -join ';')
}

function Locate-Program([string]$command, [string[]]$candidates) {
    $hit = Get-Command $command -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $hit) { return $hit.Source }
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate }
    }
    return $null
}

function Ensure-Winget {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw 'WinGet was not found. Install/update "App Installer" from Microsoft Store, restart the PC, and rerun SETUP-WINDOWS.cmd.'
    }
}

function Install-Package([string]$id, [string]$label) {
    Ensure-Winget
    Write-Host ('Installing ' + $label + ' using Windows Package Manager...')
    & winget.exe install --id $id --exact --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw ($label + ' installation did not complete (WinGet exit ' + $LASTEXITCODE + '). Check for Windows installation prompts and rerun the setup.')
    }
    Refresh-ProcessPath
}

function Append-UserPath([string]$directory) {
    $saved = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @($saved -split ';' | Where-Object { $_ -and $_.Trim() })
    if (-not ($entries | Where-Object { $_.TrimEnd('\') -ieq $directory.TrimEnd('\') })) {
        [Environment]::SetEnvironmentVariable('Path', (($entries + $directory) -join ';'), 'User')
    }
    if (-not (($env:Path -split ';') | Where-Object { $_.TrimEnd('\') -ieq $directory.TrimEnd('\') })) {
        $env:Path = $directory + ';' + $env:Path
    }
}

function Verify-External([string]$description) {
    if ($LASTEXITCODE -ne 0) {
        throw ($description + ' failed (exit ' + $LASTEXITCODE + '). See the setup log for details.')
    }
}

try {
    try {
        Start-Transcript -Path $log -ErrorAction Stop | Out-Null
        $transcriptStarted = $true
    } catch {
        Write-Warning 'Could not start a setup log, but setup will continue.'
    }

    Write-Host 'Forged & Sent - Windows development setup'
    Write-Host 'Mode: browser preview, plus optional Android Studio if selected.'
    Write-Host 'No Firebase account or credentials are needed for this early preview.'
    Write-Host ('Setup log: ' + $log)
    if (-not (Test-Path -LiteralPath (Join-Path $mobileRoot 'pubspec.yaml'))) {
        throw 'mobile\pubspec.yaml is missing. Download and unzip the entire GitHub branch, then run SETUP-WINDOWS.cmd from the extracted folder.'
    }

    Announce 'Git for Windows'
    $gitCandidates = @(
        (Join-Path $env:ProgramFiles 'Git\cmd\git.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Git\cmd\git.exe')
    )
    $git = Locate-Program 'git.exe' $gitCandidates
    if (-not $git) {
        Install-Package 'Git.Git' 'Git'
        $git = Locate-Program 'git.exe' $gitCandidates
    }
    if (-not $git) { throw 'Git was installed but cannot be found. Reopen Windows, then rerun setup.' }
    Write-Host ('Git ready: ' + $git)

    Announce 'Visual Studio Code'
    $codeCandidates = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),
        (Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd')
    )
    $code = Locate-Program 'code.cmd' $codeCandidates
    if (-not $code) {
        Install-Package 'Microsoft.VisualStudioCode' 'Visual Studio Code'
        $code = Locate-Program 'code.cmd' $codeCandidates
    }
    if (-not $code) { throw 'VS Code installation did not become available. Rerun setup after restarting Windows.' }
    Write-Host 'VS Code ready.'

    Announce 'Google Chrome'
    $programFilesX86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    $chromeCandidates = @(
        (Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),
        (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')
    )
    if ($programFilesX86) { $chromeCandidates += (Join-Path $programFilesX86 'Google\Chrome\Application\chrome.exe') }
    $chrome = Locate-Program 'chrome.exe' $chromeCandidates
    if (-not $chrome) {
        Install-Package 'Google.Chrome' 'Google Chrome'
        $chrome = Locate-Program 'chrome.exe' $chromeCandidates
    }
    if (-not $chrome) { throw 'Chrome installation did not become available. Rerun setup after restarting Windows.' }
    Write-Host 'Chrome ready.'

    Announce 'Flutter SDK'
    $existingFlutter = Locate-Program 'flutter.bat' @($flutterFile)
    if ($existingFlutter) {
        $flutterFile = $existingFlutter
        Write-Host ('Using existing Flutter SDK: ' + $flutterFile)
    } else {
        $parentDir = Split-Path -Parent $flutterRoot
        if (-not (Test-Path -LiteralPath $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        if (Test-Path -LiteralPath $flutterRoot) {
            throw ('The Flutter folder exists but no flutter.bat was found: ' + $flutterRoot + '. Please ask a developer to check this folder rather than deleting it.')
        }
        Write-Host 'Downloading the official Flutter stable SDK into your user folder.'
        & $git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $flutterRoot
        Verify-External 'Flutter download'
        if (-not (Test-Path -LiteralPath $flutterFile)) { throw 'Flutter download did not produce flutter.bat.' }
    }
    $actualFlutterBin = Split-Path -Parent $flutterFile
    Append-UserPath $actualFlutterBin
    & $flutterFile --version
    Verify-External 'Flutter initialization'
    & $flutterFile config --enable-web
    Verify-External 'Flutter web configuration'

    Announce 'Flutter editor extension'
    try {
        & $code --install-extension Dart-Code.flutter --force
        if ($LASTEXITCODE -ne 0) { Write-Warning 'VS Code Flutter extension could not be installed automatically. You can install it from Extensions later.' }
    } catch {
        Write-Warning 'VS Code extension installation skipped. Search for Flutter in VS Code Extensions.'
    }

    if ($Android) {
        Announce 'Optional Android Studio'
        $androidCandidates = @(
            (Join-Path $env:ProgramFiles 'Android\Android Studio\bin\studio64.exe')
        )
        $studio = Locate-Program 'studio64.exe' $androidCandidates
        if (-not $studio) {
            Install-Package 'Google.AndroidStudio' 'Android Studio'
            $studio = Locate-Program 'studio64.exe' $androidCandidates
        }
        if (-not $studio) { throw 'Android Studio was installed but not found. Rerun setup after restart.' }
        Write-Host 'Android Studio installed. Its first-run SDK wizard, licenses and emulator setup require interaction.'
    }

    Announce 'Create local Flutter platform files'
    Push-Location $mobileRoot
    try {
        if ($Android) {
            & $flutterFile create --platforms=web,android --project-name=forged_and_sent --org=com.forgedandsent .
        } else {
            & $flutterFile create --platforms=web --project-name=forged_and_sent --org=com.forgedandsent .
        }
        Verify-External 'Flutter platform setup'
        & $flutterFile pub get
        Verify-External 'Flutter dependency install'
        & $flutterFile analyze
        Verify-External 'Flutter static analysis'
        & $flutterFile test
        Verify-External 'Flutter tests'
    } finally {
        Pop-Location
    }

    Announce 'Finished'
    Write-Host 'Browser preview is installed. Double-click RUN-APP.cmd to see the app.'
    Write-Host 'You can rerun this setup later; it skips installed tools.'
    if ($Android) {
        Write-Host ''
        Write-Host 'Next for Android:'
        Write-Host '1. Open Android Studio and finish its first-run SDK setup wizard.'
        Write-Host '2. Run "flutter doctor --android-licenses" and review/accept SDK licenses.'
        Write-Host '3. Configure a physical Android phone or emulator.'
        Write-Host '4. A Mac is required for local iOS builds.'
    }
} catch {
    $exitCode = 1
    Write-Host ''
    Write-Host ('Setup error: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'If you need help, send a screenshot of this window and the log mentioned at the top.'
} finally {
    if ($transcriptStarted) {
        try { Stop-Transcript | Out-Null } catch {}
    }
}
exit $exitCode
