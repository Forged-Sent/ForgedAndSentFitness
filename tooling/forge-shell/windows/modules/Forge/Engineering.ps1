function ph {
    [CmdletBinding()]
    param()
    [pscustomobject]@{Check='Forge';Status='READY';Detail="2.0.0 / module load $($script:LoadMs) ms"}
    [pscustomobject]@{Check='PowerShell';Status=if($PSVersionTable.PSVersion -ge [version]'7.5' -and [Environment]::Is64BitProcess){'READY'}else{'CHECK'};Detail="$($PSVersionTable.PSVersion) / $PSHOME"}
    [pscustomobject]@{Check='Host';Status=if($script:IsAdmin){'ADMIN'}else{'USER'};Detail=$Host.Name}
    [pscustomobject]@{Check='Profile';Status=if(Test-Path -LiteralPath $PROFILE.CurrentUserAllHosts){'READY'}else{'MISSING'};Detail=$PROFILE.CurrentUserAllHosts}
    [pscustomobject]@{Check='Config';Status=if($script:Problems.Count){'CHECK'}else{'READY'};Detail=($script:Problems -join ' ')}
    [pscustomobject]@{Check='Editing';Status=if(Get-Module PSReadLine){'READY'}else{'INACTIVE'};Detail="Enabled: $($script:Settings.EnableEditing); ANSI: $($script:Ansi)"}
    foreach($name in @('git.exe','gh.exe','rg.exe','fzf.exe','python.exe','node.exe','flutter.bat','firebase.cmd','code.cmd')){
        $tool=Get-ForgeCommand $name
        [pscustomobject]@{Check=$name;Status=if($tool){'FOUND'}else{'OPTIONAL/MISSING'};Detail=$tool.Source}
    }
    foreach($name in @('bookmarks','visits','notes','todos','sessions')){
        try{$null=Read-ForgeData $name $(if($name -eq 'bookmarks'){@{}}else{@()});[pscustomobject]@{Check="Data/$name";Status='READY';Detail='Readable or not created yet'}}catch{[pscustomobject]@{Check="Data/$name";Status='CHECK';Detail='Malformed JSON retained; previous version may be available beside it.'}}
    }
}
function ptest { & (Join-Path $script:PackageRoot 'tests\Validate.ps1') }
function pathcheck {
    $seen=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase);$i=0
    foreach($p in ($env:Path -split ';')){
        if(-not $p){continue};$i++
        $clean=[Environment]::ExpandEnvironmentVariables($p.Trim('"')).TrimEnd('\')
        [pscustomobject]@{Order=$i;Exists=[IO.Directory]::Exists($clean);Duplicate=(-not $seen.Add($clean));Path=$clean}
    }
}
function refreshpath {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if($PSCmdlet.ShouldProcess('Current shell only','Refresh PATH from Machine and User registry values')){
        $env:Path=[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')
        Write-Host 'Current-session PATH refreshed. Registry settings were not modified.'
    }
}
function envshow([string]$Query='') {
    Get-ChildItem Env: | Where-Object Name -like "*$Query*" | Sort-Object Name | ForEach-Object {
        # Values are opt-in nowhere: environment inventories should not leak secrets.
        [pscustomobject]@{Name=$_.Name;Length=$_.Value.Length;Value='[hidden]'}
    }
}
function port([ValidateRange(0,65535)][int]$Number=0) {
    Get-NetTCPConnection -ErrorAction Stop | Where-Object {($_.State -eq 'Listen') -and (-not $Number -or $_.LocalPort -eq $Number)} | ForEach-Object {
        $process=Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [pscustomobject]@{Port=$_.LocalPort;Address=$_.LocalAddress;PID=$_.OwningProcess;Process=$process.ProcessName}
    } | Sort-Object Port
}
function err([ValidateRange(0,100)][int]$Index=0) {
    if($global:Error.Count -le $Index){Write-Host 'No error at that index.';return}
    $record=$global:Error[$Index]
    $message=[string]$record.Exception.Message
    if(Test-ForgeSecretValue $message){$message='Message hidden because it may contain sensitive data. Inspect $Error locally if needed.'}
    [pscustomobject]@{Type=$record.Exception.GetType().Name;Category=$record.CategoryInfo.Category;Message=(Protect-ForgeText $message);File=$record.InvocationInfo.ScriptName;Line=$record.InvocationInfo.ScriptLineNumber}
}
function netcheck([string]$Computer='127.0.0.1',[ValidateRange(1,65535)][int]$Port=8080) {
    $client=[Net.Sockets.TcpClient]::new();$watch=[Diagnostics.Stopwatch]::StartNew();$ok=$false
    try{$job=$client.ConnectAsync($Computer,$Port);$ok=$job.Wait(1500) -and $client.Connected}catch{}finally{$client.Dispose()}
    [pscustomobject]@{Computer=$Computer;Port=$Port;Reachable=$ok;ElapsedMs=[math]::Round($watch.Elapsed.TotalMilliseconds)}
}
function sshgo([string]$Name='') {
    $ssh=Get-ForgeCommand 'ssh.exe';if(-not $ssh){throw 'OpenSSH client unavailable.'}
    if(-not $Name){
        $file=Join-Path $HOME '.ssh\config';if(-not [IO.File]::Exists($file)){throw 'No SSH config. Use sshgo user@host.'}
        $items=@(Get-Content -LiteralPath $file | Where-Object {$_ -match '^\s*Host\s+'} | ForEach-Object {($_ -replace '^\s*Host\s+','') -split '\s+'} | Where-Object {$_ -and $_ -notmatch '[*?!]'} | Sort-Object -Unique | ForEach-Object {[pscustomobject]@{Label=$_;Value=$_}})
        $choice=Select-ForgeItem $items 'SSH HOSTS';if(-not $choice){return};$Name=$choice.Value
    }
    if($Name -notmatch '^[a-zA-Z0-9_][a-zA-Z0-9_.@:-]*$'){throw 'Use a configured SSH alias or user@hostname.'}
    & $ssh.Source $Name
}
function jview {
    [CmdletBinding()]
    param([Parameter(Position=0,ValueFromPipeline)][string]$InputObject,[switch]$Minify)
    begin{$pieces=[Collections.Generic.List[string]]::new()}
    process{if($null -ne $InputObject){$pieces.Add($InputObject)}}
    end{
        $text=$pieces -join "`n"
        if($pieces.Count -eq 1 -and (Test-Path -LiteralPath $text -PathType Leaf)){$text=[IO.File]::ReadAllText((Resolve-Path -LiteralPath $text).ProviderPath)}
        $obj=ConvertFrom-Json -InputObject $text -Depth 100 -ErrorAction Stop
        ConvertTo-Json -InputObject $obj -Depth 100 -Compress:$Minify
    }
}
function cliptools([ValidateSet('path','get','set')][string]$Action='path',[string]$Text='') {
    switch($Action){path{Set-Clipboard -Value $PWD.ProviderPath};get{Get-Clipboard};set{Set-Clipboard -Value $Text}}
}
function hash([Parameter(Mandatory,Position=0)][string]$Path){Get-FileHash -LiteralPath $Path -Algorithm SHA256}
function comparefile([Parameter(Mandatory,Position=0)][string]$Left,[Parameter(Mandatory,Position=1)][string]$Right){
    $a=Get-FileHash -LiteralPath $Left -Algorithm SHA256;$b=Get-FileHash -LiteralPath $Right -Algorithm SHA256
    [pscustomobject]@{Identical=$a.Hash -eq $b.Hash;Left=$a.Path;Right=$b.Path;Algorithm='SHA256'}
}
function tempwork {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $path=Join-Path $script:StateRoot ('data\scratch\'+[datetime]::Now.ToString('yyyyMMdd')+'-'+[guid]::NewGuid().ToString('N').Substring(0,8))
    if($PSCmdlet.ShouldProcess($path,'Create private scratch folder and enter')){$null=[IO.Directory]::CreateDirectory($path);Set-ForgeLocation $path}
}
function trash {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    param([Parameter(Mandatory,Position=0)][string]$Path)
    $resolved=(Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath.TrimEnd('\')
    $root=[IO.Path]::GetPathRoot($resolved).TrimEnd('\')
    $item=Get-Item -LiteralPath $resolved -Force
    if($resolved -eq $root -or $resolved -eq $HOME -or $PWD.ProviderPath.StartsWith($resolved+'\',[StringComparison]::OrdinalIgnoreCase) -or $resolved -eq $PWD.ProviderPath -or $resolved -match '(?i)(^|\\)\.git($|\\)' -or (Test-Path -LiteralPath (Join-Path $resolved '.git'))){throw 'Protected location. No file was changed.'}
    if($item.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Use native tools to inspect and manage this link explicitly.'}
    if($PSCmdlet.ShouldProcess($resolved,'Move to Windows Recycle Bin')){
        Add-Type -AssemblyName Microsoft.VisualBasic
        if($item.PSIsContainer){[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($resolved,'OnlyErrorDialogs','SendToRecycleBin','ThrowException')}
        else{[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($resolved,'OnlyErrorDialogs','SendToRecycleBin','ThrowException')}
    }
}
