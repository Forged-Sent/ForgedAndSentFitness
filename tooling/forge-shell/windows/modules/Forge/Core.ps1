function Test-ForgeSetting([string]$Name, $Value) {
    switch ($Name) {
        SchemaVersion { return $Value -is [long] -or $Value -is [int] }
        Theme { return $Value -in @('auto','normal','forged') }
        PromptMode { return $Value -in @('minimal','rich') }
        PredictionView { return $Value -in @('InlineView','ListView') }
        GitCacheSeconds { return ($Value -is [ValueType] -and $Value -ge 2 -and $Value -le 120) }
        GitTimeoutMs { return ($Value -is [ValueType] -and $Value -ge 100 -and $Value -le 5000) }
        WorkspaceRoots { return ($Value -is [array] -and @($Value | Where-Object { $_ -isnot [string] }).Count -eq 0) }
        { $_ -in @('DefaultProject','FlutterSdk') } { return $Value -is [string] }
        default { return $Value -is [bool] }
    }
}
function Read-ForgeSettings {
    $file = Join-Path $script:StateRoot 'config\settings.json'
    if (-not [IO.File]::Exists($file)) { return }
    try {
        $saved = [IO.File]::ReadAllText($file) | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        if ($saved -isnot [System.Collections.IDictionary] -or $saved.SchemaVersion -ne 1) { throw 'Unsupported configuration.' }
        foreach ($key in $script:Settings.Keys.Clone()) {
            if ($saved.Contains($key)) {
                if (Test-ForgeSetting $key $saved[$key]) { $script:Settings[$key] = $saved[$key] }
                else { $script:Problems.Add("Invalid setting: $key; using default.") }
            }
        }
    } catch { $script:Problems.Add('Configuration could not be read; using safe defaults. Original file retained.') }
}
function Write-ForgeJson([string]$Path, $Value) {
    $null = [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path))
    $tmp = $Path + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllText($tmp, (ConvertTo-Json -InputObject $Value -Depth 15), [Text.UTF8Encoding]::new($false))
        [IO.File]::Move($tmp, $Path, $true)
    } finally { if ([IO.File]::Exists($tmp)) { [IO.File]::Delete($tmp) } }
}
function Read-ForgeData([string]$Name, $Default = @()) {
    $file = Join-Path $script:StateRoot "data\$Name.json"
    if (-not [IO.File]::Exists($file)) { return $Default }
    try {
        $data=[IO.File]::ReadAllText($file) | ConvertFrom-Json -AsHashtable -NoEnumerate -ErrorAction Stop
        if($Name -eq 'bookmarks' -and $data -isnot [System.Collections.IDictionary]){throw 'Invalid object.'}
        if($Name -ne 'bookmarks' -and $data -isnot [array]){throw 'Invalid array.'}
        return $data
    }
    catch { throw "Cannot read $Name data. Original preserved; inspect it with forge doctor before writing." }
}
function Update-ForgeData([string]$Name, [scriptblock]$Update, $Default = @()) {
    $dir = Join-Path $script:StateRoot 'data'
    $null = [IO.Directory]::CreateDirectory($dir)
    $lock = $null
    try {
        for ($attempt=0; $attempt -lt 40 -and -not $lock; $attempt++) {
            try { $lock = [IO.File]::Open((Join-Path $dir "$Name.lock"), 'OpenOrCreate', 'ReadWrite', 'None') }
            catch [IO.IOException] { Start-Sleep -Milliseconds 25 }
        }
        if (-not $lock) { throw "Another shell is updating $Name. Try again." }
        $current = Read-ForgeData $Name $Default
        if($null -eq $current){$current=$Default}
        $next = & $Update $current
        $file = Join-Path $dir "$Name.json"
        if ([IO.File]::Exists($file)) { [IO.File]::Copy($file, "$file.previous", $true) }
        Write-ForgeJson $file $next
    } finally { if ($lock) { $lock.Dispose() } }
}
function Protect-ForgeText([string]$Text) {
    return ($Text -replace '[\x00-\x1f\x7f-\x9f]', '')
}
function Test-ForgeSensitive([string]$Text) {
    return $Text -match '(?i)(password|passwd|secret|api[_-]?key|access[_-]?key|token|authorization|bearer|connectionstring|private[_ -]?key|securestring|credential)|(?:sk-|gh[pousr]_|github_pat_|AKIA)[A-Za-z0-9_-]{12,}|https?://[^\s/]+:[^\s/]+@'
}
function Assert-ForgeCapture([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { throw 'Enter a short note or task.' }
    if (Test-ForgeSecretValue $Text) { throw 'This looks like sensitive text. Use your password manager; nothing was saved.' }
}
function Test-ForgeSecretValue([string]$Text) {
    return $Text -match '(?i)(?:password|passwd|secret|api[_-]?key|access[_-]?key|token|authorization|connectionstring)\s*[:=]\s*\S+|bearer\s+[A-Za-z0-9._-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(?:sk-|gh[pousr]_|github_pat_|AKIA)[A-Za-z0-9_-]{12,}|https?://[^\s/]+:[^\s/]+@'
}
function Get-ForgeCommand([string]$Name) {
    # Avoid module auto-loading while probing optional tools.
    return $ExecutionContext.SessionState.InvokeCommand.GetCommand($Name, [Management.Automation.CommandTypes]::Application)
}
function Get-ForgeContext([string]$Path = $PWD.ProviderPath) {
    if (-not $Path -or $PWD.Provider.Name -ne 'FileSystem') { return $null }
    $now = [datetime]::UtcNow
    if ($script:ContextCache.ContainsKey($Path) -and ($now - $script:ContextCache[$Path].At).TotalSeconds -lt 3) { return $script:ContextCache[$Path].Value }
    $cursor = [IO.DirectoryInfo]::new($Path)
    $context = $null
    $kind = ''
    for ($depth=0; $cursor -and $depth -lt 32; $depth++) {
        if (-not $kind) {
            if ([IO.File]::Exists((Join-Path $cursor.FullName 'pubspec.yaml'))) { $kind='Flutter' }
            elseif ([IO.File]::Exists((Join-Path $cursor.FullName 'package.json'))) { $kind='Node' }
            elseif ([IO.File]::Exists((Join-Path $cursor.FullName 'pyproject.toml')) -or [IO.File]::Exists((Join-Path $cursor.FullName 'requirements.txt'))) { $kind='Python' }
        }
        $marker = Join-Path $cursor.FullName '.git'
        if ([IO.Directory]::Exists($marker) -or [IO.File]::Exists($marker)) {
            try {
                $gitDir = $marker
                if ([IO.File]::Exists($marker)) {
                    $line = [IO.File]::ReadAllText($marker).Trim()
                    if ($line -notmatch '^gitdir:\s*(.+)$') { break }
                    $gitDir = [IO.Path]::GetFullPath($Matches[1], $cursor.FullName)
                }
                $common = $gitDir
                if ([IO.File]::Exists((Join-Path $gitDir 'commondir'))) { $common = [IO.Path]::GetFullPath([IO.File]::ReadAllText((Join-Path $gitDir 'commondir')).Trim(), $gitDir) }
                $cfg = Join-Path $common 'config'
                $isFs = [IO.File]::Exists($cfg) -and [IO.File]::ReadAllText($cfg) -match '(?im)^\s*url\s*=\s*(?:https://github\.com/|git@github\.com:)Forged-Sent/ForgedAndSentFitness(?:\.git)?\s*$'
                if (-not $kind -and [IO.File]::Exists((Join-Path $cursor.FullName 'mobile\pubspec.yaml'))) { $kind='Flutter' }
                $context = [pscustomobject]@{ Root=$cursor.FullName; GitDir=$gitDir; CommonDir=$common; IsForged=$isFs; Kind=$kind }
            } catch { }
            break
        }
        $cursor=$cursor.Parent
    }
    if (-not $context -and $kind) { $context=[pscustomobject]@{Root='';GitDir='';CommonDir='';IsForged=$false;Kind=$kind} }
    if ($script:ContextCache.Count -gt 64) { $script:ContextCache.Clear() }
    $script:ContextCache[$Path] = @{ At=$now; Value=$context }
    return $context
}
function Get-ForgeProject {
    $context = Get-ForgeContext
    if ($context -and $context.IsForged) { return $context.Root }
    $root = $script:Settings.DefaultProject
    if ($root -and [IO.Directory]::Exists($root)) {
        $context = Get-ForgeContext $root
        if ($context -and $context.IsForged) { return $context.Root }
    }
    throw 'No Forged & Sent checkout found. Enter one, then use forge project to remember it.'
}
function Write-ForgeHeading([string]$Text) { Write-Host (Protect-ForgeText $Text) -ForegroundColor Cyan }
function Invoke-ForgeNative([string]$File, [string[]]$Arguments, [string]$Directory = $PWD.ProviderPath) {
    if (-not $File) { throw 'Required tool is unavailable. Run fs doctor.' }
    Push-Location -LiteralPath $Directory
    try {
        & $File @Arguments
        $code = $LASTEXITCODE
        $global:LASTEXITCODE = $code
        if ($code -ne 0) { throw "Tool exited with code $code. Its diagnostic output is above; run err for a compact summary." }
    } finally { Pop-Location }
}
function reloadforge {
    $manifest = Join-Path $script:PackageRoot 'modules\Forge\Forge.psd1'
    & (Join-Path $script:PackageRoot 'scripts\Build-Module.ps1')
    Remove-Module Forge -Force -ErrorAction SilentlyContinue
    Import-Module $manifest -Global -Force -DisableNameChecking -ErrorAction Stop
}
