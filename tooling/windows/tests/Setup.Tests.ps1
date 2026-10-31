BeforeAll {
  . "$PSScriptRoot/../winget.ps1"
  . "$PSScriptRoot/../diagnostic-model.ps1"
}
Describe 'WinGet return code classification' {
  It 'accepts installer success' { Get-FSWinGetOutcome 0 | Should -Be 'Installed' }
  It 'accepts WinGet update-not-applicable exit code' { Get-FSWinGetOutcome 0x8A15002B | Should -Be 'AlreadyPresent' }
  It 'requires restart for reboot-required code' { Get-FSWinGetOutcome 0x8A150109 | Should -Be 'RestartRequired' }
  It 'handles installation already-present codes' { Get-FSWinGetOutcome 0x8A15010D | Should -Be 'AlreadyPresent'; Get-FSWinGetOutcome 0x8A15010E | Should -Be 'AlreadyPresent' }
  It 'handles additional restart-needed codes' { Get-FSWinGetOutcome 0x8A15010B | Should -Be 'RestartRequired'; Get-FSWinGetOutcome 0x8A15010A | Should -Be 'RestartRequired' }
  It 'distinguishes no-applications-found' { Get-FSWinGetOutcome 0x8A150014 | Should -Be 'NoApplicationsFound' }
  It 'rejects unknown exit codes' { Get-FSWinGetOutcome 17 | Should -Be 'Failed' }
}
Describe 'Profile-aware diagnostic exit codes' {
  It 'does not fail Preview for missing optional Maestro' {
    $checks=@((New-FSCheck Git Ready 'present' ''),(New-FSCheck Maestro Missing 'missing' 'setup'))
    Get-FSExitCode Preview $checks | Should -Be 0
  }
  It 'fails Mobile when required Maestro is missing' {
    $checks=@((New-FSCheck Maestro Missing 'missing' 'setup'))
    Get-FSExitCode Mobile $checks | Should -Be 1
  }
  It 'allows deferred emulator work without claiming full app readiness' { $c=@((New-FSCheck Git Ready 'present' ''),(New-FSCheck EmulatorWiring NotApplicable 'deferred' 'PR4')); Get-FSExitCode Contributor $c | Should -Be 0 }
  It 'fails Contributor when required Node is missing' { $c=@((New-FSCheck Node Missing 'missing' 'Install Node')); Get-FSExitCode Contributor $c | Should -Be 1 }
  It 'does not count a configured MCP as connected' {
    $item=New-FSCheck 'MCP:dart' ConfiguredNotConnected 'not tested' 'connect'
    $item.Status | Should -Not -Be Ready
  }
}
