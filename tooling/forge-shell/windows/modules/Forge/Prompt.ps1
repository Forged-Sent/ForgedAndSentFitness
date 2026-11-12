function Stop-ForgeProbe($Entry) {
    if ($Entry.Process) {
        try { if (-not $Entry.Process.HasExited) { $Entry.Process.Kill() } } catch { }
        $Entry.Process.Dispose(); $Entry.Process=$null
    }
}
function ConvertFrom-ForgeStatus([string]$Text) {
    $state = @{ Staged=0; Changed=0; Untracked=0; Ahead=0; Behind=0; Conflict=0 }
    foreach ($line in ($Text -split "`n")) {
        if ($line -match '^# branch.ab \+(\d+) -(\d+)') { $state.Ahead=[int]$Matches[1]; $state.Behind=[int]$Matches[2] }
        elseif ($line -match '^[12] ([^ ]{2}) ') {
            if ($Matches[1][0] -ne '.') { $state.Staged++ }
            if ($Matches[1][1] -ne '.') { $state.Changed++ }
        } elseif ($line.StartsWith('? ')) { $state.Untracked++ }
        elseif ($line.StartsWith('u ')) { $state.Conflict++ }
    }
    return $state
}
function Get-ForgeGit($Context) {
    if (-not $Context.GitDir) { return $null }
    try {
        $head = [IO.File]::ReadAllText((Join-Path $Context.GitDir 'HEAD')).Trim()
        $branch = if ($head.StartsWith('ref: refs/heads/')) { $head.Substring(16) } else { '@' + $head.Substring(0, [math]::Min(8,$head.Length)) }
    } catch { return $null }
    $root = $Context.Root; $now = [datetime]::UtcNow
    if (-not $script:GitCache.ContainsKey($root)) {
        if ($script:GitCache.Count -ge 16) { foreach ($v in $script:GitCache.Values) { Stop-ForgeProbe $v }; $script:GitCache.Clear() }
        $script:GitCache[$root] = @{ Head=$head; Process=$null; At=[datetime]::MinValue; Started=$now; State=$null; Failed=$false }
    }
    $entry = $script:GitCache[$root]
    if ($entry.Head -ne $head) { Stop-ForgeProbe $entry; $entry.State=$null; $entry.At=[datetime]::MinValue; $entry.Head=$head }
    if ($entry.Process) {
        if ($entry.Process.HasExited -and $entry.Out.IsCompleted -and $entry.Err.IsCompleted) {
            if ($entry.Process.ExitCode -eq 0) { $entry.State=ConvertFrom-ForgeStatus $entry.Out.Result; $entry.Failed=$false }
            else { $entry.Failed=$true }
            $entry.At=$now; Stop-ForgeProbe $entry
        } elseif (($now-$entry.Started).TotalMilliseconds -gt $script:Settings.GitTimeoutMs) {
            Stop-ForgeProbe $entry; $entry.At=$now; $entry.Failed=$true
        }
    }
    if ($script:Settings.EnableGitStatus -and $script:Settings.PromptMode -eq 'rich' -and -not $entry.Process -and ($now-$entry.At).TotalSeconds -ge $script:Settings.GitCacheSeconds) {
        $git = Get-ForgeCommand 'git.exe'
        if ($git) {
            try {
                $psi = [Diagnostics.ProcessStartInfo]::new($git.Source)
                $psi.UseShellExecute=$false; $psi.CreateNoWindow=$true
                $psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true
                $psi.WorkingDirectory=$root
                foreach ($arg in @('--no-optional-locks','-c','core.fsmonitor=false','status','--porcelain=v2','--branch','--untracked-files=normal')) { $psi.ArgumentList.Add($arg) }
                $entry.Process=[Diagnostics.Process]::Start($psi)
                $entry.Out=$entry.Process.StandardOutput.ReadToEndAsync(); $entry.Err=$entry.Process.StandardError.ReadToEndAsync()
                $entry.Started=$now
            } catch { $entry.At=$now; $entry.Failed=$true; Stop-ForgeProbe $entry }
        } else { $entry.At=$now; $entry.Failed=$true }
    }
    return @{ Branch=(Protect-ForgeText $branch); State=$entry.State; Pending=[bool]$entry.Process; Failed=$entry.Failed }
}
function Get-ForgePrompt([bool]$Succeeded=$true, [int]$NativeExit=0) {
    try {
        $path = $PWD.Path
        $context = Get-ForgeContext
        if ($PWD.Provider.Name -eq 'FileSystem' -and $script:LastDirectory -ne $path) {
            $script:PriorDirectory=$script:LastDirectory; $script:LastDirectory=$path
            if ($script:Settings.EnableDirectoryHistory) { try { Add-ForgeVisit $path $context.Root } catch { } }
        }
        $forged = $script:Settings.Theme -eq 'forged' -or ($script:Settings.Theme -eq 'auto' -and $context.IsForged)
        $accent = if ($forged) { '#F17B32' } else { '#79B8C8' }
        $a=''; $muted=''; $green=''; $gold=''; $red=''; $reset=''
        if ($script:Ansi) {
            $a=$PSStyle.Foreground.FromRgb($accent); $muted=$PSStyle.Foreground.FromRgb('#929CA5')
            $green=$PSStyle.Foreground.FromRgb('#7EC89A'); $gold=$PSStyle.Foreground.FromRgb('#E0C46C')
            $red=$PSStyle.Foreground.FromRgb('#F08076'); $reset=$PSStyle.Reset
        }
        $label = if ($context.IsForged) { 'FORGED & SENT' } elseif ($context.Root) { Split-Path -Leaf $context.Root } else { 'ENGINEERING' }
        $display = if ($context.Root) { [IO.Path]::GetRelativePath($context.Root,$path) } elseif ($path.StartsWith($HOME,[StringComparison]::OrdinalIgnoreCase)) { '~'+$path.Substring($HOME.Length) } else { $path }
        if ($display -eq '.') { $display=Split-Path -Leaf $path }
        if ($display.Length -gt 65) { $display='...'+$display.Substring($display.Length-62) }
        $display=Protect-ForgeText $display
        $parts=[Collections.Generic.List[string]]::new()
        $parts.Add("${a}$(Protect-ForgeText $label)${reset}")
        $parts.Add($display)
        $git=Get-ForgeGit $context
        if ($git) {
            $icon=if ($script:Settings.NerdIcons -and $script:Ansi) { [char]0xe0a0+' ' } else { '' }
            $g="${muted}${icon}$($git.Branch)${reset}"
            if ($script:Settings.PromptMode -eq 'rich' -and $script:Settings.EnableGitStatus) {
                if ($git.Failed) { $g+=" ${muted}[status unavailable]${reset}" }
                elseif ($git.State) {
                    $s=$git.State; $dirty=$s.Staged+$s.Changed+$s.Untracked+$s.Conflict
                    if ($dirty -eq 0) { $g+=" ${green}clean${reset}" }
                    else { $g+=" ${gold}~$($s.Changed) +$($s.Staged) ?$($s.Untracked)${reset}" }
                    if ($s.Conflict) { $g+=" ${red}CONFLICT:$($s.Conflict)${reset}" }
                    if ($s.Ahead) { $g+=" ${gold}ahead:$($s.Ahead)${reset}" }
                    if ($s.Behind) { $g+=" ${gold}behind:$($s.Behind)${reset}" }
                    if ($git.Pending) { $g+="${muted}*${reset}" }
                } else { $g+=" ${muted}[checking]${reset}" }
            }
            $parts.Add($g)
        }
        if ($script:Settings.PromptMode -eq 'rich' -and $context.Kind) { $parts.Add("${muted}$($context.Kind)${reset}") }
        if ($env:VIRTUAL_ENV) { $parts.Add("${muted}venv:$(Protect-ForgeText (Split-Path -Leaf $env:VIRTUAL_ENV))${reset}") }
        if ($script:IsAdmin) { $parts.Add("${gold}ADMIN${reset}") }
        if (-not $Succeeded) { $parts.Add("${red}! failed$(if ($NativeExit) { ' '+$NativeExit })${reset}") }
        if ($script:FocusUntil -and $script:FocusUntil -gt [datetime]::UtcNow) { $parts.Add("${gold}$([math]::Ceiling(($script:FocusUntil-[datetime]::UtcNow).TotalMinutes))m focus${reset}") }
        elseif ($script:FocusUntil) { $parts.Add("${green}focus complete${reset}") }
        $line=$parts -join " ${muted}|${reset} "
        if ($script:Settings.PromptMode -eq 'minimal') { return "$line ${a}>${reset} " }
        return "$line`n${a}>${reset} "
    } catch { return "PS $($PWD.Path)> " }
}
