#requires -Version 7.6
<#
Run from SETUP-DEVELOPER-WINDOWS.cmd.
Installs developer dependencies and VS Code extensions; rerunnable.
It never deploys Firebase, logs into paid services, or stores credentials.
#>
param([switch]$SkipBase,[switch]$SkipAgentCLIs,[switch]$Android)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'winget.ps1')
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$log = Join-Path $env:TEMP ('ForgedAndSent-developer-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))
$issues = New-Object System.Collections.Generic.List[string]
$logged = $false

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
    [Environment]::GetEnvironmentVariable('Path','User') + ';' +
    (Join-Path $env:APPDATA 'npm') + ';' +
    (Join-Path $env:USERPROFILE 'develop\flutter\bin')
}
function Find-Tool([string]$name,[string[]]$alternatives=@()) {
  $found = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($found) { return $found.Source }
  foreach ($path in $alternatives) {
    if ($path -and (Test-Path -LiteralPath $path)) { return $path }
  }
  return $null
}
function Package([string]$id) {
  if (-not (Find-Tool 'winget.exe')) { throw 'WinGet missing. Update App Installer from Microsoft Store and rerun.' }
  $null=Invoke-FSWinGetPackage -Id $id -Action Install
  Refresh-Path
}
function Check-Exit([string]$name) {
  if ($LASTEXITCODE -ne 0) { throw "$name returned $LASTEXITCODE" }
}
function Attempt([string]$label,[scriptblock]$operation,[switch]$Optional) {
  Write-Host ''
  Write-Host "=== $label ===" -ForegroundColor Cyan
  try {
    & $operation
    Write-Host "[OK] $label" -ForegroundColor Green
  } catch {
    if(-not $Optional){$issues.Add("$label : $($_.Exception.Message)")}
    Write-Warning "$label needs attention: $($_.Exception.Message)"
  }
}
function Npm {
  $candidate = Find-Tool 'npm.cmd' @((Join-Path $env:ProgramFiles 'nodejs\npm.cmd'))
  if (-not $candidate) { throw 'npm missing; restart Windows or rerun Node.js install' }
  return $candidate
}
function Code {
  $candidate = Find-Tool 'code.cmd' @(
    (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),
    (Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd')
  )
  if (-not $candidate) { throw 'VS Code launcher missing. Rerun SETUP-WINDOWS.cmd.' }
  return $candidate
}
try {
  try { Start-Transcript -Path $log | Out-Null; $logged=$true } catch { Write-Warning 'Log unavailable' }
  Write-Host "Setup log: $log"
  Write-Host 'Review installation and MCP trust prompts. No Firebase, GitHub, or AI login is performed.'
  Refresh-Path

  if (-not $SkipBase) {
    Attempt 'Basic Flutter/Chrome/Git/VS Code setup' {
      $setupArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $PSScriptRoot 'setup.ps1'))
      if ($Android) { $setupArgs += '-Android' }
      & (Join-Path $PSHOME 'pwsh.exe') @setupArgs
      Check-Exit 'Basic setup'
    }
    Refresh-Path
  }

  Attempt 'Node.js LTS / npm' {
    if (-not (Find-Tool 'node.exe' @((Join-Path $env:ProgramFiles 'nodejs\node.exe')))) {
      Package 'OpenJS.NodeJS.LTS'
    }
    $node=Find-Tool 'node.exe' @((Join-Path $env:ProgramFiles 'nodejs\node.exe'))
    if (-not $node) { throw 'Node.js not detected after install' }
    & $node --version; Check-Exit 'Node.js'
    $npm=Npm; & $npm --version; Check-Exit 'npm'
  }

  Attempt 'GitHub CLI' {
    $gh=Find-Tool 'gh.exe' @((Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe'))
    if (-not $gh) { Package 'GitHub.cli' }
    $gh=Find-Tool 'gh.exe' @((Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe'))
    if (-not $gh) { throw 'GitHub CLI not found; restart then retry' }
    & $gh --version | Select-Object -First 1
  }

  Attempt 'Firebase CLI (local emulators; no cloud MCP)' {
    $npm=Npm
    $pins=Get-Content (Join-Path $root 'tooling\versions.json') -Raw | ConvertFrom-Json
    $firebasePin=[string]$pins.firebaseCLI
    $firebase=Find-Tool 'firebase.cmd' @((Join-Path $env:APPDATA 'npm\firebase.cmd'))
    $foundVersion=if($firebase){((& $firebase --version | Select-Object -First 1) -join '').Trim()}else{''}
    if ($foundVersion -ne $firebasePin) {
      & $npm install --global "firebase-tools@$firebasePin"
      Check-Exit 'Firebase CLI install'
    }
    Refresh-Path
    $firebase=Find-Tool 'firebase.cmd' @((Join-Path $env:APPDATA 'npm\firebase.cmd'))
    if (-not $firebase) { throw 'Firebase CLI not found after npm installation' }
    $installedVersion=((& $firebase --version | Select-Object -First 1) -join '').Trim(); Check-Exit 'Firebase CLI'
    if($installedVersion -ne $firebasePin){throw "Firebase CLI $installedVersion was found but this project pins $firebasePin"}
  }

  Write-Host 'Playwright MCP uses the repository-pinned npx package on first start; no redundant global install.'

  if($Android){
  Attempt 'Maestro Windows CLI and Java 17+' {
    & (Join-Path $PSHOME 'pwsh.exe') -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'install-maestro.ps1')
    Check-Exit 'Maestro installer'
    Refresh-Path
    $env:Path += ';' + (Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin')
  } -Optional

  }else{
    Write-Host 'Maestro is Mobile-only and not installed for the default Contributor workstation.'
  }

  Attempt 'Approved MCP server manifest' {
    $config = Join-Path $root '.vscode\mcp.json'
    if(-not (Test-Path -LiteralPath $config)){throw 'Shared .vscode/mcp.json missing. Extract the full branch.'}
    $definition=Get-Content -LiteralPath $config -Raw | ConvertFrom-Json
    foreach($name in @('dart','playwright','github','context7','figma','maestro','google-developer-knowledge')){
      if(-not ($definition.servers.PSObject.Properties.Name -contains $name)){throw "Missing approved MCP $name"}
    }
    if($definition.servers.PSObject.Properties.Name -contains 'sentry'){throw 'Sentry must not be enabled'}
    if($definition.servers.PSObject.Properties.Name -contains 'firebase'){throw 'Cloud Firebase MCP must not be enabled by default'}
    Write-Host 'Seven safe-by-default MCPs configured in VS Code. No Firebase cloud MCP.'
  }

  Attempt 'Visual Studio Code extensions' {
    $code=Code
    $extensions=@(
      'Dart-Code.dart-code',
      'Dart-Code.flutter',
      'GitHub.copilot-chat',
      'GitHub.vscode-pull-request-github',
      'OpenAI.chatgpt',
      'Anthropic.claude-code',
      'redhat.vscode-yaml',
      'EditorConfig.EditorConfig',
      'ms-vscode.powershell'
    )
    $installed=@(& $code --list-extensions)
    foreach ($id in $extensions) {
      try {
      if ($installed | Where-Object { $_ -ieq $id }) {
        Write-Host "Already installed: $id"
      } else {
        Write-Host "Installing extension: $id"
        & $code --install-extension $id
        Check-Exit "VS Code extension $id"
      }
      } catch { if($id -in @('Dart-Code.dart-code','Dart-Code.flutter')){$issues.Add("Extension $id : $($_.Exception.Message)")}; Write-Warning "Extension $id failed but installation continues" }
    }
  }

  if (-not $SkipAgentCLIs) {
    Attempt 'Codex CLI' {
      $npm=Npm
      $codex=Find-Tool 'codex.cmd' @((Join-Path $env:APPDATA 'npm\codex.cmd'))
      if (-not $codex) {
        & $npm install --global @openai/codex
        Check-Exit 'Codex CLI install'
      }
      Refresh-Path
      $codex=Find-Tool 'codex.cmd' @((Join-Path $env:APPDATA 'npm\codex.cmd'))
      if (-not $codex) { throw 'Codex CLI not detected' }
      & $codex --version; Check-Exit 'Codex CLI'

    }
    Attempt 'Claude Code CLI' {
      $claude=Find-Tool 'claude.exe' @((Join-Path $env:USERPROFILE '.local\bin\claude.exe'))
      if (-not $claude) { Package 'Anthropic.ClaudeCode' }
      Refresh-Path
      $claude=Find-Tool 'claude.exe' @((Join-Path $env:USERPROFILE '.local\bin\claude.exe'))
      if (-not $claude) { throw 'Claude CLI not detected; VS Code extension can still work' }
      & $claude --version; Check-Exit 'Claude Code'

    }
  }

  if(-not $SkipAgentCLIs){
    Attempt 'Register safe no-cloud MCPs with Claude and Codex' {
      & (Join-Path $PSHOME 'pwsh.exe') -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'register-cli-mcps.ps1')
      Check-Exit 'Claude/Codex MCP registration'
    }
  }

  Attempt 'Developer diagnostics' {
    & (Join-Path $PSHOME 'pwsh.exe') -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'verify-developer.ps1') -TargetProfile Contributor
    Check-Exit 'Developer diagnostics'
  }

  Write-Host ''
  if ($issues.Count) {
    Write-Host "$($issues.Count) part(s) require attention. Restart and rerun safely:" -ForegroundColor Yellow
    $issues | ForEach-Object { Write-Host (' - ' + $_) }
  } else {
    Write-Host 'Installation checks complete. Full Contributor readiness requires emulator wiring from PR #4.' -ForegroundColor Green
  }
  Write-Host 'See docs/development/DEVELOPER-WINDOWS.md for MCP trust and account sign-in.'
} finally {
  if ($logged) { try { Stop-Transcript | Out-Null } catch {} }
}
if ($issues.Count) { exit 1 }
exit 0
