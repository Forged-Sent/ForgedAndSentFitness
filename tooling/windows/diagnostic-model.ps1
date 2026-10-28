#requires -Version 5.1
# Profile state model only. Full profile-specific installation is PR #4.
Set-StrictMode -Version Latest
$script:FSProfiles=@{
  Preview=@('PowerShell7','Git','Chrome','Flutter')
  Contributor=@('PowerShell7','Git','Chrome','Flutter','VSCode','Node','Npm','GitHubCLI','FirebaseCLI','EmulatorWiring')
  Mobile=@('PowerShell7','Git','Chrome','Flutter','VSCode','Node','Npm','GitHubCLI','FirebaseCLI','EmulatorWiring','AndroidStudio','Maestro','Java')
  Maintainer=@('PowerShell7','Git','Chrome','Flutter','VSCode','Node','Npm','GitHubCLI','FirebaseCLI','EmulatorWiring','DevCloudIdentity')
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
function Get-FSExitCode {
  param([ValidateSet('Preview','Contributor','Mobile','Maintainer')][string]$TargetProfile,[object[]]$Checks)
  foreach($c in $Checks) {
    if((Get-FSNeed $TargetProfile $c.Id) -eq 'Required' -and $c.Status -ne 'Ready'){return 1}
  }
  return 0
}
