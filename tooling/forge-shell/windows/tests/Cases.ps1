#requires -Version 7.5
param([Parameter(Mandatory)][string]$PackageRoot,[switch]$KeepArtifacts)
$ErrorActionPreference='Stop'
$suiteRoot=Join-Path $env:TEMP ('ForgeShell-validation-'+[guid]::NewGuid().ToString('N'))
$null=[IO.Directory]::CreateDirectory($suiteRoot)
$state=Join-Path $suiteRoot 'state with spaces';$null=[IO.Directory]::CreateDirectory((Join-Path $state 'config'))
$settings=Get-Content -LiteralPath (Join-Path $PackageRoot 'config\settings.json') -Raw | ConvertFrom-Json -AsHashtable
$settings.EnableDirectoryHistory=$false;$settings.DefaultProject='';$settings.WorkspaceRoots=@()
$settings | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $state 'config\settings.json')
$env:FORGE_HOME=$state;$env:FORGE_NO_EDITING='1'
$manifest=Join-Path $PackageRoot 'modules\Forge\Forge.psd1'
$script:Passed=0;$script:Failed=0;$script:Results=[Collections.Generic.List[object]]::new()
function Check([string]$Name,[scriptblock]$Body){
    try{& $Body;$script:Passed++;$script:Results.Add(@{Name=$Name;Result='PASS'});Write-Host "PASS $Name" -ForegroundColor Green}
    catch{$script:Failed++;$script:Results.Add(@{Name=$Name;Result='FAIL';Error=$_.Exception.Message});Write-Host "FAIL $Name : $($_.Exception.Message)" -ForegroundColor Red}
}
function Assert($Value,[string]$Message='Assertion failed'){if(-not $Value){throw $Message}}
function Assert-Throws([scriptblock]$Body,[string]$Pattern='.*'){$didThrow=$false;try{& $Body}catch{$didThrow=$true;if($_.Exception.Message -notmatch $Pattern){throw "Unexpected error: $($_.Exception.Message)"}};Assert $didThrow 'Expected a refusal.'}
function Git([string[]]$Arguments){& $script:GitExe @Arguments | Out-Null;if($LASTEXITCODE -ne 0){throw "Fixture Git command failed: $($Arguments[0])"}}
$baselineAliases=@{};foreach($a in @('ft','cd','ls','rm','cat','sort')){$baselineAliases[$a]=(Get-Alias $a).Definition}
$collisions=@();$spec=Import-PowerShellDataFile $manifest
foreach($name in $spec.FunctionsToExport){$existing=$ExecutionContext.SessionState.InvokeCommand.GetCommand($name,[Management.Automation.CommandTypes]::All);if($existing){$collisions+=$name}}
$originalLocation=$PWD.Path
try {
    Check 'All PowerShell sources parse' {
        & (Join-Path $PackageRoot 'scripts\Build-Module.ps1') -Check
        foreach($file in Get-ChildItem -LiteralPath $PackageRoot -Recurse -File | Where-Object {$_.Extension -in @('.ps1','.psm1','.psd1') -and $_.FullName -notmatch '\\(data|backups)\\'}){
            $t=$null;$e=$null;$null=[Management.Automation.Language.Parser]::ParseFile($file.FullName,[ref]$t,[ref]$e)
            Assert (-not $e.Count) "$($file.Name): $($e.Message -join ', ')"
        }
    }
    Check 'Bootstrap loads quietly and exports resolve' {
        $output=@(. (Join-Path $PackageRoot 'Microsoft.PowerShell_profile.ps1') 3>&1 6>&1)
        Assert ($output.Count -eq 0) 'Profile emitted startup output.'
        $m=Test-ModuleManifest $manifest
        foreach($command in $m.ExportedFunctions.Keys){Assert ((Get-Command $command).ModuleName -eq 'Forge') "Missing command $command"}
    }
    Check 'Built-in aliases retain their meaning' {foreach($a in $baselineAliases.Keys){Assert ((Get-Alias $a).Definition -eq $baselineAliases[$a]) "Alias changed: $a"}}
    Check 'Exported commands do not shadow native executables or built-ins' {Assert ($collisions.Count -eq 0) ("Collisions: "+($collisions -join ', '));Assert ((Get-Command clip).CommandType -eq 'Application')}
    Check 'Catalog commands and actions are complete' {
        $catalog=@(helpme -Raw)
        Assert ($catalog.Count -ge 45)
        Assert (@($catalog | Where-Object First).Count -eq 15) 'Start-here list should contain 15 entries.'
        foreach($row in $catalog){$name=($row.Command -split ' ')[0];Assert ([bool](Get-Command $name -ErrorAction SilentlyContinue)) "Catalog command missing: $name"}
    }
    Check 'Namespace and bookmark tab completion expose available choices' {
        $completion=TabExpansion2 'fs an' 5
        Assert ($completion.CompletionMatches.CompletionText -contains 'analyze')
        Assert ((TabExpansion2 'forge th' 8).CompletionMatches.CompletionText -contains 'theme')
        Assert ((TabExpansion2 'jump hom' 8).CompletionMatches.CompletionText -contains 'home')
    }
    $folder=Join-Path $suiteRoot 'folder [one] with spaces';$null=[IO.Directory]::CreateDirectory($folder)
    Check 'Bookmarks round-trip literal paths with spaces and brackets' {
        mark fixture $folder | Out-Null
        Assert ((marks fixture).Path -eq $folder) 'Bookmark name or path was not saved correctly.'
        jump fixture;Assert ($PWD.ProviderPath -eq $folder)
        unmark fixture -Confirm:$false
        Assert (@(marks fixture).Count -eq 0)
    }
    Check 'Bookmark WhatIf changes nothing' {mark dry $folder -WhatIf;Assert (@(marks dry).Count -eq 0)}
    Check 'Captures survive reload with stable IDs and project scope' {
        todo 'first fixture task';todo 'second fixture task';note 'fixture observation'
        reloadforge
        Assert (@(todos).Count -eq 2);Assert ((todos)[0].Id -eq 1)
        done 1;Assert (@(todos).Count -eq 1);Assert (@(todos -All).Count -eq 2)
        Assert ((notes fixture).Text -eq 'fixture observation')
        session save 'Next: finish fixture';Assert (@(session list).Count -eq 1)
    }
    Check 'Secret-shaped captures are refused before writes' {
        $before=(Get-FileHash -LiteralPath (Join-Path $state 'data\notes.json')).Hash
        Assert-Throws {note 'api_key = fictional-test-value'} 'sensitive'
        Assert ((Get-FileHash -LiteralPath (Join-Path $state 'data\notes.json')).Hash -eq $before)
        note 'Investigate token refresh after reconnect'
        Assert ((notes 'token refresh').Text -eq 'Investigate token refresh after reconnect') 'Ordinary engineering prose should remain capturable.'
    }
    Check 'Malformed data is retained and refuses destructive overwrite' {
        $file=Join-Path $state 'data\notes.json';$saved=[IO.File]::ReadAllBytes($file)
        try{[IO.File]::WriteAllText($file,'{broken');Assert-Throws {note 'cannot overwrite'} 'Cannot read';Assert ([IO.File]::ReadAllText($file) -eq '{broken')}
        finally{[IO.File]::WriteAllBytes($file,$saved)}
    }
    Check 'Concurrent shells cannot lose captured tasks' {
        $processes=@()
        foreach($i in 1..4){
            $psi=[Diagnostics.ProcessStartInfo]::new((Join-Path $PSHOME 'pwsh.exe'));$psi.UseShellExecute=$false;$psi.CreateNoWindow=$true;$psi.RedirectStandardOutput=$true;$psi.RedirectStandardError=$true
            foreach($arg in @('-NoLogo','-NoProfile','-NonInteractive','-File',(Join-Path $PSScriptRoot 'Capture-Fixture.ps1'),'-PackageRoot',$PackageRoot,'-State',$state,'-Text',"concurrent task $i")){$psi.ArgumentList.Add($arg)}
            $p=[Diagnostics.Process]::Start($psi);$processes+=@{Process=$p;Out=$p.StandardOutput.ReadToEndAsync();Err=$p.StandardError.ReadToEndAsync()}
        }
        foreach($job in $processes){Assert ($job.Process.WaitForExit(15000)) 'Fixture child timed out.';Assert ($job.Process.ExitCode -eq 0) $job.Err.Result;$job.Process.Dispose()}
        Assert (@(todos -All).Count -eq 6) 'A concurrent capture was lost.'
    }
    Check 'Malformed config falls back quietly and remains recoverable' {
        $cfg=Join-Path $state 'config\settings.json';$saved=[IO.File]::ReadAllBytes($cfg)
        try{[IO.File]::WriteAllText($cfg,'{broken');reloadforge;Assert ((ph | Where-Object Check -eq Config).Status -eq 'CHECK');Assert ([IO.File]::ReadAllText($cfg) -eq '{broken')}
        finally{[IO.File]::WriteAllBytes($cfg,$saved);reloadforge}
    }
    Check 'Invalid setting values are rejected and dry runs are safe' {
        Assert-Throws {forge config Theme 'rainbow'} 'Invalid'
        $old=(forge config | Where-Object Setting -eq Theme).Value
        forge theme forged -WhatIf
        Assert ((forge config | Where-Object Setting -eq Theme).Value -eq $old)
    }
    Check 'PSReadLine bindings and history filter are active when loaded' {
        Import-Module PSReadLine
        $env:FORGE_NO_EDITING='';reloadforge
        $handlers=Get-PSReadLineKeyHandler -Bound
        Assert (($handlers | Where-Object Key -eq 'Tab').Function -eq 'MenuComplete')
        Assert (($handlers | Where-Object Key -eq 'Alt+h').Function -eq 'ForgeHelp')
        $options=Get-PSReadLineOption
        Assert ($options.AddToHistoryHandler.Invoke('api_key = synthetic') -eq 'SkipAdding')
        Assert ($options.AddToHistoryHandler.Invoke(' note private thought') -eq 'SkipAdding')
        Assert ($options.AddToHistoryHandler.Invoke('git status') -eq 'MemoryAndFile')
        $env:FORGE_NO_EDITING='1'
    }
    $script:GitExe=(Get-Command git.exe).Source
    $repo=Join-Path $suiteRoot 'Forged checkout with spaces';$null=[IO.Directory]::CreateDirectory($repo)
    Git @('init','--initial-branch=feature/fixture',$repo)
    Git @('-C',$repo,'remote','add','origin','https://github.com/Forged-Sent/ForgedAndSentFitness.git')
    [IO.File]::WriteAllText((Join-Path $repo 'tracked.txt'),'baseline')
    Git @('-C',$repo,'add','--','tracked.txt')
    Git @('-C',$repo,'-c','user.name=Forge Fixture','-c','user.email=fixture@example.invalid','commit','-m','fixture')
    $null=[IO.Directory]::CreateDirectory((Join-Path $repo 'mobile'))
    [IO.File]::WriteAllText((Join-Path $repo 'mobile\pubspec.yaml'),'name: fixture')
    Set-Location -LiteralPath (Join-Path $repo 'mobile')
    Check 'Repository and Flutter context detected without Git invocation' {
        $ctx=forge context;Assert ($ctx.Root -eq $repo);Assert $ctx.IsForged;Assert ($ctx.Kind -eq 'Flutter')
    }
    Check 'Prompt displays cached dirty state and preserves exit codes' {
        $global:LASTEXITCODE=37;$first=prompt
        Assert ($global:LASTEXITCODE -eq 37) 'Prompt modified LASTEXITCODE.'
        Assert ($first -match 'FORGED & SENT' -and $first -match 'feature/fixture')
        $text='';foreach($i in 1..20){Start-Sleep -Milliseconds 50;$text=prompt;if($text -notmatch '\[checking\]'){break}}
        Assert ($text -match '\?1') "Expected untracked mobile directory in prompt: $text"
        $m=Get-Module Forge
        $state=& $m {ConvertFrom-ForgeStatus "# branch.ab +2 -3`n1 M. N... x`n1 .M N... y`n? new`nu UU conflict"}
        Assert ($state.Staged -eq 1 -and $state.Changed -eq 1 -and $state.Untracked -eq 1 -and $state.Conflict -eq 1 -and $state.Ahead -eq 2 -and $state.Behind -eq 3)
    }
    Check 'ANSI and administrator indicators are deterministic' {
        $m=Get-Module Forge
        $text=& $m {$save=$script:Ansi;$admin=$script:IsAdmin;try{$script:Ansi=$true;$script:IsAdmin=$true;Get-ForgePrompt -Succeeded $false -NativeExit 7}finally{$script:Ansi=$save;$script:IsAdmin=$admin}}
        Assert ($text.Contains("`e[38;2;241;123;50m"));Assert ($text -match 'ADMIN' -and $text -match '! failed 7')
    }
    Check 'Optional executables can be missing without breaking navigation or prompt' {
        $oldPath=$env:Path
        try{$env:Path='';$text=prompt;Assert ($text -match 'FORGED & SENT');Assert (@(ff '*tracked*' $repo).Count -eq 1);Assert (@(ftext baseline $repo).Count -ge 1)}
        finally{$env:Path=$oldPath}
    }
    Check 'Linked worktrees resolve their private HEAD and common Git config' {
        $linked=Join-Path $suiteRoot 'linked worktree';Git @('-C',$repo,'worktree','add','-b','feature/linked',$linked)
        Set-Location -LiteralPath $linked
        $ctx=forge context;Assert $ctx.IsForged;Assert ($ctx.Root -eq $linked);Assert ($ctx.GitDir -like '*worktrees*');Assert ($ctx.CommonDir -eq (Join-Path $repo '.git'))
        Assert ((prompt) -match 'feature/linked')
        Set-Location -LiteralPath $repo
    }
    Check 'Workflow plans use the selected SDK and existing launchers' {
        $m=Get-Module Forge
        $plans=& $m {param($r)foreach($a in @('run','test','analyze','format','firebase','preview')){Get-ForgeWorkflow $a $r $false $false}} $repo
        Assert (($plans | Where-Object Effect -like 'Run supported*').Arguments[-1] -eq (Join-Path $repo 'tooling\windows\run-app.ps1'))
        Assert (($plans | Where-Object Effect -like 'Check Dart*').Arguments -contains '--output=none')
        Assert (($plans | Where-Object Effect -like 'Start loopback*').Arguments[-1] -like '*start-emulators.ps1')
        foreach($plan in $plans){Assert (($plan.Arguments -join ' ') -notmatch '\b(deploy|push|login|configure)\b')}
    }
    Check 'Workflow WhatIf never launches tools or changes checkout files' {
        $launcher=Join-Path $repo 'launchers\windows\more\Architecture Atlas.cmd';$null=[IO.Directory]::CreateDirectory((Split-Path -Parent $launcher));[IO.File]::WriteAllText($launcher,'exit /b 0')
        $before=@(Get-ChildItem -LiteralPath $repo -File -Recurse -Force).Count
        foreach($action in @('run','test','analyze','format','firebase','preview','architecture','open')){fs $action -WhatIf}
        Assert (@(Get-ChildItem -LiteralPath $repo -File -Recurse -Force).Count -eq $before)
    }
    Check 'Protected branches refuse staging and commits' {
        Git @('-C',$repo,'switch','-c','main')
        Assert-Throws {gad tracked.txt -WhatIf} 'Protected branch'
        Assert-Throws {gmsg 'fixture change' -WhatIf} 'Protected branch'
        Assert-Throws {fs format -Apply} 'Protected branch'
        Assert (@(& $script:GitExe -C $repo diff --cached --name-only).Count -eq 0)
        $result=gpsh 6>&1;Assert (($result -join ' ') -match 'No push was executed')
    }
    Check 'Recycle helper refuses roots and dry runs preserve files' {
        Assert-Throws {trash $HOME -WhatIf} 'Protected'
        Assert-Throws {trash $repo -WhatIf} 'Protected'
        trash (Join-Path $repo 'tracked.txt') -WhatIf
        Assert ([IO.File]::Exists((Join-Path $repo 'tracked.txt')))
    }
    Check 'Module reload replaces the module without duplicating commands' {
        $before=Get-Module Forge;reloadforge;$after=Get-Module Forge
        Assert (-not [object]::ReferenceEquals($before,$after));Assert (@(Get-Module Forge).Count -eq 1);Assert ((Get-Command fs).ModuleName -eq 'Forge')
    }
    Check 'Installer preserves existing bytes and is idempotent' {
        $fixtureProfile=Join-Path $suiteRoot 'profile with spaces.ps1'
        [IO.File]::WriteAllText($fixtureProfile,"# original`r`nSet-Alias fixture Get-Date`r`n")
        & (Join-Path $PackageRoot 'Install.ps1') -ProfilePath $fixtureProfile -StateRoot $suiteRoot
        $content=[IO.File]::ReadAllText($fixtureProfile)
        Assert ($content.Contains('Set-Alias fixture Get-Date'));Assert ($content.Contains($PackageRoot));Assert (-not $content.Contains('__BOOTSTRAP__'))
        $hash=(Get-FileHash -LiteralPath $fixtureProfile).Hash
        & (Join-Path $PackageRoot 'Install.ps1') -ProfilePath $fixtureProfile -StateRoot $suiteRoot
        Assert ((Get-FileHash -LiteralPath $fixtureProfile).Hash -eq $hash)
        Add-Content -LiteralPath $fixtureProfile -Value '# later personal edit'
        & (Join-Path $PackageRoot 'Uninstall.ps1') -ProfilePath $fixtureProfile -ProfileOnly -StateRoot $suiteRoot
        $content=[IO.File]::ReadAllText($fixtureProfile);Assert ($content -notmatch 'Forge Shell managed');Assert ($content -match 'later personal edit')
    }
    Check 'Rollback verifies hashes and refuses later edits' {
        . (Join-Path $PackageRoot 'scripts\Transactions.ps1')
        $target=Join-Path $suiteRoot 'restore fixture.txt';[IO.File]::WriteAllBytes($target,[byte[]](0,1,2,255))
        $tx=New-ForgeTransaction $suiteRoot @($target) 'fixture'
        Write-ForgeTransactionFile $tx $target 'replacement'
        & (Join-Path $PackageRoot 'Restore.ps1') -Backup $tx.Directory -Confirm:$false
        Assert ([Convert]::ToHexString([IO.File]::ReadAllBytes($target)) -eq '000102FF')
        & (Join-Path $PackageRoot 'Restore.ps1') -Backup $tx.Directory -Confirm:$false
        $tx2=New-ForgeTransaction $suiteRoot @($target) 'fixture';Write-ForgeTransactionFile $tx2 $target 'replacement';[IO.File]::WriteAllText($target,'later edit')
        Assert-Throws {& (Join-Path $PackageRoot 'Restore.ps1') -Backup $tx2.Directory -Confirm:$false} 'changed after'
        Assert ([IO.File]::ReadAllText($target) -eq 'later edit')
    }
    Check 'Terminal preview does not alter settings and apply is recoverable' {
        $wt=Join-Path $suiteRoot 'terminal settings.json';$vsc=Join-Path $suiteRoot 'code settings.json'
        [IO.File]::WriteAllText($wt,'{"defaultProfile":"existing","profiles":{"defaults":{"opacity":97},"list":[{"guid":"existing","source":"Windows.Terminal.PowershellCore","hidden":false}]},"schemes":[],"custom":true}')
        [IO.File]::WriteAllText($vsc,'{"editor.fontSize":17,"terminal.integrated.profiles.windows":{"Existing":{"path":"pwsh.exe"}},"workbench.colorCustomizations":{"editor.background":"#111111"}}')
        $h=(Get-FileHash -LiteralPath $wt).Hash
        & (Join-Path $PackageRoot 'Configure-Terminals.ps1') -TerminalPath $wt -CodePath $vsc -StateRoot $suiteRoot | Out-Null
        Assert ((Get-FileHash -LiteralPath $wt).Hash -eq $h)
        & (Join-Path $PackageRoot 'Configure-Terminals.ps1') -TerminalPath $wt -CodePath $vsc -Apply -StateRoot $suiteRoot | Out-Null
        $w=Get-Content -LiteralPath $wt -Raw | ConvertFrom-Json;Assert $w.custom;Assert ($w.defaultProfile -eq 'existing');Assert ($w.schemes.Count -eq 2)
        $v=Get-Content -LiteralPath $vsc -Raw | ConvertFrom-Json -AsHashtable;Assert ($v['editor.fontSize'] -eq 17);Assert ($v['workbench.colorCustomizations']['editor.background'] -eq '#111111')
        $backup=[IO.File]::ReadAllText((Join-Path $suiteRoot 'data\terminal-backup.txt'))
        & (Join-Path $PackageRoot 'Configure-Terminals.ps1') -TerminalPath $wt -CodePath $vsc -Apply -StateRoot $suiteRoot | Out-Null
        Assert ([IO.File]::ReadAllText((Join-Path $suiteRoot 'data\terminal-backup.txt')) -eq $backup) 'Reapplying identical themes must retain the original backup.'
        & (Join-Path $PackageRoot 'Uninstall.ps1') -ProfilePath (Join-Path $suiteRoot 'absent.ps1') -StateRoot $suiteRoot
        & (Join-Path $PackageRoot 'Uninstall.ps1') -ProfilePath (Join-Path $suiteRoot 'absent.ps1') -StateRoot $suiteRoot
        Assert ((Get-FileHash -LiteralPath $wt).Hash -eq $h)
    }
} finally {
    Set-Location -LiteralPath $originalLocation
    Remove-Module Forge -Force -ErrorAction SilentlyContinue
    $report=@{At=[datetime]::UtcNow.ToString('o');PowerShell=$PSVersionTable.PSVersion.ToString();Passed=$script:Passed;Failed=$script:Failed;Checks=$script:Results;Artifacts=if($KeepArtifacts){$suiteRoot}else{'removed'};Unverified=@('Elevated process execution (admin indicator is simulated)','Real VS Code extension host','Live Flutter app and Firebase service startup')}
    $reportPath=Join-Path $PackageRoot 'data\validation.json';$null=[IO.Directory]::CreateDirectory((Split-Path -Parent $reportPath));$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $reportPath
    if(-not $KeepArtifacts){
        $resolved=[IO.Path]::GetFullPath($suiteRoot);$allowed=[IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')+'\ForgeShell-validation-'
        if(-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)){throw 'Fixture cleanup path rejected.'}
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
Write-Host "Validation: $script:Passed passed; $script:Failed failed. Report: $reportPath"
if($script:Failed){exit 1}
