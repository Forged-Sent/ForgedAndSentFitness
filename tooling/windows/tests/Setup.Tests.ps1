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
Describe 'Remembered setup profile for Check my setup (real local Git)' {
  BeforeEach {
    $script:repo=Join-Path $TestDrive ([guid]::NewGuid().ToString('n'))
    & git init --quiet $script:repo | Out-Null
    if($LASTEXITCODE){throw 'Git init failed'}
  }
  It 'uses the fallback until a profile is saved, then remembers it' {
    Get-FSRememberedProfile $script:repo 'Contributor' | Should -Be 'Contributor'
    Save-FSProfile $script:repo 'Preview'
    Get-FSRememberedProfile $script:repo 'Contributor' | Should -Be 'Preview'
    Save-FSProfile $script:repo 'Contributor'
    Get-FSRememberedProfile $script:repo 'Preview' | Should -Be 'Contributor'
  }
  It 'stores the choice inside .git so it is never committed' {
    Save-FSProfile $script:repo 'Contributor'
    (& git -C $script:repo status --porcelain --untracked-files=all) | Should -BeNullOrEmpty
  }
  It 'ignores an unexpected saved value' {
    $file=Get-FSProfileFile $script:repo
    Set-Content -LiteralPath $file -Value 'Administrator' -Encoding ascii
    Get-FSRememberedProfile $script:repo 'Preview' | Should -Be 'Preview'
  }
  It 'falls back without throwing outside a Git clone' {
    $plain=Join-Path $TestDrive ([guid]::NewGuid().ToString('n'))
    New-Item -ItemType Directory -Path $plain | Out-Null
    {Get-FSRememberedProfile $plain 'Preview'} | Should -Not -Throw
    Get-FSRememberedProfile $plain 'Preview' | Should -Be 'Preview'
    {Save-FSProfile $plain 'Contributor'} | Should -Not -Throw
  }
}
