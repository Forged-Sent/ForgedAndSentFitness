#requires -Version 7.5
[CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
param([ValidateSet('ripgrep','fzf')][string[]]$Tool=@('ripgrep','fzf'))
$ErrorActionPreference='Stop'
$packages=@{ripgrep='BurntSushi.ripgrep.MSVC';fzf='junegunn.fzf'}
$versions=@{ripgrep='15.2.0';fzf='0.75.0'}
foreach($name in $Tool){
    $id=$packages[$name]
    if($PSCmdlet.ShouldProcess($id,'Install optional user-scoped CLI with WinGet')){
        & winget.exe install --id $id --version $versions[$name] --exact --source winget --scope user --installer-type zip --architecture x64 --silent --disable-interactivity --accept-source-agreements --accept-package-agreements
        if($LASTEXITCODE -ne 0){throw "WinGet failed for $id. No elevated or alternative installer will be run automatically."}
    }
}
Write-Host 'Open a new shell or use refreshpath after a successful installation. Forge detects these tools on demand.'
