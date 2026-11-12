function Initialize-ForgeEditing {
    if (-not $script:Settings.EnableEditing -or $env:FORGE_NO_EDITING -eq '1') { return }
    # Extension hosts own their editor. Configure only an existing PSReadLine or a real ConsoleHost.
    if (-not (Get-Module PSReadLine) -and ($Host.Name -ne 'ConsoleHost' -or [Console]::IsInputRedirected)) { return }
    try {
        if($Host.Name -eq 'ConsoleHost' -and -not [Console]::IsInputRedirected){
            [Console]::InputEncoding=[Text.UTF8Encoding]::new($false)
            [Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
            $global:OutputEncoding=[Text.UTF8Encoding]::new($false)
        }
        Import-Module PSReadLine -ErrorAction Stop
        Set-PSReadLineOption -EditMode Windows -HistoryNoDuplicates -HistorySearchCursorMovesToEnd -MaximumHistoryCount 8000 -BellStyle None
        Set-PSReadLineOption -AddToHistoryHandler {
            param([string]$line)
            if ($line.StartsWith(' ') -or $line -match '(?i)(password|passwd|secret|api[_-]?key|access[_-]?key|token|authorization|bearer|connectionstring|private[_ -]?key|securestring|credential)|(?:sk-|gh[pousr]_|github_pat_|AKIA)[A-Za-z0-9_-]{12,}|https?://[^\s/]+:[^\s/]+@|^\s*(note|todo|session\s+save)\b') { return 'SkipAdding' }
            return 'MemoryAndFile'
        }
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -Function ReverseSearchHistory
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Chord 'Alt+h' -BriefDescription 'ForgeHelp' -LongDescription 'Insert searchable help without executing' -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine(); [Microsoft.PowerShell.PSConsoleReadLine]::Insert('helpme ') }
        Set-PSReadLineKeyHandler -Chord 'Alt+d' -BriefDescription 'ForgeDashboard' -LongDescription 'Insert dash without executing' -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine(); [Microsoft.PowerShell.PSConsoleReadLine]::Insert('dash') }
        if ($script:Ansi) {
            Set-PSReadLineOption -PredictionSource History -PredictionViewStyle $script:Settings.PredictionView
            Set-PSReadLineOption -Colors @{
                Command='#79B8C8'; Parameter='#E0C46C'; String='#7EC89A'; Number='#F2A15E'
                Variable='#CFB89C'; Operator='#E9E3CF'; Type='#79B8C8'; Comment='#929CA5'
                Error='#F08076'; InlinePrediction='#929CA5'; Selection="`e[48;2;48;53;56m`e[38;2;242;240;235m"
                ListPrediction='#929CA5'; ListPredictionSelected="`e[48;2;48;53;56m"
            }
            $PSStyle.Formatting.Error=$PSStyle.Foreground.FromRgb('#F08076')
            $PSStyle.Formatting.Warning=$PSStyle.Foreground.FromRgb('#E0C46C')
            $PSStyle.FileInfo.Directory=$PSStyle.Foreground.FromRgb('#79B8C8')
        }
    } catch { $script:Problems.Add('PSReadLine customization unavailable; native editing remains usable.') }
}
function Initialize-ForgeCompletion {
    Register-ArgumentCompleter -CommandName fs -ParameterName Action -ScriptBlock {
        param($commandName,$parameterName,$wordToComplete)
        foreach($value in @('go','mobile','status','doctor','run','test','analyze','format','firebase','preview','branch','pr','ci','diff','open','docs','architecture','help')){
            if($value -like "$wordToComplete*"){[Management.Automation.CompletionResult]::new($value,$value,'ParameterValue',"fs $value")}
        }
    }
    Register-ArgumentCompleter -CommandName forge -ParameterName Action -ScriptBlock {
        param($commandName,$parameterName,$wordToComplete)
        foreach($value in @('config','theme','prompt','project','context','doctor','test','benchmark','docs','reload')){
            if($value -like "$wordToComplete*"){[Management.Automation.CompletionResult]::new($value,$value,'ParameterValue',"forge $value")}
        }
    }
    $bookmarks=$ExecutionContext.SessionState.Module.NewBoundScriptBlock({
        param($commandName,$parameterName,$wordToComplete)
        try{foreach($key in (Get-ForgeBookmarks).Keys){if($key -like "$wordToComplete*"){[Management.Automation.CompletionResult]::new($key,$key,'ParameterValue','Saved folder')}}}catch{}
    })
    Register-ArgumentCompleter -CommandName jump,qa -ParameterName Name -ScriptBlock $bookmarks
    Register-ArgumentCompleter -CommandName z -ParameterName Query -ScriptBlock $bookmarks
}
