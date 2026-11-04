#requires -Version 5.1
<#
Minimal PowerShell 5.1 bootstrap. Installs/updates supported PowerShell 7.6 LTS+; all real development scripts run in pwsh 7.
Run by the repository's .cmd entrypoints; never changes execution policy globally.
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('wizard','contributor','check','preview','developer','setup','android','run','verify','emulators','run-emulator')]
    [string]$Mode,
    [switch]$SelfTest,
    # Report which PowerShell 7 was found and why a candidate failed; installs nothing.
    [switch]$ProbeOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'winget.ps1')
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$preferred = [version]'7.6.0'
$minimum = if($Mode -in @('setup','android','run')){[version]'7.4.0'}else{[version]'7.6.0'}
$entries = @{
    wizard    = @{File='first-run.ps1'; Args=@(); Update=$true}
    # Numbered launchers in launchers\windows run one wizard step and exit.
    contributor = @{File='first-run.ps1'; Args=@('-Action','contributor'); Update=$true}
    check     = @{File='first-run.ps1'; Args=@('-Action','check'); Update=$false}
    preview   = @{File='first-run.ps1'; Args=@('-Action','preview'); Update=$true}
    developer = @{File='setup-developer.ps1'; Args=@(); Update=$true}
    setup     = @{File='setup.ps1'; Args=@(); Update=$true}
    android   = @{File='setup.ps1'; Args=@('-Android'); Update=$true}
    run       = @{File='run-app.ps1'; Args=@(); Update=$false}
    verify    = @{File='verify-developer.ps1'; Args=@('-TargetProfile','Contributor'); Update=$false}
    emulators = @{File='start-emulators.ps1'; Args=@(); Update=$false}
    'run-emulator' = @{File='run-emulator-app.ps1'; Args=@(); Update=$false}
}
$script:PwshProbe = New-Object System.Collections.Generic.List[string]
function Get-PwshCandidates {
    # Prefer the real MSI install over PATH entries or Store app-execution aliases.
    $list = New-Object System.Collections.Generic.List[string]
    foreach($dir in @($env:ProgramFiles, $env:ProgramW6432)){
        if($dir){$list.Add((Join-Path $dir 'PowerShell\7\pwsh.exe'))}
    }
    foreach($command in @(Get-Command 'pwsh.exe' -All -ErrorAction SilentlyContinue)){
        if($command.Source){$list.Add($command.Source)}
    }
    if($env:LOCALAPPDATA){$list.Add((Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\pwsh.exe'))}
    $seen = @{}
    foreach($path in $list){
        if(-not $seen.ContainsKey($path) -and (Test-Path -LiteralPath $path)){
            $seen[$path] = $true
            $path
        }
    }
}
function PwshVersion([string]$path) {
    # Windows PowerShell 5.1 pitfalls avoided on purpose: no Select-Object -First on
    # native output (can leave $LASTEXITCODE unset or stale), no stderr redirection
    # under 'Stop' (any stderr text throws), and $LASTEXITCODE is primed so a stale
    # value from WinGet can never be mistaken for this probe's result.
    if(-not $path){return $null}
    $previous = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $global:LASTEXITCODE = -999
        $output = @(& $path -NoLogo -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()' 2>&1)
        $code = $global:LASTEXITCODE
        $stdout = (@($output | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }) | ForEach-Object { "$_" }) -join ' '
        $stderr = (@($output | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }) | ForEach-Object { "$_" }) -join ' '
        if($code -eq 0 -and $stdout -match '(\d+)\.(\d+)\.(\d+)'){
            return [version]('{0}.{1}.{2}' -f $Matches[1], $Matches[2], $Matches[3])
        }
        $script:PwshProbe.Add(("{0}: exit code {1}; output '{2}'; errors '{3}'" -f $path, $code, $stdout.Trim(), $stderr.Trim()))
    } catch {
        $script:PwshProbe.Add(("{0}: could not start ({1})" -f $path, $_.Exception.Message))
    } finally {
        $ErrorActionPreference = $previous
    }
    return $null
}
function Find-Pwsh {
    # Returns the first candidate that actually runs, plus its version.
    $script:PwshProbe.Clear()
    $first = $null
    foreach($path in @(Get-PwshCandidates)){
        if(-not $first){$first = $path}
        $found = PwshVersion $path
        if($found){return [pscustomobject]@{Path=$path; Version=$found}}
    }
    if(-not $first){$script:PwshProbe.Add('No pwsh.exe found in Program Files, PATH or WindowsApps.')}
    return [pscustomobject]@{Path=$first; Version=$null}
}
function Probe-Details {
    if($script:PwshProbe.Count){return (' Details: ' + ($script:PwshProbe -join ' | '))}
    return ''
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
        throw "Setup file $($selected.File) is missing. Use the complete Git clone and retry."
    }
    if($SelfTest){
        Write-Host "Bootstrap self-test: mode=$Mode; target=$($selected.File); minimum=$minimum"
        if($Mode -eq 'android' -and $selected.Args[0] -ne '-Android'){throw 'Android argument mapping failed.'}
        if($Mode -in @('contributor','check','preview') -and ($selected.Args -join ' ') -ne "-Action $Mode"){throw 'Wizard step mapping failed.'}
        if($selected.File -notmatch '\.ps1$'){throw 'Invalid script mapping.'}
        Write-Host 'Bootstrap mapping valid. No programs installed.'
        exit 0
    }
    $found = Find-Pwsh
    $pwsh = $found.Path
    $version = $found.Version
    if($ProbeOnly){
        Write-Host ("PowerShell 7 probe: path='{0}' version='{1}'.{2}" -f $pwsh, $version, (Probe-Details))
        if($version){exit 0}else{exit 1}
    }
    if($Mode -in @('verify','check') -and (-not $version -or $version -lt $minimum)){
        # first-run.ps1 needs PowerShell 7.6, so "check" falls back to the 5.1-safe diagnostics.
        Write-Host 'PowerShell 7 is not ready. Running read-only diagnostics in Windows PowerShell 5.1.' -ForegroundColor Yellow
        $checkProfile='Contributor'
        if($Mode -eq 'check'){
            . (Join-Path $PSScriptRoot 'diagnostic-model.ps1')
            $checkProfile=Get-FSRememberedProfile $root 'Contributor'
        }
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'verify-developer.ps1') -TargetProfile $checkProfile
        exit [int]$LASTEXITCODE
    }
    if(-not $version) {
        Install-Pwsh
        $found = Find-Pwsh
        $pwsh = $found.Path
        $version = $found.Version
    } elseif($selected.Update -and $version -lt $preferred) {
        try {
            Update-Pwsh
            $candidate = Find-Pwsh
            if($candidate.Version){$pwsh=$candidate.Path;$version=$candidate.Version}
        } catch {
            if($version -lt $minimum){throw}
            Write-Warning "PowerShell upgrade unavailable; installed $version still satisfies this script's minimum $minimum."
        }
    }
    if(-not $version -or $version -lt $minimum){
        if($version){
            throw "PowerShell $version was found at $pwsh, but this step needs $minimum or newer. Double-click START-WINDOWS.cmd again to update it."
        }
        throw ("PowerShell 7 is installed but could not be started from Windows PowerShell." + (Probe-Details) +
               " If it was installed just now, restart Windows and double-click START-WINDOWS.cmd again; if this repeats, send this whole message.")
    }
    Write-Host "Using PowerShell $version ($pwsh)" -ForegroundColor Green
    $scriptArguments = [string[]]$selected.Args
    & $pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File $script @scriptArguments
    exit [int]$LASTEXITCODE
} catch {
    Write-Host ''
    Write-Host ('PowerShell setup error: '+$_.Exception.Message) -ForegroundColor Red
    Write-Host 'Check WinGet/App Installer or ask IT if company policy blocked installation.'
    exit 1
}
