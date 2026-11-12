param([string]$PackageRoot,[string]$State,[string]$Text)
$ErrorActionPreference='Stop'
$env:FORGE_HOME=$State;$env:FORGE_NO_EDITING='1'
Import-Module (Join-Path $PackageRoot 'modules\Forge\Forge.psd1') -DisableNameChecking
todo $Text
