#requires -Version 7.4
# Registers approved no-key MCPs for Claude Code and Codex, per-user.
# Never logs in or stores authentication tokens in the repository.
param([ValidateSet('Both','Claude','Codex')][string]$Agent='Both')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$env:Path += ';' + (Join-Path $env:APPDATA 'npm') + ';' +
  (Join-Path $env:USERPROFILE 'develop\flutter\bin') + ';' +
  (Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin')
$failures=New-Object System.Collections.Generic.List[string]
$local=@(
  @{name='dart';command=@('dart','mcp-server')},
  @{name='firebase';command=@('firebase','mcp')},
  @{name='playwright';command=@('npx','-y','@playwright/mcp@latest','--browser=chrome')},
  @{name='maestro';command=@('maestro','mcp')}
)
$remote=@(
  @{name='github';url='https://api.githubcopilot.com/mcp/readonly'},
  @{name='context7';url='https://mcp.context7.com/mcp'},
  @{name='figma';url='https://mcp.figma.com/mcp'}
)
function Register([string]$client,[string]$cli,[string]$name,[string]$url,[string[]]$command) {
  # A user can be signed out while MCP configuration is still available.
  $existing = (& $cli mcp list 2>&1 | Out-String)
  if($LASTEXITCODE -ne 0){throw "$client MCP list command failed"}
  if($existing -match "(?m)^\s*$([regex]::Escape($name))\s"){
    Write-Host "$client already has $name, leaving it untouched."
    return
  }
  if($url){
    if($client -eq 'Codex'){
      & $cli mcp add $name --url $url
    }else{
      & $cli mcp add --transport http --scope user $name $url
    }
  }else{
    if($client -eq 'Codex'){
      & $cli mcp add $name -- @command
    }else{
      & $cli mcp add --scope user $name -- @command
    }
  }
  if($LASTEXITCODE -ne 0){throw "$client could not register MCP $name"}
  Write-Host ("[OK] " + $client + ": " + $name)
}
foreach($client in @('Codex','Claude')){
  if($Agent -ne 'Both' -and $client -ne $Agent){continue}
  $exeName=if($client -eq 'Codex'){'codex.cmd'}else{'claude.exe'}
  $found=Get-Command $exeName -ErrorAction SilentlyContinue|Select-Object -First 1
  if(-not $found){
    $candidate=if($client -eq 'Codex'){Join-Path $env:APPDATA 'npm\codex.cmd'}else{Join-Path $env:USERPROFILE '.local\bin\claude.exe'}
    if(Test-Path -LiteralPath $candidate){$found=[pscustomobject]@{Source=$candidate}}
  }
  if(-not $found){
    Write-Warning "$client CLI not detected. Use VS Code MCPs instead, or rerun developer setup."
    continue
  }
  Write-Host ''
  Write-Host "Configuring $client MCPs in the current Windows user profile..." -ForegroundColor Cyan
  foreach($entry in $local){
    try {Register $client $found.Source $entry.name '' $entry.command}
    catch {$failures.Add("$client / $($entry.name): $($_.Exception.Message)");Write-Warning $failures[$failures.Count-1]}
  }
  foreach($entry in $remote){
    try {Register $client $found.Source $entry.name $entry.url @()}
    catch {$failures.Add("$client / $($entry.name): $($_.Exception.Message)");Write-Warning $failures[$failures.Count-1]}
  }
}
Write-Host ''
Write-Host 'Google Developer Knowledge requires a personal API key; use the VS Code prompt.'
Write-Host 'No cloud credentials, CLI logins, or deployments were performed.'
if($failures.Count){
  Write-Host "$($failures.Count) MCP registration(s) need attention. The VS Code MCP configuration is still available." -ForegroundColor Yellow
  exit 1
}
exit 0
