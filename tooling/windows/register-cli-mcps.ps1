#requires -Version 7.4
# Idempotent per-user registration of SAFE, no-cloud-write MCP servers.
# Firebase and GitHub cloud MCPs are deliberately EXCLUDED.
param([ValidateSet('Both','Claude','Codex')][string]$Agent='Both')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$env:Path += ';' + (Join-Path $env:APPDATA 'npm') + ';' + (Join-Path $env:USERPROFILE 'develop\flutter\bin') + ';' + (Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin')
$failures=New-Object System.Collections.Generic.List[string]
$local=@(
  @{name='dart';cmd=@('cmd','/c','dart','mcp-server')},
  @{name='playwright';cmd=@('cmd','/c','npx','-y','@playwright/mcp@0.0.83','--browser=chrome')},
  @{name='maestro';cmd=@('cmd','/c','maestro','mcp')}
)
$remote=@(
  @{name='context7';url='https://mcp.context7.com/mcp'},
  @{name='figma';url='https://mcp.figma.com/mcp'}
)
function Has-Mcp([string]$cli,[string]$name) {
  # mcp get is a single configuration lookup; mcp list may initiate network auth/handshakes.
  $null = & $cli mcp get $name 2>&1
  return ($LASTEXITCODE -eq 0)
}
function Register-Mcp([string]$client,[string]$cli,[string]$name,[string[]]$argv,[string]$url='') {
  if(Has-Mcp $cli $name) {Write-Host "[ALREADY] $client / $name";return}
  if($url){
    if($client -eq 'Claude') {& $cli mcp add --scope user --transport http $name $url}
    else {& $cli mcp add $name --url $url}
  }else{
    if($client -eq 'Claude') {& $cli mcp add --scope user $name -- @argv}
    else {& $cli mcp add $name -- @argv}
  }
  if($LASTEXITCODE -ne 0){throw "$client failed to register $name"}
  Write-Host "[OK] $client / $name"
}
foreach($client in @('Codex','Claude')){
  if($Agent -ne 'Both' -and $client -ne $Agent){continue}
  $exe=if($client -eq 'Codex'){'codex.cmd'}else{'claude.exe'}
  $candidate=Get-Command $exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if(-not $candidate){
    $fallback=if($client -eq 'Codex'){Join-Path $env:APPDATA 'npm\codex.cmd'}else{Join-Path $env:USERPROFILE '.local\bin\claude.exe'}
    if(Test-Path -LiteralPath $fallback){$candidate=[pscustomobject]@{Source=$fallback}}
  }
  if(-not $candidate){Write-Host "[OPTIONAL] $client CLI not installed";continue}
  foreach($item in $local){
    try{Register-Mcp $client $candidate.Source $item.name ([string[]]$item.cmd)}
    catch{$failures.Add("$client/$($item.name): $($_.Exception.Message)")}
  }
  foreach($item in $remote){
    try{Register-Mcp $client $candidate.Source $item.name @() $item.url}
    catch{$failures.Add("$client/$($item.name): $($_.Exception.Message)")}
  }
}
Write-Host 'No Firebase MCP or cloud GitHub credentials were registered. Cloud services remain opt-in for Maintainers only.'
if($failures.Count){
  foreach($failure in $failures){Write-Warning $failure}
  exit 1
}
exit 0
