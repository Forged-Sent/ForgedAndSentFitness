function Get-ForgeFlutter {
    $sdk=$script:Settings.FlutterSdk
    if($sdk -and [IO.File]::Exists((Join-Path $sdk 'bin\flutter.bat'))){return (Join-Path $sdk 'bin\flutter.bat')}
    $command=Get-ForgeCommand 'flutter.bat'
    if($command){return $command.Source}
    throw 'Flutter is missing. Run fs doctor; no automatic installation is attempted.'
}
function Get-ForgeEngine { return (Join-Path $PSHOME 'pwsh.exe') }
function Get-ForgeWorkflow([string]$Action,[string]$Root,[bool]$Emulator,[bool]$Apply) {
    $mobile=Join-Path $Root 'mobile'
    $file='';$arguments=@();$directory=$Root;$effect=''
    switch($Action){
        run {
            $launcher=if($Emulator){'run-emulator-app.ps1'}else{'run-app.ps1'}
            $file=Get-ForgeEngine;$arguments=@('-NoLogo','-NoProfile','-File',(Join-Path $Root "tooling\windows\$launcher"))
            $effect=if($Emulator){'Run Chrome against local demo Firebase'}else{'Run supported Flutter Chrome preview; pub get may refresh dependencies'}
        }
        test {$file=Get-ForgeFlutter;$directory=$mobile;$arguments=@('test');$effect='Run Flutter tests'}
        analyze {$file=Get-ForgeFlutter;$directory=$mobile;$arguments=@('analyze');$effect='Run Flutter analysis'}
        format {
            $file=Join-Path (Split-Path -Parent (Get-ForgeFlutter)) 'dart.bat';$directory=$mobile
            $arguments=@('format');if(-not $Apply){$arguments+=@('--output=none','--set-exit-if-changed')};$arguments+=@('lib','test')
            $effect=if($Apply){'Apply Dart formatting to lib and test'}else{'Check Dart formatting without rewriting files (exit 1 means changes needed)'}
        }
        firebase {$file=Get-ForgeEngine;$arguments=@('-NoLogo','-NoProfile','-File',(Join-Path $Root 'tooling\windows\start-emulators.ps1'));$effect='Start loopback-only demo-forgedandsent Auth, Firestore, Storage emulators'}
        preview {$file=(Get-ForgeCommand 'python.exe').Source;$arguments=@((Join-Path $Root 'dev\make_preview.py'));$effect='Build dev/preview.html using the repository preview generator, then open it'}
    }
    if(-not $effect){throw 'Unknown workflow.'}
    [pscustomobject]@{File=$file;Arguments=$arguments;Directory=$directory;Effect=$effect}
}
function Assert-ForgeFeatureBranch([string]$Root) {
    $branch=& (Get-ForgeCommand 'git.exe').Source -C $Root symbolic-ref --quiet --short HEAD 2>$null
    if($LASTEXITCODE -ne 0 -or -not $branch){throw 'Detached HEAD: create a named feature branch explicitly first.'}
    if($branch -in @('main','master','production','prod')){throw 'Protected branch. Use your own feature branch before changing files or committing.'}
}
function Get-ForgeDoctor([string]$Root) {
    Write-ForgeHeading 'FORGED & SENT / LOCAL READINESS'
    [pscustomobject]@{Check='Checkout';Status='READY';Detail=$Root}
    $flutter=try{Get-ForgeFlutter}catch{''}
    $sdk=if($flutter){Split-Path -Parent (Split-Path -Parent $flutter)}else{''}
    $versionFile=if($sdk){Join-Path $sdk 'bin\cache\flutter.version.json'}else{''}
    $version=if($versionFile -and [IO.File]::Exists($versionFile)){([IO.File]::ReadAllText($versionFile) | ConvertFrom-Json).flutterVersion}else{'unknown'}
    $ci=Join-Path $Root '.github\workflows\ci-gate.yml';$pin='unknown'
    if([IO.File]::Exists($ci) -and [IO.File]::ReadAllText($ci) -match "flutter-version:\s*'([^']+)'"){$pin=$Matches[1]}
    [pscustomobject]@{Check='Flutter';Status=if($version -eq $pin){'READY'}else{'CHECK'};Detail="$version / CI $pin / $sdk"}
    $pathFlutter=(Get-ForgeCommand 'flutter.bat').Source
    [pscustomobject]@{Check='PATH Flutter';Status=if($pathFlutter -eq $flutter){'READY'}else{'DIFFERENT'};Detail="$pathFlutter (fs commands select the configured project SDK)"}
    foreach($name in @('git.exe','gh.exe','node.exe','python.exe','firebase.cmd','code.cmd')){
        $tool=Get-ForgeCommand $name;[pscustomobject]@{Check=$name;Status=if($tool){'FOUND'}else{'MISSING'};Detail=$tool.Source}
    }
    $model=Join-Path $Root 'tooling\windows\diagnostic-model.ps1'
    if([IO.File]::Exists($model)){
        $output=& (Get-ForgeEngine) -NoLogo -NoProfile -File (Join-Path $script:PackageRoot 'scripts\Test-Java.ps1') -ProjectRoot $Root 2>$null
        if($LASTEXITCODE -eq 0){$java=$output | ConvertFrom-Json;[pscustomobject]@{Check='Java';Status='READY';Detail="JDK $($java.Major) / $($java.Home)"}}
        else{[pscustomobject]@{Check='Java';Status='MISSING';Detail='Java 21 required; no installation attempted.'}}
    }
    foreach($p in @(9099,8080,9199)){$probe=netcheck '127.0.0.1' $p;[pscustomobject]@{Check="Emulator/$p";Status=if($probe.Reachable){'LISTENING'}else{'STOPPED'};Detail='A listening port alone does not verify Firebase health.'}}
    [pscustomobject]@{Check='Web host';Status=if([IO.File]::Exists((Join-Path $Root 'mobile\web\index.html'))){'READY'}else{'MISSING'};Detail='fs run refuses implicit flutter create; follow START_HERE.md to initialize.'}
}
function fs {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Position=0)][string]$Action='menu',[Parameter(Position=1)][string]$Value='', [switch]$Apply,[switch]$Emulator)
    if($Action -in @('menu','help')){if($Action -eq 'help'){helpme 'fs '}else{dash 'Forged & Sent'};return}
    $known=@('go','mobile','status','doctor','run','test','analyze','format','firebase','preview','branch','pr','ci','diff','open','docs','architecture')
    if($Action -notin $known){Write-Warning "Unknown fs action '$Action'. Available: $($known -join ', ').";return}
    $root=Get-ForgeProject
    switch($Action){
        go { Set-ForgeLocation $root }
        mobile { Set-ForgeLocation (Join-Path $root 'mobile') }
        status { Write-ForgeHeading "FORGED & SENT / $root";Invoke-ForgeNative (Get-ForgeCommand 'git.exe').Source @('--no-optional-locks','status','--short','--branch') $root;Write-Host 'Next: fs diff / fs doctor / fs docs' -ForegroundColor DarkGray }
        doctor { Get-ForgeDoctor $root }
        {$_ -in @('run','test','analyze','format','firebase','preview')} {
            $plan=Get-ForgeWorkflow $Action $root $Emulator.IsPresent $Apply.IsPresent
            if(-not $PSCmdlet.ShouldProcess($plan.Directory,$plan.Effect)){return}
            if($Action -eq 'format' -and $Apply){Assert-ForgeFeatureBranch $root}
            if($Action -eq 'run'){
                if(-not [IO.File]::Exists((Join-Path $root 'mobile\web\index.html'))){throw 'Web host missing. This wrapper will not run flutter create implicitly. Read fs docs START_HERE.'}
                # Repo launchers prefer this SDK; refuse a setting that would make test/run disagree.
                $launcherSdk=Join-Path $HOME 'develop\flutter\bin\flutter.bat'
                if([IO.File]::Exists($launcherSdk) -and (Get-ForgeFlutter) -ne $launcherSdk){throw 'The repository launcher and Forge SDK differ. Align FlutterSdk with the documented launcher before running.'}
            }
            if($Action -eq 'firebase'){
                $config=Get-Content -LiteralPath (Join-Path $root 'firebase.json') -Raw | ConvertFrom-Json
                foreach($service in @('auth','firestore','storage','ui')){if($config.emulators.$service.host -notin @('127.0.0.1','localhost','::1')){throw "Emulator $service is not loopback-only. Review Firebase configuration explicitly."}}
                $java=& (Get-ForgeEngine) -NoLogo -NoProfile -File (Join-Path $script:PackageRoot 'scripts\Test-Java.ps1') -ProjectRoot $root 2>$null
                if($LASTEXITCODE -ne 0){throw 'Java 21 was not found. No emulator launcher or installer was started.'}
                if(-not (Get-ForgeCommand 'firebase.cmd')){throw 'Firebase CLI missing. Approve a separate installation first.'}
            }
            if($Action -eq 'format' -and -not $Apply){
                Push-Location -LiteralPath $plan.Directory
                try{& $plan.File @($plan.Arguments);$code=$LASTEXITCODE;$global:LASTEXITCODE=$code;if($code -eq 1){Write-Host 'Formatting changes are available. Review with fs diff; apply with fs format -Apply on a feature branch.' -ForegroundColor Yellow}elseif($code -ne 0){throw "Dart format failed ($code)."}}finally{Pop-Location}
            }else{Invoke-ForgeNative $plan.File $plan.Arguments $plan.Directory}
            if($Action -eq 'preview'){Invoke-Item -LiteralPath (Join-Path $root 'dev\preview.html')}
        }
        branch {
            if(-not $Value){
                $branches=@(& (Get-ForgeCommand 'git.exe').Source -C $root for-each-ref '--format=%(refname:short)' refs/heads/)
                $item=Select-ForgeItem @($branches | ForEach-Object {[pscustomobject]@{Label=$_;Value=$_}}) 'LOCAL BRANCHES (switch requires confirmation)'
                if(-not $item){return};$Value=$item.Value
            }
            & (Get-ForgeCommand 'git.exe').Source -C $root show-ref --verify --quiet "refs/heads/$Value"
            if($LASTEXITCODE -ne 0){throw 'Choose an existing local branch. This command never creates or deletes branches.'}
            $dirty=@(& (Get-ForgeCommand 'git.exe').Source --no-optional-locks -C $root status --porcelain)
            if($dirty.Count){throw 'Working tree has changes. Branch switching is paused; review fs status first.'}
            if($PSCmdlet.ShouldProcess("$root / $Value",'Switch existing branch') -and $PSCmdlet.ShouldContinue("Switch to '$Value'?",'Confirm branch switch')){Invoke-ForgeNative (Get-ForgeCommand 'git.exe').Source @('switch','--',$Value) $root}
        }
        pr { Invoke-ForgeNative (Get-ForgeCommand 'gh.exe').Source @('pr','list','--repo','Forged-Sent/ForgedAndSentFitness','--limit','10') $root }
        ci { Invoke-ForgeNative (Get-ForgeCommand 'gh.exe').Source @('run','list','--repo','Forged-Sent/ForgedAndSentFitness','--limit','10') $root }
        diff { Invoke-ForgeNative (Get-ForgeCommand 'git.exe').Source @('--no-pager','diff','--stat') $root;Invoke-ForgeNative (Get-ForgeCommand 'git.exe').Source @('--no-pager','diff','--') $root;Write-Host 'Staged changes: git diff --cached' -ForegroundColor DarkGray }
        open { if($PSCmdlet.ShouldProcess($root,'Open VS Code')){Invoke-ForgeNative (Get-ForgeCommand 'code.cmd').Source @('--new-window',$root) $root;Write-Host 'Select Forge Command Center in the terminal profile menu. If the repository shell replaces the prompt, run reloadforge.' -ForegroundColor DarkGray} }
        docs {
            $docs=Join-Path $root 'docs'
            if($Value){ftext $Value $docs;return}
            $rows=@(Get-ChildItem -LiteralPath $docs -Filter '*.md' -File -Recurse | ForEach-Object {[pscustomobject]@{Label=[IO.Path]::GetRelativePath($docs,$_.FullName);Value=$_.FullName}})
            $item=Select-ForgeItem $rows 'PROJECT DOCUMENTATION'
            if($item){Invoke-Item -LiteralPath $item.Value}
        }
        architecture {
            $atlas=Join-Path $root 'build\architecture-explorer\Architecture-Atlas.html'
            if([IO.File]::Exists($atlas)){Invoke-Item -LiteralPath $atlas}
            else{
                $launcher=Join-Path $root 'launchers\windows\more\Architecture Atlas.cmd'
                if(-not [IO.File]::Exists($launcher)){throw 'Architecture launcher missing in this checkout. Use fs docs architecture.'}
                if($PSCmdlet.ShouldProcess($launcher,'Run repository Architecture Atlas launcher')){& $launcher}
            }
        }
    }
}
function gst { Invoke-ForgeNative (Get-ForgeCommand 'git.exe').Source @('--no-optional-locks','status','--short','--branch') }
function gad {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory,Position=0,ValueFromRemainingArguments)][string[]]$Path)
    $ctx=Get-ForgeContext;if(-not $ctx.Root){throw 'Enter a Git repository first.'};Assert-ForgeFeatureBranch $ctx.Root
    if($Path -contains '.'){throw 'Choose explicit files so generated files and credentials are not staged accidentally.'}
    if($PSCmdlet.ShouldProcess(($Path -join ', '),'Stage explicit files')){Invoke-ForgeNative (Get-ForgeCommand 'git.exe').Source (@('add','--')+$Path)}
}
function gmsg {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    param([Parameter(Mandatory,Position=0)][string]$Message)
    Assert-ForgeCapture $Message
    $ctx=Get-ForgeContext;if(-not $ctx.Root){throw 'Enter a Git repository first.'};Assert-ForgeFeatureBranch $ctx.Root
    if($PSCmdlet.ShouldProcess($ctx.Root,'Commit already-staged changes; hooks still run')){Invoke-ForgeNative (Get-ForgeCommand 'git.exe').Source @('commit','-m',$Message) $ctx.Root}
}
function gpsh {
    Write-Host 'Review fs status, fs pr and fs ci first. Pushing is an explicit manual Git operation.' -ForegroundColor Yellow
    Write-Host 'Agents require current-session authorization and the repository review/CI checks. Never push main or force-push. No push was executed.'
}
