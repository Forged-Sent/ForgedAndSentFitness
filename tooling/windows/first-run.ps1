#requires -Version 7.6
# Beginner-friendly Windows wizard. Git checkout required; no unattended logins.
param(
  [switch]$SelfTest,
  # Used by the numbered launchers in launchers\windows: run one step, then exit.
  [ValidateSet('menu','contributor','check','preview')][string]$Action='menu'
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$verify=Join-Path $PSScriptRoot 'verify-developer.ps1'
$profileScript=Join-Path $PSScriptRoot 'setup-profile.ps1'
$previewScript=Join-Path $PSScriptRoot 'setup.ps1'
. (Join-Path $PSScriptRoot 'diagnostic-model.ps1')
# Grade "Check my setup" against the profile this clone was set up for. If none was
# saved yet, a present Firebase CLI means Contributor tools were installed earlier.
$firebaseFound=([bool](Get-Command firebase.cmd -ErrorAction SilentlyContinue) -or
  [bool]($env:APPDATA -and (Test-Path -LiteralPath (Join-Path $env:APPDATA 'npm\firebase.cmd'))))
$script:LastCheckStatus=0
$script:LastSetupStatus=0
$script:SelectedProfile=Get-FSRememberedProfile $root $(if($firebaseFound){'Contributor'}else{'Preview'})
function Banner([string]$message){Write-Host '';Write-Host ("=== "+$message+" ===") -ForegroundColor Cyan}
function Ask([string]$question){return ((Read-Host "$question [y/N]") -match '^(y|yes)$')}
function RunScript([string]$path,[string[]]$params=@()){
  & (Join-Path $PSHOME 'pwsh.exe') -NoLogo -NoProfile -File $path @params | Out-Host
  return [int]$LASTEXITCODE
}
function CheckTools {
  Banner 'Your setup report'
  Write-Host "Checking your setup as: $script:SelectedProfile (choose 1 or 6 in the menu to switch)." -ForegroundColor Cyan
  $status=RunScript $verify @('-TargetProfile',$script:SelectedProfile)
  $script:LastCheckStatus=$status
  if($status){Write-Host 'Some tools need attention. Follow each WHY/FIX line.' -ForegroundColor Yellow}
  else{Write-Host 'Installed-tool checks passed. Live Firebase and MCP tests are separate.' -ForegroundColor Green}
  $help=Get-ChildItem -LiteralPath $env:TEMP -Filter 'ForgedAndSent-AskAI-*.txt' -File -ErrorAction SilentlyContinue|
    Sort-Object LastWriteTime -Descending|Select-Object -First 1
  if($help -and (Ask 'Copy the redacted help report to your clipboard?')){
    Get-Content -LiteralPath $help.FullName -Raw|Set-Clipboard
    Write-Host 'Copied. Review the report before sending it to an assistant.'
  }
}
function SetGitIdentity {
  if(-not (Test-Path -LiteralPath (Join-Path $root '.git'))){
    Write-Host 'This folder is not a Git clone. Follow docs/development/WINDOWS-QUICKSTART.md.' -ForegroundColor Yellow
    return
  }
  Push-Location $root
  try{
    . (Join-Path $root 'tooling\shell\fs-tools.ps1')
    Ensure-FSGitIdentity
    Write-Host 'Git commit name and email are set for this project.' -ForegroundColor Green
  }finally{Pop-Location}
}
function RunSetup([string]$targetProfile){
  $script:SelectedProfile=$targetProfile
  Save-FSProfile $root $targetProfile
  Banner "Set up $targetProfile"
  $setupArgs=@('-TargetProfile',$targetProfile)
  if($targetProfile -ne 'Preview'){
    $agents=Select-FSAssistants
    $setupArgs+=@('-AIChoice',($agents -join ','))
    Write-Host ("Selected: "+($agents -join ', ')+". No AI account is needed to use Flutter or the demo Firebase emulators.")
  }
  $status=RunScript $profileScript $setupArgs
  $script:LastSetupStatus=$status
  if($status){
    Write-Host 'One or more installs require attention. Check the error and rerun when resolved.' -ForegroundColor Yellow
  }else{
    Write-Host 'Tools installed. This does not automatically sign in or verify emulator connections.' -ForegroundColor Green
  }
  if($targetProfile -ne 'Preview'){
    # Always offered, even after an install warning; only prompts if not yet set.
    Banner 'Your Git commit name and email'
    try{SetGitIdentity}
    catch{Write-Host ('Not set yet: '+$_.Exception.Message+' Set it later with 8 > 5 before your first commit.') -ForegroundColor Yellow}
  }
  CheckTools
}
function OpenGuide {
  $doc=Join-Path $root 'docs\development\FIRST-CONTRIBUTION.md'
  if(-not (Test-Path -LiteralPath $doc)){Write-Host 'Guide missing. Use the complete Git clone.';return}
  Write-Host "First contribution guide: $doc"
  if(Ask 'Open the guide with your default editor?'){Start-Process -FilePath $doc}
}
function OpenVSCode {
  $code=Get-Command code.cmd -ErrorAction SilentlyContinue|Select-Object -First 1
  $path=if($code){$code.Source}else{Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'}
  if(-not (Test-Path -LiteralPath $path)){Write-Host 'VS Code missing. Run Contributor setup.';return}
  & $path $root
  Write-Host 'In VS Code, use Source Control for Git and MCP: List Servers for agent tools.'
  Write-Host 'One signed-in AI assistant is enough; Dart/Context7/Playwright are the basic MCPs.'
}
function StartEmulators {
  Banner 'Demo-only Firebase emulators'
  Write-Host 'No Firebase account is needed. Emulators open in a SEPARATE window.'
  if(Ask 'Start local Auth, Firestore and Storage?'){
    $launcher=Join-Path $root 'launchers\windows\3 - Start practice Firebase.cmd'
    if(-not (Test-Path -LiteralPath $launcher)){throw 'Local emulator launcher is missing. Use the complete Git clone.'}
    Start-Process -FilePath $launcher -WorkingDirectory $root
    Write-Host 'Keep the new window open until the emulators report ready.'
  }
}
# Optional AI assistants: pick any combination (or none). Each one is installed
# separately; signing in to its account is always a separate, manual step.
$script:FSAssistants=[ordered]@{'1'='Codex';'2'='Claude';'3'='Copilot';'4'='Antigravity'}
function ConvertTo-FSAssistants([string]$answer){
  $picked=New-Object System.Collections.Generic.List[string]
  foreach($token in @(($answer -replace '[^0-9]',' ').Trim() -split '\s+' | Where-Object {$_})){
    foreach($digit in $token.ToCharArray()){
      $name=$script:FSAssistants[[string]$digit]
      if($name -and -not $picked.Contains($name)){$picked.Add($name)}
    }
  }
  if($picked.Count -eq 0){return @('None')}
  return @($picked.ToArray())
}
function Select-FSAssistants {
  Write-Host 'Optional AI assistants. Pick any you use, or none:'
  Write-Host '  1 = Codex (OpenAI)   2 = Claude Code   3 = GitHub Copilot   4 = Antigravity CLI (Google Gemini)'
  Write-Host '  Type the numbers separated by commas, for example 2,4. Press Enter for none.'
  return @(ConvertTo-FSAssistants (Read-Host 'Assistants [none]'))
}
function MoreOptions {
  Banner 'More options (optional)'
  Write-Host '  1. Mobile/Android tools'
  Write-Host '  2. Maintainer setup (DEV IAM is separate; never PROD)'
  Write-Host '  3. Sign in to GitHub CLI'
  Write-Host '  4. Show project MCP configuration'
  Write-Host '  5. Check Git commit name/email'
  Write-Host '  0. Back'
  switch(Read-Host 'Your choice'){
    '1' {RunSetup 'Mobile'}
    '2' {RunSetup 'Maintainer'}
    '3' {
      $gh=Get-Command gh.exe -ErrorAction SilentlyContinue|Select-Object -First 1
      if($gh){& $gh.Source auth login}
      else{Write-Host 'GitHub CLI missing. Run Contributor setup first.'}
    }
    '4' {
      Write-Host '.vscode/mcp.json (VS Code, Copilot), .mcp.json (Claude), .codex/config.toml (Codex).'
      Write-Host 'Antigravity CLI reads AGENTS.md and .agents/skills; its MCP servers are not preconfigured yet.'
      Write-Host 'Configured does NOT mean connected. Authenticate providers independently.'
    }
    '5' {SetGitIdentity}
    default { }
  }
}
if($SelfTest){
  if(-not (Test-Path -LiteralPath (Join-Path $root 'docs\development\FIRST-CONTRIBUTION.md'))){throw 'First-contribution guide missing.'}
  $parsed=(ConvertTo-FSAssistants '2, 4 4') -join ','
  if($parsed -ne 'Claude,Antigravity'){throw "Assistant parsing failed: $parsed"}
  if(((ConvertTo-FSAssistants '') -join ',') -ne 'None' -or ((ConvertTo-FSAssistants '1234') -join ',') -ne 'Codex,Claude,Copilot,Antigravity'){throw 'Assistant parsing failed.'}
  foreach($launcher in @('START-WINDOWS.cmd','launchers\windows\3 - Start practice Firebase.cmd','launchers\windows\4 - Run app with practice Firebase.cmd')){
    if(-not (Test-Path -LiteralPath (Join-Path $root $launcher))){throw "Missing $launcher"}
  }
  if((RunScript $verify @('-SelfTest')) -ne 0){throw 'Diagnostic self-test failed.'}
  Write-Host 'Wizard self-test passed.';exit 0
}
if($Action -ne 'menu'){
  switch($Action){
    'contributor' {RunSetup 'Contributor'}
    'preview' {RunSetup 'Preview'}
    'check' {CheckTools}
  }
  if($Action -ne 'check' -and $script:LastSetupStatus){
    Banner 'Setup did not finish'
    Write-Host 'Fix the first error shown above (it says what to do), then double-click the same' -ForegroundColor Yellow
    Write-Host 'setup file again. Finished parts are reused, so nothing is downloaded twice.' -ForegroundColor Yellow
    Write-Host 'Still stuck? Run 5 - Check my setup.cmd and share its redacted help report.'
    exit 1
  }
  Banner 'What to do next'
  Write-Host 'Open the launchers\windows folder and double-click the next numbered file:'
  Write-Host '  2 - Run the app.cmd                     (the app in Chrome)'
  Write-Host '  3 - Start practice Firebase.cmd         (local practice database; keep it open)'
  Write-Host '  4 - Run app with practice Firebase.cmd  (after step 3 says ready)'
  Write-Host 'Then read docs\development\FIRST-CONTRIBUTION.md to make your first change.'
  exit $script:LastCheckStatus
}
Banner 'Forged & Sent: first run'
Write-Host 'This wizard uses the current Git clone, not a ZIP or an extra copy.'
Write-Host 'No production Firebase credentials or paid AI account is required.'
do {
  Write-Host ''
  # 1-5 match the numbered files in launchers\windows.
  Write-Host '  1. Set up this computer (full setup: edit, test, and submit PRs)'
  Write-Host '  2. Run the app in Chrome'
  Write-Host '  3. Start practice Firebase (opens a separate window)'
  Write-Host '  4. Run the app with practice Firebase'
  Write-Host '  5. Check my setup'
  Write-Host '  6. Preview-only setup (quickest; view only)'
  Write-Host '  7. Open VS Code and the first-contribution guide'
  Write-Host '  8. More options (Android, maintainer, GitHub sign-in)'
  Write-Host '  0. Exit'
  $choice=Read-Host 'Choose a number'
  try{
    switch($choice){
      '1' {RunSetup 'Contributor'}
      '2' {
        $rc=RunScript (Join-Path $PSScriptRoot 'run-app.ps1')
        if($rc){Write-Host 'Flutter did not launch. Run option 1 (setup), then option 5 (check).' -ForegroundColor Yellow}
      }
      '3' {StartEmulators}
      '4' {
        Write-Host 'Start practice Firebase with option 3 first and wait until it says ready.'
        $rc=RunScript (Join-Path $PSScriptRoot 'run-emulator-app.ps1')
        if($rc){Write-Host 'Emulator-mode app failed. Check that all three local services are running.' -ForegroundColor Yellow}
      }
      '5' {CheckTools}
      '6' {RunSetup 'Preview'}
      '7' {OpenVSCode;OpenGuide}
      '8' {MoreOptions}
      '0' {Write-Host 'You can reopen this wizard any time; no reinstall is needed.'}
      default {Write-Host 'Choose one of the listed numbers.'}
    }
  }catch{Write-Host ('Action needs attention: '+$_.Exception.Message) -ForegroundColor Yellow}
}until($choice -eq '0')
exit 0
