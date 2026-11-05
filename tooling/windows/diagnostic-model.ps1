#requires -Version 5.1
# Profile state model shared by setup, Check my setup and the wizard.
Set-StrictMode -Version Latest
$script:FSProfiles=@{
  Preview=@('PowerShell7','Git','Chrome','Flutter','VSCode')
  Contributor=@('PowerShell7','Git','Chrome','Flutter','VSCode','Node','Npm','GitHubCLI','FirebaseCLI','FlutterFireCLI','Java21','GitRepo','DemoConfig','Python','GitIdentity')
  Mobile=@('PowerShell7','Git','Chrome','Flutter','VSCode','Node','Npm','GitHubCLI','FirebaseCLI','FlutterFireCLI','Java21','GitRepo','DemoConfig','Python','GitIdentity','AndroidStudio','Maestro','AndroidDevice')
  Maintainer=@('PowerShell7','Git','Chrome','Flutter','VSCode','Node','Npm','GitHubCLI','FirebaseCLI','FlutterFireCLI','Java21','GitRepo','DemoConfig','Python','GitIdentity','AndroidStudio','Maestro','AndroidDevice','DevCloudIdentity')
}
$script:FSStatuses=@('Ready','Missing','Outdated','ConfiguredNotConnected','AuthRequired','PermissionDenied','NotApplicable','Failed')
function New-FSCheck {
  param([string]$Id,[ValidateSet('Ready','Missing','Outdated','ConfiguredNotConnected','AuthRequired','PermissionDenied','NotApplicable','Failed')][string]$Status,[string]$Reason,[string]$Fix,[string]$Version='')
  return [pscustomobject]@{ Id=$Id;Status=$Status;Reason=$Reason;Fix=$Fix;Version=$Version }
}
function Get-FSNeed {
  param([ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile,[string]$Id)
  if($script:FSProfiles[$TargetProfile] -contains $Id){return 'Required'}
  return 'Optional'
}
# The wizard remembers the last chosen profile inside this clone's private Git
# directory (never committed, never global) so "Check my setup" grades a
# returning Contributor as a Contributor, not as Preview.
function Get-FSProfileFile([string]$Root){
  try{
    $gitDir=(& git -C $Root rev-parse --absolute-git-dir 2>$null | Out-String).Trim()
    if($LASTEXITCODE -ne 0 -or -not $gitDir){return $null}
    return (Join-Path $gitDir 'forged-sent-profile')
  }catch{return $null}
}
function Save-FSProfile([string]$Root,[ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile){
  $file=Get-FSProfileFile $Root
  if($file){try{Set-Content -LiteralPath $file -Value $TargetProfile -Encoding ascii}catch{}}
}
function Get-FSRememberedProfile([string]$Root,[ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$Fallback='Preview'){
  $file=Get-FSProfileFile $Root
  if($file -and (Test-Path -LiteralPath $file)){
    $saved=((Get-Content -LiteralPath $file -TotalCount 1 -ErrorAction SilentlyContinue) | Out-String).Trim()
    if($saved -and $script:FSProfiles.ContainsKey($saved)){return $saved}
  }
  return $Fallback
}
# Every program the setup check starts gets a closed input and a time limit. Output is
# captured (so it is invisible), so a first-run question such as the Python install
# manager's welcome prompt would otherwise wait forever for an answer nobody can see.
function Invoke-FSProbe([string]$file,[string[]]$arguments=@(),[int]$timeoutMs=15000){
  try{
    $psi=New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName=$file
    $psi.Arguments=(@($arguments | ForEach-Object { if($_ -match '[\s"]'){'"'+($_ -replace '"','\"')+'"'}else{$_} }) -join ' ')
    $psi.UseShellExecute=$false
    $psi.CreateNoWindow=$true
    $psi.RedirectStandardInput=$true
    $psi.RedirectStandardOutput=$true
    $psi.RedirectStandardError=$true
    $proc=[System.Diagnostics.Process]::Start($psi)
    # Close input at once: a hidden prompt reads end-of-input and takes its default.
    try{$proc.StandardInput.Close()}catch{}
    $stdout=$proc.StandardOutput.ReadToEndAsync()
    $stderr=$proc.StandardError.ReadToEndAsync()
    if(-not $proc.WaitForExit($timeoutMs)){
      try{$proc.Kill()}catch{}
      return [pscustomobject]@{TimedOut=$true;ExitCode=-1;Text=''}
    }
    $proc.WaitForExit()
    return [pscustomobject]@{TimedOut=$false;ExitCode=[int]$proc.ExitCode;Text=($stdout.Result+"`n"+$stderr.Result)}
  }catch{return [pscustomobject]@{TimedOut=$false;ExitCode=-1;Text=''}}
}
# One JDK 21 search shared by "Check my setup" (verify-developer.ps1) and the
# installer/emulator launcher (ensure-java21.ps1), so they can never disagree.
# Order: JAVA_HOME, java on PATH, Eclipse Adoptium jdk-21*. JAVA_HOME and PATH are
# only read, never changed; an older JAVA_HOME can stay for other projects.
function Get-FSJavaMajor([string]$javaExe){
  if(-not $javaExe -or -not (Test-Path -LiteralPath $javaExe)){return 0}
  $text=(Invoke-FSProbe $javaExe @('-version')).Text
  if($text -match '(?:version|openjdk)\s+"?(\d+)(?:\.(\d+))?'){
    $major=[int]$Matches[1]
    if($major -eq 1 -and $Matches[2]){$major=[int]$Matches[2]}
    return $major
  }
  return 0
}
function Find-FSJava21 {
  $candidates=New-Object System.Collections.Generic.List[string]
  if($env:JAVA_HOME){$candidates.Add((Join-Path $env:JAVA_HOME 'bin\java.exe'))}
  $onPath=Get-Command java.exe -ErrorAction SilentlyContinue|Select-Object -First 1
  if($onPath){$candidates.Add($onPath.Source)}
  if($env:ProgramFiles){
    $adoptium=Join-Path $env:ProgramFiles 'Eclipse Adoptium'
    if(Test-Path -LiteralPath $adoptium){
      foreach($dir in @(Get-ChildItem -LiteralPath $adoptium -Directory -Filter 'jdk-21*' -ErrorAction SilentlyContinue|Sort-Object Name -Descending)){
        $candidates.Add((Join-Path $dir.FullName 'bin\java.exe'))
      }
    }
  }
  $best=$null
  foreach($exe in $candidates){
    $major=Get-FSJavaMajor $exe
    if($major -le 0){continue}
    $found=[pscustomobject]@{Home=(Split-Path (Split-Path $exe -Parent) -Parent);Major=$major;Exe=$exe}
    if($major -ge 21){return $found}
    if(-not $best -or $major -gt $best.Major){$best=$found}
  }
  return $best
}
# Extras that only matter for a bigger profile, or for an assistant the person did
# not pick. When they are not Ready they are listed on one line instead of with
# WHY/FIX, so a finished Contributor setup does not look broken.
$script:FSExtras=@('AndroidStudio','Maestro','AndroidDevice','Java','DevCloudIdentity','ClaudeCLI','CodexCLI','AntigravityCLI')
function Test-FSNotInProfile {
  param([ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile,[string]$Id)
  if($script:FSExtras -notcontains $Id){return $false}
  if($script:FSProfiles[$TargetProfile] -contains $Id){return $false}
  if($Id -eq 'Java' -and $TargetProfile -in @('Mobile','Maintainer')){return $false}
  return $true
}
function Get-FSExitCode {
  param([ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile,[object[]]$Checks)
  foreach($c in $Checks) {
    if((Get-FSNeed $TargetProfile $c.Id) -eq 'Required' -and $c.Status -notin @('Ready','NotApplicable')){return 1}
  }
  return 0
}
