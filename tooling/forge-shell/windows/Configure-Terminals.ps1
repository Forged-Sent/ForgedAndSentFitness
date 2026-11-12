#requires -Version 7.5
[CmdletBinding(SupportsShouldProcess)]
param([switch]$Apply,[switch]$TerminalOnly,[string]$TerminalPath,[string]$CodePath=(Join-Path $env:APPDATA 'Code\User\settings.json'),[string]$StateRoot=$PSScriptRoot)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'scripts\Transactions.ps1')
if(-not $TerminalPath){
    $TerminalPath=Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal*\LocalState\settings.json') -ErrorAction SilentlyContinue | Sort-Object FullName | Select-Object -First 1 -ExpandProperty FullName
}
$engine=Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
if(-not [IO.File]::Exists($engine)){$engine=Join-Path $PSHOME 'pwsh.exe'}
$schemes=@(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'themes\terminal-schemes.json') -Raw | ConvertFrom-Json -AsHashtable)
$changes=@();$previews=Join-Path $StateRoot 'themes\proposed';$null=[IO.Directory]::CreateDirectory($previews)
if($TerminalPath -and [IO.File]::Exists($TerminalPath)){
    $before=Get-ForgeFileHash $TerminalPath
    $wt=Get-Content -LiteralPath $TerminalPath -Raw | ConvertFrom-Json -AsHashtable
    if(-not $wt.profiles -or -not $wt.profiles.Contains('list')){throw 'Unsupported Windows Terminal profile structure.'}
    $wt.schemes=@($wt.schemes | Where-Object {$_.name -notin @('Forge Graphite','Forge Ember')})+$schemes
    foreach($profile in $wt.profiles.list){
        if($profile.source -eq 'Windows.Terminal.PowershellCore'){$profile.colorScheme='Forge Graphite';if(-not $profile.font){$profile.font=@{}};$profile.font.face='Cascadia Mono';$profile.font.size=13}
    }
    $guid='{20784930-ff6a-435d-b208-c50a59112a25}'
    $wt.profiles.list=@($wt.profiles.list | Where-Object guid -ne $guid)+@(@{guid=$guid;name='Forge Command Center';commandline=('"'+$engine+'" -NoLogo');startingDirectory='%USERPROFILE%';colorScheme='Forge Ember';font=@{face='Cascadia Mono';size=13};padding='12';useAcrylic=$false;hidden=$false})
    $text=$wt | ConvertTo-Json -Depth 100
    $preview=Join-Path $previews 'windows-terminal.settings.json'
    [IO.File]::WriteAllText($preview,$text,[Text.UTF8Encoding]::new($false))
    $changes+=@{Target=$TerminalPath;Text=$text;Before=$before;Preview=$preview}
}
if(-not $TerminalOnly -and [IO.File]::Exists($CodePath)){
    $before=Get-ForgeFileHash $CodePath
    $code=Get-Content -LiteralPath $CodePath -Raw | ConvertFrom-Json -AsHashtable
    if(-not $code['terminal.integrated.profiles.windows']){$code['terminal.integrated.profiles.windows']=@{}}
    $code['terminal.integrated.profiles.windows']['Forge Command Center']=@{path=$engine;args=@('-NoLogo');icon='terminal-powershell'}
    $code['terminal.integrated.fontFamily']='Cascadia Mono, Consolas, monospace'
    if(-not $code['workbench.colorCustomizations']){$code['workbench.colorCustomizations']=@{}}
    $colors=@{background='#151719';foreground='#F2F0EB';selectionBackground='#303538';ansiBlack='#222528';ansiRed='#F08076';ansiGreen='#7EC89A';ansiYellow='#E0C46C';ansiBlue='#79A8CF';ansiMagenta='#CFB89C';ansiCyan='#79B8C8';ansiWhite='#DCD8D1';ansiBrightBlack='#929CA5';ansiBrightRed='#FF9A90';ansiBrightGreen='#9EDBAF';ansiBrightYellow='#FF9A55';ansiBrightBlue='#A4C8E8';ansiBrightMagenta='#E3C9AD';ansiBrightCyan='#A1D5DE';ansiBrightWhite='#F2F0EB'}
    foreach($key in $colors.Keys){$code['workbench.colorCustomizations']["terminal.$key"]=$colors[$key]}
    $code['workbench.colorCustomizations']['terminalCursor.foreground']='#F17B32'
    $text=$code | ConvertTo-Json -Depth 100
    $preview=Join-Path $previews 'vscode.settings.json'
    [IO.File]::WriteAllText($preview,$text,[Text.UTF8Encoding]::new($false))
    $changes+=@{Target=$CodePath;Text=$text;Before=$before;Preview=$preview}
}
if(-not $changes.Count){throw 'No supported terminal settings found.'}
$changes | ForEach-Object {[pscustomobject]@{Target=$_.Target;Preview=$_.Preview;Mode=if($Apply){'APPLY'}else{'PREVIEW ONLY'}}}
if(-not $Apply){Write-Host 'Previews prepared. Use -Apply only after approving the described terminal settings changes.';return}
$changes=@($changes | Where-Object {[IO.File]::ReadAllText($_.Target) -cne $_.Text})
if(-not $changes.Count){Write-Host 'Terminal settings are already current; the original recovery point is retained.';return}
if(-not $PSCmdlet.ShouldProcess(($changes.Target -join ', '),'Back up and apply coordinated terminal styling')){return}
foreach($change in $changes){if((Get-ForgeFileHash $change.Target) -ne $change.Before){throw 'Settings changed during preview. Rerun the command.'}}
$tx=New-ForgeTransaction $StateRoot @($changes.Target) 'terminals'
try{
    foreach($change in $changes){Write-ForgeTransactionFile $tx $change.Target $change.Text}
    $tx.Status='installed';Save-ForgeTransaction $tx
    $null=[IO.Directory]::CreateDirectory((Join-Path $StateRoot 'data'))
    $chainPath=Join-Path $StateRoot 'data\terminal-backups.json'
    $pointer=Join-Path $StateRoot 'data\terminal-backup.txt'
    $chain=@()
    if([IO.File]::Exists($chainPath)){$chain=@(Get-Content -LiteralPath $chainPath -Raw | ConvertFrom-Json)}
    elseif([IO.File]::Exists($pointer)){$chain=@([IO.File]::ReadAllText($pointer).Trim())}
    $chain=@($chain)+@($tx.Directory)
    [IO.File]::WriteAllText($chainPath,(ConvertTo-Json -InputObject $chain))
    [IO.File]::WriteAllText((Join-Path $StateRoot 'data\terminal-backup.txt'),$tx.Directory)
    Write-Host "Terminal styling installed. Backup: $($tx.Directory)"
}catch{Undo-ForgeTransaction $tx;throw}
