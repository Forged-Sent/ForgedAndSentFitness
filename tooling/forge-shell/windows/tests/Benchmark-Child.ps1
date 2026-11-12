param([string]$PackageRoot,[ValidateSet('Bare','Profile','Editing')][string]$Mode='Bare')
$watch=[Diagnostics.Stopwatch]::StartNew()
if($Mode -eq 'Editing'){Import-Module PSReadLine}
if($Mode -ne 'Bare'){. (Join-Path $PackageRoot 'Microsoft.PowerShell_profile.ps1')}
$watch.Stop()
$first=$null;$warm=$null
if($Mode -ne 'Bare'){
    $p=[Diagnostics.Stopwatch]::StartNew();$null=prompt;$p.Stop();$first=$p.Elapsed.TotalMilliseconds
    $samples=foreach($i in 1..20){$p.Restart();$null=prompt;$p.Stop();$p.Elapsed.TotalMilliseconds};$warm=($samples | Measure-Object -Average).Average
}
[pscustomobject]@{Mode=$Mode;LoadMs=$watch.Elapsed.TotalMilliseconds;FirstPromptMs=$first;WarmPromptMs=$warm} | ConvertTo-Json -Compress
