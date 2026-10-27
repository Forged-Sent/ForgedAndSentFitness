# One-time GitHub setup for the planning workflow (Windows / PowerShell). Same as bootstrap_github.sh.
# Needs: GitHub CLI (winget install GitHub.cli), then `gh auth login` with admin rights on the repo.
# Run from the repository root:   powershell -ExecutionPolicy Bypass -File tools\planning\bootstrap_github.ps1
# Optional:                        ... -File tools\planning\bootstrap_github.ps1 -Repo owner/name -Protect
param(
  [string]$Repo = "sfcsmithc-afk/ForgedAndSentFitness",
  [switch]$Protect   # also apply branch protection to main (tools/planning/branch-protection.json)
)
$ErrorActionPreference = "Stop"
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "GitHub CLI not found. Install: winget install GitHub.cli, then run: gh auth login" }
if (-not (Test-Path ".github/labels.yml")) { throw "Run this from the repository root (.github/labels.yml not found)." }

# labels.yml uses one flow-style entry per line: - { name: x, color: "hex", description: "text" }
$pattern = '^\s*-\s*\{\s*name:\s*"?(?<name>[^",]+?)"?\s*,\s*color:\s*"(?<color>[0-9a-fA-F]{6})"\s*,\s*description:\s*"(?<desc>[^"]*)"\s*\}'
$count = 0
foreach ($line in Get-Content ".github/labels.yml") {
  $m = [regex]::Match($line, $pattern)
  if (-not $m.Success) { continue }
  gh label create $m.Groups["name"].Value --repo $Repo --color $m.Groups["color"].Value --description $m.Groups["desc"].Value --force
  if ($LASTEXITCODE -ne 0) { throw "gh label create failed for $($m.Groups['name'].Value)" }
  Write-Host "label $($m.Groups['name'].Value)"; $count++
}
Write-Host "`n$count labels created or updated on $Repo."

if ($Protect) {
  gh api -X PUT "repos/$Repo/branches/main/protection" --input "tools/planning/branch-protection.json"
  if ($LASTEXITCODE -ne 0) { throw "Branch protection failed (needs repo admin)." }
  Write-Host "Branch protection applied to main (required checks + code-owner review)."
} else {
  Write-Host "Branch protection: re-run with -Protect, or set it in GitHub > Settings > Branches."
}
Write-Host "Optional project board: gh auth refresh -s project; gh project create --owner $($Repo.Split('/')[0]) --title 'Forged & Sent planning'"
