#requires -Version 5.1
# Non-destructive workstation diagnostics. Does not install, authenticate or deploy.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$report=Join-Path $env:TEMP ('ForgedAndSent-developer-check-{0:yyyyMMdd-HHmmss}.txt' -f (Get-Date))
$issues=New-Object System.Collections.Generic.List[string]
$lines=New-Object System.Collections.Generic.List[string]
$env:Path+=';' + (Join-Path $env:APPDATA 'npm') + ';' + (Join-Path $env:USERPROFILE 'develop\flutter\bin')
function Check([string]$name,[string]$command,[string[]]$locations=@()){
  $found=Get-Command $command -ErrorAction SilentlyContinue | Select-Object -First 1
  $path=if($found){$found.Source}else{$locations|Where-Object{$_ -and (Test-Path -LiteralPath $_)}|Select-Object -First 1}
  if($path){$lines.Add("[OK] $name : $path")}else{
    $lines.Add("[MISSING] $name");$issues.Add($name)
  }
}
Check 'Git' 'git.exe' @((Join-Path $env:ProgramFiles 'Git\cmd\git.exe'))
Check 'Flutter' 'flutter.bat' @((Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'))
Check 'VS Code' 'code.cmd' @((Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),(Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'))
Check 'Node.js' 'node.exe' @((Join-Path $env:ProgramFiles 'nodejs\node.exe'))
Check 'npm' 'npm.cmd' @((Join-Path $env:ProgramFiles 'nodejs\npm.cmd'))
Check 'Firebase CLI' 'firebase.cmd' @((Join-Path $env:APPDATA 'npm\firebase.cmd'))
Check 'GitHub CLI' 'gh.exe' @((Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe'))
Check 'Codex CLI' 'codex.cmd' @((Join-Path $env:APPDATA 'npm\codex.cmd'))
Check 'Claude CLI' 'claude.exe' @((Join-Path $env:USERPROFILE '.local\bin\claude.exe'))
$code=Get-Command code.cmd -ErrorAction SilentlyContinue | Select-Object -First 1
if(-not $code){
  foreach($p in @((Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),(Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'))){
    if(Test-Path -LiteralPath $p){$code=[pscustomobject]@{Source=$p};break}
  }
}
if($code){
  try{
    $installed=@(& $code.Source --list-extensions)
    foreach($name in @('Dart-Code.dart-code','Dart-Code.flutter','GitHub.copilot-chat','OpenAI.chatgpt','Anthropic.claude-code')){
      if($installed|Where-Object{$_ -ieq $name}){$lines.Add("[OK] Extension $name")}
      else{$lines.Add("[MISSING] Extension $name");$issues.Add("Extension $name")}
    }
  }catch{$lines.Add('[WARN] Could not read installed VS Code extensions')}
}
$config=Join-Path $root '.vscode\mcp.json'
if(Test-Path -LiteralPath $config){
  try{
    $settings=Get-Content -LiteralPath $config -Raw|ConvertFrom-Json
    foreach($name in @('dart','firebase','playwright','github')){
      if($settings.servers.PSObject.Properties.Name -contains $name){
        $lines.Add("[CONFIGURED] MCP $name (NOT a live connection test)")
      }else{$lines.Add("[MISSING] MCP $name");$issues.Add("MCP $name")}
    }
    if($settings.servers.github.url -notmatch '/readonly$'){
      $issues.Add('GitHub MCP must be read-only')
    }
  }catch{$lines.Add('[ERROR] Invalid MCP configuration JSON');$issues.Add('MCP configuration')}
}else{$lines.Add('[MISSING] .vscode\mcp.json');$issues.Add('MCP configuration')}
$lines.Add('')
$lines.Add('No automatic accounts, permissions, cloud deploys, or server connections were performed.')
$lines.Add("Missing / failed checks: $($issues.Count)")
$lines | ForEach-Object{Write-Host $_}
$lines | Set-Content -LiteralPath $report -Encoding UTF8
Write-Host "Diagnostic report saved: $report"
if($issues.Count){exit 1}
exit 0
