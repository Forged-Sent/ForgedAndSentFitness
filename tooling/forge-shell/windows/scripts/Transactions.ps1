function Get-ForgeFileHash([string]$Path){if([IO.File]::Exists($Path)){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash}else{$null}}
function New-ForgeTransaction([string]$Root,[string[]]$Targets,[string]$Kind){
    $dir=Join-Path $Root ('backups\'+[datetime]::Now.ToString('yyyyMMdd-HHmmss-fff')+'-'+$Kind+'-'+[guid]::NewGuid().ToString('N').Substring(0,6))
    $null=[IO.Directory]::CreateDirectory($dir)
    $entries=@();$n=0
    foreach($target in $Targets){
        $target=[IO.Path]::GetFullPath($target)
        $exists=[IO.File]::Exists($target);$backup="$n.bin";$n++
        if($exists){[IO.File]::Copy($target,(Join-Path $dir $backup))}
        $entries+=@{Target=$target;Existed=$exists;BackupFile=$backup;OriginalHash=(Get-ForgeFileHash $target);InstalledHash=$null;Written=$false}
    }
    $tx=@{SchemaVersion=1;Kind=$Kind;At=[datetime]::UtcNow.ToString('o');Status='prepared';Entries=$entries;Directory=$dir}
    Save-ForgeTransaction $tx
    return $tx
}
function Save-ForgeTransaction($Transaction){
    [IO.File]::WriteAllText((Join-Path $Transaction.Directory 'manifest.json'),($Transaction | ConvertTo-Json -Depth 10),[Text.UTF8Encoding]::new($false))
}
function Write-ForgeTransactionFile($Transaction,[string]$Target,[string]$Text){
    $entry=$Transaction.Entries | Where-Object Target -eq ([IO.Path]::GetFullPath($Target)) | Select-Object -First 1
    if(-not $entry){throw 'Target not covered by backup.'}
    if((Get-ForgeFileHash $Target) -ne $entry.OriginalHash){throw "Concurrent edit detected: $Target. Nothing overwritten."}
    $null=[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Target))
    $tmp=$Target+'.forge-'+[guid]::NewGuid().ToString('N')+'.tmp'
    try{[IO.File]::WriteAllText($tmp,$Text,[Text.UTF8Encoding]::new($false));[IO.File]::Move($tmp,$Target,$true)}finally{if([IO.File]::Exists($tmp)){[IO.File]::Delete($tmp)}}
    $entry.InstalledHash=Get-ForgeFileHash $Target;$entry.Written=$true;Save-ForgeTransaction $Transaction
}
function Undo-ForgeTransaction($Transaction){
    foreach($entry in $Transaction.Entries){
        if(-not $entry.Written){continue}
        if((Get-ForgeFileHash $entry.Target) -ne $entry.InstalledHash){throw "Concurrent edit detected during recovery: $($entry.Target)"}
        if($entry.Existed){[IO.File]::Copy((Join-Path $Transaction.Directory $entry.BackupFile),$entry.Target,$true)}
        elseif([IO.File]::Exists($entry.Target)){[IO.File]::Delete($entry.Target)}
    }
    $Transaction.Status='rolled-back';Save-ForgeTransaction $Transaction
}
