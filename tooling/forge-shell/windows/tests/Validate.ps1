#requires -Version 7.5
[CmdletBinding()]
param([switch]$KeepArtifacts)
$root=Split-Path -Parent $PSScriptRoot
$engine=Join-Path $PSHOME 'pwsh.exe'
$arguments=@('-NoLogo','-NoProfile','-NonInteractive','-File',(Join-Path $PSScriptRoot 'Cases.ps1'),'-PackageRoot',$root)
if($KeepArtifacts){$arguments+='-KeepArtifacts'}
& $engine @arguments
if($LASTEXITCODE -ne 0){throw 'Forge validation failed. See the failing check above.'}
