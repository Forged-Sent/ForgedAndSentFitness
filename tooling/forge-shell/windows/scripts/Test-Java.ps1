#requires -Version 7.5
param([Parameter(Mandatory)][string]$ProjectRoot)
$ErrorActionPreference='Stop'
# This model defines read-only probes; unlike ensure-java21.ps1 it does not install anything.
. (Join-Path $ProjectRoot 'tooling\windows\diagnostic-model.ps1')
$java=Find-FSJava21
if(-not $java -or $java.Major -lt 21){throw 'Java 21 is missing. Approve a separate installation before starting emulators.'}
$java | Select-Object Home,Major,Exe | ConvertTo-Json -Compress
