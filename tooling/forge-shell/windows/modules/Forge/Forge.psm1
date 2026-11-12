$script:PackageRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$script:StateRoot = if ($env:FORGE_HOME) { [IO.Path]::GetFullPath($env:FORGE_HOME) } else { $script:PackageRoot }
$script:LoadWatch = [Diagnostics.Stopwatch]::StartNew()
$script:Problems = [Collections.Generic.List[string]]::new()
$script:GitCache = @{}
$script:ContextCache = @{}
$script:LastDirectory = ''
$script:PriorDirectory = ''
$script:Settings = @{
    SchemaVersion=1; Theme='auto'; PromptMode='rich'; EnablePrompt=$true; EnableGitStatus=$true
    EnableEditing=$true; EnableDirectoryHistory=$true; EnableFzf=$true; NerdIcons=$false
    GitCacheSeconds=5; GitTimeoutMs=1500; DefaultProject=''; WorkspaceRoots=@(); FlutterSdk=''; PredictionView='InlineView'
}
. (Join-Path $PSScriptRoot 'Core.ps1')
Read-ForgeSettings
foreach ($part in @('Prompt','Editing','Catalog','Navigation','Productivity','Engineering','Project')) {
    . (Join-Path $PSScriptRoot "$part.ps1")
}
$script:IsAdmin = $false
try { $script:IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch { }
$script:Ansi = $Host.UI.SupportsVirtualTerminal -and -not $env:NO_COLOR -and -not [Console]::IsOutputRedirected
$script:OriginalPrompt = (Get-Item Function:\prompt -ErrorAction SilentlyContinue).ScriptBlock
if ($script:Settings.EnablePrompt) {
    # Retain the module session state for private helpers, unlike a function-local dot-source reload.
    $script:OwnedPrompt = $ExecutionContext.SessionState.Module.NewBoundScriptBlock({
        $forgeSuccess = $?; $forgeExit = $global:LASTEXITCODE
        Get-ForgePrompt -Succeeded $forgeSuccess -NativeExit $forgeExit
    })
    Set-Item Function:\global:prompt -Value $script:OwnedPrompt
}
Initialize-ForgeEditing
Initialize-ForgeCompletion
$ExecutionContext.SessionState.Module.OnRemove = {
    foreach ($entry in $script:GitCache.Values) { Stop-ForgeProbe $entry }
    if ((Get-Item Function:\prompt -ErrorAction SilentlyContinue).ScriptBlock -eq $script:OwnedPrompt -and $script:OriginalPrompt) {
        Set-Item Function:\global:prompt -Value $script:OriginalPrompt
    }
}
$script:LoadWatch.Stop()
$script:LoadMs = [math]::Round($script:LoadWatch.Elapsed.TotalMilliseconds, 1)
