#requires -Version 7.6
# Shared optional shell selection and installation.
function Test-FSEngineeringShellInteractive {
    return (-not $env:CI -and -not [Console]::IsInputRedirected -and [Environment]::UserInteractive)
}

function Select-FSEngineeringShell {
    $choice=@{Apply=$false;Style='None';Tools=$false}
    # Piped input, CI and unattended setup must never change a user's shell.
    if(-not (Test-FSEngineeringShellInteractive)){return $choice}
    Write-Host ''
    Write-Host 'Optional Forge Shell: command menu, bookmarks, tasks, notes and focus timer for any project.'
    Write-Host 'Installs in your home folder and adds a backed-up PowerShell 7 profile loader.'
    if((Read-Host 'Would you like the ADHD-friendly engineering shell? [y/N]') -notmatch '^(y|yes)$'){return $choice}
    $choice.Apply=$true
    Write-Host 'Optional colors: 1 = Windows Terminal, 2 = Terminal + VS Code terminals, Enter = keep current colors.'
    switch(Read-Host 'Colors [none]'){
        '1' {$choice.Style='Terminal'}
        '2' {$choice.Style='TerminalAndVSCode'}
    }
    $choice.Tools=((Read-Host 'Also install ripgrep and fzf with user-scoped WinGet? [y/N]') -match '^(y|yes)$')
    return $choice
}

function Install-FSEngineeringShell {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$InstallRoot=(Join-Path $HOME '.config\powershell'),
        [string]$ProfilePath=$PROFILE.CurrentUserAllHosts,
        [string]$ProjectRoot=(Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
        [ValidateSet('None','Terminal','TerminalAndVSCode')][string]$Style='None',
        [switch]$Tools
    )
    $ErrorActionPreference='Stop'
    $source=Join-Path $PSScriptRoot '..\forge-shell\windows'
    $destination=[IO.Path]::GetFullPath($InstallRoot).TrimEnd('\','/')
    $checkout=[IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\','/')
    if($destination -eq $checkout -or $destination.StartsWith($checkout+'\',[StringComparison]::OrdinalIgnoreCase)){
        throw 'Install the personal shell outside the repository, normally in $HOME\.config\powershell.'
    }
    & (Join-Path $source 'scripts\Build-Module.ps1') -Check
    . (Join-Path $source 'scripts\Transactions.ps1')
    $writes=[ordered]@{}
    foreach($file in Get-ChildItem -LiteralPath $source -Recurse -File){
        $relative=[IO.Path]::GetRelativePath($source,$file.FullName)
        if($relative -match '(^|[\\/])(data|backups|proposed|__pycache__)([\\/]|$)' -or $file.Name -eq '.gitignore'){continue}
        $target=Join-Path $destination $relative
        if($relative -eq 'config\settings.json' -or $relative -eq 'config/settings.json'){
            if(Test-Path -LiteralPath $target){continue} # Preserve personal preferences and remembered projects.
            $settings=Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
            $settings.DefaultProject=$checkout
            $settings.WorkspaceRoots=@((Split-Path -Parent $checkout))
            $settings.FlutterSdk=Join-Path $HOME 'develop\flutter'
            $content=($settings | ConvertTo-Json -Depth 8)+"`n"
        }else{$content=[IO.File]::ReadAllText($file.FullName)}
        if(-not [IO.File]::Exists($target) -or [IO.File]::ReadAllText($target) -cne $content){$writes[$target]=$content}
    }
    if(-not $PSCmdlet.ShouldProcess($destination,"Back up/install $($writes.Count) package files and activate the PowerShell profile at $ProfilePath")){return}
    $tx=$null
    try{
        if($writes.Count){
            $tx=New-ForgeTransaction $destination @($writes.Keys) 'package'
            foreach($target in $writes.Keys){Write-ForgeTransactionFile $tx $target $writes[$target]}
        }
        & (Join-Path $destination 'Install.ps1') -ProfilePath $ProfilePath -StateRoot $destination
        if($tx){$tx.Status='installed';Save-ForgeTransaction $tx;Write-Host "Package backup: $($tx.Directory)"}
    }catch{if($tx){Undo-ForgeTransaction $tx};throw}
    if($Style -ne 'None'){
        try{
            $styleArgs=@{Apply=$true;StateRoot=$destination}
            if($Style -eq 'Terminal'){$styleArgs.TerminalOnly=$true}
            & (Join-Path $destination 'Configure-Terminals.ps1') @styleArgs
        }catch{Write-Warning "Shell installed; optional styling needs attention: $($_.Exception.Message)"}
    }
    if($Tools){
        try{& (Join-Path $destination 'Install-OptionalTools.ps1') -Confirm:$false}
        catch{Write-Warning "Shell installed; optional tools need attention: $($_.Exception.Message)"}
    }
    Write-Host 'Open a new PowerShell 7 tab, then type dash. Guide: docs/development/SHELL-SETUP.md'
}
