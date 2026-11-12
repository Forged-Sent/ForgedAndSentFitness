#requires -Version 7.6
# Optional user shell entrypoint. The wizard uses forge-shell-functions.ps1.
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Offer,
    [switch]$Apply,
    [ValidateSet('None','Terminal','TerminalAndVSCode')][string]$Style='None',
    [switch]$Tools,
    [switch]$SelfTest,
    [string]$InstallRoot=(Join-Path $HOME '.config\powershell'),
    [string]$ProfilePath=$PROFILE.CurrentUserAllHosts,
    [string]$ProjectRoot=(Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

. (Join-Path $PSScriptRoot 'forge-shell-functions.ps1')

if($MyInvocation.InvocationName -eq '.'){return}
if($SelfTest){
    $bundle=Join-Path $PSScriptRoot '..\forge-shell\windows'
    if(-not (Test-Path -LiteralPath (Join-Path $bundle 'Install.ps1'))){throw 'Windows shell package missing.'}
    & (Join-Path $bundle 'scripts\Build-Module.ps1') -Check
    Write-Host 'Optional Windows shell self-test passed (no changes made).'
    exit 0
}
if($Offer){
    $selection=Select-FSEngineeringShell
    if(-not $selection.Apply){Write-Host 'Optional shell skipped. You can add it later from More options > 6.';exit 0}
    $Apply=$true;$Style=$selection.Style;$Tools=$selection.Tools
}
if(-not $Apply){
    Write-Host 'Preview only. Use -Offer for the optional wizard, or -Apply to install the core shell.'
    Write-Host "Package: $InstallRoot | PowerShell profile: $ProfilePath | Project: $ProjectRoot"
    exit 0
}
Install-FSEngineeringShell -InstallRoot $InstallRoot -ProfilePath $ProfilePath -ProjectRoot $ProjectRoot -Style $Style -Tools:$Tools -WhatIf:$WhatIfPreference
