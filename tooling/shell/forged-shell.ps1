# Requires PowerShell 7.6; scoped to the VS Code workspace terminal.
. (Join-Path $PSScriptRoot 'fs-tools.ps1')
function prompt {
  $branch=(& git branch --show-current 2>$null | Out-String).Trim()
  if($branch){
    $count=@(& git status --porcelain 2>$null).Count
    $label=if($branch -eq 'main'){'MAIN: use fs-start before making changes'}else{"working on $branch"}
    Write-Host ("Forged & Sent | "+$label+" | "+$count+" uncommitted change(s)") -ForegroundColor Cyan
  }
  return ('PS '+(Split-Path -Leaf (Get-Location).Path)+'> ')
}
Write-Host 'Forged & Sent terminal. Type fs-help for friendly Git commands.' -ForegroundColor Green
