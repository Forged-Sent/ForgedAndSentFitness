function todo {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory,Position=0,ValueFromRemainingArguments)][string[]]$Text)
    $message=$Text -join ' ';Assert-ForgeCapture $message
    $project=(Get-ForgeContext).Root
    if($PSCmdlet.ShouldProcess('Local TODO list','Capture task')){
        Update-ForgeData 'todos' {
            param($items)
            $items=@($items);$max=($items | Measure-Object Id -Maximum).Maximum
            return ,@($items+@(@{Id=([int]$max+1);Text=$message;Project=$project;Created=[datetime]::UtcNow.ToString('o');Completed=$false;CompletedAt=$null}))
        }
        Write-Host 'Captured. Use todos to see the list.' -ForegroundColor Green
    }
}
function todos([switch]$All,[switch]$Project) {
    $root=(Get-ForgeContext).Root
    @(Read-ForgeData 'todos' @()) | Where-Object {($All -or -not $_.Completed) -and (-not $Project -or $_.Project -eq $root)} | ForEach-Object {[pscustomobject]@{Id=$_.Id;State=if($_.Completed){'done'}else{'OPEN'};Text=$_.Text;Project=$_.Project;Created=$_.Created}}
}
function done {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory,Position=0)][int[]]$Id)
    if($PSCmdlet.ShouldProcess(($Id -join ','),'Complete TODO')){
        Update-ForgeData 'todos' {param($items);foreach($item in $items){if($item.Id -in $Id){$item.Completed=$true;$item.CompletedAt=[datetime]::UtcNow.ToString('o')}};return ,@($items)}
    }
}
function note {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory,Position=0,ValueFromRemainingArguments)][string[]]$Text)
    $message=$Text -join ' ';Assert-ForgeCapture $message
    $project=(Get-ForgeContext).Root
    if($PSCmdlet.ShouldProcess('Local engineering notes','Capture note')){
        Update-ForgeData 'notes' {param($items);return ,@(@($items)+@(@{Id=[guid]::NewGuid().ToString('N');Text=$message;Project=$project;Created=[datetime]::UtcNow.ToString('o')}))}
        Write-Host 'Noted.' -ForegroundColor Green
    }
}
function notes([string]$Query='', [switch]$Project) {
    $root=(Get-ForgeContext).Root
    @(Read-ForgeData 'notes' @()) | Where-Object { $_.Text -like "*$Query*" -and (-not $Project -or $_.Project -eq $root) } | Sort-Object Created -Descending | ForEach-Object {[pscustomobject]@{Created=$_.Created;Text=$_.Text;Project=$_.Project}}
}
function recent-notes([ValidateRange(1,100)][int]$Count=10){notes | Select-Object -First $Count}
function session {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Position=0)][ValidateSet('summary','save','resume','list')][string]$Action='summary',[Parameter(Position=1)][string]$Text='')
    switch($Action){
        summary {
            $ctx=Get-ForgeContext
            [pscustomobject]@{Directory=$PWD.Path;Repository=$ctx.Root;OpenTasks=@(todos -Project).Count;CommandsThisSession=@(Get-History).Count;Next='session save "next action"'}
        }
        save {
            Assert-ForgeCapture $Text
            $ctx=Get-ForgeContext;$git=Get-ForgeGit $ctx;$path=$PWD.ProviderPath
            if($PSCmdlet.ShouldProcess('Session checkpoints','Save next action and location')){
                Update-ForgeData 'sessions' {param($items);return ,@(@(@{Id=[guid]::NewGuid().ToString('N');Path=$path;Branch=$git.Branch;Text=$Text;At=[datetime]::UtcNow.ToString('o')})+@($items | Select-Object -First 49))}
            }
        }
        list { @(Read-ForgeData 'sessions' @()) | ForEach-Object {[pscustomobject]$_} }
        resume {
            $rows=@(Read-ForgeData 'sessions' @() | ForEach-Object {[pscustomobject]@{Label=($_.At+'  '+$_.Text+'  '+$_.Path);Value=$_}})
            $item=Select-ForgeItem $rows 'RESUME' $Text
            if($item -and $PSCmdlet.ShouldProcess($item.Value.Path,'Resume folder')){
                Set-ForgeLocation $item.Value.Path
                Write-Host (Protect-ForgeText $item.Value.Text) -ForegroundColor Yellow
                Write-Host ("Saved branch: "+$item.Value.Branch+'. Branches are never switched by resume.') -ForegroundColor DarkGray
            }
        }
    }
}
function focus([ValidateRange(1,180)][int]$Minutes=25,[switch]$Stop){
    if($Stop){$script:FocusUntil=$null;Write-Host 'Focus timer cleared.';return}
    $script:FocusUntil=[datetime]::UtcNow.AddMinutes($Minutes)
    Write-Host "Focus until $($script:FocusUntil.ToLocalTime().ToString('t')). Remaining time appears in the prompt; this is a session timer, not a scheduled notification." -ForegroundColor Cyan
}
function recent-command([string]$Query='', [ValidateRange(1,100)][int]$Count=15) {
    Get-History | Where-Object { $_.CommandLine -like "*$Query*" -and -not (Test-ForgeSensitive $_.CommandLine) -and $_.CommandLine -notmatch '^\s*(note|todo|session\s+save)\b' } | Select-Object -Last $Count Id,CommandLine,ExecutionStatus
}
