#requires -Version 5.1
# Read-only, profile-aware diagnostics. Does NOT authenticate or contact cloud MCPs.
param(
  [ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$Profile='Contributor',
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
Check Git git.exe @((Join-Path $env:ProgramFiles 'Git\cmd\git.exe')) 'Run SETUP-WINDOWS.cmd, then restart the terminal.'
Check Chrome chrome.exe @((Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),(Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')) 'Run SETUP-WINDOWS.cmd to install Chrome.'
Check Flutter flutter.bat @((Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat')) 'Run SETUP-WINDOWS.cmd, then check flutter doctor.'
Check VSCode code.cmd @((Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),(Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd')) 'Install VS Code with SETUP-DEVELOPER-WINDOWS.cmd.'
Check Node node.exe @((Join-Path $env:ProgramFiles 'nodejs\node.exe')) 'Run developer setup for Node.js LTS.'
Check Npm npm.cmd @((Join-Path $env:ProgramFiles 'nodejs\npm.cmd')) 'Reinstall Node.js LTS, then restart Windows.'
Check GitHubCLI gh.exe @((Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe')) 'Run developer setup for GitHub CLI.'
Check FirebaseCLI firebase.cmd @((Join-Path $env:APPDATA 'npm\firebase.cmd')) 'Run developer setup for local Firebase CLI. No Firebase login required for Preview.'
# Contributor profiles require a real clone, local SDK/CLI and running emulators.
$gitFolder=Join-Path $root '.git'
if(Test-Path -LiteralPath $gitFolder){
  $checks.Add((New-FSCheck GitRepo Ready 'This is a Git clone.' ''))
}else{$checks.Add((New-FSCheck GitRepo Missing 'This folder was extracted from ZIP; it cannot create PRs.' 'Use wizard option 10 to clone the repository.'))}
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
$javaHome=[Environment]::GetEnvironmentVariable('JAVA_HOME','User')
$javaPath=if($javaHome){Join-Path $javaHome 'bin\java.exe'}else{''}
if($javaPath -and (Test-Path -LiteralPath $javaPath)){
  $javaText=(& cmd.exe /c ('"'+$javaPath+'" -version 2>&1')|Out-String)
  if($javaText -match '(?:version|openjdk)\s+"?(\d+)'){
    $javaMajor=[int]$Matches[1]
    if($javaMajor -ge 21){$checks.Add((New-FSCheck Java21 Ready 'JDK 21+ is installed.' '' "$javaMajor"))}
    else{$checks.Add((New-FSCheck Java21 Outdated 'JDK 21+ is required.' 'Run the Contributor setup JDK installer.' "$javaMajor"))}
  }else{$checks.Add((New-FSCheck Java21 Failed 'Could not read JAVA_HOME Java version.' 'Rerun Contributor setup.'))}
}else{$checks.Add((New-FSCheck Java21 Missing 'Java 21 not detected in the user development profile.' 'Run Contributor setup; restart Windows if needed.'))}
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
  $checks.Add((New-FSCheck EmulatorOnline ConfiguredNotConnected 'Local emulator ports are not all reachable.' 'Run START-EMULATORS-WINDOWS.cmd. Check ports 8080, 9099, 9199.'))
}else{
  $checks.Add((New-FSCheck EmulatorOnline Ready 'Local Auth/Firestore/Storage TCP ports respond; app integration still needs a real UI test.' ''))
}
$gh=Get-Command gh.exe -ErrorAction SilentlyContinue|Select-Object -First 1
if($gh){
  $null=& $gh.Source auth status 2>&1
  if($LASTEXITCODE -eq 0){$checks.Add((New-FSCheck GitHubAuth Ready 'GitHub CLI account is authenticated.' ''))}
  else{$checks.Add((New-FSCheck GitHubAuth AuthRequired 'GitHub account not authorized for draft PRs.' 'Run wizard option 4 to sign in.'))}
}else{$checks.Add((New-FSCheck GitHubAuth Missing 'GitHub CLI missing.' 'Run Contributor setup.'))}
$checks.Add((New-FSCheck AndroidDevice ConfiguredNotConnected 'A native Android device and Maestro flow were not run by this diagnostic.' 'Run flutter devices and one Maestro flow on an emulator or phone.'))
Check Maestro maestro.bat @((Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin\maestro.bat')) 'Run setup for mobile testing. Java and a phone/emulator are required.'
Check AndroidStudio studio64.exe @((Join-Path $env:ProgramFiles 'Android\Android Studio\bin\studio64.exe')) 'Run SETUP-ANDROID.cmd and complete the Android SDK setup wizard.'
Check ClaudeCLI claude.exe @((Join-Path $env:USERPROFILE '.local\bin\claude.exe')) 'Optional: run the developer setup or use VS Code extension.'
Check CodexCLI codex.cmd @((Join-Path $env:APPDATA 'npm\codex.cmd')) 'Optional: run developer setup or use Codex VS Code extension.'
$pwsh=(Get-Command pwsh.exe -ErrorAction SilentlyContinue|Select-Object -First 1)
$pwshPath=if($pwsh){$pwsh.Source}else{Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'}
if(Test-Path -LiteralPath $pwshPath){
  try {
    $vers=& $pwshPath -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()'
    $v=[version](([string]($vers|Select-Object -First 1)) -replace '-.*$','')
    if($v -ge [version]'7.6.0'){$checks.Add((New-FSCheck PowerShell7 Ready 'Version meets baseline.' '' $v.ToString()))}
    else{$checks.Add((New-FSCheck PowerShell7 Outdated 'PowerShell 7.6 LTS+ required.' 'Run FIRST-RUN-WINDOWS.cmd to update PowerShell.' $v.ToString()))}
  }catch{$checks.Add((New-FSCheck PowerShell7 Failed 'PowerShell 7 could not start.' 'Restart terminal or ask IT to repair PowerShell 7.'))}
}else{$checks.Add((New-FSCheck PowerShell7 Missing 'PowerShell 7 not found.' 'Run FIRST-RUN-WINDOWS.cmd to install it.'))}
$java=Get-Command java.exe -ErrorAction SilentlyContinue|Select-Object -First 1
if($java) {
  $verLine=(& cmd.exe /c 'java -version 2>&1'|Out-String)
  $found=[regex]::Match($verLine,'(?:version\s+["'']|openjdk\s+)(?<major>\d+)')
  if($found.Success){
    $major=[int]$found.Groups['major'].Value
    if($major -eq 1 -and $verLine -match '1\.(\d+)'){$major=[int]$Matches[1]}
    if($major -ge 17){$checks.Add((New-FSCheck Java Ready 'Java meets Maestro minimum; PR #4 will standardize JDK 21.' '' "$major"))}
    else{$checks.Add((New-FSCheck Java Outdated 'Maestro requires Java 17+.' 'Install supported JDK, then restart terminal.' "$major"))}
  }else{$checks.Add((New-FSCheck Java Failed 'Could not parse Java version.' 'Run java -version and check installation.'))}
}else{$checks.Add((New-FSCheck Java Missing 'Java is not installed.' 'Mobile setup will install a suitable JDK.'))}
# Maintainer DEV cloud identity is intentionally not enabled by PR #3.
$checks.Add((New-FSCheck DevCloudIdentity AuthRequired 'Maintainer DEV credentials are not configured in the default bootstrap.' 'PR #4 will add explicit restricted DEV access; do not use PROD credentials.'))
$config=Join-Path $root '.vscode\mcp.json'
if(Test-Path -LiteralPath $config) {
  try {
    $mcp=Get-Content -LiteralPath $config -Raw|ConvertFrom-Json
    foreach($id in @('dart','playwright','github','context7','figma','maestro','google-developer-knowledge')){
      if($mcp.servers.PSObject.Properties.Name -contains $id){
        $checks.Add((New-FSCheck "MCP:$id" ConfiguredNotConnected 'MCP is declared, but tools/list handshake was not performed.' 'Start the MCP in VS Code and verify tools/list before claiming Ready.'))
      }else{$checks.Add((New-FSCheck "MCP:$id" Missing 'MCP declaration is missing.' 'Restore .vscode/mcp.json from the approved PR.'))}
    }
    if($mcp.servers.PSObject.Properties.Name -contains 'firebase'){
      $checks.Add((New-FSCheck 'CloudFirebaseMCP' Failed 'Default cloud Firebase MCP violates security policy.' 'Remove Firebase MCP from all default configs.'))
    }
  }catch{$checks.Add((New-FSCheck 'MCPConfig' Failed 'MCP configuration could not be parsed.' 'Restore the approved .vscode/mcp.json.'))}
}else{$checks.Add((New-FSCheck 'MCPConfig' Missing 'VS Code MCP configuration is absent.' 'Extract the entire repository.'))}
$results=@($checks.ToArray())
$exit=Get-FSExitCode $Profile $results
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add("Forged & Sent environment check | Profile: $Profile | Result: $(if($exit){'NEEDS REPAIR'}else{'INSTALL CHECKS PASSED'})")
$lines.Add('ConfiguredNotConnected is NOT Ready. Local profile checks are advisory; only a real app/MCP handshake proves functionality.')
$lines.Add('No usernames, filesystem paths, tokens or Firebase project IDs are included below.')
$lines.Add('')
foreach($c in $results){
  $need=Get-FSNeed $Profile $c.Id
  $lines.Add("[$($c.Status)] $($c.Id) | $need$(if($c.Version){" | Version $($c.Version)"})")
  if($c.Status -ne 'Ready'){$lines.Add(" WHY: $($c.Reason)");$lines.Add(" FIX: $($c.Fix)")}
}
$lines | ForEach-Object {Write-Host $_}
$lines | Set-Content -LiteralPath $report -Encoding UTF8
$ai=New-Object System.Collections.Generic.List[string]
$ai.Add("Help me fix Forged & Sent Windows onboarding for the $Profile profile.")
$ai.Add('Suggest safe, simple steps. Do not request secrets, admin bypass or production Firebase credentials.')
foreach($c in $results){
  if($c.Status -ne 'Ready' -and $c.Status -ne 'NotApplicable'){
    $need=Get-FSNeed $Profile $c.Id
    $ai.Add("ISSUE $($c.Id) ($need, $($c.Status)): $($c.Reason)")
    $ai.Add("FIX: $($c.Fix)")
  }
}
$ai | Set-Content -LiteralPath $aiReport -Encoding UTF8
Write-Host "Diagnostic file: $report"
Write-Host "AI help prompt: $aiReport"
exit $exit
