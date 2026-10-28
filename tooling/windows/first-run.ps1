#requires -Version 7.6
# Guided, interactive Windows setup wizard. No unattended credential prompts.
param([switch]$SelfTest)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$verify=Join-Path $PSScriptRoot 'verify-developer.ps1'
$setup=Join-Path $PSScriptRoot 'setup-developer.ps1'
$base=Join-Path $PSScriptRoot 'setup.ps1'
$script:selectedProfile='Preview'
function Banner([string]$title) {
  Write-Host ''
  Write-Host ('====== '+$title+' ======') -ForegroundColor Cyan
}
function Ask([string]$question) {
  $response=Read-Host "$question [y/N]"
  return ($response -match '^(y|yes)$')
}
function RunScript([string]$file,[string[]]$extra=@()){
  & (Join-Path $PSHOME 'pwsh.exe') -NoLogo -NoProfile -File $file @extra | Out-Host
  return [int]$LASTEXITCODE
}
function HelpReport {
  Banner 'Checking for problems'
  $exitCode=RunScript $verify @('-Profile',$script:selectedProfile)
  if($exitCode -eq 0){
    Write-Host 'All required installed/configured checks passed.' -ForegroundColor Green
    Write-Host 'Account approvals and actual MCP handshakes are still separate.'
  }else{
    Write-Host 'Some items need attention; each is explained with WHY and FIX above.' -ForegroundColor Yellow
  }
  $help=Get-ChildItem -LiteralPath $env:TEMP -Filter 'ForgedAndSent-AskAI-*.txt' -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if($help){
    Write-Host ('AI-ready help report: '+$help.FullName)
    if(Ask 'Copy the secret-free report to the clipboard for Claude, Codex or ChatGPT?'){
      Get-Content -LiteralPath $help.FullName -Raw | Set-Clipboard
      Write-Host 'Copied. Open your AI assistant and paste it for step-by-step troubleshooting.' -ForegroundColor Green
    }
  }
}
function OpenRepo {
  $vscode=(Get-Command code.cmd -ErrorAction SilentlyContinue | Select-Object -First 1)
  $exe=if($vscode){$vscode.Source}else{Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'}
  if(-not (Test-Path -LiteralPath $exe)){
    Write-Host 'VS Code is missing. Run full developer setup first.' -ForegroundColor Yellow
    return
  }
  & $exe $root
  Write-Host 'In VS Code, press Ctrl+Shift+P and choose MCP: List Servers.'
  Write-Host 'Start Dart, Context7, Playwright, and Maestro first.'
  Write-Host 'Sign into Figma/GitHub; Google Knowledge needs an API key from a Google Cloud project.'
  Write-Host 'Firebase cloud MCP is disabled. Start local emulators instead.'
}
function LaunchApp {
  $runner=Join-Path $PSScriptRoot 'run-app.ps1'
  if(-not (Test-Path -LiteralPath $runner)){
    Write-Host 'App launcher not found. Extract the whole branch ZIP.' -ForegroundColor Yellow
    return
  }
  Write-Host 'The browser opens a starter Flutter screen, not the complete old prototype.'
  $code=RunScript $runner
  if($code -ne 0){Write-Host 'App start failed. Choose option 3 to get specific help.' -ForegroundColor Yellow}
}
function ConnectAccounts {
  Banner 'Connect your own accounts (optional)'
  Write-Host 'Only continue if you have the required accounts and understand permissions.'
  Write-Host 'No tokens or passwords are collected or saved by this wizard.'
  if(Ask 'Sign in to GitHub CLI?'){
    $gh=Get-Command gh.exe -ErrorAction SilentlyContinue|Select-Object -First 1
    if($gh){& $gh.Source auth login}else{Write-Host 'Missing GitHub CLI. Run full setup.'}
  }
  Write-Host 'Firebase cloud login is intentionally excluded from Contributor onboarding.'
  Write-Host 'Copilot, Codex, Claude and Figma use their own interactive extension/browser sign-in.'
  Write-Host 'Google Developer Knowledge requires an API-enabled Google Cloud project.'
  Write-Host 'The API key is prompted as a password input when the VS Code MCP starts.'
  if(Ask 'Open VS Code for extension/MCP sign-in and trust prompts?'){OpenRepo}
}
if($SelfTest){
  $code=RunScript $verify @('-SelfTest')
  if($code -ne 0){throw 'Wizard self-test did not produce a valid diagnostic report.'}
  Write-Host 'Wizard self-test passed.'
  exit 0
}
Banner 'Welcome to Forged & Sent'
Write-Host 'Choose a numbered option. No programming experience required.'
Write-Host 'Your computer can develop and test independently; no private Linux server is needed.'
do {
  Write-Host ''
  Write-Host '  1. Choose what you want to do (Preview / Contributor / Mobile / Maintainer)'
  Write-Host '  2. Install only Flutter browser-preview tools'
  Write-Host '  3. Check everything and explain missing items'
  Write-Host '  4. Connect GitHub account (Firebase cloud access is maintainer-only)'
  Write-Host '  5. Open VS Code and set up MCP permissions'
  Write-Host '  6. Run the Flutter starter app in Chrome'
  Write-Host '  7. Read troubleshooting instructions'
  Write-Host '  8. Review project-scoped MCP integrations'
  Write-Host '  9. Start local Firebase emulators'
  Write-Host '  10. Clone a real Git repository (not a ZIP)'
  Write-Host '  0. Exit'
  $choice=Read-Host 'Your choice'
  switch($choice){
    '1' {
      Banner 'Choose your development goal'
      Write-Host '  1. Preview: I only want to see the app'
      Write-Host '  2. Contributor: I want to edit and share changes'
      Write-Host '  3. Mobile: I want to test the Android app'
      Write-Host '  4. Maintainer: I need approved DEV infrastructure access'
      $level=Read-Host 'Choose a profile [1-4]'
      $options=@{'1'='Preview';'2'='Contributor';'3'='Mobile';'4'='Maintainer'}
      if($options.ContainsKey($level)){
        $script:selectedProfile=$options[$level]
        Write-Host "Selected: $script:selectedProfile"
        if(Ask "Install or repair the $script:selectedProfile tools now?"){
          $status=RunScript (Join-Path $PSScriptRoot 'setup-profile.ps1') @('-Profile',$script:selectedProfile)
          if($status -ne 0){Write-Host 'Some components need repair; the next check explains them.' -ForegroundColor Yellow}
          HelpReport
        }
      }else{Write-Host 'Enter a number between 1 and 4.' -ForegroundColor Yellow}
    }
    '2' {
      Banner 'Preview-only setup'
      $status=RunScript $base
      if($status -eq 0){Write-Host 'Now choose option 6 to launch the app.' -ForegroundColor Green}
      else{Write-Host 'Preview setup failed. See its error output or use option 3.' -ForegroundColor Yellow}
    }
    '3' { HelpReport }
    '4' { ConnectAccounts }
    '5' { OpenRepo }
    '6' { LaunchApp }
    '7' {
      $doc=Join-Path $root 'docs\development\FIRST-RUN-TROUBLESHOOTING.md'
      if(Test-Path -LiteralPath $doc){
        Write-Host "Guide: $doc"
        if(Ask 'Open the troubleshooting guide in your default editor?'){Start-Process -FilePath $doc}
      }else{Write-Host 'Troubleshooting guide missing. Extract the entire branch ZIP.'}
    }
    '8' {
      Banner 'Optional Claude/Codex MCP registration'
      Write-Host 'Reviews project MCP configurations; no Firebase cloud MCP is enabled.'
      Write-Host 'Google Knowledge is configured in VS Code with a password-style API key prompt.'
      Write-Host 'Configuration stays within this repository; no user-global registrations.'
      if(Ask 'Show project-scoped MCP locations?'){
        $status=RunScript (Join-Path $PSScriptRoot 'register-cli-mcps.ps1')
        if($status -ne 0){Write-Host 'Some CLI registrations failed. Review errors or use VS Code MCPs.' -ForegroundColor Yellow}
      }
    }
    '9' {
      Banner 'Start local emulators'
      Write-Host 'Only demo-forgedandsent is used. No cloud login is needed.'
      if(Ask 'Start Firebase Local Emulator Suite in this window?'){
        $status=RunScript (Join-Path $PSScriptRoot 'start-emulators.ps1')
        if($status -ne 0){Write-Host 'Check Java 21, Firebase CLI and free ports 8080/9099/9199.' -ForegroundColor Yellow}
      }
    }
    '10' {
      Banner 'Clone a Git repository'
      if(Test-Path -LiteralPath (Join-Path $root '.git')){
        Write-Host 'This folder is already a Git repository. Open it in VS Code.'
      }else{
        $gh=Get-Command gh.exe -ErrorAction SilentlyContinue|Select-Object -First 1
        if(-not $gh){Write-Host 'GitHub CLI missing. Run Contributor setup.' -ForegroundColor Yellow}
        else{
          $target=Join-Path $env:USERPROFILE 'source\ForgedAndSentFitness'
          Write-Host "Suggested clone location: $target"
          if(Test-Path -LiteralPath $target){Write-Host 'Folder exists. Nothing was overwritten.'}
          elseif(Ask 'Clone from GitHub into that new folder?'){
            & $gh.Source auth status
            if($LASTEXITCODE -ne 0){& $gh.Source auth login}
            & $gh.Source repo clone sfcsmithc-afk/ForgedAndSentFitness $target
            if($LASTEXITCODE -eq 0){Write-Host 'Clone ready. Open this new folder in VS Code.'}
            else{Write-Host 'Clone failed. Check GitHub login, network and permissions.' -ForegroundColor Yellow}
          }
        }
      }
    }
    '0' { Write-Host 'Exiting without making more changes.' }
    default {Write-Host 'Please enter one of the listed numbers.' -ForegroundColor Yellow}
  }
} until($choice -eq '0')
exit 0
