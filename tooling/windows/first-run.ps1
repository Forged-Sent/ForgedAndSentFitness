#requires -Version 7.6
# Beginner-friendly Windows wizard. Git checkout required; no unattended logins.
param([switch]$SelfTest)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$verify=Join-Path $PSScriptRoot 'verify-developer.ps1'
$profileScript=Join-Path $PSScriptRoot 'setup-profile.ps1'
$previewScript=Join-Path $PSScriptRoot 'setup.ps1'
$script:SelectedProfile='Preview'
function Banner([string]$message){Write-Host '';Write-Host ("=== "+$message+" ===") -ForegroundColor Cyan}
function Ask([string]$question){return ((Read-Host "$question [y/N]") -match '^(y|yes)$')}
function RunScript([string]$path,[string[]]$params=@()){
  & (Join-Path $PSHOME 'pwsh.exe') -NoLogo -NoProfile -File $path @params | Out-Host
  return [int]$LASTEXITCODE
}
function CheckTools {
  Banner 'Your setup report'
  $status=RunScript $verify @('-TargetProfile',$script:SelectedProfile)
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
  }finally{Pop-Location}
}
function RunSetup([string]$targetProfile){
  $script:SelectedProfile=$targetProfile
  Banner "Set up $targetProfile"
  $setupArgs=@('-TargetProfile',$targetProfile)
  if($targetProfile -ne 'Preview'){
    Write-Host 'Choose ONE optional AI assistant: 0=None, 1=Codex, 2=Claude, 3=GitHub Copilot.'
    $answer=Read-Host 'Assistant [0]'
    $agent= switch($answer){'1'{'Codex'} '2'{'Claude'} '3'{'Copilot'} default{'None'}}
    $setupArgs+=@('-AIChoice',$agent)
    Write-Host "Selected: $agent. No AI account is needed to use Flutter or the demo Firebase emulators."
  }
  $status=RunScript $profileScript $setupArgs
  if($status){
    Write-Host 'One or more installs require attention. Check the error and rerun when resolved.' -ForegroundColor Yellow
  }else{
    Write-Host 'Tools installed. This does not automatically sign in or verify emulator connections.' -ForegroundColor Green
    if($targetProfile -ne 'Preview' -and (Ask 'Check your Git commit name/email now?')){SetGitIdentity}
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
    $launcher=Join-Path $root 'START-EMULATORS-WINDOWS.cmd'
    if(-not (Test-Path -LiteralPath $launcher)){throw 'Local emulator launcher is missing. Use the complete Git clone.'}
    Start-Process -FilePath $launcher -WorkingDirectory $root
    Write-Host 'Keep the new window open until the emulators report ready.'
  }
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
      Write-Host '.vscode/mcp.json (VS Code), .mcp.json (Claude), .codex/config.toml (Codex).'
      Write-Host 'Configured does NOT mean connected. Authenticate providers independently.'
    }
    '5' {SetGitIdentity}
    default { }
  }
}
if($SelfTest){
  if(-not (Test-Path -LiteralPath (Join-Path $root 'docs\development\FIRST-CONTRIBUTION.md'))){throw 'First-contribution guide missing.'}
  foreach($launcher in @('START-EMULATORS-WINDOWS.cmd','RUN-EMULATOR-APP-WINDOWS.cmd')){
    if(-not (Test-Path -LiteralPath (Join-Path $root $launcher))){throw "Missing $launcher"}
  }
  if((RunScript $verify @('-SelfTest')) -ne 0){throw 'Diagnostic self-test failed.'}
  Write-Host 'Wizard self-test passed.';exit 0
}
Banner 'Forged & Sent: first run'
Write-Host 'This wizard uses the current Git clone, not a ZIP or an extra copy.'
Write-Host 'No production Firebase credentials or paid AI account is required.'
do {
  Write-Host ''
  Write-Host '  1. Just preview the Flutter app (recommended first)'
  Write-Host '  2. Set up as a Contributor (edit, test, and submit PRs)'
  Write-Host '  3. Check or repair my setup'
  Write-Host '  4. Run the Flutter app in Chrome'
  Write-Host '  5. Start local Firebase emulators in a separate window'
  Write-Host '  6. Run Flutter connected to local Firebase'
  Write-Host '  7. Open VS Code and the first-contribution guide'
  Write-Host '  8. More options (Android, maintainer, GitHub sign-in)'
  Write-Host '  0. Exit'
  $choice=Read-Host 'Choose a number'
  try{
    switch($choice){
      '1' {RunSetup 'Preview'}
      '2' {RunSetup 'Contributor'}
      '3' {CheckTools}
      '4' {
        $rc=RunScript (Join-Path $PSScriptRoot 'run-app.ps1')
        if($rc){Write-Host 'Flutter did not launch. Run Preview setup and diagnostics.' -ForegroundColor Yellow}
      }
      '5' {StartEmulators}
      '6' {
        Write-Host 'Start the emulators using option 5 first and wait for readiness.'
        $rc=RunScript (Join-Path $PSScriptRoot 'run-emulator-app.ps1')
        if($rc){Write-Host 'Emulator-mode app failed. Check that all three local services are running.' -ForegroundColor Yellow}
      }
      '7' {OpenVSCode;OpenGuide}
      '8' {MoreOptions}
      '0' {Write-Host 'You can reopen this wizard any time; no reinstall is needed.'}
      default {Write-Host 'Choose one of the listed numbers.'}
    }
  }catch{Write-Host ('Action needs attention: '+$_.Exception.Message) -ForegroundColor Yellow}
}until($choice -eq '0')
exit 0
