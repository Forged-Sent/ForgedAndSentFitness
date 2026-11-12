function Get-ForgeBookmarks {
    $defaults=@{home=$HOME; desktop=[Environment]::GetFolderPath('Desktop'); documents=[Environment]::GetFolderPath('MyDocuments'); downloads=(Join-Path $HOME 'Downloads')}
    if($env:OneDrive){$defaults.onedrive=$env:OneDrive}
    if($script:Settings.DefaultProject){$defaults.fs=$script:Settings.DefaultProject}
    if($script:Settings.WorkspaceRoots.Count){$defaults.work=$script:Settings.WorkspaceRoots[0]}
    $saved=Read-ForgeData 'bookmarks' @{}
    if($saved -isnot [System.Collections.IDictionary]){throw 'Bookmarks must be a JSON object; original retained.'}
    foreach($key in $saved.Keys){$defaults[$key]=[string]$saved[$key]}
    return $defaults
}
function Add-ForgeVisit([string]$Path,[string]$Repo='') {
    if(-not [IO.Directory]::Exists($Path)){return}
    Update-ForgeData 'visits' {
        param($items)
        $items=@($items); $old=@($items | Where-Object Path -eq $Path | Select-Object -First 1)
        $count=if($old.Count){[int]$old[0].Count+1}else{1}
        $row=@{Path=$Path;Repo=$Repo;Count=$count;LastUtc=[datetime]::UtcNow.ToString('o')}
        return ,@(@($row)+@($items | Where-Object Path -ne $Path | Sort-Object LastUtc -Descending | Select-Object -First 199))
    }
}
function Set-ForgeLocation([string]$Path) {
    if(-not (Test-Path -LiteralPath $Path -PathType Container)){throw "Folder unavailable: $Path"}
    $previous=$PWD.ProviderPath
    Set-Location -LiteralPath $Path
    $script:PriorDirectory=$previous; $script:LastDirectory=$PWD.ProviderPath
    if($script:Settings.EnableDirectoryHistory){try{Add-ForgeVisit $PWD.ProviderPath (Get-ForgeContext).Root}catch{Write-Warning 'Directory history could not be saved. Navigation succeeded.'}}
}
function mark {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory,Position=0)][ValidatePattern('^[a-zA-Z][a-zA-Z0-9_-]{0,39}$')][string]$Name,[Parameter(Position=1)][string]$Path=$PWD.ProviderPath)
    $resolved=(Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
    if(-not [IO.Directory]::Exists($resolved)){throw 'Bookmarks must point to folders.'}
    $bookmarkName=$Name.ToLowerInvariant()
    if($PSCmdlet.ShouldProcess($Name,"Remember $resolved")){
        Update-ForgeData 'bookmarks' {param($data);$data[$bookmarkName]=$resolved;return $data} @{}
        marks $Name
    }
}
function marks([string]$Query='') {
    (Get-ForgeBookmarks).GetEnumerator() | Where-Object Key -like "*$Query*" | Sort-Object Key | ForEach-Object {[pscustomobject]@{Name=$_.Key;Path=$_.Value;Exists=[IO.Directory]::Exists($_.Value)}}
}
function unmark {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    param([Parameter(Mandatory)][string]$Name)
    $bookmarkName=$Name
    if($PSCmdlet.ShouldProcess($Name,'Forget saved bookmark (built-in quick folders remain)')){Update-ForgeData 'bookmarks' {param($data);$null=$data.Remove($bookmarkName);return $data} @{}}
}
function jump {
    [CmdletBinding()]
    param([Parameter(Position=0)][string]$Name='')
    if($Name -and (Test-Path -LiteralPath $Name -PathType Container)){Set-ForgeLocation $Name;return}
    $bookmarks=Get-ForgeBookmarks
    if($Name -and $bookmarks.ContainsKey($Name)){Set-ForgeLocation $bookmarks[$Name];return}
    $items=@($bookmarks.GetEnumerator() | Where-Object {[IO.Directory]::Exists($_.Value)} | Sort-Object Key | ForEach-Object {[pscustomobject]@{Label=($_.Key.PadRight(15)+' '+$_.Value);Value=$_.Value}})
    $visits=@(Read-ForgeData 'visits' @())
    $items+=@($visits | Where-Object {[IO.Directory]::Exists($_.Path)} | Sort-Object @{Expression={([int]$_.Count)/[math]::Max(1,([datetime]::UtcNow-[datetime]$_.LastUtc).TotalDays+1)};Descending=$true} | ForEach-Object {[pscustomobject]@{Label=$_.Path;Value=$_.Path}})
    $seen=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $items=@($items | Where-Object {$seen.Add($_.Value)})
    $filteredItems=@(Get-ForgeMatches $items $Name)
    if($Name -and $filteredItems.Count -eq 1){Set-ForgeLocation $filteredItems[0].Value;return}
    $choice=Select-ForgeItem $items 'JUMP' $Name
    if($choice){Set-ForgeLocation $choice.Value}
}
function z([string]$Query=''){jump $Query}
function qa([string]$Name=''){jump $Name}
function back { if($script:PriorDirectory){Set-ForgeLocation $script:PriorDirectory}else{Write-Host 'No previous folder in this shell.'} }
function up([ValidateRange(1,20)][int]$Count=1){$p=$PWD.ProviderPath;for($i=0;$i -lt $Count;$i++){$parent=[IO.Directory]::GetParent($p);if(-not $parent){break};$p=$parent.FullName};Set-ForgeLocation $p}
function mkcd {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory,Position=0)][string]$Path)
    if($PSCmdlet.ShouldProcess($Path,'Create folder and enter')){$full=$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);$null=[IO.Directory]::CreateDirectory($full);Set-ForgeLocation $full}
}
function projects {
    [CmdletBinding()]
    param([string]$Query='', [switch]$List)
    $found=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach($visit in @(Read-ForgeData 'visits' @())){if($visit.Repo -and [IO.Directory]::Exists($visit.Repo)){$null=$found.Add($visit.Repo)}}
    foreach($root in $script:Settings.WorkspaceRoots){
        if(-not [IO.Directory]::Exists($root)){continue}
        $candidates=@(Get-Item -LiteralPath $root)+@(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue | Where-Object { -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) })
        foreach($dir in $candidates){if(Test-Path -LiteralPath (Join-Path $dir.FullName '.git')){$null=$found.Add($dir.FullName)}}
    }
    $items=@($found | Sort-Object | ForEach-Object {[pscustomobject]@{Label=(Split-Path -Leaf $_).PadRight(45)+' '+$_;Value=$_}})
    if($List){return $items | Select-Object @{n='Project';e={Split-Path -Leaf $_.Value}},@{n='Path';e={$_.Value}}}
    $choice=Select-ForgeItem $items 'PROJECTS' $Query
    if($choice){Set-ForgeLocation $choice.Value}
}
function Get-ForgeFiles([string]$Path, [int]$Limit=20000) {
    $queue=[Collections.Generic.Queue[string]]::new();$queue.Enqueue((Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath)
    $count=0
    while($queue.Count -and $count -lt $Limit){
        foreach($item in Get-ChildItem -LiteralPath $queue.Dequeue() -Force -ErrorAction SilentlyContinue){
            if($item.Attributes -band [IO.FileAttributes]::ReparsePoint){continue}
            if($item.PSIsContainer){if($item.Name -notin @('.git','node_modules','build','.dart_tool','.venv','venv','.gradle','.idea')){$queue.Enqueue($item.FullName)}}
            else {$item;$count++;if($count -ge $Limit){break}}
        }
    }
    if($queue.Count){Write-Warning "Search reached $Limit files. Narrow the path or install ripgrep for larger trees."}
}
function ff {
    [CmdletBinding()]
    param([Parameter(Position=0)][string]$Query='*',[Parameter(Position=1)][string]$Path='.')
    $pattern=if($Query -match '[*?]'){$Query}else{"*$Query*"}
    $rg=Get-ForgeCommand 'rg.exe'
    if($rg){& $rg.Source --files --hidden --glob '!.git/**' --glob '!node_modules/**' --glob '!build/**' -- $Path | Where-Object {$_ -like $pattern}}
    else {Get-ForgeFiles $Path | Where-Object Name -like $pattern | Select-Object -ExpandProperty FullName}
}
function ftext {
    [CmdletBinding()]
    param([Parameter(Mandatory,Position=0)][string]$Query,[Parameter(Position=1)][string]$Path='.')
    $rg=Get-ForgeCommand 'rg.exe'
    if($rg){& $rg.Source --line-number --smart-case --color=auto --glob '!.env*' --glob '!*.pem' --glob '!*.key' --glob '!*-account*.json' -- $Query $Path;return}
    $files=if(Test-Path -LiteralPath $Path -PathType Leaf){@(Get-Item -LiteralPath $Path)}else{@(Get-ForgeFiles $Path)}
    foreach($file in $files){
        if($file.Length -gt 2MB -or $file.Name -match '^(\.env|id_rsa|id_ed25519)' -or $file.Extension -in @('.png','.jpg','.jpeg','.gif','.zip','.exe','.dll','.pdf','.woff','.ttf','.pem','.key')){continue}
        Select-String -LiteralPath $file.FullName -Pattern $Query -ErrorAction SilentlyContinue
    }
}
function ll([string]$Path='.') { Get-ChildItem -LiteralPath $Path | Sort-Object @{Expression='PSIsContainer';Descending=$true},Name | Select-Object Mode,LastWriteTime,Length,Name }
