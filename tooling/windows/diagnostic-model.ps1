#requires -Version 5.1
# Profile state model only. Full profile-specific installation is PR #4.
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
function Get-FSExitCode {
  param([ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile,[object[]]$Checks)
  foreach($c in $Checks) {
    if((Get-FSNeed $TargetProfile $c.Id) -eq 'Required' -and $c.Status -notin @('Ready','NotApplicable')){return 1}
  }
  return 0
}
