BeforeAll {
  . "$PSScriptRoot/../../shell/fs-tools.ps1"
}
Describe 'Beginner Git helpers (real local Git, no network)' {
  BeforeEach {
    $script:previousLocation=(Get-Location).Path
    $script:repoPath=Join-Path $TestDrive ([guid]::NewGuid().ToString('n'))
    & git init --quiet --initial-branch=main $script:repoPath | Out-Null
    if($LASTEXITCODE){throw 'Git init failed'}
    & git -C $script:repoPath -c user.name='CI Test' -c user.email='ci@example.invalid' commit --quiet --allow-empty -m 'initial'
    if($LASTEXITCODE){throw 'Git initial commit failed'}
    Set-Location $script:repoPath
  }
  AfterEach {
    Set-Location $script:previousLocation
  }
  It 'handles detached HEAD without a PowerShell crash' {
    & git switch --quiet --detach HEAD
    FSBranch | Should -Be ''
    {Assert-FeatureBranch} | Should -Throw '*detached HEAD*'
  }
  It 'uses --no-track so new feature branches do not track main' {
    $remote=Join-Path $TestDrive ([guid]::NewGuid().ToString('n')+'.git')
    & git init --quiet --bare $remote
    & git remote add origin $remote
    & git push --quiet --set-upstream origin main
    fs-start 'first contribution'
    FSBranch | Should -Be 'feature/first-contribution'
    $upstream=(& git config --get 'branch.feature/first-contribution.remote' 2>$null | Out-String).Trim()
    $upstream | Should -Be ''
  }
  It 'recognizes an already configured local Git identity' {
    & git config --local user.name 'A Contributor'
    & git config --local user.email '12345+example@users.noreply.github.com'
    {Ensure-FSGitIdentity} | Should -Not -Throw
    (& git config --local user.email) | Should -Be '12345+example@users.noreply.github.com'
  }
  It 'merges main without rewriting feature history' {
    $remote=Join-Path $TestDrive ([guid]::NewGuid().ToString('n')+'.git')
    & git init --quiet --bare $remote
    & git remote add origin $remote
    & git push --quiet --set-upstream origin main
    fs-start 'merge scenario'
    & git config --local user.name 'CI Test'
    & git config --local user.email 'ci@example.invalid'
    & git commit --quiet --allow-empty -m 'feature'
    & git switch --quiet main
    & git commit --quiet --allow-empty -m 'main advanced'
    & git push --quiet origin main
    & git switch --quiet feature/merge-scenario
    fs-sync
    & git merge-base --is-ancestor origin/main HEAD
    $LASTEXITCODE | Should -Be 0
    FSBranch | Should -Be 'feature/merge-scenario'
  }
}
