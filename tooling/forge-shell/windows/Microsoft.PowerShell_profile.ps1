# Forge Shell bootstrap. Safe to dot-source repeatedly; no network or package installation.
if ($env:FORGE_DISABLE -eq '1' -or $PSVersionTable.PSVersion -lt [version]'7.5' -or -not [Environment]::Is64BitProcess) { return }
try {
    Import-Module (Join-Path $PSScriptRoot 'modules\Forge\Forge.psd1') -Global -DisableNameChecking -ErrorAction Stop
} catch {
    # Keep a usable shell; diagnostic deliberately omits exception text and command contents.
    $global:ForgeStartupProblem = 'Forge could not load. Start pwsh -NoProfile, then run .config/powershell/tests/Validate.ps1.'
}
