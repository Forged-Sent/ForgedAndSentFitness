# Forged-Sent organization security: administrator checklist

The repository is now under the Forged-Sent organization, and @Chadillac12 has Admin permission. This GitHub connection can write repository files but has no available ruleset/secret-scanning configuration action. These server protections are NOT enabled by committing this file.

## Enable now
1. GitHub > Settings > Rules > Rulesets > New branch ruleset for main: Require pull request; block force-push and branch deletion. No direct-push bypass. Allow administrator bypass only in "For pull requests only" mode, if strictly necessary.
2. GitHub > Settings > Security > Code security and analysis: enable secret scanning and push protection where the public repository settings provide them.
3. Do not publish actual secrets to test protection.

## After PR #3 merges and the named human owners have write access
1. Confirm both @Chadillac12 and @sfcsmithc-afk have write-or-higher organization repository permission. They are both listed in CODEOWNERS, and authors cannot approve their own pull requests.
2. Require one human approval AND required code-owner review in the main ruleset.
3. Require only the always-present ci-gate job, never path-filtered workflow jobs.
4. Verify direct main pushes are rejected and intentionally failed CI makes ci-gate fail.

AI agent reviews are advisory and do not satisfy human approvals. Rulesets, not local hooks or CODEOWNERS alone, enforce server protection.

Settings: https://github.com/Forged-Sent/ForgedAndSentFitness/settings/rules

**After transfer:** Check organization GitHub App access, Actions permissions and Git remotes. Use `https://github.com/Forged-Sent/ForgedAndSentFitness.git` for new clones.
