# Project-only friendly Git workflow. These are convenience guards, not security.
Set-StrictMode -Version Latest
function Assert-FSRepo {
  & git rev-parse --show-toplevel 2>$null | Out-Null
  if($LASTEXITCODE){throw 'Open the cloned Forged & Sent repository in VS Code first.'}
}
function FSBranch { return ((& git branch --show-current | Out-String).Trim()) }
function Assert-FeatureBranch {
  Assert-FSRepo
  $branch=FSBranch
  if(-not $branch){throw 'Git is not on a branch (detached HEAD). Select a feature branch before editing; do not reset or force push.'}
  if($branch -eq 'main'){throw 'You are on the shared main branch. Use fs-start first.'}
}
function FSClean {
  return -not [bool](@(& git status --porcelain).Count)
}
function fs-status {
  Assert-FSRepo
  $branch=FSBranch
  $changes=@(& git status --porcelain).Count
  Write-Host ("Working on: " + $(if(-not $branch){'DETACHED HEAD (select a branch)'}elseif($branch -eq 'main'){'MAIN (start a branch before editing)'}else{$branch}))
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
  & git switch --no-track -c ("feature/"+$slug) origin/main
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
function Ensure-FSGitIdentity {
  Assert-FSRepo
  $name=((& git config --get user.name 2>$null | Out-String).Trim())
  $email=((& git config --get user.email 2>$null | Out-String).Trim())
  if($name -and $email){return}
  Write-Host 'Git needs a public commit name and email. A GitHub noreply email protects your personal address.' -ForegroundColor Yellow
  Write-Host 'Find it at github.com > Settings > Emails (it looks like 12345+name@users.noreply.github.com).'
  if(-not $name){
    $name=Read-Host 'Name shown on commits'
    if(-not $name -or $name -match '[\r\n]'){throw 'Enter a name before saving. Git settings were not changed.'}
  }
  if(-not $email){
    $email=Read-Host 'Git email (GitHub noreply recommended)'
    if(-not $email -or $email -notmatch '^[^\s@]+@[^\s@]+\.[^\s@]+$'){throw 'Enter a valid email before saving. Git settings were not changed.'}
  }
  & git config --local user.name $name
  if($LASTEXITCODE){throw 'Could not set local Git name.'}
  & git config --local user.email $email
  if($LASTEXITCODE){throw 'Could not set local Git email.'}
  Write-Host 'Git identity saved in this repository only (not globally).' -ForegroundColor Green
}
function fs-save([string]$message) {
  Assert-FeatureBranch
  if(-not $message){throw 'Example: fs-save "added workout timer button"'}
  if(FSClean){Write-Host 'Nothing changed since the last save.';return}
  Ensure-FSGitIdentity
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
  Write-Host 'Merging latest main into your feature branch without rewriting history...'
  & git merge --no-edit origin/main
  if($LASTEXITCODE){
    $mergeHead=(& git rev-parse -q --verify MERGE_HEAD 2>$null | Out-String).Trim()
    if($mergeHead){
      & git merge --abort
      if($LASTEXITCODE){throw 'Merge conflicted and abort failed. Stop and ask for help before changing anything.'}
      throw 'Merge conflict. The feature branch has been restored. Ask for help resolving it without force-pushing.'
    }
    throw 'Git could not complete the merge. Check git status before proceeding.'
  }
  Write-Host 'Latest main merged safely. Run your tests before sharing.' -ForegroundColor Green
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
  Write-Host 'Your changes are in a Draft PR. CI must pass; the maintainer makes the final merge decision.'
}
function fs-undo {
  Assert-FeatureBranch
  if(-not (FSClean)){throw 'There are uncommitted changes. Ask for help before undoing.'}
  $branch=FSBranch
  $remote=(& git ls-remote --heads origin $branch | Out-String).Trim()
  if($LASTEXITCODE){throw 'Unable to check GitHub. Undo is disabled while offline.'}
  $last=(& git rev-parse HEAD).Trim()
  $main=(& git rev-parse origin/main 2>$null | Out-String).Trim()
  if(-not $main){throw 'Unable to verify shared main; undo disabled until you sync.'}
  if($last -eq $main){throw 'You have not saved a feature commit to undo yet.'}

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
  Write-Host 'Branch = isolated work. Save (commit) = checkpoint. Draft PR = changes proposed to main.'
  Write-Host 'fs-start "new feature" : make a safe branch'
  Write-Host 'fs-save "my change"   : scan secrets and save'
  Write-Host 'fs-sync               : merge current main into your feature branch safely'
  Write-Host 'fs-share              : test and open a draft PR'
  Write-Host 'fs-status             : explain your current work'
  Write-Host 'fs-undo               : undo only the last unpublished save'
  Write-Host 'GitHub rules, not these commands, ultimately protect main.'
}
