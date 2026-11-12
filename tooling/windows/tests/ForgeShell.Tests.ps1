BeforeAll {
    . "$PSScriptRoot/../forge-shell-functions.ps1"
    $script:checkout=(Resolve-Path "$PSScriptRoot/../../..").Path
}
Describe 'Optional shell consent' {
    BeforeEach { Mock Read-Host { '' }; Mock Test-FSEngineeringShellInteractive { $true } }
    It 'defaults to no without asking for extras' {
        $choice=Select-FSEngineeringShell
        $choice.Apply | Should -BeFalse
        $choice.Style | Should -Be 'None'
        $choice.Tools | Should -BeFalse
        Should -Invoke Read-Host -Times 1 -Exactly
    }
    It 'never prompts when input is redirected or unattended' {
        Mock Test-FSEngineeringShellInteractive { $false }
        (Select-FSEngineeringShell).Apply | Should -BeFalse
        Should -Invoke Read-Host -Times 0 -Exactly
    }
    It 'keeps extras off when only core is accepted' {
        Mock Read-Host { 'yes' } -ParameterFilter { $Prompt -like '*ADHD-friendly*' }
        $choice=Select-FSEngineeringShell
        $choice.Apply | Should -BeTrue
        $choice.Style | Should -Be 'None'
        $choice.Tools | Should -BeFalse
    }
    It 'records separate explicit choices for colors and tools' {
        Mock Read-Host { 'yes' }
        Mock Read-Host { '2' } -ParameterFilter { $Prompt -like 'Colors*' }
        $choice=Select-FSEngineeringShell
        $choice.Apply | Should -BeTrue
        $choice.Style | Should -Be 'TerminalAndVSCode'
        $choice.Tools | Should -BeTrue
    }
}
Describe 'Packaged shell installation with isolated profiles' {
    BeforeEach {
        $script:install=Join-Path $TestDrive ([guid]::NewGuid().ToString('n')+' package [test]')
        $script:profileFile=Join-Path $TestDrive ([guid]::NewGuid().ToString('n')+' profile.ps1')
    }
    It 'previews without creating package, profile or backups' {
        Install-FSEngineeringShell -InstallRoot $install -ProfilePath $profileFile -ProjectRoot $checkout -WhatIf
        Test-Path -LiteralPath $install | Should -BeFalse
        Test-Path -LiteralPath $profileFile | Should -BeFalse
    }
    It 'preserves profile and personal settings on an idempotent upgrade' {
        [IO.File]::WriteAllText($profileFile,"# my existing customization`n")
        Install-FSEngineeringShell -InstallRoot $install -ProfilePath $profileFile -ProjectRoot $checkout
        $before=[IO.File]::ReadAllText($profileFile)
        $before | Should -Match 'my existing customization'
        $before | Should -Match ([regex]::Escape($install))
        $settingsFile=Join-Path $install 'config/settings.json'
        $settings=Get-Content -LiteralPath $settingsFile -Raw | ConvertFrom-Json
        $settings.DefaultProject | Should -Be $checkout
        $settings.PromptMode='minimal'
        $settings | ConvertTo-Json | Set-Content -LiteralPath $settingsFile
        $settingsHash=(Get-FileHash -LiteralPath $settingsFile).Hash
        $data=Join-Path $install 'data/notes.json'
        $null=New-Item -ItemType Directory -Path (Split-Path $data) -Force
        [IO.File]::WriteAllText($data,'{"personal":"retained"}')
        $backupCount=@(Get-ChildItem -LiteralPath (Join-Path $install 'backups') -Directory).Count
        Install-FSEngineeringShell -InstallRoot $install -ProfilePath $profileFile -ProjectRoot $checkout
        [IO.File]::ReadAllText($profileFile) | Should -BeExactly $before
        (Get-FileHash -LiteralPath $settingsFile).Hash | Should -Be $settingsHash
        [IO.File]::ReadAllText($data) | Should -BeExactly '{"personal":"retained"}'
        @(Get-ChildItem -LiteralPath (Join-Path $install 'backups') -Directory).Count | Should -Be $backupCount
    }
    It 'rolls back copied code when profile activation is refused' {
        $original="# >>> Forge Shell managed bootstrap >>>`nmalformed`n"
        [IO.File]::WriteAllText($profileFile,$original)
        { Install-FSEngineeringShell -InstallRoot $install -ProfilePath $profileFile -ProjectRoot $checkout } | Should -Throw '*Ambiguous managed block*'
        [IO.File]::ReadAllText($profileFile) | Should -BeExactly $original
        Test-Path -LiteralPath (Join-Path $install 'Microsoft.PowerShell_profile.ps1') | Should -BeFalse
        $manifest=Get-ChildItem -LiteralPath (Join-Path $install 'backups') -Recurse -Filter manifest.json | Select-Object -First 1
        (Get-Content -LiteralPath $manifest.FullName -Raw | ConvertFrom-Json).Status | Should -Be 'rolled-back'
    }
    It 'rejects installation of personal state inside the checkout' {
        { Install-FSEngineeringShell -InstallRoot (Join-Path $checkout '.test-state') -ProjectRoot $checkout -WhatIf } | Should -Throw '*outside the repository*'
    }
}
