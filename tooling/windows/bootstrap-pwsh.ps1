#requires -Version 5.1
<#
Minimal PowerShell 5.1 bootstrap. Installs/updates supported PowerShell 7.6 LTS+; all real development scripts run in pwsh 7.
Run by the repository's .cmd entrypoints; never changes execution policy globally.
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('wizard','developer','setup','android','run','verify')]
    [string]$Mode,
    [switch]$SelfTest
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'winget.ps1')
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$minimum = [version]'7.6.0'
$entries = @{
    wizard    = @{File='first-run.ps1'; Args=@(); Update=$true}
    developer = @{File='setup-developer.ps1'; Args=@(); Update=$true}
    setup     = @{File='setup.ps1'; Args=@(); Update=$true}
    android   = @{File='setup.ps1'; Args=@('-Android'); Update=$true}
    run       = @{File='run-app.ps1'; Args=@(); Update=$false}
    verify    = @{File='verify-developer.ps1'; Args=@('-TargetProfile','Contributor'); Update=$false}
}
function Locate-Pwsh {
    $command = Get-Command 'pwsh.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if($command){return $command.Source}
    $candidates = @(
        (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\pwsh.exe')
    )
    foreach($path in $candidates){
        if($path -and (Test-Path -LiteralPath $path)){return $path}
    }
    return $null
}
function PwshVersion([string]$path) {
    if(-not $path){return $null}
    try {
        $raw = (& $path -NoLogo -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()' 2>$null | Select-Object -First 1)
        if($LASTEXITCODE -ne 0){return $null}
        return [version]([string]$raw).Trim()
    } catch {return $null}
}
function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
        [Environment]::GetEnvironmentVariable('Path','User')
}
function Require-Winget {
    if(-not (Get-Command 'winget.exe' -ErrorAction SilentlyContinue)){
        throw 'Windows Package Manager (winget) is missing. Install/update App Installer from Microsoft Store, reopen this window, and try again. If company policy blocks this, contact IT.'
    }
}
function Install-Pwsh {
    Require-Winget
    Write-Host 'Installing current supported PowerShell 7 through Microsoft WinGet...' -ForegroundColor Cyan
    $null=Invoke-FSWinGetPackage -Id 'Microsoft.PowerShell' -Action Install
    Refresh-Path
}
function Update-Pwsh {
    if(-not (Get-Command 'winget.exe' -ErrorAction SilentlyContinue)){
        Write-Warning 'WinGet unavailable. Keeping the supported installed PowerShell 7.'
        return
    }
    Write-Host 'Checking for a supported PowerShell 7 update...'
    $null=Invoke-FSWinGetPackage -Id 'Microsoft.PowerShell' -Action Upgrade
    Refresh-Path
}
try {
    $selected = $entries[$Mode]
    $script = Join-Path $PSScriptRoot $selected.File
    if(-not (Test-Path -LiteralPath $script)){
        throw "Setup file $($selected.File) is missing. Extract the complete repository ZIP and retry."
    }
    if($SelfTest){
        Write-Host "Bootstrap self-test: mode=$Mode; target=$($selected.File); minimum=$minimum"
        if($Mode -eq 'android' -and $selected.Args[0] -ne '-Android'){throw 'Android argument mapping failed.'}
        if($selected.File -notmatch '\.ps1$'){throw 'Invalid script mapping.'}
        Write-Host 'Bootstrap mapping valid. No programs installed.'
        exit 0
    }
    $pwsh = Locate-Pwsh
    $version = PwshVersion $pwsh
    if($Mode -eq 'verify' -and (-not $version -or $version -lt $minimum)){
        Write-Host 'PowerShell 7 is not ready. Running read-only diagnostics in Windows PowerShell 5.1.' -ForegroundColor Yellow
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script
        exit [int]$LASTEXITCODE
    }
    if(-not $version) {
        Install-Pwsh
        $pwsh = Locate-Pwsh
        $version = PwshVersion $pwsh
    } elseif($version -lt $minimum) {
        Update-Pwsh
        $pwsh = Locate-Pwsh
        $version = PwshVersion $pwsh
    }
    if(-not $version -or $version -lt $minimum){
        throw "PowerShell 7.6 LTS or newer could not be started. Restart Windows after installation. Current version: $version. Run FIRST-RUN-WINDOWS.cmd again."
    }
    Write-Host "Using PowerShell $version ($pwsh)" -ForegroundColor Green
    $scriptArguments = [string[]]$selected.Args
    & $pwsh -NoLogo -NoProfile -File $script @scriptArguments
    exit [int]$LASTEXITCODE
} catch {
    Write-Host ''
    Write-Host ('PowerShell setup error: '+$_.Exception.Message) -ForegroundColor Red
    Write-Host 'Check WinGet/App Installer or ask IT if company policy blocked installation.'
    exit 1
}
