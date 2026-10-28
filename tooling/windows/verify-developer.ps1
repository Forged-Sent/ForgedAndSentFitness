#requires -Version 5.1
<#
Read-only profile-aware diagnostics and local, redacted Ask AI report.
"Ready" for an MCP requires a real protocol initialize + tools/list.
#>
param(
  [ValidateSet('Preview','Contributor','Mobile','Maintainer')]
  [string]$Profile='Preview',
  [switch]$SelfTest
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$diag=Join-Path $env:TEMP "ForgedAndSent-Diagnostics-$stamp.txt"
$askAI=Join-Path $env:TEMP "ForgedAndSent-AskAI-$stamp.txt"
$entries=New-Object System.Collections.Generic.List[object]
$env:Path+=';' + (Join-Path $env:APPDATA 'npm') + ';' +
 (Join-Path $env:USERPROFILE 'develop\flutter\bin') + ';' +
 (Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin')
$rank=@{Preview=1;Contributor=2;Mobile=3;Maintainer=4}
function Add-Status([string]$name,[string]$state,[int]$from,[string]$why,[string]$fix){
  $necessary=($rank[$Profile] -ge $from)
  $entries.Add([pscustomobject]@{
    Name=$name;Status=$state;Required=$necessary;Why=$why;Fix=$fix
  })
}
function Find-Command([string]$exe,[string[]]$fallback=@()){
  $command=Get-Command $exe -ErrorAction SilentlyContinue|Select-Object -First 1
  if($command){return $command.Source}
  foreach($path in $fallback){if($path -and (Test-Path -LiteralPath $path)){return $path}}
  return $null
}
function Check-Command([string]$name,[string]$exe,[int]$from,[string]$why,[string]$fix,[string[]]$fallback=@()){
  if(Find-Command $exe $fallback){Add-Status $name 'Ready' $from 'Executable located.' 'None.'}
  else{Add-Status $name 'Missing' $from $why $fix}
}
function Read-PSVersion([string]$path){
  if(-not $path){return $null}
  try{
    $output=& $path -NoLogo -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()' 2>$null|Select-Object -First 1
    if($LASTEXITCODE -ne 0){return $null}
    return [version]([string]$output).Trim()
  }catch{return $null}
}
if($SelfTest){
  Add-Status 'Git' 'Ready' 1 'Fixture is present.' 'None.'
  Add-Status 'Maestro' 'Missing' 3 'The Maestro executable was not found.' 'Install Java 21 and Maestro, then rerun the Mobile setup.'
  Add-Status 'GoogleKnowledgeAuth' 'AuthRequired' 4 'Google Developer Knowledge needs its own Google Cloud API key.' 'Enter it in the VS Code password prompt. Never paste it into Git or AI chat.'
}else{
  Check-Command 'Git' 'git.exe' 1 'Git is needed to obtain and manage sources.' 'Rerun setup to install Git.' @((Join-Path $env:ProgramFiles 'Git\cmd\git.exe'))
  Check-Command 'Chrome' 'chrome.exe' 1 'Chrome is required for the preview.' 'Rerun preview setup or ask IT to install Chrome.' @((Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),(Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe'))
  $flutter=Find-Command 'flutter.bat' @((Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'))
  if($flutter){
    Add-Status 'Flutter' 'Ready' 1 'Flutter launcher found. Runtime build remains a separate check.' 'Run RUN-APP.cmd and flutter doctor.'
  }else{
    Add-Status 'Flutter' 'Missing' 1 'Flutter SDK was not found.' 'Rerun SETUP-WINDOWS.cmd to install Flutter.'
  }
  $pwsh=Find-Command 'pwsh.exe' @((Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'))
  $pv=Read-PSVersion $pwsh
  if($pv -and $pv -ge [version]'7.6.0'){
    Add-Status 'PowerShell 7' 'Ready' 1 "PowerShell $pv detected." 'None.'
  }elseif($pv){
    Add-Status 'PowerShell 7' 'Outdated' 1 "PowerShell $pv is older than required 7.6." 'Run FIRST-RUN-WINDOWS.cmd to update PowerShell.'
  }else{
    Add-Status 'PowerShell 7' 'Missing' 1 'PowerShell 7.6 could not be started.' 'Install/repair Microsoft.PowerShell through WinGet; restart your terminal.'
  }
  Check-Command 'VS Code' 'code.cmd' 2 'Editor required for Contributor work.' 'Run the developer setup.' @((Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),(Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'))
  Check-Command 'Node' 'node.exe' 2 'Node runs Firebase emulators and browser MCPs.' 'Install Node LTS via developer setup.' @((Join-Path $env:ProgramFiles 'nodejs\node.exe'))
  Check-Command 'GitHub CLI' 'gh.exe' 2 'GitHub CLI is needed for branches and draft PRs.' 'Install the GitHub CLI, then run gh auth login.' @((Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe'))
  Check-Command 'Firebase CLI' 'firebase.cmd' 2 'The local emulator runtime needs Firebase CLI.' 'Install firebase-tools through developer setup. Do not sign into production.' @((Join-Path $env:APPDATA 'npm\firebase.cmd'))
  $projectMCP=Join-Path $root '.vscode\mcp.json'
  if(Test-Path -LiteralPath $projectMCP){
    try{
      $settings=Get-Content -LiteralPath $projectMCP -Raw|ConvertFrom-Json
      $names=@($settings.servers.PSObject.Properties.Name)
      if($names -contains 'firebase'){Add-Status 'Firebase MCP isolation' 'Failed' 2 'Cloud Firebase MCP is enabled in a Contributor workspace.' 'Remove the Firebase server; use the Local Emulator Suite instead.'}
      else{Add-Status 'Firebase MCP isolation' 'Ready' 2 'No cloud Firebase MCP in default workspace.' 'None.'}
      foreach($item in @('dart','playwright','context7','figma','maestro','github','google-developer-knowledge')){
        if($names -contains $item){Add-Status "MCP:$item" 'ConfiguredNotConnected' 5 'Server configured, but no live MCP tools/list handshake was performed.' 'Open VS Code MCP: List Servers, connect and verify a read-only tool call.'}
        else{Add-Status "MCP:$item" 'Missing' 5 'Server definition is absent.' 'Restore the current project .vscode/mcp.json.'}
      }
    }catch{Add-Status 'VS Code MCP config' 'Failed' 2 'The MCP JSON could not be parsed.' 'Restore .vscode/mcp.json from the repository.'}
  }else{Add-Status 'VS Code MCP config' 'Missing' 2 'MCP project configuration missing.' 'Clone/extract the full repository.'}
  Add-Status 'Firebase emulator app wiring' 'NotApplicable' 2 'Contributor emulator wiring is scheduled for PR #4, not available in this PR.' 'Use Preview for now; do not claim the Contributor profile is complete.'
  Check-Command 'Java 21' 'java.exe' 3 'JDK 21 is needed for the Firebase emulator and Maestro.' 'Install Temurin 21 through the mobile setup.'
  Check-Command 'Maestro' 'maestro.bat' 3 'Maestro is needed for mobile smoke tests.' 'Install Maestro with the Mobile installer.' @((Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin\maestro.bat'))
  Add-Status 'Android device/emulator' 'ConfiguredNotConnected' 3 'No device run was performed by diagnostics.' 'Run flutter devices, launch a device and execute a Maestro flow.'
  Add-Status 'DEV cloud credentials' 'AuthRequired' 4 'Cloud DEV access is explicitly restricted to maintainers.' 'Request a separate least-privileged DEV identity. No production credentials permitted.'
}
$blocked=@($entries|Where-Object {$_.Required -and $_.Status -notin @('Ready')})
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('Forged & Sent Windows setup diagnostic')
$lines.Add("Profile: $Profile")
$lines.Add('Status is local-only; MCP configuration never implies a live connection.')
$lines.Add('No names, secrets, local file paths, environment variable values or project credentials are included below.')
$lines.Add('')
foreach($item in $entries){
  $req=if($item.Required){'REQUIRED'}else{'OPTIONAL'}
  $lines.Add("[$($item.Status)] $($item.Name) ($req)")
  if($item.Status -ne 'Ready'){
    $lines.Add("  WHY: $($item.Why)")
    $lines.Add("  FIX: $($item.Fix)")
  }
}
$lines.Add('')
$lines.Add("Required unresolved checks: $($blocked.Count)")
$lines|ForEach-Object{Write-Host $_}
$lines|Set-Content -LiteralPath $diag -Encoding UTF8
$ai=New-Object System.Collections.Generic.List[string]
$ai.Add("Help me repair Forged & Sent on Windows. I selected the $Profile setup profile.")
$ai.Add('Do not request credentials, disable security or modify production services.')
$ai.Add('Provide one plain-English repair step at a time; statuses are local checks only.')
foreach($item in $entries|Where-Object{$_.Status -ne 'Ready'}){
  $ai.Add("ISSUE $($item.Name) [$($item.Status)] required=$($item.Required): $($item.Why)")
  $ai.Add("SUGGESTED FIX: $($item.Fix)")
}
$ai|Set-Content -LiteralPath $askAI -Encoding UTF8
Write-Host "Local diagnostic: $diag"
Write-Host "Review-before-sharing AI prompt: $askAI"
if($SelfTest){
  $content=Get-Content -LiteralPath $askAI -Raw
  if($content -notmatch 'ISSUE Maestro'){throw 'SelfTest: missing expected missing-Maestro explanation'}
  Write-Host 'Diagnostic self-test passed.'
  exit 0
}
if($blocked.Count){exit 1}
exit 0
