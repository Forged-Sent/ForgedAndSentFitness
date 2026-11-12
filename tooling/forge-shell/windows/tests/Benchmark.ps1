#requires -Version 7.5
[CmdletBinding()]
param([ValidateRange(3,20)][int]$Samples=7,[string]$Engine=(Join-Path $PSHOME 'pwsh.exe'))
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$state=Join-Path $env:TEMP ('ForgeShell-benchmark-'+[guid]::NewGuid().ToString('N'))
$null=[IO.Directory]::CreateDirectory((Join-Path $state 'config'))
$config=Get-Content -LiteralPath (Join-Path $root 'config\settings.json') -Raw | ConvertFrom-Json -AsHashtable
$config.EnableDirectoryHistory=$false
$config | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $state 'config\settings.json')
$results=@()
try{
    foreach($i in 0..$Samples){
        foreach($mode in @('Bare','Profile','Editing')){
            $psi=[Diagnostics.ProcessStartInfo]::new($Engine);$psi.UseShellExecute=$false;$psi.CreateNoWindow=$true;$psi.RedirectStandardOutput=$true;$psi.RedirectStandardError=$true
            $psi.Environment['FORGE_HOME']=$state;$psi.Environment['FORGE_NO_EDITING']=''
            foreach($arg in @('-NoLogo','-NoProfile','-NonInteractive','-File',(Join-Path $PSScriptRoot 'Benchmark-Child.ps1'),'-PackageRoot',$root,'-Mode',$mode)){$psi.ArgumentList.Add($arg)}
            $watch=[Diagnostics.Stopwatch]::StartNew();$p=[Diagnostics.Process]::Start($psi);$out=$p.StandardOutput.ReadToEndAsync();$err=$p.StandardError.ReadToEndAsync()
            if(-not $p.WaitForExit(15000)){$p.Kill();throw 'Benchmark child timed out.'};$watch.Stop()
            if($p.ExitCode -ne 0){throw "Benchmark failed: $($err.Result)"}
            $sample=$out.Result | ConvertFrom-Json;$sample | Add-Member TotalMs $watch.Elapsed.TotalMilliseconds;$p.Dispose()
            if($i -gt 0){$results+=$sample}
        }
    }
    $summary=foreach($mode in @('Bare','Profile','Editing')){
        $rows=@($results | Where-Object Mode -eq $mode);$medianIndex=[int][math]::Floor($rows.Count/2)
        [pscustomobject]@{Mode=$mode;Samples=$Samples;ProcessMedianMs=[math]::Round(@($rows.TotalMs | Sort-Object)[$medianIndex],1);LoadMedianMs=[math]::Round(@($rows.LoadMs | Sort-Object)[$medianIndex],1);FirstPromptMedianMs=[math]::Round(@($rows.FirstPromptMs | Sort-Object)[$medianIndex],1);WarmPromptMeanMs=[math]::Round(($rows.WarmPromptMs | Measure-Object -Average).Average,2)}
    }
    $report=@{At=[datetime]::UtcNow.ToString('o');Engine=$Engine;Location=$PWD.Path;Method='Separate fresh -NoProfile processes; one warmup discarded per mode. Editing explicitly imports bundled PSReadLine in a redirected host; real interactive startup may differ.';Summary=$summary;Samples=$results}
    $reportPath=Join-Path $root 'data\benchmark.json';$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath
    $summary | Format-Table -AutoSize
    Write-Host "Report: $reportPath"
}finally{
    $resolved=[IO.Path]::GetFullPath($state);$allowed=[IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')+'\ForgeShell-benchmark-'
    if(-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)){throw 'Benchmark cleanup path rejected.'}
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
