# Project-only friendly Git workflow. These are convenience guards, not security.
Set-StrictMode -Version Latest
function Assert-FSRepo {
  & git rev-parse --show-toplevel 2>$null | Out-Null
  if($LASTEXITCODE){throw 'Open the cloned Forged & Sent repository in VS Code first.'}
}
function FSBranch { (& git branch --show-current).Trim() }
function Assert-FeatureBranch {
  Assert-FSRepo
  $branch=FSBranch
  if(-not $branch -or $branch -eq 'main'){throw 'You are on the shared main branch. Use fs-start first.'}
}
function FSClean {
  return -not [bool](@(& git status --porcelain).Count)
}
function fs-status {
  Assert-FSRepo
  $branch=FSBranch
  $changes=@(& git status --porcelain).Count
  Write-Host ("Working on: " + $(if($branch -eq 'main'){'MAIN (start a branch before editing)'}else{$branch}))
  Write-Host "$changes uncommitted change(s)."
  & git status -sb
  if($branch -eq 'main'){Write-Host 'Next: fs-start "describe your change"'}
  elseif($changes){Write-Host 'Next: fs-save "describe what you changed"'}
  else{Write-Host 'Next: fs-share when your work is ready for review.'}
}
function fs-start([string]$description) {
  Assert-FSRepo
  if(-not $description){throw 'Example: fs-start "add workout timer"'}
  if(-not (FSClean)){throw 'You have uncommitted changes. Finish or ask AI for help before starting a new branch.'}
  $slug=($description.ToLowerInvariant() -replace '[^a-z0-9]+','-').Trim('-')
  if(-not $slug){throw 'Describe the change using letters or numbers.'}
  $slug=$slug.Substring(0,[Math]::Min(40,$slug.Length))
  & git fetch origin main
  if($LASTEXITCODE){throw 'Unable to download latest main. Check internet/GitHub login.'}
  & git switch -c ("feature/"+$slug) origin/main
  if($LASTEXITCODE){throw 'Branch name already used. Try a different description.'}
  Write-Host 'Your own working branch is ready. Make changes, then run fs-save.'
}
function FSCheck {
  Assert-FeatureBranch
  $root=(& git rev-parse --show-toplevel).Trim()
  $mobile=Join-Path $root 'mobile'
  if(-not (Test-Path (Join-Path $mobile 'pubspec.yaml'))){throw 'Flutter mobile project missing.'}
  Push-Location $mobile
  try{
    & flutter analyze
    if($LASTEXITCODE){throw 'Flutter analyze found errors. Ask AI to explain the diagnostics.'}
    & flutter test
    if($LASTEXITCODE){throw 'Flutter tests failed. Fix them before sharing.'}
  }finally{Pop-Location}
}
function fs-save([string]$message) {
  Assert-FeatureBranch
  if(-not $message){throw 'Example: fs-save "added workout timer button"'}
  if(FSClean){Write-Host 'Nothing changed since the last save.';return}
  & git add -A
  if($LASTEXITCODE){throw 'Unable to stage changes.'}
  $staged=@(& git diff --cached --name-only)
  foreach($path in $staged){
    $file=Join-Path (& git rev-parse --show-toplevel).Trim() $path
    if((Test-Path -LiteralPath $file -PathType Leaf) -and (Get-Item -LiteralPath $file).Length -gt 5MB){
      throw "File exceeds 5 MB: $path. Use appropriate large-file storage."
    }
  }
  $leaks=Get-Command gitleaks -ErrorAction SilentlyContinue|Select-Object -First 1
  if(-not $leaks){throw 'Gitleaks missing. Run Contributor setup; never skip the secret check.'}
  & $leaks.Source git --staged --redact --no-banner
  if($LASTEXITCODE){throw 'Potential secret detected. Remove it before saving.'}
  & git commit -m $message
  if($LASTEXITCODE){throw 'Save failed. Check hooks or Git name/email setup.'}
  Write-Host 'Saved on your feature branch. Use fs-share when ready.'
}
function fs-sync {
  Assert-FeatureBranch
  if(-not (FSClean)){throw 'You have uncommitted changes. Save or ask for help first.'}
  & git fetch origin main
  if($LASTEXITCODE){throw 'Could not fetch latest main.'}
  & git merge-base --is-ancestor origin/main HEAD
  if($LASTEXITCODE -eq 0){Write-Host 'Your branch already includes the latest main.';return}
  Write-Host 'Main has new changes. Automatic history rewriting is disabled for safety.' -ForegroundColor Yellow
  Write-Host 'Ask an AI reviewer: How do I safely bring origin/main into this branch?'
}
function fs-share {
  Assert-FeatureBranch
  if(-not (FSClean)){throw 'Save your changes with fs-save first.'}
  FSCheck
  & git push --set-upstream origin HEAD
  if($LASTEXITCODE){throw 'Could not share branch. Check GitHub access.'}
  & gh pr create --draft --base main --fill
  if($LASTEXITCODE){
    Write-Host 'A PR may already exist. Checking for a URL.'
    & gh pr view --web
  }
  Write-Host 'Your changes are shared in a DRAFT PR. A human must review and merge them.'
}
function fs-undo {
  Assert-FeatureBranch
  if(-not (FSClean)){throw 'There are uncommitted changes. Ask for help before undoing.'}
  $branch=FSBranch
  $remote=(& git ls-remote --heads origin $branch | Out-String).Trim()
  if($LASTEXITCODE){throw 'Unable to check GitHub. Undo is disabled while offline.'}
  $last=(& git rev-parse HEAD).Trim()
  if($remote){
    $sha=($remote -split '\s+')[0]
    if($sha -eq $last){throw 'The last save is already shared. Do not rewrite it; make a new commit instead.'}
  }
  Write-Host 'Undo will turn the last LOCAL commit back into uncommitted changes.'
  $choice=Read-Host 'Type UNDO to confirm'
  if($choice -ne 'UNDO'){Write-Host 'No changes made.';return}
  & git reset --soft HEAD~1
  if($LASTEXITCODE){throw 'Unable to undo. No changes were shared or deleted.'}
  Write-Host 'Last unshared commit undone; file changes were preserved.'
}
function fs-help {
  Write-Host 'Branch = your own copy. Save (commit) = checkpoint. Draft PR = request human review.'
  Write-Host 'fs-start "new feature" : make a safe branch'
  Write-Host 'fs-save "my change"   : scan secrets and save'
  Write-Host 'fs-sync               : check for changes on main safely'
  Write-Host 'fs-share              : test and open a draft PR'
  Write-Host 'fs-status             : explain your current work'
  Write-Host 'fs-undo               : undo only the last unpublished save'
  Write-Host 'GitHub rules, not these commands, ultimately protect main.'
}
