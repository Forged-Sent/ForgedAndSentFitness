# Server-side GitHub protection: administrator checklist

The connected GitHub tool has push but not repository administrator permission. These settings are NOT enabled by committing this file.

## Enable now
1. GitHub > Settings > Rules > Rulesets > New branch ruleset for main: Require pull request; block force-push and branch deletion. No direct-push bypass. Allow administrator bypass only in "For pull requests only" mode, if strictly necessary.
2. GitHub > Settings > Security > Code security and analysis: enable secret scanning and push protection where the public repository settings provide them.
3. Do not publish actual secrets to test protection.

## After PR #3 merges
1. Add the second real developer GitHub handle to CODEOWNERS. The currently verified owner is @sfcsmithc-afk. **Do not enable mandatory code-owner review while sole owner is authoring PRs.**
2. Require one human approval AND required code-owner review in the main ruleset.
3. Require only the always-present ci-gate job, never path-filtered workflow jobs.
4. Verify direct main pushes are rejected and intentionally failed CI makes ci-gate fail.

AI agent reviews are advisory and do not satisfy human approvals. Rulesets, not local hooks or CODEOWNERS alone, enforce server protection.

Settings: https://github.com/sfcsmithc-afk/ForgedAndSentFitness/settings/rules
