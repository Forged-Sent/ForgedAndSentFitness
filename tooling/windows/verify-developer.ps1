#requires -Version 5.1
# Read-only diagnostics. Outputs a secret-free AI troubleshooting prompt.
param([switch]$SelfTest)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$report=Join-Path $env:TEMP "ForgedAndSent-Diagnostics-$stamp.txt"
$aiReport=Join-Path $env:TEMP "ForgedAndSent-AskAI-$stamp.txt"
$issues=New-Object System.Collections.Generic.List[object]
$ok=New-Object System.Collections.Generic.List[string]
$pending=New-Object System.Collections.Generic.List[string]
$env:Path += ';' + (Join-Path $env:APPDATA 'npm') + ';' + (Join-Path $env:USERPROFILE 'develop\flutter\bin') + ';' + (Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin')

function Issue([string]$id,[string]$why,[string]$fix,[string]$kind='MISSING'){
  $issues.Add([pscustomobject]@{Code=$id;Why=$why;Fix=$fix;Status=$kind})
}
function CheckTool([string]$id,[string]$exe,[string[]]$alternates,[string]$why,[string]$fix) {
  $found=Get-Command $exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if(-not $found){foreach($p in $alternates){if($p -and (Test-Path -LiteralPath $p)){$found=$p;break}}}
  if($found){$ok.Add($id)}else{Issue $id $why $fix}
}
function HelpFor([string]$id) {
  switch($id) {
    'Java17' {return 'Maestro requires Java 17+. Run full developer setup again; it installs Temurin JDK. Restart Windows afterward.'}
    'Maestro' {return 'Maestro CLI is not on PATH. Run the developer setup again and verify Java 17. Android device/emulator is separately required for UI testing.'}
    'GoogleKnowledgeAuth' {return 'Google Developer Knowledge requires a personal Google Cloud API key, an enabled Developer Knowledge API, and account permissions. In VS Code, start the MCP server and enter your key when prompted. Never put the key in Git or AI chat.'}
    'FigmaAuth' {return 'Figma MCP requires a Figma login. In VS Code > MCP: List Servers, start Figma, then authorize it in the browser.'}
    'GitHubAuth' {return 'Run gh auth login, then authorize the read-only GitHub MCP in VS Code. Do not share GitHub tokens.'}
    'FirebaseAuth' {return 'Run firebase login, confirm access to the team DEV Firebase project, and approve the MCP only for DEV. Do not deploy to production.'}
    default {return 'See the issue instructions and docs/development/FIRST-RUN-TROUBLESHOOTING.md. Rerun the installer after resolving the issue.'}
  }
}
if($SelfTest){
  Issue 'Maestro' 'The Maestro executable was not found.' (HelpFor 'Maestro')
  Issue 'GoogleKnowledgeAuth' 'The Google Developer Knowledge MCP has not been authenticated.' (HelpFor 'GoogleKnowledgeAuth') 'ACTION'
}else {
  CheckTool 'Git' 'git.exe' @((Join-Path $env:ProgramFiles 'Git\cmd\git.exe')) 'Git is required for Flutter and repository changes.' 'Rerun SETUP-DEVELOPER-WINDOWS.cmd; if WinGet is blocked, request access from IT.'
  CheckTool 'Flutter' 'flutter.bat' @((Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat')) 'Flutter SDK is missing or its bin folder is not on PATH.' 'Run SETUP-WINDOWS.cmd, restart terminals, then retry.'
  CheckTool 'VSCode' 'code.cmd' @((Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),(Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd')) 'VS Code is required for the supported agent/MCP workspace.' 'Rerun setup, then restart VS Code.'
  CheckTool 'Node' 'node.exe' @((Join-Path $env:ProgramFiles 'nodejs\node.exe')) 'Node.js LTS runs the Firebase and Playwright MCP tools.' 'Rerun developer setup to install Node.js LTS; restart Windows after installation.'
  CheckTool 'Npm' 'npm.cmd' @((Join-Path $env:ProgramFiles 'nodejs\npm.cmd')) 'npm is provided by Node.js and is required for JavaScript MCP runtimes.' 'Reinstall Node.js LTS, then restart Windows.'
  CheckTool 'FirebaseCLI' 'firebase.cmd' @((Join-Path $env:APPDATA 'npm\firebase.cmd')) 'Firebase CLI is not installed; the Firebase MCP runtime cannot launch.' 'Rerun developer setup or run npm install -g firebase-tools in a trusted terminal.'
  CheckTool 'GitHubCLI' 'gh.exe' @((Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe')) 'GitHub CLI is missing; GitHub sign-in/PR workflows are unavailable.' 'Rerun developer setup to install GitHub CLI.'
  CheckTool 'CodexCLI' 'codex.cmd' @((Join-Path $env:APPDATA 'npm\codex.cmd')) 'Codex CLI could not be found; VS Code extension may still work.' 'Rerun developer setup or install the official Codex CLI after reviewing its sign-in requirements.'
  CheckTool 'ClaudeCLI' 'claude.exe' @((Join-Path $env:USERPROFILE '.local\bin\claude.exe')) 'Claude CLI could not be found; VS Code extension may still work.' 'Rerun developer setup. If the WinGet package is unavailable, follow the official Claude Code installer.'
  CheckTool 'Maestro' 'maestro.bat' @((Join-Path $env:LOCALAPPDATA 'Programs\Maestro\bin\maestro.bat')) 'Maestro CLI is missing, so Android/iOS UI automation MCP cannot start.' (HelpFor 'Maestro')
  $j=Get-Command java.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if($j){
    $line=(& $j.Source -version 2>&1 | Out-String)
    if($line -match 'version "(\d+)'){
      $ver=[int]$Matches[1]
      if($ver -eq 1 -and $line -match 'version "1\.(\d+)'){$ver=[int]$Matches[1]}
      if($ver -ge 17){$ok.Add('Java17')}else{Issue 'Java17' "Java $ver is too old for Maestro." (HelpFor 'Java17')}
    }elseif($line -match 'openjdk (\d+)'){
      if([int]$Matches[1] -ge 17){$ok.Add('Java17')}else{Issue 'Java17' 'Java is older than 17.' (HelpFor 'Java17')}
    }else{Issue 'Java17' 'Java version could not be determined.' (HelpFor 'Java17')}
  }else{Issue 'Java17' 'Java was not found.' (HelpFor 'Java17')}

  $code=Get-Command code.cmd -ErrorAction SilentlyContinue|Select-Object -First 1
  if(-not $code){
    foreach($p in @((Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),(Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'))){
      if(Test-Path -LiteralPath $p){$code=[pscustomobject]@{Source=$p};break}
    }
  }
  if($code){
    try{
      $ext=@(& $code.Source --list-extensions)
      foreach($id in @('Dart-Code.dart-code','Dart-Code.flutter','GitHub.copilot-chat','OpenAI.chatgpt','Anthropic.claude-code')){
        if($ext | Where-Object {$_ -ieq $id}){$ok.Add("Extension:$id")}
        else{Issue "Extension:$id" "VS Code extension $id is not installed." "Rerun developer setup or install $id from VS Code Extensions."}
      }
    }catch{Issue 'VSCodeExtensions' 'Could not query VS Code extensions.' 'Restart VS Code and rerun diagnostics.'}
  }

  $cfg=Join-Path $root '.vscode\mcp.json'
  if(Test-Path -LiteralPath $cfg){
    try{
      $doc=Get-Content -LiteralPath $cfg -Raw|ConvertFrom-Json
      foreach($name in @('dart','firebase','playwright','github','context7','figma','maestro','google-developer-knowledge')){
        if($doc.servers.PSObject.Properties.Name -contains $name){$ok.Add("MCPConfig:$name")}
        else{Issue "MCPConfig:$name" "MCP $name is not listed in the workspace configuration." 'Download the complete PR branch ZIP or pull the latest feature branch.'}
      }
      if($doc.servers.github.url -notmatch '/readonly$'){Issue 'GitHubMcpWrite' 'GitHub MCP was not configured read-only.' 'Replace the GitHub MCP URL with the approved /mcp/readonly endpoint.'}
      if($doc.servers.PSObject.Properties.Name -contains 'sentry'){Issue 'UnexpectedSentry' 'Sentry was enabled against the agreed configuration.' 'Remove Sentry from the MCP list.'}
    }catch{Issue 'MCPJson' 'The VS Code MCP file is not valid JSON.' 'Restore .vscode/mcp.json from the branch and avoid pasting API keys into it.'}
  }else{Issue 'MCPJson' 'The repository MCP file is missing.' 'Download and extract the complete feature branch, not just the setup CMD.'}

  $pending.Add('GoogleKnowledgeAuth: needs a user-supplied Google Cloud API key and the API enabled.')
  $pending.Add('FigmaAuth: needs Figma OAuth authorization in VS Code.')
  $pending.Add('GitHubAuth: needs GitHub OAuth approval for the read-only MCP.')
  $pending.Add('FirebaseAuth: needs DEV Firebase account authorization and project selection.')
  $pending.Add('MaestroDevice: requires Android Studio/emulator or physical Android device to test mobile UI.')
  $pending.Add('MCPConnections: static configuration is not a live protocol handshake; test each inside VS Code.')
}
$reportLines=New-Object System.Collections.Generic.List[string]
$reportLines.Add('Forged & Sent - Developer workstation diagnostic')
$reportLines.Add('This report contains no token values, user names, local file paths, or private Firebase project IDs.')
$reportLines.Add('')
$reportLines.Add("Installed/configured checks passed: $($ok.Count)")
$reportLines.Add("Unresolved prerequisites: $($issues.Count)")
$reportLines.Add('')
foreach($issue in $issues){
  $reportLines.Add("[$($issue.Status)] $($issue.Code)")
  $reportLines.Add(" WHY: $($issue.Why)")
  $reportLines.Add(" FIX: $($issue.Fix)")
}
$reportLines.Add('')
foreach($p in $pending){$reportLines.Add("[SIGN-IN / LIVE CHECK] $p")}
$reportLines | ForEach-Object {Write-Host $_}
$reportLines|Set-Content -LiteralPath $report -Encoding UTF8
$prompt=New-Object System.Collections.Generic.List[string]
$prompt.Add('Help me repair my Forged & Sent Windows development environment.')
$prompt.Add('We use Flutter, VS Code, Firebase DEV, and Dart/Firebase/Playwright/GitHub/Context7/Figma/Maestro/Google Developer Knowledge MCP.')
$prompt.Add('Do not request secrets or ask me to disable security. Give me simple ordered fixes and commands, one at a time.')
$prompt.Add('These statuses came from a local checker, NOT successful MCP handshake tests:')
foreach($issue in $issues){
  $prompt.Add("ISSUE $($issue.Code): $($issue.Why)")
  $prompt.Add("SUGGESTED FIX: $($issue.Fix)")
}
foreach($p in $pending){$prompt.Add("TO VERIFY LATER: $p")}
$prompt.Add('Ask me for the next error message only after I have removed any tokens, personal details, or project secrets.')
$prompt|Set-Content -LiteralPath $aiReport -Encoding UTF8
Write-Host ''
Write-Host "Diagnostic file: $report"
Write-Host "Safe-to-paste AI help prompt: $aiReport" -ForegroundColor Cyan
if($SelfTest){
  if((Get-Content $aiReport -Raw) -notmatch 'ISSUE Maestro:'){throw 'SelfTest: missing issue'}
  if((Get-Content $report -Raw) -notmatch 'WHY:'){throw 'SelfTest: missing explanation'}
  Write-Host 'Self-test passed.'
  exit 0
}
if($issues.Count){exit 1}
exit 0
