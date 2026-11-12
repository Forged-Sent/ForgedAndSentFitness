function Get-ForgeCatalog {
    if (-not $script:Catalog) { $script:Catalog=@([IO.File]::ReadAllText((Join-Path $script:PackageRoot 'config\catalog.json')) | ConvertFrom-Json) }
    return $script:Catalog
}
function Get-ForgeMatches([object[]]$Items, [string]$Query) {
    if (-not $Query) { return $Items }
    $pattern=(@($Query.ToCharArray() | ForEach-Object { [regex]::Escape([string]$_) }) -join '.*?')
    return @($Items | Where-Object { $_.Label -match $pattern } | Sort-Object -Stable @{Expression={if($_.Label.StartsWith($Query,[StringComparison]::OrdinalIgnoreCase)){0}else{1}}})
}
function Select-ForgeItem([object[]]$Items, [string]$Title='Choose', [string]$Query='') {
    if (-not $Items.Count) { Write-Host 'No matching items.' -ForegroundColor DarkGray; return }
    if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected -or $Host.Name -ne 'ConsoleHost') {
        Get-ForgeMatches $Items $Query | ForEach-Object { Write-Host (Protect-ForgeText $_.Label) }
        Write-Host 'Use the explicit command or name in this host.' -ForegroundColor DarkGray
        return
    }
    $fzf = if ($script:Settings.EnableFzf) { Get-ForgeCommand 'fzf.exe' }
    if ($fzf) {
        $rows=for($i=0;$i -lt $Items.Count;$i++){"$i`t$(Protect-ForgeText $Items[$i].Label)"}
        $picked=$rows | & $fzf.Source '--height=60%' '--layout=reverse' '--border=rounded' '--delimiter=\t' '--with-nth=2..' '--no-multi' '--prompt' "$Title > " '--query' $Query '--color=fg:#f2f0eb,bg:#151719,hl:#f17b32,fg+:#f2f0eb,bg+:#303538,hl+:#ff9a55,prompt:#79b8c8,pointer:#f17b32,marker:#7ec89a'
        if ($LASTEXITCODE -eq 0 -and $picked -match '^(\d+)\t' -and [int]$Matches[1] -lt $Items.Count) { return $Items[[int]$Matches[1]] }
        return
    }
    if (-not $script:Ansi) {
        $filteredItems=@(Get-ForgeMatches $Items $Query)
        for($i=0;$i -lt [math]::Min(25,$filteredItems.Count);$i++){Write-Host ("{0,2}  {1}" -f ($i+1), (Protect-ForgeText $filteredItems[$i].Label))}
        $choice=Read-Host "$Title (number; blank cancels)"
        $n=0
        if ([int]::TryParse($choice,[ref]$n) -and $n -ge 1 -and $n -le [math]::Min(25,$filteredItems.Count)) { return $filteredItems[$n-1] }
        return
    }
    $selected=0; $painted=0; $result=$null; $cursorVisible=[Console]::CursorVisible
    try {
        [Console]::CursorVisible=$false
        while($true) {
            $filteredItems=@(Get-ForgeMatches $Items $Query)
            $selected=[math]::Max(0,[math]::Min($selected,$filteredItems.Count-1))
            $height=[math]::Max(2,[math]::Min(10,[Console]::WindowHeight-5))
            $offset=[math]::Max(0,$selected-$height+1)
            if($painted){[Console]::Write("`e[${painted}A")}
            $width=[math]::Max(10,[Console]::WindowWidth-2)
            $header="  $Title  / $Query"
            [Console]::Write("`e[2K`r`e[38;2;121;184;200m"+$header.Substring(0,[math]::Min($width,$header.Length))+"`e[0m`n")
            for($i=0;$i -lt $height;$i++) {
                $idx=$offset+$i; $line=''; $color=''
                if($idx -lt $filteredItems.Count) {
                    $prefix=if($idx -eq $selected){'> '}else{'  '}
                    $line=$prefix+(Protect-ForgeText $filteredItems[$idx].Label)
                    if($idx -eq $selected){$color="`e[48;2;48;53;56m`e[38;2;242;240;235m"}
                }
                [Console]::Write("`e[2K`r"+$color+$line.Substring(0,[math]::Min($width,$line.Length))+"`e[0m`n")
            }
            [Console]::Write("`e[2K`r`e[38;2;146;156;165m  type to filter | arrows | Enter | Esc`e[0m`n")
            $painted=$height+2
            $key=[Console]::ReadKey($true)
            if($key.Key -eq 'Escape' -or ($key.Key -eq 'C' -and ($key.Modifiers -band [ConsoleModifiers]::Control))){break}
            if($key.Key -eq 'Enter'){if($filteredItems.Count){$result=$filteredItems[$selected]};break}
            switch($key.Key){
                UpArrow {$selected=[math]::Max(0,$selected-1)}
                DownArrow {$selected=[math]::Min($filteredItems.Count-1,$selected+1)}
                Backspace {if($Query.Length){$Query=$Query.Substring(0,$Query.Length-1);$selected=0}}
                default {if(-not [char]::IsControl($key.KeyChar)){$Query+=$key.KeyChar;$selected=0}}
            }
        }
    } finally {
        if($painted){[Console]::Write("`e[${painted}A");for($i=0;$i -lt $painted;$i++){[Console]::Write("`e[2K`r`n")};[Console]::Write("`e[${painted}A")}
        [Console]::CursorVisible=$cursorVisible
    }
    return $result
}
function helpme {
    [CmdletBinding()]
    param([Parameter(Position=0)][string]$Query='', [switch]$Raw)
    $items=@(Get-ForgeCatalog | Where-Object { ($_.Command+' '+$_.Category+' '+$_.Description+' '+$_.Example) -like "*$Query*" })
    if($Raw){return $items}
    Write-ForgeHeading $(if($Query){"COMMANDS / $Query"}else{'COMMANDS / start here'})
    if(-not $Query){$items=@($items | Where-Object First)}
    $items | Select-Object Command,Description,Example | Format-Table -AutoSize -Wrap
    Write-Host 'helpme <topic> searches everything; dash opens the menu; keys shows shortcuts.' -ForegroundColor DarkGray
    $ctx=Get-ForgeContext
    if($ctx.IsForged){Write-Host 'Here: fs status / fs doctor / fs docs / fs run -WhatIf' -ForegroundColor DarkGray}
}
function dash {
    [CmdletBinding()]
    param([Parameter(Position=0)][string]$Category='')
    if(-not $Category){
        $categories=@('Projects','Git','Forged & Sent','Flutter/Firebase','Files and navigation','Notes and TODOs','System tools','Recent activity','Settings and themes','Help and keyboard shortcuts')
        $item=Select-ForgeItem @($categories | ForEach-Object {[pscustomobject]@{Label=$_;Value=$_}}) 'COMMAND CENTER'
        if(-not $item){return};$Category=$item.Value
    }
    if($Category -eq 'Projects'){projects;return}
    $rows=@(Get-ForgeCatalog | Where-Object Category -eq $Category | ForEach-Object {[pscustomobject]@{Label=($_.Command.PadRight(19)+' '+$_.Description);Value=$_.Action;Example=$_.Example}})
    $item=Select-ForgeItem $rows $Category
    if(-not $item){return}
    Write-Host ("  " + $item.Example) -ForegroundColor DarkGray
    switch($item.Value){
        fs { fs }
        fs-status { fs status }
        fs-doctor { fs doctor }
        fs-go { fs go }
        fs-mobile { fs mobile }
        fs-run { fs run -Confirm }
        fs-emulator { fs run -Emulator -Confirm }
        fs-test { fs test -Confirm }
        fs-analyze { fs analyze -Confirm }
        fs-format { fs format }
        fs-firebase { fs firebase -Confirm }
        fs-preview { fs preview -Confirm }
        fs-branch { fs branch }
        fs-pr { fs pr }
        fs-ci { fs ci }
        fs-diff { fs diff }
        fs-open { fs open -Confirm }
        fs-docs { fs docs }
        fs-architecture { fs architecture }
        jump { jump }
        projects { projects }
        marks { marks }
        mark { $text=Read-Host 'Bookmark name for this folder';if($text){mark $text} }
        find-file { $text=Read-Host 'Filename or pattern';if($text){ff $text} }
        find-text { $text=Read-Host 'Text or regular expression';if($text){ftext $text} }
        ll { ll }
        todo { $text=Read-Host 'Quick task (blank cancels)';if($text){todo $text} }
        note { $text=Read-Host 'Engineering note (blank cancels)';if($text){note $text} }
        todos { todos }
        done {
            $rows=@(todos | ForEach-Object {[pscustomobject]@{Label=('#'+$_.Id+'  '+$_.Text);Value=$_.Id}})
            $task=Select-ForgeItem $rows 'COMPLETE A TASK';if($task){done $task.Value}
        }
        notes { notes }
        session { session }
        resume { session resume }
        recent { recent-command }
        focus { focus }
        port { port }
        path { pathcheck }
        health { ph }
        test { ptest }
        keys { keys }
        help { helpme }
        config { forge config }
        theme { $pick=Select-ForgeItem @('auto','normal','forged' | ForEach-Object {[pscustomobject]@{Label=$_;Value=$_}}) 'PROMPT ACCENT';if($pick){forge theme $pick.Value} }
        prompt { $pick=Select-ForgeItem @('minimal','rich' | ForEach-Object {[pscustomobject]@{Label=$_;Value=$_}}) 'PROMPT DETAIL';if($pick){forge prompt $pick.Value} }
        default { Write-Host 'Use the example above with your own text or path.' -ForegroundColor Cyan }
    }
}
function keys {
    [pscustomobject]@{Key='Tab';Action='Completion menu'}
    [pscustomobject]@{Key='Up / Down';Action='History matching the current prefix'}
    [pscustomobject]@{Key='Ctrl+R';Action='Search command history'}
    [pscustomobject]@{Key='F2';Action='Switch inline / list predictions (PSReadLine)'}
    [pscustomobject]@{Key='Alt+H';Action='Insert helpme; press Enter when ready'}
    [pscustomobject]@{Key='Alt+D';Action='Insert dash; press Enter when ready'}
    [pscustomobject]@{Key='Leading space';Action='Keep this input out of PSReadLine saved history'}
    if(Get-Module PSReadLine){Get-PSReadLineKeyHandler -Bound | Where-Object Key -in @('Tab','UpArrow','DownArrow','Ctrl+r','Alt+h','Alt+d') | Select-Object Key,Function}
    else {Write-Host 'This host is not currently using PSReadLine; shortcut bindings are inactive.' -ForegroundColor DarkGray}
}
function forge {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Position=0)][string]$Action='help', [Parameter(Position=1)][string]$Value, [Parameter(Position=2)]$SettingValue)
    switch($Action){
        help { helpme 'Settings and themes' }
        config {
            if(-not $Value){$script:Settings.GetEnumerator() | Sort-Object Key | Select-Object @{n='Setting';e={$_.Key}},Value;return}
            if(-not $script:Settings.ContainsKey($Value)){throw 'Unknown setting; use forge config.'}
            if($SettingValue -is [string] -and $SettingValue -match '^(true|false)$'){$SettingValue=[bool]::Parse($SettingValue)}
            if(-not (Test-ForgeSetting $Value $SettingValue)){throw 'Invalid value. See README.md customization examples.'}
            if($PSCmdlet.ShouldProcess($Value,'Save Forge setting')){$script:Settings[$Value]=$SettingValue;Write-ForgeJson (Join-Path $script:StateRoot 'config\settings.json') $script:Settings;Write-Host 'Saved. Run reloadforge for editing or prompt enable/disable changes.'}
        }
        theme {
            if(-not $Value){Write-Host "Theme: $($script:Settings.Theme). Choose: forge theme auto / normal / forged";return}
            forge config Theme $Value -WhatIf:$WhatIfPreference
        }
        prompt {
            if(-not $Value){Write-Host "Prompt: $($script:Settings.PromptMode). Choose: forge prompt minimal / rich";return}
            forge config PromptMode $Value -WhatIf:$WhatIfPreference
        }
        project {
            $ctx=Get-ForgeContext
            if(-not $ctx.IsForged){throw 'Enter the Forged & Sent checkout you want to remember first.'}
            forge config DefaultProject $ctx.Root -WhatIf:$WhatIfPreference
        }
        context { Get-ForgeContext }
        doctor { ph }
        test { ptest }
        benchmark { & (Join-Path $script:PackageRoot 'tests\Benchmark.ps1') }
        docs { Invoke-Item -LiteralPath (Join-Path $script:PackageRoot 'README.md') }
        reload { reloadforge }
        default { throw "Unknown Forge action '$Action'. Use helpme settings." }
    }
}
