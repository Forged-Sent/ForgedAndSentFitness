#requires -Version 5.1
# Read-only, profile-aware diagnostics. Does NOT authenticate or contact cloud MCPs.
param(
  [Alias('Profile')][ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile='Contributor',
  [switch]$SelfTest
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $PSScriptRoot 'diagnostic-model.ps1')
$report=Join-Path $env:TEMP ('ForgedAndSent-Diagnostics-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'.txt')
$aiReport=Join-Path $env:TEMP ('ForgedAndSent-AskAI-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'.txt')
$checks=New-Object System.Collections.Generic.List[object]
$env:Path+=';'+(Join-Path $env:APPDATA 'npm')+';'+(Join-Path $env:USERPROFILE 'develop\flutter\bin')+';'+(Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin')
function Check([string]$id,[string]$name,[string[]]$paths,[string]$fix) {
  $cmd=Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
  $path=if($cmd){$cmd.Source}else{$paths|Where-Object{$_ -and (Test-Path -LiteralPath $_)}|Select-Object -First 1}
  if($path){$checks.Add((New-FSCheck $id Ready 'Executable found. Live runtime testing is separate.' ''))}
  else{$checks.Add((New-FSCheck $id Missing 'Required executable was not located.' $fix))}
}
if($SelfTest){
  $fixture=@(
    (New-FSCheck Git Ready 'Found' ''),
    (New-FSCheck Maestro Missing 'Not installed' 'Run Mobile setup')
  )
  if((Get-FSNeed Preview Maestro) -ne 'Optional'){throw 'Optional tool was marked required'}
  if((Get-FSExitCode Preview $fixture) -ne 0){throw 'Optional tool incorrectly failed Preview'}
  if((Get-FSExitCode Mobile $fixture) -ne 1){throw 'Required tool incorrectly passed Mobile'}
  $text='ISSUE Maestro: Not installed; FIX: Run Mobile setup'
  if($text -notmatch 'ISSUE Maestro'){throw 'Help prompt fixture missing'}
  Write-Host 'Self-test passed: profile-aware statuses and optional/required exit logic.'
  exit 0
}
# Progress lines so a long check never looks frozen; the full report prints at the end.
function Say([string]$what){Write-Host ('  checking '+$what+'...') -ForegroundColor DarkGray}
Write-Host "Checking your computer for the $TargetProfile setup (usually under a minute; the report prints at the end)." -ForegroundColor Cyan
Say 'Git, Chrome, Flutter, VS Code, Node and command-line tools'
Check Git git.exe @((Join-Path $env:ProgramFiles 'Git\cmd\git.exe')) 'Run launchers\windows\1 - Set up this computer.cmd, then restart the terminal.'
Check Chrome chrome.exe @((Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),(Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')) 'Run launchers\windows\1 - Set up this computer.cmd to install Chrome.'
# The project (launchers, VS Code dart.flutterSdkPath) uses the pinned SDK in the user folder.
$pinnedFlutter=Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'
if(Test-Path -LiteralPath $pinnedFlutter){$checks.Add((New-FSCheck Flutter Ready 'Pinned project SDK found. Live runtime testing is separate.' ''))}
elseif(Get-Command flutter.bat -ErrorAction SilentlyContinue){$checks.Add((New-FSCheck Flutter Outdated 'A different Flutter SDK is on PATH; this project uses its own pinned 3.47.8 in your user folder.' 'Run launchers\windows\1 - Set up this computer.cmd. It installs 3.47.8 side by side and leaves the other SDK alone.'))}
else{$checks.Add((New-FSCheck Flutter Missing 'Flutter SDK was not located.' 'Run launchers\windows\1 - Set up this computer.cmd, then check flutter doctor.'))}
Check VSCode code.cmd @((Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),(Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd')) 'Install VS Code with launchers\windows\1 - Set up this computer.cmd.'
Check Node node.exe @((Join-Path $env:ProgramFiles 'nodejs\node.exe')) 'Run developer setup for Node.js LTS.'
Check Npm npm.cmd @((Join-Path $env:ProgramFiles 'nodejs\npm.cmd')) 'Reinstall Node.js LTS, then restart Windows.'
Check GitHubCLI gh.exe @((Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe')) 'Run developer setup for GitHub CLI.'
Check FirebaseCLI firebase.cmd @((Join-Path $env:APPDATA 'npm\firebase.cmd')) 'Run developer setup for local Firebase CLI. No Firebase login required for Preview.'
Say 'Python'
$pyVersion=''
$pyTimedOut=$false
foreach($candidate in @(@('py.exe','-3'),@('python.exe'))) {
  $tool=Get-Command $candidate[0] -ErrorAction SilentlyContinue|Select-Object -First 1
  if(-not $tool){continue}
  try{
    $versionArgs=if($candidate.Count -gt 1){@($candidate[1])}else{@()}
    $probe=Invoke-FSProbe $tool.Source (@($versionArgs)+@('--version'))
    if($probe.TimedOut){$pyTimedOut=$true;break}
    $verText=$probe.Text
    if($probe.ExitCode -eq 0 -and $verText -match 'Python (\d+)\.(\d+)'){
      if([int]$Matches[1] -gt 3 -or ([int]$Matches[1] -eq 3 -and [int]$Matches[2] -ge 11)){$pyVersion="$($Matches[1]).$($Matches[2])";break}
    }
  }catch{}
}
if($pyVersion){$checks.Add((New-FSCheck Python Ready 'Python 3.11+ available for Atlas/review.' '' $pyVersion))}
elseif($pyTimedOut){$checks.Add((New-FSCheck Python Failed 'Python did not answer within 15 seconds (often a one-time Python install manager question).' 'Open PowerShell, run py --version once and answer its questions, then run 5 - Check my setup.cmd again.'))}
else{$checks.Add((New-FSCheck Python Missing 'Python 3.11+ not found; the Atlas and AI review tools cannot run.' 'Run Contributor setup to install Python 3.12.'))}
# Contributor profiles require a real clone, local SDK/CLI and running emulators.
$gitFolder=Join-Path $root '.git'
if(Test-Path -LiteralPath $gitFolder){
  $checks.Add((New-FSCheck GitRepo Ready 'This is a Git clone.' ''))
  $gitName=(& git -C $root config --get user.name 2>$null|Out-String).Trim()
  $gitEmail=(& git -C $root config --get user.email 2>$null|Out-String).Trim()
  if($gitName -and $gitEmail){$checks.Add((New-FSCheck GitIdentity Ready 'Git commit identity is configured.' ''))}
  else{$checks.Add((New-FSCheck GitIdentity Missing 'New Git commits need a name and email.' 'Use the first-run wizard Git identity option; a GitHub noreply email is recommended.'))}
}else{
  $checks.Add((New-FSCheck GitRepo Missing 'This folder is not a Git clone.' 'Use Git to clone Forged-Sent/ForgedAndSentFitness; see WINDOWS-QUICKSTART.md.'))
  $checks.Add((New-FSCheck GitIdentity Missing 'No repository exists for local Git identity.' 'First clone the repository with Git.'))
}
Check FlutterFireCLI flutterfire.bat @((Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin\flutterfire.bat')) 'Run Contributor setup to install FlutterFire CLI. Do not run flutterfire configure automatically.'
$demo=(Join-Path $root '.firebaserc')
$configFile=(Join-Path $root 'firebase.json')
if((Test-Path -LiteralPath $demo) -and (Test-Path -LiteralPath $configFile)){
  try {
    $id=(Get-Content -LiteralPath $demo -Raw|ConvertFrom-Json).projects.default
    if($id -eq 'demo-forgedandsent'){$checks.Add((New-FSCheck DemoConfig Ready 'Local demo Firebase config found.' ''))}
    else{$checks.Add((New-FSCheck DemoConfig Failed 'Firebase project is not demo-forgedandsent.' 'Restore the checked-in demo .firebaserc.'))}
  }catch{$checks.Add((New-FSCheck DemoConfig Failed 'Local demo configuration could not be parsed.' 'Restore firebase.json and .firebaserc.'))}
}else{$checks.Add((New-FSCheck DemoConfig Missing 'Firebase emulator files are missing.' 'Checkout PR #4 complete files.'))}
Say 'Java 21 for practice Firebase'
$jdk=Find-FSJava21
if($jdk -and $jdk.Major -ge 21){$checks.Add((New-FSCheck Java21 Ready 'JDK 21+ found for practice Firebase (your JAVA_HOME is not changed).' '' "$($jdk.Major)"))}
elseif($jdk){$checks.Add((New-FSCheck Java21 Outdated "Only Java $($jdk.Major) was found; practice Firebase needs JDK 21+." 'Run launchers\windows\1 - Set up this computer.cmd. It adds Temurin JDK 21 next to your current Java and does not change JAVA_HOME.' "$($jdk.Major)"))}
else{$checks.Add((New-FSCheck Java21 Missing 'Java 21 was not found (checked JAVA_HOME, PATH and Eclipse Adoptium).' 'Run launchers\windows\1 - Set up this computer.cmd; restart Windows if the JDK was just installed.'))}
Say 'practice Firebase ports 8080, 9099, 9199'
$listen=@(8080,9099,9199)
$closed=New-Object System.Collections.Generic.List[int]
foreach($port in $listen) {
  $client=New-Object System.Net.Sockets.TcpClient
  try {
    $pending=$client.BeginConnect('127.0.0.1',$port,$null,$null)
    if(-not $pending.AsyncWaitHandle.WaitOne(600) -or -not $client.Connected){$closed.Add($port)}
    elseif($client.Connected){$client.EndConnect($pending)}
  }catch{$closed.Add($port)}
  finally{$client.Close()}
}
if($closed.Count){
  $checks.Add((New-FSCheck EmulatorOnline ConfiguredNotConnected 'Local emulator ports are not all reachable.' 'Run launchers\windows\3 - Start practice Firebase.cmd. Check ports 8080, 9099, 9199.'))
}else{
  $checks.Add((New-FSCheck EmulatorOnline Ready 'Local Auth/Firestore/Storage TCP ports respond; app integration still needs a real UI test.' ''))
}
$gh=Get-Command gh.exe -ErrorAction SilentlyContinue|Select-Object -First 1
if($gh){
  Say 'GitHub sign-in (needs the internet; gives up after 15 seconds)'
  # gh contacts GitHub to validate a saved token; never let a slow network freeze setup.
  try{
    $ghProbe=Invoke-FSProbe $gh.Source @('auth','status')
    if($ghProbe.TimedOut){
      $checks.Add((New-FSCheck GitHubAuth AuthRequired 'GitHub sign-in check timed out (no reply from GitHub within 15 seconds).' 'Check the internet connection, then run 5 - Check my setup.cmd again.'))
    }elseif($ghProbe.ExitCode -eq 0){$checks.Add((New-FSCheck GitHubAuth Ready 'GitHub CLI account is authenticated.' ''))}
    else{$checks.Add((New-FSCheck GitHubAuth AuthRequired 'GitHub account not authorized for draft PRs.' 'In START-WINDOWS.cmd choose 8 (More options), then 3 to sign in to GitHub.'))}
  }catch{$checks.Add((New-FSCheck GitHubAuth Failed 'GitHub CLI could not be started.' 'Rerun launchers\windows\1 - Set up this computer.cmd.'))}
}else{$checks.Add((New-FSCheck GitHubAuth Missing 'GitHub CLI missing.' 'Run Contributor setup.'))}
$checks.Add((New-FSCheck AndroidDevice ConfiguredNotConnected 'A native Android device and Maestro flow were not run by this diagnostic.' 'Run flutter devices and one Maestro flow on an emulator or phone.'))

Check Maestro maestro.bat @((Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin\maestro.bat')) 'Run setup for mobile testing. Java and a phone/emulator are required.'
Check AndroidStudio studio64.exe @((Join-Path $env:ProgramFiles 'Android\Android Studio\bin\studio64.exe')) 'Run launchers\windows\more\Android setup.cmd and complete the Android SDK setup wizard.'
Check ClaudeCLI claude.exe @((Join-Path $env:USERPROFILE '.local\bin\claude.exe')) 'Optional: run the developer setup or use VS Code extension.'
Check CodexCLI codex.cmd @((Join-Path $env:APPDATA 'npm\codex.cmd')) 'Optional: run developer setup or use Codex VS Code extension.'
Check AntigravityCLI agy.exe @((Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\agy.exe')) 'Optional: pick Antigravity (4) during setup, then sign in by running agy.'
Say 'PowerShell 7 and VS Code MCP configuration'
$pwsh=(Get-Command pwsh.exe -ErrorAction SilentlyContinue|Select-Object -First 1)
$pwshPath=if($pwsh){$pwsh.Source}else{Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'}
if(Test-Path -LiteralPath $pwshPath){
  try {
    $pwshProbe=Invoke-FSProbe $pwshPath @('-NoProfile','-NonInteractive','-Command','$PSVersionTable.PSVersion.ToString()')
    if($pwshProbe.TimedOut -or $pwshProbe.ExitCode -ne 0){throw 'PowerShell 7 did not answer.'}
    $v=[version](([string](($pwshProbe.Text -split "`r?`n")|Where-Object {$_.Trim()}|Select-Object -First 1)).Trim() -replace '-.*$','')
    $requiredPwsh=if($TargetProfile -eq 'Preview'){[version]'7.4.0'}else{[version]'7.6.0'}
    if($v -ge $requiredPwsh){$checks.Add((New-FSCheck PowerShell7 Ready 'Version meets baseline.' '' $v.ToString()))}
    else{$checks.Add((New-FSCheck PowerShell7 Outdated 'PowerShell version is below the chosen profile minimum.' 'Run START-WINDOWS.cmd to update PowerShell.' $v.ToString()))}
  }catch{$checks.Add((New-FSCheck PowerShell7 Failed 'PowerShell 7 could not start.' 'Restart terminal or ask IT to repair PowerShell 7.'))}
}else{$checks.Add((New-FSCheck PowerShell7 Missing 'PowerShell 7 not found.' 'Run START-WINDOWS.cmd to install it.'))}
$java=Get-Command java.exe -ErrorAction SilentlyContinue|Select-Object -First 1
if($java) {
  $verLine=(Invoke-FSProbe $java.Source @('-version')).Text
  $found=[regex]::Match($verLine,'(?:version\s+["'']|openjdk\s+)(?<major>\d+)')
  if($found.Success){
    $major=[int]$found.Groups['major'].Value
    if($major -eq 1 -and $verLine -match '1\.(\d+)'){$major=[int]$Matches[1]}
    if($major -ge 17){$checks.Add((New-FSCheck Java Ready 'Java meets Maestro minimum; local Firebase uses a dedicated JDK 21.' '' "$major"))}
    else{$checks.Add((New-FSCheck Java Outdated 'Maestro requires Java 17+.' 'Install supported JDK, then restart terminal.' "$major"))}
  }else{$checks.Add((New-FSCheck Java Failed 'Could not parse Java version.' 'Run java -version and check installation.'))}
}else{$checks.Add((New-FSCheck Java Missing 'Java is not installed.' 'Mobile setup will install a suitable JDK.'))}
# Maintainer DEV cloud identity is intentionally not enabled by PR #3.
$demoCheck=@($checks | Where-Object {$_.Id -eq 'DemoConfig'})
$emulatorCheck=@($checks | Where-Object {$_.Id -eq 'EmulatorOnline'})
if($demoCheck.Count -gt 0 -and $emulatorCheck.Count -gt 0 -and $demoCheck[0].Status -eq 'Ready' -and $emulatorCheck[0].Status -eq 'Ready'){
  $checks.Add((New-FSCheck EmulatorWiring ConfiguredNotConnected 'Emulator ports and demo configuration detected; Flutter app handshake is still required.' 'Launch launchers\windows\4 - Run app with practice Firebase.cmd and verify successful local sign-in.'))
}else{
  $checks.Add((New-FSCheck EmulatorWiring ConfiguredNotConnected 'Demo Firebase configuration or running emulators are missing.' 'Start launchers\windows\3 - Start practice Firebase.cmd and the local Flutter app.'))
}
$checks.Add((New-FSCheck DevCloudIdentity AuthRequired 'Maintainer DEV credentials are not configured in the default bootstrap.' 'Request separately authorized DEV-only IAM when needed; do not use PROD credentials.'))
$config=Join-Path $root '.vscode\mcp.json'
if(Test-Path -LiteralPath $config) {
  try {
    $mcp=Get-Content -LiteralPath $config -Raw|ConvertFrom-Json
    foreach($id in @('dart','playwright','context7')){
      if($mcp.servers.PSObject.Properties.Name -contains $id){
        $checks.Add((New-FSCheck "MCP:$id" ConfiguredNotConnected 'MCP is declared, but tools/list handshake was not performed.' 'Start the MCP in VS Code and verify tools/list before claiming Ready.'))
      }else{$checks.Add((New-FSCheck "MCP:$id" Missing 'MCP declaration is missing.' 'Restore .vscode/mcp.json from the approved Git branch.'))}
    }
    if($mcp.servers.PSObject.Properties.Name -contains 'firebase'){
      $checks.Add((New-FSCheck 'CloudFirebaseMCP' Failed 'Default cloud Firebase MCP violates security policy.' 'Remove Firebase MCP from all default configs.'))
    }
  }catch{$checks.Add((New-FSCheck 'MCPConfig' Failed 'MCP configuration could not be parsed.' 'Restore the approved .vscode/mcp.json.'))}
}else{$checks.Add((New-FSCheck 'MCPConfig' Missing 'VS Code MCP configuration is absent.' 'Use the complete Git clone; check that .vscode/mcp.json exists.'))}
$results=@($checks.ToArray())
$exit=Get-FSExitCode $TargetProfile $results
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add("Forged & Sent environment check | Profile: $TargetProfile | Result: $(if($exit){'NEEDS REPAIR'}else{'INSTALL CHECKS PASSED'})")
$lines.Add('INSTALL CHECKS PASSED covers installed tools; real emulator app calls, GitHub auth, devices and MCP handshakes must be tested separately.')
$lines.Add('No usernames, filesystem paths, tokens or Firebase project IDs are included in the report body.')
if($results | Where-Object { $_.Status -eq 'NotApplicable' -and (Get-FSNeed $TargetProfile $_.Id) -eq 'Required' }){$lines.Add('DEFERRED: This profile has unimplemented PR #4 capabilities; installation success is NOT full readiness.')}
$lines.Add('')
foreach($c in $results){
  $need=Get-FSNeed $TargetProfile $c.Id
  $lines.Add("[$($c.Status)] $($c.Id) | $need$(if($c.Version){" | Version $($c.Version)"})")
  if($c.Status -ne 'Ready'){$lines.Add(" WHY: $($c.Reason)");$lines.Add(" FIX: $($c.Fix)")}
}
$lines | ForEach-Object {Write-Host $_}
$lines | Set-Content -LiteralPath $report -Encoding UTF8
$ai=New-Object System.Collections.Generic.List[string]
$ai.Add("Help me fix Forged & Sent Windows onboarding for the $TargetProfile profile.")
$ai.Add('Suggest safe, simple steps. Do not request secrets, admin bypass or production Firebase credentials.')
foreach($c in $results){
  if($c.Status -ne 'Ready' -and $c.Status -ne 'NotApplicable'){
    $need=Get-FSNeed $TargetProfile $c.Id
    $ai.Add("ISSUE $($c.Id) ($need, $($c.Status)): $($c.Reason)")
    $ai.Add("FIX: $($c.Fix)")
  }
}
$ai | Set-Content -LiteralPath $aiReport -Encoding UTF8
Write-Host "Diagnostic file: $report"
Write-Host "AI help prompt: $aiReport"
exit $exit
